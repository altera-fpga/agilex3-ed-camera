package require ::quartus::project

set script_dir [file dirname [file normalize [info script]]]
set project_dir [file normalize "${script_dir}/../../.."]

if {![is_project_open]} {
  cd $project_dir
  project_open top -revision top
}

# Force "IP Generation" to regenerate files on system change
file delete -force "${project_dir}/gen/vds/mipi_rx_subsystem"

source "${project_dir}/scripts/vds/lib/vds_helpers.tcl"

# ---------------------------------------------------------------------------
# Parameters (AGX_3C_Devkit / connector J21)
# ---------------------------------------------------------------------------

set REF_CLK_FREQ 150.0
set VCO_CLK_FREQ 600.0
set BYTE_LOC 4
set CONTINUOUS_CLK 1
set EN_DEBUG 0
set PIP 1

puts "mipi_rx_subsystem: creating system"
::vh::new_system "mipi_rx_subsystem"

# ---------------------------------------------------------------------------
# Instances
# ---------------------------------------------------------------------------

puts "mipi_rx_subsystem: creating cells"

::vh::create_cell mipi_in_cpu_clk_bridge altera_clock_bridge {
  EXPLICIT_CLOCK_RATE 100000000.0
  NUM_CLOCK_OUTPUTS   1
}

::vh::create_cell mipi_in_cpu_rst_bridge altera_reset_bridge {
  ACTIVE_LOW_RESET  0
  NUM_RESET_OUTPUTS 1
  SYNCHRONOUS_EDGES deassert
  SYNC_RESET        0
  USE_RESET_REQUEST 0
}

::vh::create_cell mipi_in_vid_clk_bridge altera_clock_bridge {
  EXPLICIT_CLOCK_RATE 297000000.0
  NUM_CLOCK_OUTPUTS   1
}

::vh::create_cell mipi_in_vid_rst_bridge altera_reset_bridge {
  ACTIVE_LOW_RESET  0
  NUM_RESET_OUTPUTS 1
  SYNCHRONOUS_EDGES deassert
  SYNC_RESET        0
  USE_RESET_REQUEST 0
}

::vh::create_cell mipi_in_mm_bridge altera_avalon_mm_bridge {
  ADDRESS_UNITS            SYMBOLS
  ADDRESS_WIDTH            14
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
  SYNC_RESET               1
  USE_AUTO_ADDRESS_WIDTH   1
  USE_RESPONSE             0
  USE_WRITERESPONSE        0
}

::vh::create_cell cam_i2c altera_avalon_i2c {
  FIFO_DEPTH 32
  USE_AV_ST  0
}

# mipi_in_mipi_dphy -- see the header comment above re: the create_cell
# -properties bug. Never set these via a properties dict at creation time.
::vh::create_cell mipi_in_mipi_dphy mipi_dphy [subst {
    GUI_ALT_CAL_EN_0                        0
    GUI_ALT_CAL_LEN                         65536
    GUI_BIT_RATE_MBPS_RNG_0                 1500.0
    GUI_BYTE_LOC_0                          ${BYTE_LOC}
    GUI_CONTINUOUS_CLK_0                    0
    GUI_CORE_CLK_DIV_0                      8
    GUI_CORE_CLK_DIV_1                      8
    GUI_DPHY_IP_ROLE_0                      0
    GUI_NUM_LANES_0                         2
    GUI_NUM_PLL                             1
    GUI_PER_SKEW_CAL_EN_0                   0
    GUI_PPI_WIDTH_USR_0                     16
    GUI_PREAMBLE_EN_0                       0
    GUI_REF_CLK_FREQ_MHZ_0                  ${REF_CLK_FREQ}
    GUI_REF_CLK_FREQ_MHZ_1                  20.0
    GUI_REF_CLK_IO_0                        3
    GUI_REF_CLK_IO_1                        0
    GUI_REF_CLK_IO_SHARE                    1
    GUI_RX_AUTO_TYPE_0                      2
    GUI_RX_BIT_RATE_MBPS_SEL_0              64
    GUI_RX_CLK_LOSS_DETECT_0                3
    GUI_RX_CLK_LOSS_DETECT_0_AUTO_BOOL      1
    GUI_RX_CLK_POST_0                       1
    GUI_RX_CLK_SETTLE_0                     7
    GUI_RX_CLK_SETTLE_0_AUTO_BOOL           1
    GUI_RX_DLANE_DESKEW_DELAY_0_0           48
    GUI_RX_DLANE_DESKEW_DELAY_1_0           48
    GUI_RX_DLANE_DESKEW_DELAY_2_0           48
    GUI_RX_DLANE_DESKEW_DELAY_3_0           48
    GUI_RX_DLANE_DESKEW_DELAY_4_0           0
    GUI_RX_DLANE_DESKEW_DELAY_5_0           0
    GUI_RX_DLANE_DESKEW_DELAY_6_0           0
    GUI_RX_DLANE_DESKEW_DELAY_7_0           0
    GUI_RX_HS_SETTLE_0                      2
    GUI_RX_HS_SETTLE_0_AUTO_BOOL            1
    GUI_RX_INIT_0                           12
    GUI_RX_INIT_0_AUTO_BOOL                 1
    GUI_RX_PREP_TIME_TM_0                   0
    GUI_RX_TIMING_RW_0                      1
    GUI_RX_TM_CONTROL_RX_TM_EN_0            0
    GUI_RX_TM_CONTROL_RX_TM_LOOPBACK_MODE_0 0
    GUI_RZQ_ID                              1
    GUI_SKEW_CAL_EN_0                       0
    GUI_SKEW_CAL_LEN                        32768
    GUI_SOURCE_PLL_0                        0
    GUI_TM_EN_0                             0
    GUI_TM_LOOPBACK_MODE_0                  0
    GUI_VCO_FREQ_MHZ_0                      ${VCO_CLK_FREQ}
    GUI_VCO_FREQ_MHZ_1                      600.0
}]

