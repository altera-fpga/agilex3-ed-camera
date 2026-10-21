package require ::quartus::project

set script_dir [file dirname [file normalize [info script]]]
set project_dir [file normalize "${script_dir}/../../.."]

if {![is_project_open]} {
    cd $project_dir
    project_open top -revision top
}

# Force "IP Generation" to regenerate files on system change
file delete -force "${project_dir}/gen/vds/isp_lite_out_subsystem"

source "${project_dir}/scripts/vds/lib/vds_helpers.tcl"

set PIP_IN 1
set PIP_DP_OUT 2
set PIP_DSI_OUT 1
set BPS 10
set EN_DEBUG 1

set MAX_WIDTH 4096
set MAX_HEIGHT 4096

puts "isp_lite_out_subsystem: creating system"

::vh::new_system "isp_lite_out_subsystem"

# ---------------------------------------------------------------------------
# Create instances
# ---------------------------------------------------------------------------

puts "isp_lite_out_subsystem: creating cells"
::vh::create_cell isp_cpu_clk_bridge altera_clock_bridge {
  EXPLICIT_CLOCK_RATE 100000000.0
  NUM_CLOCK_OUTPUTS   1
}

::vh::create_cell isp_cpu_rst_bridge altera_reset_bridge {
  ACTIVE_LOW_RESET   0
  NUM_RESET_OUTPUTS  1
  SYNCHRONOUS_EDGES  deassert
  SYNC_RESET         0
  USE_RESET_REQUEST  0
}

::vh::create_cell isp_vid_clk_bridge altera_clock_bridge {
  EXPLICIT_CLOCK_RATE 297000000.0
  NUM_CLOCK_OUTPUTS   1
}

::vh::create_cell isp_vid_rst_bridge altera_reset_bridge {
  ACTIVE_LOW_RESET   0
  NUM_RESET_OUTPUTS  1
  SYNCHRONOUS_EDGES  deassert
  SYNC_RESET         0
  USE_RESET_REQUEST  0
}

::vh::create_cell isp_vid_clk_out_bridge altera_clock_bridge {
  EXPLICIT_CLOCK_RATE 148500000.0
  NUM_CLOCK_OUTPUTS   1
}

::vh::create_cell isp_vid_rst_out_bridge altera_reset_bridge {
  ACTIVE_LOW_RESET   0
  NUM_RESET_OUTPUTS  1
  SYNCHRONOUS_EDGES  deassert
  SYNC_RESET         0
  USE_RESET_REQUEST  0
}

::vh::create_cell isp_emif_clk_bridge altera_clock_bridge {
  EXPLICIT_CLOCK_RATE 170000000.0
  NUM_CLOCK_OUTPUTS   1
}

::vh::create_cell isp_emif_rst_bridge altera_reset_bridge {
  ACTIVE_LOW_RESET  1
  NUM_RESET_OUTPUTS 1
  SYNCHRONOUS_EDGES deassert
  SYNC_RESET        0
  USE_RESET_REQUEST 0
}

::vh::create_cell isp_mm_bridge altera_avalon_mm_bridge {
  ADDRESS_UNITS            SYMBOLS
  ADDRESS_WIDTH            0
  DATA_WIDTH               32
  LINEWRAPBURSTS           0
  M0_WAITREQUEST_ALLOWANCE 0
  MAX_BURST_SIZE           1
  MAX_PENDING_RESPONSES    4
  MAX_PENDING_WRITES       0
  PIPELINE_COMMAND         1
  PIPELINE_RESPONSE        1
  S0_WAITREQUEST_ALLOWANCE 0
  SYMBOL_WIDTH             8
  SYNC_RESET               0
  USE_AUTO_ADDRESS_WIDTH   1
  USE_RESPONSE             0
  USE_WRITERESPONSE        0
}
::vh::create_cell isp_tpg intel_vvp_tpg {
    BPS 10
    OUTPUT_FORMAT 4.4.4
    PIXELS_IN_PARALLEL 1
    NUM_CORES 1
    CORE_COL_SPACE_0 0
    CORE_PATTERN_0 1
    ENABLE_DEBUG 0
    EXTERNAL_MODE 1
    PIPELINE_READY 1
    RUNTIME_CONTROL 1
    SEPARATE_SLAVE_CLOCK 1
}
::vh::create_cell isp_vfb intel_vvp_vfb {
    BPS 10
    CLOCKS_ARE_SEPARATE 1
    DROP_BROKEN_FRAMES 1
    DROP_RPT_AUX_PKTS_WITH_FRAMES 0
    ENABLE_DEBUG 0
    EXTERNAL_MODE 1
    FRAME_DROP_ENABLE 1
    FRAME_REPEAT_ENABLE 1
    MAX_CONTROL_PACKETS 0
    MAX_HEIGHT 4096
    MAX_WIDTH 4096
    MEM_BUFF_BASE_ADDR 0
    MEM_BUFF_LINE_STRIDE 49152
    MEM_BUFF_STRIDE 268435456
    NUMBER_OF_COLOR_PLANES 3
    PACKING PERFECT
    PIXELS_IN_PARALLEL 1
    P_AV_MM_ADDR_WIDTH 32
    P_AV_MM_DATA_WIDTH 256
    READ_BURST_TARGET 64
    READ_FIFO_DEPTH 512
    WRITE_BURST_TARGET 64
    WRITE_FIFO_DEPTH 512
    RUNTIME_CONTROL 1
    SEPARATE_SLAVE_CLOCK 1
}
::vh::create_cell isp_se_vfb altera_address_span_extender {
    BURSTCOUNT_WIDTH 7
    DATA_WIDTH 256
    ENABLE_SLAVE_PORT 0
    MASTER_ADDRESS_DEF 0
    MASTER_ADDRESS_WIDTH 33
    MAX_PENDING_READS 8
    SLAVE_ADDRESS_WIDTH 27
    SUB_WINDOW_COUNT 1
    SYNC_RESET 0
}
::vh::create_cell isp_icon intel_vvp_icon [subst {
    BPS $BPS
    EXTERNAL_MODE 1
    PIPELINE_READY 1
    PIXELS_IN_PARALLEL $PIP_IN
}]

