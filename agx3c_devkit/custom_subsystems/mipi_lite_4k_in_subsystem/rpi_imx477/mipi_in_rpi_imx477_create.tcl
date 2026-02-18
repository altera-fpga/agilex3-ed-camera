###################################################################################
# Copyright (C) Altera Corporation
#
# This software and the related documents are Altera copyrighted materials, and
# your use of them is governed by the express license under which they were
# provided to you ("License"). Unless the License provides otherwise, you may
# not use, modify, copy, publish, distribute, disclose or transmit this software
# or the related documents without Altera's prior written permission.
#
# This software and the related documents are provided as is, with no express
# or implied warranties, other than those that are expressly stated in the License.
###################################################################################

set_shell_parameter SHELL_DESIGN_ROOT     ""
set_shell_parameter PROJECT_PATH          ""

set_shell_parameter CAM_I2C_MASTER_IRQ_PRIORITY  "X"
set_shell_parameter CAM_I2C_MASTER_IRQ_HOST      ""

set_shell_parameter AVMM_HOST             {{AUTO X}}

#-- Mipi connector options:
#-- Agilex 3: J21
set_shell_parameter CONNECTOR_NAME        "Y"

# General Video Controls
set_shell_parameter PIP                   {1}
set_shell_parameter VID_OUT_RATE          "p30"
set_shell_parameter EN_DEBUG              {0}


proc pre_creation_step {} {
    transfer_files
    evaluate_terp
}

proc creation_step {} {
    create_mipi_in_subsystem
}

proc post_creation_step {} {
    edit_top_level_qsys
    add_auto_connections
    edit_top_v_file
}

# resolve interdependencies
proc derive_parameters {param_array} {
    upvar $param_array p_array
    set drv_clock_subsystem_name ""

    for {set id 0} {$id < $p_array(project,id)} {incr id} {
        if {$p_array($id,type) == "clock"} {
            set params $p_array($id,params)

            foreach v_pair ${params} {
                set v_name  [lindex ${v_pair} 0]
                set v_value [lindex ${v_pair} 1]
                set v_temp_array(${v_name}) ${v_value}
            }

            if {[info exists v_temp_array(INSTANCE_NAME)]} {
                set drv_clock_subsystem_name $v_temp_array(INSTANCE_NAME)
                break
            }
        }
    }
    set_shell_parameter DRV_CLOCK_SUBSYSTEM_NAME ${drv_clock_subsystem_name}
}

proc transfer_files {} {
    set v_project_path      [get_shell_parameter PROJECT_PATH]
    set v_script_path       [get_shell_parameter SUBSYSTEM_SOURCE_PATH]
    set v_board_name        [get_shell_parameter DEVKIT]

    if {${v_board_name} == "AGX_5E_Si_Devkit"} {
        file_copy   ${v_script_path}/mipi_in_rpi_imx477_PremKit.qsf.terp \
                                              ${v_project_path}/quartus/user/mipi_in.qsf.terp
    } elseif {${v_board_name} == "AGX_5E_ARROW_Eagle_Devkit"} {
        file_copy   ${v_script_path}/mipi_in_rpi_imx477_ArrowKit.qsf.terp \
                                              ${v_project_path}/quartus/user/mipi_in.qsf.terp
    } elseif {${v_board_name} == "AGX_5E_MACNICA_Sulfur_Devkit"} {
        file_copy   ${v_script_path}/mipi_in_rpi_imx477_MacnicaKit.qsf.terp \
                                              ${v_project_path}/quartus/user/mipi_in.qsf.terp
    } elseif {${v_board_name} == "AGX_3C_Devkit"} {
        file_copy   ${v_script_path}/mipi_in_rpi_imx477_Agx3Kit.qsf.terp \
                                              ${v_project_path}/quartus/user/mipi_in.qsf.terp
    } else {
        send_message ERROR "IMX477 on ${v_board_name} not supported."
    }
    file_copy   ${v_script_path}/mipi_in_rpi_imx477.sdc \
                                              ${v_project_path}/sdc/user/mipi_in.sdc
}

proc evaluate_terp {} {
    set v_project_name    [get_shell_parameter PROJECT_NAME]
    set v_project_path    [get_shell_parameter PROJECT_PATH]
    set v_connector_name  [get_shell_parameter CONNECTOR_NAME]
    evaluate_terp_file  ${v_project_path}/quartus/user/mipi_in.qsf.terp   [list ${v_project_name} ${v_connector_name}] 0 1
}

