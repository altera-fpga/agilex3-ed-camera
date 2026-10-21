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

set PIP 1
set EN_DEBUG 0
set MULTI_SENSOR 0
set EXP_FUSION_EN 0

set BPS [expr {$EXP_FUSION_EN ? 16 : 12}]
set NUM_INPUTS [expr {$MULTI_SENSOR ? 3 : 2}]

puts "isp_lite_in_subsystem: creating system"
::vh::new_system "isp_lite_in_subsystem"

# ---------------------------------------------------------------------------
# Instances
# ---------------------------------------------------------------------------

puts "isp_lite_in_subsystem: creating cells"
::vh::create_cell isp_in_cpu_clk_bridge altera_clock_bridge {
  EXPLICIT_CLOCK_RATE 100000000.0
  NUM_CLOCK_OUTPUTS   1
}

::vh::create_cell isp_in_cpu_rst_bridge altera_reset_bridge {
  ACTIVE_LOW_RESET  0
  NUM_RESET_OUTPUTS 1
  SYNCHRONOUS_EDGES deassert
  SYNC_RESET        0
  USE_RESET_REQUEST 0
}

::vh::create_cell isp_in_vid_clk_bridge altera_clock_bridge {
  EXPLICIT_CLOCK_RATE 297000000.0
  NUM_CLOCK_OUTPUTS   1
}

::vh::create_cell isp_in_vid_rst_bridge altera_reset_bridge {
  ACTIVE_LOW_RESET  0
  NUM_RESET_OUTPUTS 1
  SYNCHRONOUS_EDGES deassert
  SYNC_RESET        0
  USE_RESET_REQUEST 0
}