::vh::create_cell mipi_in_mipi_csi2 intel_mipi_csi2 [subst {
    BITS_PER_LANE                        16
    BUFFER_DEPTH                         4096
    DIRECTION                            rx
    ENABLE_ED_FILESET_SIM                0
    ENABLE_ED_FILESET_SYNTHESIS          1
    ENABLE_SCRAMBLING                    0
    LANE                                 2
    NUMBER_OF_VIDEO_STREAMING_INTERFACES 1
    PIXELS_IN_PARALLEL                   1
    SELECT_CUSTOM_DEVICE                 0
    SELECT_ED_FILESET                    VERILOG
    SELECT_SUPPORTED_VARIANT             1
    SELECT_TARGETED_BOARD                0
    SUPPORT_LEGACY_YUV420_8B             0
    SUPPORT_RAW10                        0
    SUPPORT_RAW12                        1
    SUPPORT_RAW14                        0
    SUPPORT_RAW16                        0
    SUPPORT_RAW20                        0
    SUPPORT_RAW24                        0
    SUPPORT_RAW6                         0
    SUPPORT_RAW7                         0
    SUPPORT_RAW8                         0
    SUPPORT_RGB444                       0
    SUPPORT_RGB555                       0
    SUPPORT_RGB565                       0
    SUPPORT_RGB666                       0
    SUPPORT_RGB888                       0
    SUPPORT_YUV420_10B                   0
    SUPPORT_YUV420_8B                    0
    SUPPORT_YUV422_10B                   0
    SUPPORT_YUV422_8B                    0
    ENABLE_ECC                           0
    ENABLE_CRC                           0
    ENABLE_CSR                           0
    USE_CONTINUOUS_CLK                   ${CONTINUOUS_CLK}
    VIDEO_INTERFACE_MODE                 simple
}]

::vh::create_cell mipi_in_proto_conv intel_vvp_protocol_conv [subst {
    BPS                      12
    CHROMA_SAMPLING          444
    CHROMA_SITING            TOP_LEFT
    CLIP_LONG_FIELDS         0
    COLOR_SPACE              RGB
    ENABLE_DEBUG             ${EN_DEBUG}
    ENABLE_TIMEOUT           0
    ENABLE_YCBCR_SWAP        0
    INPUT_MODE               INTERNAL
    NUMBER_OF_COLOR_PLANES   1
    OUTPUT_MODE              EXTERNAL
    PIPELINE_READY           1
    PIXELS_IN_PARALLEL       1
    RUNTIME_CONTROL          0
    SEPARATE_SLAVE_CLOCK     0
    VIP_USER_SUPPORT         DISCARD
    VVP_USER_SUPPORT         NONE_ALLOWED
}]

::vh::sync

# -----------------------------------------------------------------------------
# Wiring
# -----------------------------------------------------------------------------

puts "mipi_rx_subsystem: wiring up cells"

::vh::connect_pin {mipi_in_cpu_clk_bridge out_clk} {mipi_in_cpu_rst_bridge clk}
::vh::connect_pin {mipi_in_cpu_clk_bridge out_clk} {mipi_in_mm_bridge clk}
::vh::connect_pin {mipi_in_cpu_clk_bridge out_clk} {cam_i2c clock}
::vh::connect_pin {mipi_in_cpu_clk_bridge out_clk} {mipi_in_mipi_dphy reg_clk}

::vh::connect_pin {mipi_in_cpu_rst_bridge out_reset} {mipi_in_mm_bridge reset}
::vh::connect_pin {mipi_in_cpu_rst_bridge out_reset} {cam_i2c reset_sink}
::vh::connect_pin {mipi_in_cpu_rst_bridge out_reset} {mipi_in_mipi_dphy reg_srst}
::vh::connect_pin {mipi_in_cpu_rst_bridge out_reset} {mipi_in_mipi_dphy arst}

::vh::connect_pin {mipi_in_vid_clk_bridge out_clk} {mipi_in_vid_rst_bridge clk}
::vh::connect_pin {mipi_in_vid_clk_bridge out_clk} {mipi_in_mipi_csi2 axi4s_clk}
::vh::connect_pin {mipi_in_vid_clk_bridge out_clk} {mipi_in_proto_conv main_clock}