proc create_mipi_in_subsystem {} {
    set v_quartus_version   [get_shell_parameter QUARTUS_VERSION]
    set v_project_path      [get_shell_parameter PROJECT_PATH]
    set v_instance_name     [get_shell_parameter INSTANCE_NAME]
    set v_board_name        [get_shell_parameter DEVKIT]
    set v_connector_name    [get_shell_parameter CONNECTOR_NAME]

    # CSI2 Video pipeline
    set v_mipi_pip          {get_shell_parameter PIP}
    set v_mipi_bps          {16}

    # video pipeline
    set v_cppp              {1}
    set v_bps               {12}
    set v_pip               [get_shell_parameter PIP]
    set v_vid_out_rate      [get_shell_parameter VID_OUT_RATE]

    # General
    set v_enable_debug      [get_shell_parameter EN_DEBUG]
    set v_pipeline_ready    {1}

    create_system ${v_instance_name}
    save_system   ${v_project_path}/rtl/user/${v_instance_name}.qsys
    load_system   ${v_project_path}/rtl/user/${v_instance_name}.qsys

    ############################
    #### Add Instances      ####
    ############################
    add_instance  mipi_in_cpu_clk_bridge          altera_clock_bridge
    add_instance  mipi_in_cpu_rst_bridge          altera_reset_bridge
    add_instance  mipi_in_vid_clk_bridge          altera_clock_bridge
    add_instance  mipi_in_vid_rst_bridge          altera_reset_bridge
    add_instance  mipi_in_mm_bridge               altera_avalon_mm_bridge
    add_instance  cam_i2c                         altera_avalon_i2c
    add_instance  mipi_in_mipi_dphy               mipi_dphy
    add_instance  mipi_in_mipi_csi2               intel_mipi_csi2
    add_instance  mipi_in_proto_conv              intel_vvp_protocol_conv

    ############################
    #### Set Parameters     ####
    ############################
    # mipi_in_cpu_clk_bridge
    set_instance_parameter_value    mipi_in_cpu_clk_bridge      EXPLICIT_CLOCK_RATE     {100000000.0}
    set_instance_parameter_value    mipi_in_cpu_clk_bridge      NUM_CLOCK_OUTPUTS       {1}

    # mipi_in_cpu_rst_bridge
    set_instance_parameter_value    mipi_in_cpu_rst_bridge      ACTIVE_LOW_RESET        {0}
    set_instance_parameter_value    mipi_in_cpu_rst_bridge      NUM_RESET_OUTPUTS       {1}
    set_instance_parameter_value    mipi_in_cpu_rst_bridge      SYNCHRONOUS_EDGES       {deassert}
    set_instance_parameter_value    mipi_in_cpu_rst_bridge      SYNC_RESET              {0}
    set_instance_parameter_value    mipi_in_cpu_rst_bridge      USE_RESET_REQUEST       {0}

    set_instance_parameter_value    mipi_in_vid_clk_bridge      EXPLICIT_CLOCK_RATE     {297000000.0}
    set_instance_parameter_value    mipi_in_vid_clk_bridge      NUM_CLOCK_OUTPUTS       {1}

    # mipi_in_vid_rst_bridge
    set_instance_parameter_value    mipi_in_vid_rst_bridge      ACTIVE_LOW_RESET        {0}
    set_instance_parameter_value    mipi_in_vid_rst_bridge      NUM_RESET_OUTPUTS       {1}
    set_instance_parameter_value    mipi_in_vid_rst_bridge      SYNCHRONOUS_EDGES       {deassert}
    set_instance_parameter_value    mipi_in_vid_rst_bridge      SYNC_RESET              {0}
    set_instance_parameter_value    mipi_in_vid_rst_bridge      USE_RESET_REQUEST       {0}

    # mipi_in_mm_bridge
    set_instance_parameter_value    mipi_in_mm_bridge     ADDRESS_UNITS                 {SYMBOLS}
    set_instance_parameter_value    mipi_in_mm_bridge     ADDRESS_WIDTH                 {14}
    set_instance_parameter_value    mipi_in_mm_bridge     DATA_WIDTH                    {32}
    set_instance_parameter_value    mipi_in_mm_bridge     LINEWRAPBURSTS                {0}
    set_instance_parameter_value    mipi_in_mm_bridge     M0_WAITREQUEST_ALLOWANCE      {0}
    set_instance_parameter_value    mipi_in_mm_bridge     MAX_BURST_SIZE                {1}
    set_instance_parameter_value    mipi_in_mm_bridge     MAX_PENDING_RESPONSES         {4}
    set_instance_parameter_value    mipi_in_mm_bridge     MAX_PENDING_WRITES            {0}
    set_instance_parameter_value    mipi_in_mm_bridge     PIPELINE_COMMAND              {1}
    set_instance_parameter_value    mipi_in_mm_bridge     PIPELINE_RESPONSE             {1}
    set_instance_parameter_value    mipi_in_mm_bridge     S0_WAITREQUEST_ALLOWANCE      {0}
    set_instance_parameter_value    mipi_in_mm_bridge     SYMBOL_WIDTH                  {8}
    set_instance_parameter_value    mipi_in_mm_bridge     SYNC_RESET                    {1}
    set_instance_parameter_value    mipi_in_mm_bridge     USE_AUTO_ADDRESS_WIDTH        {1}
    set_instance_parameter_value    mipi_in_mm_bridge     USE_RESPONSE                  {0}
    set_instance_parameter_value    mipi_in_mm_bridge     USE_WRITERESPONSE             {0}

    # i2c_master
    set_instance_parameter_value    cam_i2c               FIFO_DEPTH                    {32}
    set_instance_parameter_value    cam_i2c               USE_AV_ST                     {0}

    # mipi_in_mipi_dphy
    if {${v_board_name} == "AGX_5E_ARROW_Eagle_Devkit"} {
        set v_ref_clk_freq {25.0}
        set v_vco_clk_freq {600.0}
        if { ${v_connector_name} == "Y"} {
            set v_byte_loc 1
        } elseif { ${v_connector_name} == "X"} {
            set v_byte_loc 5
        } else {
            send_message ERROR "Mipi Connector ${v_connector_name} not supported for ${v_board_name}"
        }
    } elseif {${v_board_name} == "AGX_5E_MACNICA_Sulfur_Devkit"} {
        set v_ref_clk_freq {125.0}
        set v_vco_clk_freq {625.0}
        if { ${v_connector_name} == "3"} {
            set v_byte_loc 1
        } elseif { ${v_connector_name} == "4"} {
            set v_byte_loc 0
        } else {
            send_message ERROR "Mipi Connector ${v_connector_name} not supported for ${v_board_name}"
        }
    } elseif {${v_board_name} == "AGX_3C_Devkit"} {
        set v_ref_clk_freq {150.0}
        set v_vco_clk_freq {600.0}
        if { ${v_connector_name} == "J21"} {
            set v_byte_loc 4
        } else {
            send_message ERROR "Mipi Connector ${v_connector_name} not supported for ${v_board_name}"
        }
    } else {
        #-- Premkit or anything else that uses IMX477
        set v_ref_clk_freq {100.0}
        set v_vco_clk_freq {600.0}
        set v_byte_loc 1
    }

    #-- We have to set the CSI-2's continuous clock setting in 24.3 or else we get a spurious clock input.
    if {${v_quartus_version} != 24.2} {
        set v_continuous_clk 1
    } else {
        set v_continuous_clk 0
    }

    set_instance_parameter_value    mipi_in_mipi_dphy   GUI_ALT_CAL_EN_0                        {0}
    set_instance_parameter_value    mipi_in_mipi_dphy   GUI_ALT_CAL_LEN                         {65536}
    set_instance_parameter_value    mipi_in_mipi_dphy   GUI_BIT_RATE_MBPS_RNG_0                 {1500.0}
    set_instance_parameter_value    mipi_in_mipi_dphy   GUI_BYTE_LOC_0                          ${v_byte_loc}
    set_instance_parameter_value    mipi_in_mipi_dphy   GUI_CONTINUOUS_CLK_0                    {0}
    set_instance_parameter_value    mipi_in_mipi_dphy   GUI_CORE_CLK_DIV_0                      {8}
    set_instance_parameter_value    mipi_in_mipi_dphy   GUI_CORE_CLK_DIV_1                      {8}
    set_instance_parameter_value    mipi_in_mipi_dphy   GUI_DPHY_IP_ROLE_0                      {0}
    set_instance_parameter_value    mipi_in_mipi_dphy   GUI_NUM_LANES_0                         {2}
    set_instance_parameter_value    mipi_in_mipi_dphy   GUI_NUM_PLL                             {1}
    set_instance_parameter_value    mipi_in_mipi_dphy   GUI_PER_SKEW_CAL_EN_0                   {0}
    set_instance_parameter_value    mipi_in_mipi_dphy   GUI_PPI_WIDTH_USR_0                     {16}
    set_instance_parameter_value    mipi_in_mipi_dphy   GUI_PREAMBLE_EN_0                       {0}
    set_instance_parameter_value    mipi_in_mipi_dphy   GUI_REF_CLK_FREQ_MHZ_0                  ${v_ref_clk_freq}
    set_instance_parameter_value    mipi_in_mipi_dphy   GUI_REF_CLK_FREQ_MHZ_1                  {20.0}
    set_instance_parameter_value    mipi_in_mipi_dphy   GUI_REF_CLK_IO_0                        {3}
    set_instance_parameter_value    mipi_in_mipi_dphy   GUI_REF_CLK_IO_1                        {0}
    set_instance_parameter_value    mipi_in_mipi_dphy   GUI_REF_CLK_IO_SHARE                    {1}
    set_instance_parameter_value    mipi_in_mipi_dphy   GUI_RX_AUTO_TYPE_0                      {2}
    set_instance_parameter_value    mipi_in_mipi_dphy   GUI_RX_BIT_RATE_MBPS_SEL_0              {64}
    set_instance_parameter_value    mipi_in_mipi_dphy   GUI_RX_CLK_LOSS_DETECT_0                {3}
    set_instance_parameter_value    mipi_in_mipi_dphy   GUI_RX_CLK_LOSS_DETECT_0_AUTO_BOOL      {1}
    set_instance_parameter_value    mipi_in_mipi_dphy   GUI_RX_CLK_POST_0                       {1}
    set_instance_parameter_value    mipi_in_mipi_dphy   GUI_RX_CLK_SETTLE_0                     {7}
    set_instance_parameter_value    mipi_in_mipi_dphy   GUI_RX_CLK_SETTLE_0_AUTO_BOOL           {1}
    set_instance_parameter_value    mipi_in_mipi_dphy   GUI_RX_DLANE_DESKEW_DELAY_0_0           {48}
    set_instance_parameter_value    mipi_in_mipi_dphy   GUI_RX_DLANE_DESKEW_DELAY_1_0           {48}
    set_instance_parameter_value    mipi_in_mipi_dphy   GUI_RX_DLANE_DESKEW_DELAY_2_0           {48}
    set_instance_parameter_value    mipi_in_mipi_dphy   GUI_RX_DLANE_DESKEW_DELAY_3_0           {48}
    set_instance_parameter_value    mipi_in_mipi_dphy   GUI_RX_DLANE_DESKEW_DELAY_4_0           {0}
    set_instance_parameter_value    mipi_in_mipi_dphy   GUI_RX_DLANE_DESKEW_DELAY_5_0           {0}
    set_instance_parameter_value    mipi_in_mipi_dphy   GUI_RX_DLANE_DESKEW_DELAY_6_0           {0}
    set_instance_parameter_value    mipi_in_mipi_dphy   GUI_RX_DLANE_DESKEW_DELAY_7_0           {0}
    set_instance_parameter_value    mipi_in_mipi_dphy   GUI_RX_HS_SETTLE_0                      {2}
    set_instance_parameter_value    mipi_in_mipi_dphy   GUI_RX_HS_SETTLE_0_AUTO_BOOL            {1}
    set_instance_parameter_value    mipi_in_mipi_dphy   GUI_RX_INIT_0                           {12}
    set_instance_parameter_value    mipi_in_mipi_dphy   GUI_RX_INIT_0_AUTO_BOOL                 {1}
    set_instance_parameter_value    mipi_in_mipi_dphy   GUI_RX_PREP_TIME_TM_0                   {0}
    set_instance_parameter_value    mipi_in_mipi_dphy   GUI_RX_TIMING_RW_0                      {1}
    set_instance_parameter_value    mipi_in_mipi_dphy   GUI_RX_TM_CONTROL_RX_TM_EN_0            {0}
    set_instance_parameter_value    mipi_in_mipi_dphy   GUI_RX_TM_CONTROL_RX_TM_LOOPBACK_MODE_0 {0}
    set_instance_parameter_value    mipi_in_mipi_dphy   GUI_RZQ_ID                              {1}
    set_instance_parameter_value    mipi_in_mipi_dphy   GUI_SKEW_CAL_EN_0                       {0}
    set_instance_parameter_value    mipi_in_mipi_dphy   GUI_SKEW_CAL_LEN                        {32768}
    set_instance_parameter_value    mipi_in_mipi_dphy   GUI_SOURCE_PLL_0                        {0}
    set_instance_parameter_value    mipi_in_mipi_dphy   GUI_TM_EN_0                             {0}
    set_instance_parameter_value    mipi_in_mipi_dphy   GUI_TM_LOOPBACK_MODE_0                  {0}
    set_instance_parameter_value    mipi_in_mipi_dphy   GUI_VCO_FREQ_MHZ_0                      ${v_vco_clk_freq}
    set_instance_parameter_value    mipi_in_mipi_dphy   GUI_VCO_FREQ_MHZ_1                      {600.0}

    # mipi_in_mipi_csi2
    set_instance_parameter_value    mipi_in_mipi_csi2   BITS_PER_LANE                           ${v_mipi_bps}
    set_instance_parameter_value    mipi_in_mipi_csi2   BUFFER_DEPTH                            {4096}
    set_instance_parameter_value    mipi_in_mipi_csi2   DIRECTION                               {rx}
    set_instance_parameter_value    mipi_in_mipi_csi2   ENABLE_ED_FILESET_SIM                   {0}
    set_instance_parameter_value    mipi_in_mipi_csi2   ENABLE_ED_FILESET_SYNTHESIS             {1}
    set_instance_parameter_value    mipi_in_mipi_csi2   ENABLE_SCRAMBLING                       {0}
    set_instance_parameter_value    mipi_in_mipi_csi2   LANE                                    {2}
    set_instance_parameter_value    mipi_in_mipi_csi2   NUMBER_OF_VIDEO_STREAMING_INTERFACES    {1}
    set_instance_parameter_value    mipi_in_mipi_csi2   PIXELS_IN_PARALLEL                      {1}
    set_instance_parameter_value    mipi_in_mipi_csi2   SELECT_CUSTOM_DEVICE                    {0}
    set_instance_parameter_value    mipi_in_mipi_csi2   SELECT_ED_FILESET                       {VERILOG}
    set_instance_parameter_value    mipi_in_mipi_csi2   SELECT_SUPPORTED_VARIANT                {1}
    set_instance_parameter_value    mipi_in_mipi_csi2   SELECT_TARGETED_BOARD                   {0}
    set_instance_parameter_value    mipi_in_mipi_csi2   SUPPORT_LEGACY_YUV420_8B                {0}
    set_instance_parameter_value    mipi_in_mipi_csi2   SUPPORT_RAW10                           {0}
    set_instance_parameter_value    mipi_in_mipi_csi2   SUPPORT_RAW12                           {1}
    set_instance_parameter_value    mipi_in_mipi_csi2   SUPPORT_RAW14                           {0}
    set_instance_parameter_value    mipi_in_mipi_csi2   SUPPORT_RAW16                           {0}
    set_instance_parameter_value    mipi_in_mipi_csi2   SUPPORT_RAW20                           {0}
    set_instance_parameter_value    mipi_in_mipi_csi2   SUPPORT_RAW24                           {0}
    set_instance_parameter_value    mipi_in_mipi_csi2   SUPPORT_RAW6                            {0}
    set_instance_parameter_value    mipi_in_mipi_csi2   SUPPORT_RAW7                            {0}
    set_instance_parameter_value    mipi_in_mipi_csi2   SUPPORT_RAW8                            {0}
    set_instance_parameter_value    mipi_in_mipi_csi2   SUPPORT_RGB444                          {0}
    set_instance_parameter_value    mipi_in_mipi_csi2   SUPPORT_RGB555                          {0}
    set_instance_parameter_value    mipi_in_mipi_csi2   SUPPORT_RGB565                          {0}
    set_instance_parameter_value    mipi_in_mipi_csi2   SUPPORT_RGB666                          {0}
    set_instance_parameter_value    mipi_in_mipi_csi2   SUPPORT_RGB888                          {0}
    set_instance_parameter_value    mipi_in_mipi_csi2   SUPPORT_YUV420_10B                      {0}
    set_instance_parameter_value    mipi_in_mipi_csi2   SUPPORT_YUV420_8B                       {0}
    set_instance_parameter_value    mipi_in_mipi_csi2   SUPPORT_YUV422_10B                      {0}
    set_instance_parameter_value    mipi_in_mipi_csi2   SUPPORT_YUV422_8B                       {0}
    set_instance_parameter_value    mipi_in_mipi_csi2   ENABLE_ECC                              {0}
    set_instance_parameter_value    mipi_in_mipi_csi2   ENABLE_CRC                              {0}
    set_instance_parameter_value    mipi_in_mipi_csi2   ENABLE_CSR                              {0}
    set_instance_parameter_value    mipi_in_mipi_csi2   USE_CONTINUOUS_CLK                      ${v_continuous_clk}
    set_instance_parameter_value    mipi_in_mipi_csi2   VIDEO_INTERFACE_MODE                    {simple}

    # mipi_in_proto_conv
    set_instance_parameter_value    mipi_in_proto_conv   BPS                         ${v_bps}
    set_instance_parameter_value    mipi_in_proto_conv   CHROMA_SAMPLING             {444}
    set_instance_parameter_value    mipi_in_proto_conv   CHROMA_SITING               {TOP_LEFT}
    set_instance_parameter_value    mipi_in_proto_conv   CLIP_LONG_FIELDS            {0}
    set_instance_parameter_value    mipi_in_proto_conv   COLOR_SPACE                 {RGB}
    set_instance_parameter_value    mipi_in_proto_conv   C_OMNI_CAP_ID_ASSOCIATED    {0}
    set_instance_parameter_value    mipi_in_proto_conv   C_OMNI_CAP_ID_COMPONENT     {0}
    set_instance_parameter_value    mipi_in_proto_conv   C_OMNI_CAP_IRQ              {255}
    set_instance_parameter_value    mipi_in_proto_conv   C_OMNI_CAP_IRQ_ENABLE       {0}
    set_instance_parameter_value    mipi_in_proto_conv   C_OMNI_CAP_IRQ_ENABLE_EN    {0}
    set_instance_parameter_value    mipi_in_proto_conv   C_OMNI_CAP_IRQ_STATUS       {0}
    set_instance_parameter_value    mipi_in_proto_conv   C_OMNI_CAP_IRQ_STATUS_EN    {0}
    set_instance_parameter_value    mipi_in_proto_conv   C_OMNI_CAP_TAG              {0}
    set_instance_parameter_value    mipi_in_proto_conv   C_OMNI_CAP_TYPE             {573}
    set_instance_parameter_value    mipi_in_proto_conv   C_OMNI_CAP_VERSION          {1}
    set_instance_parameter_value    mipi_in_proto_conv   ENABLE_DEBUG                ${v_enable_debug}
    set_instance_parameter_value    mipi_in_proto_conv   ENABLE_TIMEOUT              {0}
    set_instance_parameter_value    mipi_in_proto_conv   ENABLE_YCBCR_SWAP           {0}
    set_instance_parameter_value    mipi_in_proto_conv   INPUT_MODE                  {INTERNAL}
    set_instance_parameter_value    mipi_in_proto_conv   NUMBER_OF_COLOR_PLANES      ${v_cppp}
    set_instance_parameter_value    mipi_in_proto_conv   OUTPUT_MODE                 {EXTERNAL}
    set_instance_parameter_value    mipi_in_proto_conv   PIPELINE_READY              ${v_pipeline_ready}
    set_instance_parameter_value    mipi_in_proto_conv   PIXELS_IN_PARALLEL          {1}
    set_instance_parameter_value    mipi_in_proto_conv   RUNTIME_CONTROL             {0}
    set_instance_parameter_value    mipi_in_proto_conv   SEPARATE_SLAVE_CLOCK        {0}
    set_instance_parameter_value    mipi_in_proto_conv   SLAVE_PROTOCOL              {Avalon}
    set_instance_parameter_value    mipi_in_proto_conv   VIP_USER_SUPPORT            {DISCARD}
    set_instance_parameter_value    mipi_in_proto_conv   VVP_USER_SUPPORT            {NONE_ALLOWED}

    ############################
    #### Create Connections ####
    ############################
    # mipi_in_cpu_clk_bridge
    add_connection      mipi_in_cpu_clk_bridge.out_clk        mipi_in_cpu_rst_bridge.clk
    add_connection      mipi_in_cpu_clk_bridge.out_clk        mipi_in_mm_bridge.clk
    add_connection      mipi_in_cpu_clk_bridge.out_clk        cam_i2c.clock
    add_connection      mipi_in_cpu_clk_bridge.out_clk        mipi_in_mipi_dphy.reg_clk

    # mipi_in_cpu_rst_bridge
    add_connection      mipi_in_cpu_rst_bridge.out_reset      mipi_in_mm_bridge.reset
    add_connection      mipi_in_cpu_rst_bridge.out_reset      cam_i2c.reset_sink
    add_connection      mipi_in_cpu_rst_bridge.out_reset      mipi_in_mipi_dphy.reg_srst
    add_connection      mipi_in_cpu_rst_bridge.out_reset      mipi_in_mipi_dphy.arst

    # mipi_in_vid_clk_bridge
    add_connection      mipi_in_vid_clk_bridge.out_clk        mipi_in_vid_rst_bridge.clk
    add_connection      mipi_in_vid_clk_bridge.out_clk        mipi_in_mipi_csi2.axi4s_clk
    add_connection      mipi_in_vid_clk_bridge.out_clk        mipi_in_proto_conv.main_clock

    # mipi_in_vid_rst_bridge
    add_connection      mipi_in_vid_rst_bridge.out_reset      mipi_in_mipi_csi2.axi4s_rst
    add_connection      mipi_in_vid_rst_bridge.out_reset      mipi_in_proto_conv.main_reset

    # mipi_in_mm_bridge
    add_connection      mipi_in_mm_bridge.m0                  mipi_in_mipi_dphy.axi_lite
    add_connection      mipi_in_mm_bridge.m0                  cam_i2c.csr

    # mipi_in_mipi_dphy
    add_connection      mipi_in_mipi_dphy.LINK0_D0_ppi_rx_hs_clk      mipi_in_mipi_csi2.d0_ppi_hs_clk
    add_connection      mipi_in_mipi_dphy.LINK0_D0_ppi_rx_hs_srst     mipi_in_mipi_csi2.d0_ppi_rx_hs_srst
    add_connection      mipi_in_mipi_dphy.LINK0_D0_ppi_ctrl           mipi_in_mipi_csi2.d0_ppi_ctrl

    add_connection      mipi_in_mipi_dphy.LINK0_D1_ppi_rx_hs_clk      mipi_in_mipi_csi2.d1_ppi_hs_clk
    add_connection      mipi_in_mipi_dphy.LINK0_D1_ppi_rx_hs_srst     mipi_in_mipi_csi2.d1_ppi_rx_hs_srst
    add_connection      mipi_in_mipi_dphy.LINK0_D1_ppi_ctrl           mipi_in_mipi_csi2.d1_ppi_ctrl

    add_connection      mipi_in_mipi_dphy.LINK0_CK_ppi_rx_hs_clk      mipi_in_mipi_csi2.ck_ppi_hs_clk
    add_connection      mipi_in_mipi_dphy.LINK0_CK_ppi_rx_hs_srst     mipi_in_mipi_csi2.ck_ppi_rx_hs_srst
    add_connection      mipi_in_mipi_dphy.LINK0_CK_ppi_ctrl           mipi_in_mipi_csi2.ck_ppi_ctrl

    # mipi_in_mipi_csi2
    add_connection      mipi_in_mipi_csi2.d0_ppi_hs                   mipi_in_mipi_dphy.LINK0_D0_ppi_rx_hs
    add_connection      mipi_in_mipi_csi2.d0_ppi_lp                   mipi_in_mipi_dphy.LINK0_D0_ppi_rx_lp
    add_connection      mipi_in_mipi_csi2.i_d0_ppi_rx_err             mipi_in_mipi_dphy.LINK0_D0_ppi_rx_err

    add_connection      mipi_in_mipi_csi2.d1_ppi_hs                   mipi_in_mipi_dphy.LINK0_D1_ppi_rx_hs
    add_connection      mipi_in_mipi_csi2.d1_ppi_lp                   mipi_in_mipi_dphy.LINK0_D1_ppi_rx_lp
    add_connection      mipi_in_mipi_csi2.i_d1_ppi_rx_err             mipi_in_mipi_dphy.LINK0_D1_ppi_rx_err
    add_connection      mipi_in_mipi_csi2.ck_ppi_hs                   mipi_in_mipi_dphy.LINK0_CK_ppi_rx_hs
    add_connection      mipi_in_mipi_csi2.ck_ppi_lp                   mipi_in_mipi_dphy.LINK0_CK_ppi_rx_lp
    add_connection      mipi_in_mipi_csi2.i_ck_ppi_rx_err             mipi_in_mipi_dphy.LINK0_CK_ppi_rx_err

    # mipi_in_proto_conv
    add_connection      mipi_in_mipi_csi2.video_streaming_interface_0     mipi_in_proto_conv.axi4s_vid_in

    ##########################
    ##### Create Exports #####
    ##########################
    # mipi_in_cpu_clk_bridge
    add_interface           cpu_clk_in                clock       sink
    set_interface_property  cpu_clk_in                EXPORT_OF   mipi_in_cpu_clk_bridge.in_clk

    # mipi_in_cpu_rst_bridge
    add_interface           cpu_rst_in                reset       sink
    set_interface_property  cpu_rst_in                EXPORT_OF   mipi_in_cpu_rst_bridge.in_reset

    # mipi_in_vid_clk_bridge
    add_interface           vid_clk_in                clock       sink
    set_interface_property  vid_clk_in                EXPORT_OF   mipi_in_vid_clk_bridge.in_clk

    # mipi_in_vid_rst_bridge
    add_interface           vid_rst_in                reset       sink
    set_interface_property  vid_rst_in                EXPORT_OF   mipi_in_vid_rst_bridge.in_reset

    # mipi_in_mm_bridge
    add_interface           mm_ctrl_in                avalon      slave
    set_interface_property  mm_ctrl_in                EXPORT_OF   mipi_in_mm_bridge.s0

    # mipi_in_mipi_dphy
    add_interface           reg_bus                   conduit     end
    set_interface_property  reg_bus                   EXPORT_OF   mipi_in_mipi_dphy.reg_bus

    add_interface           mipi_dphy_rzq             conduit     end
    set_interface_property  mipi_dphy_rzq             EXPORT_OF   mipi_in_mipi_dphy.rzq

    add_interface           mipi_dphy_ref_clk_0       clock       sink
    set_interface_property  mipi_dphy_ref_clk_0       EXPORT_OF   mipi_in_mipi_dphy.ref_clk_0

    add_interface           mipi_dphy_LINK0_dphy_io   conduit     end
    set_interface_property  mipi_dphy_LINK0_dphy_io   EXPORT_OF   mipi_in_mipi_dphy.LINK0_dphy_io

    # mipi_in_proto_conv
    add_interface           mipi_csi2_m_vid_axis      axi4stream  manager
    set_interface_property  mipi_csi2_m_vid_axis      EXPORT_OF   mipi_in_proto_conv.axi4s_vid_out

    # i2c_master
    add_interface             cam_i2c_i2c_serial      conduit     end
    set_interface_property    cam_i2c_i2c_serial      export_of   cam_i2c.i2c_serial

    add_interface             cam_i2c_irq             interrupt   sender
    set_interface_property    cam_i2c_irq             export_of   cam_i2c.interrupt_sender

    ##### Sync / Validation     #####
    ##### Assign Base Addresses #####
    sync_sysinfo_parameters
    auto_assign_system_base_addresses
    save_system
}

