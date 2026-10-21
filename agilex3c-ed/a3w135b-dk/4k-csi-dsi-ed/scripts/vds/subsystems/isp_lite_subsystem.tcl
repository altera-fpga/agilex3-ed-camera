package require ::quartus::project

set script_dir [file dirname [file normalize [info script]]]
set project_dir [file normalize "${script_dir}/../../.."]

if {![is_project_open]} {
    cd $project_dir
    project_open top -revision top
}

# Force "IP Generation" to regenerate files on system change
file delete -force "${project_dir}/gen/vds/isp_lite_subsystem"

source "${project_dir}/scripts/vds/lib/vds_helpers.tcl"

# ---------------------------------------------------------------------------
# Parameters
# ---------------------------------------------------------------------------

set PIP         1
set VID_OUT_BPS 10
set EN_DEBUG    0
set ISP_BPS     12

# Input bayer
set ISP_CPPP    1

# Output RGB
set CPPP        3

puts "isp_lite_subsystem: creating system"
set params_str "PIP=$PIP, ISP_BPS=$ISP_BPS, VID_OUT_BPS=$VID_OUT_BPS"
puts "isp_lite_subsystem: subsystem parameters: $params_str"

::vh::new_system "isp_lite_subsystem"

# ---------------------------------------------------------------------------
# Instances
# ---------------------------------------------------------------------------

puts "isp_lite_subsystem: creating cells"
::vh::create_cell isp_cpu_clk_bridge altera_clock_bridge {
  EXPLICIT_CLOCK_RATE 100000000.0
  NUM_CLOCK_OUTPUTS   1
}

::vh::create_cell isp_cpu_rst_bridge altera_reset_bridge {
  ACTIVE_LOW_RESET  0
  NUM_RESET_OUTPUTS 1
  SYNCHRONOUS_EDGES deassert
  SYNC_RESET        0
  USE_RESET_REQUEST 0
}

::vh::create_cell isp_vid_clk_bridge altera_clock_bridge {
  EXPLICIT_CLOCK_RATE 297000000.0
  NUM_CLOCK_OUTPUTS   1
}

