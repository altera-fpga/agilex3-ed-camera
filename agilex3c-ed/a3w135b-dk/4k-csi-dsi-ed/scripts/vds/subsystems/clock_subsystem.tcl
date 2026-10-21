package require ::quartus::project

set script_dir [file dirname [file normalize [info script]]]
set project_dir [file normalize "${script_dir}/../../.."]

if {![is_project_open]} {
  cd $project_dir
  project_open top -revision top
}

source "${project_dir}/scripts/vds/lib/vds_helpers.tcl"

# ---------------------------------------------------------------------------
# Parameters
# ---------------------------------------------------------------------------

set GEN_CLK_FREQ { 148.5 297.0 16.0 }
set RESET_MIN_LENGTH 3000
set EXPORT_TO_TOP 0
set REMOTE_RESET_EN 0
set NUM_RESETS 1
set IOPLL_EN_PERMIT_CAL 0

set REF_CLK_FREQ 100
set REF_CLK_FREQ_HZ [expr {int($REF_CLK_FREQ * 1000000)}]

set NUM_GEN_CLOCKS [llength $GEN_CLK_FREQ]
set MAX_IOPLL_CLKS 8
set NUM_IOPLLS [expr {1 + ($NUM_GEN_CLOCKS - 1) / $MAX_IOPLL_CLKS}]


set params_str "NUM_GEN_CLOCKS=$NUM_GEN_CLOCKS"
append params_str ", GEN_CLK_FREQ={$GEN_CLK_FREQ}"
append params_str ", REF_CLK_FREQ=$REF_CLK_FREQ"

puts "clock_subsystem: creating system"
puts "clock_subsystem: subsystem parameters: $params_str"
::vh::new_system "clock_subsystem"

# ===========================================================================
# 1. input layer
# ===========================================================================

puts "clock_subsystem: creating and wiring input clock/reset bridges"
::vh::create_cell input_clk_bridge altera_clock_bridge [subst {
    NUM_CLOCK_OUTPUTS   1
    EXPLICIT_CLOCK_RATE $REF_CLK_FREQ_HZ
}]

set num_reset_inputs [expr {$NUM_RESETS + $REMOTE_RESET_EN}]

::vh::create_cell input_rst_ctrl altera_reset_controller [subst {
    NUM_RESET_INPUTS         1
    MIN_RST_ASSERTION_TIME   3
    OUTPUT_RESET_SYNC_EDGES  deassert
    SYNC_DEPTH               2
    RESET_REQUEST_PRESENT    0
    USE_RESET_REQUEST_INPUT  0
    NUM_RESET_INPUTS $num_reset_inputs
}]

::vh::connect_pin {input_clk_bridge out_clk} {input_rst_ctrl clk}

for {set rst_id 0} {$rst_id < $NUM_RESETS} {incr rst_id} {
  ::vh::create_cell input_rst_${rst_id}_bridge altera_reset_bridge {
      ACTIVE_LOW_RESET   0
      SYNCHRONOUS_EDGES  none
      NUM_RESET_OUTPUTS  1
      USE_RESET_REQUEST  0
      SYNC_RESET         0
  }
  ::vh::connect_pin [list input_rst_${rst_id}_bridge out_reset] [list input_rst_ctrl reset_in${rst_id}]
}

# JTAG remote reset master
if {$REMOTE_RESET_EN} {
  ::vh::create_cell input_jtag_reset altera_jtag_avalon_master {}
  ::vh::connect_pin {input_clk_bridge out_clk} {input_jtag_reset clk}
  ::vh::connect_pin {input_rst_1_bridge out_reset} {input_jtag_reset clk_reset}
  set jtag_rst_id [expr {$NUM_RESETS + 1}]
  ::vh::connect_pin {input_jtag_reset master_reset} [list input_rst_ctrl reset_in${jtag_rst_id}]
}

# ===========================================================================
# 2. generation layer (IOPLL(s) + locked shim)
# ===========================================================================

