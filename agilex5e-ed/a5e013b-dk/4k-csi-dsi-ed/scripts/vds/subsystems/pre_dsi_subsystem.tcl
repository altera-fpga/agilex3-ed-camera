package require ::quartus::project

set script_dir [file dirname [file normalize [info script]]]
set project_dir [file normalize "${script_dir}/../../.."]

if {![is_project_open]} {
  cd $project_dir
  project_open top -revision top
}

# Force "IP Generation" to regenerate files on system change
file delete -force "${project_dir}/gen/vds/pre_dsi_subsystem"

source "${project_dir}/scripts/vds/lib/vds_helpers.tcl"

set BPS_IN 10
set BPS_OUT 8
set PIP 1

set WIDTH_IN 3840
set HEIGHT_IN 2160

# Dimensions of DSI panel used for design
set WIDTH_OUT 1280
set HEIGHT_OUT 800

puts "pre_dsi_subsystem: creating system"
::vh::new_system "pre_dsi_subsystem"

# -----------------------------------------------------------------------------
# Instances
# -----------------------------------------------------------------------------

puts "pre_dsi_subsystem: creating cells"
::vh::create_cell pre_dsi_subsystem_cpu_clk_bridge altera_clock_bridge {
  EXPLICIT_CLOCK_RATE 0.0
  NUM_CLOCK_OUTPUTS   1
}

::vh::create_cell pre_dsi_subsystem_cpu_rst_bridge altera_reset_bridge {
  ACTIVE_LOW_RESET   0
  NUM_RESET_OUTPUTS  1
  SYNCHRONOUS_EDGES  deassert
  SYNC_RESET         0
  USE_RESET_REQUEST  0
}

::vh::create_cell pre_dsi_subsystem_main_clk_bridge altera_clock_bridge {
  EXPLICIT_CLOCK_RATE 0.0
  NUM_CLOCK_OUTPUTS   1
}

::vh::create_cell pre_dsi_subsystem_main_rst_bridge altera_reset_bridge {
  ACTIVE_LOW_RESET   0
  NUM_RESET_OUTPUTS  1
  SYNCHRONOUS_EDGES  deassert
  SYNC_RESET         0
  USE_RESET_REQUEST  0
}

::vh::create_cell pre_dsi_subsystem_tx_clk_bridge altera_clock_bridge {
  EXPLICIT_CLOCK_RATE 0.0
  NUM_CLOCK_OUTPUTS   1
}

::vh::create_cell pre_dsi_subsystem_tx_rst_bridge altera_reset_bridge {
  ACTIVE_LOW_RESET   0
  NUM_RESET_OUTPUTS  1
  SYNCHRONOUS_EDGES  deassert
  SYNC_RESET         0
  USE_RESET_REQUEST  0
}

::vh::create_cell pre_dsi_subsystem_mem_clk_bridge altera_clock_bridge {
  EXPLICIT_CLOCK_RATE 0.0
  NUM_CLOCK_OUTPUTS   1
}

::vh::create_cell pre_dsi_subsystem_mem_rst_bridge altera_reset_bridge {
  ACTIVE_LOW_RESET   0
  NUM_RESET_OUTPUTS  1
  SYNCHRONOUS_EDGES  deassert
  SYNC_RESET         0
  USE_RESET_REQUEST  0
}

::vh::create_cell pre_dsi_subsystem_cpu_mm_bridge altera_avalon_mm_bridge {
  DATA_WIDTH               32
  SYMBOL_WIDTH             8
  LINEWRAPBURSTS           0
  M0_WAITREQUEST_ALLOWANCE 0
  MAX_BURST_SIZE           1
  MAX_PENDING_RESPONSES    4
  MAX_PENDING_WRITES       0
  PIPELINE_COMMAND         1
  PIPELINE_RESPONSE        1
  S0_WAITREQUEST_ALLOWANCE 0
  SYNC_RESET               0
  USE_AUTO_ADDRESS_WIDTH   1
  USE_RESPONSE             0
  USE_WRITERESPONSE        0
}

::vh::create_cell pre_dsi_subsystem_mem_mm_bridge altera_avalon_mm_bridge {
  DATA_WIDTH               256
  SYMBOL_WIDTH             8
  LINEWRAPBURSTS           0
  M0_WAITREQUEST_ALLOWANCE 0
  MAX_BURST_SIZE           64
  MAX_PENDING_RESPONSES    10
  MAX_PENDING_WRITES       0
  PIPELINE_COMMAND         0
  PIPELINE_RESPONSE        0
  S0_WAITREQUEST_ALLOWANCE 0
  SYNC_RESET               0
  USE_AUTO_ADDRESS_WIDTH   1
  USE_AUTO_ADDRESS_WIDTH   1
  USE_RESPONSE             0
  USE_WRITERESPONSE        0
}

