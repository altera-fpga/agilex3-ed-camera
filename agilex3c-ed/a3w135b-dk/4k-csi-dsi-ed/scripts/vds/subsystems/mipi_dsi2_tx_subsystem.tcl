package require ::quartus::project

set script_dir [file dirname [file normalize [info script]]]
set project_dir [file normalize "${script_dir}/../../.."]

if {![is_project_open]} {
  cd $project_dir
  project_open top -revision top
}

# Force "IP Generation" to regenerate files on system change
file delete -force "${project_dir}/gen/vds/mipi_dsi2_tx_subsystem"

source "${project_dir}/scripts/vds/lib/vds_helpers.tcl"

puts "mipi_dsi2_tx_subsystem: creating system"
::vh::new_system "mipi_dsi2_tx_subsystem"

set continuous_clock 0

# ---------------------------------------------------------------------------
# Instances
# ---------------------------------------------------------------------------

puts "mipi_dsi2_tx_subsystem: creating cells"
::vh::create_cell mipi_out_cpu_clk_bridge altera_clock_bridge {
  EXPLICIT_CLOCK_RATE 100000000.0
  NUM_CLOCK_OUTPUTS   1
}

::vh::create_cell mipi_out_cpu_rst_bridge altera_reset_bridge {
  ACTIVE_LOW_RESET  0
  NUM_RESET_OUTPUTS 1
  SYNCHRONOUS_EDGES deassert
  SYNC_RESET        0
  USE_RESET_REQUEST 0
}

::vh::create_cell mipi_out_mipi_clk_bridge altera_clock_bridge {
  NUM_CLOCK_OUTPUTS 2
}

::vh::create_cell mipi_out_mipi_rst_bridge altera_reset_bridge {
  ACTIVE_LOW_RESET  0
  NUM_RESET_OUTPUTS 2
  SYNCHRONOUS_EDGES deassert
  SYNC_RESET        0
  USE_RESET_REQUEST 0
}