puts "clock_subsystem: creating and wring up IOPLLS"
for {set i 0} {$i < $NUM_GEN_CLOCKS} {incr i} {
  set pll_index [expr {$i / $MAX_IOPLL_CLKS}]
  set pll_output_index [expr {$i % $MAX_IOPLL_CLKS}]

  if {$pll_output_index == 0} {
    if {$NUM_GEN_CLOCKS <= ($pll_index + 1) * $MAX_IOPLL_CLKS} {
      set gui_number_of_clocks [expr {$NUM_GEN_CLOCKS - $pll_index * $MAX_IOPLL_CLKS}]
    } else {
      set gui_number_of_clocks $MAX_IOPLL_CLKS
    }

    ::vh::create_cell iopll_${pll_index} altera_iopll {}
    ::vh::set_params iopll_${pll_index} [list \
      gui_reference_clock_frequency $REF_CLK_FREQ \
      gui_use_locked 1 \
      gui_en_adv_params 0 \
      gui_operation_mode direct \
      gui_number_of_clocks $gui_number_of_clocks \
      gui_fix_vco_frequency 0 \
      gui_clock_name_global 0 \
      gui_clock_name_instantiation 0 \
      gui_enable_permit_cal $IOPLL_EN_PERMIT_CAL \
      gui_pll_bandwidth_preset Medium \
      gui_pll_auto_reset 0 \
      gui_refclk_switch 0]

    ::vh::create_cell iopll_locked_shim_${pll_index} intel_iopll_locked_shim {}

    ::vh::connect_pin {input_clk_bridge out_clk} [list iopll_${pll_index} refclk]
    ::vh::connect_pin {input_rst_ctrl reset_out} [list iopll_${pll_index} reset]
    ::vh::connect_pin [list iopll_${pll_index} locked] [list iopll_locked_shim_${pll_index} locked_in]
  }

  set clk_freq [lindex $GEN_CLK_FREQ $i]
  ::vh::set_params iopll_${pll_index} [list \
    gui_clock_name_string${pll_output_index} clk_${i} \
    gui_output_clock_frequency${pll_output_index} $clk_freq \
    gui_ps_units${pll_output_index} ps \
    gui_phase_shift${pll_output_index} 0 \
    gui_duty_cycle${pll_output_index} 50.0]
}

# ===========================================================================
# 3. iopll reset sync layer
# ===========================================================================

puts "clock_subsystem: creating and wring up reset synchronizers and extenders"
::vh::create_cell reset_extender intel_vvp_reset_extend {
    RESYNC_RESET_IN  0
    SYNC_LEN         3
    DUAL_CONDUIT_OUT 0
}
::vh::set_param reset_extender RESET_MIN_LENGTH $RESET_MIN_LENGTH
::vh::connect_pin {input_clk_bridge out_clk} {reset_extender clk}

set num_reset_sources [expr {$NUM_IOPLLS + 1}]

if {$num_reset_sources > 1} {
  ::vh::create_cell reset_sync altera_reset_controller {
        OUTPUT_RESET_SYNC_EDGES deassert
        SYNC_DEPTH              2
        RESET_REQUEST_PRESENT   0
        USE_RESET_REQUEST_INPUT 0
    }
  ::vh::set_param reset_sync NUM_RESET_INPUTS $num_reset_sources

  ::vh::connect_pin {input_clk_bridge out_clk} {reset_sync clk}
  ::vh::connect_pin {input_rst_ctrl reset_out} {reset_sync reset_in0}

  for {set i 0} {$i < $NUM_IOPLLS} {incr i} {
    set j [expr {$i + 1}]
    ::vh::connect_pin [list iopll_locked_shim_${i} reset] [list reset_sync reset_in${j}]
  }

  ::vh::connect_pin {reset_sync reset_out} {reset_extender in_reset}
} else {
  ::vh::connect_pin {input_rst_ctrl reset_out} {reset_extender in_reset}
}

# ===========================================================================
# 4. local reset sync layer
# ===========================================================================

::vh::create_cell ref_clk_reset_sync intel_vip_reset_sync_block {
    GEN_OUT_CLK            1
    ASYNC_RESET            1
    SYNC_DEPTH             3
    ADDITIONAL_DEPTH       2
    DISABLE_GLOBAL_NETWORK 1
}
::vh::set_param ref_clk_reset_sync INPUT_CLOCK_FREQUENCY $REF_CLK_FREQ_HZ
::vh::connect_pin {input_clk_bridge out_clk} {ref_clk_reset_sync clock_in}
::vh::connect_pin {reset_extender out_reset} {ref_clk_reset_sync reset_in}

for {set i 0} {$i < $NUM_GEN_CLOCKS} {incr i} {
  set pll_index [expr {$i / $MAX_IOPLL_CLKS}]
  set pll_output_index [expr {$i % $MAX_IOPLL_CLKS}]
  set clk_freq_hz [expr {int([lindex $GEN_CLK_FREQ $i] * 1000000)}]
  set name gen_clk_${i}

  ::vh::create_cell ${name}_reset_sync intel_vip_reset_sync_block {
        GEN_OUT_CLK            1
        ASYNC_RESET            1
        SYNC_DEPTH             3
        ADDITIONAL_DEPTH       2
        DISABLE_GLOBAL_NETWORK 1
    }
  ::vh::set_param ${name}_reset_sync INPUT_CLOCK_FREQUENCY $clk_freq_hz

  ::vh::connect_pin [list iopll_${pll_index} outclk${pll_output_index}] [list ${name}_reset_sync clock_in]
  ::vh::connect_pin {reset_extender out_reset} [list ${name}_reset_sync reset_in]
}