::vh::create_cell pre_dsi_subsystem_other_mem_in_mm_bridge altera_avalon_mm_bridge {
  DATA_WIDTH               256
  SYMBOL_WIDTH             8
  LINEWRAPBURSTS           0
  M0_WAITREQUEST_ALLOWANCE 0
  MAX_BURST_SIZE           64
  MAX_PENDING_RESPONSES    10
  MAX_PENDING_WRITES       0
  PIPELINE_COMMAND         0
  PIPELINE_RESPONSE        0
  S0_WAITREQUEST_ALLOWANCE 0
  SYNC_RESET               0
  USE_AUTO_ADDRESS_WIDTH   1
  USE_RESPONSE             0
  USE_WRITERESPONSE        0
}

# 3840x2160 to 1280x800 (note aspect ratio change)
::vh::create_cell pre_dsi_subsystem_downscaler intel_vvp_scaler [subst {
  EXTERNAL_MODE          1
  BPS                    $BPS_IN
  NUMBER_OF_COLOR_PLANES 3
  PIXELS_IN_PARALLEL     $PIP
  PIPELINE_READY         1
  RUNTIME_CONTROL        1
  SEPARATE_SLAVE_CLOCK   1
  ENABLE_DEBUG           0
  ENABLE_444             1
  MAX_IN_WIDTH           $WIDTH_IN
  MAX_OUT_WIDTH          $WIDTH_OUT
  ALGORITHM              NEAREST_NEIGHBOUR
  EDGE_MIRROR            REPLICATE
  RUNTIME_LOAD           1
  MEM_INIT               0
  ENABLE_V               1
  V_PARTIAL_SCALING      0
  V_TAPS                 4
  V_PHASES               16
  V_BANKS                1
  ENABLE_H               1
  H_PARTIAL_SCALING      0
  H_TAPS                 4
  H_PHASES               16
  H_BANKS                1
}]

# Naive FPS conversion from 30 to 60 FPS (+ smooth scaler data)
::vh::create_cell pre_dsi_subsystem_vfb intel_vvp_vfb [subst {
  EXTERNAL_MODE                 1
  BPS                           $BPS_IN
  NUMBER_OF_COLOR_PLANES        3
  PIXELS_IN_PARALLEL            $PIP
  MAX_WIDTH                     $WIDTH_OUT
  MAX_HEIGHT                    $HEIGHT_OUT
  FRAME_DROP_ENABLE             1
  FRAME_REPEAT_ENABLE           1
  DROP_BROKEN_FRAMES            1
  DROP_RPT_AUX_PKTS_WITH_FRAMES 0
  RUNTIME_CONTROL               1
  SEPARATE_SLAVE_CLOCK          1
  ENABLE_DEBUG                  0
  P_AV_MM_DATA_WIDTH            256
  P_AV_MM_ADDR_WIDTH            32
  WRITE_FIFO_DEPTH              256
  WRITE_BURST_TARGET            64
  READ_FIFO_DEPTH               512
  READ_BURST_TARGET             64
  MEM_BUFF_BASE_ADDR            0x40000000
  MEM_BUFF_STRIDE               0x10000000
  MEM_BUFF_LINE_STRIDE          0x4000
  PACKING                       PERFECT
  CLOCKS_ARE_SEPARATE           1
}]

# CDC from 297MHz pixel clock (for 4k30) to DSI TX clock
::vh::create_cell pre_dsi_subsystem_fifo intel_vvp_fifo [subst {
  BPS                    $BPS_IN
  NUMBER_OF_COLOR_PLANES 3
  PIXELS_IN_PARALLEL     $PIP
  DUAL_CLOCK             1
  FIFO_DEPTH             64
  PIPELINE_READY         1
}]

# 10->8 bps
::vh::create_cell pre_dsi_subsystem_bps_conv intel_vvp_pixel_adapter [subst {
  BPS_IN                 $BPS_IN
  BPS_OUT                $BPS_OUT
  NUMBER_OF_COLOR_PLANES 3
  PIXELS_IN_PARALLEL     1
  RUNTIME_CONTROL        0
  PIPELINE_READY         1
  EXTERNAL_MODE          1
}]

# DSI Tx takes in full variant of streaming protocol
::vh::create_cell pre_dsi_subsystem_lite_to_full intel_vvp_protocol_conv [subst {
  BPS                    $BPS_OUT
  NUMBER_OF_COLOR_PLANES 3
  PIXELS_IN_PARALLEL     1
  PIPELINE_READY         1
  ENABLE_DEBUG           0
  RUNTIME_CONTROL        1
  SEPARATE_SLAVE_CLOCK   1
  ENABLE_TIMEOUT         0
  INPUT_MODE             EXTERNAL
  OUTPUT_MODE            INTERNAL
  CLIP_LONG_FIELDS       0
}]

