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

set PORT BANK_2A

puts "emif_subsystem: creating system"
puts "emif_subsystem: subsystem parameters: PORT=$PORT"
::vh::new_system "emif_subsystem"

# ---------------------------------------------------------------------------
# Instances
# ---------------------------------------------------------------------------

puts "emif_subsystem: creating cells"
::vh::create_cell emif_cpu_clk_bridge altera_clock_bridge {
  EXPLICIT_CLOCK_RATE 100000000.0
  NUM_CLOCK_OUTPUTS   1
}

::vh::create_cell emif_cpu_rst_bridge altera_reset_bridge {
  ACTIVE_LOW_RESET  0
  NUM_RESET_OUTPUTS 1
  SYNCHRONOUS_EDGES deassert
  SYNC_RESET        0
  USE_RESET_REQUEST 0
}

::vh::create_cell emif_axi_clk_out_bridge altera_clock_bridge {
  NUM_CLOCK_OUTPUTS 1
}

::vh::create_cell emif_axi_ctrl_ready_out_bridge altera_reset_bridge {
  ACTIVE_LOW_RESET  0
  NUM_RESET_OUTPUTS 1
  SYNCHRONOUS_EDGES none
  SYNC_RESET        0
  USE_RESET_REQUEST 0
}

::vh::create_cell emif_rst_bridge altera_reset_bridge {
  ACTIVE_LOW_RESET  1
  NUM_RESET_OUTPUTS 1
  SYNCHRONOUS_EDGES none
  SYNC_RESET        0
  USE_RESET_REQUEST 0
}

::vh::create_cell emif_core_clk_rst_bridge altera_reset_bridge {
  ACTIVE_LOW_RESET  1
  NUM_RESET_OUTPUTS 1
  SYNCHRONOUS_EDGES deassert
  SYNC_RESET        0
  USE_RESET_REQUEST 0
}