proc edit_top_level_qsys {} {
    set v_project_name  [get_shell_parameter PROJECT_NAME]
    set v_project_path  [get_shell_parameter PROJECT_PATH]
    set v_instance_name [get_shell_parameter INSTANCE_NAME]

    load_system ${v_project_path}/rtl/${v_project_name}_qsys.qsys
    add_instance ${v_instance_name} ${v_instance_name}

    # i2c_master
    add_interface             "${v_instance_name}_cam_i2c_i2c_serial"            conduit   end
    set_interface_property    "${v_instance_name}_cam_i2c_i2c_serial" \
                              export_of   ${v_instance_name}.cam_i2c_i2c_serial

    add_interface           mipi_dphy_rzq               conduit     end
    set_interface_property  mipi_dphy_rzq               EXPORT_OF   ${v_instance_name}.mipi_dphy_rzq

    add_interface           mipi_dphy_ref_clk_0         clock       sink
    set_interface_property  mipi_dphy_ref_clk_0         EXPORT_OF   ${v_instance_name}.mipi_dphy_ref_clk_0

    add_interface           mipi_dphy_LINK0_dphy_io     conduit     end
    set_interface_property  mipi_dphy_LINK0_dphy_io     EXPORT_OF   ${v_instance_name}.mipi_dphy_LINK0_dphy_io

    sync_sysinfo_parameters
    save_system
}

