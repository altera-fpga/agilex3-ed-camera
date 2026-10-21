// ##################################################################################
// Copyright (C) Altera Corporation
//
// This software and the related documents are Altera copyrighted materials, and
// your use of them is governed by the express license under which they were
// provided to you ("License"). Unless the License provides otherwise, you may
// not use, modify, copy, publish, distribute, disclose or transmit this software
// or the related documents without Altera's prior written permission.
//
// This software and the related documents are provided as is, with no express
// or implied warranties, other than those that are expressly stated in the License.
// ##################################################################################

module top (
   input  logic       clk_100_mhz,
   input  logic       rst_pb_n,
   input  logic [0:0] user_pb_n,
   output logic [1:0] user_led,


   // board_subsystem exports
   input  logic        bank_2a_mem_pll_ref_clk,
   input  logic        bank_2a_mem_oct_rzqin,
   output logic [ 0:0] bank_2a_mem_ck,
   output logic [ 0:0] bank_2a_mem_ck_n,
   output logic [ 0:0] bank_2a_mem_cke,
   output logic [ 0:0] bank_2a_mem_cs,
   output logic [ 5:0] bank_2a_mem_ca,
   output logic        bank_2a_mem_reset_n,
   inout  logic [31:0] bank_2a_mem_dq,
   inout  logic [ 3:0] bank_2a_mem_dqs,
   inout  logic [ 3:0] bank_2a_mem_dqs_n,
   inout  logic [ 3:0] bank_2a_mem_dmi,

   // mipi_rx_subsystem exports
   input  logic       mipi_csi2_rx_dphy_rzq,
   input  logic       mipi_csi2_rx_dphy_ref_clk,
   input  logic [1:0] mipi_csi2_rx_dphy_link0_io_d_p,
   input  logic [1:0] mipi_csi2_rx_dphy_link0_io_d_n,
   input  logic       mipi_csi2_rx_dphy_link0_io_c_p,
   input  logic       mipi_csi2_rx_dphy_link0_io_c_n,
   inout  logic       mipi_csi2_rx_i2c_scl,
   inout  logic       mipi_csi2_rx_i2c_sda,
   output logic       mipi_csi2_rx_power_en,
   output logic       mipi_csi2_rx_led_en,

   // mipi_dsi2_tx_subsystem exports
   input  logic       mipi_dsi2_tx_dphy_rzq,
   input  logic       mipi_dsi2_tx_dphy_ref_clk,
   output logic [1:0] mipi_dsi2_tx_dphy_link0_io_d_p,
   output logic [1:0] mipi_dsi2_tx_dphy_link0_io_d_n,
   output logic       mipi_dsi2_tx_dphy_link0_io_c_p,
   output logic       mipi_dsi2_tx_dphy_link0_io_c_n,
   inout  logic       mipi_dsi2_tx_i2c_scl,
   inout  logic       mipi_dsi2_tx_i2c_sda,

   // dp_tx_subsystem exports
   input  logic       fgt_refclk_150,
   output logic [1:0] pin_dp_tx_p,
   output logic [1:0] pin_dp_tx_n,
   output logic       pin_dp_tx_cad,
   input  logic       pin_dp_tx_hpd,
   input  logic       pin_dp_tx_aux_in,
   output logic       pin_dp_tx_aux_out,
   output logic       pin_dp_tx_aux_oe
);

   // clock_subsystem exports
   logic        clock_subsystem_ref_clk;
   logic        clock_subsystem_ref_rst;
   logic        clock_subsystem_iopll_0_locked;

   // board_subsystem exports
   logic        user_device_ready_export;

   // mipi_rx_subsystem exports
   logic        mipi_csi2_rx_i2c_scl_oe;
   logic        mipi_csi2_rx_i2c_sda_oe;
   logic        mipi_csi2_rx_i2c_scl_in;
   logic        mipi_csi2_rx_i2c_sda_in;

   // emif_subsystem exports
   logic        cal_done_rst_n;

   // mipi_dsi2_tx_subsystem exports
   logic        mipi_dsi2_tx_i2c_scl_oe;
   logic        mipi_dsi2_tx_i2c_sda_oe;
   logic        mipi_dsi2_tx_i2c_scl_in;
   logic        mipi_dsi2_tx_i2c_sda_in;

   // dp_tx_subsystem exports
   logic [31:0] pio_board;
   logic [31:0] dp_tx_status_o;
   logic [31:0] dp_tx_supportd_fmats_o;
   logic [31:0] dp_tx_curr_format_o;
   logic [31:0] dp_tx_format_ovrride_i;
   logic        dp_tx_analog_rcfg_req;
   logic        dp_tx_analog_rcfg_ack;
   logic [ 3:0] dp_tx_analog_rcfg_vod;
   logic [ 3:0] dp_tx_analog_rcfg_emp;
   logic [ 7:0] dp_tx_link_rate;
   logic        dp_tx_rate_rcfg_req;
   logic        dp_tx_rate_rcfg_ack;
   logic        dp_tx_rate_rcfg_busy;
   logic [79:0] dp_tx_parallel_data;
   logic [ 1:0] dp_tx_cal_busy;
   logic        gxb_tx_clkout;
   logic        dp_txpll_locked;
   logic        dp_tx_hpd;
   logic        dp_tx_aux_in;
   logic        dp_tx_aux_out;
   logic        dp_tx_aux_oe;

   assign user_led                = 2'b00;

   // mipi_rx_subsystem exports
   assign mipi_csi2_rx_i2c_scl_in = mipi_csi2_rx_i2c_scl;
   assign mipi_csi2_rx_i2c_sda_in = mipi_csi2_rx_i2c_sda;
   assign mipi_csi2_rx_i2c_scl    = mipi_csi2_rx_i2c_scl_oe ? 1'b0 : 1'bz;
   assign mipi_csi2_rx_i2c_sda    = mipi_csi2_rx_i2c_sda_oe ? 1'b0 : 1'bz;
   assign mipi_csi2_rx_power_en   = 1'b1;
   assign mipi_csi2_rx_led_en     = 1'b1;

   // mipi_dsi2_tx_subsystem exports
   assign mipi_dsi2_tx_i2c_scl_in = mipi_dsi2_tx_i2c_scl;
   assign mipi_dsi2_tx_i2c_sda_in = mipi_dsi2_tx_i2c_sda;
   assign mipi_dsi2_tx_i2c_scl    = mipi_dsi2_tx_i2c_scl_oe ? 1'b0 : 1'bz;
   assign mipi_dsi2_tx_i2c_sda    = mipi_dsi2_tx_i2c_sda_oe ? 1'b0 : 1'bz;

   // dp_tx_subsystem exports
   assign pin_dp_tx_cad           = 1'b0;
   assign dp_tx_hpd               = ~pin_dp_tx_hpd;
   assign dp_tx_aux_in            = pin_dp_tx_aux_in;
   assign pin_dp_tx_aux_out       = dp_tx_aux_out;
   assign pin_dp_tx_aux_oe        = dp_tx_aux_oe;
   assign dp_tx_cal_busy          = '0;

   top_subsystem u0 (
      .board_subsystem_i_clk_clk          (clk_100_mhz),
      .board_subsystem_ia_reset_pb_n_reset(rst_pb_n),

      // clock_subsystem exports
      .clock_subsystem_o_ref_clk_clk          (clock_subsystem_ref_clk),
      .clock_subsystem_o_ref_rst_reset        (clock_subsystem_ref_rst),
      .clock_subsystem_o_iopll_0_locked_export(clock_subsystem_iopll_0_locked),

      // board_subsystem exports
      .board_subsystem_o_rst_device_ready_export_reset(user_device_ready_export),

      // mipi_rx_subsystem exports
      .mipi_rx_subsystem_cam_i2c_i2c_serial_sda_in           (mipi_csi2_rx_i2c_sda_in),
      .mipi_rx_subsystem_cam_i2c_i2c_serial_scl_in           (mipi_csi2_rx_i2c_scl_in),
      .mipi_rx_subsystem_cam_i2c_i2c_serial_sda_oe           (mipi_csi2_rx_i2c_sda_oe),
      .mipi_rx_subsystem_cam_i2c_i2c_serial_scl_oe           (mipi_csi2_rx_i2c_scl_oe),
      .mipi_rx_subsystem_mipi_dphy_rzq_rzq                   (mipi_csi2_rx_dphy_rzq),
      .mipi_rx_subsystem_mipi_dphy_ref_clk_0_clk             (mipi_csi2_rx_dphy_ref_clk),
      .mipi_rx_subsystem_mipi_dphy_LINK0_dphy_io_dphy_link_dp(mipi_csi2_rx_dphy_link0_io_d_p),
      .mipi_rx_subsystem_mipi_dphy_LINK0_dphy_io_dphy_link_dn(mipi_csi2_rx_dphy_link0_io_d_n),
      .mipi_rx_subsystem_mipi_dphy_LINK0_dphy_io_dphy_link_cp(mipi_csi2_rx_dphy_link0_io_c_p),
      .mipi_rx_subsystem_mipi_dphy_LINK0_dphy_io_dphy_link_cn(mipi_csi2_rx_dphy_link0_io_c_n),

      // emif_subsystem exports
      .emif_subsystem_emif_rst_brdg_in_reset_n(~user_device_ready_export),
      .emif_subsystem_emif_cal_done_rst_n_reset_n(cal_done_rst_n),
      .emif_subsystem_emif_cal_pio_export({6'd0, clock_subsystem_iopll_0_locked, cal_done_rst_n}),
      .emif_subsystem_c_ddr4_emif_oct_oct_rzqin(bank_2a_mem_oct_rzqin),
      .emif_subsystem_i_clk_ddr4_emif_pll_ref_clk(bank_2a_mem_pll_ref_clk),
      .emif_subsystem_c_ddr4_emif_mem_mem_cke(bank_2a_mem_cke),
      .emif_subsystem_c_ddr4_emif_mem_mem_dq(bank_2a_mem_dq),
      .emif_subsystem_c_ddr4_emif_mem_mem_dqs_t(bank_2a_mem_dqs),
      .emif_subsystem_c_ddr4_emif_mem_mem_dqs_c(bank_2a_mem_dqs_n),
      .emif_subsystem_c_ddr4_emif_mem_mem_cs(bank_2a_mem_cs),
      .emif_subsystem_c_ddr4_emif_mem_mem_ca(bank_2a_mem_ca),
      .emif_subsystem_c_ddr4_emif_mem_mem_dmi(bank_2a_mem_dmi),
      .emif_subsystem_c_ddr4_emif_ck0_mem_ck_t(bank_2a_mem_ck),
      .emif_subsystem_c_ddr4_emif_ck0_mem_ck_c(bank_2a_mem_ck_n),
      .emif_subsystem_c_ddr4_emif_resetn_mem_reset_n(bank_2a_mem_reset_n),

      // mipi_dsi2_tx_subsystem exports
      .mipi_dsi2_tx_subsystem_mipi_dphy_rzq_rzq                   (mipi_dsi2_tx_dphy_rzq),
      .mipi_dsi2_tx_subsystem_mipi_dphy_ref_clk_0_clk             (mipi_dsi2_tx_dphy_ref_clk),
      .mipi_dsi2_tx_subsystem_mipi_dphy_LINK0_dphy_io_dphy_link_dp(mipi_dsi2_tx_dphy_link0_io_d_p),
      .mipi_dsi2_tx_subsystem_mipi_dphy_LINK0_dphy_io_dphy_link_dn(mipi_dsi2_tx_dphy_link0_io_d_n),
      .mipi_dsi2_tx_subsystem_mipi_dphy_LINK0_dphy_io_dphy_link_cp(mipi_dsi2_tx_dphy_link0_io_c_p),
      .mipi_dsi2_tx_subsystem_mipi_dphy_LINK0_dphy_io_dphy_link_cn(mipi_dsi2_tx_dphy_link0_io_c_n),
      .mipi_dsi2_tx_subsystem_dsi_i2c_sda_in                      (mipi_dsi2_tx_i2c_sda_in),
      .mipi_dsi2_tx_subsystem_dsi_i2c_scl_in                      (mipi_dsi2_tx_i2c_scl_in),
      .mipi_dsi2_tx_subsystem_dsi_i2c_sda_oe                      (mipi_dsi2_tx_i2c_sda_oe),
      .mipi_dsi2_tx_subsystem_dsi_i2c_scl_oe                      (mipi_dsi2_tx_i2c_scl_oe),

      // dp_tx_subsystem exports
      .dp_tx_subsystem_dp_core_board_pio_export (pio_board),
      .dp_tx_subsystem_status_pio_export        (dp_tx_status_o),
      .dp_tx_subsystem_supportd_fmats_pio_export(dp_tx_supportd_fmats_o),
      .dp_tx_subsystem_curr_format_pio_export   (dp_tx_curr_format_o),
      .dp_tx_subsystem_format_ovrride_pio_export(32'd0),

      // HPD
      .dp_tx_subsystem_dp_source_tx_aux_tx_hpd(dp_tx_hpd),

      // Aux
      .dp_tx_subsystem_dp_source_tx_aux_tx_aux_in                          (dp_tx_aux_in),
      .dp_tx_subsystem_dp_source_tx_aux_tx_aux_out                         (dp_tx_aux_out),
      .dp_tx_subsystem_dp_source_tx_aux_tx_aux_oe                          (dp_tx_aux_oe),
      .dp_tx_subsystem_dp_source_tx_analog_reconfig_tx_analog_reconfig_req (dp_tx_analog_rcfg_req),
      .dp_tx_subsystem_dp_source_tx_analog_reconfig_tx_analog_reconfig_ack (dp_tx_analog_rcfg_ack),
      .dp_tx_subsystem_dp_source_tx_analog_reconfig_tx_analog_reconfig_busy(),
      .dp_tx_subsystem_dp_source_tx_analog_reconfig_tx_vod                 (dp_tx_analog_rcfg_vod),
      .dp_tx_subsystem_dp_source_tx_analog_reconfig_tx_emp                 (dp_tx_analog_rcfg_emp),
      .dp_tx_subsystem_dp_source_tx_reconfig_tx_link_rate                  (),
      .dp_tx_subsystem_dp_source_tx_reconfig_tx_link_rate_8bits            (dp_tx_link_rate),
      .dp_tx_subsystem_dp_source_tx_reconfig_tx_reconfig_req               (dp_tx_rate_rcfg_req),
      .dp_tx_subsystem_dp_source_tx_reconfig_tx_reconfig_ack               (dp_tx_rate_rcfg_ack),
      .dp_tx_subsystem_dp_source_tx_reconfig_tx_reconfig_busy              (dp_tx_rate_rcfg_busy),
      .dp_tx_subsystem_dp_source_tx_xcvr_interface_tx_parallel_data        (dp_tx_parallel_data),
      .dp_tx_subsystem_dp_source_tx_xcvr_interface_tx_pll_powerdown        (),
      .dp_tx_subsystem_dp_source_tx_xcvr_interface_tx_analogreset          (),
      .dp_tx_subsystem_dp_source_tx_xcvr_interface_tx_digitalreset         (),
      .dp_tx_subsystem_dp_source_tx_xcvr_interface_tx_cal_busy             (dp_tx_cal_busy),
      .dp_tx_subsystem_dp_source_tx_xcvr_interface_tx_std_clkout           (gxb_tx_clkout),
      .dp_tx_subsystem_dp_source_tx_xcvr_interface_tx_pll_locked           (dp_txpll_locked),
      .dp_tx_subsystem_dp_core_i2c_board_i2c_serial_sda_in                 (),
      .dp_tx_subsystem_dp_core_i2c_board_i2c_serial_scl_in                 (),
      .dp_tx_subsystem_dp_core_i2c_board_i2c_serial_sda_oe                 (),
      .dp_tx_subsystem_dp_core_i2c_board_i2c_serial_scl_oe                 (),
      .dp_tx_subsystem_i2c_master_i2c_serial_sda_in                        (),
      .dp_tx_subsystem_i2c_master_i2c_serial_scl_in                        (),
      .dp_tx_subsystem_i2c_master_i2c_serial_sda_oe                        (),
      .dp_tx_subsystem_i2c_master_i2c_serial_scl_oe                        (),

      // DSC
      .dp_tx_subsystem_dp_source_tx_im_dsc_clk_clk(),
      .dp_tx_subsystem_dp_source_dsc_sync_clk_clk ()
   );

   // dp_tx_subsystem exports
   logic       rss_clk;
   logic [9:0] rss_refclk_cmd_bus_in;
   logic [9:0] rss_refclk_status_bus_out;
   logic [7:0] rss_refclk_fail_status;
   logic       rss_refclk_on_ack;
   logic [9:0] rss_refclk_on;

   logic [1:0] rss_req;
   logic [1:0] rss_grant;
   logic [1:0] rss_priority;

   // Not required as clocks are always stable.
   assign rss_priority              = '0;
   assign rss_refclk_status_bus_out = '0;
   assign rss_refclk_on             = 10'b0;

   // Agilex Global Shoreline Reset Sequencer (One Per Side)
   dp_gts_rss i_dp_gts_rss (
      .i_src_rs_priority         (rss_priority),
      .i_src_rs_req              (rss_req),
      .o_src_rs_grant            (rss_grant),
      .o_pma_cu_clk              (rss_clk),
      .i_src_rs_refclk_status_bus(rss_refclk_status_bus_out),
      .o_refclk_fail_status      (rss_refclk_fail_status),
      .o_refclk_on_ack           (rss_refclk_on_ack),
      .i_refclk_on               (rss_refclk_on),
      .o_src_rs_refclk_cmd_bus   (rss_refclk_cmd_bus_in)
   );

   // Phy
   dp_gts_tx i_dp_gts_tx (
      .refclk_150        (fgt_refclk_150),
      .mgmt_clock        (clock_subsystem_ref_clk),
      .mgmt_resetn       (~clock_subsystem_ref_rst & pio_board[1]),
      .rss_req           (rss_req),
      .rss_grant         (rss_grant),
      .rss_clk           (rss_clk),
      .tx_clk            (gxb_tx_clkout),
      .tx_p              (pin_dp_tx_p),
      .tx_n              (pin_dp_tx_n),
      .tx_rate_rcfg_busy (dp_tx_rate_rcfg_busy),
      .tx_link_rate      (dp_tx_link_rate),
      .tx_rate_rcfg_req  (dp_tx_rate_rcfg_req),
      .tx_rate_rcfg_ack  (dp_tx_rate_rcfg_ack),
      .tx_reconfig_en    (1'b1),
      .tx_analog_rcfg_req(dp_tx_analog_rcfg_req),
      .tx_analog_rcfg_ack(dp_tx_analog_rcfg_ack),
      .tx_analog_rcfg_vod(dp_tx_analog_rcfg_vod),
      .tx_analog_rcfg_emp(dp_tx_analog_rcfg_emp),
      .tx_parallel_data  (dp_tx_parallel_data),
      .tx_pll_locked     (dp_txpll_locked)
   );


endmodule

