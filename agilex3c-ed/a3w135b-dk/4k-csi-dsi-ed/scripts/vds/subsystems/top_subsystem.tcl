package require ::quartus::project

set script_dir [file dirname [file normalize [info script]]]
set project_dir [file normalize "${script_dir}/../../.."]

if {![is_project_open]} {
  cd $project_dir
  project_open top -revision top
}

source "${project_dir}/scripts/vds/lib/vds_helpers.tcl"

set EXPORT_REF_CLK 1
set EXPORT_GEN_CLKS 0
set EXPORT_DPTX_DSC 0

puts "top_subsystem: creating system"
::vh::new_system "top_subsystem"

# =============================================================================
# Subsystem instantiation
# =============================================================================

puts "top_subsystem: adding subsystems"
foreach s {
    clock_subsystem
    board_subsystem
    niosv_subsystem
    mipi_rx_subsystem
    isp_lite_in_subsystem
    isp_lite_subsystem
    isp_lite_out_subsystem
    emif_subsystem
    pre_dsi_subsystem
    mipi_dsi2_tx_subsystem
    dp_tx_subsystem
} {
  ::vh::system_cell $s
}

::vh::sync

# =============================================================================
# Clocks/reset wiring
# =============================================================================

puts "top_subsystem: wiring clock/resets"
# --- 100MHz cpu (ref) clock --------------------------------------------------
foreach {inst port} {
    niosv_subsystem         i_clk_cpu
    mipi_rx_subsystem       cpu_clk_in
    isp_lite_in_subsystem   cpu_clk_in
    isp_lite_subsystem      cpu_clk_in
    isp_lite_out_subsystem  cpu_clk_in
    emif_subsystem          cpu_clk_in
    pre_dsi_subsystem       cpu_clk_in
    mipi_dsi2_tx_subsystem  cpu_clk
    dp_tx_subsystem         mgmt_clk_in_clk
    board_subsystem         i_clk_board_data
} {
  ::vh::auto_connect {clock_subsystem o_ref_clk} [list $inst $port]
}

# --- reset for 100MHz clock -------------------------------------------------
foreach {inst port} {
    niosv_subsystem         i_reset_cpu
    mipi_rx_subsystem       cpu_rst_in
    isp_lite_in_subsystem   cpu_rst_in
    isp_lite_subsystem      cpu_rst_in
    isp_lite_out_subsystem  cpu_rst_in
    emif_subsystem          cpu_rst_in
    pre_dsi_subsystem       cpu_rst_in
    mipi_dsi2_tx_subsystem  cpu_rst
    dp_tx_subsystem         mgmt_rst_in_rst
    board_subsystem         i_rst_board_data
} {
  ::vh::auto_connect {clock_subsystem o_ref_rst} [list $inst $port]
}

# --- 148.5 MHz 4k30 (at 2 PIP) pixel clock -----------------------------------
::vh::auto_connect {clock_subsystem o_gen_clk_0_clk} {isp_lite_out_subsystem vid_clk_out}
::vh::auto_connect {clock_subsystem o_gen_clk_0_clk} {dp_tx_subsystem        vvp_clock_bridge_in_clk}
::vh::auto_connect {clock_subsystem o_gen_clk_0_rst} {isp_lite_out_subsystem vid_rst_out}
::vh::auto_connect {clock_subsystem o_gen_clk_0_rst} {dp_tx_subsystem        vvp_reset_bridge_in_reset}

# --- 297.0 MHz 4k30 (at 1 PIP) pixel clock -----------------------------------
foreach {inst port} {
    mipi_rx_subsystem       vid_clk_in
    isp_lite_in_subsystem   vid_clk_in
    isp_lite_subsystem      vid_clk_in
    isp_lite_out_subsystem  vid_clk_in
    pre_dsi_subsystem       main_clk_in
} {
  ::vh::auto_connect {clock_subsystem o_gen_clk_1_clk} [list $inst $port]
}
foreach {inst port} {
    mipi_rx_subsystem      vid_rst_in
    isp_lite_in_subsystem  vid_rst_in
    isp_lite_subsystem     vid_rst_in
    isp_lite_out_subsystem vid_rst_in
    pre_dsi_subsystem      main_rst_in
} {
  ::vh::auto_connect {clock_subsystem o_gen_clk_1_rst} [list $inst $port]
}

