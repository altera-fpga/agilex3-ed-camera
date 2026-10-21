package require ::quartus::project

set script_dir [file dirname [file normalize [info script]]]
set project_dir [file normalize "${script_dir}/../../.."]

if {![is_project_open]} {
  cd $project_dir
  project_open top -revision top
}

source "${project_dir}/scripts/vds/lib/vds_helpers.tcl"

puts "dp_tx_subsystem: creating system"
::vh::new_system "dp_tx_subsystem"

# -----------------------------------------------------------------------------
# Instances
# -----------------------------------------------------------------------------

puts "dp_tx_subsystem: creating cells"
::vh::create_cell clk_16 altera_clock_bridge {
  EXPLICIT_CLOCK_RATE 16000000.0
  NUM_CLOCK_OUTPUTS   1
}

::vh::create_cell rst_16 altera_reset_bridge {
  ACTIVE_LOW_RESET  0
  NUM_RESET_OUTPUTS 1
  SYNCHRONOUS_EDGES deassert
  SYNC_RESET        0
  USE_RESET_REQUEST 0
}

::vh::create_cell mgmt_clk altera_clock_bridge {
  EXPLICIT_CLOCK_RATE 100000000.0
  NUM_CLOCK_OUTPUTS   1
}

::vh::create_cell mgmt_rst altera_reset_bridge {
  ACTIVE_LOW_RESET  0
  NUM_RESET_OUTPUTS 1
  SYNCHRONOUS_EDGES deassert
  SYNC_RESET        0
  USE_RESET_REQUEST 0
}
::vh::create_cell dp_tx_mgmt_bridge altera_avalon_mm_bridge {
  ADDRESS_UNITS            SYMBOLS
  ADDRESS_WIDTH            10
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

::vh::create_cell vvp_clock_bridge altera_clock_bridge {
  EXPLICIT_CLOCK_RATE 148500000.0
  NUM_CLOCK_OUTPUTS   1
}

::vh::create_cell vvp_reset_bridge altera_reset_bridge {
  ACTIVE_LOW_RESET   0
  NUM_RESET_OUTPUTS  1
  SYNCHRONOUS_EDGES  deassert
  SYNC_RESET         0
  USE_RESET_REQUEST  0
}

::vh::create_cell i2c_master altera_avalon_i2c {
  FIFO_DEPTH 32
  USE_AV_ST  0
}

::vh::create_cell dp_core_i2c_board altera_avalon_i2c {
  FIFO_DEPTH 32
  USE_AV_ST  0
}

::vh::create_cell dp_core_pio_board altera_avalon_pio {
  bitClearingEdgeCapReg 0
  bitModifyingOutReg    0
  captureEdge           0
  direction             Output
  edgeType              RISING
  generateIRQ           0
  irqType               LEVEL
  resetValue            0.0
  simDoTestBenchWiring  0
  simDrivenValue        0.0
  width                 32
}

::vh::create_cell pio_status altera_avalon_pio {
  bitClearingEdgeCapReg 0
  bitModifyingOutReg    0
  captureEdge           0
  direction             Output
  edgeType              RISING
  generateIRQ           0
  irqType               LEVEL
  resetValue            0.0
  simDoTestBenchWiring  0
  simDrivenValue        0.0
  width                 32
}

::vh::create_cell pio_supportd_fmats altera_avalon_pio {
  bitClearingEdgeCapReg 0
  bitModifyingOutReg    0
  captureEdge           0
  direction             Output
  edgeType              RISING
  generateIRQ           0
  irqType               LEVEL
  resetValue            0.0
  simDoTestBenchWiring  0
  simDrivenValue        0.0
  width                 32
}

::vh::create_cell pio_curr_format altera_avalon_pio {
  bitClearingEdgeCapReg 0
  bitModifyingOutReg    0
  captureEdge           0
  direction             Output
  edgeType              RISING
  generateIRQ           0
  irqType               LEVEL
  resetValue            0.0
  simDoTestBenchWiring  0
  simDrivenValue        0.0
  width                 32
}

::vh::create_cell pio_format_ovrride altera_avalon_pio {
  bitClearingEdgeCapReg 0
  bitModifyingOutReg 0
  captureEdge 0
  direction Input
  edgeType RISING
  generateIRQ 0
  irqType LEVEL
  resetValue 0.0
  simDoTestBenchWiring 0
  simDrivenValue 0.0
  width 32
}

::vh::create_cell dp_source altera_dp {
  ENABLE_ED_FILESET_SIM       0
  ENABLE_ED_FILESET_SYNTHESIS 1
  GTS_CLK                     0
  PHY_STRUCTURE               0
  RX_AUDIO_CHANS              2
  RX_AUX_DEBUG                0
  RX_AUX_GPU                  1
  RX_AXIS_VIDEOIF_EN          0
  RX_EXPORT_MSA               1
  RX_FEC_ERRCNT_EN            1
  RX_FEC_ERRINJ_EN            0
  RX_HDCP_KEY_VERSION         0
  RX_I2C_SCL_KHZ              100
  RX_IEEE_OUI                 1
  RX_MAX_LANE_COUNT           2
  RX_MAX_LINK_RATE            30
  RX_MAX_NUM_OF_STREAMS       1
  RX_PIXELS_PER_CLOCK         2
  RX_PRBS_CHECKER             0
  RX_SCRAMBLER_SEED           65535
  RX_SUPPORT_AUDIO            0
  RX_SUPPORT_AUTOMATED_TEST   0
  RX_SUPPORT_DP               0
  RX_SUPPORT_FEC              0
  RX_SUPPORT_GTC              0
  RX_SUPPORT_HDCP1X           0
  RX_SUPPORT_HDCP2X           0
  RX_SUPPORT_HDCP_KEY_MANAGE  0
  RX_SUPPORT_I2CMASTER        0
  RX_SUPPORT_MST              0
  RX_SUPPORT_PR               0
  RX_SUPPORT_SS               0
  RX_SYMBOLS_PER_CLOCK        4
  RX_TOOLKIT                  0
  RX_VIDEO_BPS                8
  SELECT_CUSTOM_DEVICE        0
  SELECT_ED_FILESET           VERILOG
  SELECT_FMC_REV              8
  SELECT_SUPPORTED_VARIANT    5
  SELECT_TARGETED_BOARD       0
  TX_AUDIO_CHANS              2
  TX_AUX_DEBUG                0
  TX_AXIS_VIDEOIF_EN          1
  TX_HDCP_KEY_VERSION         0
  TX_MAX_LANE_COUNT           2
  TX_MAX_LINK_RATE            30
  TX_MAX_NUM_OF_STREAMS       1
  TX_PIXELS_PER_CLOCK         2
  TX_SCRAMBLER_SEED           65535
  TX_SUPPORT_ANALOG_RECONFIG  1
  TX_SUPPORT_AUDIO            0
  TX_SUPPORT_AUTOMATED_TEST   0
  TX_SUPPORT_DP               1
  TX_SUPPORT_FEC              0
  TX_SUPPORT_GTC              0
  TX_SUPPORT_HDCP1X           0
  TX_SUPPORT_HDCP2X           0
  TX_SUPPORT_HDCP_KEY_MANAGE  0
  TX_SUPPORT_MST              0
  TX_SUPPORT_SS               0
  TX_SYMBOLS_PER_CLOCK        4
  TX_TOOLKIT                  0
  TX_VIDEO_BPS                10
  TX_VIDEO_IM_ENABLE          0
}

::vh::sync

# -----------------------------------------------------------------------------
# Wiring
# -----------------------------------------------------------------------------

puts "dp_tx_subsystem: wiring cells together"
::vh::connect_pin {clk_16 out_clk} {rst_16 clk}
::vh::connect_pin {clk_16 out_clk} {dp_source aux_clk}
::vh::connect_pin {rst_16 out_reset} {dp_source aux_reset}

::vh::connect_pin {mgmt_clk out_clk} {mgmt_rst clk}
::vh::connect_pin {mgmt_clk out_clk} {dp_tx_mgmt_bridge clk}
::vh::connect_pin {mgmt_clk out_clk} {i2c_master clock}
::vh::connect_pin {mgmt_clk out_clk} {dp_core_i2c_board clock}
::vh::connect_pin {mgmt_clk out_clk} {dp_core_pio_board clk}
::vh::connect_pin {mgmt_clk out_clk} {pio_status clk}
::vh::connect_pin {mgmt_clk out_clk} {pio_supportd_fmats clk}
::vh::connect_pin {mgmt_clk out_clk} {pio_curr_format clk}
::vh::connect_pin {mgmt_clk out_clk} {pio_format_ovrride clk}
::vh::connect_pin {mgmt_clk out_clk} {dp_source clk}
::vh::connect_pin {mgmt_clk out_clk} {dp_source xcvr_mgmt_clk}

::vh::connect_pin {mgmt_rst out_reset} {dp_tx_mgmt_bridge reset}
::vh::connect_pin {mgmt_rst out_reset} {i2c_master reset_sink}
::vh::connect_pin {mgmt_rst out_reset} {dp_core_i2c_board reset_sink}
::vh::connect_pin {mgmt_rst out_reset} {dp_core_pio_board reset}
::vh::connect_pin {mgmt_rst out_reset} {pio_status reset}
::vh::connect_pin {mgmt_rst out_reset} {pio_supportd_fmats reset}
::vh::connect_pin {mgmt_rst out_reset} {pio_curr_format reset}
::vh::connect_pin {mgmt_rst out_reset} {pio_format_ovrride reset}
::vh::connect_pin {mgmt_rst out_reset} {dp_source reset}

::vh::connect_pin {vvp_clock_bridge out_clk} {vvp_reset_bridge clk}
::vh::connect_pin {vvp_clock_bridge out_clk} {dp_source tx_axi4s_clk}
::vh::connect_pin {vvp_clock_bridge out_clk} {dp_source tx_vid_clk}
::vh::connect_pin {vvp_reset_bridge out_reset} {dp_source tx_axi4s_reset}


::vh::connect_if {dp_tx_mgmt_bridge m0} {i2c_master csr}
::vh::connect_if {dp_tx_mgmt_bridge m0} {dp_core_i2c_board csr}
::vh::connect_if {dp_tx_mgmt_bridge m0} {dp_core_pio_board s1}
::vh::connect_if {dp_tx_mgmt_bridge m0} {pio_status s1}
::vh::connect_if {dp_tx_mgmt_bridge m0} {pio_supportd_fmats s1}
::vh::connect_if {dp_tx_mgmt_bridge m0} {pio_curr_format s1}
::vh::connect_if {dp_tx_mgmt_bridge m0} {pio_format_ovrride s1}
::vh::connect_if {dp_tx_mgmt_bridge m0} {dp_source tx_mgmt}

::vh::sync

# -----------------------------------------------------------------------------
# Assign base addresses
# -----------------------------------------------------------------------------

puts "dp_tx_subsystem: auto assigning base addresses"

vds::assign_base_address

::vh::sync

# -----------------------------------------------------------------------------
# Exports
# -----------------------------------------------------------------------------

puts "dp_tx_subsystem: exporting pins/interfaces"

# Clocks/resets
::vh::export_pin {clk_16           in_clk}        clk_16_in_clk
::vh::export_pin {rst_16           in_reset}      rst_16_in_rst
::vh::export_pin {mgmt_clk         in_clk}        mgmt_clk_in_clk
::vh::export_pin {mgmt_rst         in_reset}      mgmt_rst_in_rst
::vh::export_pin {vvp_clock_bridge in_clk}        vvp_clock_bridge_in_clk
::vh::export_pin {vvp_reset_bridge in_reset}      vvp_reset_bridge_in_reset
::vh::export_pin {dp_source        tx_im_dsc_clk} dp_source_tx_im_dsc_clk
::vh::export_pin {dp_source        dsc_sync_clk}  dp_source_dsc_sync_clk

# PIOs
::vh::export_pin {dp_core_pio_board  external_connection} dp_core_board_pio
::vh::export_pin {pio_status         external_connection} status_pio
::vh::export_pin {pio_supportd_fmats external_connection} supportd_fmats_pio
::vh::export_pin {pio_curr_format    external_connection} curr_format_pio
::vh::export_pin {pio_format_ovrride external_connection} format_ovrride_pio

# CSR/management
::vh::export_if {dp_tx_mgmt_bridge s0}                dp_source_tx_mgmt
::vh::export_if {i2c_master        interrupt_sender}  i2c_master_irq
::vh::export_if {dp_core_i2c_board interrupt_sender}  dp_core_i2c_board_irq
::vh::export_if {dp_source         tx_mgmt_interrupt} dp_source_tx_mgmt_interrupt

# Top-level pins
::vh::export_if {i2c_master        i2c_serial}         i2c_master_i2c_serial
::vh::export_if {dp_core_i2c_board i2c_serial}         dp_core_i2c_board_i2c_serial
::vh::export_if {dp_source         tx_xcvr_interface}  dp_source_tx_xcvr_interface
::vh::export_if {dp_source         tx_aux}             dp_source_tx_aux
::vh::export_if {dp_source         tx_analog_reconfig} dp_source_tx_analog_reconfig
::vh::export_if {dp_source         tx_reconfig}        dp_source_tx_reconfig

# Video input interface
::vh::export_if {dp_source tx_axi4s_vid_in} dp_source_tx_axi4s_vid_in

# DSC (unused)
::vh::export_if {dp_source dsc_mgmt}        dp_source_dsc_mgmt
::vh::export_if {dp_source tx_im_dsc}       dp_source_tx_im_dsc
::vh::export_if {dp_source dsc_passthrough} dp_source_dsc_passthrough
::vh::export_if {dp_source dsc_ctrl}        dp_source_dsc_ctrl
::vh::export_if {dp_source dsc_sync}        dp_source_dsc_sync
::vh::export_if {dp_source dsc_axi4s}       dp_source_dsc_axi4s
::vh::export_if {dp_source dsc_tx_tpg}      dp_source_dsc_tx_tpg

::vh::sync

puts "dp_tx_subsystem: build complete"
