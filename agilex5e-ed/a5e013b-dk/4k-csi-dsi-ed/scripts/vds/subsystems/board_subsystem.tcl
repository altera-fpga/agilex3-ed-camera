package require ::quartus::project

set script_dir [file dirname [file normalize [info script]]]
set project_dir [file normalize "${script_dir}/../../.."]

if {![is_project_open]} {
  cd $project_dir
  project_open top -revision top
}

source "${project_dir}/scripts/vds/lib/vds_helpers.tcl"

# ---------------------------------------------------------------------------
# Parameters (production values, see header comment)
# ---------------------------------------------------------------------------

set USER_LED_TO_AVMM_EN 1
set USER_PB_TO_AVMM_EN 1
set DEVICE_READY_EN 1

puts "board_subsystem: creating system"

set params_str "USER_LED_TO_AVMM_EN=$USER_LED_TO_AVMM_EN"
append params_str ", USER_PB_TO_AVMM_EN=$USER_PB_TO_AVMM_EN"
append params_str ", DEVICE_READY_EN=$DEVICE_READY_EN"
puts "board_subsystem: subsystem parameters: $params_str"

::vh::new_system "board_subsystem"

# -----------------------------------------------------------------------------
# Instances
# -----------------------------------------------------------------------------

puts "board_subsystem: creating cells"
::vh::create_cell board_clk_bridge altera_clock_bridge {
    EXPLICIT_CLOCK_RATE 100000000.0
    NUM_CLOCK_OUTPUTS   2
}

::vh::create_cell board_pb_reset_generator intel_vip_reset_gen_block {
    CNTR_WIDTH 23
}

::vh::create_cell board_init_generator intel_user_rst_clkgate {
    outputType {Reset Interface}
}

::vh::create_cell board_init_reset_bridge altera_reset_bridge {
    NUM_RESET_OUTPUTS 3
}

::vh::create_cell board_reset_controller altera_reset_controller {
    NUM_RESET_INPUTS        2
    MIN_RST_ASSERTION_TIME  3
    OUTPUT_RESET_SYNC_EDGES deassert
    SYNC_DEPTH              2
    RESET_REQUEST_PRESENT   0
    USE_RESET_REQUEST_INPUT 0
}

set avmm_num [expr {$USER_LED_TO_AVMM_EN + $USER_PB_TO_AVMM_EN}]

set avmm_bridge_en [expr {$avmm_num > 1}]

if {$avmm_bridge_en} {
  ::vh::create_cell io_data_clk_bridge altera_clock_bridge {
    NUM_CLOCK_OUTPUTS   {1}
    EXPLICIT_CLOCK_RATE {0}
  }

  ::vh::create_cell io_data_rst_bridge altera_reset_bridge {
    NUM_RESET_OUTPUTS   {1}
  }

  ::vh::create_cell io_data_avmm_bridge altera_avalon_mm_bridge {
    SYNC_RESET             {0}
    DATA_WIDTH             {32}
    SYMBOL_WIDTH           {8}
    ADDRESS_WIDTH          {0}
    USE_AUTO_ADDRESS_WIDTH {1}
    ADDRESS_WIDTH          {SYMBOLS}
    MAX_BURST_SIZE         {1}
    LINEWRAPBURSTS         {0}
    MAX_PENDING_RESPONSES  {4}
    PIPELINE_COMMAND       {1}
    PIPELINE_RESPONSE      {1}
    USE_RESPONSE           {0}
  }
}

if {$USER_LED_TO_AVMM_EN} {
  ::vh::create_cell user_led_pio altera_avalon_pio {
    WIDTH              {8}
    DIRECTION          {Output}
    resetValue         {0x0}
    bitModifyingOutReg {0}
  }
}

if {$USER_PB_TO_AVMM_EN} {
  ::vh::create_cell user_pb_pio altera_avalon_pio {
    WIDTH                {8}
    DIRECTION            {Input}
    captureEdge          {0}
    generateIRQ          {0}
    simDoTestBenchWiring {0}
  }
}