# --- 16 MHz DPTX aux clock ---------------------------------------------------
::vh::auto_connect {clock_subsystem o_gen_clk_2_clk} {dp_tx_subsystem clk_16_in_clk}
::vh::auto_connect {clock_subsystem o_gen_clk_2_rst} {dp_tx_subsystem rst_16_in_rst}
# --- board_subsystem -> clock_subsystem reference clock/reset ----------------
::vh::auto_connect {board_subsystem o_clk} {clock_subsystem i_ref_clk}
::vh::auto_connect {board_subsystem o_reset} {clock_subsystem i_ref_rst}

# --- emif_subsystem clock/ready fan-out --------------------------------------
::vh::auto_connect {emif_subsystem emif_clk_out}   {isp_lite_out_subsystem emif_clk_in}
::vh::auto_connect {emif_subsystem emif_clk_out}   {pre_dsi_subsystem      mem_clk_in}
::vh::auto_connect {emif_subsystem emif_ready_out} {isp_lite_out_subsystem emif_rst_in}
::vh::auto_connect {emif_subsystem emif_ready_out} {pre_dsi_subsystem      mem_rst_in}

# --- mipi_dsi2_tx_subsystem -> pre_dsi_subsystem TX clock/reset --------------
::vh::auto_connect {mipi_dsi2_tx_subsystem vid_mipi_clk} {pre_dsi_subsystem tx_clk_in}
::vh::auto_connect {mipi_dsi2_tx_subsystem vid_mipi_rst} {pre_dsi_subsystem tx_rst_in}

::vh::sync

# =============================================================================
# Video pipeline chain
# =============================================================================

puts "top_subsystem: wiring video pipeline"
::vh::auto_connect {mipi_rx_subsystem      mipi_csi2_m_vid_axis} {isp_lite_in_subsystem  mipi_csi2_0_s_vid_axis}
::vh::auto_connect {isp_lite_in_subsystem  isp_in_m_vid_axis}    {isp_lite_subsystem     isp_in_s_vid_axis}
::vh::auto_connect {isp_lite_subsystem     isp_out_m_vid_axis}   {isp_lite_out_subsystem vid_in}
::vh::auto_connect {isp_lite_out_subsystem vid_out}              {dp_tx_subsystem        dp_source_tx_axi4s_vid_in}
::vh::auto_connect {isp_lite_out_subsystem vid_out_2}            {pre_dsi_subsystem      vid_in}
::vh::auto_connect {pre_dsi_subsystem      vid_out_to_dsi}       {mipi_dsi2_tx_subsystem mipi_dsi2_0_vid_axis_in}

# =============================================================================
# Interrupts
# =============================================================================

puts "top_subsystem: wiring interrupts"
::vh::connect_if {niosv_subsystem ia_cpu_irq_receiver} {dp_tx_subsystem i2c_master_irq}
::vh::set_interrupt_irq {niosv_subsystem ia_cpu_irq_receiver} {dp_tx_subsystem i2c_master_irq} 0

::vh::connect_if {niosv_subsystem ia_cpu_irq_receiver} {dp_tx_subsystem dp_core_i2c_board_irq}
::vh::set_interrupt_irq {niosv_subsystem ia_cpu_irq_receiver} {dp_tx_subsystem dp_core_i2c_board_irq} 1

::vh::connect_if {niosv_subsystem ia_cpu_irq_receiver} {dp_tx_subsystem dp_source_tx_mgmt_interrupt}
::vh::set_interrupt_irq {niosv_subsystem ia_cpu_irq_receiver} {dp_tx_subsystem dp_source_tx_mgmt_interrupt} 2

::vh::connect_if {niosv_subsystem ia_cpu_irq_receiver} {mipi_rx_subsystem cam_i2c_irq}
::vh::set_interrupt_irq {niosv_subsystem ia_cpu_irq_receiver} {mipi_rx_subsystem cam_i2c_irq} 3