::vh::create_cell isp_mixer intel_vvp_mixer [subst {
    BPS $BPS
    PIXELS_IN_PARALLEL $PIP_IN
    NUM_LAYERS 3
    BLENDING_MODE_1 1
    BLENDING_MODE_2 1
    BLENDING_MODE_3 1
    RESTRICTED_OFFSETS_3 0
    BLENDING_MODE_4 0
    BLENDING_MODE_5 0
    BLENDING_MODE_6 0
    BLENDING_MODE_7 0
    DO_ROUNDING 0
    ENABLE_DEBUG 0
    EXPORT_PROBES 0
    EXTERNAL_MODE 1
    NUMBER_OF_COLOR_PLANES 3
    PIPELINE_LEVEL 2
    RESTRICTED_OFFSETS_1 0
    RESTRICTED_OFFSETS_2 0
    RESTRICTED_OFFSETS_4 0
    RESTRICTED_OFFSETS_5 0
    RESTRICTED_OFFSETS_6 0
    RESTRICTED_OFFSETS_7 0
    RUNTIME_CONTROL 1
    SEPARATE_SLAVE_CLOCK 1
}]

::vh::create_cell isp_1d_lut intel_vvp_1d_lut [subst {
  AV_MAX_PENDING_READS   8
  BITS_LUT               9
  BITS_STEP              2
  PIXELS_IN_PARALLEL     $PIP_IN
  BPS_IN                 $BPS
  BPS_OUT                $BPS
  NUMBER_OF_COLOR_PLANES 3
  DUPLICATE_AND_BYPASS   0
  ENABLE_DEBUG           0
  ENABLE_EXT_DATA_RW     0
  EQUIDISTANT            0
  EXTERNAL_MODE          1
  H_TAPS                 1
  MAX_HEIGHT             $MAX_HEIGHT
  MAX_WIDTH              $MAX_WIDTH
  NO_BLANKING            1
  PIPELINE_DATA_MM       0
  PIPELINE_READY         1
  REVERSE_LUT            0
  RUNTIME_CONTROL        1
  SEPARATE_SLAVE_CLOCK   1
  V_TAPS                 1
}]

::vh::create_cell isp_out_switch intel_vvp_switch [subst {
  VVP_INTF_TYPE          VVP_LITE
  PIXELS_IN_PARALLEL     $PIP_IN
  EXTERNAL_MODE          1
  BPS                    $BPS
  NUMBER_OF_COLOR_PLANES 3
  ENABLE_DEBUG           0
  SEPARATE_SLAVE_CLOCK   1
  NUM_INPUTS             1
  NUM_OUTPUTS            2
  USE_OP_RESP            0
  UNINTERRUPTED_INPUTS   1
}]

::vh::create_cell vid_out_pip_conv intel_vvp_pip_conv [subst {
  BPS                    $BPS
  PIXELS_IN_PARALLEL_IN  $PIP_IN
  PIXELS_IN_PARALLEL_OUT $PIP_DP_OUT
  NUMBER_OF_COLOR_PLANES 3
  DUAL_CLOCK             1
  FIFO_DEPTH             2048
  ENABLE_DEBUG           0
  EXTERNAL_MODE          1
  PIPELINE_READY         1
  SEPARATE_SLAVE_CLOCK   1
}]