::vh::create_cell pre_dsi_subsystem_vfb_rst_ctrl vfb_reset_ctrl

::vh::sync

# -----------------------------------------------------------------------------
# Wiring
# -----------------------------------------------------------------------------

puts "pre_dsi_subsystem: wiring up cells"

# Bridges clock + reset
::vh::connect_pin {pre_dsi_subsystem_cpu_clk_bridge out_clk} {pre_dsi_subsystem_cpu_rst_bridge clk}
::vh::connect_pin {pre_dsi_subsystem_main_clk_bridge out_clk} {pre_dsi_subsystem_main_rst_bridge clk}
::vh::connect_pin {pre_dsi_subsystem_tx_clk_bridge out_clk} {pre_dsi_subsystem_tx_rst_bridge clk}
::vh::connect_pin {pre_dsi_subsystem_mem_clk_bridge out_clk} {pre_dsi_subsystem_mem_rst_bridge clk}
::vh::connect_pin {pre_dsi_subsystem_cpu_clk_bridge out_clk} {pre_dsi_subsystem_cpu_mm_bridge clk}
::vh::connect_pin {pre_dsi_subsystem_cpu_rst_bridge out_reset} {pre_dsi_subsystem_cpu_mm_bridge reset}
::vh::connect_pin {pre_dsi_subsystem_mem_clk_bridge out_clk} {pre_dsi_subsystem_mem_mm_bridge clk}
::vh::connect_pin {pre_dsi_subsystem_mem_rst_bridge out_reset} {pre_dsi_subsystem_mem_mm_bridge reset}
::vh::connect_pin {pre_dsi_subsystem_mem_clk_bridge out_clk} {pre_dsi_subsystem_other_mem_in_mm_bridge clk}
::vh::connect_pin {pre_dsi_subsystem_mem_rst_bridge out_reset} {pre_dsi_subsystem_other_mem_in_mm_bridge reset}

::vh::connect_pin {pre_dsi_subsystem_mem_clk_bridge out_clk} {pre_dsi_subsystem_vfb_rst_ctrl mem_clock}
::vh::connect_pin {pre_dsi_subsystem_main_clk_bridge out_clk} {pre_dsi_subsystem_vfb_rst_ctrl main_clock}
::vh::connect_pin {pre_dsi_subsystem_mem_rst_bridge out_reset} {pre_dsi_subsystem_vfb_rst_ctrl mem_reset_in}
::vh::connect_pin {pre_dsi_subsystem_main_rst_bridge out_reset} {pre_dsi_subsystem_vfb_rst_ctrl main_reset_in}

# Other clocks + resets
::vh::connect_pin {pre_dsi_subsystem_main_clk_bridge out_clk} {pre_dsi_subsystem_downscaler main_clock}
::vh::connect_pin {pre_dsi_subsystem_main_rst_bridge out_reset} {pre_dsi_subsystem_downscaler main_reset}
::vh::connect_pin {pre_dsi_subsystem_main_clk_bridge out_clk} {pre_dsi_subsystem_vfb main_clock}
::vh::connect_pin {pre_dsi_subsystem_vfb_rst_ctrl main_reset_out} {pre_dsi_subsystem_vfb main_reset}
::vh::connect_pin {pre_dsi_subsystem_main_clk_bridge out_clk} {pre_dsi_subsystem_fifo in_clock}
::vh::connect_pin {pre_dsi_subsystem_main_rst_bridge out_reset} {pre_dsi_subsystem_fifo in_reset}

::vh::connect_pin {pre_dsi_subsystem_tx_clk_bridge out_clk} {pre_dsi_subsystem_fifo out_clock}
::vh::connect_pin {pre_dsi_subsystem_tx_rst_bridge out_reset} {pre_dsi_subsystem_fifo out_reset}
::vh::connect_pin {pre_dsi_subsystem_tx_clk_bridge out_clk} {pre_dsi_subsystem_bps_conv main_clock}
::vh::connect_pin {pre_dsi_subsystem_tx_rst_bridge out_reset} {pre_dsi_subsystem_bps_conv main_reset}
::vh::connect_pin {pre_dsi_subsystem_tx_clk_bridge out_clk} {pre_dsi_subsystem_lite_to_full main_clock}
::vh::connect_pin {pre_dsi_subsystem_tx_rst_bridge out_reset} {pre_dsi_subsystem_lite_to_full main_reset}