::vh::create_cell mipi_out_mm_bridge altera_avalon_mm_bridge {
  ADDRESS_UNITS            SYMBOLS
  ADDRESS_WIDTH            15
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

::vh::create_cell mipi_out_i2c altera_avalon_i2c {
  FIFO_DEPTH 4
  USE_AV_ST  0
}

::vh::create_cell mipi_out_mipi_dphy mipi_dphy [subst {
  GUI_ALT_CAL_EN_0                        0
  GUI_ALT_CAL_LEN                         65536
  GUI_BIT_RATE_MBPS_RNG_0                 900.0
  GUI_BYTE_LOC_0                          4
  GUI_CONTINUOUS_CLK_0                    $continuous_clock
  GUI_CORE_CLK_DIV_0                      8
  GUI_CORE_CLK_DIV_1                      8
  GUI_DPHY_IP_ROLE_0                      1
  GUI_NUM_LANES_0                         2
  GUI_NUM_PLL                             1
  GUI_PER_SKEW_CAL_EN_0                   0
  GUI_PPI_WIDTH_USR_0                     16
  GUI_PREAMBLE_EN_0                       0
  GUI_REF_CLK_FREQ_MHZ_0                  150.0
  GUI_REF_CLK_FREQ_MHZ_1                  20.0
  GUI_REF_CLK_IO_0                        3
  GUI_REF_CLK_IO_1                        0
  GUI_REF_CLK_IO_SHARE                    1
  GUI_RX_AUTO_TYPE_0                      2
  GUI_RX_BIT_RATE_MBPS_SEL_0              64
  GUI_RX_CAP_EQ_MODE_0                    0
  GUI_RX_CLK_LOSS_DETECT_0                3
  GUI_RX_CLK_LOSS_DETECT_0_AUTO_BOOL      1
  GUI_RX_CLK_POST_0                       1
  GUI_RX_CLK_SETTLE_0                     7
  GUI_RX_CLK_SETTLE_0_AUTO_BOOL           1
  GUI_RX_TM_CONTROL_RX_TM_EN_0            0
  GUI_RX_TM_CONTROL_RX_TM_LOOPBACK_MODE_0 0
  GUI_RZQ_ID                              1
  GUI_RZQ_SHARING                         0
  GUI_SKEW_CAL_EN_0                       0
  GUI_SKEW_CAL_LEN                        32768
  GUI_SOURCE_PLL_0                        0
  GUI_TM_EN_0                             0
  GUI_TM_LOOPBACK_MODE_0                  0
  GUI_TX_AUTO_TYPE_0                      2
  GUI_TX_CAP_EQ_MODE_0                    0
  GUI_TX_CLK_LANE_PS_0                    32
  GUI_TX_CLK_POST_0                       7
  GUI_TX_CLK_POST_0_AUTO_BOOL             1
  GUI_TX_CLK_PREPARE_0                    2
  GUI_TX_CLK_PREPARE_0_AUTO_BOOL          1
  GUI_TX_CLK_PRE_0                        3
  GUI_TX_CLK_PRE_0_AUTO_BOOL              1
  GUI_TX_CLK_TRAIL_0                      7
  GUI_TX_CLK_TRAIL_0_AUTO_BOOL            1
  GUI_TX_CLK_ZERO_0                       22
  GUI_TX_CLK_ZERO_0_AUTO_BOOL             1
  GUI_TX_HS_EXIT_0                        12
  GUI_TX_HS_EXIT_0_AUTO_BOOL              1
  GUI_TX_HS_PREPARE_0                     3
  GUI_TX_HS_PREPARE_0_AUTO_BOOL           1
  GUI_TX_HS_TM_DESKEW_P_0                 0
  GUI_TX_HS_TRAIL_0                       8
  GUI_TX_HS_TRAIL_0_AUTO_BOOL             1
  GUI_TX_HS_ZERO_0                        6
  GUI_TX_HS_ZERO_0_AUTO_BOOL              1
  GUI_TX_INIT_0                           12
  GUI_TX_INIT_0_AUTO_BOOL                 1
  GUI_TX_LPX_0                            6
  GUI_TX_LPX_0_AUTO_BOOL                  1
  GUI_TX_LP_EXIT_0                        12
  GUI_TX_LP_EXIT_0_AUTO_BOOL              1
  GUI_TX_PREAMBLE_LEN_PREAMLBE_LEN_0      0
  GUI_TX_TIMING_RW_0                      1
  GUI_TX_TM_CONTROL_TX_TM_EN_0            0
  GUI_TX_TM_CONTROL_TX_TM_LOOPBACK_MODE_0 0
  GUI_TX_VCO_FREQ_MULT_0                  2
  GUI_TX_WAKE_0                           111
  GUI_TX_WAKE_0_AUTO_BOOL                 1
  GUI_VCO_FREQ_MHZ_0                      993.75
  GUI_VCO_FREQ_MHZ_1                      600.0
  EX_DESIGN_GEN_BSI                       0
  EX_DESIGN_GEN_CDC                       0
  EX_DESIGN_GEN_SIM                       0
  EX_DESIGN_GEN_SYNTH                     0
  EX_DESIGN_HDL_FORMAT                    HDL_FORMAT_VERILOG
  EX_DESIGN_OSC_CLK_1_FREQ                OSC_CLK_1_125MHZ
  EX_DESIGN_SIM_CHK_PAR                   0
  EX_DESIGN_SIM_LOOPBACK                  1
  EX_DESIGN_SYNTH_MIRROR                  0
  EX_DESIGN_TEST_COUNT                    10
  EX_DESIGN_USE_TG                        0
  GUI_ALT_CAL_EN_1                        0
  GUI_BIT_RATE_MBPS_RNG_1                 1600.0
  GUI_BYTE_LOC_1                          4
  GUI_CONTINUOUS_CLK_1                    0
  GUI_NUM_LANES_1                         2
  GUI_PER_SKEW_CAL_EN_1                   0
  GUI_PPI_WIDTH_USR_1                     16
  GUI_PREAMBLE_EN_1                       0
  GUI_RX_AUTO_TYPE_1                      2
  GUI_RX_BIT_RATE_MBPS_SEL_1              64
  GUI_RX_CAP_EQ_MODE_1                    0
  GUI_RX_CLK_LOSS_DETECT_1                3
  GUI_RX_CLK_LOSS_DETECT_1_AUTO_BOOL      1
  GUI_RX_CLK_POST_1                       1
  GUI_RX_CLK_SETTLE_1                     7
  GUI_RX_CLK_SETTLE_1_AUTO_BOOL           1
  GUI_RX_TM_CONTROL_RX_TM_EN_1            0
  GUI_RX_TM_CONTROL_RX_TM_LOOPBACK_MODE_1 0
  GUI_SKEW_CAL_EN_1                       0
  GUI_SOURCE_PLL_1                        0
  GUI_TM_EN_1                             0
  GUI_TM_LOOPBACK_MODE_1                  0
  GUI_TX_AUTO_TYPE_1                      2
  GUI_TX_CAP_EQ_MODE_1                    0
  GUI_TX_CLK_LANE_PS_1                    32
  GUI_TX_CLK_POST_1                       7
  GUI_TX_CLK_POST_1_AUTO_BOOL             1
  GUI_TX_CLK_PREPARE_1                    2
  GUI_TX_CLK_PREPARE_1_AUTO_BOOL          1
  GUI_TX_CLK_PRE_1                        3
  GUI_TX_CLK_PRE_1_AUTO_BOOL              1
  GUI_TX_CLK_TRAIL_1                      7
  GUI_TX_CLK_TRAIL_1_AUTO_BOOL            1
  GUI_TX_CLK_ZERO_1                       22
  GUI_TX_CLK_ZERO_1_AUTO_BOOL             1
  GUI_TX_HS_EXIT_1                        12
  GUI_TX_HS_EXIT_1_AUTO_BOOL              1
  GUI_TX_HS_PREPARE_1                     3
  GUI_TX_HS_PREPARE_1_AUTO_BOOL           1
  GUI_TX_HS_TM_DESKEW_P_1                 0
  GUI_TX_HS_TRAIL_1                       8
  GUI_TX_HS_TRAIL_1_AUTO_BOOL             1
  GUI_TX_HS_ZERO_1                        6
  GUI_TX_HS_ZERO_1_AUTO_BOOL              1
  GUI_TX_INIT_1                           12
  GUI_TX_INIT_1_AUTO_BOOL                 1
  GUI_TX_LPX_1                            6
  GUI_TX_LPX_1_AUTO_BOOL                  1
  GUI_TX_LP_EXIT_1                        12
  GUI_TX_LP_EXIT_1_AUTO_BOOL              1
  GUI_TX_PREAMBLE_LEN_PREAMLBE_LEN_1      0
  GUI_TX_TIMING_RW_1                      1
  GUI_TX_TM_CONTROL_TX_TM_EN_1            0
  GUI_TX_TM_CONTROL_TX_TM_LOOPBACK_MODE_1 0
  GUI_TX_VCO_FREQ_MULT_1                  2
  GUI_TX_WAKE_1                           111
  GUI_TX_WAKE_1_AUTO_BOOL                 1
}]

::vh::create_cell mipi_out_mipi_dsi2_0 intel_mipi_dsi2_vds_fix [subst {
  BUFFER_DEPTH                2048
  BYTES_PER_LANE              2
  CLOCKS_ARE_SAME             1
  SEPARATE_SLAVE_CLOCK        1
  C_TIM_HS_START              156
  C_TIM_HS_END                176
  C_TIM_HB_END                965
  C_TIM_HTOTAL                2245
  C_TIM_V1B_START             0
  C_TIM_V1B_END               128
  C_TIM_V1S_HSTART            156
  C_TIM_V1S_HEND              156
  C_TIM_V1S_VSTART            40
  C_TIM_V1S_VEND              88
  C_TIM_VTOTAL                928
  DATA_TYPE                   RGB_24bit
  DIRECTION                   tx
  ENABLE_CRC                  1
  ENABLE_CSR                  1
  ENABLE_ECC                  1
  ENABLE_ED_FILESET_SIM       0
  ENABLE_ED_FILESET_SYNTHESIS 1
  ENABLE_FIXED_LATENCY        1
  ENABLE_PASSTHROUGH          0
  FRAME_WIDTH_PIXELS          1280
  LANE                        2
  PIXELS_IN_PARALLEL          1
  SELECT_ED_SIM_VARIANT       fast
  SELECT_SUPPORTED_VARIANT    3
  SELECT_TARGETED_BOARD       0
  VID_LIST                    0
  USE_CONTINUOUS_CLK          $continuous_clock
}]

::vh::sync

# ---------------------------------------------------------------------------
# Wiring
# ---------------------------------------------------------------------------

puts "mipi_dsi2_tx_subsystem: wiring up cells"

# Bridges clock + reset
::vh::connect_pin {mipi_out_mipi_clk_bridge out_clk} {mipi_out_mipi_rst_bridge clk}
::vh::connect_pin {mipi_out_cpu_clk_bridge out_clk} {mipi_out_cpu_rst_bridge clk}
::vh::connect_pin {mipi_out_cpu_clk_bridge out_clk} {mipi_out_mm_bridge clk}
::vh::connect_pin {mipi_out_cpu_rst_bridge out_reset} {mipi_out_mm_bridge reset}
::vh::connect_pin {mipi_out_cpu_rst_bridge out_reset} {mipi_out_mipi_rst_bridge in_reset}

# Other clocks + resets
::vh::connect_pin {mipi_out_cpu_clk_bridge out_clk} {mipi_out_mipi_dphy reg_clk}
::vh::connect_pin {mipi_out_cpu_rst_bridge out_reset} {mipi_out_mipi_dphy reg_srst}
::vh::connect_pin {mipi_out_cpu_rst_bridge out_reset} {mipi_out_mipi_dphy arst}

::vh::connect_pin {mipi_out_cpu_clk_bridge out_clk} {mipi_out_i2c clock}
::vh::connect_pin {mipi_out_cpu_rst_bridge out_reset} {mipi_out_i2c reset_sink}

::vh::connect_pin {mipi_out_cpu_clk_bridge out_clk} {mipi_out_mipi_dsi2_0 slave_clock}
::vh::connect_pin {mipi_out_cpu_rst_bridge out_reset} {mipi_out_mipi_dsi2_0 slave_reset}

::vh::connect_pin {mipi_out_mipi_clk_bridge out_clk} {mipi_out_mipi_dsi2_0 clk}
::vh::connect_pin {mipi_out_mipi_rst_bridge out_reset} {mipi_out_mipi_dsi2_0 reset}

# Export DSI TX clock
::vh::connect_pin {mipi_out_mipi_dphy LINK0_CK_ppi_tx_hs_clk} {mipi_out_mipi_clk_bridge in_clk}

# MIPI PHY <-> MIPI core
::vh::connect_pin {mipi_out_mipi_dphy LINK0_CK_ppi_tx_hs_clk} {mipi_out_mipi_dsi2_0 ck_ppi_hs_clk}
::vh::connect_pin {mipi_out_mipi_dphy LINK0_CK_ppi_tx_lp_clk} {mipi_out_mipi_dsi2_0 ck_ppi_tx_lp_clk}
::vh::connect_pin {mipi_out_mipi_dphy LINK0_D0_ppi_tx_hs_clk} {mipi_out_mipi_dsi2_0 d0_ppi_hs_clk}
::vh::connect_pin {mipi_out_mipi_dphy LINK0_D0_ppi_tx_lp_clk} {mipi_out_mipi_dsi2_0 d0_ppi_tx_lp_clk}
::vh::connect_pin {mipi_out_mipi_dphy LINK0_D1_ppi_tx_hs_clk} {mipi_out_mipi_dsi2_0 d1_ppi_hs_clk}
::vh::connect_pin {mipi_out_mipi_dphy LINK0_D1_ppi_tx_lp_clk} {mipi_out_mipi_dsi2_0 d1_ppi_tx_lp_clk}
::vh::connect_if {mipi_out_mipi_dsi2_0 ck_ppi_hs} {mipi_out_mipi_dphy LINK0_CK_ppi_tx_hs}
::vh::connect_if {mipi_out_mipi_dsi2_0 ck_ppi_lp} {mipi_out_mipi_dphy LINK0_CK_ppi_tx_lp}
::vh::connect_if {mipi_out_mipi_dphy LINK0_CK_ppi_ctrl} {mipi_out_mipi_dsi2_0 ck_ppi_ctrl}
::vh::connect_if {mipi_out_mipi_dsi2_0 d0_ppi_hs} {mipi_out_mipi_dphy LINK0_D0_ppi_tx_hs}
::vh::connect_if {mipi_out_mipi_dsi2_0 d0_ppi_lp} {mipi_out_mipi_dphy LINK0_D0_ppi_tx_lp}
::vh::connect_if {mipi_out_mipi_dphy LINK0_D0_ppi_ctrl} {mipi_out_mipi_dsi2_0 d0_ppi_ctrl}
::vh::connect_if {mipi_out_mipi_dsi2_0 d1_ppi_hs} {mipi_out_mipi_dphy LINK0_D1_ppi_tx_hs}
::vh::connect_if {mipi_out_mipi_dsi2_0 d1_ppi_lp} {mipi_out_mipi_dphy LINK0_D1_ppi_tx_lp}
::vh::connect_if {mipi_out_mipi_dphy LINK0_D1_ppi_ctrl} {mipi_out_mipi_dsi2_0 d1_ppi_ctrl}

# Control interfaces
::vh::connect_if {mipi_out_mm_bridge m0} {mipi_out_mipi_dphy axi_lite}
::vh::connect_if {mipi_out_mm_bridge m0} {mipi_out_i2c csr}
::vh::connect_if {mipi_out_mm_bridge m0} {mipi_out_mipi_dsi2_0 control}

::vh::sync

# ---------------------------------------------------------------------------
# Assign base addresses
# ---------------------------------------------------------------------------

puts "mipi_dsi2_tx_subsystem: assigning base addresses"
::vh::assign_base_address {mipi_out_mm_bridge m0} {mipi_out_mipi_dphy axi_lite} 0x00000000
::vh::assign_base_address {mipi_out_mm_bridge m0} {mipi_out_i2c csr} 0x00002000
::vh::assign_base_address {mipi_out_mm_bridge m0} {mipi_out_mipi_dsi2_0 control} 0x00004000

::vh::lock_base_address {mipi_out_mipi_dphy axi_lite}
::vh::lock_base_address {mipi_out_mipi_dphy axi_lite}
::vh::lock_base_address {mipi_out_i2c csr}
::vh::lock_base_address {mipi_out_mipi_dsi2_0 control}

::vh::sync

# ---------------------------------------------------------------------------
# Exports
# ---------------------------------------------------------------------------

puts "mipi_dsi2_tx_subsystem: exporting pins/interfaces"
::vh::export_pin {mipi_out_cpu_clk_bridge in_clk} cpu_clk
::vh::export_pin {mipi_out_cpu_rst_bridge in_reset} cpu_rst
::vh::export_pin {mipi_out_mipi_clk_bridge out_clk_1} vid_mipi_clk
::vh::export_pin {mipi_out_mipi_rst_bridge out_reset_1} vid_mipi_rst
::vh::export_pin {mipi_out_mipi_dsi2_0 frame_start} mipi_dsi2_0_frame_start
::vh::export_pin {mipi_out_mipi_dphy rzq} mipi_dphy_rzq
::vh::export_pin {mipi_out_mipi_dphy ref_clk_0} mipi_dphy_ref_clk_0

::vh::export_if {mipi_out_mm_bridge s0} mm_ctrl_in
::vh::export_if {mipi_out_i2c i2c_serial} dsi_i2c
::vh::export_if {mipi_out_i2c interrupt_sender} dsi_i2c_irq
::vh::export_if {mipi_out_mipi_dsi2_0 axi4s_vid_in} mipi_dsi2_0_vid_axis_in
::vh::export_if {mipi_out_mipi_dphy LINK0_dphy_io} mipi_dphy_LINK0_dphy_io

::vh::sync

puts "mipi_dsi2_tx_subsystem: build complete"
