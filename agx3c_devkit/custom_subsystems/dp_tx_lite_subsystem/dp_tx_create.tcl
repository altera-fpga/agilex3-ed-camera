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

# create script specific parameters and default values

set_shell_parameter AVMM_HOST                     {{AUTO X}}

set_shell_parameter VID_OUT_BPS                   {10}

set_shell_parameter I2C_MASTER_IRQ_PRIORITY       "X"
set_shell_parameter I2C_MASTER_IRQ_HOST           ""

set_shell_parameter I2C_BOARD_IRQ_PRIORITY        "X"
set_shell_parameter I2C_BOARD_IRQ_HOST            ""

set_shell_parameter DP_IRQ_PRIORITY               "X"
set_shell_parameter DP_IRQ_HOST                   ""

set_shell_parameter DP_50MHZ_CAL_CLK_EN           "1"
set_shell_parameter DP_AUX_DEBUG_EN               "0"

proc pre_creation_step {} {
    transfer_files
    evaluate_terp
}

proc creation_step {} {
    create_dp_tx_subsystem
}

proc post_creation_step {} {
    edit_top_level_qsys
    add_auto_connections
    edit_top_v_file
}

proc derive_parameters {param_array} {
    upvar $param_array p_array

    set v_drv_clock_subsystem_name ""

    for {set id 0} {$id < $p_array(project,id)} {incr id} {

        if {$p_array($id,type) == "clock"} {
            set params $p_array($id,params)

            foreach v_pair ${params} {
                set v_name  [lindex ${v_pair} 0]
                set v_value [lindex ${v_pair} 1]
                set v_temp_array(${v_name}) ${v_value}
            }

            if {[info exists v_temp_array(INSTANCE_NAME)]} {
                set v_drv_clock_subsystem_name $v_temp_array(INSTANCE_NAME)
                break
            }
        }
    }
    set_shell_parameter DRV_CLOCK_SUBSYSTEM_NAME ${v_drv_clock_subsystem_name}
}

proc transfer_files {} {
    set v_project_path        [get_shell_parameter PROJECT_PATH]
    set v_script_path         [get_shell_parameter SUBSYSTEM_SOURCE_PATH]

    exec cp -rf ${v_script_path}/non_qpds_ip/dp_tx_phy         ${v_project_path}/non_qpds_ip/user/dp_tx_phy

    file_copy   ${v_script_path}/dp_tx_subsystem.qsf.terp \
                ${v_project_path}/quartus/user/dp_tx_subsystem.qsf.terp

    file_copy   ${v_script_path}/dp_tx_subsystem.sdc.terp \
                ${v_project_path}/sdc/user/dp_tx_subsystem.sdc
}

proc evaluate_terp {} {
    set v_project_name  [get_shell_parameter PROJECT_NAME]
    set v_project_path  [get_shell_parameter PROJECT_PATH]

    evaluate_terp_file  ${v_project_path}/quartus/user/dp_tx_subsystem.qsf.terp    [list ${v_project_name}] 0 1
}

