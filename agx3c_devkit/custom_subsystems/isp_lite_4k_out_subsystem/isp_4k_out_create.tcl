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
set_shell_parameter VID_OUT_BPS             {10}
set_shell_parameter EN_DEBUG                {1}

proc pre_creation_step {} {
    transfer_files
}

proc creation_step {} {
    create_isp_subsystem
}

proc post_creation_step {} {
    edit_top_level_qsys
    add_auto_connections
}

proc transfer_files {} {
    set v_project_path              [get_shell_parameter PROJECT_PATH]
    set v_script_path               [get_shell_parameter SUBSYSTEM_SOURCE_PATH]

    # Copy Icon
    exec cp -rf ${v_script_path}/../../non_qpds_ip/intel_vvp_icon \
                                                      ${v_project_path}/non_qpds_ip/user/intel_vvp_icon
    file_copy   ${v_script_path}/../../non_qpds_ip/intel_vvp_icon.ipx     ${v_project_path}/non_qpds_ip/user
}

proc create_isp_subsystem {} {
    set v_project_path            [get_shell_parameter PROJECT_PATH]
    set v_instance_name           [get_shell_parameter INSTANCE_NAME]

    # Video Pipeline
    set v_cppp                    {3}
    set v_vid_out_bps             [get_shell_parameter VID_OUT_BPS]
    set v_pip                     [get_shell_parameter PIP]

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
    add_instance  isp_vid_clk_out_bridge    altera_clock_bridge
    add_instance  isp_vid_rst_out_bridge    altera_reset_bridge
    add_instance  isp_emif_clk_bridge       altera_clock_bridge
    add_instance  isp_emif_rst_bridge       altera_reset_bridge
    add_instance  isp_mm_bridge             altera_avalon_mm_bridge
    add_instance  isp_tpg                   intel_vvp_tpg
    add_instance  isp_vfb                   intel_vvp_vfb
    add_instance  isp_se_vfb                altera_address_span_extender
    add_instance  isp_icon                  intel_vvp_icon
    add_instance  isp_mixer                 intel_vvp_mixer
    add_instance  isp_1d_lut                intel_vvp_1d_lut
    add_instance  vid_out_pip_conv          intel_vvp_pip_conv
    add_instance  isp_out_proto_conv        intel_vvp_protocol_conv

    ############################
    #### Set Parameters     ####
    ############################
    # isp_cpu_clk_bridge
    set_instance_parameter_value      isp_cpu_clk_bridge        EXPLICIT_CLOCK_RATE             {100000000.0}
    set_instance_parameter_value      isp_cpu_clk_bridge        NUM_CLOCK_OUTPUTS               {1}

    # isp_cpu_rst_bridge
    set_instance_parameter_value      isp_cpu_rst_bridge        ACTIVE_LOW_RESET                {0}
    set_instance_parameter_value      isp_cpu_rst_bridge        NUM_RESET_OUTPUTS               {1}
    set_instance_parameter_value      isp_cpu_rst_bridge        SYNCHRONOUS_EDGES               {deassert}
    set_instance_parameter_value      isp_cpu_rst_bridge        SYNC_RESET                      {0}
    set_instance_parameter_value      isp_cpu_rst_bridge        USE_RESET_REQUEST               {0}

    # isp_vid_clk_bridge
    set_instance_parameter_value      isp_vid_clk_bridge        EXPLICIT_CLOCK_RATE             {297000000.0}
    set_instance_parameter_value      isp_vid_clk_bridge        NUM_CLOCK_OUTPUTS               {1}

    # isp_vid_rst_bridge
    set_instance_parameter_value      isp_vid_rst_bridge        ACTIVE_LOW_RESET                {0}
    set_instance_parameter_value      isp_vid_rst_bridge        NUM_RESET_OUTPUTS               {1}
    set_instance_parameter_value      isp_vid_rst_bridge        SYNCHRONOUS_EDGES               {deassert}
    set_instance_parameter_value      isp_vid_rst_bridge        SYNC_RESET                      {0}
    set_instance_parameter_value      isp_vid_rst_bridge        USE_RESET_REQUEST               {0}

    # isp_vid_clk_out_bridge
    set_instance_parameter_value      isp_vid_clk_out_bridge    EXPLICIT_CLOCK_RATE             {148500000.0}
    set_instance_parameter_value      isp_vid_clk_out_bridge    NUM_CLOCK_OUTPUTS               {1}

    # isp_vid_rst_out_bridge
    set_instance_parameter_value      isp_vid_rst_out_bridge    ACTIVE_LOW_RESET                {0}
    set_instance_parameter_value      isp_vid_rst_out_bridge    NUM_RESET_OUTPUTS               {1}
    set_instance_parameter_value      isp_vid_rst_out_bridge    SYNCHRONOUS_EDGES               {deassert}
    set_instance_parameter_value      isp_vid_rst_out_bridge    SYNC_RESET                      {0}
    set_instance_parameter_value      isp_vid_rst_out_bridge    USE_RESET_REQUEST               {0}

    # isp_emif_clk_bridge
    set_instance_parameter_value      isp_emif_clk_bridge       EXPLICIT_CLOCK_RATE             {170000000.0}
    set_instance_parameter_value      isp_emif_clk_bridge       NUM_CLOCK_OUTPUTS               {1}

    # isp_emif_rst_bridge
    set_instance_parameter_value      isp_emif_rst_bridge       ACTIVE_LOW_RESET                {1}
    set_instance_parameter_value      isp_emif_rst_bridge       NUM_RESET_OUTPUTS               {1}
    set_instance_parameter_value      isp_emif_rst_bridge       SYNCHRONOUS_EDGES               {deassert}
    set_instance_parameter_value      isp_emif_rst_bridge       SYNC_RESET                      {0}
    set_instance_parameter_value      isp_emif_rst_bridge       USE_RESET_REQUEST               {0}

    # isp_mm_bridge
    set_instance_parameter_value      isp_mm_bridge             ADDRESS_UNITS                   {SYMBOLS}
    set_instance_parameter_value      isp_mm_bridge             ADDRESS_WIDTH                   {0}
    set_instance_parameter_value      isp_mm_bridge             DATA_WIDTH                      {32}
    set_instance_parameter_value      isp_mm_bridge             LINEWRAPBURSTS                  {0}
    set_instance_parameter_value      isp_mm_bridge             M0_WAITREQUEST_ALLOWANCE        {0}
    set_instance_parameter_value      isp_mm_bridge             MAX_BURST_SIZE                  {1}
    set_instance_parameter_value      isp_mm_bridge             MAX_PENDING_RESPONSES           {4}
    set_instance_parameter_value      isp_mm_bridge             MAX_PENDING_WRITES              {0}
    set_instance_parameter_value      isp_mm_bridge             PIPELINE_COMMAND                {1}
    set_instance_parameter_value      isp_mm_bridge             PIPELINE_RESPONSE               {1}
    set_instance_parameter_value      isp_mm_bridge             S0_WAITREQUEST_ALLOWANCE        {0}
    set_instance_parameter_value      isp_mm_bridge             SYMBOL_WIDTH                    {8}
    set_instance_parameter_value      isp_mm_bridge             SYNC_RESET                      {0}
    set_instance_parameter_value      isp_mm_bridge             USE_AUTO_ADDRESS_WIDTH          {1}
    set_instance_parameter_value      isp_mm_bridge             USE_RESPONSE                    {0}
    set_instance_parameter_value      isp_mm_bridge             USE_WRITERESPONSE               {0}

    # isp_vfb
    set_instance_parameter_value      isp_vfb                   BPS                             ${v_vid_out_bps}
    set_instance_parameter_value      isp_vfb                   CLOCKS_ARE_SEPARATE             {1}
    set_instance_parameter_value      isp_vfb                   C_OMNI_CAP_ID_ASSOCIATED        {0}
    set_instance_parameter_value      isp_vfb                   C_OMNI_CAP_ID_COMPONENT         {0}
    set_instance_parameter_value      isp_vfb                   C_OMNI_CAP_IRQ                  {255}
    set_instance_parameter_value      isp_vfb                   C_OMNI_CAP_IRQ_ENABLE           {0}
    set_instance_parameter_value      isp_vfb                   C_OMNI_CAP_IRQ_ENABLE_EN        {0}
    set_instance_parameter_value      isp_vfb                   C_OMNI_CAP_IRQ_STATUS           {0}
    set_instance_parameter_value      isp_vfb                   C_OMNI_CAP_IRQ_STATUS_EN        {0}
    set_instance_parameter_value      isp_vfb                   C_OMNI_CAP_TAG                  {0}
    set_instance_parameter_value      isp_vfb                   C_OMNI_CAP_TYPE                 {567}
    set_instance_parameter_value      isp_vfb                   C_OMNI_CAP_VERSION              {1}
    set_instance_parameter_value      isp_vfb                   DROP_BROKEN_FRAMES              {1}
    set_instance_parameter_value      isp_vfb                   DROP_RPT_AUX_PKTS_WITH_FRAMES   {0}
    set_instance_parameter_value      isp_vfb                   ENABLE_DEBUG                    ${v_enable_debug}
    set_instance_parameter_value      isp_vfb                   EXTERNAL_MODE                   {1}
    set_instance_parameter_value      isp_vfb                   FRAME_DROP_ENABLE               {1}
    set_instance_parameter_value      isp_vfb                   FRAME_REPEAT_ENABLE             {1}
    set_instance_parameter_value      isp_vfb                   MAX_CONTROL_PACKETS             {0}
    set_instance_parameter_value      isp_vfb                   MAX_HEIGHT                      {4096}
    set_instance_parameter_value      isp_vfb                   MAX_WIDTH                       {4096}
    set_instance_parameter_value      isp_vfb                   MEM_BUFF_BASE_ADDR              {0}
    set_instance_parameter_value      isp_vfb                   MEM_BUFF_LINE_STRIDE            {49152}
    set_instance_parameter_value      isp_vfb                   MEM_BUFF_STRIDE                 {268435456}
    set_instance_parameter_value      isp_vfb                   NUMBER_OF_COLOR_PLANES          ${v_cppp}
    set_instance_parameter_value      isp_vfb                   PACKING                         {PERFECT}
    set_instance_parameter_value      isp_vfb                   PIXELS_IN_PARALLEL              ${v_pip}
    set_instance_parameter_value      isp_vfb                   P_AV_MM_ADDR_WIDTH              {32}
    set_instance_parameter_value      isp_vfb                   P_AV_MM_DATA_WIDTH              {256}
    set_instance_parameter_value      isp_vfb                   READ_BURST_TARGET               {64}
    set_instance_parameter_value      isp_vfb                   READ_FIFO_DEPTH                 {512}
    set_instance_parameter_value      isp_vfb                   WRITE_BURST_TARGET              {64}
    set_instance_parameter_value      isp_vfb                   WRITE_FIFO_DEPTH                {512}
    set_instance_parameter_value      isp_vfb                   RUNTIME_CONTROL                 {1}
    set_instance_parameter_value      isp_vfb                   SEPARATE_SLAVE_CLOCK            {1}

    # isp_se_vfb
    set_instance_parameter_value      isp_se_vfb                BURSTCOUNT_WIDTH                {7}
    set_instance_parameter_value      isp_se_vfb                DATA_WIDTH                      {256}
    set_instance_parameter_value      isp_se_vfb                ENABLE_SLAVE_PORT               {0}
    set_instance_parameter_value      isp_se_vfb                MASTER_ADDRESS_DEF              {0}
    set_instance_parameter_value      isp_se_vfb                MASTER_ADDRESS_WIDTH            {33}
    set_instance_parameter_value      isp_se_vfb                MAX_PENDING_READS               {8}
    set_instance_parameter_value      isp_se_vfb                SLAVE_ADDRESS_WIDTH             {27}
    set_instance_parameter_value      isp_se_vfb                SUB_WINDOW_COUNT                {1}
    set_instance_parameter_value      isp_se_vfb                SYNC_RESET                      {0}

    # isp_tpg
    set_instance_parameter_value      isp_tpg                   BINARY_DISPLAY_MODE             {Seconds}
    set_instance_parameter_value      isp_tpg                   BPS                             ${v_vid_out_bps}
    set_instance_parameter_value      isp_tpg                   CORE_COL_SPACE_0                {0}
    set_instance_parameter_value      isp_tpg                   CORE_COL_SPACE_1                {0}
    set_instance_parameter_value      isp_tpg                   CORE_COL_SPACE_2                {0}
    set_instance_parameter_value      isp_tpg                   CORE_COL_SPACE_3                {0}
    set_instance_parameter_value      isp_tpg                   CORE_COL_SPACE_4                {0}
    set_instance_parameter_value      isp_tpg                   CORE_COL_SPACE_5                {0}
    set_instance_parameter_value      isp_tpg                   CORE_COL_SPACE_6                {0}
    set_instance_parameter_value      isp_tpg                   CORE_COL_SPACE_7                {0}
    set_instance_parameter_value      isp_tpg                   CORE_PATTERN_0                  {1}
    set_instance_parameter_value      isp_tpg                   CORE_PATTERN_1                  {0}
    set_instance_parameter_value      isp_tpg                   CORE_PATTERN_2                  {0}
    set_instance_parameter_value      isp_tpg                   CORE_PATTERN_3                  {0}
    set_instance_parameter_value      isp_tpg                   CORE_PATTERN_4                  {0}
    set_instance_parameter_value      isp_tpg                   CORE_PATTERN_5                  {0}
    set_instance_parameter_value      isp_tpg                   CORE_PATTERN_6                  {0}
    set_instance_parameter_value      isp_tpg                   CORE_PATTERN_7                  {0}
    set_instance_parameter_value      isp_tpg                   C_OMNI_CAP_ID_ASSOCIATED        {0}
    set_instance_parameter_value      isp_tpg                   C_OMNI_CAP_ID_COMPONENT         {1}
    set_instance_parameter_value      isp_tpg                   C_OMNI_CAP_IRQ                  {255}
    set_instance_parameter_value      isp_tpg                   C_OMNI_CAP_IRQ_ENABLE           {0}
    set_instance_parameter_value      isp_tpg                   C_OMNI_CAP_IRQ_ENABLE_EN        {0}
    set_instance_parameter_value      isp_tpg                   C_OMNI_CAP_IRQ_STATUS           {0}
    set_instance_parameter_value      isp_tpg                   C_OMNI_CAP_IRQ_STATUS_EN        {0}
    set_instance_parameter_value      isp_tpg                   C_OMNI_CAP_TAG                  {0}
    set_instance_parameter_value      isp_tpg                   C_OMNI_CAP_TYPE                 {566}
    set_instance_parameter_value      isp_tpg                   C_OMNI_CAP_VERSION              {1}
    set_instance_parameter_value      isp_tpg                   ENABLE_CTRL_IN                  {0}
    set_instance_parameter_value      isp_tpg                   ENABLE_DEBUG                    ${v_enable_debug}
    set_instance_parameter_value      isp_tpg                   EXTERNAL_MODE                   {1}
    set_instance_parameter_value      isp_tpg                   FIXED_BARS_MODE                 {0}
    set_instance_parameter_value      isp_tpg                   FIXED_B_BACKGROUND              {0}
    set_instance_parameter_value      isp_tpg                   FIXED_B_CB                      {16}
    set_instance_parameter_value      isp_tpg                   FIXED_B_FONT                    {255}
    set_instance_parameter_value      isp_tpg                   FIXED_FINE_FACTOR               {256}
    set_instance_parameter_value      isp_tpg                   FIXED_FPS                       {60}
    set_instance_parameter_value      isp_tpg                   FIXED_G_BACKGROUND              {0}
    set_instance_parameter_value      isp_tpg                   FIXED_G_FONT                    {255}
    set_instance_parameter_value      isp_tpg                   FIXED_G_Y                       {16}
    set_instance_parameter_value      isp_tpg                   FIXED_HEIGHT                    {16384}
    set_instance_parameter_value      isp_tpg                   FIXED_INTERLACE                 {0}
    set_instance_parameter_value      isp_tpg                   FIXED_LOCATION_X                {0}
    set_instance_parameter_value      isp_tpg                   FIXED_LOCATION_Y                {0}
    set_instance_parameter_value      isp_tpg                   FIXED_POWER_FACTOR              {16}
    set_instance_parameter_value      isp_tpg                   FIXED_R_BACKGROUND              {0}
    set_instance_parameter_value      isp_tpg                   FIXED_R_CR                      {16}
    set_instance_parameter_value      isp_tpg                   FIXED_R_FONT                    {255}
    set_instance_parameter_value      isp_tpg                   FIXED_SCALE_FACTOR              {1}
    set_instance_parameter_value      isp_tpg                   FIXED_WIDTH                     {16384}
    set_instance_parameter_value      isp_tpg                   NUM_CORES                       {1}
    set_instance_parameter_value      isp_tpg                   OUTPUT_FORMAT                   {4.4.4}
    set_instance_parameter_value      isp_tpg                   PIPELINE_READY                  ${v_pipeline_ready}
    set_instance_parameter_value      isp_tpg                   PIXELS_IN_PARALLEL              ${v_pip}
    set_instance_parameter_value      isp_tpg                   RUNTIME_CONTROL                 {1}
    set_instance_parameter_value      isp_tpg                   SEPARATE_SLAVE_CLOCK            {1}
    set_instance_parameter_value      isp_tpg                   SLAVE_PROTOCOL                  {Avalon}

    # isp_icon
    set_instance_parameter_value      isp_icon                  BPS                             ${v_vid_out_bps}
    set_instance_parameter_value      isp_icon                  EXTERNAL_MODE                   {1}
    set_instance_parameter_value      isp_icon                  PIPELINE_READY                  ${v_pipeline_ready}
    set_instance_parameter_value      isp_icon                  PIXELS_IN_PARALLEL              ${v_pip}

    # isp_mixer
    set_instance_parameter_value      isp_mixer                 NUM_LAYERS                      {3}
    set_instance_parameter_value      isp_mixer                 BLENDING_MODE_1                 {1}
    set_instance_parameter_value      isp_mixer                 BLENDING_MODE_2                 {1}
    set_instance_parameter_value      isp_mixer                 BLENDING_MODE_3                 {1}
    set_instance_parameter_value      isp_mixer                 RESTRICTED_OFFSETS_3            {0}
    set_instance_parameter_value      isp_mixer                 BLENDING_MODE_4                 {0}
    set_instance_parameter_value      isp_mixer                 BLENDING_MODE_5                 {0}
    set_instance_parameter_value      isp_mixer                 BLENDING_MODE_6                 {0}
    set_instance_parameter_value      isp_mixer                 BLENDING_MODE_7                 {0}
    set_instance_parameter_value      isp_mixer                 BPS                             ${v_vid_out_bps}
    set_instance_parameter_value      isp_mixer                 C_OMNI_CAP_ID_ASSOCIATED        {0}
    set_instance_parameter_value      isp_mixer                 C_OMNI_CAP_ID_COMPONENT         {0}
    set_instance_parameter_value      isp_mixer                 C_OMNI_CAP_IRQ                  {255}
    set_instance_parameter_value      isp_mixer                 C_OMNI_CAP_IRQ_ENABLE           {0}
    set_instance_parameter_value      isp_mixer                 C_OMNI_CAP_IRQ_ENABLE_EN        {0}
    set_instance_parameter_value      isp_mixer                 C_OMNI_CAP_IRQ_STATUS           {0}
    set_instance_parameter_value      isp_mixer                 C_OMNI_CAP_IRQ_STATUS_EN        {0}
    set_instance_parameter_value      isp_mixer                 C_OMNI_CAP_TAG                  {0}
    set_instance_parameter_value      isp_mixer                 C_OMNI_CAP_TYPE                 {563}
    set_instance_parameter_value      isp_mixer                 C_OMNI_CAP_VERSION              {1}
    set_instance_parameter_value      isp_mixer                 DO_ROUNDING                     {0}
    set_instance_parameter_value      isp_mixer                 ENABLE_DEBUG                    ${v_enable_debug}
    set_instance_parameter_value      isp_mixer                 EXPORT_PROBES                   {0}
    set_instance_parameter_value      isp_mixer                 EXTERNAL_MODE                   {1}
    set_instance_parameter_value      isp_mixer                 NUMBER_OF_COLOR_PLANES          ${v_cppp}
    set_instance_parameter_value      isp_mixer                 PIPELINE_LEVEL                  {2}
    set_instance_parameter_value      isp_mixer                 PIXELS_IN_PARALLEL              ${v_pip}
    set_instance_parameter_value      isp_mixer                 P_CORE_CTRL_ID                  {0}
    set_instance_parameter_value      isp_mixer                 P_UPDATE_CMD_SUPPORTED          {0}
    set_instance_parameter_value      isp_mixer                 RESTRICTED_OFFSETS_1            {0}
    set_instance_parameter_value      isp_mixer                 RESTRICTED_OFFSETS_2            {0}
    set_instance_parameter_value      isp_mixer                 RESTRICTED_OFFSETS_4            {0}
    set_instance_parameter_value      isp_mixer                 RESTRICTED_OFFSETS_5            {0}
    set_instance_parameter_value      isp_mixer                 RESTRICTED_OFFSETS_6            {0}
    set_instance_parameter_value      isp_mixer                 RESTRICTED_OFFSETS_7            {0}
    set_instance_parameter_value      isp_mixer                 RUNTIME_CONTROL                 {1}
    set_instance_parameter_value      isp_mixer                 SEPARATE_SLAVE_CLOCK            {1}
    set_instance_parameter_value      isp_mixer                 SLAVE_PROTOCOL                  {Avalon}

    # isp_1d_lut
    set_instance_parameter_value      isp_1d_lut                AV_MAX_PENDING_READS            {8}
    set_instance_parameter_value      isp_1d_lut                BITS_LUT                        {9}
    set_instance_parameter_value      isp_1d_lut                BITS_STEP                       {2}
    set_instance_parameter_value      isp_1d_lut                BPS_IN                          ${v_vid_out_bps}
    set_instance_parameter_value      isp_1d_lut                BPS_OUT                         ${v_vid_out_bps}
    set_instance_parameter_value      isp_1d_lut                C_OMNI_CAP_ID_ASSOCIATED        {0}
    set_instance_parameter_value      isp_1d_lut                C_OMNI_CAP_ID_COMPONENT         {0}
    set_instance_parameter_value      isp_1d_lut                C_OMNI_CAP_IRQ                  {255}
    set_instance_parameter_value      isp_1d_lut                C_OMNI_CAP_IRQ_ENABLE           {0}
    set_instance_parameter_value      isp_1d_lut                C_OMNI_CAP_IRQ_ENABLE_EN        {0}
    set_instance_parameter_value      isp_1d_lut                C_OMNI_CAP_IRQ_STATUS           {0}
    set_instance_parameter_value      isp_1d_lut                C_OMNI_CAP_IRQ_STATUS_EN        {0}
    set_instance_parameter_value      isp_1d_lut                C_OMNI_CAP_TAG                  {0}
    set_instance_parameter_value      isp_1d_lut                C_OMNI_CAP_TYPE                 {381}
    set_instance_parameter_value      isp_1d_lut                C_OMNI_CAP_VERSION              {1}
    set_instance_parameter_value      isp_1d_lut                DUPLICATE_AND_BYPASS            {0}
    set_instance_parameter_value      isp_1d_lut                ENABLE_DEBUG                    ${v_enable_debug}
    set_instance_parameter_value      isp_1d_lut                ENABLE_EXT_DATA_RW              {0}
    set_instance_parameter_value      isp_1d_lut                EQUIDISTANT                     {0}
    set_instance_parameter_value      isp_1d_lut                EXTERNAL_MODE                   {1}
    set_instance_parameter_value      isp_1d_lut                H_TAPS                          {1}
    set_instance_parameter_value      isp_1d_lut                MAX_HEIGHT                      {4096}
    set_instance_parameter_value      isp_1d_lut                MAX_WIDTH                       {4096}
    set_instance_parameter_value      isp_1d_lut                NO_BLANKING                     {1}
    set_instance_parameter_value      isp_1d_lut                NUMBER_OF_COLOR_PLANES          ${v_cppp}
    set_instance_parameter_value      isp_1d_lut                PIPELINE_DATA_MM                {0}
    set_instance_parameter_value      isp_1d_lut                PIPELINE_READY                  ${v_pipeline_ready}
    set_instance_parameter_value      isp_1d_lut                PIXELS_IN_PARALLEL              ${v_pip}
    set_instance_parameter_value      isp_1d_lut                P_CORE_CTRL_ID                  {0}
    set_instance_parameter_value      isp_1d_lut                P_UPDATE_CMD_SUPPORTED          {0}
    set_instance_parameter_value      isp_1d_lut                REVERSE_LUT                     {0}
    set_instance_parameter_value      isp_1d_lut                RUNTIME_CONTROL                 {1}
    set_instance_parameter_value      isp_1d_lut                SEPARATE_SLAVE_CLOCK            {1}
    set_instance_parameter_value      isp_1d_lut                SLAVE_PROTOCOL                  {Avalon}
    set_instance_parameter_value      isp_1d_lut                V_TAPS                          {1}

    # vid_out_pip_conv
    set_instance_parameter_value      vid_out_pip_conv          BPS                             ${v_vid_out_bps}
    set_instance_parameter_value      vid_out_pip_conv          C_OMNI_CAP_ID_ASSOCIATED        {0}
    set_instance_parameter_value      vid_out_pip_conv          C_OMNI_CAP_ID_COMPONENT         {2}
    set_instance_parameter_value      vid_out_pip_conv          C_OMNI_CAP_IRQ                  {255}
    set_instance_parameter_value      vid_out_pip_conv          C_OMNI_CAP_IRQ_ENABLE           {0}
    set_instance_parameter_value      vid_out_pip_conv          C_OMNI_CAP_IRQ_ENABLE_EN        {0}
    set_instance_parameter_value      vid_out_pip_conv          C_OMNI_CAP_IRQ_STATUS           {0}
    set_instance_parameter_value      vid_out_pip_conv          C_OMNI_CAP_IRQ_STATUS_EN        {0}
    set_instance_parameter_value      vid_out_pip_conv          C_OMNI_CAP_TAG                  {0}
    set_instance_parameter_value      vid_out_pip_conv          C_OMNI_CAP_TYPE                 {569}
    set_instance_parameter_value      vid_out_pip_conv          C_OMNI_CAP_VERSION              {1}
    set_instance_parameter_value      vid_out_pip_conv          DUAL_CLOCK                      {1}
    set_instance_parameter_value      vid_out_pip_conv          FIFO_DEPTH                      {2048}
    set_instance_parameter_value      vid_out_pip_conv          ENABLE_DEBUG                    ${v_enable_debug}
    set_instance_parameter_value      vid_out_pip_conv          EXTERNAL_MODE                   {1}
    set_instance_parameter_value      vid_out_pip_conv          NUMBER_OF_COLOR_PLANES          ${v_cppp}
    set_instance_parameter_value      vid_out_pip_conv          PIPELINE_READY                  ${v_pipeline_ready}
    set_instance_parameter_value      vid_out_pip_conv          PIXELS_IN_PARALLEL_IN           ${v_pip}
    set_instance_parameter_value      vid_out_pip_conv          PIXELS_IN_PARALLEL_OUT          {2}
    set_instance_parameter_value      vid_out_pip_conv          SEPARATE_SLAVE_CLOCK            {1}
    set_instance_parameter_value      vid_out_pip_conv          SLAVE_PROTOCOL                  {Avalon}

    # isp_out_proto_conv
    set_instance_parameter_value      isp_out_proto_conv        BPS                             ${v_vid_out_bps}
    set_instance_parameter_value      isp_out_proto_conv        CHROMA_SAMPLING                 {444}
    set_instance_parameter_value      isp_out_proto_conv        CHROMA_SITING                   {TOP_LEFT}
    set_instance_parameter_value      isp_out_proto_conv        CLIP_LONG_FIELDS                {0}
    set_instance_parameter_value      isp_out_proto_conv        COLOR_SPACE                     {RGB}
    set_instance_parameter_value      isp_out_proto_conv        C_OMNI_CAP_ID_ASSOCIATED        {0}
    set_instance_parameter_value      isp_out_proto_conv        C_OMNI_CAP_ID_COMPONENT         {4}
    set_instance_parameter_value      isp_out_proto_conv        C_OMNI_CAP_IRQ                  {255}
    set_instance_parameter_value      isp_out_proto_conv        C_OMNI_CAP_IRQ_ENABLE           {0}
    set_instance_parameter_value      isp_out_proto_conv        C_OMNI_CAP_IRQ_ENABLE_EN        {0}
    set_instance_parameter_value      isp_out_proto_conv        C_OMNI_CAP_IRQ_STATUS           {0}
    set_instance_parameter_value      isp_out_proto_conv        C_OMNI_CAP_IRQ_STATUS_EN        {0}
    set_instance_parameter_value      isp_out_proto_conv        C_OMNI_CAP_TAG                  {0}
    set_instance_parameter_value      isp_out_proto_conv        C_OMNI_CAP_TYPE                 {573}
    set_instance_parameter_value      isp_out_proto_conv        C_OMNI_CAP_VERSION              {1}
    set_instance_parameter_value      isp_out_proto_conv        ENABLE_DEBUG                    ${v_enable_debug}
    set_instance_parameter_value      isp_out_proto_conv        ENABLE_TIMEOUT                  {0}
    set_instance_parameter_value      isp_out_proto_conv        ENABLE_YCBCR_SWAP               {0}
    set_instance_parameter_value      isp_out_proto_conv        INPUT_MODE                      {EXTERNAL}
    set_instance_parameter_value      isp_out_proto_conv        NUMBER_OF_COLOR_PLANES          ${v_cppp}
    set_instance_parameter_value      isp_out_proto_conv        OUTPUT_MODE                     {INTERNAL}
    set_instance_parameter_value      isp_out_proto_conv        PIPELINE_READY                  ${v_pipeline_ready}
    set_instance_parameter_value      isp_out_proto_conv        PIXELS_IN_PARALLEL              {2}
    set_instance_parameter_value      isp_out_proto_conv        RUNTIME_CONTROL                 {1}
    set_instance_parameter_value      isp_out_proto_conv        SEPARATE_SLAVE_CLOCK            {1}
    set_instance_parameter_value      isp_out_proto_conv        SLAVE_PROTOCOL                  {Avalon}
    set_instance_parameter_value      isp_out_proto_conv        VIP_USER_SUPPORT                {DISCARD}
    set_instance_parameter_value      isp_out_proto_conv        VVP_USER_SUPPORT                {NONE_ALLOWED}

    ############################
    #### Create Connections ####
    ############################
    # isp_cpu_clk_bridge
    add_connection      isp_cpu_clk_bridge.out_clk          isp_cpu_rst_bridge.clk
    add_connection      isp_cpu_clk_bridge.out_clk          isp_mm_bridge.clk
    add_connection      isp_cpu_clk_bridge.out_clk          isp_vfb.control_clock
    add_connection      isp_cpu_clk_bridge.out_clk          isp_tpg.agent_clock
    add_connection      isp_cpu_clk_bridge.out_clk          isp_mixer.agent_clock
    add_connection      isp_cpu_clk_bridge.out_clk          isp_1d_lut.agent_clock
    add_connection      isp_cpu_clk_bridge.out_clk          vid_out_pip_conv.agent_clock
    add_connection      isp_cpu_clk_bridge.out_clk          isp_out_proto_conv.agent_clock

    # isp_cpu_rst_bridge
    add_connection      isp_cpu_rst_bridge.out_reset        isp_mm_bridge.reset
    add_connection      isp_cpu_rst_bridge.out_reset        isp_vfb.control_reset
    add_connection      isp_cpu_rst_bridge.out_reset        isp_tpg.agent_reset
    add_connection      isp_cpu_rst_bridge.out_reset        isp_mixer.agent_reset
    add_connection      isp_cpu_rst_bridge.out_reset        isp_1d_lut.agent_reset
    add_connection      isp_cpu_rst_bridge.out_reset        vid_out_pip_conv.agent_reset
    add_connection      isp_cpu_rst_bridge.out_reset        isp_out_proto_conv.agent_reset

    # isp_vid_clk_bridge
    add_connection      isp_vid_clk_bridge.out_clk          isp_vid_rst_bridge.clk
    add_connection      isp_vid_clk_bridge.out_clk          isp_vfb.main_clock
    add_connection      isp_vid_clk_bridge.out_clk          isp_tpg.main_clock
    add_connection      isp_vid_clk_bridge.out_clk          isp_icon.main_clock
    add_connection      isp_vid_clk_bridge.out_clk          isp_mixer.main_clock
    add_connection      isp_vid_clk_bridge.out_clk          isp_1d_lut.main_clock
    add_connection      isp_vid_clk_bridge.out_clk          vid_out_pip_conv.in_clock

    # isp_vid_rst_bridge
    add_connection      isp_vid_rst_bridge.out_reset        isp_vfb.main_reset
    add_connection      isp_vid_rst_bridge.out_reset        isp_tpg.main_reset
    add_connection      isp_vid_rst_bridge.out_reset        isp_icon.main_reset
    add_connection      isp_vid_rst_bridge.out_reset        isp_mixer.main_reset
    add_connection      isp_vid_rst_bridge.out_reset        isp_1d_lut.main_reset
    add_connection      isp_vid_rst_bridge.out_reset        vid_out_pip_conv.in_reset

    # isp_vid_clk_out_bridge
    add_connection      isp_vid_clk_out_bridge.out_clk      isp_vid_rst_out_bridge.clk
    add_connection      isp_vid_clk_out_bridge.out_clk      vid_out_pip_conv.out_clock
    add_connection      isp_vid_clk_out_bridge.out_clk      isp_out_proto_conv.main_clock

    # isp_vid_rst_out_bridge
    add_connection      isp_vid_rst_out_bridge.out_reset    vid_out_pip_conv.out_reset
    add_connection      isp_vid_rst_out_bridge.out_reset    isp_out_proto_conv.main_reset

    # isp_emif_clk_bridge
    add_connection      isp_emif_clk_bridge.out_clk         isp_emif_rst_bridge.clk
    add_connection      isp_emif_clk_bridge.out_clk         isp_vfb.mem_clock
    add_connection      isp_emif_clk_bridge.out_clk         isp_se_vfb.clock

    # isp_emif_rst_bridge
    add_connection      isp_emif_rst_bridge.out_reset       isp_vfb.mem_reset
    add_connection      isp_emif_rst_bridge.out_reset       isp_se_vfb.reset

    # isp_mm_bridge
    add_connection      isp_mm_bridge.m0                    isp_vfb.av_mm_control_agent
    add_connection      isp_mm_bridge.m0                    isp_tpg.av_mm_control_agent
    add_connection      isp_mm_bridge.m0                    isp_mixer.av_mm_control_agent
    add_connection      isp_mm_bridge.m0                    isp_1d_lut.av_mm_control_agent
    add_connection      isp_mm_bridge.m0                    vid_out_pip_conv.av_mm_control_agent
    add_connection      isp_mm_bridge.m0                    isp_out_proto_conv.av_mm_control_agent

    # isp_tpg
    add_connection      isp_tpg.axi4s_vid_out               isp_mixer.axi4s_vid_0_in

    # isp_vfb
    add_connection      isp_vfb.axi4s_vid_out               isp_mixer.axi4s_vid_1_in
    add_connection      isp_vfb.av_mm_mem_write_host        isp_se_vfb.windowed_slave
    add_connection      isp_vfb.av_mm_mem_read_host         isp_se_vfb.windowed_slave

    # isp_icon
    add_connection      isp_icon.axi4s_vid_out              isp_mixer.axi4s_vid_2_in

    # isp_mixer
    add_connection      isp_mixer.axi4s_vid_out             isp_1d_lut.axi4s_vid_in

    # isp_1d_lut
    add_connection      isp_1d_lut.axi4s_vid_out            vid_out_pip_conv.axi4s_vid_in

    # vid_out_pip_conv
    add_connection      vid_out_pip_conv.axi4s_vid_out          isp_out_proto_conv.axi4s_vid_in

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

    # isp_vid_clk_out_bridge
    set_interface_property  vid_clk_out         EXPORT_OF   isp_vid_clk_out_bridge.in_clk

    # isp_vid_rst_out_bridge
    set_interface_property  vid_rst_out         EXPORT_OF   isp_vid_rst_out_bridge.in_reset

    # isp_emif_clk_bridge
    set_interface_property  emif_clk_in         EXPORT_OF   isp_emif_clk_bridge.in_clk

    # isp_emif_rst_bridge
    set_interface_property  emif_rst_in         EXPORT_OF   isp_emif_rst_bridge.in_reset

    # isp_mm_bridge
    add_interface           mm_ctrl_in          avalon      slave
    set_interface_property  mm_ctrl_in          EXPORT_OF   isp_mm_bridge.s0

    # isp_se_vfb
    set_interface_property  av_mm_host_se_vfb   EXPORT_OF   isp_se_vfb.expanded_master

    # isp_vfb
    add_interface           vid_in              axi4stream  subordinate
    set_interface_property  vid_in              EXPORT_OF   isp_vfb.axi4s_vid_in

    # isp_out_proto_conv
    add_interface           vid_out             axi4stream  manager
    set_interface_property  vid_out             EXPORT_OF   isp_out_proto_conv.axi4s_vid_out

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

    add_auto_connection   ${v_instance_name} cpu_clk_in       100000000
    add_auto_connection   ${v_instance_name} cpu_rst_in       100000000
    add_auto_connection   ${v_instance_name} vid_clk_in       297000000
    add_auto_connection   ${v_instance_name} vid_rst_in       297000000
    add_auto_connection   ${v_instance_name} vid_clk_out      148500000
    add_auto_connection   ${v_instance_name} vid_rst_out      148500000

    # from isp pipe
    add_auto_connection   ${v_instance_name}    vid_in              isp_out_vid_axis

    # to vid out
    add_auto_connection   ${v_instance_name}    vid_out             vid_out_if_vid_in

    # isp_emif_clk_bridge
    add_auto_connection   ${v_instance_name}    emif_clk_in         from_emif_clk_out

    # isp_emif_rst_bridge
    add_auto_connection   ${v_instance_name}    emif_rst_in         from_emif_ready_out

    # to emif s0_axi4
    add_auto_connection   ${v_instance_name}    av_mm_host_se_vfb   from_i_emif_s0_axi4

    # HPS to mm bridge
    add_avmm_connections  mm_ctrl_in      ${v_avmm_host}
}