proc add_auto_connections {} {
    set v_instance_name           [get_shell_parameter INSTANCE_NAME]
    set v_avmm_host               [get_shell_parameter AVMM_HOST]
    set v_vid_out_rate            [get_shell_parameter VID_OUT_RATE]
    set v_pip                     [get_shell_parameter PIP]
    set v_i2c_irq_master_priority [get_shell_parameter CAM_I2C_MASTER_IRQ_PRIORITY]
    set v_i2c_irq_master_host     [get_shell_parameter CAM_I2C_MASTER_IRQ_HOST]

    if {(${v_i2c_irq_master_host} != "NONE") && (${v_i2c_irq_master_host} != "")} {
        add_irq_connection ${v_instance_name} "cam_i2c_irq" \
                                              ${v_i2c_irq_master_priority} ${v_i2c_irq_master_host}_irq
    }

    add_auto_connection   ${v_instance_name}    cpu_clk_in          100000000
    add_auto_connection   ${v_instance_name}    cpu_rst_in          100000000
    add_auto_connection   ${v_instance_name}    vid_clk_in          297000000
    add_auto_connection   ${v_instance_name}    vid_rst_in          297000000

    # to isp in
    add_auto_connection   ${v_instance_name}    mipi_csi2_m_vid_axis    mipi_csi2_0_vid_axis
    # HPS to mm bridge
    add_avmm_connections  mm_ctrl_in    ${v_avmm_host}
}