proc create_dp_tx_subsystem {} {
    set v_instance_name         [get_shell_parameter INSTANCE_NAME]
    set v_project_path          [get_shell_parameter PROJECT_PATH]
    set v_dp_bits_per_symbol    [get_shell_parameter VID_OUT_BPS]
    set v_dp_50mhz_cal_clk_en   [get_shell_parameter DP_50MHZ_CAL_CLK_EN]
    set v_dp_aux_debug_en       [get_shell_parameter DP_AUX_DEBUG_EN]

    create_system ${v_instance_name}
    save_system   ${v_project_path}/rtl/user/${v_instance_name}.qsys
    load_system   ${v_project_path}/rtl/user/${v_instance_name}.qsys

    ############################
    #### Add Instances      ####
    ############################

    add_instance  clk_16                      altera_clock_bridge
    add_instance  rst_16                      altera_reset_bridge
    if {${v_dp_50mhz_cal_clk_en}} {
        add_instance  cal_clk                 altera_clock_bridge
    }
    add_instance  mgmt_clk                    altera_clock_bridge
    add_instance  mgmt_rst                    altera_reset_bridge
    add_instance  dp_tx_mgmt_bridge           altera_avalon_mm_bridge
    add_instance  vvp_clock_bridge            altera_clock_bridge
    add_instance  vvp_reset_bridge            altera_reset_bridge
    add_instance  i2c_master                  altera_avalon_i2c
    add_instance  dp_core_i2c_board           altera_avalon_i2c
    add_instance  dp_core_pio_board           altera_avalon_pio
    add_instance  pio_status                  altera_avalon_pio
    add_instance  pio_supportd_fmats          altera_avalon_pio
    add_instance  pio_curr_format             altera_avalon_pio
    add_instance  pio_format_ovrride          altera_avalon_pio
    add_instance  dp_source                   altera_dp

    ############################
    #### Set Parameters     ####
    ############################

    # clk_16
    set_instance_parameter_value  clk_16                    EXPLICIT_CLOCK_RATE           {16000000.0}
    set_instance_parameter_value  clk_16                    NUM_CLOCK_OUTPUTS             {1}

    # rst_16
    set_instance_parameter_value  rst_16                    ACTIVE_LOW_RESET              {0}
    set_instance_parameter_value  rst_16                    NUM_RESET_OUTPUTS             {1}
    set_instance_parameter_value  rst_16                    SYNCHRONOUS_EDGES             {deassert}
    set_instance_parameter_value  rst_16                    SYNC_RESET                    {0}
    set_instance_parameter_value  rst_16                    USE_RESET_REQUEST             {0}

    if {${v_dp_50mhz_cal_clk_en}} {
        # cal_clk
        set_instance_parameter_value  cal_clk               EXPLICIT_CLOCK_RATE           {50000000.0}
        set_instance_parameter_value  cal_clk               NUM_CLOCK_OUTPUTS             {1}
    }

    # mgmt_clk
    set_instance_parameter_value  mgmt_clk                  EXPLICIT_CLOCK_RATE           {100000000.0}
    set_instance_parameter_value  mgmt_clk                  NUM_CLOCK_OUTPUTS             {1}

    # mgmt_rst
    set_instance_parameter_value  mgmt_rst                  ACTIVE_LOW_RESET              {0}
    set_instance_parameter_value  mgmt_rst                  NUM_RESET_OUTPUTS             {1}
    set_instance_parameter_value  mgmt_rst                  SYNCHRONOUS_EDGES             {deassert}
    set_instance_parameter_value  mgmt_rst                  SYNC_RESET                    {0}
    set_instance_parameter_value  mgmt_rst                  USE_RESET_REQUEST             {0}

    # dp_tx_mgmt_bridge
    set_instance_parameter_value  dp_tx_mgmt_bridge         ADDRESS_UNITS                 {SYMBOLS}
    set_instance_parameter_value  dp_tx_mgmt_bridge         ADDRESS_WIDTH                 {10}
    set_instance_parameter_value  dp_tx_mgmt_bridge         DATA_WIDTH                    {32}
    set_instance_parameter_value  dp_tx_mgmt_bridge         LINEWRAPBURSTS                {0}
    set_instance_parameter_value  dp_tx_mgmt_bridge         M0_WAITREQUEST_ALLOWANCE      {0}
    set_instance_parameter_value  dp_tx_mgmt_bridge         MAX_BURST_SIZE                {1}
    set_instance_parameter_value  dp_tx_mgmt_bridge         MAX_PENDING_RESPONSES         {4}
    set_instance_parameter_value  dp_tx_mgmt_bridge         MAX_PENDING_WRITES            {0}
    set_instance_parameter_value  dp_tx_mgmt_bridge         PIPELINE_COMMAND              {1}
    set_instance_parameter_value  dp_tx_mgmt_bridge         PIPELINE_RESPONSE             {1}
    set_instance_parameter_value  dp_tx_mgmt_bridge         S0_WAITREQUEST_ALLOWANCE      {0}
    set_instance_parameter_value  dp_tx_mgmt_bridge         SYMBOL_WIDTH                  {8}
    set_instance_parameter_value  dp_tx_mgmt_bridge         SYNC_RESET                    {0}
    set_instance_parameter_value  dp_tx_mgmt_bridge         USE_AUTO_ADDRESS_WIDTH        {1}
    set_instance_parameter_value  dp_tx_mgmt_bridge         USE_RESPONSE                  {0}
    set_instance_parameter_value  dp_tx_mgmt_bridge         USE_WRITERESPONSE             {0}

    # vvp_clock_bridge
    set_instance_parameter_value  vvp_clock_bridge          EXPLICIT_CLOCK_RATE           {148500000.0}
    set_instance_parameter_value  vvp_clock_bridge          NUM_CLOCK_OUTPUTS             {1}

    # vvp_reset_bridge
    set_instance_parameter_value  vvp_reset_bridge          ACTIVE_LOW_RESET              {0}
    set_instance_parameter_value  vvp_reset_bridge          NUM_RESET_OUTPUTS             {1}
    set_instance_parameter_value  vvp_reset_bridge          SYNCHRONOUS_EDGES             {deassert}
    set_instance_parameter_value  vvp_reset_bridge          SYNC_RESET                    {0}
    set_instance_parameter_value  vvp_reset_bridge          USE_RESET_REQUEST             {0}

    # i2c_master
    set_instance_parameter_value  i2c_master                FIFO_DEPTH                    {32}
    set_instance_parameter_value  i2c_master                USE_AV_ST                     {0}

    # dp_core_i2c_board
    set_instance_parameter_value  dp_core_i2c_board         FIFO_DEPTH                    {32}
    set_instance_parameter_value  dp_core_i2c_board         USE_AV_ST                     {0}

    # dp_core_pio_board
    set_instance_parameter_value  dp_core_pio_board       bitClearingEdgeCapReg         {0}
    set_instance_parameter_value  dp_core_pio_board       bitModifyingOutReg            {0}
    set_instance_parameter_value  dp_core_pio_board       captureEdge                   {0}
    set_instance_parameter_value  dp_core_pio_board       direction                     {Output}
    set_instance_parameter_value  dp_core_pio_board       edgeType                      {RISING}
    set_instance_parameter_value  dp_core_pio_board       generateIRQ                   {0}
    set_instance_parameter_value  dp_core_pio_board       irqType                       {LEVEL}
    set_instance_parameter_value  dp_core_pio_board       resetValue                    {0.0}
    set_instance_parameter_value  dp_core_pio_board       simDoTestBenchWiring          {0}
    set_instance_parameter_value  dp_core_pio_board       simDrivenValue                {0.0}
    set_instance_parameter_value  dp_core_pio_board       width                         {32}

    # pio_status
    set_instance_parameter_value  pio_status              bitClearingEdgeCapReg         {0}
    set_instance_parameter_value  pio_status              bitModifyingOutReg            {0}
    set_instance_parameter_value  pio_status              captureEdge                   {0}
    set_instance_parameter_value  pio_status              direction                     {Output}
    set_instance_parameter_value  pio_status              edgeType                      {RISING}
    set_instance_parameter_value  pio_status              generateIRQ                   {0}
    set_instance_parameter_value  pio_status              irqType                       {LEVEL}
    set_instance_parameter_value  pio_status              resetValue                    {0.0}
    set_instance_parameter_value  pio_status              simDoTestBenchWiring          {0}
    set_instance_parameter_value  pio_status              simDrivenValue                {0.0}
    set_instance_parameter_value  pio_status              width                         {32}

    # pio_supportd_fmats
    set_instance_parameter_value  pio_supportd_fmats      bitClearingEdgeCapReg         {0}
    set_instance_parameter_value  pio_supportd_fmats      bitModifyingOutReg            {0}
    set_instance_parameter_value  pio_supportd_fmats      captureEdge                   {0}
    set_instance_parameter_value  pio_supportd_fmats      direction                     {Output}
    set_instance_parameter_value  pio_supportd_fmats      edgeType                      {RISING}
    set_instance_parameter_value  pio_supportd_fmats      generateIRQ                   {0}
    set_instance_parameter_value  pio_supportd_fmats      irqType                       {LEVEL}
    set_instance_parameter_value  pio_supportd_fmats      resetValue                    {0.0}
    set_instance_parameter_value  pio_supportd_fmats      simDoTestBenchWiring          {0}
    set_instance_parameter_value  pio_supportd_fmats      simDrivenValue                {0.0}
    set_instance_parameter_value  pio_supportd_fmats      width                         {32}

    # pio_curr_format
    set_instance_parameter_value  pio_curr_format         bitClearingEdgeCapReg         {0}
    set_instance_parameter_value  pio_curr_format         bitModifyingOutReg            {0}
    set_instance_parameter_value  pio_curr_format         captureEdge                   {0}
    set_instance_parameter_value  pio_curr_format         direction                     {Output}
    set_instance_parameter_value  pio_curr_format         edgeType                      {RISING}
    set_instance_parameter_value  pio_curr_format         generateIRQ                   {0}
    set_instance_parameter_value  pio_curr_format         irqType                       {LEVEL}
    set_instance_parameter_value  pio_curr_format         resetValue                    {0.0}
    set_instance_parameter_value  pio_curr_format         simDoTestBenchWiring          {0}
    set_instance_parameter_value  pio_curr_format         simDrivenValue                {0.0}
    set_instance_parameter_value  pio_curr_format         width                         {32}

    # pio_format_ovrride
    set_instance_parameter_value  pio_format_ovrride      bitClearingEdgeCapReg         {0}
    set_instance_parameter_value  pio_format_ovrride      bitModifyingOutReg            {0}
    set_instance_parameter_value  pio_format_ovrride      captureEdge                   {0}
    set_instance_parameter_value  pio_format_ovrride      direction                     {Input}
    set_instance_parameter_value  pio_format_ovrride      edgeType                      {RISING}
    set_instance_parameter_value  pio_format_ovrride      generateIRQ                   {0}
    set_instance_parameter_value  pio_format_ovrride      irqType                       {LEVEL}
    set_instance_parameter_value  pio_format_ovrride      resetValue                    {0.0}
    set_instance_parameter_value  pio_format_ovrride      simDoTestBenchWiring          {0}
    set_instance_parameter_value  pio_format_ovrride      simDrivenValue                {0.0}
    set_instance_parameter_value  pio_format_ovrride      width                         {32}

    # dp_source
    set_instance_parameter_value  dp_source                 ENABLE_ED_FILESET_SIM         {0}
    set_instance_parameter_value  dp_source                 ENABLE_ED_FILESET_SYNTHESIS   {1}
    set_instance_parameter_value  dp_source                 GTS_CLK                       {0}
    set_instance_parameter_value  dp_source                 PHY_STRUCTURE                 {0}
    set_instance_parameter_value  dp_source                 RX_AUDIO_CHANS                {2}
    set_instance_parameter_value  dp_source                 RX_AUX_DEBUG                  {0}
    set_instance_parameter_value  dp_source                 RX_AUX_GPU                    {1}
    set_instance_parameter_value  dp_source                 RX_AXIS_VIDEOIF_EN            {0}
    set_instance_parameter_value  dp_source                 RX_EXPORT_MSA                 {1}
    set_instance_parameter_value  dp_source                 RX_FEC_ERRCNT_EN              {1}
    set_instance_parameter_value  dp_source                 RX_FEC_ERRINJ_EN              {0}
    set_instance_parameter_value  dp_source                 RX_HDCP_KEY_VERSION           {0}
    set_instance_parameter_value  dp_source                 RX_I2C_SCL_KHZ                {100}
    set_instance_parameter_value  dp_source                 RX_IEEE_OUI                   {1}
    set_instance_parameter_value  dp_source                 RX_MAX_LANE_COUNT             {2}
    set_instance_parameter_value  dp_source                 RX_MAX_LINK_RATE              {30}
    set_instance_parameter_value  dp_source                 RX_MAX_NUM_OF_STREAMS         {1}
    set_instance_parameter_value  dp_source                 RX_PIXELS_PER_CLOCK           {2}
    set_instance_parameter_value  dp_source                 RX_PRBS_CHECKER               {0}
    set_instance_parameter_value  dp_source                 RX_SCRAMBLER_SEED             {65535}
    set_instance_parameter_value  dp_source                 RX_SUPPORT_AUDIO              {0}
    set_instance_parameter_value  dp_source                 RX_SUPPORT_AUTOMATED_TEST     {0}
    set_instance_parameter_value  dp_source                 RX_SUPPORT_DP                 {0}
    set_instance_parameter_value  dp_source                 RX_SUPPORT_FEC                {0}
    set_instance_parameter_value  dp_source                 RX_SUPPORT_GTC                {0}
    set_instance_parameter_value  dp_source                 RX_SUPPORT_HDCP1X             {0}
    set_instance_parameter_value  dp_source                 RX_SUPPORT_HDCP2X             {0}
    set_instance_parameter_value  dp_source                 RX_SUPPORT_HDCP_KEY_MANAGE    {0}
    set_instance_parameter_value  dp_source                 RX_SUPPORT_I2CMASTER          {0}
    set_instance_parameter_value  dp_source                 RX_SUPPORT_MST                {0}
    set_instance_parameter_value  dp_source                 RX_SUPPORT_PR                 {0}
    set_instance_parameter_value  dp_source                 RX_SUPPORT_SS                 {0}
    set_instance_parameter_value  dp_source                 RX_SYMBOLS_PER_CLOCK          {4}
    set_instance_parameter_value  dp_source                 RX_TOOLKIT                    {0}
    set_instance_parameter_value  dp_source                 RX_VIDEO_BPS                  {8}
    set_instance_parameter_value  dp_source                 SELECT_CUSTOM_DEVICE          {0}
    set_instance_parameter_value  dp_source                 SELECT_ED_FILESET             {VERILOG}
    set_instance_parameter_value  dp_source                 SELECT_FMC_REV                {8}
    set_instance_parameter_value  dp_source                 SELECT_SUPPORTED_VARIANT      {5}
    set_instance_parameter_value  dp_source                 SELECT_TARGETED_BOARD         {0}
    set_instance_parameter_value  dp_source                 TX_AUDIO_CHANS                {2}
    set_instance_parameter_value  dp_source                 TX_AUX_DEBUG                  ${v_dp_aux_debug_en}
    set_instance_parameter_value  dp_source                 TX_AXIS_VIDEOIF_EN            {1}
    set_instance_parameter_value  dp_source                 TX_HDCP_KEY_VERSION           {0}
    set_instance_parameter_value  dp_source                 TX_MAX_LANE_COUNT             {2}
    set_instance_parameter_value  dp_source                 TX_MAX_LINK_RATE              {30}
    set_instance_parameter_value  dp_source                 TX_MAX_NUM_OF_STREAMS         {1}
    set_instance_parameter_value  dp_source                 TX_PIXELS_PER_CLOCK           {2}
    set_instance_parameter_value  dp_source                 TX_SCRAMBLER_SEED             {65535}
    set_instance_parameter_value  dp_source                 TX_SUPPORT_ANALOG_RECONFIG    {1}
    set_instance_parameter_value  dp_source                 TX_SUPPORT_AUDIO              {0}
    set_instance_parameter_value  dp_source                 TX_SUPPORT_AUTOMATED_TEST     {0}
    set_instance_parameter_value  dp_source                 TX_SUPPORT_DP                 {1}
    set_instance_parameter_value  dp_source                 TX_SUPPORT_FEC                {0}
    set_instance_parameter_value  dp_source                 TX_SUPPORT_GTC                {0}
    set_instance_parameter_value  dp_source                 TX_SUPPORT_HDCP1X             {0}
    set_instance_parameter_value  dp_source                 TX_SUPPORT_HDCP2X             {0}
    set_instance_parameter_value  dp_source                 TX_SUPPORT_HDCP_KEY_MANAGE    {0}
    set_instance_parameter_value  dp_source                 TX_SUPPORT_MST                {0}
    set_instance_parameter_value  dp_source                 TX_SUPPORT_SS                 {0}
    set_instance_parameter_value  dp_source                 TX_SYMBOLS_PER_CLOCK          {4}
    set_instance_parameter_value  dp_source                 TX_TOOLKIT                    {0}
    set_instance_parameter_value  dp_source                 TX_VIDEO_BPS                  ${v_dp_bits_per_symbol}
    set_instance_parameter_value  dp_source                 TX_VIDEO_IM_ENABLE            {0}

    ############################
    #### Create Connections ####
    ############################
    # clk_16
    add_connection    clk_16.out_clk                rst_16.clk
    add_connection    clk_16.out_clk                dp_source.aux_clk

    # rst_16
    add_connection    rst_16.out_reset              dp_source.aux_reset

    # mgmt_clk
    add_connection    mgmt_clk.out_clk              mgmt_rst.clk
    add_connection    mgmt_clk.out_clk              dp_tx_mgmt_bridge.clk
    add_connection    mgmt_clk.out_clk              i2c_master.clock
    add_connection    mgmt_clk.out_clk              dp_core_i2c_board.clock
    add_connection    mgmt_clk.out_clk              dp_core_pio_board.clk
    add_connection    mgmt_clk.out_clk              pio_status.clk
    add_connection    mgmt_clk.out_clk              pio_supportd_fmats.clk
    add_connection    mgmt_clk.out_clk              pio_curr_format.clk
    add_connection    mgmt_clk.out_clk              pio_format_ovrride.clk
    add_connection    mgmt_clk.out_clk              dp_source.clk
    add_connection    mgmt_clk.out_clk              dp_source.xcvr_mgmt_clk
    if {${v_dp_50mhz_cal_clk_en}} {
        # cal_clk
        add_connection    cal_clk.out_clk               dp_source.clk_cal
    } else {
        add_connection    mgmt_clk.out_clk              dp_source.clk_cal
    }

    # mgmt_rst
    add_connection    mgmt_rst.out_reset            dp_tx_mgmt_bridge.reset
    add_connection    mgmt_rst.out_reset            i2c_master.reset_sink
    add_connection    mgmt_rst.out_reset            dp_core_i2c_board.reset_sink
    add_connection    mgmt_rst.out_reset            dp_core_pio_board.reset
    add_connection    mgmt_rst.out_reset            pio_status.reset
    add_connection    mgmt_rst.out_reset            pio_supportd_fmats.reset
    add_connection    mgmt_rst.out_reset            pio_curr_format.reset
    add_connection    mgmt_rst.out_reset            pio_format_ovrride.reset
    add_connection    mgmt_rst.out_reset            dp_source.reset

    # dp_tx_mgmt_bridge
    add_connection    dp_tx_mgmt_bridge.m0          i2c_master.csr
    add_connection    dp_tx_mgmt_bridge.m0          dp_core_i2c_board.csr
    add_connection    dp_tx_mgmt_bridge.m0          dp_core_pio_board.s1
    add_connection    dp_tx_mgmt_bridge.m0          pio_status.s1
    add_connection    dp_tx_mgmt_bridge.m0          pio_supportd_fmats.s1
    add_connection    dp_tx_mgmt_bridge.m0          pio_curr_format.s1
    add_connection    dp_tx_mgmt_bridge.m0          pio_format_ovrride.s1
    add_connection    dp_tx_mgmt_bridge.m0          dp_source.tx_mgmt

    # vvp_clock_bridge
    add_connection    vvp_clock_bridge.out_clk      vvp_reset_bridge.clk
    add_connection    vvp_clock_bridge.out_clk      dp_source.tx_axi4s_clk
    add_connection    vvp_clock_bridge.out_clk      dp_source.tx_vid_clk

    # vvp_reset_bridge
    add_connection    vvp_reset_bridge.out_reset    dp_source.tx_axi4s_reset

    ##########################
    ##### Create Exports #####
    ##########################
    # clk_16
    add_interface             clk_16_in_clk                   clock       input
    set_interface_property    clk_16_in_clk                   export_of   clk_16.in_clk

    # rst_16
    add_interface             rst_16_in_rst                   clock       input
    set_interface_property    rst_16_in_rst                   export_of   rst_16.in_reset

    if {${v_dp_50mhz_cal_clk_en}} {
        # cal_clk
        add_interface             cal_clk_in_clk                  clock       input
        set_interface_property    cal_clk_in_clk                  export_of   cal_clk.in_clk
    }

    # mgmt_clk
    add_interface             mgmt_clk_in_clk                 clock       input
    set_interface_property    mgmt_clk_in_clk                 export_of   mgmt_clk.in_clk

    # mgmt_rst
    add_interface             mgmt_rst_in_rst                 clock       input
    set_interface_property    mgmt_rst_in_rst                 export_of   mgmt_rst.in_reset

    # dp_tx_mgmt_bridge
    add_interface             dp_source_tx_mgmt               avmm        agent
    set_interface_property    dp_source_tx_mgmt               export_of   dp_tx_mgmt_bridge.s0

    # vvp_clock_bridge
    add_interface             vvp_clock_bridge_in_clk         clock       input
    set_interface_property    vvp_clock_bridge_in_clk         export_of   vvp_clock_bridge.in_clk

    # vvp_reset_bridge
    add_interface             vvp_reset_bridge_in_reset       reset       sink
    set_interface_property    vvp_reset_bridge_in_reset       export_of   vvp_reset_bridge.in_reset

    # i2c_master
    add_interface             i2c_master_i2c_serial           conduit     end
    set_interface_property    i2c_master_i2c_serial           export_of   i2c_master.i2c_serial

    add_interface             i2c_master_irq                  interrupt   sender
    set_interface_property    i2c_master_irq                  export_of   i2c_master.interrupt_sender

    # dp_core_i2c_board
    add_interface             dp_core_i2c_board_i2c_serial    conduit     end
    set_interface_property    dp_core_i2c_board_i2c_serial    export_of   dp_core_i2c_board.i2c_serial

    add_interface             dp_core_i2c_board_irq     interrupt   sender
    set_interface_property    dp_core_i2c_board_irq     export_of   dp_core_i2c_board.interrupt_sender

    # dp_core_pio_board
    add_interface             dp_core_board_pio     conduit     end
    set_interface_property    dp_core_board_pio     export_of   dp_core_pio_board.external_connection

    # pio_status
    add_interface             status_pio            conduit     end
    set_interface_property    status_pio            export_of   pio_status.external_connection

    # pio_supportd_fmats
    add_interface             supportd_fmats_pio    conduit     end
    set_interface_property    supportd_fmats_pio    export_of   pio_supportd_fmats.external_connection

    # pio_curr_format
    add_interface             curr_format_pio       conduit     end
    set_interface_property    curr_format_pio       export_of   pio_curr_format.external_connection

    # pio_format_ovrride
    add_interface             format_ovrride_pio    conduit     end
    set_interface_property    format_ovrride_pio    export_of   pio_format_ovrride.external_connection

    # dp_source
    add_interface             dp_source_tx_xcvr_interface     conduit     end
    set_interface_property    dp_source_tx_xcvr_interface     export_of   dp_source.tx_xcvr_interface

    add_interface             dp_source_tx_aux                conduit     end
    set_interface_property    dp_source_tx_aux                export_of   dp_source.tx_aux

    add_interface             dp_source_tx_analog_reconfig    conduit     end
    set_interface_property    dp_source_tx_analog_reconfig    export_of   dp_source.tx_analog_reconfig

    add_interface             dp_source_tx_reconfig           conduit     end
    set_interface_property    dp_source_tx_reconfig           export_of   dp_source.tx_reconfig

    add_interface             dp_source_tx_axi4s_vid_in       axi4stream  subordinate
    set_interface_property    dp_source_tx_axi4s_vid_in       export_of   dp_source.tx_axi4s_vid_in

    add_interface             dp_source_tx_mgmt_interrupt     interrupt   sender
    set_interface_property    dp_source_tx_mgmt_interrupt     export_of   dp_source.tx_mgmt_interrupt

	add_interface             dp_source_dsc_mgmt              conduit     end
	set_interface_property    dp_source_dsc_mgmt              export_of   dp_source.dsc_mgmt

	add_interface             dp_source_dsc_passthrough       conduit     end
	set_interface_property    dp_source_dsc_passthrough       export_of   dp_source.dsc_passthrough

	add_interface             dp_source_tx_im_dsc_clk         clock       input
	set_interface_property    dp_source_tx_im_dsc_clk         export_of   dp_source.tx_im_dsc_clk

	add_interface             dp_source_tx_im_dsc             conduit     end
	set_interface_property    dp_source_tx_im_dsc             export_of   dp_source.tx_im_dsc

	add_interface             dp_source_dsc_ctrl              conduit     end
	set_interface_property    dp_source_dsc_ctrl              export_of   dp_source.dsc_ctrl

	add_interface             dp_source_dsc_sync_clk          clock       input
	set_interface_property    dp_source_dsc_sync_clk          export_of   dp_source.dsc_sync_clk

	add_interface             dp_source_dsc_sync              conduit     end
	set_interface_property    dp_source_dsc_sync              export_of   dp_source.dsc_sync

	add_interface             dp_source_dsc_axi4s             conduit     end
	set_interface_property    dp_source_dsc_axi4s             export_of   dp_source.dsc_axi4s

	add_interface             dp_source_dsc_tx_tpg            conduit     end
	set_interface_property    dp_source_dsc_tx_tpg            export_of   dp_source.dsc_tx_tpg

    #################################
    ##### Assign Base Addresses #####
    #################################
    sync_sysinfo_parameters
    auto_assign_system_base_addresses
    save_system
}