::vh::connect_if {niosv_subsystem ia_cpu_irq_receiver} {mipi_dsi2_tx_subsystem dsi_i2c_irq}
::vh::set_interrupt_irq {niosv_subsystem ia_cpu_irq_receiver} {mipi_dsi2_tx_subsystem dsi_i2c_irq} 4

# ===========================================================================
# CPU -> peripherals wiring
# ===========================================================================

puts "top_subsystem: wiring CPU avmm connections"
foreach {inst port} {
    mipi_rx_subsystem       mm_ctrl_in
    isp_lite_in_subsystem   mm_ctrl_in
    isp_lite_subsystem      mm_ctrl_in
    isp_lite_out_subsystem  mm_ctrl_in
    emif_subsystem          mm_ctrl_in
    pre_dsi_subsystem       cpu_mm_in
    mipi_dsi2_tx_subsystem  mm_ctrl_in
    dp_tx_subsystem         dp_source_tx_mgmt
} {
  ::vh::connect_if {niosv_subsystem o_cpu_mm_master} [list $inst $port]
}

# ===========================================================================
# VFBs -> EMIF wiring
# ===========================================================================

puts "top_subsystem: wiring VFB/EMIF connections"
::vh::auto_connect {isp_lite_out_subsystem av_mm_host_se_vfb} {pre_dsi_subsystem other_vfb_mem_in}
::vh::auto_connect {pre_dsi_subsystem      vfb_mem_host} {emif_subsystem    i_emif_s0_axi4}

::vh::sync

# ===========================================================================
# Exports
# ===========================================================================

puts "top_subsystem: exporting top-level pins/interfaces"

if {$EXPORT_REF_CLK} {
  foreach {port top_name} {
      o_ref_clk_export        clock_subsystem_o_ref_clk
      o_ref_rst_export        clock_subsystem_o_ref_rst
      o_iopll_0_locked_export clock_subsystem_o_iopll_0_locked
  } {
    ::vh::auto_export [list clock_subsystem $port] $top_name
  }
}

if {$EXPORT_GEN_CLKS} {
  set clock_subsystem_exports []

  set num_clks 3
  for {set i 0} {$i < $num_clks} {incr i} {
    lappend clock_subsystem_exports o_gen_clk_${i}_clk_export clock_subsystem_o_gen_clk_${i}_clk
    lappend clock_subsystem_exports o_gen_rst_${i}_clk_export clock_subsystem_o_gen_clk_${i}_rst
  }

  foreach {port top_name} $clock_subsystem_exports {
    ::vh::auto_export [list clock_subsystem $port] $top_name
  }
}

# --- board_subsystem -------------------------------------------------------
foreach {port top_name} {
    i_clk                board_subsystem_i_clk
    ia_reset_pb_n        board_subsystem_ia_reset_pb_n
    o_rst_device_ready   board_subsystem_o_rst_device_ready_export
    ia_pb                board_subsystem_ia_pb
    o_leds               board_subsystem_o_leds
} {
  ::vh::auto_export [list board_subsystem $port] $top_name
}

# --- mipi_rx_subsystem ------------------------------------------------------
foreach {port top_name} {
    cam_i2c_i2c_serial       mipi_rx_subsystem_cam_i2c_i2c_serial
    mipi_dphy_rzq            mipi_rx_subsystem_mipi_dphy_rzq
    mipi_dphy_ref_clk_0      mipi_rx_subsystem_mipi_dphy_ref_clk_0
    mipi_dphy_LINK0_dphy_io  mipi_rx_subsystem_mipi_dphy_LINK0_dphy_io
} {
  ::vh::auto_export [list mipi_rx_subsystem $port] $top_name
}