# DPTX takes full variant of streaming protocol
::vh::create_cell isp_out_proto_conv intel_vvp_protocol_conv [subst {
  BPS                      $BPS
  CHROMA_SAMPLING          444
  CHROMA_SITING            TOP_LEFT
  CLIP_LONG_FIELDS         0
  COLOR_SPACE              RGB
  ENABLE_DEBUG             0
  ENABLE_TIMEOUT           0
  ENABLE_YCBCR_SWAP        0
  INPUT_MODE               EXTERNAL
  NUMBER_OF_COLOR_PLANES   3
  OUTPUT_MODE              INTERNAL
  PIPELINE_READY           1
  PIXELS_IN_PARALLEL       $PIP_DP_OUT
  RUNTIME_CONTROL          1
  SEPARATE_SLAVE_CLOCK     1
  VIP_USER_SUPPORT         DISCARD
  VVP_USER_SUPPORT         NONE_ALLOWED
}]

::vh::sync

# ---------------------------------------------------------------------------
# Wiring
# ---------------------------------------------------------------------------

puts "isp_lite_out_subsystem: wiring up cells"

::vh::connect_pin {isp_cpu_clk_bridge out_clk} {isp_cpu_rst_bridge clk}
::vh::connect_pin {isp_cpu_clk_bridge out_clk} {isp_mm_bridge clk}
::vh::connect_pin {isp_cpu_clk_bridge out_clk} {isp_vfb control_clock}
::vh::connect_pin {isp_cpu_clk_bridge out_clk} {isp_tpg agent_clock}
::vh::connect_pin {isp_cpu_clk_bridge out_clk} {isp_mixer agent_clock}
::vh::connect_pin {isp_cpu_clk_bridge out_clk} {isp_1d_lut agent_clock}
::vh::connect_pin {isp_cpu_clk_bridge out_clk} {isp_out_switch agent_clock}
::vh::connect_pin {isp_cpu_clk_bridge out_clk} {vid_out_pip_conv agent_clock}
::vh::connect_pin {isp_cpu_clk_bridge out_clk} {isp_out_proto_conv agent_clock}

::vh::connect_pin {isp_cpu_rst_bridge out_reset} {isp_mm_bridge reset}
::vh::connect_pin {isp_cpu_rst_bridge out_reset} {isp_vfb control_reset}
::vh::connect_pin {isp_cpu_rst_bridge out_reset} {isp_tpg agent_reset}
::vh::connect_pin {isp_cpu_rst_bridge out_reset} {isp_mixer agent_reset}
::vh::connect_pin {isp_cpu_rst_bridge out_reset} {isp_1d_lut agent_reset}
::vh::connect_pin {isp_cpu_rst_bridge out_reset} {isp_out_switch agent_reset}
::vh::connect_pin {isp_cpu_rst_bridge out_reset} {vid_out_pip_conv agent_reset}
::vh::connect_pin {isp_cpu_rst_bridge out_reset} {isp_out_proto_conv agent_reset}

::vh::connect_pin {isp_vid_clk_bridge out_clk} {isp_vid_rst_bridge clk}
::vh::connect_pin {isp_vid_clk_bridge out_clk} {isp_vfb main_clock}
::vh::connect_pin {isp_vid_clk_bridge out_clk} {isp_tpg main_clock}
::vh::connect_pin {isp_vid_clk_bridge out_clk} {isp_icon main_clock}
::vh::connect_pin {isp_vid_clk_bridge out_clk} {isp_mixer main_clock}
::vh::connect_pin {isp_vid_clk_bridge out_clk} {isp_1d_lut main_clock}
::vh::connect_pin {isp_vid_clk_bridge out_clk} {isp_out_switch main_clock}
::vh::connect_pin {isp_vid_clk_bridge out_clk} {vid_out_pip_conv in_clock}

::vh::connect_pin {isp_vid_rst_bridge out_reset} {isp_vfb main_reset}
::vh::connect_pin {isp_vid_rst_bridge out_reset} {isp_tpg main_reset}
::vh::connect_pin {isp_vid_rst_bridge out_reset} {isp_icon main_reset}
::vh::connect_pin {isp_vid_rst_bridge out_reset} {isp_mixer main_reset}
::vh::connect_pin {isp_vid_rst_bridge out_reset} {isp_1d_lut main_reset}
::vh::connect_pin {isp_vid_rst_bridge out_reset} {isp_out_switch main_reset}
::vh::connect_pin {isp_vid_rst_bridge out_reset} {vid_out_pip_conv in_reset}