proc edit_top_level_qsys {} {
    set v_project_name          [get_shell_parameter PROJECT_NAME]
    set v_project_path          [get_shell_parameter PROJECT_PATH]
    set v_instance_name         [get_shell_parameter INSTANCE_NAME]

    load_system   ${v_project_path}/rtl/${v_project_name}_qsys.qsys
    add_instance  ${v_instance_name}  ${v_instance_name}

    # i2c_master
    add_interface             "${v_instance_name}_i2c_master_i2c_serial"            conduit   end
    set_interface_property    "${v_instance_name}_i2c_master_i2c_serial" \
                              export_of   ${v_instance_name}.i2c_master_i2c_serial

    # dp_core_i2c_board
    add_interface             "${v_instance_name}_dp_core_i2c_board_i2c_serial"     conduit   end
    set_interface_property    "${v_instance_name}_dp_core_i2c_board_i2c_serial" \
                              export_of   ${v_instance_name}.dp_core_i2c_board_i2c_serial

    # dp_core_pio_board
    add_interface             "${v_instance_name}_dp_core_board_pio"    conduit     end
    set_interface_property    "${v_instance_name}_dp_core_board_pio" \
                              export_of   ${v_instance_name}.dp_core_board_pio

    # pio_status
    add_interface             "${v_instance_name}_status_pio"           conduit     end
    set_interface_property    "${v_instance_name}_status_pio" \
                              export_of   ${v_instance_name}.status_pio

    # pio_supportd_fmats
    add_interface             "${v_instance_name}_supportd_fmats_pio"   conduit     end
    set_interface_property    "${v_instance_name}_supportd_fmats_pio" \
                              export_of   ${v_instance_name}.supportd_fmats_pio

    # pio_curr_format
    add_interface             "${v_instance_name}_curr_format_pio"      conduit     end
    set_interface_property    "${v_instance_name}_curr_format_pio" \
                              export_of   ${v_instance_name}.curr_format_pio

    # pio_format_ovrride
    add_interface             "${v_instance_name}_format_ovrride_pio"   conduit     end
    set_interface_property    "${v_instance_name}_format_ovrride_pio" \
                              export_of   ${v_instance_name}.format_ovrride_pio

    # dp_source
    add_interface             "${v_instance_name}_dp_source_tx_xcvr_interface"      conduit   end
    set_interface_property    "${v_instance_name}_dp_source_tx_xcvr_interface" \
                              export_of ${v_instance_name}.dp_source_tx_xcvr_interface

    add_interface             "${v_instance_name}_dp_source_tx_aux"                 conduit   end
    set_interface_property    "${v_instance_name}_dp_source_tx_aux" \
                              export_of ${v_instance_name}.dp_source_tx_aux

    add_interface             "${v_instance_name}_dp_source_tx_analog_reconfig"     conduit   end
    set_interface_property    "${v_instance_name}_dp_source_tx_analog_reconfig" \
                              export_of  ${v_instance_name}.dp_source_tx_analog_reconfig

    add_interface             "${v_instance_name}_dp_source_tx_reconfig"            conduit   end
    set_interface_property    "${v_instance_name}_dp_source_tx_reconfig" \
                              export_of ${v_instance_name}.dp_source_tx_reconfig

	add_interface             "${v_instance_name}_dp_source_dsc_mgmt"           conduit     end
	set_interface_property    "${v_instance_name}_dp_source_dsc_mgmt" \
                              export_of ${v_instance_name}.dp_source_dsc_mgmt

	add_interface             "${v_instance_name}_dp_source_dsc_passthrough"    conduit     end
	set_interface_property    "${v_instance_name}_dp_source_dsc_passthrough" \
                              export_of ${v_instance_name}.dp_source_dsc_passthrough

	add_interface             "${v_instance_name}_dp_source_tx_im_dsc_clk"      clock       input
	set_interface_property    "${v_instance_name}_dp_source_tx_im_dsc_clk" \
                              export_of ${v_instance_name}.dp_source_tx_im_dsc_clk

	add_interface             "${v_instance_name}_dp_source_tx_im_dsc"          conduit     end
	set_interface_property    "${v_instance_name}_dp_source_tx_im_dsc" \
                              export_of ${v_instance_name}.dp_source_tx_im_dsc

	add_interface             "${v_instance_name}_dp_source_dsc_ctrl"           conduit     end
	set_interface_property    "${v_instance_name}_dp_source_dsc_ctrl" \
                              export_of ${v_instance_name}.dp_source_dsc_ctrl

	add_interface             "${v_instance_name}_dp_source_dsc_sync_clk"       clock       input
	set_interface_property    "${v_instance_name}_dp_source_dsc_sync_clk" \
                              export_of ${v_instance_name}.dp_source_dsc_sync_clk

	add_interface             "${v_instance_name}_dp_source_dsc_sync"           conduit     end
	set_interface_property    "${v_instance_name}_dp_source_dsc_sync" \
                              export_of ${v_instance_name}.dp_source_dsc_sync

	add_interface             "${v_instance_name}_dp_source_dsc_axi4s"          conduit     end
	set_interface_property    "${v_instance_name}_dp_source_dsc_axi4s" \
                              export_of ${v_instance_name}.dp_source_dsc_axi4s

	add_interface             "${v_instance_name}_dp_source_dsc_tx_tpg"         conduit     end
	set_interface_property    "${v_instance_name}_dp_source_dsc_tx_tpg" \
                              export_of ${v_instance_name}.dp_source_dsc_tx_tpg

    sync_sysinfo_parameters
    save_system
}

