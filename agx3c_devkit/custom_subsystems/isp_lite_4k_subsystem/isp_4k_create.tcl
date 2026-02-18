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

set_shell_parameter AVMM_HOST               {{AUTO X}}

# General Video Controls
set_shell_parameter PIP                     {2}
set_shell_parameter VID_OUT_RATE            "p60"
set_shell_parameter VID_OUT_BPS             {10}
set_shell_parameter EN_DEBUG                {1}

proc creation_step {} {
    create_isp_subsystem
}

proc post_creation_step {} {
    edit_top_level_qsys
    add_auto_connections
}

proc create_isp_subsystem {} {
    set v_project_path            [get_shell_parameter PROJECT_PATH]
    set v_instance_name           [get_shell_parameter INSTANCE_NAME]

    # Video Pipeline
    set v_cppp                    {3}
    set v_vid_out_rate            [get_shell_parameter VID_OUT_RATE]
    set v_vid_out_bps             [get_shell_parameter VID_OUT_BPS]
    set v_pip                     [get_shell_parameter PIP]

    # ISP Pipeline
    set v_isp_cppp                {1}
    set v_isp_bps                 {12}

    # General
    set v_enable_debug            [get_shell_parameter EN_DEBUG]
    set v_pipeline_ready          {1}

    create_system ${v_instance_name}
    save_system   ${v_project_path}/rtl/user/${v_instance_name}.qsys
    load_system   ${v_project_path}/rtl/user/${v_instance_name}.qsys

    ############################
    #### Add Instances      ####
    ############################
    add_instance  isp_cpu_clk_bridge        altera_clock_bridge
    add_instance  isp_cpu_rst_bridge        altera_reset_bridge
    add_instance  isp_vid_clk_bridge        altera_clock_bridge
    add_instance  isp_vid_rst_bridge        altera_reset_bridge
    add_instance  isp_mm_bridge             altera_avalon_mm_bridge
    add_instance  isp_blc                   intel_vvp_blc
    add_instance  isp_wbc                   intel_vvp_wbc
    add_instance  isp_dms                   intel_vvp_demosaic
    add_instance  isp_ccm                   intel_vvp_csc

    ############################
    #### Set Parameters     ####
    ############################
    # isp_cpu_clk_bridge
    set_instance_parameter_value      isp_cpu_clk_bridge    EXPLICIT_CLOCK_RATE       {100000000.0}
    set_instance_parameter_value      isp_cpu_clk_bridge    NUM_CLOCK_OUTPUTS         {1}

    # isp_cpu_rst_bridge
    set_instance_parameter_value      isp_cpu_rst_bridge    ACTIVE_LOW_RESET          {0}
    set_instance_parameter_value      isp_cpu_rst_bridge    NUM_RESET_OUTPUTS         {1}
    set_instance_parameter_value      isp_cpu_rst_bridge    SYNCHRONOUS_EDGES         {deassert}
    set_instance_parameter_value      isp_cpu_rst_bridge    SYNC_RESET                {0}
    set_instance_parameter_value      isp_cpu_rst_bridge    USE_RESET_REQUEST         {0}

    # isp_mm_bridge
    set_instance_parameter_value      isp_mm_bridge       ADDRESS_UNITS                 {SYMBOLS}
    set_instance_parameter_value      isp_mm_bridge       ADDRESS_WIDTH                 {0}
    set_instance_parameter_value      isp_mm_bridge       DATA_WIDTH                    {32}
    set_instance_parameter_value      isp_mm_bridge       LINEWRAPBURSTS                {0}
    set_instance_parameter_value      isp_mm_bridge       M0_WAITREQUEST_ALLOWANCE      {0}
    set_instance_parameter_value      isp_mm_bridge       MAX_BURST_SIZE                {1}
    set_instance_parameter_value      isp_mm_bridge       MAX_PENDING_RESPONSES         {4}
    set_instance_parameter_value      isp_mm_bridge       MAX_PENDING_WRITES            {0}
    set_instance_parameter_value      isp_mm_bridge       PIPELINE_COMMAND              {1}
    set_instance_parameter_value      isp_mm_bridge       PIPELINE_RESPONSE             {1}
    set_instance_parameter_value      isp_mm_bridge       S0_WAITREQUEST_ALLOWANCE      {0}
    set_instance_parameter_value      isp_mm_bridge       SYMBOL_WIDTH                  {8}
    set_instance_parameter_value      isp_mm_bridge       SYNC_RESET                    {0}
    set_instance_parameter_value      isp_mm_bridge       USE_AUTO_ADDRESS_WIDTH        {1}
    set_instance_parameter_value      isp_mm_bridge       USE_RESPONSE                  {0}
    set_instance_parameter_value      isp_mm_bridge       USE_WRITERESPONSE             {0}

    # isp_vid_clk_bridge
    set_instance_parameter_value      isp_vid_clk_bridge  EXPLICIT_CLOCK_RATE           {297000000.0}
    set_instance_parameter_value      isp_vid_clk_bridge  NUM_CLOCK_OUTPUTS             {1}

    # isp_vid_rst_bridge
    set_instance_parameter_value      isp_vid_rst_bridge      ACTIVE_LOW_RESET        {0}
    set_instance_parameter_value      isp_vid_rst_bridge      NUM_RESET_OUTPUTS       {1}
    set_instance_parameter_value      isp_vid_rst_bridge      SYNCHRONOUS_EDGES       {deassert}
    set_instance_parameter_value      isp_vid_rst_bridge      SYNC_RESET              {0}
    set_instance_parameter_value      isp_vid_rst_bridge      USE_RESET_REQUEST       {0}

    # isp_blc
    set_instance_parameter_value      isp_blc       AV_MAX_PENDING_READS          {8}
    set_instance_parameter_value      isp_blc       BPS_IN                        ${v_isp_bps}
    set_instance_parameter_value      isp_blc       BPS_OUT                       ${v_isp_bps}
    set_instance_parameter_value      isp_blc       C_OMNI_CAP_ID_ASSOCIATED      {0}
    set_instance_parameter_value      isp_blc       C_OMNI_CAP_ID_COMPONENT       {0}
    set_instance_parameter_value      isp_blc       C_OMNI_CAP_IRQ                {255}
    set_instance_parameter_value      isp_blc       C_OMNI_CAP_IRQ_ENABLE         {0}
    set_instance_parameter_value      isp_blc       C_OMNI_CAP_IRQ_ENABLE_EN      {0}
    set_instance_parameter_value      isp_blc       C_OMNI_CAP_IRQ_STATUS         {0}
    set_instance_parameter_value      isp_blc       C_OMNI_CAP_IRQ_STATUS_EN      {0}
    set_instance_parameter_value      isp_blc       C_OMNI_CAP_TAG                {0}
    set_instance_parameter_value      isp_blc       C_OMNI_CAP_TYPE               {375}
    set_instance_parameter_value      isp_blc       C_OMNI_CAP_VERSION            {1}
    set_instance_parameter_value      isp_blc       DUPLICATE_AND_BYPASS          {0}
    set_instance_parameter_value      isp_blc       ENABLE_DEBUG                  ${v_enable_debug}
    set_instance_parameter_value      isp_blc       ENABLE_EXT_DATA_RW            {0}
    set_instance_parameter_value      isp_blc       EXTERNAL_MODE                 {1}
    set_instance_parameter_value      isp_blc       H_TAPS                        {1}
    set_instance_parameter_value      isp_blc       MAX_HEIGHT                    {4096}
    set_instance_parameter_value      isp_blc       MAX_WIDTH                     {4096}
    set_instance_parameter_value      isp_blc       NO_BLANKING                   {1}
    set_instance_parameter_value      isp_blc       NUMBER_OF_COLOR_PLANES_IN     ${v_isp_cppp}
    set_instance_parameter_value      isp_blc       NUMBER_OF_COLOR_PLANES_OUT    ${v_isp_cppp}
    set_instance_parameter_value      isp_blc       NUM_EXT_DATA_REGS             {0}
    set_instance_parameter_value      isp_blc       PIPELINE_DATA_MM              {0}
    set_instance_parameter_value      isp_blc       PIPELINE_READY                ${v_pipeline_ready}
    set_instance_parameter_value      isp_blc       PIXELS_IN_PARALLEL            ${v_pip}
    set_instance_parameter_value      isp_blc       P_CORE_CTRL_ID                {0}
    set_instance_parameter_value      isp_blc       P_UPDATE_CMD_SUPPORTED        {0}
    set_instance_parameter_value      isp_blc       REFLECT_AROUND_ZERO           {1}
    set_instance_parameter_value      isp_blc       RUNTIME_CONTROL               {1}
    set_instance_parameter_value      isp_blc       SEPARATE_SLAVE_CLOCK          {1}
    set_instance_parameter_value      isp_blc       SLAVE_PROTOCOL                {Avalon}
    set_instance_parameter_value      isp_blc       V_TAPS                        {1}

    # isp_wbc
    set_instance_parameter_value      isp_wbc       AV_MAX_PENDING_READS          {8}
    set_instance_parameter_value      isp_wbc       BPS_IN                        ${v_isp_bps}
    set_instance_parameter_value      isp_wbc       BPS_OUT                       ${v_isp_bps}
    set_instance_parameter_value      isp_wbc       C_OMNI_CAP_ID_ASSOCIATED      {0}
    set_instance_parameter_value      isp_wbc       C_OMNI_CAP_ID_COMPONENT       {0}
    set_instance_parameter_value      isp_wbc       C_OMNI_CAP_IRQ                {255}
    set_instance_parameter_value      isp_wbc       C_OMNI_CAP_IRQ_ENABLE         {0}
    set_instance_parameter_value      isp_wbc       C_OMNI_CAP_IRQ_ENABLE_EN      {0}
    set_instance_parameter_value      isp_wbc       C_OMNI_CAP_IRQ_STATUS         {0}
    set_instance_parameter_value      isp_wbc       C_OMNI_CAP_IRQ_STATUS_EN      {0}
    set_instance_parameter_value      isp_wbc       C_OMNI_CAP_TAG                {0}
    set_instance_parameter_value      isp_wbc       C_OMNI_CAP_TYPE               {378}
    set_instance_parameter_value      isp_wbc       C_OMNI_CAP_VERSION            {1}
    set_instance_parameter_value      isp_wbc       DUPLICATE_AND_BYPASS          {0}
    set_instance_parameter_value      isp_wbc       ENABLE_DEBUG                  ${v_enable_debug}
    set_instance_parameter_value      isp_wbc       ENABLE_EXT_DATA_RW            {0}
    set_instance_parameter_value      isp_wbc       EXTERNAL_MODE                 {1}
    set_instance_parameter_value      isp_wbc       H_TAPS                        {1}
    set_instance_parameter_value      isp_wbc       MAX_HEIGHT                    {4096}
    set_instance_parameter_value      isp_wbc       MAX_WIDTH                     {4096}
    set_instance_parameter_value      isp_wbc       NO_BLANKING                   {1}
    set_instance_parameter_value      isp_wbc       NUMBER_OF_COLOR_PLANES_IN     ${v_isp_cppp}
    set_instance_parameter_value      isp_wbc       NUMBER_OF_COLOR_PLANES_OUT    ${v_isp_cppp}
    set_instance_parameter_value      isp_wbc       NUM_EXT_DATA_REGS             {0}
    set_instance_parameter_value      isp_wbc       PIPELINE_DATA_MM              {0}
    set_instance_parameter_value      isp_wbc       PIPELINE_READY                ${v_pipeline_ready}
    set_instance_parameter_value      isp_wbc       PIXELS_IN_PARALLEL            ${v_pip}
    set_instance_parameter_value      isp_wbc       P_CORE_CTRL_ID                {0}
    set_instance_parameter_value      isp_wbc       P_UPDATE_CMD_SUPPORTED        {0}
    set_instance_parameter_value      isp_wbc       RUNTIME_CONTROL               {1}
    set_instance_parameter_value      isp_wbc       SEPARATE_SLAVE_CLOCK          {1}
    set_instance_parameter_value      isp_wbc       SLAVE_PROTOCOL                {Avalon}
    set_instance_parameter_value      isp_wbc       V_TAPS                        {1}

    # isp_dms
    set_instance_parameter_value      isp_dms       AV_MAX_PENDING_READS          {8}
    set_instance_parameter_value      isp_dms       BPS_IN                        ${v_isp_bps}
    set_instance_parameter_value      isp_dms       BPS_OUT                       ${v_isp_bps}
    set_instance_parameter_value      isp_dms       C_OMNI_CAP_ID_ASSOCIATED      {0}
    set_instance_parameter_value      isp_dms       C_OMNI_CAP_ID_COMPONENT       {0}
    set_instance_parameter_value      isp_dms       C_OMNI_CAP_IRQ                {255}
    set_instance_parameter_value      isp_dms       C_OMNI_CAP_IRQ_ENABLE         {0}
    set_instance_parameter_value      isp_dms       C_OMNI_CAP_IRQ_ENABLE_EN      {0}
    set_instance_parameter_value      isp_dms       C_OMNI_CAP_IRQ_STATUS         {0}
    set_instance_parameter_value      isp_dms       C_OMNI_CAP_IRQ_STATUS_EN      {0}
    set_instance_parameter_value      isp_dms       C_OMNI_CAP_TAG                {0}
    set_instance_parameter_value      isp_dms       C_OMNI_CAP_TYPE               {582}
    set_instance_parameter_value      isp_dms       C_OMNI_CAP_VERSION            {2}
    set_instance_parameter_value      isp_dms       DUPLICATE_AND_BYPASS          {0}
    set_instance_parameter_value      isp_dms       ENABLE_DEBUG                  ${v_enable_debug}
    set_instance_parameter_value      isp_dms       ENABLE_EXT_DATA_RW            {0}
    set_instance_parameter_value      isp_dms       EXTERNAL_MODE                 {1}
    set_instance_parameter_value      isp_dms       H_TAPS                        {5}
    set_instance_parameter_value      isp_dms       MAX_HEIGHT                    {4096}
    set_instance_parameter_value      isp_dms       MAX_WIDTH                     {4096}
    set_instance_parameter_value      isp_dms       NO_BLANKING                   {1}
    set_instance_parameter_value      isp_dms       NUMBER_OF_COLOR_PLANES_IN     ${v_isp_cppp}
    set_instance_parameter_value      isp_dms       NUMBER_OF_COLOR_PLANES_OUT    ${v_cppp}
    set_instance_parameter_value      isp_dms       NUM_EXT_DATA_REGS             {0}
    set_instance_parameter_value      isp_dms       PIPELINE_DATA_MM              {0}
    set_instance_parameter_value      isp_dms       PIPELINE_READY                ${v_pipeline_ready}
    set_instance_parameter_value      isp_dms       PIXELS_IN_PARALLEL            ${v_pip}
    set_instance_parameter_value      isp_dms       P_CORE_CTRL_ID                {0}
    set_instance_parameter_value      isp_dms       P_UPDATE_CMD_SUPPORTED        {0}
    set_instance_parameter_value      isp_dms       RUNTIME_CONTROL               {1}
    set_instance_parameter_value      isp_dms       SEPARATE_SLAVE_CLOCK          {1}
    set_instance_parameter_value      isp_dms       SLAVE_PROTOCOL                {Avalon}
    set_instance_parameter_value      isp_dms       V_TAPS                        {5}

    # isp_ccm
    set_instance_parameter_value      isp_ccm       BPS_IN                        ${v_isp_bps}
    set_instance_parameter_value      isp_ccm       BPS_OUT                       ${v_vid_out_bps}
    set_instance_parameter_value      isp_ccm       COEFFICIENT_INT_BITS          {8}
    set_instance_parameter_value      isp_ccm       COEFFICIENT_SIGNED            {1}
    set_instance_parameter_value      isp_ccm       COEF_SUM_FRACTION_BITS        {8}
    set_instance_parameter_value      isp_ccm       C_OMNI_CAP_ID_ASSOCIATED      {0}
    set_instance_parameter_value      isp_ccm       C_OMNI_CAP_ID_COMPONENT       {1}
    set_instance_parameter_value      isp_ccm       C_OMNI_CAP_IRQ                {255}
    set_instance_parameter_value      isp_ccm       C_OMNI_CAP_IRQ_ENABLE         {0}
    set_instance_parameter_value      isp_ccm       C_OMNI_CAP_IRQ_ENABLE_EN      {0}
    set_instance_parameter_value      isp_ccm       C_OMNI_CAP_IRQ_STATUS         {0}
    set_instance_parameter_value      isp_ccm       C_OMNI_CAP_IRQ_STATUS_EN      {0}
    set_instance_parameter_value      isp_ccm       C_OMNI_CAP_TAG                {0}
    set_instance_parameter_value      isp_ccm       C_OMNI_CAP_TYPE               {559}
    set_instance_parameter_value      isp_ccm       C_OMNI_CAP_VERSION            {1}
    set_instance_parameter_value      isp_ccm       ENABLE_DEBUG                  ${v_enable_debug}
    set_instance_parameter_value      isp_ccm       EXTERNAL_MODE                 {1}
    set_instance_parameter_value      isp_ccm       MOVE_BINARY_POINT_RIGHT       {0}
    set_instance_parameter_value      isp_ccm       OUTPUT_COLORSPACE             {0}
    set_instance_parameter_value      isp_ccm       PIPELINE_READY                ${v_pipeline_ready}
    set_instance_parameter_value      isp_ccm       PIXELS_IN_PARALLEL            ${v_pip}
    set_instance_parameter_value      isp_ccm       P_CORE_CTRL_ID                {0}
    set_instance_parameter_value      isp_ccm       P_UPDATE_CMD_SUPPORTED        {0}
    set_instance_parameter_value      isp_ccm       REMOVE_FRACTION_METHOD        {1}
    set_instance_parameter_value      isp_ccm       REQ_FCOEFF_A0                 {1.0}
    set_instance_parameter_value      isp_ccm       REQ_FCOEFF_A1                 {0.0}
    set_instance_parameter_value      isp_ccm       REQ_FCOEFF_A2                 {0.0}
    set_instance_parameter_value      isp_ccm       REQ_FCOEFF_B0                 {0.0}
    set_instance_parameter_value      isp_ccm       REQ_FCOEFF_B1                 {1.0}
    set_instance_parameter_value      isp_ccm       REQ_FCOEFF_B2                 {0.0}
    set_instance_parameter_value      isp_ccm       REQ_FCOEFF_C0                 {0.0}
    set_instance_parameter_value      isp_ccm       REQ_FCOEFF_C1                 {0.0}
    set_instance_parameter_value      isp_ccm       REQ_FCOEFF_C2                 {1.0}
    set_instance_parameter_value      isp_ccm       REQ_FCOEFF_S0                 {0.0}
    set_instance_parameter_value      isp_ccm       REQ_FCOEFF_S1                 {0.0}
    set_instance_parameter_value      isp_ccm       REQ_FCOEFF_S2                 {0.0}
    set_instance_parameter_value      isp_ccm       RUNTIME_CONTROL               {1}
    set_instance_parameter_value      isp_ccm       SEPARATE_SLAVE_CLOCK          {1}
    set_instance_parameter_value      isp_ccm       SLAVE_PROTOCOL                {Avalon}
    set_instance_parameter_value      isp_ccm       SUMMAND_INT_BITS              {10}
    set_instance_parameter_value      isp_ccm       SUMMAND_SIGNED                {1}

    ############################
    #### Create Connections ####
    ############################
    # isp_cpu_clk_bridge
    add_connection         isp_cpu_clk_bridge.out_clk           isp_cpu_rst_bridge.clk
    add_connection         isp_cpu_clk_bridge.out_clk           isp_mm_bridge.clk
    add_connection         isp_cpu_clk_bridge.out_clk           isp_blc.agent_clock
    add_connection         isp_cpu_clk_bridge.out_clk           isp_wbc.agent_clock
    add_connection         isp_cpu_clk_bridge.out_clk           isp_dms.agent_clock
    add_connection         isp_cpu_clk_bridge.out_clk           isp_ccm.agent_clock

    # isp_cpu_rst_bridge
    add_connection         isp_cpu_rst_bridge.out_reset         isp_mm_bridge.reset
    add_connection         isp_cpu_rst_bridge.out_reset         isp_blc.agent_reset
    add_connection         isp_cpu_rst_bridge.out_reset         isp_wbc.agent_reset
    add_connection         isp_cpu_rst_bridge.out_reset         isp_dms.agent_reset
    add_connection         isp_cpu_rst_bridge.out_reset         isp_ccm.agent_reset

    # isp_vid_clk_bridge
    add_connection         isp_vid_clk_bridge.out_clk           isp_vid_rst_bridge.clk
    add_connection         isp_vid_clk_bridge.out_clk           isp_blc.main_clock
    add_connection         isp_vid_clk_bridge.out_clk           isp_wbc.main_clock
    add_connection         isp_vid_clk_bridge.out_clk           isp_dms.main_clock
    add_connection         isp_vid_clk_bridge.out_clk           isp_ccm.main_clock

    # isp_vid_rst_bridge
    add_connection         isp_vid_rst_bridge.out_reset         isp_blc.main_reset
    add_connection         isp_vid_rst_bridge.out_reset         isp_wbc.main_reset
    add_connection         isp_vid_rst_bridge.out_reset         isp_dms.main_reset
    add_connection         isp_vid_rst_bridge.out_reset         isp_ccm.main_reset

    # isp_mm_bridge
    add_connection          isp_mm_bridge.m0                    isp_blc.av_mm_control_agent
    add_connection          isp_mm_bridge.m0                    isp_wbc.av_mm_control_agent
    add_connection          isp_mm_bridge.m0                    isp_dms.av_mm_control_agent
    add_connection          isp_mm_bridge.m0                    isp_ccm.av_mm_control_agent

    # isp_blc
    add_connection          isp_blc.axi4s_vid_out               isp_wbc.axi4s_vid_in

    # isp_wbc
    add_connection          isp_wbc.axi4s_vid_out               isp_dms.axi4s_vid_in

    # isp_dms
    add_connection          isp_dms.axi4s_vid_out               isp_ccm.axi4s_vid_in

    ##########################
    ##### Create Exports #####
    ##########################
    # isp_cpu_clk_bridge
    add_interface           cpu_clk_in          clock       sink
    set_interface_property  cpu_clk_in          EXPORT_OF   isp_cpu_clk_bridge.in_clk

    # isp_cpu_rst_bridge
    add_interface           cpu_rst_in          reset       sink
    set_interface_property  cpu_rst_in          EXPORT_OF   isp_cpu_rst_bridge.in_reset

    # isp_vid_clk_bridge
    set_interface_property  vid_clk_in          EXPORT_OF   isp_vid_clk_bridge.in_clk

    # isp_vid_rst_bridge
    set_interface_property  vid_rst_in          EXPORT_OF   isp_vid_rst_bridge.in_reset

    # isp_mm_bridge
    add_interface           mm_ctrl_in          avalon      slave
    set_interface_property  mm_ctrl_in          EXPORT_OF   isp_mm_bridge.s0

    # isp_blc
    add_interface           isp_in_s_vid_axis   axi4stream  subordinate
    set_interface_property  isp_in_s_vid_axis   EXPORT_OF   isp_blc.axi4s_vid_in

    # isp_ccm
    add_interface           isp_out_m_vid_axis  axi4stream  manager
    set_interface_property  isp_out_m_vid_axis  EXPORT_OF   isp_ccm.axi4s_vid_out

    #################################
    ##### Sync / Validation     #####
    ##### Assign Base Addresses #####
    #################################
    sync_sysinfo_parameters
    auto_assign_system_base_addresses
    save_system

}