::vh::connect_pin {isp_vid_clk_out_bridge out_clk} {isp_vid_rst_out_bridge clk}
::vh::connect_pin {isp_vid_clk_out_bridge out_clk} {vid_out_pip_conv out_clock}
::vh::connect_pin {isp_vid_clk_out_bridge out_clk} {isp_out_proto_conv main_clock}

::vh::connect_pin {isp_vid_rst_out_bridge out_reset} {vid_out_pip_conv out_reset}
::vh::connect_pin {isp_vid_rst_out_bridge out_reset} {isp_out_proto_conv main_reset}

::vh::connect_pin {isp_emif_clk_bridge out_clk} {isp_emif_rst_bridge clk}
::vh::connect_pin {isp_emif_clk_bridge out_clk} {isp_vfb mem_clock}
::vh::connect_pin {isp_emif_clk_bridge out_clk} {isp_se_vfb clock}

::vh::connect_pin {isp_emif_rst_bridge out_reset} {isp_vfb mem_reset}
::vh::connect_pin {isp_emif_rst_bridge out_reset} {isp_se_vfb reset}

::vh::connect_if {isp_mm_bridge m0} {isp_vfb av_mm_control_agent}
::vh::connect_if {isp_mm_bridge m0} {isp_tpg av_mm_control_agent}
::vh::connect_if {isp_mm_bridge m0} {isp_mixer av_mm_control_agent}
::vh::connect_if {isp_mm_bridge m0} {isp_1d_lut av_mm_control_agent}
::vh::connect_if {isp_mm_bridge m0} {isp_out_switch av_mm_control_agent}
::vh::connect_if {isp_mm_bridge m0} {vid_out_pip_conv av_mm_control_agent}
::vh::connect_if {isp_mm_bridge m0} {isp_out_proto_conv av_mm_control_agent}

::vh::connect_if {isp_tpg axi4s_vid_out}          {isp_mixer axi4s_vid_0_in}
::vh::connect_if {isp_vfb axi4s_vid_out}          {isp_mixer axi4s_vid_1_in}
::vh::connect_if {isp_vfb av_mm_mem_write_host}   {isp_se_vfb windowed_slave}
::vh::connect_if {isp_vfb av_mm_mem_read_host}    {isp_se_vfb windowed_slave}
::vh::connect_if {isp_icon axi4s_vid_out}         {isp_mixer axi4s_vid_2_in}
::vh::connect_if {isp_mixer axi4s_vid_out}        {isp_1d_lut axi4s_vid_in}
::vh::connect_if {isp_1d_lut axi4s_vid_out}       {isp_out_switch axi4s_vid_in_0}
::vh::connect_if {isp_out_switch axi4s_vid_out_0} {vid_out_pip_conv axi4s_vid_in}
::vh::connect_if {vid_out_pip_conv axi4s_vid_out} {isp_out_proto_conv axi4s_vid_in}

::vh::sync

# -----------------------------------------------------------------------------
# Assign base addresses
# -----------------------------------------------------------------------------

puts "isp_lite_out_subsystem: assigning base addresses"

vds::assign_base_address

::vh::sync

# -----------------------------------------------------------------------------
# Exports
# -----------------------------------------------------------------------------

puts "isp_lite_out_subsystem: exporting pins/interfaces"

::vh::export_pin {isp_cpu_clk_bridge in_clk} cpu_clk_in
::vh::export_pin {isp_cpu_rst_bridge in_reset} cpu_rst_in
::vh::export_pin {isp_vid_clk_bridge in_clk} vid_clk_in
::vh::export_pin {isp_vid_rst_bridge in_reset} vid_rst_in
::vh::export_pin {isp_vid_clk_out_bridge in_clk} vid_clk_out
::vh::export_pin {isp_vid_rst_out_bridge in_reset} vid_rst_out
::vh::export_pin {isp_emif_clk_bridge in_clk} emif_clk_in
::vh::export_pin {isp_emif_rst_bridge in_reset} emif_rst_in

::vh::export_if {isp_mm_bridge s0} mm_ctrl_in
::vh::export_if {isp_se_vfb expanded_master} av_mm_host_se_vfb
::vh::export_if {isp_vfb axi4s_vid_in} vid_in
::vh::export_if {isp_out_proto_conv axi4s_vid_out} vid_out
::vh::export_if {isp_out_switch axi4s_vid_out_1} vid_out_2

::vh::sync

puts "isp_lite_out_subsystem: build complete"
