# Project setup with top.qsf 
set prj_top [file join .. .. top.qsf]
project_open $prj_top

post_message [pwd]
puts [pwd]

# Project setup with qsys system
set prj_vds [file join src vds top_subsystem top_subsystem.vds]

post_message [pwd]
puts [pwd]

load_package vds
# project_new top
# 
# Info: Current script was exported with Quartus Prime Pro Release 26.1.1 Build 130
# 
regexp {[\.0-9]+} $quartus(version) import_release
if {$import_release != "26.1.1"} {
	post_message -type error "Cannot import script exported from Quartus Prime Pro version \"26.1.1 Build 130\" into current release \"$import_release\".\n\tOpen, upgrade, and validate the original system in VDS to ensure design correctness."
	return
}
proc get_current_hier {} {
set current_hier [vds::get_current_hier]
if {$current_hier == "|"} {
	set current_hier ""
}
return $current_hier
}

proc create_board_subsystem {} {
vds::create_system board_subsystem
vds::create_cell -properties { parameters:EXPLICIT_CLOCK_RATE {100000000} parameters:NUM_CLOCK_OUTPUTS {2}  } -vlnv altera.com:ip:altera_clock_bridge:19.2.0 board_clk_bridge
vds::create_cell -properties { parameters:outputType {Reset Interface}  } -vlnv altera.com:ip:intel_user_rst_clkgate:1.0.1 board_init_generator
vds::create_cell -properties { parameters:NUM_RESET_OUTPUTS {3}  } -vlnv altera.com:ip:altera_reset_bridge:19.2.0 board_init_reset_bridge
vds::create_cell -properties { parameters:CNTR_WIDTH {23}  } -vlnv :ip:intel_vip_reset_gen_block:99.0 board_pb_reset_generator
vds::create_cell -properties { parameters:NUM_RESET_INPUTS {2}  } -vlnv altera.com:ip:altera_reset_controller:19.2.4 board_reset_controller
vds::export_pin board_clk_bridge|out_clk o_clk
vds::connect_net -src board_clk_bridge|out_clk_1 -dest board_pb_reset_generator|clk
vds::connect_net -src board_clk_bridge|out_clk_1 -dest board_init_reset_bridge|clk
vds::connect_net -src board_clk_bridge|out_clk_1 -dest board_reset_controller|clk
vds::connect_net -src board_init_generator|ninit_done -dest board_init_reset_bridge|in_reset
vds::connect_net -src board_init_reset_bridge|out_reset -dest board_reset_controller|reset_in1
vds::export_pin board_init_reset_bridge|out_reset_1 o_rst_device_ready_export
vds::export_pin board_init_reset_bridge|out_reset_2 o_rst_device_ready
vds::connect_net -src board_pb_reset_generator|reset -dest board_reset_controller|reset_in0
vds::export_pin board_reset_controller|reset_out o_reset
vds::export_pin board_clk_bridge|in_clk i_clk
vds::export_pin board_pb_reset_generator|pb_resetn ia_reset_pb_n
vds::validate_system
vds::save_system board_subsystem
vds::close_system board_subsystem
}
proc create_clock_subsystem {} {
vds::create_system clock_subsystem
vds::create_cell -properties { parameters:EXPLICIT_CLOCK_RATE {148500000}  } -vlnv altera.com:ip:altera_clock_bridge:19.2.0 gen_clk_0_clk_export_bridge
vds::create_cell -properties { parameters:INPUT_CLOCK_FREQUENCY {148500000}  } -vlnv :ip:intel_vip_reset_sync_block:99.0 gen_clk_0_reset_sync
vds::create_cell -vlnv altera.com:ip:altera_reset_bridge:19.2.0 gen_clk_0_rst_export_bridge
vds::create_cell -properties { parameters:EXPLICIT_CLOCK_RATE {297000000}  } -vlnv altera.com:ip:altera_clock_bridge:19.2.0 gen_clk_1_clk_export_bridge
vds::create_cell -properties { parameters:INPUT_CLOCK_FREQUENCY {297000000}  } -vlnv :ip:intel_vip_reset_sync_block:99.0 gen_clk_1_reset_sync
vds::create_cell -vlnv altera.com:ip:altera_reset_bridge:19.2.0 gen_clk_1_rst_export_bridge
vds::create_cell -properties { parameters:EXPLICIT_CLOCK_RATE {16000000}  } -vlnv altera.com:ip:altera_clock_bridge:19.2.0 gen_clk_2_clk_export_bridge
vds::create_cell -properties { parameters:INPUT_CLOCK_FREQUENCY {16000000}  } -vlnv :ip:intel_vip_reset_sync_block:99.0 gen_clk_2_reset_sync
vds::create_cell -vlnv altera.com:ip:altera_reset_bridge:19.2.0 gen_clk_2_rst_export_bridge
vds::create_cell -properties { parameters:EXPLICIT_CLOCK_RATE {100000000}  } -vlnv altera.com:ip:altera_clock_bridge:19.2.0 input_clk_bridge
vds::create_cell -properties { parameters:SYNCHRONOUS_EDGES {none}  } -vlnv altera.com:ip:altera_reset_bridge:19.2.0 input_rst_0_bridge
vds::create_cell -properties { parameters:NUM_RESET_INPUTS {1}  } -vlnv altera.com:ip:altera_reset_controller:19.2.4 input_rst_ctrl
vds::create_cell -properties { parameters:gui_clock_name_string0 {clk_0} parameters:gui_clock_name_string1 {clk_1} parameters:gui_clock_name_string2 {clk_2} parameters:gui_number_of_clocks {3} parameters:gui_output_clock_frequency0 {148.5} parameters:gui_output_clock_frequency1 {297.0} parameters:gui_output_clock_frequency2 {16.0} parameters:gui_pll_bandwidth_preset {Medium}  } -vlnv altera.com:ip:altera_iopll:21.1.0 iopll_0
vds::create_cell -vlnv :ip:intel_iopll_locked_shim:99.0 iopll_locked_shim_0
vds::create_cell -properties { parameters:EXPLICIT_CLOCK_RATE {100000000} parameters:NUM_CLOCK_OUTPUTS {2}  } -vlnv altera.com:ip:altera_clock_bridge:19.2.0 ref_clk_export_bridge
vds::create_cell -properties { parameters:INPUT_CLOCK_FREQUENCY {100000000}  } -vlnv :ip:intel_vip_reset_sync_block:99.0 ref_clk_reset_sync
vds::create_cell -properties { parameters:NUM_RESET_OUTPUTS {2}  } -vlnv altera.com:ip:altera_reset_bridge:19.2.0 ref_rst_export_bridge
vds::create_cell -properties { parameters:RESET_MIN_LENGTH {3000}  } -vlnv :ip:intel_vvp_reset_extend:99.0 reset_extender
vds::create_cell -properties { parameters:NUM_RESET_INPUTS {2}  } -vlnv altera.com:ip:altera_reset_controller:19.2.4 reset_sync
vds::export_pin gen_clk_0_clk_export_bridge|out_clk o_gen_clk_0_clk
vds::connect_net -src gen_clk_0_reset_sync|clock_out -dest gen_clk_0_rst_export_bridge|clk
vds::connect_net -src gen_clk_0_reset_sync|clock_out -dest gen_clk_0_clk_export_bridge|in_clk
vds::connect_net -src gen_clk_0_reset_sync|reset_out -dest gen_clk_0_rst_export_bridge|in_reset
vds::export_pin gen_clk_0_rst_export_bridge|out_reset o_gen_clk_0_rst
vds::export_pin gen_clk_1_clk_export_bridge|out_clk o_gen_clk_1_clk
vds::connect_net -src gen_clk_1_reset_sync|clock_out -dest gen_clk_1_rst_export_bridge|clk
vds::connect_net -src gen_clk_1_reset_sync|clock_out -dest gen_clk_1_clk_export_bridge|in_clk
vds::connect_net -src gen_clk_1_reset_sync|reset_out -dest gen_clk_1_rst_export_bridge|in_reset
vds::export_pin gen_clk_1_rst_export_bridge|out_reset o_gen_clk_1_rst
vds::export_pin gen_clk_2_clk_export_bridge|out_clk o_gen_clk_2_clk
vds::connect_net -src gen_clk_2_reset_sync|clock_out -dest gen_clk_2_rst_export_bridge|clk
vds::connect_net -src gen_clk_2_reset_sync|clock_out -dest gen_clk_2_clk_export_bridge|in_clk
vds::connect_net -src gen_clk_2_reset_sync|reset_out -dest gen_clk_2_rst_export_bridge|in_reset
vds::export_pin gen_clk_2_rst_export_bridge|out_reset o_gen_clk_2_rst
vds::export_pin input_clk_bridge|in_clk i_ref_clk
vds::export_pin input_rst_0_bridge|in_reset i_ref_rst
vds::connect_net -src input_clk_bridge|out_clk -dest input_rst_ctrl|clk
vds::connect_net -src input_clk_bridge|out_clk -dest reset_extender|clk
vds::connect_net -src input_clk_bridge|out_clk -dest reset_sync|clk
vds::connect_net -src input_clk_bridge|out_clk -dest ref_clk_reset_sync|clock_in
vds::connect_net -src input_clk_bridge|out_clk -dest iopll_0|refclk
vds::connect_net -src input_rst_0_bridge|out_reset -dest input_rst_ctrl|reset_in0
vds::connect_net -src input_rst_ctrl|reset_out -dest iopll_0|reset
vds::connect_net -src input_rst_ctrl|reset_out -dest reset_sync|reset_in0
vds::connect_net -src iopll_0|locked -dest iopll_locked_shim_0|locked_in
vds::connect_net -src iopll_0|outclk0 -dest gen_clk_0_reset_sync|clock_in
vds::connect_net -src iopll_0|outclk1 -dest gen_clk_1_reset_sync|clock_in
vds::connect_net -src iopll_0|outclk2 -dest gen_clk_2_reset_sync|clock_in
vds::export_pin iopll_locked_shim_0|locked_out o_iopll_0_locked
vds::export_pin iopll_locked_shim_0|locked_out_1 o_iopll_0_locked_export
vds::connect_net -src iopll_locked_shim_0|reset -dest reset_sync|reset_in1
vds::export_pin ref_clk_export_bridge|out_clk o_ref_clk
vds::export_pin ref_clk_export_bridge|out_clk_1 o_ref_clk_export
vds::connect_net -src ref_clk_reset_sync|clock_out -dest ref_rst_export_bridge|clk
vds::connect_net -src ref_clk_reset_sync|clock_out -dest ref_clk_export_bridge|in_clk
vds::connect_net -src ref_clk_reset_sync|reset_out -dest ref_rst_export_bridge|in_reset
vds::export_pin ref_rst_export_bridge|out_reset o_ref_rst
vds::export_pin ref_rst_export_bridge|out_reset_1 o_ref_rst_export
vds::connect_net -src reset_extender|out_reset -dest ref_clk_reset_sync|reset_in
vds::connect_net -src reset_extender|out_reset -dest gen_clk_0_reset_sync|reset_in
vds::connect_net -src reset_extender|out_reset -dest gen_clk_1_reset_sync|reset_in
vds::connect_net -src reset_extender|out_reset -dest gen_clk_2_reset_sync|reset_in
vds::connect_net -src reset_sync|reset_out -dest reset_extender|in_reset
vds::validate_system
vds::save_system clock_subsystem
vds::close_system clock_subsystem
}
proc create_dp_tx_subsystem {} {
vds::create_system dp_tx_subsystem
vds::create_cell -properties { parameters:EXPLICIT_CLOCK_RATE {16000000}  } -vlnv altera.com:ip:altera_clock_bridge:19.2.0 clk_16
vds::create_cell -properties { parameters:FIFO_DEPTH {32}  } -vlnv altera.com:ip:altera_avalon_i2c:19.2.6 dp_core_i2c_board
vds::create_cell -properties { parameters:width {32}  } -vlnv altera.com:ip:altera_avalon_pio:19.2.4 dp_core_pio_board
vds::create_cell -properties { parameters:RX_MAX_LANE_COUNT {2} parameters:RX_PIXELS_PER_CLOCK {2} parameters:RX_SUPPORT_DP {0} parameters:SELECT_SUPPORTED_VARIANT {5} parameters:TX_AXIS_VIDEOIF_EN {1} parameters:TX_MAX_LANE_COUNT {2} parameters:TX_PIXELS_PER_CLOCK {2} parameters:TX_VIDEO_BPS {10}  } -vlnv altera.com:ip:altera_dp:20.4.0 dp_source
vds::create_cell -properties { parameters:USE_AUTO_ADDRESS_WIDTH {1}  } -vlnv altera.com:ip:altera_avalon_mm_bridge:20.1.0 dp_tx_mgmt_bridge
vds::create_cell -properties { parameters:FIFO_DEPTH {32}  } -vlnv altera.com:ip:altera_avalon_i2c:19.2.6 i2c_master
vds::create_cell -properties { parameters:EXPLICIT_CLOCK_RATE {100000000}  } -vlnv altera.com:ip:altera_clock_bridge:19.2.0 mgmt_clk
vds::create_cell -vlnv altera.com:ip:altera_reset_bridge:19.2.0 mgmt_rst
vds::create_cell -properties { parameters:width {32}  } -vlnv altera.com:ip:altera_avalon_pio:19.2.4 pio_curr_format
vds::create_cell -properties { parameters:direction {Input} parameters:width {32}  } -vlnv altera.com:ip:altera_avalon_pio:19.2.4 pio_format_ovrride
vds::create_cell -properties { parameters:width {32}  } -vlnv altera.com:ip:altera_avalon_pio:19.2.4 pio_status
vds::create_cell -properties { parameters:width {32}  } -vlnv altera.com:ip:altera_avalon_pio:19.2.4 pio_supportd_fmats
vds::create_cell -vlnv altera.com:ip:altera_reset_bridge:19.2.0 rst_16
vds::create_cell -properties { parameters:EXPLICIT_CLOCK_RATE {148500000}  } -vlnv altera.com:ip:altera_clock_bridge:19.2.0 vvp_clock_bridge
vds::create_cell -vlnv altera.com:ip:altera_reset_bridge:19.2.0 vvp_reset_bridge
vds::connect_interface_net -dest dp_core_i2c_board|csr -src dp_tx_mgmt_bridge|m0
vds::assign_base_address -connection dp_tx_mgmt_bridge.m0/dp_core_i2c_board.csr 0x2000
vds::connect_interface_net -dest dp_core_pio_board|s1 -src dp_tx_mgmt_bridge|m0
vds::assign_base_address -connection dp_tx_mgmt_bridge.m0/dp_core_pio_board.s1 0x20c0
vds::connect_interface_net -dest dp_source|tx_mgmt -src dp_tx_mgmt_bridge|m0
vds::assign_base_address -connection dp_tx_mgmt_bridge.m0/dp_source.tx_mgmt 0x0000
vds::connect_interface_net -dest i2c_master|csr -src dp_tx_mgmt_bridge|m0
vds::assign_base_address -connection dp_tx_mgmt_bridge.m0/i2c_master.csr 0x2040
vds::connect_interface_net -dest pio_status|s1 -src dp_tx_mgmt_bridge|m0
vds::assign_base_address -connection dp_tx_mgmt_bridge.m0/pio_status.s1 0x20b0
vds::connect_interface_net -dest pio_supportd_fmats|s1 -src dp_tx_mgmt_bridge|m0
vds::assign_base_address -connection dp_tx_mgmt_bridge.m0/pio_supportd_fmats.s1 0x20a0
vds::connect_interface_net -dest pio_curr_format|s1 -src dp_tx_mgmt_bridge|m0
vds::assign_base_address -connection dp_tx_mgmt_bridge.m0/pio_curr_format.s1 0x2090
vds::connect_interface_net -dest pio_format_ovrride|s1 -src dp_tx_mgmt_bridge|m0
vds::assign_base_address -connection dp_tx_mgmt_bridge.m0/pio_format_ovrride.s1 0x2080
vds::export_interface_pin i2c_master|i2c_serial i2c_master_i2c_serial
vds::export_interface_pin i2c_master|interrupt_sender i2c_master_irq
vds::export_interface_pin dp_tx_mgmt_bridge|s0 dp_source_tx_mgmt
vds::export_interface_pin dp_source|tx_axi4s_vid_in dp_source_tx_axi4s_vid_in
vds::export_interface_pin dp_source|dsc_tx_tpg dp_source_dsc_tx_tpg
vds::export_interface_pin dp_source|dsc_axi4s dp_source_dsc_axi4s
vds::export_interface_pin dp_source|dsc_sync dp_source_dsc_sync
vds::export_interface_pin dp_source|dsc_ctrl dp_source_dsc_ctrl
vds::export_interface_pin dp_source|tx_im_dsc dp_source_tx_im_dsc
vds::export_interface_pin dp_source|dsc_passthrough dp_source_dsc_passthrough
vds::export_interface_pin dp_source|dsc_mgmt dp_source_dsc_mgmt
vds::export_interface_pin dp_source|tx_mgmt_interrupt dp_source_tx_mgmt_interrupt
vds::export_interface_pin dp_source|tx_reconfig dp_source_tx_reconfig
vds::export_interface_pin dp_source|tx_analog_reconfig dp_source_tx_analog_reconfig
vds::export_interface_pin dp_source|tx_aux dp_source_tx_aux
vds::export_interface_pin dp_source|tx_xcvr_interface dp_source_tx_xcvr_interface
vds::export_interface_pin dp_core_i2c_board|i2c_serial dp_core_i2c_board_i2c_serial
vds::export_interface_pin dp_core_i2c_board|interrupt_sender dp_core_i2c_board_irq
vds::connect_net -src clk_16|out_clk -dest dp_source|aux_clk
vds::connect_net -src clk_16|out_clk -dest rst_16|clk
vds::export_pin clk_16|in_clk clk_16_in_clk
vds::export_pin dp_core_pio_board|external_connection dp_core_board_pio
vds::export_pin dp_source|dsc_sync_clk dp_source_dsc_sync_clk
vds::export_pin dp_source|tx_im_dsc_clk dp_source_tx_im_dsc_clk
vds::export_pin pio_format_ovrride|external_connection format_ovrride_pio
vds::connect_net -src mgmt_clk|out_clk -dest mgmt_rst|clk
vds::connect_net -src mgmt_clk|out_clk -dest dp_tx_mgmt_bridge|clk
vds::connect_net -src mgmt_clk|out_clk -dest dp_core_pio_board|clk
vds::connect_net -src mgmt_clk|out_clk -dest pio_status|clk
vds::connect_net -src mgmt_clk|out_clk -dest pio_supportd_fmats|clk
vds::connect_net -src mgmt_clk|out_clk -dest pio_curr_format|clk
vds::connect_net -src mgmt_clk|out_clk -dest pio_format_ovrride|clk
vds::connect_net -src mgmt_clk|out_clk -dest dp_source|clk
vds::connect_net -src mgmt_clk|out_clk -dest i2c_master|clock
vds::connect_net -src mgmt_clk|out_clk -dest dp_core_i2c_board|clock
vds::connect_net -src mgmt_clk|out_clk -dest dp_source|xcvr_mgmt_clk
vds::export_pin mgmt_clk|in_clk mgmt_clk_in_clk
vds::connect_net -src mgmt_rst|out_reset -dest dp_tx_mgmt_bridge|reset
vds::connect_net -src mgmt_rst|out_reset -dest dp_core_pio_board|reset
vds::connect_net -src mgmt_rst|out_reset -dest pio_status|reset
vds::connect_net -src mgmt_rst|out_reset -dest pio_supportd_fmats|reset
vds::connect_net -src mgmt_rst|out_reset -dest pio_curr_format|reset
vds::connect_net -src mgmt_rst|out_reset -dest pio_format_ovrride|reset
vds::connect_net -src mgmt_rst|out_reset -dest dp_source|reset
vds::connect_net -src mgmt_rst|out_reset -dest i2c_master|reset_sink
vds::connect_net -src mgmt_rst|out_reset -dest dp_core_i2c_board|reset_sink
vds::export_pin mgmt_rst|in_reset mgmt_rst_in_rst
vds::export_pin pio_curr_format|external_connection curr_format_pio
vds::export_pin pio_status|external_connection status_pio
vds::export_pin pio_supportd_fmats|external_connection supportd_fmats_pio
vds::connect_net -src rst_16|out_reset -dest dp_source|aux_reset
vds::export_pin rst_16|in_reset rst_16_in_rst
vds::connect_net -src vvp_clock_bridge|out_clk -dest vvp_reset_bridge|clk
vds::connect_net -src vvp_clock_bridge|out_clk -dest dp_source|tx_axi4s_clk
vds::connect_net -src vvp_clock_bridge|out_clk -dest dp_source|tx_vid_clk
vds::export_pin vvp_clock_bridge|in_clk vvp_clock_bridge_in_clk
vds::connect_net -src vvp_reset_bridge|out_reset -dest dp_source|tx_axi4s_reset
vds::export_pin vvp_reset_bridge|in_reset vvp_reset_bridge_in_reset
vds::set_domain_properties {qsys_mm.burstAdapterImplementation GENERIC_CONVERTER qsys_mm.clockCrossingAdapter AUTO qsys_mm.enableAllPipelines FALSE qsys_mm.enableEccProtection FALSE qsys_mm.enableInstrumentation FALSE qsys_mm.enableOutOfOrderSupport FALSE qsys_mm.fifoDepth 8 qsys_mm.insertDefaultSlave FALSE qsys_mm.interconnectResetSource DEFAULT qsys_mm.maxAdditionalLatency 1 qsys_mm.optimizeRdFifoSize FALSE qsys_mm.piplineType PIPELINE_STAGE qsys_mm.responseFifoType REGISTER_BASED qsys_mm.splitCommandsFor4KBoundary FALSE qsys_mm.syncResets TRUE qsys_mm.widthAdapterImplementation GENERIC_CONVERTER } dp_tx_mgmt_bridge.m0
vds::validate_system
vds::save_system dp_tx_subsystem
vds::close_system dp_tx_subsystem
}
proc create_emif_subsystem {} {
vds::create_system emif_subsystem
vds::create_cell -vlnv :ip:emif_ph2_axil_driver:1.0.0 ddr4_cal
vds::create_cell -properties { parameters:ADV_CAL_ENABLE_REQ {true} parameters:ADV_CAL_ENABLE_WEQ {true} parameters:CTRL_AUTO_PRECHARGE_EN {true} parameters:CTRL_ECC_AUTOCORRECT_EN {false} parameters:CTRL_ECC_WRITEBACK_EN {false} parameters:CTRL_PERFORMANCE_PROFILE {RAND} parameters:EX_DESIGN_USER_PLL_OUTPUT_FREQ_MHZ {150.0} parameters:JEDEC_OVERRIDE_TABLE_PARAM_NAME {{MEM_TREFI_NS} {MEM_TMRR_NS}} parameters:MEM_CA_VREF {13} parameters:MEM_CHANNEL_DATA_DQ_WIDTH {32} parameters:MEM_CL_CYC {20} parameters:MEM_CWL_CYC {18} parameters:MEM_DIE_DENSITY_GBITS {8} parameters:MEM_DQ_VREF {20} parameters:MEM_MINNUMREFSREQ {8192.0} parameters:MEM_NUM_CHANNELS {1} parameters:MEM_ODT_CA_X_CA_COMM {3} parameters:MEM_ODT_CA_X_CA_ENABLE {true} parameters:MEM_ODT_CA_X_CK_ENABLE {true} parameters:MEM_ODT_CA_X_CS_ENABLE {true} parameters:MEM_ODT_DQ_X_IDLE {off} parameters:MEM_ODT_DQ_X_RON {6} parameters:MEM_ODT_DQ_X_TGT_WR {5} parameters:MEM_OPERATING_FREQ_MHZ {1066.667} parameters:MEM_OPERATING_FREQ_MHZ_AUTOSET_EN {false} parameters:MEM_PER_BANK_REF_EN {1} parameters:MEM_TCCD_NS {7.5} parameters:MEM_TCKCKEH_NS {2.8125} parameters:MEM_TCKCKEL_NS {5.0} parameters:MEM_TCKEHCMD_NS {7.5} parameters:MEM_TCKELCK_NS {5.0} parameters:MEM_TCKELCMD_NS {5.0} parameters:MEM_TCKE_NS {7.5} parameters:MEM_TCMDCKE_NS {2.8125} parameters:MEM_TCSCKEH_NS {1.75} parameters:MEM_TCSCKE_NS {1.75} parameters:MEM_TDQSCK_MAX_NS {3.5} parameters:MEM_TDQSCK_MIN_NS {1.5} parameters:MEM_TESCKE_NS {2.8125} parameters:MEM_TFAW_NS {40.0} parameters:MEM_TMRD_NS {14.0} parameters:MEM_TMRR_NS {8.0} parameters:MEM_TMRWCKEL_NS {14.0} parameters:MEM_TMRW_NS {10.0} parameters:MEM_TPPD_CYC {4.0} parameters:MEM_TRAS_NS {42.0} parameters:MEM_TRCD_NS {18.0} parameters:MEM_TRC_NS {63.0} parameters:MEM_TREFI_NS {3906.0} parameters:MEM_TREFW_NS {3.2E7} parameters:MEM_TRFCAB_NS {280.0} parameters:MEM_TRFCPB_NS {140.0} parameters:MEM_TRPAB_NS {21.0} parameters:MEM_TRPPB_NS {18.0} parameters:MEM_TRRD_NS {10.0} parameters:MEM_TRTP_NS {7.5} parameters:MEM_TSR_NS {15.0} parameters:MEM_TWR_NS {18.0} parameters:MEM_TWTR_NS {10.0} parameters:MEM_TXP_NS {7.5} parameters:MEM_TXSR_NS {287.5} parameters:MEM_TZQCAL_NS {1000.0} parameters:MEM_TZQCKE_NS {2.8125} parameters:MEM_TZQLAT_NS {30.0} parameters:MEM_VREF_CA_X_CA_VALUE {27.2} parameters:MEM_VREF_DQ_X_VALUE {18.0} parameters:MEM_WLS {1.0} parameters:PHY_AC_TX_EQUALIZATION {OFF} parameters:PHY_CK_TX_EQUALIZATION {OFF} parameters:PHY_CS_TX_EQUALIZATION {OFF} parameters:PHY_DQ_TX_EQUALIZATION {OFF} parameters:PHY_MAINBAND_ACCESS_MODE {SYNC} parameters:PHY_MAINBAND_ACCESS_MODE_AUTOSET_EN {false} parameters:PHY_REFCLK_ADVANCED_SELECT_EN {true} parameters:PHY_REFCLK_FREQ_MHZ {166.6667} parameters:PHY_REFCLK_FREQ_MHZ_AUTOSET_EN {false} parameters:PHY_SIDEBAND_ACCESS_MODE {FABRIC} parameters:PHY_SWIZZLE_MAP {BYTE_SWIZZLE_CH0=1,0,X,X,X,X,2,3;  PIN_SWIZZLE_CH0_DQS0=0,1,3,2,6,7,4,5;  PIN_SWIZZLE_CH0_DQS1=15,14,13,12,9,11,8,10;  PIN_SWIZZLE_CH0_DQS2=19,20,21,18,17,16,23,22;  PIN_SWIZZLE_CH0_DQS3=25,30,24,31,27,26,28,29;} parameters:PHY_TERM_X_AC_OUTPUT_IO_STD_TYPE {LVSTL} parameters:PHY_TERM_X_AC_SLEW_RATE {FASTEST} parameters:PHY_TERM_X_CK_OUTPUT_IO_STD_TYPE {DF_LVSTL} parameters:PHY_TERM_X_CK_SLEW_RATE {FASTEST} parameters:PHY_TERM_X_CS_OUTPUT_IO_STD_TYPE {LVSTL} parameters:PHY_TERM_X_CS_SLEW_RATE {FASTEST} parameters:PHY_TERM_X_DQS_IO_STD_TYPE {DF_LVSTL} parameters:PHY_TERM_X_DQ_IO_STD_TYPE {LVSTL} parameters:PHY_TERM_X_DQ_SLEW_RATE {FASTEST} parameters:PHY_TERM_X_DQ_VREF {17.5} parameters:PHY_TERM_X_GPIO_IO_STD_TYPE {LVCMOS} parameters:PHY_TERM_X_REFCLK_IO_STD_TYPE {TRUE_DIFF} parameters:PHY_TERM_X_R_S_AC_OUTPUT_OHM {SERIES_40_OHM_CAL} parameters:PHY_TERM_X_R_S_CK_OUTPUT_OHM {SERIES_40_OHM_CAL} parameters:PHY_TERM_X_R_S_CS_OUTPUT_OHM {SERIES_40_OHM_CAL} parameters:PHY_TERM_X_R_S_DQ_OUTPUT_OHM {SERIES_40_OHM_CAL} parameters:PHY_TERM_X_R_T_DQ_INPUT_OHM {RT_50_OHM_CAL} parameters:PHY_TERM_X_R_T_GPIO_INPUT_OHM {RT_OFF} parameters:PHY_TERM_X_R_T_REFCLK_INPUT_OHM {RT_DIFF}  } -vlnv altera.com:ip:emif_io96b_lpddr4:5.0.0 ddr4_emif
vds::create_cell -vlnv altera.com:ip:altera_clock_bridge:19.2.0 emif_axi_clk_out_bridge
vds::create_cell -properties { parameters:SYNCHRONOUS_EDGES {none}  } -vlnv altera.com:ip:altera_reset_bridge:19.2.0 emif_axi_ctrl_ready_out_bridge
vds::create_cell -properties { parameters:ACTIVE_LOW_RESET {1}  } -vlnv altera.com:ip:altera_reset_bridge:19.2.0 emif_core_clk_rst_bridge
vds::create_cell -properties { parameters:EXPLICIT_CLOCK_RATE {100000000}  } -vlnv altera.com:ip:altera_clock_bridge:19.2.0 emif_cpu_clk_bridge
vds::create_cell -vlnv altera.com:ip:altera_reset_bridge:19.2.0 emif_cpu_rst_bridge
vds::create_cell -properties { parameters:ADDRESS_WIDTH {0} parameters:USE_AUTO_ADDRESS_WIDTH {1}  } -vlnv altera.com:ip:altera_avalon_mm_bridge:20.1.0 emif_mm_bridge
vds::create_cell -properties { parameters:ACTIVE_LOW_RESET {1} parameters:SYNCHRONOUS_EDGES {none}  } -vlnv altera.com:ip:altera_reset_bridge:19.2.0 emif_rst_bridge
vds::create_cell -properties { parameters:DATA_WIDTH {256} parameters:MAX_BURST_SIZE {64} parameters:MAX_PENDING_RESPONSES {10} parameters:PIPELINE_COMMAND {0} parameters:PIPELINE_RESPONSE {0} parameters:USE_AUTO_ADDRESS_WIDTH {1}  } -vlnv altera.com:ip:altera_avalon_mm_bridge:20.1.0 mm_bridge_0
vds::create_cell -properties { parameters:direction {Input}  } -vlnv altera.com:ip:altera_avalon_pio:19.2.4 pio_emif_cal
vds::connect_interface_net -dest ddr4_emif|s0_axi4lite -src ddr4_cal|axil_driver_axi4_lite
vds::assign_base_address -connection ddr4_cal.axil_driver_axi4_lite/ddr4_emif.s0_axi4lite 0x0000
vds::connect_interface_net -dest ddr4_emif|s0_axi4 -src mm_bridge_0|m0
vds::assign_base_address -connection mm_bridge_0.m0/ddr4_emif.s0_axi4 0x0000
vds::connect_interface_net -dest pio_emif_cal|s1 -src emif_mm_bridge|m0
vds::assign_base_address -connection emif_mm_bridge.m0/pio_emif_cal.s1 0x0000
vds::export_interface_pin mm_bridge_0|s0 s0
vds::export_interface_pin emif_mm_bridge|s0 mm_ctrl_in
vds::export_interface_pin ddr4_emif|mem_ck_0 c_ddr4_emif_ck0
vds::export_interface_pin ddr4_emif|mem_0 c_ddr4_emif_mem
vds::export_pin ddr4_emif|oct_0 c_ddr4_emif_oct
vds::export_pin emif_cpu_clk_bridge|in_clk cpu_clk_in
vds::export_pin emif_cpu_rst_bridge|in_reset cpu_rst_in
vds::export_pin ddr4_cal|cal_done_rst_n emif_cal_done_rst_n
vds::export_pin ddr4_emif|mem_reset_n c_ddr4_emif_resetn
vds::connect_net -src ddr4_emif|s0_axi4_clock_out -dest emif_core_clk_rst_bridge|clk
vds::connect_net -src ddr4_emif|s0_axi4_clock_out -dest mm_bridge_0|clk
vds::connect_net -src ddr4_emif|s0_axi4_clock_out -dest emif_axi_clk_out_bridge|in_clk
vds::connect_net -src ddr4_emif|s0_axi4_ctrl_ready -dest emif_axi_ctrl_ready_out_bridge|in_reset
vds::connect_net -src ddr4_emif|s0_axi4_ctrl_ready -dest mm_bridge_0|reset
vds::export_pin emif_axi_clk_out_bridge|out_clk emif_clk_out
vds::export_pin emif_axi_ctrl_ready_out_bridge|out_reset emif_ready_out
vds::export_pin pio_emif_cal|external_connection emif_cal_pio
vds::connect_net -src emif_core_clk_rst_bridge|out_reset -dest ddr4_emif|core_init_n
vds::connect_net -src emif_cpu_clk_bridge|out_clk -dest ddr4_cal|axil_driver_clk
vds::connect_net -src emif_cpu_clk_bridge|out_clk -dest emif_mm_bridge|clk
vds::connect_net -src emif_cpu_clk_bridge|out_clk -dest pio_emif_cal|clk
vds::connect_net -src emif_cpu_clk_bridge|out_clk -dest emif_cpu_rst_bridge|clk
vds::connect_net -src emif_cpu_clk_bridge|out_clk -dest ddr4_emif|s0_axi4lite_clock
vds::connect_net -src emif_cpu_rst_bridge|out_reset -dest emif_mm_bridge|reset
vds::connect_net -src emif_cpu_rst_bridge|out_reset -dest pio_emif_cal|reset
vds::export_pin emif_rst_bridge|in_reset emif_rst_brdg_in
vds::connect_net -src emif_rst_bridge|out_reset -dest ddr4_cal|axil_driver_rst_n
vds::connect_net -src emif_rst_bridge|out_reset -dest emif_core_clk_rst_bridge|in_reset
vds::connect_net -src emif_rst_bridge|out_reset -dest ddr4_emif|s0_axi4lite_reset_n
vds::export_pin ddr4_emif|ref_clk i_clk_ddr4_emif_pll_ref
vds::set_domain_properties {qsys_mm.burstAdapterImplementation GENERIC_CONVERTER qsys_mm.clockCrossingAdapter AUTO qsys_mm.enableAllPipelines FALSE qsys_mm.enableEccProtection FALSE qsys_mm.enableInstrumentation FALSE qsys_mm.enableOutOfOrderSupport FALSE qsys_mm.fifoDepth 8 qsys_mm.insertDefaultSlave FALSE qsys_mm.interconnectResetSource DEFAULT qsys_mm.maxAdditionalLatency 1 qsys_mm.optimizeRdFifoSize FALSE qsys_mm.piplineType PIPELINE_STAGE qsys_mm.responseFifoType REGISTER_BASED qsys_mm.splitCommandsFor4KBoundary FALSE qsys_mm.syncResets TRUE qsys_mm.widthAdapterImplementation GENERIC_CONVERTER } ddr4_cal.axil_driver_axi4_lite
vds::set_domain_properties {qsys_mm.burstAdapterImplementation GENERIC_CONVERTER qsys_mm.clockCrossingAdapter AUTO qsys_mm.enableAllPipelines FALSE qsys_mm.enableEccProtection FALSE qsys_mm.enableInstrumentation FALSE qsys_mm.enableOutOfOrderSupport FALSE qsys_mm.fifoDepth 8 qsys_mm.insertDefaultSlave FALSE qsys_mm.interconnectResetSource DEFAULT qsys_mm.maxAdditionalLatency 1 qsys_mm.optimizeRdFifoSize FALSE qsys_mm.piplineType PIPELINE_STAGE qsys_mm.responseFifoType REGISTER_BASED qsys_mm.splitCommandsFor4KBoundary FALSE qsys_mm.syncResets TRUE qsys_mm.widthAdapterImplementation GENERIC_CONVERTER } emif_mm_bridge.m0
vds::set_domain_properties {qsys_mm.burstAdapterImplementation GENERIC_CONVERTER qsys_mm.clockCrossingAdapter AUTO qsys_mm.enableAllPipelines FALSE qsys_mm.enableEccProtection FALSE qsys_mm.enableInstrumentation FALSE qsys_mm.enableOutOfOrderSupport FALSE qsys_mm.fifoDepth 8 qsys_mm.insertDefaultSlave FALSE qsys_mm.interconnectResetSource DEFAULT qsys_mm.maxAdditionalLatency 1 qsys_mm.optimizeRdFifoSize FALSE qsys_mm.piplineType PIPELINE_STAGE qsys_mm.responseFifoType REGISTER_BASED qsys_mm.splitCommandsFor4KBoundary FALSE qsys_mm.syncResets TRUE qsys_mm.widthAdapterImplementation GENERIC_CONVERTER } mm_bridge_0.m0
vds::validate_system
vds::save_system emif_subsystem
vds::close_system emif_subsystem
}
proc create_isp_lite_in_subsystem {} {
vds::create_system isp_lite_in_subsystem
vds::create_cell -properties { parameters:EXPLICIT_CLOCK_RATE {100000000}  } -vlnv altera.com:ip:altera_clock_bridge:19.2.0 isp_in_cpu_clk_bridge
vds::create_cell -vlnv altera.com:ip:altera_reset_bridge:19.2.0 isp_in_cpu_rst_bridge
vds::create_cell -properties { parameters:ADDRESS_WIDTH {0} parameters:USE_AUTO_ADDRESS_WIDTH {1}  } -vlnv altera.com:ip:altera_avalon_mm_bridge:20.1.0 isp_in_mm_bridge
vds::create_cell -properties { parameters:BPS {12} parameters:C_CONV_MODE {148} parameters:PIXELS_IN_PARALLEL {1}  } -vlnv altera.com:ip:intel_vvp_remosaic:1.0 isp_in_rms
vds::create_cell -properties { parameters:BPS {12} parameters:C_OMNI_CAP_ID_COMPONENT {1} parameters:EXTERNAL_MODE {1} parameters:NUMBER_OF_COLOR_PLANES {1} parameters:NUM_OUTPUTS {1} parameters:SEPARATE_SLAVE_CLOCK {1} parameters:VVP_INTF_TYPE {VVP_LITE}  } -vlnv altera.com:ip:intel_vvp_switch:24.7.0 isp_in_switch
vds::create_cell -properties { parameters:BPS {12} parameters:CORE_PATTERN_1 {1} parameters:EXTERNAL_MODE {1} parameters:NUM_CORES {2} parameters:PIPELINE_READY {1} parameters:RUNTIME_CONTROL {1} parameters:SEPARATE_SLAVE_CLOCK {1}  } -vlnv altera.com:ip:intel_vvp_tpg:24.8.0 isp_in_tpg
vds::create_cell -properties { parameters:EXPLICIT_CLOCK_RATE {297000000}  } -vlnv altera.com:ip:altera_clock_bridge:19.2.0 isp_in_vid_clk_bridge
vds::create_cell -vlnv altera.com:ip:altera_reset_bridge:19.2.0 isp_in_vid_rst_bridge
vds::connect_interface_net -dest isp_in_tpg|av_mm_control_agent -src isp_in_mm_bridge|m0
vds::assign_base_address -connection isp_in_mm_bridge.m0/isp_in_tpg.av_mm_control_agent 0x0200
vds::connect_interface_net -dest isp_in_rms|av_mm_control_agent -src isp_in_mm_bridge|m0
vds::assign_base_address -connection isp_in_mm_bridge.m0/isp_in_rms.av_mm_control_agent 0x0400
vds::connect_interface_net -dest isp_in_switch|av_mm_control_agent -src isp_in_mm_bridge|m0
vds::assign_base_address -connection isp_in_mm_bridge.m0/isp_in_switch.av_mm_control_agent 0x0000
vds::connect_interface_net -dest isp_in_switch|axi4s_vid_in_0 -src isp_in_rms|axi4s_vid_out
vds::connect_interface_net -dest isp_in_rms|axi4s_vid_in -src isp_in_tpg|axi4s_vid_out
vds::export_interface_pin isp_in_switch|axi4s_vid_out_0 isp_in_m_vid_axis
vds::export_interface_pin isp_in_switch|axi4s_vid_in_1 mipi_csi2_0_s_vid_axis
vds::export_interface_pin isp_in_mm_bridge|s0 mm_ctrl_in
vds::export_pin isp_in_cpu_clk_bridge|in_clk cpu_clk_in
vds::export_pin isp_in_cpu_rst_bridge|in_reset cpu_rst_in
vds::connect_net -src isp_in_cpu_clk_bridge|out_clk -dest isp_in_tpg|agent_clock
vds::connect_net -src isp_in_cpu_clk_bridge|out_clk -dest isp_in_rms|agent_clock
vds::connect_net -src isp_in_cpu_clk_bridge|out_clk -dest isp_in_switch|agent_clock
vds::connect_net -src isp_in_cpu_clk_bridge|out_clk -dest isp_in_cpu_rst_bridge|clk
vds::connect_net -src isp_in_cpu_clk_bridge|out_clk -dest isp_in_mm_bridge|clk
vds::connect_net -src isp_in_cpu_rst_bridge|out_reset -dest isp_in_tpg|agent_reset
vds::connect_net -src isp_in_cpu_rst_bridge|out_reset -dest isp_in_rms|agent_reset
vds::connect_net -src isp_in_cpu_rst_bridge|out_reset -dest isp_in_switch|agent_reset
vds::connect_net -src isp_in_cpu_rst_bridge|out_reset -dest isp_in_mm_bridge|reset
vds::connect_net -src isp_in_vid_clk_bridge|out_clk -dest isp_in_vid_rst_bridge|clk
vds::connect_net -src isp_in_vid_clk_bridge|out_clk -dest isp_in_tpg|main_clock
vds::connect_net -src isp_in_vid_clk_bridge|out_clk -dest isp_in_rms|main_clock
vds::connect_net -src isp_in_vid_clk_bridge|out_clk -dest isp_in_switch|main_clock
vds::connect_net -src isp_in_vid_rst_bridge|out_reset -dest isp_in_tpg|main_reset
vds::connect_net -src isp_in_vid_rst_bridge|out_reset -dest isp_in_rms|main_reset
vds::connect_net -src isp_in_vid_rst_bridge|out_reset -dest isp_in_switch|main_reset
vds::export_pin isp_in_vid_clk_bridge|in_clk vid_clk_in
vds::export_pin isp_in_vid_rst_bridge|in_reset vid_rst_in
vds::set_domain_properties {qsys_mm.burstAdapterImplementation GENERIC_CONVERTER qsys_mm.clockCrossingAdapter AUTO qsys_mm.enableAllPipelines FALSE qsys_mm.enableEccProtection FALSE qsys_mm.enableInstrumentation FALSE qsys_mm.enableOutOfOrderSupport FALSE qsys_mm.fifoDepth 8 qsys_mm.insertDefaultSlave FALSE qsys_mm.interconnectResetSource DEFAULT qsys_mm.maxAdditionalLatency 1 qsys_mm.optimizeRdFifoSize FALSE qsys_mm.piplineType PIPELINE_STAGE qsys_mm.responseFifoType REGISTER_BASED qsys_mm.splitCommandsFor4KBoundary FALSE qsys_mm.syncResets TRUE qsys_mm.widthAdapterImplementation GENERIC_CONVERTER } isp_in_mm_bridge.m0
vds::validate_system
vds::save_system isp_lite_in_subsystem
vds::close_system isp_lite_in_subsystem
}
proc create_isp_lite_out_subsystem {} {
vds::create_system isp_lite_out_subsystem
vds::create_cell -properties { parameters:BITS_LUT {9} parameters:BPS_IN {10} parameters:BPS_OUT {10} parameters:EQUIDISTANT {0} parameters:NUMBER_OF_COLOR_PLANES {3} parameters:PIPELINE_READY {1} parameters:SEPARATE_SLAVE_CLOCK {1}  } -vlnv altera.com:ip:intel_vvp_1d_lut:24.7.0 isp_1d_lut
vds::create_cell -properties { parameters:EXPLICIT_CLOCK_RATE {100000000}  } -vlnv altera.com:ip:altera_clock_bridge:19.2.0 isp_cpu_clk_bridge
vds::create_cell -vlnv altera.com:ip:altera_reset_bridge:19.2.0 isp_cpu_rst_bridge
vds::create_cell -properties { parameters:EXPLICIT_CLOCK_RATE {170000000}  } -vlnv altera.com:ip:altera_clock_bridge:19.2.0 isp_emif_clk_bridge
vds::create_cell -properties { parameters:ACTIVE_LOW_RESET {1}  } -vlnv altera.com:ip:altera_reset_bridge:19.2.0 isp_emif_rst_bridge
vds::create_cell -properties { parameters:BPS {10} parameters:EXTERNAL_MODE {1} parameters:PIPELINE_READY {1}  } -vlnv altera.com:ip:intel_vvp_icon:99.0 isp_icon
vds::create_cell -properties { parameters:BLENDING_MODE_1 {1} parameters:BLENDING_MODE_2 {1} parameters:BLENDING_MODE_3 {1} parameters:BPS {10} parameters:EXTERNAL_MODE {1} parameters:NUMBER_OF_COLOR_PLANES {3} parameters:NUM_LAYERS {3} parameters:PIPELINE_LEVEL {2} parameters:SEPARATE_SLAVE_CLOCK {1}  } -vlnv altera.com:ip:intel_vvp_mixer:24.8.0 isp_mixer
vds::create_cell -properties { parameters:ADDRESS_WIDTH {0} parameters:USE_AUTO_ADDRESS_WIDTH {1}  } -vlnv altera.com:ip:altera_avalon_mm_bridge:20.1.0 isp_mm_bridge
vds::create_cell -properties { parameters:BPS {10} parameters:INPUT_MODE {EXTERNAL} parameters:NUMBER_OF_COLOR_PLANES {3} parameters:OUTPUT_MODE {INTERNAL} parameters:PIPELINE_READY {1} parameters:PIXELS_IN_PARALLEL {2} parameters:RUNTIME_CONTROL {1} parameters:SEPARATE_SLAVE_CLOCK {1}  } -vlnv altera.com:ip:intel_vvp_protocol_conv:24.9.0 isp_out_proto_conv
vds::create_cell -properties { parameters:BPS {10} parameters:EXTERNAL_MODE {1} parameters:NUMBER_OF_COLOR_PLANES {3} parameters:NUM_INPUTS {1} parameters:NUM_OUTPUTS {1} parameters:SEPARATE_SLAVE_CLOCK {1} parameters:UNINTERRUPTED_INPUTS {1} parameters:VVP_INTF_TYPE {VVP_LITE}  } -vlnv altera.com:ip:intel_vvp_switch:24.7.0 isp_out_switch
vds::create_cell -properties { parameters:BURSTCOUNT_WIDTH {7} parameters:DATA_WIDTH {256} parameters:ENABLE_SLAVE_PORT {false} parameters:MASTER_ADDRESS_WIDTH {33} parameters:MAX_PENDING_READS {8} parameters:SLAVE_ADDRESS_WIDTH {27}  } -vlnv altera.com:ip:altera_address_span_extender:19.2.1 isp_se_vfb
vds::create_cell -properties { parameters:BPS {10} parameters:CORE_PATTERN_0 {1} parameters:EXTERNAL_MODE {1} parameters:PIPELINE_READY {1} parameters:RUNTIME_CONTROL {1} parameters:SEPARATE_SLAVE_CLOCK {1}  } -vlnv altera.com:ip:intel_vvp_tpg:24.8.0 isp_tpg
vds::create_cell -properties { parameters:BPS {10} parameters:DROP_RPT_AUX_PKTS_WITH_FRAMES {0} parameters:EXTERNAL_MODE {1} parameters:MAX_HEIGHT {4096} parameters:MEM_BUFF_LINE_STRIDE {49152} parameters:NUMBER_OF_COLOR_PLANES {3} parameters:P_AV_MM_DATA_WIDTH {256} parameters:READ_BURST_TARGET {64} parameters:READ_FIFO_DEPTH {512} parameters:RUNTIME_CONTROL {1} parameters:SEPARATE_SLAVE_CLOCK {1} parameters:WRITE_BURST_TARGET {64} parameters:WRITE_FIFO_DEPTH {512}  } -vlnv altera.com:ip:intel_vvp_vfb:24.8.0 isp_vfb
vds::create_cell -properties { parameters:EXPLICIT_CLOCK_RATE {297000000}  } -vlnv altera.com:ip:altera_clock_bridge:19.2.0 isp_vid_clk_bridge
vds::create_cell -properties { parameters:EXPLICIT_CLOCK_RATE {148500000}  } -vlnv altera.com:ip:altera_clock_bridge:19.2.0 isp_vid_clk_out_bridge
vds::create_cell -vlnv altera.com:ip:altera_reset_bridge:19.2.0 isp_vid_rst_bridge
vds::create_cell -vlnv altera.com:ip:altera_reset_bridge:19.2.0 isp_vid_rst_out_bridge
vds::create_cell -properties { parameters:BPS {10} parameters:DUAL_CLOCK {1} parameters:EXTERNAL_MODE {1} parameters:FIFO_DEPTH {2048} parameters:NUMBER_OF_COLOR_PLANES {3} parameters:PIPELINE_READY {1} parameters:SEPARATE_SLAVE_CLOCK {1}  } -vlnv altera.com:ip:intel_vvp_pip_conv:24.8.0 vid_out_pip_conv
vds::connect_interface_net -dest isp_1d_lut|av_mm_control_agent -src isp_mm_bridge|m0
vds::assign_base_address -connection isp_mm_bridge.m0/isp_1d_lut.av_mm_control_agent 0x0000
vds::connect_interface_net -dest isp_out_switch|axi4s_vid_in_0 -src isp_1d_lut|axi4s_vid_out
vds::connect_interface_net -dest isp_1d_lut|axi4s_vid_in -src isp_mixer|axi4s_vid_out
vds::connect_interface_net -dest isp_mixer|axi4s_vid_2_in -src isp_icon|axi4s_vid_out
vds::connect_interface_net -dest isp_mixer|av_mm_control_agent -src isp_mm_bridge|m0
vds::assign_base_address -connection isp_mm_bridge.m0/isp_mixer.av_mm_control_agent 0x2000
vds::connect_interface_net -dest isp_mixer|axi4s_vid_1_in -src isp_vfb|axi4s_vid_out
vds::connect_interface_net -dest isp_mixer|axi4s_vid_0_in -src isp_tpg|axi4s_vid_out
vds::connect_interface_net -dest isp_vfb|av_mm_control_agent -src isp_mm_bridge|m0
vds::assign_base_address -connection isp_mm_bridge.m0/isp_vfb.av_mm_control_agent 0x2c00
vds::connect_interface_net -dest isp_tpg|av_mm_control_agent -src isp_mm_bridge|m0
vds::assign_base_address -connection isp_mm_bridge.m0/isp_tpg.av_mm_control_agent 0x2a00
vds::connect_interface_net -dest isp_out_switch|av_mm_control_agent -src isp_mm_bridge|m0
vds::assign_base_address -connection isp_mm_bridge.m0/isp_out_switch.av_mm_control_agent 0x2800
vds::connect_interface_net -dest vid_out_pip_conv|av_mm_control_agent -src isp_mm_bridge|m0
vds::assign_base_address -connection isp_mm_bridge.m0/vid_out_pip_conv.av_mm_control_agent 0x2600
vds::connect_interface_net -dest isp_out_proto_conv|av_mm_control_agent -src isp_mm_bridge|m0
vds::assign_base_address -connection isp_mm_bridge.m0/isp_out_proto_conv.av_mm_control_agent 0x2400
vds::connect_interface_net -dest isp_out_proto_conv|axi4s_vid_in -src vid_out_pip_conv|axi4s_vid_out
vds::connect_interface_net -dest vid_out_pip_conv|axi4s_vid_in -src isp_out_switch|axi4s_vid_out_0
vds::connect_interface_net -dest isp_se_vfb|windowed_slave -src isp_vfb|av_mm_mem_read_host
vds::assign_base_address -connection isp_vfb.av_mm_mem_read_host/isp_se_vfb.windowed_slave 0x0000
vds::connect_interface_net -dest isp_se_vfb|windowed_slave -src isp_vfb|av_mm_mem_write_host
vds::assign_base_address -connection isp_vfb.av_mm_mem_write_host/isp_se_vfb.windowed_slave 0x0000
vds::export_interface_pin isp_vfb|axi4s_vid_in vid_in
vds::export_interface_pin isp_se_vfb|expanded_master av_mm_host_se_vfb
vds::export_interface_pin isp_out_proto_conv|axi4s_vid_out vid_out
vds::export_interface_pin isp_mm_bridge|s0 mm_ctrl_in
vds::export_pin isp_cpu_clk_bridge|in_clk cpu_clk_in
vds::export_pin isp_cpu_rst_bridge|in_reset cpu_rst_in
vds::export_pin isp_emif_clk_bridge|in_clk emif_clk_in
vds::export_pin isp_emif_rst_bridge|in_reset emif_rst_in
vds::connect_net -src isp_cpu_clk_bridge|out_clk -dest isp_tpg|agent_clock
vds::connect_net -src isp_cpu_clk_bridge|out_clk -dest isp_mixer|agent_clock
vds::connect_net -src isp_cpu_clk_bridge|out_clk -dest isp_1d_lut|agent_clock
vds::connect_net -src isp_cpu_clk_bridge|out_clk -dest isp_out_switch|agent_clock
vds::connect_net -src isp_cpu_clk_bridge|out_clk -dest vid_out_pip_conv|agent_clock
vds::connect_net -src isp_cpu_clk_bridge|out_clk -dest isp_out_proto_conv|agent_clock
vds::connect_net -src isp_cpu_clk_bridge|out_clk -dest isp_cpu_rst_bridge|clk
vds::connect_net -src isp_cpu_clk_bridge|out_clk -dest isp_mm_bridge|clk
vds::connect_net -src isp_cpu_clk_bridge|out_clk -dest isp_vfb|control_clock
vds::connect_net -src isp_cpu_rst_bridge|out_reset -dest isp_tpg|agent_reset
vds::connect_net -src isp_cpu_rst_bridge|out_reset -dest isp_mixer|agent_reset
vds::connect_net -src isp_cpu_rst_bridge|out_reset -dest isp_1d_lut|agent_reset
vds::connect_net -src isp_cpu_rst_bridge|out_reset -dest isp_out_switch|agent_reset
vds::connect_net -src isp_cpu_rst_bridge|out_reset -dest vid_out_pip_conv|agent_reset
vds::connect_net -src isp_cpu_rst_bridge|out_reset -dest isp_out_proto_conv|agent_reset
vds::connect_net -src isp_cpu_rst_bridge|out_reset -dest isp_vfb|control_reset
vds::connect_net -src isp_cpu_rst_bridge|out_reset -dest isp_mm_bridge|reset
vds::connect_net -src isp_emif_clk_bridge|out_clk -dest isp_emif_rst_bridge|clk
vds::connect_net -src isp_emif_clk_bridge|out_clk -dest isp_se_vfb|clock
vds::connect_net -src isp_emif_clk_bridge|out_clk -dest isp_vfb|mem_clock
vds::connect_net -src isp_emif_rst_bridge|out_reset -dest isp_vfb|mem_reset
vds::connect_net -src isp_emif_rst_bridge|out_reset -dest isp_se_vfb|reset
vds::connect_net -src isp_vid_clk_bridge|out_clk -dest isp_vid_rst_bridge|clk
vds::connect_net -src isp_vid_clk_bridge|out_clk -dest vid_out_pip_conv|in_clock
vds::connect_net -src isp_vid_clk_bridge|out_clk -dest isp_vfb|main_clock
vds::connect_net -src isp_vid_clk_bridge|out_clk -dest isp_tpg|main_clock
vds::connect_net -src isp_vid_clk_bridge|out_clk -dest isp_icon|main_clock
vds::connect_net -src isp_vid_clk_bridge|out_clk -dest isp_mixer|main_clock
vds::connect_net -src isp_vid_clk_bridge|out_clk -dest isp_1d_lut|main_clock
vds::connect_net -src isp_vid_clk_bridge|out_clk -dest isp_out_switch|main_clock
vds::connect_net -src isp_vid_clk_out_bridge|out_clk -dest isp_vid_rst_out_bridge|clk
vds::connect_net -src isp_vid_clk_out_bridge|out_clk -dest isp_out_proto_conv|main_clock
vds::connect_net -src isp_vid_clk_out_bridge|out_clk -dest vid_out_pip_conv|out_clock
vds::connect_net -src isp_vid_rst_bridge|out_reset -dest vid_out_pip_conv|in_reset
vds::connect_net -src isp_vid_rst_bridge|out_reset -dest isp_vfb|main_reset
vds::connect_net -src isp_vid_rst_bridge|out_reset -dest isp_tpg|main_reset
vds::connect_net -src isp_vid_rst_bridge|out_reset -dest isp_icon|main_reset
vds::connect_net -src isp_vid_rst_bridge|out_reset -dest isp_mixer|main_reset
vds::connect_net -src isp_vid_rst_bridge|out_reset -dest isp_1d_lut|main_reset
vds::connect_net -src isp_vid_rst_bridge|out_reset -dest isp_out_switch|main_reset
vds::connect_net -src isp_vid_rst_out_bridge|out_reset -dest isp_out_proto_conv|main_reset
vds::connect_net -src isp_vid_rst_out_bridge|out_reset -dest vid_out_pip_conv|out_reset
vds::export_pin isp_vid_clk_bridge|in_clk vid_clk_in
vds::export_pin isp_vid_clk_out_bridge|in_clk vid_clk_out
vds::export_pin isp_vid_rst_bridge|in_reset vid_rst_in
vds::export_pin isp_vid_rst_out_bridge|in_reset vid_rst_out
vds::set_domain_properties {qsys_mm.burstAdapterImplementation GENERIC_CONVERTER qsys_mm.clockCrossingAdapter AUTO qsys_mm.enableAllPipelines FALSE qsys_mm.enableEccProtection FALSE qsys_mm.enableInstrumentation FALSE qsys_mm.enableOutOfOrderSupport FALSE qsys_mm.fifoDepth 8 qsys_mm.insertDefaultSlave FALSE qsys_mm.interconnectResetSource DEFAULT qsys_mm.maxAdditionalLatency 1 qsys_mm.optimizeRdFifoSize FALSE qsys_mm.piplineType PIPELINE_STAGE qsys_mm.responseFifoType REGISTER_BASED qsys_mm.splitCommandsFor4KBoundary FALSE qsys_mm.syncResets TRUE qsys_mm.widthAdapterImplementation GENERIC_CONVERTER } isp_mm_bridge.m0
vds::set_domain_properties {qsys_mm.burstAdapterImplementation GENERIC_CONVERTER qsys_mm.clockCrossingAdapter AUTO qsys_mm.enableAllPipelines FALSE qsys_mm.enableEccProtection FALSE qsys_mm.enableInstrumentation FALSE qsys_mm.enableOutOfOrderSupport FALSE qsys_mm.fifoDepth 8 qsys_mm.insertDefaultSlave FALSE qsys_mm.interconnectResetSource DEFAULT qsys_mm.maxAdditionalLatency 1 qsys_mm.optimizeRdFifoSize FALSE qsys_mm.piplineType PIPELINE_STAGE qsys_mm.responseFifoType REGISTER_BASED qsys_mm.splitCommandsFor4KBoundary FALSE qsys_mm.syncResets TRUE qsys_mm.widthAdapterImplementation GENERIC_CONVERTER } isp_vfb.av_mm_mem_read_host
vds::validate_system
vds::save_system isp_lite_out_subsystem
vds::close_system isp_lite_out_subsystem
}
proc create_isp_lite_subsystem {} {
vds::create_system isp_lite_subsystem
vds::create_cell -properties { parameters:BPS_IN {12} parameters:BPS_OUT {12} parameters:PIPELINE_READY {1} parameters:ENABLE_DEBUG {0} parameters:REFLECT_AROUND_ZERO {1} parameters:SEPARATE_SLAVE_CLOCK {1}  } -vlnv altera.com:ip:intel_vvp_blc:24.8.0 isp_blc
vds::create_cell -properties { parameters:BPS_IN {12} parameters:BPS_OUT {10} parameters:COEFFICIENT_INT_BITS {8} parameters:EXTERNAL_MODE {1} parameters:PIPELINE_READY {1} parameters:RUNTIME_CONTROL {1} parameters:SEPARATE_SLAVE_CLOCK {1} parameters:SUMMAND_SIGNED {1}  } -vlnv altera.com:ip:intel_vvp_csc:24.8.0 isp_ccm
vds::create_cell -properties { parameters:EXPLICIT_CLOCK_RATE {100000000}  } -vlnv altera.com:ip:altera_clock_bridge:19.2.0 isp_cpu_clk_bridge
vds::create_cell -vlnv altera.com:ip:altera_reset_bridge:19.2.0 isp_cpu_rst_bridge
vds::create_cell -properties { parameters:BPS_IN {12} parameters:BPS_OUT {12} parameters:PIPELINE_READY {1} parameters:SEPARATE_SLAVE_CLOCK {1}  } -vlnv altera.com:ip:intel_vvp_demosaic:24.7.0 isp_dms
vds::create_cell -properties { parameters:ADDRESS_WIDTH {0} parameters:USE_AUTO_ADDRESS_WIDTH {1}  } -vlnv altera.com:ip:altera_avalon_mm_bridge:20.1.0 isp_mm_bridge
vds::create_cell -properties { parameters:EXPLICIT_CLOCK_RATE {297000000}  } -vlnv altera.com:ip:altera_clock_bridge:19.2.0 isp_vid_clk_bridge
vds::create_cell -vlnv altera.com:ip:altera_reset_bridge:19.2.0 isp_vid_rst_bridge
vds::create_cell -properties { parameters:BPS_IN {12} parameters:BPS_OUT {12} parameters:PIPELINE_READY {1} parameters:SEPARATE_SLAVE_CLOCK {1}  } -vlnv altera.com:ip:intel_vvp_wbc:24.7.0 isp_wbc
vds::connect_interface_net -dest isp_blc|av_mm_control_agent -src isp_mm_bridge|m0
vds::assign_base_address -connection isp_mm_bridge.m0/isp_blc.av_mm_control_agent 0x0600
vds::connect_interface_net -dest isp_wbc|axi4s_vid_in -src isp_blc|axi4s_vid_out
vds::connect_interface_net -dest isp_ccm|av_mm_control_agent -src isp_mm_bridge|m0
vds::assign_base_address -connection isp_mm_bridge.m0/isp_ccm.av_mm_control_agent 0x0000
vds::connect_interface_net -dest isp_ccm|axi4s_vid_in -src isp_dms|axi4s_vid_out
vds::connect_interface_net -dest isp_dms|av_mm_control_agent -src isp_mm_bridge|m0
vds::assign_base_address -connection isp_mm_bridge.m0/isp_dms.av_mm_control_agent 0x0200
vds::connect_interface_net -dest isp_dms|axi4s_vid_in -src isp_wbc|axi4s_vid_out
vds::connect_interface_net -dest isp_wbc|av_mm_control_agent -src isp_mm_bridge|m0
vds::assign_base_address -connection isp_mm_bridge.m0/isp_wbc.av_mm_control_agent 0x0400
vds::export_interface_pin isp_mm_bridge|s0 mm_ctrl_in
vds::export_interface_pin isp_ccm|axi4s_vid_out isp_out_m_vid_axis
vds::export_interface_pin isp_blc|axi4s_vid_in isp_in_s_vid_axis
vds::export_pin isp_cpu_clk_bridge|in_clk cpu_clk_in
vds::export_pin isp_cpu_rst_bridge|in_reset cpu_rst_in
vds::connect_net -src isp_cpu_clk_bridge|out_clk -dest isp_blc|agent_clock
vds::connect_net -src isp_cpu_clk_bridge|out_clk -dest isp_wbc|agent_clock
vds::connect_net -src isp_cpu_clk_bridge|out_clk -dest isp_dms|agent_clock
vds::connect_net -src isp_cpu_clk_bridge|out_clk -dest isp_ccm|agent_clock
vds::connect_net -src isp_cpu_clk_bridge|out_clk -dest isp_cpu_rst_bridge|clk
vds::connect_net -src isp_cpu_clk_bridge|out_clk -dest isp_mm_bridge|clk
vds::connect_net -src isp_cpu_rst_bridge|out_reset -dest isp_blc|agent_reset
vds::connect_net -src isp_cpu_rst_bridge|out_reset -dest isp_wbc|agent_reset
vds::connect_net -src isp_cpu_rst_bridge|out_reset -dest isp_dms|agent_reset
vds::connect_net -src isp_cpu_rst_bridge|out_reset -dest isp_ccm|agent_reset
vds::connect_net -src isp_cpu_rst_bridge|out_reset -dest isp_mm_bridge|reset
vds::connect_net -src isp_vid_clk_bridge|out_clk -dest isp_vid_rst_bridge|clk
vds::connect_net -src isp_vid_clk_bridge|out_clk -dest isp_blc|main_clock
vds::connect_net -src isp_vid_clk_bridge|out_clk -dest isp_wbc|main_clock
vds::connect_net -src isp_vid_clk_bridge|out_clk -dest isp_dms|main_clock
vds::connect_net -src isp_vid_clk_bridge|out_clk -dest isp_ccm|main_clock
vds::connect_net -src isp_vid_rst_bridge|out_reset -dest isp_blc|main_reset
vds::connect_net -src isp_vid_rst_bridge|out_reset -dest isp_wbc|main_reset
vds::connect_net -src isp_vid_rst_bridge|out_reset -dest isp_dms|main_reset
vds::connect_net -src isp_vid_rst_bridge|out_reset -dest isp_ccm|main_reset
vds::export_pin isp_vid_clk_bridge|in_clk vid_clk_in
vds::export_pin isp_vid_rst_bridge|in_reset vid_rst_in
vds::set_domain_properties {qsys_mm.burstAdapterImplementation GENERIC_CONVERTER qsys_mm.clockCrossingAdapter AUTO qsys_mm.enableAllPipelines FALSE qsys_mm.enableEccProtection FALSE qsys_mm.enableInstrumentation FALSE qsys_mm.enableOutOfOrderSupport FALSE qsys_mm.fifoDepth 8 qsys_mm.insertDefaultSlave FALSE qsys_mm.interconnectResetSource DEFAULT qsys_mm.maxAdditionalLatency 1 qsys_mm.optimizeRdFifoSize FALSE qsys_mm.piplineType PIPELINE_STAGE qsys_mm.responseFifoType REGISTER_BASED qsys_mm.splitCommandsFor4KBoundary FALSE qsys_mm.syncResets TRUE qsys_mm.widthAdapterImplementation GENERIC_CONVERTER } isp_mm_bridge.m0
vds::validate_system
vds::save_system isp_lite_subsystem
vds::close_system isp_lite_subsystem
}
proc create_mipi_rx_subsystem {} {
vds::create_system mipi_rx_subsystem
vds::create_cell -properties { parameters:FIFO_DEPTH {32}  } -vlnv altera.com:ip:altera_avalon_i2c:19.2.6 cam_i2c
vds::create_cell -properties { parameters:EXPLICIT_CLOCK_RATE {100000000}  } -vlnv altera.com:ip:altera_clock_bridge:19.2.0 mipi_in_cpu_clk_bridge
vds::create_cell -vlnv altera.com:ip:altera_reset_bridge:19.2.0 mipi_in_cpu_rst_bridge
vds::create_cell -properties { parameters:BUFFER_DEPTH {4096} parameters:ENABLE_CRC {0} parameters:ENABLE_CSR {0} parameters:ENABLE_ECC {0} parameters:PIXELS_IN_PARALLEL {1} parameters:SUPPORT_RAW12 {1} parameters:SUPPORT_RGB888 {0}  } -vlnv altera.com:ip:intel_mipi_csi2:4.0.0 mipi_in_mipi_csi2
vds::create_cell -properties { parameters:GUI_BIT_RATE_MBPS_RNG_0 {1500.0} parameters:GUI_BYTE_LOC_0 {4} parameters:GUI_DPHY_IP_ROLE_0 {0} parameters:GUI_NUM_LANES_0 {2} parameters:GUI_REF_CLK_FREQ_MHZ_0 {150.0} parameters:GUI_REF_CLK_IO_0 {3} parameters:GUI_RX_DLANE_DESKEW_DELAY_0_0 {48} parameters:GUI_RX_DLANE_DESKEW_DELAY_1_0 {48} parameters:GUI_RX_DLANE_DESKEW_DELAY_2_0 {48} parameters:GUI_RX_DLANE_DESKEW_DELAY_3_0 {48} parameters:GUI_RZQ_ID {1}  } -vlnv altera.com:ip:mipi_dphy:6.2.1 mipi_in_mipi_dphy
vds::create_cell -properties { parameters:ADDRESS_WIDTH {14} parameters:SYNC_RESET {1} parameters:USE_AUTO_ADDRESS_WIDTH {1}  } -vlnv altera.com:ip:altera_avalon_mm_bridge:20.1.0 mipi_in_mm_bridge
vds::create_cell -properties { parameters:BPS {12} parameters:INPUT_MODE {INTERNAL} parameters:NUMBER_OF_COLOR_PLANES {1} parameters:PIPELINE_READY {1}  } -vlnv altera.com:ip:intel_vvp_protocol_conv:24.9.0 mipi_in_proto_conv
vds::create_cell -properties { parameters:EXPLICIT_CLOCK_RATE {297000000}  } -vlnv altera.com:ip:altera_clock_bridge:19.2.0 mipi_in_vid_clk_bridge
vds::create_cell -vlnv altera.com:ip:altera_reset_bridge:19.2.0 mipi_in_vid_rst_bridge
vds::connect_interface_net -dest cam_i2c|csr -src mipi_in_mm_bridge|m0
vds::assign_base_address -connection mipi_in_mm_bridge.m0/cam_i2c.csr 0x1000
vds::connect_interface_net -dest mipi_in_proto_conv|axi4s_vid_in -src mipi_in_mipi_csi2|video_streaming_interface_0
vds::connect_interface_net -dest mipi_in_mipi_dphy|LINK0_CK_ppi_rx_err -src mipi_in_mipi_csi2|i_ck_ppi_rx_err
vds::connect_interface_net -dest mipi_in_mipi_dphy|LINK0_D1_ppi_rx_err -src mipi_in_mipi_csi2|i_d1_ppi_rx_err
vds::connect_interface_net -dest mipi_in_mipi_dphy|LINK0_D0_ppi_rx_err -src mipi_in_mipi_csi2|i_d0_ppi_rx_err
vds::connect_interface_net -dest mipi_in_mipi_dphy|LINK0_CK_ppi_ctrl -src mipi_in_mipi_csi2|ck_ppi_ctrl
vds::connect_interface_net -dest mipi_in_mipi_dphy|LINK0_D1_ppi_ctrl -src mipi_in_mipi_csi2|d1_ppi_ctrl
vds::connect_interface_net -dest mipi_in_mipi_dphy|LINK0_D0_ppi_ctrl -src mipi_in_mipi_csi2|d0_ppi_ctrl
vds::connect_interface_net -dest mipi_in_mipi_dphy|LINK0_CK_ppi_rx_lp -src mipi_in_mipi_csi2|ck_ppi_lp
vds::connect_interface_net -dest mipi_in_mipi_dphy|LINK0_D1_ppi_rx_lp -src mipi_in_mipi_csi2|d1_ppi_lp
vds::connect_interface_net -dest mipi_in_mipi_dphy|LINK0_D0_ppi_rx_lp -src mipi_in_mipi_csi2|d0_ppi_lp
vds::connect_interface_net -dest mipi_in_mipi_dphy|LINK0_CK_ppi_rx_hs -src mipi_in_mipi_csi2|ck_ppi_hs
vds::connect_interface_net -dest mipi_in_mipi_dphy|LINK0_D1_ppi_rx_hs -src mipi_in_mipi_csi2|d1_ppi_hs
vds::connect_interface_net -dest mipi_in_mipi_dphy|LINK0_D0_ppi_rx_hs -src mipi_in_mipi_csi2|d0_ppi_hs
vds::connect_interface_net -dest mipi_in_mipi_dphy|axi_lite -src mipi_in_mm_bridge|m0
vds::assign_base_address -connection mipi_in_mm_bridge.m0/mipi_in_mipi_dphy.axi_lite 0x0000
vds::export_interface_pin mipi_in_proto_conv|axi4s_vid_out mipi_csi2_m_vid_axis
vds::export_interface_pin mipi_in_mm_bridge|s0 mm_ctrl_in
vds::export_interface_pin mipi_in_mipi_dphy|reg_bus reg_bus
vds::export_interface_pin mipi_in_mipi_dphy|LINK0_dphy_io mipi_dphy_LINK0_dphy_io
vds::export_interface_pin cam_i2c|i2c_serial cam_i2c_i2c_serial
vds::export_interface_pin cam_i2c|interrupt_sender cam_i2c_irq
vds::export_pin mipi_in_cpu_clk_bridge|in_clk cpu_clk_in
vds::export_pin mipi_in_cpu_rst_bridge|in_reset cpu_rst_in
vds::export_pin mipi_in_mipi_dphy|ref_clk_0 mipi_dphy_ref_clk_0
vds::export_pin mipi_in_mipi_dphy|rzq mipi_dphy_rzq
vds::connect_net -src mipi_in_cpu_clk_bridge|out_clk -dest mipi_in_cpu_rst_bridge|clk
vds::connect_net -src mipi_in_cpu_clk_bridge|out_clk -dest mipi_in_mm_bridge|clk
vds::connect_net -src mipi_in_cpu_clk_bridge|out_clk -dest cam_i2c|clock
vds::connect_net -src mipi_in_cpu_clk_bridge|out_clk -dest mipi_in_mipi_dphy|reg_clk
vds::connect_net -src mipi_in_cpu_rst_bridge|out_reset -dest mipi_in_mipi_dphy|arst
vds::connect_net -src mipi_in_cpu_rst_bridge|out_reset -dest mipi_in_mipi_dphy|reg_srst
vds::connect_net -src mipi_in_cpu_rst_bridge|out_reset -dest mipi_in_mm_bridge|reset
vds::connect_net -src mipi_in_cpu_rst_bridge|out_reset -dest cam_i2c|reset_sink
vds::connect_net -src mipi_in_mipi_dphy|LINK0_CK_ppi_rx_hs_clk -dest mipi_in_mipi_csi2|ck_ppi_hs_clk
vds::connect_net -src mipi_in_mipi_dphy|LINK0_CK_ppi_rx_hs_srst -dest mipi_in_mipi_csi2|ck_ppi_rx_hs_srst
vds::connect_net -src mipi_in_mipi_dphy|LINK0_D0_ppi_rx_hs_clk -dest mipi_in_mipi_csi2|d0_ppi_hs_clk
vds::connect_net -src mipi_in_mipi_dphy|LINK0_D0_ppi_rx_hs_srst -dest mipi_in_mipi_csi2|d0_ppi_rx_hs_srst
vds::connect_net -src mipi_in_mipi_dphy|LINK0_D1_ppi_rx_hs_clk -dest mipi_in_mipi_csi2|d1_ppi_hs_clk
vds::connect_net -src mipi_in_mipi_dphy|LINK0_D1_ppi_rx_hs_srst -dest mipi_in_mipi_csi2|d1_ppi_rx_hs_srst
vds::connect_net -src mipi_in_vid_clk_bridge|out_clk -dest mipi_in_mipi_csi2|axi4s_clk
vds::connect_net -src mipi_in_vid_clk_bridge|out_clk -dest mipi_in_vid_rst_bridge|clk
vds::connect_net -src mipi_in_vid_clk_bridge|out_clk -dest mipi_in_proto_conv|main_clock
vds::connect_net -src mipi_in_vid_rst_bridge|out_reset -dest mipi_in_mipi_csi2|axi4s_rst
vds::connect_net -src mipi_in_vid_rst_bridge|out_reset -dest mipi_in_proto_conv|main_reset
vds::export_pin mipi_in_vid_clk_bridge|in_clk vid_clk_in
vds::export_pin mipi_in_vid_rst_bridge|in_reset vid_rst_in
vds::set_domain_properties {qsys_mm.burstAdapterImplementation GENERIC_CONVERTER qsys_mm.clockCrossingAdapter AUTO qsys_mm.enableAllPipelines FALSE qsys_mm.enableEccProtection FALSE qsys_mm.enableInstrumentation FALSE qsys_mm.enableOutOfOrderSupport FALSE qsys_mm.fifoDepth 8 qsys_mm.insertDefaultSlave FALSE qsys_mm.interconnectResetSource DEFAULT qsys_mm.maxAdditionalLatency 1 qsys_mm.optimizeRdFifoSize FALSE qsys_mm.piplineType PIPELINE_STAGE qsys_mm.responseFifoType REGISTER_BASED qsys_mm.splitCommandsFor4KBoundary FALSE qsys_mm.syncResets TRUE qsys_mm.widthAdapterImplementation GENERIC_CONVERTER } mipi_in_mm_bridge.m0
vds::validate_system
vds::save_system mipi_rx_subsystem
vds::close_system mipi_rx_subsystem
}
proc create_niosv_subsystem {} {
vds::create_system niosv_subsystem
vds::create_cell -properties { parameters:resetSlave {cpu_ram.axi_s1}  } -vlnv altera.com:ip:intel_niosv_m:26.0.0 cpu
vds::create_cell -properties { parameters:EXPLICIT_CLOCK_RATE {100000000}  } -vlnv altera.com:ip:altera_clock_bridge:19.2.0 cpu_clk_bridge
vds::create_cell -properties { parameters:readBufferDepth {1024} parameters:writeBufferDepth {1024}  } -vlnv altera.com:ip:altera_avalon_jtag_uart:19.3.2 cpu_jtag_uart
vds::create_cell -properties { parameters:USE_AUTO_ADDRESS_WIDTH {1}  } -vlnv altera.com:ip:altera_avalon_mm_bridge:20.1.0 cpu_mm_bridge
vds::create_cell -properties { parameters:idWidth {2} parameters:interfaceType {1} parameters:memorySize {262144}  } -vlnv altera.com:ip:intel_onchip_memory:2.0.0 cpu_ram
vds::create_cell -vlnv altera.com:ip:altera_reset_bridge:19.2.0 cpu_rst_bridge
vds::create_cell -properties { parameters:periodUnits {USEC}  } -vlnv altera.com:ip:altera_avalon_timer:19.3.5 cpu_timer
vds::create_cell -properties { parameters:IRQ_WIDTH {5}  } -vlnv altera.com:ip:altera_irq_bridge:20.0.0 irq_bridge
vds::connect_interface_net -dest cpu|dm_agent -src cpu|data_manager
vds::assign_base_address -connection cpu.data_manager/cpu.dm_agent 0x00400000
vds::connect_interface_net -dest cpu|dm_agent -src cpu|instruction_manager
vds::assign_base_address -connection cpu.instruction_manager/cpu.dm_agent 0x00400000
vds::lock_base_address -interface cpu|dm_agent
vds::connect_interface_net -dest cpu|timer_sw_agent -src cpu|data_manager
vds::assign_base_address -connection cpu.data_manager/cpu.timer_sw_agent 0x00410000
vds::lock_base_address -interface cpu|timer_sw_agent
vds::connect_interface_net -dest cpu_jtag_uart|avalon_jtag_slave -src cpu|data_manager
vds::assign_base_address -connection cpu.data_manager/cpu_jtag_uart.avalon_jtag_slave 0x00410060
vds::connect_interface_net -dest cpu_ram|axi_s1 -src cpu|data_manager
vds::assign_base_address -connection cpu.data_manager/cpu_ram.axi_s1 0x0000
vds::connect_interface_net -dest cpu_mm_bridge|s0 -src cpu|data_manager
vds::assign_base_address -connection cpu.data_manager/cpu_mm_bridge.s0 0x00420000
vds::connect_interface_net -dest cpu_timer|s1 -src cpu|data_manager
vds::assign_base_address -connection cpu.data_manager/cpu_timer.s1 0x00410040
vds::connect_interface_net -dest cpu_ram|axi_s1 -src cpu|instruction_manager
vds::assign_base_address -connection cpu.instruction_manager/cpu_ram.axi_s1 0x0000
vds::connect_interface_net -dest cpu_jtag_uart|irq -src cpu|platform_irq_rx
vds::set_interrupt_irq -connection cpu.platform_irq_rx/cpu_jtag_uart.irq 0
vds::connect_interface_net -dest cpu_timer|irq -src cpu|platform_irq_rx
vds::set_interrupt_irq -connection cpu.platform_irq_rx/cpu_timer.irq 1
vds::connect_interface_net -dest irq_bridge|sender0_irq -src cpu|platform_irq_rx
vds::set_interrupt_irq -connection cpu.platform_irq_rx/irq_bridge.sender0_irq 2
vds::connect_interface_net -dest irq_bridge|sender1_irq -src cpu|platform_irq_rx
vds::set_interrupt_irq -connection cpu.platform_irq_rx/irq_bridge.sender1_irq 3
vds::connect_interface_net -dest irq_bridge|sender2_irq -src cpu|platform_irq_rx
vds::set_interrupt_irq -connection cpu.platform_irq_rx/irq_bridge.sender2_irq 4
vds::connect_interface_net -dest irq_bridge|sender3_irq -src cpu|platform_irq_rx
vds::set_interrupt_irq -connection cpu.platform_irq_rx/irq_bridge.sender3_irq 5
vds::connect_interface_net -dest irq_bridge|sender4_irq -src cpu|platform_irq_rx
vds::set_interrupt_irq -connection cpu.platform_irq_rx/irq_bridge.sender4_irq 6
vds::lock_base_address -interface cpu_jtag_uart|avalon_jtag_slave
vds::lock_base_address -interface cpu_mm_bridge|s0
vds::lock_base_address -interface cpu_ram|axi_s1
vds::lock_base_address -interface cpu_timer|s1
vds::export_interface_pin irq_bridge|receiver_irq ia_cpu_irq_receiver
vds::export_interface_pin cpu_mm_bridge|m0 o_cpu_mm_master
vds::connect_net -src cpu_clk_bridge|out_clk -dest cpu_rst_bridge|clk
vds::connect_net -src cpu_clk_bridge|out_clk -dest cpu_mm_bridge|clk
vds::connect_net -src cpu_clk_bridge|out_clk -dest cpu|clk
vds::connect_net -src cpu_clk_bridge|out_clk -dest cpu_jtag_uart|clk
vds::connect_net -src cpu_clk_bridge|out_clk -dest cpu_timer|clk
vds::connect_net -src cpu_clk_bridge|out_clk -dest irq_bridge|clk
vds::connect_net -src cpu_clk_bridge|out_clk -dest cpu_ram|clk1
vds::connect_net -src cpu_rst_bridge|out_reset -dest irq_bridge|clk_reset
vds::connect_net -src cpu_rst_bridge|out_reset -dest cpu_mm_bridge|reset
vds::connect_net -src cpu_rst_bridge|out_reset -dest cpu|reset
vds::connect_net -src cpu_rst_bridge|out_reset -dest cpu_jtag_uart|reset
vds::connect_net -src cpu_rst_bridge|out_reset -dest cpu_timer|reset
vds::connect_net -src cpu_rst_bridge|out_reset -dest cpu_ram|reset1
vds::export_pin cpu_clk_bridge|in_clk i_clk_cpu
vds::export_pin cpu_rst_bridge|in_reset i_reset_cpu
vds::set_domain_properties {qsys_mm.burstAdapterImplementation GENERIC_CONVERTER qsys_mm.clockCrossingAdapter AUTO qsys_mm.enableAllPipelines FALSE qsys_mm.enableEccProtection FALSE qsys_mm.enableInstrumentation FALSE qsys_mm.enableOutOfOrderSupport FALSE qsys_mm.fifoDepth 8 qsys_mm.insertDefaultSlave FALSE qsys_mm.interconnectResetSource DEFAULT qsys_mm.maxAdditionalLatency 1 qsys_mm.optimizeRdFifoSize FALSE qsys_mm.piplineType PIPELINE_STAGE qsys_mm.responseFifoType REGISTER_BASED qsys_mm.splitCommandsFor4KBoundary FALSE qsys_mm.syncResets TRUE qsys_mm.widthAdapterImplementation GENERIC_CONVERTER } cpu.data_manager
vds::validate_system
vds::save_system niosv_subsystem
vds::close_system niosv_subsystem
}
create_mipi_rx_subsystem
create_niosv_subsystem
create_clock_subsystem
create_board_subsystem
create_emif_subsystem
create_dp_tx_subsystem
create_isp_lite_in_subsystem
create_isp_lite_subsystem
create_isp_lite_out_subsystem
vds::create_system top_subsystem
vds::create_cell board_subsystem -type system -ref board_subsystem
vds::create_cell clock_subsystem -type system -ref clock_subsystem
vds::create_cell dp_tx_subsystem -type system -ref dp_tx_subsystem
vds::create_cell emif_subsystem -type system -ref emif_subsystem
vds::create_cell isp_lite_in_subsystem -type system -ref isp_lite_in_subsystem
vds::create_cell isp_lite_out_subsystem -type system -ref isp_lite_out_subsystem
vds::create_cell isp_lite_subsystem -type system -ref isp_lite_subsystem
vds::create_cell mipi_rx_subsystem -type system -ref mipi_rx_subsystem
vds::create_cell niosv_subsystem -type system -ref niosv_subsystem
vds::connect_interface_net -dest dp_tx_subsystem|i2c_master_irq -src niosv_subsystem|ia_cpu_irq_receiver
vds::set_interrupt_irq -connection niosv_subsystem.ia_cpu_irq_receiver/dp_tx_subsystem.i2c_master_irq 0
vds::connect_interface_net -dest dp_tx_subsystem|dp_source_tx_mgmt -src niosv_subsystem|o_cpu_mm_master
vds::assign_base_address -connection niosv_subsystem.o_cpu_mm_master/dp_tx_subsystem.dp_source_tx_mgmt 0x4000
vds::connect_interface_net -dest dp_tx_subsystem|dp_source_tx_axi4s_vid_in -src isp_lite_out_subsystem|vid_out
vds::connect_interface_net -dest dp_tx_subsystem|dp_source_tx_mgmt_interrupt -src niosv_subsystem|ia_cpu_irq_receiver
vds::set_interrupt_irq -connection niosv_subsystem.ia_cpu_irq_receiver/dp_tx_subsystem.dp_source_tx_mgmt_interrupt 2
vds::connect_interface_net -dest dp_tx_subsystem|dp_core_i2c_board_irq -src niosv_subsystem|ia_cpu_irq_receiver
vds::set_interrupt_irq -connection niosv_subsystem.ia_cpu_irq_receiver/dp_tx_subsystem.dp_core_i2c_board_irq 1
vds::connect_interface_net -dest emif_subsystem|s0 -src isp_lite_out_subsystem|av_mm_host_se_vfb
vds::assign_base_address -connection isp_lite_out_subsystem.av_mm_host_se_vfb/emif_subsystem.s0 0x0000
vds::connect_interface_net -dest emif_subsystem|mm_ctrl_in -src niosv_subsystem|o_cpu_mm_master
vds::assign_base_address -connection niosv_subsystem.o_cpu_mm_master/emif_subsystem.mm_ctrl_in 0xb000
vds::connect_interface_net -dest isp_lite_subsystem|isp_in_s_vid_axis -src isp_lite_in_subsystem|isp_in_m_vid_axis
vds::connect_interface_net -dest isp_lite_in_subsystem|mipi_csi2_0_s_vid_axis -src mipi_rx_subsystem|mipi_csi2_m_vid_axis
vds::connect_interface_net -dest isp_lite_in_subsystem|mm_ctrl_in -src niosv_subsystem|o_cpu_mm_master
vds::assign_base_address -connection niosv_subsystem.o_cpu_mm_master/isp_lite_in_subsystem.mm_ctrl_in 0xa800
vds::connect_interface_net -dest isp_lite_out_subsystem|vid_in -src isp_lite_subsystem|isp_out_m_vid_axis
vds::connect_interface_net -dest isp_lite_out_subsystem|mm_ctrl_in -src niosv_subsystem|o_cpu_mm_master
vds::assign_base_address -connection niosv_subsystem.o_cpu_mm_master/isp_lite_out_subsystem.mm_ctrl_in 0x0000
vds::connect_interface_net -dest isp_lite_subsystem|mm_ctrl_in -src niosv_subsystem|o_cpu_mm_master
vds::assign_base_address -connection niosv_subsystem.o_cpu_mm_master/isp_lite_subsystem.mm_ctrl_in 0xa000
vds::connect_interface_net -dest mipi_rx_subsystem|mm_ctrl_in -src niosv_subsystem|o_cpu_mm_master
vds::assign_base_address -connection niosv_subsystem.o_cpu_mm_master/mipi_rx_subsystem.mm_ctrl_in 0x8000
vds::connect_interface_net -dest mipi_rx_subsystem|cam_i2c_irq -src niosv_subsystem|ia_cpu_irq_receiver
vds::set_interrupt_irq -connection niosv_subsystem.ia_cpu_irq_receiver/mipi_rx_subsystem.cam_i2c_irq 3
vds::export_interface_pin mipi_rx_subsystem|mipi_dphy_LINK0_dphy_io mipi_rx_subsystem_mipi_dphy_LINK0_dphy_io
vds::export_interface_pin mipi_rx_subsystem|cam_i2c_i2c_serial mipi_rx_subsystem_cam_i2c_i2c_serial
vds::export_interface_pin emif_subsystem|c_ddr4_emif_ck0 emif_subsystem_c_ddr4_emif_ck0
vds::export_interface_pin emif_subsystem|c_ddr4_emif_mem emif_subsystem_c_ddr4_emif_mem
vds::export_interface_pin dp_tx_subsystem|i2c_master_i2c_serial dp_tx_subsystem_i2c_master_i2c_serial
vds::export_interface_pin dp_tx_subsystem|dp_source_tx_reconfig dp_tx_subsystem_dp_source_tx_reconfig
vds::export_interface_pin dp_tx_subsystem|dp_source_tx_analog_reconfig dp_tx_subsystem_dp_source_tx_analog_reconfig
vds::export_interface_pin dp_tx_subsystem|dp_source_tx_aux dp_tx_subsystem_dp_source_tx_aux
vds::export_interface_pin dp_tx_subsystem|dp_source_tx_xcvr_interface dp_tx_subsystem_dp_source_tx_xcvr_interface
vds::export_interface_pin dp_tx_subsystem|dp_core_i2c_board_i2c_serial dp_tx_subsystem_dp_core_i2c_board_i2c_serial
vds::connect_net -src board_subsystem|o_clk -dest clock_subsystem|i_ref_clk
vds::connect_net -src board_subsystem|o_reset -dest clock_subsystem|i_ref_rst
vds::export_pin board_subsystem|o_rst_device_ready board_subsystem_o_rst_device_ready_export
vds::export_pin board_subsystem|i_clk board_subsystem_i_clk
vds::export_pin board_subsystem|ia_reset_pb_n board_subsystem_ia_reset_pb_n
vds::connect_net -src clock_subsystem|o_gen_clk_0_clk -dest isp_lite_out_subsystem|vid_clk_out
vds::connect_net -src clock_subsystem|o_gen_clk_0_clk -dest dp_tx_subsystem|vvp_clock_bridge_in_clk
vds::connect_net -src clock_subsystem|o_gen_clk_0_rst -dest isp_lite_out_subsystem|vid_rst_out
vds::connect_net -src clock_subsystem|o_gen_clk_0_rst -dest dp_tx_subsystem|vvp_reset_bridge_in_reset
vds::connect_net -src clock_subsystem|o_gen_clk_1_clk -dest mipi_rx_subsystem|vid_clk_in
vds::connect_net -src clock_subsystem|o_gen_clk_1_clk -dest isp_lite_in_subsystem|vid_clk_in
vds::connect_net -src clock_subsystem|o_gen_clk_1_clk -dest isp_lite_subsystem|vid_clk_in
vds::connect_net -src clock_subsystem|o_gen_clk_1_clk -dest isp_lite_out_subsystem|vid_clk_in
vds::connect_net -src clock_subsystem|o_gen_clk_1_rst -dest mipi_rx_subsystem|vid_rst_in
vds::connect_net -src clock_subsystem|o_gen_clk_1_rst -dest isp_lite_in_subsystem|vid_rst_in
vds::connect_net -src clock_subsystem|o_gen_clk_1_rst -dest isp_lite_subsystem|vid_rst_in
vds::connect_net -src clock_subsystem|o_gen_clk_1_rst -dest isp_lite_out_subsystem|vid_rst_in
vds::connect_net -src clock_subsystem|o_gen_clk_2_clk -dest dp_tx_subsystem|clk_16_in_clk
vds::connect_net -src clock_subsystem|o_gen_clk_2_rst -dest dp_tx_subsystem|rst_16_in_rst
vds::export_pin clock_subsystem|o_iopll_0_locked_export clock_subsystem_o_iopll_0_locked
vds::connect_net -src clock_subsystem|o_ref_clk -dest mipi_rx_subsystem|cpu_clk_in
vds::connect_net -src clock_subsystem|o_ref_clk -dest isp_lite_in_subsystem|cpu_clk_in
vds::connect_net -src clock_subsystem|o_ref_clk -dest isp_lite_subsystem|cpu_clk_in
vds::connect_net -src clock_subsystem|o_ref_clk -dest isp_lite_out_subsystem|cpu_clk_in
vds::connect_net -src clock_subsystem|o_ref_clk -dest emif_subsystem|cpu_clk_in
vds::connect_net -src clock_subsystem|o_ref_clk -dest niosv_subsystem|i_clk_cpu
vds::connect_net -src clock_subsystem|o_ref_clk -dest dp_tx_subsystem|mgmt_clk_in_clk
vds::export_pin clock_subsystem|o_ref_clk_export clock_subsystem_o_ref_clk
vds::connect_net -src clock_subsystem|o_ref_rst -dest mipi_rx_subsystem|cpu_rst_in
vds::connect_net -src clock_subsystem|o_ref_rst -dest isp_lite_in_subsystem|cpu_rst_in
vds::connect_net -src clock_subsystem|o_ref_rst -dest isp_lite_subsystem|cpu_rst_in
vds::connect_net -src clock_subsystem|o_ref_rst -dest isp_lite_out_subsystem|cpu_rst_in
vds::connect_net -src clock_subsystem|o_ref_rst -dest emif_subsystem|cpu_rst_in
vds::connect_net -src clock_subsystem|o_ref_rst -dest niosv_subsystem|i_reset_cpu
vds::connect_net -src clock_subsystem|o_ref_rst -dest dp_tx_subsystem|mgmt_rst_in_rst
vds::export_pin clock_subsystem|o_ref_rst_export clock_subsystem_o_ref_rst
vds::export_pin dp_tx_subsystem|curr_format_pio dp_tx_subsystem_curr_format_pio
vds::export_pin dp_tx_subsystem|dp_core_board_pio dp_tx_subsystem_dp_core_board_pio
vds::export_pin dp_tx_subsystem|status_pio dp_tx_subsystem_status_pio
vds::export_pin dp_tx_subsystem|supportd_fmats_pio dp_tx_subsystem_supportd_fmats_pio
vds::export_pin dp_tx_subsystem|dp_source_dsc_sync_clk dp_tx_subsystem_dp_source_dsc_sync_clk
vds::export_pin dp_tx_subsystem|dp_source_tx_im_dsc_clk dp_tx_subsystem_dp_source_tx_im_dsc_clk
vds::export_pin dp_tx_subsystem|format_ovrride_pio dp_tx_subsystem_format_ovrride_pio
vds::export_pin emif_subsystem|c_ddr4_emif_resetn emif_subsystem_c_ddr4_emif_resetn
vds::export_pin emif_subsystem|emif_cal_done_rst_n emif_subsystem_emif_cal_done_rst_n
vds::connect_net -src emif_subsystem|emif_clk_out -dest isp_lite_out_subsystem|emif_clk_in
vds::connect_net -src emif_subsystem|emif_ready_out -dest isp_lite_out_subsystem|emif_rst_in
vds::export_pin emif_subsystem|c_ddr4_emif_oct emif_subsystem_c_ddr4_emif_oct
vds::export_pin emif_subsystem|emif_cal_pio emif_subsystem_emif_cal_pio
vds::export_pin emif_subsystem|emif_rst_brdg_in emif_subsystem_emif_rst_brdg_in
vds::export_pin emif_subsystem|i_clk_ddr4_emif_pll_ref emif_subsystem_i_clk_ddr4_emif_pll_ref
vds::export_pin mipi_rx_subsystem|mipi_dphy_ref_clk_0 mipi_rx_subsystem_mipi_dphy_ref_clk_0
vds::export_pin mipi_rx_subsystem|mipi_dphy_rzq mipi_rx_subsystem_mipi_dphy_rzq
vds::set_domain_properties {qsys_mm.burstAdapterImplementation GENERIC_CONVERTER qsys_mm.clockCrossingAdapter AUTO qsys_mm.enableAllPipelines FALSE qsys_mm.enableEccProtection FALSE qsys_mm.enableInstrumentation FALSE qsys_mm.enableOutOfOrderSupport FALSE qsys_mm.fifoDepth 8 qsys_mm.insertDefaultSlave FALSE qsys_mm.interconnectResetSource DEFAULT qsys_mm.maxAdditionalLatency 1 qsys_mm.optimizeRdFifoSize FALSE qsys_mm.piplineType PIPELINE_STAGE qsys_mm.responseFifoType REGISTER_BASED qsys_mm.splitCommandsFor4KBoundary FALSE qsys_mm.syncResets TRUE qsys_mm.widthAdapterImplementation GENERIC_CONVERTER } isp_lite_out_subsystem.av_mm_host_se_vfb
vds::set_domain_properties {qsys_mm.burstAdapterImplementation GENERIC_CONVERTER qsys_mm.clockCrossingAdapter AUTO qsys_mm.enableAllPipelines FALSE qsys_mm.enableEccProtection FALSE qsys_mm.enableInstrumentation FALSE qsys_mm.enableOutOfOrderSupport FALSE qsys_mm.fifoDepth 8 qsys_mm.insertDefaultSlave FALSE qsys_mm.interconnectResetSource DEFAULT qsys_mm.maxAdditionalLatency 1 qsys_mm.optimizeRdFifoSize FALSE qsys_mm.piplineType PIPELINE_STAGE qsys_mm.responseFifoType REGISTER_BASED qsys_mm.splitCommandsFor4KBoundary FALSE qsys_mm.syncResets TRUE qsys_mm.widthAdapterImplementation GENERIC_CONVERTER } niosv_subsystem.o_cpu_mm_master
vds::sync_system_info
vds::validate_system
vds::save_system top_subsystem
post_message [pwd]
puts [pwd]
vds::generate_system -design_file $prj_vds -search_path $ -synthesis Verilog
vds::close_system top_subsystem
post_message "Script completed successfully."