::vh::create_cell isp_in_mm_bridge altera_avalon_mm_bridge {
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

::vh::create_cell isp_in_tpg intel_vvp_tpg [subst {
  BPS                  ${BPS}
  CORE_COL_SPACE_0     0
  CORE_COL_SPACE_1     0
  CORE_PATTERN_0       0
  CORE_PATTERN_1       1
  ENABLE_DEBUG         ${EN_DEBUG}
  EXTERNAL_MODE        1
  NUM_CORES            2
  OUTPUT_FORMAT        4.4.4
  PIPELINE_READY       1
  PIXELS_IN_PARALLEL   ${PIP}
  RUNTIME_CONTROL      1
  SEPARATE_SLAVE_CLOCK 1
  SLAVE_PROTOCOL       Avalon
}]

::vh::create_cell isp_in_rms intel_vvp_remosaic [subst {
  BPS                      ${BPS}
  C_CONV_MODE              148
  C_CPU_OFFSET             0
  C_OMNI_CAP_ID_ASSOCIATED 0
  C_OMNI_CAP_ID_COMPONENT  0
  C_OMNI_CAP_IRQ           255
  C_OMNI_CAP_IRQ_ENABLE    0
  C_OMNI_CAP_IRQ_ENABLE_EN 0
  C_OMNI_CAP_IRQ_STATUS    0
  C_OMNI_CAP_IRQ_STATUS_EN 0
  C_OMNI_CAP_SIZE          64
  C_OMNI_CAP_TAG           0
  C_OMNI_CAP_TYPE          581
  C_OMNI_CAP_VERSION       1
  NUMBER_OF_COLOR_PLANES   3
  PIXELS_IN_PARALLEL       ${PIP}
  RUNTIME_CONTROL          1
}]

::vh::create_cell isp_in_switch intel_vvp_switch [subst {
  BPS                      ${BPS}
  CRASH_SWITCH             0
  C_OMNI_CAP_ID_ASSOCIATED 0
  C_OMNI_CAP_ID_COMPONENT  1
  C_OMNI_CAP_IRQ           255
  C_OMNI_CAP_IRQ_ENABLE    0
  C_OMNI_CAP_IRQ_ENABLE_EN 0
  C_OMNI_CAP_IRQ_STATUS    0
  C_OMNI_CAP_IRQ_STATUS_EN 0
  C_OMNI_CAP_TAG           0
  C_OMNI_CAP_TYPE          565
  C_OMNI_CAP_VERSION       2
  ENABLE_DEBUG             ${EN_DEBUG}
  EXTERNAL_MODE            1
  NUMBER_OF_COLOR_PLANES   1
  NUM_INPUTS               ${NUM_INPUTS}
  NUM_OUTPUTS              1
  PIXELS_IN_PARALLEL       ${PIP}
  SEPARATE_SLAVE_CLOCK     1
  SLAVE_PROTOCOL           Avalon
  UNINTERRUPTED_INPUTS     0
  USE_OP_RESP              0
  USE_TREADIES             1
  VVP_INTF_TYPE            VVP_LITE
}]

::vh::sync

# ---------------------------------------------------------------------------
# Plain-pin connections
# ---------------------------------------------------------------------------

puts "isp_lite_in_subsystem: wiring up cells"
::vh::connect_pin {isp_in_cpu_clk_bridge out_clk} {isp_in_cpu_rst_bridge clk}
::vh::connect_pin {isp_in_cpu_clk_bridge out_clk} {isp_in_mm_bridge clk}
::vh::connect_pin {isp_in_cpu_clk_bridge out_clk} {isp_in_tpg agent_clock}
::vh::connect_pin {isp_in_cpu_clk_bridge out_clk} {isp_in_rms agent_clock}
::vh::connect_pin {isp_in_cpu_clk_bridge out_clk} {isp_in_switch agent_clock}

::vh::connect_pin {isp_in_cpu_rst_bridge out_reset} {isp_in_mm_bridge reset}
::vh::connect_pin {isp_in_cpu_rst_bridge out_reset} {isp_in_tpg agent_reset}
::vh::connect_pin {isp_in_cpu_rst_bridge out_reset} {isp_in_rms agent_reset}
::vh::connect_pin {isp_in_cpu_rst_bridge out_reset} {isp_in_switch agent_reset}

::vh::connect_pin {isp_in_vid_clk_bridge out_clk} {isp_in_vid_rst_bridge clk}
::vh::connect_pin {isp_in_vid_clk_bridge out_clk} {isp_in_tpg main_clock}
::vh::connect_pin {isp_in_vid_clk_bridge out_clk} {isp_in_rms main_clock}
::vh::connect_pin {isp_in_vid_clk_bridge out_clk} {isp_in_switch main_clock}

::vh::connect_pin {isp_in_vid_rst_bridge out_reset} {isp_in_tpg main_reset}
::vh::connect_pin {isp_in_vid_rst_bridge out_reset} {isp_in_rms main_reset}
::vh::connect_pin {isp_in_vid_rst_bridge out_reset} {isp_in_switch main_reset}

::vh::connect_if {isp_in_mm_bridge m0} {isp_in_tpg av_mm_control_agent}
::vh::connect_if {isp_in_mm_bridge m0} {isp_in_rms av_mm_control_agent}
::vh::connect_if {isp_in_mm_bridge m0} {isp_in_switch av_mm_control_agent}

::vh::connect_if {isp_in_tpg axi4s_vid_out} {isp_in_rms axi4s_vid_in}
::vh::connect_if {isp_in_rms axi4s_vid_out} {isp_in_switch axi4s_vid_in_0}

# -----------------------------------------------------------------------------
# Assign base addresses
# -----------------------------------------------------------------------------

puts "isp_lite_in_subsystem: assigning base addresses"

vds::assign_base_address

::vh::sync

# ---------------------------------------------------------------------------
# Exports
# ---------------------------------------------------------------------------

puts "isp_lite_in_subsystem: exporting pins/interfaces"
::vh::export_pin {isp_in_cpu_clk_bridge in_clk} cpu_clk_in
::vh::export_pin {isp_in_cpu_rst_bridge in_reset} cpu_rst_in
::vh::export_pin {isp_in_vid_clk_bridge in_clk} vid_clk_in
::vh::export_pin {isp_in_vid_rst_bridge in_reset} vid_rst_in

::vh::export_if {isp_in_mm_bridge s0} mm_ctrl_in
::vh::export_if {isp_in_switch axi4s_vid_in_1} mipi_csi2_0_s_vid_axis

if {$MULTI_SENSOR} {
  ::vh::export_if {isp_in_switch axi4s_vid_in_2} mipi_csi2_1_s_vid_axis
}

::vh::export_if {isp_in_switch axi4s_vid_out_0} isp_in_m_vid_axis

::vh::sync

puts "isp_lite_in_subsystem: build complete"