::vh::create_cell isp_vid_rst_bridge altera_reset_bridge {
  ACTIVE_LOW_RESET  0
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

::vh::create_cell isp_blc intel_vvp_blc [subst {
  AV_MAX_PENDING_READS       8
  BPS_IN                     ${ISP_BPS}
  BPS_OUT                    ${ISP_BPS}
  DUPLICATE_AND_BYPASS       0
  ENABLE_DEBUG               ${EN_DEBUG}
  ENABLE_EXT_DATA_RW         0
  EXTERNAL_MODE              1
  H_TAPS                     1
  MAX_HEIGHT                 4096
  MAX_WIDTH                  4096
  NO_BLANKING                1
  NUMBER_OF_COLOR_PLANES_IN  ${ISP_CPPP}
  NUMBER_OF_COLOR_PLANES_OUT ${ISP_CPPP}
  NUM_EXT_DATA_REGS          0
  PIPELINE_DATA_MM           0
  PIPELINE_READY             1
  PIXELS_IN_PARALLEL         ${PIP}
  REFLECT_AROUND_ZERO        1
  RUNTIME_CONTROL            1
  SEPARATE_SLAVE_CLOCK       1
  V_TAPS                     1
}]

::vh::create_cell isp_wbc intel_vvp_wbc [subst {
  AV_MAX_PENDING_READS       8
  BPS_IN                     ${ISP_BPS}
  BPS_OUT                    ${ISP_BPS}
  DUPLICATE_AND_BYPASS       0
  ENABLE_DEBUG               ${EN_DEBUG}
  ENABLE_EXT_DATA_RW         0
  EXTERNAL_MODE              1
  H_TAPS                     1
  MAX_HEIGHT                 4096
  MAX_WIDTH                  4096
  NO_BLANKING                1
  NUMBER_OF_COLOR_PLANES_IN  ${ISP_CPPP}
  NUMBER_OF_COLOR_PLANES_OUT ${ISP_CPPP}
  NUM_EXT_DATA_REGS          0
  PIPELINE_DATA_MM           0
  PIPELINE_READY             1
  PIXELS_IN_PARALLEL         ${PIP}
  RUNTIME_CONTROL            1
  SEPARATE_SLAVE_CLOCK       1
  V_TAPS                     1
}]

::vh::create_cell isp_dms intel_vvp_demosaic [subst {
  AV_MAX_PENDING_READS       8
  BPS_IN                     ${ISP_BPS}
  BPS_OUT                    ${ISP_BPS}
  DUPLICATE_AND_BYPASS       0
  ENABLE_DEBUG               ${EN_DEBUG}
  ENABLE_EXT_DATA_RW         0
  EXTERNAL_MODE              1
  H_TAPS                     5
  MAX_HEIGHT                 4096
  MAX_WIDTH                  4096
  NO_BLANKING                1
  NUMBER_OF_COLOR_PLANES_IN  ${ISP_CPPP}
  NUMBER_OF_COLOR_PLANES_OUT ${CPPP}
  NUM_EXT_DATA_REGS          0
  PIPELINE_DATA_MM           0
  PIPELINE_READY             1
  PIXELS_IN_PARALLEL         ${PIP}
  RUNTIME_CONTROL            1
  SEPARATE_SLAVE_CLOCK       1
  V_TAPS                     5
}]

::vh::create_cell isp_ccm intel_vvp_csc [subst {
  BPS_IN                  ${ISP_BPS}
  BPS_OUT                 ${VID_OUT_BPS}
  COEFFICIENT_INT_BITS    8
  COEFFICIENT_SIGNED      1
  COEF_SUM_FRACTION_BITS  8
  ENABLE_DEBUG            ${EN_DEBUG}
  EXTERNAL_MODE           1
  MOVE_BINARY_POINT_RIGHT 0
  OUTPUT_COLORSPACE       0
  PIPELINE_READY          1
  PIXELS_IN_PARALLEL      ${PIP}
  REMOVE_FRACTION_METHOD  1
  REQ_FCOEFF_A0           1.0
  REQ_FCOEFF_A1           0.0
  REQ_FCOEFF_A2           0.0
  REQ_FCOEFF_B0           0.0
  REQ_FCOEFF_B1           1.0
  REQ_FCOEFF_B2           0.0
  REQ_FCOEFF_C0           0.0
  REQ_FCOEFF_C1           0.0
  REQ_FCOEFF_C2           1.0
  REQ_FCOEFF_S0           0.0
  REQ_FCOEFF_S1           0.0
  REQ_FCOEFF_S2           0.0
  RUNTIME_CONTROL         1
  SEPARATE_SLAVE_CLOCK    1
  SUMMAND_INT_BITS        10
  SUMMAND_SIGNED          1
}]

::vh::sync

# -----------------------------------------------------------------------------
# Wiring
# -----------------------------------------------------------------------------

puts "isp_lite_subsystem: wiring up cells"

::vh::connect_pin {isp_cpu_clk_bridge out_clk} {isp_cpu_rst_bridge clk}
::vh::connect_pin {isp_cpu_clk_bridge out_clk} {isp_mm_bridge clk}
::vh::connect_pin {isp_cpu_clk_bridge out_clk} {isp_blc agent_clock}
::vh::connect_pin {isp_cpu_clk_bridge out_clk} {isp_wbc agent_clock}
::vh::connect_pin {isp_cpu_clk_bridge out_clk} {isp_dms agent_clock}
::vh::connect_pin {isp_cpu_clk_bridge out_clk} {isp_ccm agent_clock}

::vh::connect_pin {isp_cpu_rst_bridge out_reset} {isp_mm_bridge reset}
::vh::connect_pin {isp_cpu_rst_bridge out_reset} {isp_blc agent_reset}
::vh::connect_pin {isp_cpu_rst_bridge out_reset} {isp_wbc agent_reset}
::vh::connect_pin {isp_cpu_rst_bridge out_reset} {isp_dms agent_reset}
::vh::connect_pin {isp_cpu_rst_bridge out_reset} {isp_ccm agent_reset}

::vh::connect_pin {isp_vid_clk_bridge out_clk} {isp_vid_rst_bridge clk}
::vh::connect_pin {isp_vid_clk_bridge out_clk} {isp_blc main_clock}
::vh::connect_pin {isp_vid_clk_bridge out_clk} {isp_wbc main_clock}
::vh::connect_pin {isp_vid_clk_bridge out_clk} {isp_dms main_clock}
::vh::connect_pin {isp_vid_clk_bridge out_clk} {isp_ccm main_clock}

::vh::connect_pin {isp_vid_rst_bridge out_reset} {isp_blc main_reset}
::vh::connect_pin {isp_vid_rst_bridge out_reset} {isp_wbc main_reset}
::vh::connect_pin {isp_vid_rst_bridge out_reset} {isp_dms main_reset}
::vh::connect_pin {isp_vid_rst_bridge out_reset} {isp_ccm main_reset}

::vh::connect_if {isp_mm_bridge m0} {isp_blc av_mm_control_agent}
::vh::connect_if {isp_mm_bridge m0} {isp_wbc av_mm_control_agent}
::vh::connect_if {isp_mm_bridge m0} {isp_dms av_mm_control_agent}
::vh::connect_if {isp_mm_bridge m0} {isp_ccm av_mm_control_agent}

::vh::connect_if {isp_blc axi4s_vid_out} {isp_wbc axi4s_vid_in}
::vh::connect_if {isp_wbc axi4s_vid_out} {isp_dms axi4s_vid_in}
::vh::connect_if {isp_dms axi4s_vid_out} {isp_ccm axi4s_vid_in}

::vh::sync

# -----------------------------------------------------------------------------
# Assign base addresses
# -----------------------------------------------------------------------------

puts "isp_lite_subsystem: assigning base addresses"

vds::assign_base_address

::vh::sync

# -----------------------------------------------------------------------------
# Exports
# -----------------------------------------------------------------------------

puts "isp_lite_subsystem: exporting pins/interfaces"

::vh::export_pin {isp_cpu_clk_bridge in_clk}   cpu_clk_in
::vh::export_pin {isp_cpu_rst_bridge in_reset} cpu_rst_in
::vh::export_pin {isp_vid_clk_bridge in_clk}   vid_clk_in
::vh::export_pin {isp_vid_rst_bridge in_reset} vid_rst_in

::vh::export_if {isp_mm_bridge s0}      mm_ctrl_in
::vh::export_if {isp_blc axi4s_vid_in}  isp_in_s_vid_axis
::vh::export_if {isp_ccm axi4s_vid_out} isp_out_m_vid_axis

::vh::sync

puts "isp_lite_subsystem: build complete"