# --- emif_subsystem ----------------------------------------------------------
foreach {port top_name} {
    emif_cal_pio            emif_subsystem_emif_cal_pio
    emif_cal_done_rst_n     emif_subsystem_emif_cal_done_rst_n
    emif_rst_brdg_in        emif_subsystem_emif_rst_brdg_in
    i_clk_ddr4_emif_pll_ref emif_subsystem_i_clk_ddr4_emif_pll_ref
    c_ddr4_emif_oct         emif_subsystem_c_ddr4_emif_oct
    c_ddr4_emif_mem         emif_subsystem_c_ddr4_emif_mem
    c_ddr4_emif_ck0         emif_subsystem_c_ddr4_emif_ck0
    c_ddr4_emif_resetn      emif_subsystem_c_ddr4_emif_resetn
} {
  ::vh::auto_export [list emif_subsystem $port] $top_name
}

# --- mipi_dsi2_tx_subsystem --------------------------------------------------
foreach {port top_name} {
    mipi_dphy_rzq            mipi_dsi2_tx_subsystem_mipi_dphy_rzq
    mipi_dphy_ref_clk_0      mipi_dsi2_tx_subsystem_mipi_dphy_ref_clk_0
    mipi_dphy_LINK0_dphy_io  mipi_dsi2_tx_subsystem_mipi_dphy_LINK0_dphy_io
    dsi_i2c                  mipi_dsi2_tx_subsystem_dsi_i2c
} {
  ::vh::auto_export [list mipi_dsi2_tx_subsystem $port] $top_name
}

# --- dp_tx_subsystem ----------------------------------------------------------
foreach {port top_name} {
  i2c_master_i2c_serial        dp_tx_subsystem_i2c_master_i2c_serial
  dp_core_i2c_board_i2c_serial dp_tx_subsystem_dp_core_i2c_board_i2c_serial
  dp_core_board_pio            dp_tx_subsystem_dp_core_board_pio
  status_pio                   dp_tx_subsystem_status_pio
  supportd_fmats_pio           dp_tx_subsystem_supportd_fmats_pio
  curr_format_pio              dp_tx_subsystem_curr_format_pio
  format_ovrride_pio           dp_tx_subsystem_format_ovrride_pio
  dp_source_tx_xcvr_interface  dp_tx_subsystem_dp_source_tx_xcvr_interface
  dp_source_tx_aux             dp_tx_subsystem_dp_source_tx_aux
  dp_source_tx_analog_reconfig dp_tx_subsystem_dp_source_tx_analog_reconfig
  dp_source_tx_reconfig        dp_tx_subsystem_dp_source_tx_reconfig
  dp_source_tx_im_dsc_clk      dp_tx_subsystem_dp_source_tx_im_dsc_clk
  dp_source_dsc_sync_clk       dp_tx_subsystem_dp_source_dsc_sync_clk

} {
  ::vh::auto_export [list dp_tx_subsystem $port] $top_name
}

if {$EXPORT_DPTX_DSC} {
  foreach {port top_name} {
    dp_source_dsc_mgmt           dp_tx_subsystem_dp_source_dsc_mgmt
    dp_source_dsc_passthrough    dp_tx_subsystem_dp_source_dsc_passthrough
    dp_source_tx_im_dsc          dp_tx_subsystem_dp_source_tx_im_dsc
    dp_source_dsc_ctrl           dp_tx_subsystem_dp_source_dsc_ctrl
    dp_source_dsc_sync           dp_tx_subsystem_dp_source_dsc_sync
    dp_source_dsc_axi4s          dp_tx_subsystem_dp_source_dsc_axi4s
    dp_source_dsc_tx_tpg         dp_tx_subsystem_dp_source_dsc_tx_tpg
    dp_source_tx_im_dsc_clk      dp_tx_subsystem_dp_source_tx_im_dsc_clk
    dp_source_dsc_sync_clk       dp_tx_subsystem_dp_source_dsc_sync_clk

  } {
    ::vh::auto_export [list dp_tx_subsystem $port] $top_name
  }
}

puts "top_subsystem: assigning base addresses"
vds::assign_base_address

puts "top_subsystem: setting domain properties"

# Defaults to LUTRAM based, which takes up 1/5 of all ALMs on this device
::vh::set_domain_property \
  {pre_dsi_subsystem vfb_mem_host} \
  "qsys_mm.responseFifoType" \
  EMBEDDED_MEMORY_BASED

::vh::sync

puts "top_subsystem: build complete"