::vh::sync

# -----------------------------------------------------------------------------
# Wiring
# -----------------------------------------------------------------------------

puts "board_subsystem: wiring up cells"
::vh::connect_pin {board_clk_bridge out_clk_1} {board_pb_reset_generator clk}
::vh::connect_pin {board_clk_bridge out_clk_1} {board_init_reset_bridge clk}
::vh::connect_pin {board_clk_bridge out_clk_1} {board_reset_controller clk}

::vh::connect_pin {board_pb_reset_generator reset} {board_reset_controller reset_in0}

::vh::connect_pin {board_init_generator ninit_done} {board_init_reset_bridge in_reset}

::vh::connect_pin {board_init_reset_bridge out_reset} {board_reset_controller reset_in1}

if {$avmm_bridge_en} {
  ::vh::connect_pin {io_data_clk_bridge out_clk} {io_data_avmm_bridge clk}
  ::vh::connect_pin {io_data_clk_bridge out_clk} {io_data_rst_bridge  clk}

  ::vh::connect_pin {io_data_rst_bridge out_reset} {io_data_avmm_bridge reset}

  if {$USER_LED_TO_AVMM_EN} {
    ::vh::connect_pin {io_data_clk_bridge  out_clk} {user_led_pio clk }
    ::vh::connect_pin {io_data_rst_bridge  out_reset} {user_led_pio reset}
    ::vh::connect_if {io_data_avmm_bridge m0} {user_led_pio s1  }
  }

  if {$USER_PB_TO_AVMM_EN} {
    ::vh::connect_pin {io_data_clk_bridge  out_clk} {user_pb_pio clk }
    ::vh::connect_pin {io_data_rst_bridge  out_reset} {user_pb_pio reset}
    ::vh::connect_if {io_data_avmm_bridge m0} {user_pb_pio s1  }
  }
}

# -----------------------------------------------------------------------------
# Assign base addresses
# -----------------------------------------------------------------------------

puts "board_subsystem: assigning base addresses"

vds::assign_base_address

::vh::sync

# -----------------------------------------------------------------------------
# Exports
# -----------------------------------------------------------------------------

puts "board_subsystem: exporting pins/interfaces"

::vh::export_pin {board_clk_bridge in_clk} i_clk
::vh::export_pin {board_clk_bridge out_clk} o_clk
::vh::export_pin {board_pb_reset_generator pb_resetn} ia_reset_pb_n
::vh::export_pin {board_reset_controller reset_out} o_reset

if {$DEVICE_READY_EN} {
  ::vh::export_pin {board_init_reset_bridge out_reset_1} o_rst_device_ready_export
  ::vh::export_pin {board_init_reset_bridge out_reset_2} o_rst_device_ready
}

if {$USER_PB_TO_AVMM_EN} {
  if {!$avmm_bridge_en} {
    ::vh::export_pin {user_led_pio clk} i_clk_board_data
    ::vh::export_pin {user_led_pio reset} i_rst_board_data
    ::vh::export_if {user_led_pio s1} i_avmm_board_data
  }

  ::vh::export_pin {user_led_pio external_connection} o_leds
}

if {$USER_PB_TO_AVMM_EN} {
  if {!$avmm_bridge_en} {
    ::vh::export_pin {user_pb_pio clk} i_clk_board_data
    ::vh::export_pin {user_pb_pio reset} i_rst_board_data
    ::vh::export_if {user_pb_pio s1} i_avmm_board_data
  }

  ::vh::export_pin {user_pb_pio external_connection} ia_pb
}

if {$avmm_bridge_en} {
  ::vh::export_pin {io_data_clk_bridge  in_clk} i_clk_board_data
  ::vh::export_pin {io_data_rst_bridge  in_reset} i_rst_board_data
  ::vh::export_if {io_data_avmm_bridge s0} i_avmm_board_data
}

::vh::sync

puts "board_subsystem: build complete"