::vh::create_cell emif_mm_bridge altera_avalon_mm_bridge {
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

::vh::create_cell pio_emif_cal altera_avalon_pio {
  bitClearingEdgeCapReg 0
  bitModifyingOutReg    0
  captureEdge           0
  direction             Input
  edgeType              RISING
  generateIRQ           0
  irqType               LEVEL
  resetValue            0.0
  simDoTestBenchWiring  0
  simDrivenValue        0.0
  width                 8
}

::vh::create_cell ddr4_emif emif_io96b_lpddr4 {
  PHY_TERM_X_R_T_DQ_INPUT_OHM         RT_50_OHM_CAL
  PHY_TERM_X_DQS_IO_STD_TYPE          DF_LVSTL
  PHY_TERM_X_R_S_CK_OUTPUT_OHM        SERIES_40_OHM_CAL
  PHY_TERM_X_REFCLK_IO_STD_TYPE       TRUE_DIFF
  PHY_REFCLK_FREQ_MHZ_AUTOSET_EN      false
  PHY_TERM_X_GPIO_IO_STD_TYPE         LVCMOS
  PHY_TERM_X_DQ_VREF                  17.5
  CTRL_PERFORMANCE_PROFILE            RAND
  PHY_TERM_X_DQ_SLEW_RATE             FASTEST
  PHY_TERM_X_DQ_IO_STD_TYPE           LVSTL
  CTRL_ECC_AUTOCORRECT_EN             false
  PHY_TERM_X_CK_OUTPUT_IO_STD_TYPE    DF_LVSTL
  PHY_TERM_X_R_S_CS_OUTPUT_OHM        SERIES_40_OHM_CAL
  PHY_TERM_X_R_T_REFCLK_INPUT_OHM     RT_DIFF
  PHY_REFCLK_FREQ_MHZ                 166.6667
  MEM_ODT_DQ_X_TGT_WR                 5
  PHY_REFCLK_ADVANCED_SELECT_EN       true
  MEM_VREF_DQ_X_VALUE                 18.0
  MEM_PER_BANK_REF_EN                 1
  PHY_MAINBAND_ACCESS_MODE_AUTOSET_EN false
  PHY_MAINBAND_ACCESS_MODE            SYNC
  MEM_TXSR_NS                         287.5
  PHY_SIDEBAND_ACCESS_MODE            FABRIC
  MEM_VREF_DQ_X_RANGE                 1
  MEM_WLS                             1.0
  MEM_TCKCKEL_NS                      5.0
  MEM_VREF_CA_X_CA_RANGE              2
  MEM_DIE_DENSITY_GBITS               8
  MEM_TSR_NS                          15.0
  MEM_TWTR_NS                         10.0
  MEM_TZQLAT_NS                       30.0
  MEM_TZQCAL_NS                       1000.0
  MEM_TRC_NS                          63.0
  MEM_TCCD_NS                         7.5
  MEM_TESCKE_NS                       2.8125
  MEM_TRPPB_NS                        18.0
  MEM_TCKELCMD_NS                     5.0
  MEM_TDQSCK_MIN_NS                   1.5
  MEM_TRFCAB_NS                       280.0
  EX_DESIGN_USER_PLL_OUTPUT_FREQ_MHZ  200.0
  MEM_CA_VREF                         13
  MEM_TRCD_NS                         18.0
  MEM_ODT_CA_X_CS_ENABLE              true
  MEM_TFAW_NS                         40.0
  MEM_TCSCKEH_NS                      1.75
  MEM_ODT_CA_X_CA_COMM                3
  PHY_TERM_X_CS_OUTPUT_IO_STD_TYPE    LVSTL
  ADV_CAL_ENABLE_REQ                  true
  MEM_ODT_CA_X_CA_ENABLE              true
  MEM_CWL_CYC                         18
  MEM_TREFW_NS                        3.2E7
  MEM_ODT_DQ_X_IDLE                   off
  ADV_CAL_ENABLE_WEQ                  true
  MEM_CL_CYC                          20
  PHY_TERM_X_R_T_GPIO_INPUT_OHM       RT_OFF
  MEM_OPERATING_FREQ_MHZ              1066.667
  MEM_TMRR_NS                         8.0
  MEM_TCKELCK_NS                      5.0
  MEM_TRAS_NS                         42.0
  PHY_TERM_X_R_S_DQ_OUTPUT_OHM        SERIES_40_OHM_CAL
  MEM_OPERATING_FREQ_MHZ_AUTOSET_EN   false
  CTRL_AUTO_PRECHARGE_EN              true
  MEM_TREFI_NS                        3906.0
  MEM_TRRD_NS                         10.0
  MEM_TCKCKEH_NS                      2.8125
  MEM_TRPAB_NS                        21.0
  PHY_TERM_X_R_S_AC_OUTPUT_OHM        SERIES_40_OHM_CAL
  MEM_VREF_CA_X_CA_VALUE               27.2
  MEM_CHANNEL_DATA_DQ_WIDTH           32
  MEM_ODT_DQ_X_RON                    6
  MEM_TCSCKE_NS                       1.75
  PHY_TERM_X_AC_OUTPUT_IO_STD_TYPE    LVSTL
  MEM_TRTP_NS                         7.5
  MEM_TCKEHCMD_NS                     7.5
  MEM_NUM_CHANNELS                    1
  MEM_MINNUMREFSREQ                   8192.0
  MEM_TDQSCK_MAX_NS                   3.5
  MEM_ODT_CA_X_CK_ENABLE              true
  MEM_DQ_VREF                         20
  MEM_TCMDCKE_NS                      2.8125
  MEM_TMRD_NS                         14.0
  MEM_TMRWCKEL_NS                     14.0
  MEM_TMRW_NS                         10.0
  MEM_TPPD_CYC                        4.0
  MEM_TWR_NS                          18.0
  MEM_TRFCPB_NS                       140.0
  MEM_TCKE_NS                         7.5
  MEM_TXP_NS                          7.5
  MEM_TZQCKE_NS                       2.8125
}

::vh::set_param ddr4_emif JEDEC_OVERRIDE_TABLE_PARAM_NAME {{MEM_TREFI_NS} {MEM_TMRR_NS}}

# pin/byte swizzle map (board-specific PCB routing)
set swizzle_map "BYTE_SWIZZLE_CH0=1,0,X,X,X,X,2,3; \
               PIN_SWIZZLE_CH0_DQS0=0,1,3,2,6,7,4,5; \
               PIN_SWIZZLE_CH0_DQS1=15,14,13,12,9,11,8,10; \
               PIN_SWIZZLE_CH0_DQS2=19,20,21,18,17,16,23,22; \
               PIN_SWIZZLE_CH0_DQS3=25,30,24,31,27,26,28,29;"
::vh::set_param ddr4_emif PHY_SWIZZLE_MAP $swizzle_map

::vh::create_cell ddr4_cal emif_ph2_axil_driver {
  AXIL_DRIVER_ADDRESS_WIDTH 32
}

::vh::sync

# ---------------------------------------------------------------------------
# Wiring
# ---------------------------------------------------------------------------

puts "emif_subsystem: wiring up cells"

::vh::connect_pin {emif_cpu_clk_bridge out_clk} {emif_cpu_rst_bridge clk}
::vh::connect_pin {emif_cpu_clk_bridge out_clk} {emif_mm_bridge clk}
::vh::connect_pin {emif_cpu_clk_bridge out_clk} {pio_emif_cal clk}
::vh::connect_pin {emif_cpu_clk_bridge out_clk} {ddr4_emif s0_axi4lite_clock}
::vh::connect_pin {emif_cpu_clk_bridge out_clk} {ddr4_cal axil_driver_clk}

::vh::connect_pin {emif_cpu_rst_bridge out_reset} {emif_mm_bridge reset}
::vh::connect_pin {emif_cpu_rst_bridge out_reset} {pio_emif_cal reset}

::vh::connect_pin {ddr4_emif s0_axi4_clock_out} {emif_axi_clk_out_bridge in_clk}
::vh::connect_pin {ddr4_emif s0_axi4_clock_out} {emif_core_clk_rst_bridge clk}

::vh::connect_pin {ddr4_emif s0_axi4_ctrl_ready} {emif_axi_ctrl_ready_out_bridge in_reset}

::vh::connect_pin {emif_rst_bridge out_reset} {emif_core_clk_rst_bridge in_reset}
::vh::connect_pin {emif_rst_bridge out_reset} {ddr4_emif s0_axi4lite_reset_n}
::vh::connect_pin {emif_rst_bridge out_reset} {ddr4_cal axil_driver_rst_n}

::vh::connect_pin {emif_core_clk_rst_bridge out_reset} {ddr4_emif core_init_n}


# ---------------------------------------------------------------------------
# Assign base addresses
# ---------------------------------------------------------------------------

puts "emif_subsystem: assigning base addresses"

vds::assign_base_address

::vh::sync

# ---------------------------------------------------------------------------
# Set domain properties
# ---------------------------------------------------------------------------

puts "emif_subsystem: setting domain properties"

::vh::set_domain_property {ddr4_emif s0_axi4} \
  "qsys_mm.responseFifoType" \
  EMBEDDED_MEMORY_BASED

::vh::sync


# ---------------------------------------------------------------------------
# Exports
# ---------------------------------------------------------------------------

puts "emif_subsystem: exporting interfaces"

::vh::export_pin {emif_cpu_clk_bridge in_clk} cpu_clk_in
::vh::export_pin {emif_cpu_rst_bridge in_reset} cpu_rst_in
::vh::export_pin {emif_axi_clk_out_bridge out_clk} emif_clk_out
::vh::export_pin {emif_axi_ctrl_ready_out_bridge out_reset} emif_ready_out
::vh::export_pin {emif_rst_bridge in_reset} emif_rst_brdg_in
::vh::export_pin {pio_emif_cal external_connection} emif_cal_pio
::vh::export_pin {ddr4_emif mem_reset_n} c_ddr4_emif_resetn
::vh::export_pin {ddr4_emif oct_0} c_ddr4_emif_oct
::vh::export_pin {ddr4_emif ref_clk} i_clk_ddr4_emif_pll_ref
::vh::export_pin {ddr4_cal cal_done_rst_n} emif_cal_done_rst_n

::vh::connect_if {emif_mm_bridge m0} {pio_emif_cal s1}
::vh::connect_if {ddr4_cal axil_driver_axi4_lite} {ddr4_emif s0_axi4lite}

::vh::export_if {emif_mm_bridge s0} mm_ctrl_in
::vh::export_if {ddr4_emif s0_axi4} i_emif_s0_axi4
::vh::export_if {ddr4_emif mem_ck_0} c_ddr4_emif_ck0
::vh::export_if {ddr4_emif mem_0} c_ddr4_emif_mem

::vh::sync


puts "emif_subsystem: build complete"