::vh::connect_pin {mipi_in_vid_rst_bridge out_reset} {mipi_in_mipi_csi2 axi4s_rst}
::vh::connect_pin {mipi_in_vid_rst_bridge out_reset} {mipi_in_proto_conv main_reset}

# D-PHY <-> CSI2 raw PPI hs_clk/hs_srst pins (plain, per-lane: D0/D1/CK)
::vh::connect_pin {mipi_in_mipi_dphy LINK0_D0_ppi_rx_hs_clk} {mipi_in_mipi_csi2 d0_ppi_hs_clk}
::vh::connect_pin {mipi_in_mipi_dphy LINK0_D0_ppi_rx_hs_srst} {mipi_in_mipi_csi2 d0_ppi_rx_hs_srst}

::vh::connect_pin {mipi_in_mipi_dphy LINK0_D1_ppi_rx_hs_clk} {mipi_in_mipi_csi2 d1_ppi_hs_clk}
::vh::connect_pin {mipi_in_mipi_dphy LINK0_D1_ppi_rx_hs_srst} {mipi_in_mipi_csi2 d1_ppi_rx_hs_srst}

::vh::connect_pin {mipi_in_mipi_dphy LINK0_CK_ppi_rx_hs_clk} {mipi_in_mipi_csi2 ck_ppi_hs_clk}
::vh::connect_pin {mipi_in_mipi_dphy LINK0_CK_ppi_rx_hs_srst} {mipi_in_mipi_csi2 ck_ppi_rx_hs_srst}

# D-PHY <-> CSI2 PPI control/hs/lp/err bus interfaces (per-lane: D0/D1/CK).
# NOTE: on the D-PHY side these are named LINK0_<lane>_ppi_ctrl /
# LINK0_<lane>_ppi_rx_hs / LINK0_<lane>_ppi_rx_lp / LINK0_<lane>_ppi_rx_err;
# on the CSI2 side they drop the LINK0_/rx_ prefixes (and rx_err becomes
# i_<lane>_ppi_rx_err on input), verified live against the catalog IP.
foreach lane {D0 D1 CK} {
  set lane_lc [string tolower $lane]
  ::vh::connect_if [list mipi_in_mipi_dphy "LINK0_${lane}_ppi_ctrl"] [list mipi_in_mipi_csi2 "${lane_lc}_ppi_ctrl"]
  ::vh::connect_if [list mipi_in_mipi_dphy "LINK0_${lane}_ppi_rx_hs"] [list mipi_in_mipi_csi2 "${lane_lc}_ppi_hs"]
  ::vh::connect_if [list mipi_in_mipi_dphy "LINK0_${lane}_ppi_rx_lp"] [list mipi_in_mipi_csi2 "${lane_lc}_ppi_lp"]
  ::vh::connect_if [list mipi_in_mipi_dphy "LINK0_${lane}_ppi_rx_err"] [list mipi_in_mipi_csi2 "i_${lane_lc}_ppi_rx_err"]
}

::vh::connect_if {mipi_in_mipi_csi2 video_streaming_interface_0} {mipi_in_proto_conv axi4s_vid_in}

::vh::connect_if {mipi_in_mm_bridge m0} {mipi_in_mipi_dphy axi_lite}
::vh::connect_if {mipi_in_mm_bridge m0} {cam_i2c csr}

::vh::sync

# -----------------------------------------------------------------------------
# Assign base addresses
# -----------------------------------------------------------------------------

puts "mipi_rx_subsystem: assigning base addresses"

vds::assign_base_address

::vh::sync

# -----------------------------------------------------------------------------
# Exports
# -----------------------------------------------------------------------------

puts "mipi_rx_subsystem: exporting pins/interfaces"
::vh::export_pin {mipi_in_cpu_clk_bridge in_clk} cpu_clk_in
::vh::export_pin {mipi_in_cpu_rst_bridge in_reset} cpu_rst_in
::vh::export_pin {mipi_in_vid_clk_bridge in_clk} vid_clk_in
::vh::export_pin {mipi_in_vid_rst_bridge in_reset} vid_rst_in
::vh::export_pin {mipi_in_mipi_dphy ref_clk_0} mipi_dphy_ref_clk_0
::vh::export_pin {mipi_in_mipi_dphy rzq} mipi_dphy_rzq

::vh::export_if {mipi_in_mm_bridge s0} mm_ctrl_in
::vh::export_if {mipi_in_mipi_dphy reg_bus} reg_bus
::vh::export_if {mipi_in_mipi_dphy LINK0_dphy_io} mipi_dphy_LINK0_dphy_io
::vh::export_if {mipi_in_proto_conv axi4s_vid_out} mipi_csi2_m_vid_axis
::vh::export_if {cam_i2c i2c_serial} cam_i2c_i2c_serial
::vh::export_if {cam_i2c interrupt_sender} cam_i2c_irq

::vh::sync

puts "mipi_rx_subsystem: build complete"