proc add_auto_connections {} {
    set v_instance_name           [get_shell_parameter INSTANCE_NAME]
    set v_avmm_host               [get_shell_parameter AVMM_HOST]
    set v_i2c_irq_master_priority [get_shell_parameter I2C_MASTER_IRQ_PRIORITY]
    set v_i2c_irq_master_host     [get_shell_parameter I2C_MASTER_IRQ_HOST]
    set v_i2c_irq_board_priority  [get_shell_parameter I2C_BOARD_IRQ_PRIORITY]
    set v_i2c_irq_board_host      [get_shell_parameter I2C_BOARD_IRQ_HOST]
    set v_dp_irq_priority         [get_shell_parameter DP_IRQ_PRIORITY]
    set v_dp_irq_host             [get_shell_parameter DP_IRQ_HOST]
    set v_dp_50mhz_cal_clk_en     [get_shell_parameter DP_50MHZ_CAL_CLK_EN]

    add_auto_connection ${v_instance_name}  clk_16_in_clk                 16000000
    add_auto_connection ${v_instance_name}  rst_16_in_rst                 16000000

    if {${v_dp_50mhz_cal_clk_en}} {
        add_auto_connection ${v_instance_name}  cal_clk_in_clk            50000000
    }
    add_auto_connection ${v_instance_name}  mgmt_clk_in_clk               100000000
    add_auto_connection ${v_instance_name}  mgmt_rst_in_rst               100000000
    add_auto_connection ${v_instance_name}  vvp_clock_bridge_in_clk       148500000
    add_auto_connection ${v_instance_name}  vvp_reset_bridge_in_reset     148500000

    add_auto_connection ${v_instance_name}  dp_source_tx_axi4s_vid_in     vid_out_if_vid_in

    add_avmm_connections dp_source_tx_mgmt  ${v_avmm_host}

    if {(${v_i2c_irq_master_host} != "NONE") && (${v_i2c_irq_master_host} != "")} {
        add_irq_connection ${v_instance_name} "i2c_master_irq" \
                                              ${v_i2c_irq_master_priority} ${v_i2c_irq_master_host}_irq
    }

    if {(${v_i2c_irq_board_host} != "NONE") && (${v_i2c_irq_board_host} != "")} {
        add_irq_connection ${v_instance_name} "dp_core_i2c_board_irq" \
                                              ${v_i2c_irq_board_priority} ${v_i2c_irq_board_host}_irq
    }

    if {(${v_dp_irq_host} != "NONE") && (${v_dp_irq_host} != "")} {
        add_irq_connection ${v_instance_name} "dp_source_tx_mgmt_interrupt" \
                                              ${v_dp_irq_priority} ${v_dp_irq_host}_irq
    }
}