# ===========================================================================
# 5. output layer (EXPORT_TO_TOP=1 branch: extra duplicate export bridges)
# ===========================================================================

::vh::create_cell ref_clk_export_bridge altera_clock_bridge {
    NUM_CLOCK_OUTPUTS 2
}
::vh::set_param ref_clk_export_bridge EXPLICIT_CLOCK_RATE $REF_CLK_FREQ_HZ

::vh::create_cell ref_rst_export_bridge altera_reset_bridge {
    ACTIVE_LOW_RESET  0
    SYNCHRONOUS_EDGES deassert
    NUM_RESET_OUTPUTS 2
    USE_RESET_REQUEST 0
    SYNC_RESET        0
}

::vh::connect_pin {ref_clk_reset_sync clock_out} {ref_clk_export_bridge in_clk}
::vh::connect_pin {ref_clk_reset_sync clock_out} {ref_rst_export_bridge clk}
::vh::connect_pin {ref_clk_reset_sync reset_out} {ref_rst_export_bridge in_reset}

for {set i 0} {$i < $NUM_GEN_CLOCKS} {incr i} {
  set clk_freq_hz [expr {int([lindex $GEN_CLK_FREQ $i] * 1000000)}]
  set name gen_clk_${i}

  ::vh::create_cell ${name}_clk_export_bridge altera_clock_bridge {
        NUM_CLOCK_OUTPUTS 2
    }
  ::vh::set_param ${name}_clk_export_bridge EXPLICIT_CLOCK_RATE $clk_freq_hz

  ::vh::create_cell ${name}_rst_export_bridge altera_reset_bridge {
        ACTIVE_LOW_RESET  0
        SYNCHRONOUS_EDGES deassert
        NUM_RESET_OUTPUTS 2
        USE_RESET_REQUEST 0
        SYNC_RESET        0
    }

  ::vh::connect_pin [list ${name}_reset_sync clock_out] [list ${name}_clk_export_bridge in_clk]
  ::vh::connect_pin [list ${name}_reset_sync clock_out] [list ${name}_rst_export_bridge clk]
  ::vh::connect_pin [list ${name}_reset_sync reset_out] [list ${name}_rst_export_bridge in_reset]
}

# ---------------------------------------------------------------------------
# Exports
# ---------------------------------------------------------------------------

puts "clock_subsystem: exporting clocks and resets"
# input side
# Note: the original MDT script exports input_rst_0_bridge.in_reset under
# TWO boundary names (i_rst_0 generically, and ia_board_reset for
# auto-connect_pin matching) -- VDS does not allow exporting the same pin twice,
# so only the one actually consumed at the top level (ia_board_reset) is
# kept here; i_rst_0 was never re-exported to top.v by edit_top_level_qsys
# anyway when NUM_RESETS=1 (its loop only covers reset ids >= 1).
::vh::export_pin {input_clk_bridge in_clk} i_ref_clk
::vh::export_pin {input_rst_0_bridge in_reset} i_ref_rst

# reference clock / reset (duplicated: plain + "_export" alias, matching the
# original's o_ref_clk / o_ref_clk_export pair used by add_auto_connection at
# the top level)
::vh::export_pin {ref_clk_export_bridge out_clk} o_ref_clk
::vh::export_pin {ref_clk_export_bridge out_clk_1} o_ref_clk_export
::vh::export_pin {ref_rst_export_bridge out_reset} o_ref_rst
::vh::export_pin {ref_rst_export_bridge out_reset_1} o_ref_rst_export

# generated clocks / resets, plus one "iopll_<n>_locked" conduit per PLL
for {set i 0} {$i < $NUM_GEN_CLOCKS} {incr i} {
  set pll_index [expr {$i / $MAX_IOPLL_CLKS}]
  set pll_output_index [expr {$i % $MAX_IOPLL_CLKS}]
  set name gen_clk_${i}

  if {$pll_output_index == 0} {
    ::vh::export_pin [list iopll_locked_shim_${pll_index} locked_out] o_iopll_${pll_index}_locked
    ::vh::export_pin [list iopll_locked_shim_${pll_index} locked_out_1] o_iopll_${pll_index}_locked_export
  }

  ::vh::export_pin [list ${name}_clk_export_bridge out_clk] o_${name}_clk
  ::vh::export_pin [list ${name}_clk_export_bridge out_clk_1] o_${name}_clk_export
  ::vh::export_pin [list ${name}_rst_export_bridge out_reset] o_${name}_rst
  ::vh::export_pin [list ${name}_rst_export_bridge out_reset_1] o_${name}_rst_export
}

::vh::sync

puts "clock_subsystem: build complete"