proc  edit_top_level_qsys {} {
    set v_project_name      [get_shell_parameter PROJECT_NAME]
    set v_project_path      [get_shell_parameter PROJECT_PATH]
    set v_instance_name     [get_shell_parameter INSTANCE_NAME]

    load_system ${v_project_path}/rtl/${v_project_name}_qsys.qsys
    add_instance ${v_instance_name} ${v_instance_name}
    sync_sysinfo_parameters
    save_system
}

proc add_auto_connections {} {
    set v_instance_name       [get_shell_parameter INSTANCE_NAME]
    set v_avmm_host           [get_shell_parameter AVMM_HOST]
    set v_vid_out_rate        [get_shell_parameter VID_OUT_RATE]
    set v_pip                 [get_shell_parameter PIP]

    add_auto_connection   ${v_instance_name} cpu_clk_in       100000000
    add_auto_connection   ${v_instance_name} cpu_rst_in       100000000
    add_auto_connection   ${v_instance_name} vid_clk_in       297000000
    add_auto_connection   ${v_instance_name} vid_rst_in       297000000

    # from isp in
    add_auto_connection   ${v_instance_name} isp_in_s_vid_axis     isp_in_vid_axis

    # to vid out
    add_auto_connection   ${v_instance_name} isp_out_m_vid_axis    isp_out_vid_axis

    # NiosV to mm bridge
    add_avmm_connections  mm_ctrl_in      ${v_avmm_host}
}