proc edit_top_v_file {} {
    set v_drv_clock_subsystem_name  [get_shell_parameter DRV_CLOCK_SUBSYSTEM_NAME]
    set v_instance_name             [get_shell_parameter INSTANCE_NAME]

    add_top_port_list input  ""             fgt_refclk_150
    add_top_port_list output "\[1:0\]"      pin_dp_tx_p
    add_top_port_list output "\[1:0\]"      pin_dp_tx_n
    add_top_port_list output ""             pin_dp_tx_cad
    add_top_port_list input  ""             pin_dp_tx_hpd
    add_top_port_list input  ""             pin_dp_tx_aux_in
    add_top_port_list output ""             pin_dp_tx_aux_out
    add_top_port_list output ""             pin_dp_tx_aux_oe

    add_declaration_list  reg "\[31:0\]"  pio_board
    add_declaration_list  reg "\[31:0\]"  dp_tx_status_o
    add_declaration_list  reg "\[31:0\]"  dp_tx_supportd_fmats_o
    add_declaration_list  reg "\[31:0\]"  dp_tx_curr_format_o
    add_declaration_list  reg "\[31:0\]"  dp_tx_format_ovrride_i

    add_declaration_list  wire ""          dp_tx_analog_rcfg_req
    add_declaration_list  wire ""          dp_tx_analog_rcfg_ack
    add_declaration_list  wire "\[3:0\]"   dp_tx_analog_rcfg_vod
    add_declaration_list  wire "\[3:0\]"   dp_tx_analog_rcfg_emp
    add_declaration_list  wire "\[7:0\]"   dp_tx_link_rate
    add_declaration_list  wire ""          dp_tx_rate_rcfg_req
    add_declaration_list  wire ""          dp_tx_rate_rcfg_ack
    add_declaration_list  wire ""          dp_tx_rate_rcfg_busy
    add_declaration_list  wire "\[79:0\]"  dp_tx_parallel_data
    add_declaration_list  wire "\[1:0\]"   dp_tx_cal_busy
    add_declaration_list  wire ""          gxb_tx_clkout
    add_declaration_list  wire ""          dp_txpll_locked

    add_declaration_list  wire ""          dp_tx_hpd
    add_declaration_list  wire ""          dp_tx_aux_in
    add_declaration_list  wire ""          dp_tx_aux_out
    add_declaration_list  wire ""          dp_tx_aux_oe

    add_declaration_list  wire ""          cold_reset
    add_declaration_list  wire ""          sys_reset
    add_declaration_list  wire ""          sys_resetn

    add_assignments_list "pin_dp_tx_cad"      "1'b0"
    add_assignments_list "dp_tx_hpd"          "~pin_dp_tx_hpd"
    add_assignments_list "dp_tx_aux_in"       "pin_dp_tx_aux_in"
    add_assignments_list "pin_dp_tx_aux_out"  "dp_tx_aux_out"
    add_assignments_list "pin_dp_tx_aux_oe"   "dp_tx_aux_oe"

    add_assignments_list "dp_tx_cal_busy"     "'0"

    set generic_code {}
    lappend generic_code  ""
    lappend generic_code  "wire        rss_clk;"
    lappend generic_code  "wire \[9:0\]  rss_refclk_cmd_bus_in;"
    lappend generic_code  "wire \[9:0\]  rss_refclk_status_bus_out;"
    lappend generic_code  "wire \[7:0\]  rss_refclk_fail_status;"
    lappend generic_code  "wire        rss_refclk_on_ack;"
    lappend generic_code  "wire \[9:0\]  rss_refclk_on;"
    lappend generic_code  ""
    lappend generic_code  "wire \[1:0\] rss_req;"
    lappend generic_code  "wire \[1:0\] rss_grant;"
    lappend generic_code  "wire \[1:0\] rss_priority;"
    lappend generic_code  ""
    lappend generic_code  "// Not required as clocks are always stable."
    lappend generic_code  "assign rss_priority = '0;"
    lappend generic_code  "assign rss_refclk_status_bus_out = '0;"
    lappend generic_code  "assign rss_refclk_on = 10'b0;"
    lappend generic_code  ""
    lappend generic_code  "// Agilex Global Shoreline Reset Sequencer (One Per Side)"
    lappend generic_code  "dp_gts_rss i_dp_gts_rss ("
    lappend generic_code  "    .i_src_rs_priority              (rss_priority),"
    lappend generic_code  "    .i_src_rs_req                   (rss_req),"
    lappend generic_code  "    .o_src_rs_grant                 (rss_grant),"
    lappend generic_code  "    .o_pma_cu_clk                   (rss_clk),"
    lappend generic_code  "    .i_src_rs_refclk_status_bus_out (rss_refclk_status_bus_out),"
    lappend generic_code  "    .o_refclk_fail_status           (rss_refclk_fail_status),"
    lappend generic_code  "    .o_refclk_on_ack                (rss_refclk_on_ack),"
    lappend generic_code  "    .i_refclk_on                    (rss_refclk_on),"
    lappend generic_code  "    .o_src_rs_refclk_cmd_bus_in     (rss_refclk_cmd_bus_in)"
    lappend generic_code  ");"
    lappend generic_code  ""
    lappend generic_code  "// Phy"
    lappend generic_code  "dp_gts_tx i_dp_gts_tx ("
    lappend generic_code  "    .refclk_150                (fgt_refclk_150),"
    lappend generic_code  "    .mgmt_clock                (clock_subsystem_ref_clk),"
    lappend generic_code  "    .mgmt_resetn               (~clock_subsystem_ref_rst & pio_board\[1\]),"
    lappend generic_code  "    .rss_req                   (rss_req),"
    lappend generic_code  "    .rss_grant                 (rss_grant),"
    lappend generic_code  "    .rss_clk                   (rss_clk),"
    lappend generic_code  "    .tx_clk                    (gxb_tx_clkout),"
    lappend generic_code  "    .tx_p                      (pin_dp_tx_p),"
    lappend generic_code  "    .tx_n                      (pin_dp_tx_n),"
    lappend generic_code  "    .tx_rate_rcfg_busy         (dp_tx_rate_rcfg_busy),"
    lappend generic_code  "    .tx_link_rate              (dp_tx_link_rate),"
    lappend generic_code  "    .tx_rate_rcfg_req          (dp_tx_rate_rcfg_req),"
    lappend generic_code  "    .tx_rate_rcfg_ack          (dp_tx_rate_rcfg_ack),"
    lappend generic_code  "    .tx_reconfig_en            (1'b1),"
    lappend generic_code  "    .tx_analog_rcfg_req        (dp_tx_analog_rcfg_req),"
    lappend generic_code  "    .tx_analog_rcfg_ack        (dp_tx_analog_rcfg_ack),"
    lappend generic_code  "    .tx_analog_rcfg_vod        (dp_tx_analog_rcfg_vod),"
    lappend generic_code  "    .tx_analog_rcfg_emp        (dp_tx_analog_rcfg_emp),"
    lappend generic_code  "    .tx_parallel_data          (dp_tx_parallel_data),"
    lappend generic_code  "    .tx_pll_locked             (dp_txpll_locked)"
    lappend generic_code  ");"

    add_code_insert_list $generic_code

    # PIO
    add_qsys_inst_exports_list  ${v_instance_name}_dp_core_board_pio_export               pio_board
    add_qsys_inst_exports_list  ${v_instance_name}_status_pio_export                      dp_tx_status_o
    add_qsys_inst_exports_list  ${v_instance_name}_supportd_fmats_pio_export              dp_tx_supportd_fmats_o
    add_qsys_inst_exports_list  ${v_instance_name}_curr_format_pio_export                 dp_tx_curr_format_o
    add_qsys_inst_exports_list  ${v_instance_name}_format_ovrride_pio_export              "32'd0"

    # I2C for board to reconfigure Board Clocks
    add_qsys_inst_exports_list  ${v_instance_name}_dp_core_i2c_board_i2c_serial_sda_in    ""
    add_qsys_inst_exports_list  ${v_instance_name}_dp_core_i2c_board_i2c_serial_scl_in    ""
    add_qsys_inst_exports_list  ${v_instance_name}_dp_core_i2c_board_i2c_serial_sda_oe    ""
    add_qsys_inst_exports_list  ${v_instance_name}_dp_core_i2c_board_i2c_serial_scl_oe    ""
    # add_qsys_inst_exports_list  ${v_instance_name}_dp_core_i2c_board_i2c_serial_sda_in    board_i2c_sda_in
    # add_qsys_inst_exports_list  ${v_instance_name}_dp_core_i2c_board_i2c_serial_scl_in    board_i2c_scl_in
    # add_qsys_inst_exports_list  ${v_instance_name}_dp_core_i2c_board_i2c_serial_sda_oe    board_i2c_sda_oe
    # add_qsys_inst_exports_list  ${v_instance_name}_dp_core_i2c_board_i2c_serial_scl_oe    board_i2c_scl_oe

    add_qsys_inst_exports_list  ${v_instance_name}_i2c_master_i2c_serial_sda_in           ""
    add_qsys_inst_exports_list  ${v_instance_name}_i2c_master_i2c_serial_scl_in           ""
    add_qsys_inst_exports_list  ${v_instance_name}_i2c_master_i2c_serial_sda_oe           ""
    add_qsys_inst_exports_list  ${v_instance_name}_i2c_master_i2c_serial_scl_oe           ""

    # Hot Plug Detect Interface
    add_qsys_inst_exports_list  ${v_instance_name}_dp_source_tx_aux_tx_hpd                dp_tx_hpd
    # DisplayPort Auxiliarty Interface
    add_qsys_inst_exports_list  ${v_instance_name}_dp_source_tx_aux_tx_aux_in             dp_tx_aux_in
    add_qsys_inst_exports_list  ${v_instance_name}_dp_source_tx_aux_tx_aux_out            dp_tx_aux_out
    add_qsys_inst_exports_list  ${v_instance_name}_dp_source_tx_aux_tx_aux_oe             dp_tx_aux_oe

    # DisplayPort Analog Reconfiguration Interface
    add_qsys_inst_exports_list  ${v_instance_name}_dp_source_tx_analog_reconfig_tx_analog_reconfig_req \
                                                                                            dp_tx_analog_rcfg_req
    add_qsys_inst_exports_list  ${v_instance_name}_dp_source_tx_analog_reconfig_tx_analog_reconfig_ack \
                                                                                            dp_tx_analog_rcfg_ack
    add_qsys_inst_exports_list  ${v_instance_name}_dp_source_tx_analog_reconfig_tx_analog_reconfig_busy    ""
    add_qsys_inst_exports_list  ${v_instance_name}_dp_source_tx_analog_reconfig_tx_vod \
                                                                                            dp_tx_analog_rcfg_vod
    add_qsys_inst_exports_list  ${v_instance_name}_dp_source_tx_analog_reconfig_tx_emp \
                                                                                            dp_tx_analog_rcfg_emp
    add_qsys_inst_exports_list  ${v_instance_name}_dp_source_tx_reconfig_tx_link_rate             ""
    add_qsys_inst_exports_list  ${v_instance_name}_dp_source_tx_reconfig_tx_link_rate_8bits       dp_tx_link_rate
    add_qsys_inst_exports_list  ${v_instance_name}_dp_source_tx_reconfig_tx_reconfig_req          dp_tx_rate_rcfg_req
    add_qsys_inst_exports_list  ${v_instance_name}_dp_source_tx_reconfig_tx_reconfig_ack          dp_tx_rate_rcfg_ack
    add_qsys_inst_exports_list  ${v_instance_name}_dp_source_tx_reconfig_tx_reconfig_busy         dp_tx_rate_rcfg_busy
    add_qsys_inst_exports_list  ${v_instance_name}_dp_source_tx_xcvr_interface_tx_parallel_data   dp_tx_parallel_data
    add_qsys_inst_exports_list  ${v_instance_name}_dp_source_tx_xcvr_interface_tx_pll_powerdown   ""
    add_qsys_inst_exports_list  ${v_instance_name}_dp_source_tx_xcvr_interface_tx_analogreset     ""
    add_qsys_inst_exports_list  ${v_instance_name}_dp_source_tx_xcvr_interface_tx_digitalreset    ""
    add_qsys_inst_exports_list  ${v_instance_name}_dp_source_tx_xcvr_interface_tx_cal_busy        dp_tx_cal_busy
    add_qsys_inst_exports_list  ${v_instance_name}_dp_source_tx_xcvr_interface_tx_std_clkout      gxb_tx_clkout
    add_qsys_inst_exports_list  ${v_instance_name}_dp_source_tx_xcvr_interface_tx_pll_locked      dp_txpll_locked
}