::vh::connect_pin {pre_dsi_subsystem_cpu_clk_bridge out_clk} {pre_dsi_subsystem_downscaler agent_clock}
::vh::connect_pin {pre_dsi_subsystem_cpu_rst_bridge out_reset} {pre_dsi_subsystem_downscaler agent_reset}
::vh::connect_pin {pre_dsi_subsystem_cpu_clk_bridge out_clk} {pre_dsi_subsystem_vfb control_clock}
::vh::connect_pin {pre_dsi_subsystem_cpu_rst_bridge out_reset} {pre_dsi_subsystem_vfb control_reset}
::vh::connect_pin {pre_dsi_subsystem_cpu_clk_bridge out_clk} {pre_dsi_subsystem_lite_to_full agent_clock}
::vh::connect_pin {pre_dsi_subsystem_cpu_rst_bridge out_reset} {pre_dsi_subsystem_lite_to_full agent_reset}

::vh::connect_pin {pre_dsi_subsystem_mem_clk_bridge out_clk} {pre_dsi_subsystem_vfb mem_clock}
::vh::connect_pin {pre_dsi_subsystem_vfb_rst_ctrl mem_reset_out} {pre_dsi_subsystem_vfb mem_reset}

# Video pipeline
::vh::connect_if {pre_dsi_subsystem_downscaler axi4s_vid_out} {pre_dsi_subsystem_vfb axi4s_vid_in}
::vh::connect_if {pre_dsi_subsystem_vfb axi4s_vid_out} {pre_dsi_subsystem_fifo axi4s_vid_in}
::vh::connect_if {pre_dsi_subsystem_fifo axi4s_vid_out} {pre_dsi_subsystem_bps_conv axi4s_vid_in}
::vh::connect_if {pre_dsi_subsystem_bps_conv axi4s_vid_out} {pre_dsi_subsystem_lite_to_full axi4s_vid_in}

::vh::connect_if {pre_dsi_subsystem_cpu_mm_bridge m0} {pre_dsi_subsystem_downscaler av_mm_control_agent}
::vh::connect_if {pre_dsi_subsystem_cpu_mm_bridge m0} {pre_dsi_subsystem_vfb av_mm_control_agent}
::vh::connect_if {pre_dsi_subsystem_cpu_mm_bridge m0} {pre_dsi_subsystem_lite_to_full av_mm_control_agent}

# VFB bridge; expose single master for EMIF connection.
::vh::connect_if {pre_dsi_subsystem_vfb av_mm_mem_write_host} {pre_dsi_subsystem_mem_mm_bridge s0}
::vh::connect_if {pre_dsi_subsystem_vfb av_mm_mem_read_host} {pre_dsi_subsystem_mem_mm_bridge s0}
::vh::connect_if {pre_dsi_subsystem_other_mem_in_mm_bridge m0} {pre_dsi_subsystem_mem_mm_bridge s0}

::vh::sync

# ---------------------------------------------------------------------------
# Assign base addresses
# ---------------------------------------------------------------------------

puts "pre_dsi_subsystem: assigning base addresses"
vds::assign_base_address

::vh::sync

# ---------------------------------------------------------------------------
# Exports
# ---------------------------------------------------------------------------

::vh::export_pin {pre_dsi_subsystem_cpu_clk_bridge in_clk} cpu_clk_in
::vh::export_pin {pre_dsi_subsystem_cpu_rst_bridge in_reset} cpu_rst_in
::vh::export_pin {pre_dsi_subsystem_main_clk_bridge in_clk} main_clk_in
::vh::export_pin {pre_dsi_subsystem_main_rst_bridge in_reset} main_rst_in
::vh::export_pin {pre_dsi_subsystem_tx_clk_bridge in_clk} tx_clk_in
::vh::export_pin {pre_dsi_subsystem_tx_rst_bridge in_reset} tx_rst_in
::vh::export_pin {pre_dsi_subsystem_mem_clk_bridge in_clk} mem_clk_in
::vh::export_pin {pre_dsi_subsystem_mem_rst_bridge in_reset} mem_rst_in

::vh::export_if {pre_dsi_subsystem_cpu_mm_bridge s0} cpu_mm_in
::vh::export_if {pre_dsi_subsystem_mem_mm_bridge m0} vfb_mem_host
::vh::export_if {pre_dsi_subsystem_other_mem_in_mm_bridge s0} other_vfb_mem_in
::vh::export_if {pre_dsi_subsystem_downscaler axi4s_vid_in} vid_in
::vh::export_if {pre_dsi_subsystem_lite_to_full axi4s_vid_out} vid_out_to_dsi

::vh::sync

puts "pre_dsi_subsystem: build complete"