proc edit_top_v_file {} {
    set v_drv_clock_subsystem_name  [get_shell_parameter DRV_CLOCK_SUBSYSTEM_NAME]
    set v_vid_out_rate              [get_shell_parameter VID_OUT_RATE]
    set v_board_name                [get_shell_parameter DEVKIT]
    set time_seconds                [clock seconds]
    set v_instance_name             [get_shell_parameter INSTANCE_NAME]

    add_top_port_list input   ""          "mipi_dphy_rzq"
    add_top_port_list input   ""          "mipi_dphy_ref_clk"
    add_top_port_list input   "\[1:0\]"   "LINK0_dphy_io_dphy_link_d_p"
    add_top_port_list input   "\[1:0\]"   "LINK0_dphy_io_dphy_link_d_n"
    add_top_port_list input   ""          "LINK0_dphy_io_dphy_link_c_p"
    add_top_port_list input   ""          "LINK0_dphy_io_dphy_link_c_n"
    add_top_port_list inout   ""          "cam_i2c_scl"
    add_top_port_list inout   ""          "cam_i2c_sda"
    add_top_port_list output  ""          "cam_power_en"
    add_top_port_list output  ""          "cam_led_en"

    add_declaration_list wire   ""    "cam_i2c_scl_oe"
    add_declaration_list wire   ""    "cam_i2c_sda_oe"
    add_declaration_list wire   ""    "cam_i2c_scl_in"
    add_declaration_list wire   ""    "cam_i2c_sda_in"

    add_qsys_inst_exports_list  ${v_instance_name}_cam_i2c_i2c_serial_sda_in           cam_i2c_sda_in
    add_qsys_inst_exports_list  ${v_instance_name}_cam_i2c_i2c_serial_scl_in           cam_i2c_scl_in
    add_qsys_inst_exports_list  ${v_instance_name}_cam_i2c_i2c_serial_sda_oe           cam_i2c_sda_oe
    add_qsys_inst_exports_list  ${v_instance_name}_cam_i2c_i2c_serial_scl_oe           cam_i2c_scl_oe

    add_qsys_inst_exports_list    mipi_dphy_rzq_rzq                       mipi_dphy_rzq
    add_qsys_inst_exports_list    mipi_dphy_ref_clk_0_clk                 mipi_dphy_ref_clk
    add_qsys_inst_exports_list    mipi_dphy_LINK0_dphy_io_dphy_link_dp    LINK0_dphy_io_dphy_link_d_p
    add_qsys_inst_exports_list    mipi_dphy_LINK0_dphy_io_dphy_link_dn    LINK0_dphy_io_dphy_link_d_n
    add_qsys_inst_exports_list    mipi_dphy_LINK0_dphy_io_dphy_link_cp    LINK0_dphy_io_dphy_link_c_p
    add_qsys_inst_exports_list    mipi_dphy_LINK0_dphy_io_dphy_link_cn    LINK0_dphy_io_dphy_link_c_n

    add_assignments_list    "cam_i2c_scl_in"              "cam_i2c_scl"
    add_assignments_list    "cam_i2c_sda_in"              "cam_i2c_sda"
    add_assignments_list    "cam_i2c_scl"                 "cam_i2c_scl_oe ? 1'b0 : 1'bz"
    add_assignments_list    "cam_i2c_sda"                 "cam_i2c_sda_oe ? 1'b0 : 1'bz"
    add_assignments_list    "cam_power_en"                "1'b1"
    add_assignments_list    "cam_led_en"                  "1'b1"
}
