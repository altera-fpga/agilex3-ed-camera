# (C) 2001-2026 Altera Corporation. All rights reserved.
# Your use of Altera Corporation's design tools, logic functions and other 
# software and tools, and its AMPP partner logic functions, and any output 
# files from any of the foregoing (including device programming or simulation 
# files), and any associated documentation or information are expressly subject 
# to the terms and conditions of the Altera Program License Subscription 
# Agreement, Altera IP License Agreement, or other applicable 
# license agreement, including, without limitation, that your use is for the 
# sole purpose of programming logic devices manufactured by Altera and sold by 
# Altera or its authorized distributors.  Please refer to the applicable 
# agreement for further details.

# +----------------------------------
# |
# |   MIPI DSI-2 - VDS workaround (copy of 26.3 version)
# |   Altera Corporation
# |
# +-----------------------------------
 
package require -exact qsys 24.3
package require altera_terp
 
source common_tcl/mipi_helper.tcl
source common_tcl/mipi_csi2_interface.tcl
source intel_cvg_parameters.tcl
 
# +-----------------------------------
# | module intel_mipi_dsi2
# |
set_module_property NAME intel_mipi_dsi2_vds_fix
set_module_property VERSION 3.0.0
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property GROUP "Interface Protocols/Audio & Video"
set_module_property DISPLAY_NAME "MIPI DSI-2 IP"
set_module_property DESCRIPTION "MIPI DSI-2 is a video interface protocol used primarily for interfacing with display panels. This IP provides the Transmitter and is configurable for interface properties and video data type support.  D-PHY interfaces comply with the MIPI PHY-Protocol Interface (PPI) standard and are designed to interface to the Altera MIPI D-PHY IP.  Video interfaces are compatible with the Altera Streaming Video Protocol."
set_module_property AUTHOR "Altera Corporation"
set_module_property OUTDATED_IP_FILE mipi_dsi2.odip
set_module_property SUPPORTED_DEVICE_FAMILIES {{Agilex 3} {Agilex 5}}
set_module_property VALIDATION_CALLBACK dsi2_validation_callback
 
add_documentation_link "User Guide" https://docs.altera.com/r/docs/869461/current
add_documentation_link "Release Notes" https://docs.altera.com/r/docs/869464/current/mipi-dsi-2-ip-release-notes
 
# +-----------------------------------
# | GUI
# |
 
# | Split to 2 tabs
add_display_item "" "IP" GROUP tab
add_display_item "" "Video Timing" GROUP tab
add_display_item "" "Design Example" GROUP tab
 
# | IP tab
# MIPI DSI-2 Source
add_display_item "IP" "Device Family" GROUP
add_display_item "Device Family" FAMILY parameter
 
add_display_item "IP" "Video Streaming Interface Options" GROUP
add_display_item "IP" "Video Packing/Unpacking Options" GROUP
add_display_item "IP" "MIPI D-PHY Interface Options" GROUP
add_display_item "IP" "General Options" GROUP
add_display_item "Video Streaming Interface Options" PIXELS_IN_PARALLEL parameter
add_display_item "Video Streaming Interface Options" FRAME_WIDTH_PIXELS parameter
add_display_item "Video Streaming Interface Options" TDATA_WIDTH parameter
add_display_item "Video Streaming Interface Options" CLOCKS_ARE_SAME parameter
add_display_item "Video Packing/Unpacking Options" DATA_TYPE parameter
add_display_item "MIPI D-PHY Interface Options" LANE parameter
add_display_item "MIPI D-PHY Interface Options" BYTES_PER_LANE parameter
add_display_item "MIPI D-PHY Interface Options" USE_CONTINUOUS_CLK parameter
add_display_item "General Options" DIRECTION parameter
add_display_item "General Options" ENABLE_CSR parameter
add_display_item "General Options" SEPARATE_SLAVE_CLOCK parameter
add_display_item "General Options" ENABLE_CRC parameter
add_display_item "General Options" ENABLE_ECC parameter
add_display_item "General Options" ENABLE_PASSTHROUGH parameter
add_display_item "General Options" TIMING_MODE parameter
add_display_item "General Options" BUFFER_DEPTH parameter
 
# | Design Example tab
add_display_item "Design Example" "Available Design Example" GROUP
add_display_item "Available Design Example" SELECT_SUPPORTED_VARIANT parameter
add_display_item "Design Example" "de_variant_txt" text \
        "<html>The design example supports generation, simulation, and Quartus compilation flows for any selected device. <br> \
        For MIPI DSI-2 Rx+Tx Simulation Design Example, only the 'Simulation' option is available. <br> \
        For MIPI DSI-2 TX Synthesis Design Example, only the 'Synthesis' option is available. </html>"
 
add_display_item "Design Example" "Design Example Files" GROUP
add_display_item "Design Example Files" ENABLE_ED_FILESET_SYNTHESIS parameter
add_display_item "Design Example Files" ENABLE_ED_FILESET_SIM parameter
add_display_item "Design Example Files" SELECT_ED_SIM_VARIANT parameter
add_display_item "Design Example Files" "de_sim_variant_txt" text \
        "<html>The design example simulation supports two options Fast and Full.<br> \
        The Fast simulation has reduced runtime and is intended for simulating the MIPI DSI-2 behavior.<br> \
        The Full simulation has a longer runtime and is intended for simulating the full MIPI DSI-2 and MIPI D-PHY system behavior.</html>"
 
add_display_item "Design Example" "Target Development Kit" GROUP
add_display_item "Target Development Kit" SELECT_TARGETED_BOARD parameter
add_display_item "Target Development Kit" "target_devkit_txt" text \
        "<html>Design Example supports generation, simulation and Quartus compilation flows for any selected device.<br> \
        The hardware support is provided through selected development kit with a specific device.<br> \
        To exclude hardware aspects of design example, select 'None' from the Target Development Kit pull down menu.</html>"
 
# add_display_item "Design Example" "Target Device" GROUP
# add_display_item "Target Device" "target_dev" text "<html>Device Selected:     Family: Agilex 5 Device A5ED065BB32AE6SR0<br><br></html>"
 
# add_display_item "Target Device" SELECT_CUSTOM_DEVICE parameter
# add_display_item "Target Device" "custom_device_txt" text "<html></html>"
 
# CVO
add_display_item     "Video Timing" VID_LIST              parameter
add_display_item     "Video Timing" VALIDATE_TIMING       parameter
 
add_display_item     "Video Timing" "Dimensions"          GROUP
add_display_item     "Video Timing" "Blanking Timing"     GROUP
add_display_item     "Video Timing" "Sync Timing"         GROUP
 
# --------------------------------------------------------------------------------------------------
# --                                                                                              --
# -- Callbacks                                                                                    --
# --                                                                                              --
# --------------------------------------------------------------------------------------------------
# Composition callback to wire up components and expose external interfaces
set_module_property COMPOSITION_CALLBACK composition_cb
 
add_parameter FAMILY STRING "Unknown"
set_parameter_property FAMILY SYSTEM_INFO device_family  ;#forces family to always match Qsys
set_parameter_property FAMILY HDL_PARAMETER false
set_parameter_property FAMILY VISIBLE false
 
add_parameter DEVICE string "Unknown"
set_parameter_property DEVICE SYSTEM_INFO {DEVICE}
set_parameter_property DEVICE HDL_PARAMETER false
set_parameter_property DEVICE VISIBLE false
 
add_parameter DEVICE_SPEED_GRADE string "Unknown"
set_parameter_property DEVICE_SPEED_GRADE DISPLAY_NAME "Device speed grade"
set_parameter_property DEVICE_SPEED_GRADE SYSTEM_INFO {DEVICE_SPEEDGRADE}
set_parameter_property DEVICE HDL_PARAMETER false
set_parameter_property DEVICE_SPEED_GRADE VISIBLE false
 
add_parameter DIRECTION STRING "tx"
set_parameter_property DIRECTION DISPLAY_NAME "Direction"
set_parameter_property DIRECTION AFFECTS_ELABORATION true
set_parameter_property DIRECTION AFFECTS_VALIDATION true
set_parameter_property DIRECTION DESCRIPTION "Select the port direction."
set_parameter_property DIRECTION ALLOWED_RANGES {tx:TX}
set_parameter_property DIRECTION ENABLED false
set_parameter_update_callback DIRECTION update_ed_variant
 
add_parameter FRAME_WIDTH_PIXELS INTEGER 128
set_parameter_property FRAME_WIDTH_PIXELS DISPLAY_NAME "Pixels per video line"
set_parameter_property FRAME_WIDTH_PIXELS AFFECTS_ELABORATION true
set_parameter_property FRAME_WIDTH_PIXELS HDL_PARAMETER false
set_parameter_property FRAME_WIDTH_PIXELS DESCRIPTION "The number of pixels on each video line."
 
add_parameter LANE INTEGER 2
set_parameter_property LANE DISPLAY_NAME "Number of lanes"
set_parameter_property LANE AFFECTS_ELABORATION true
set_parameter_property LANE HDL_PARAMETER false
set_parameter_property LANE DESCRIPTION "Select the number of D-PHY lanes."
set_parameter_property LANE ALLOWED_RANGES {1:1 2:2 4:4}
 
add_parameter BYTES_PER_LANE INTEGER 2
set_parameter_property BYTES_PER_LANE DISPLAY_NAME "PPI bus width per lane"
set_parameter_property BYTES_PER_LANE UNITS bytes
set_parameter_property BYTES_PER_LANE AFFECTS_ELABORATION true
set_parameter_property BYTES_PER_LANE AFFECTS_GENERATION true
set_parameter_property BYTES_PER_LANE ENABLED false
set_parameter_property BYTES_PER_LANE HDL_PARAMETER false
set_parameter_property BYTES_PER_LANE DESCRIPTION "Select the PPI bus width per lane in bytes."
set_parameter_property BYTES_PER_LANE ALLOWED_RANGES {2:2}
 
add_parameter USE_CONTINUOUS_CLK BOOLEAN false
set_parameter_property USE_CONTINUOUS_CLK DISPLAY_NAME "MIPI D-PHY continuous clock"
set_parameter_property USE_CONTINUOUS_CLK AFFECTS_ELABORATION true
set_parameter_property USE_CONTINUOUS_CLK HDL_PARAMETER false
set_parameter_property USE_CONTINUOUS_CLK DESCRIPTION "Enable when the clock lane on the MIPI D-PHY interface is continually enabled in HS mode.  This must be enabled when the connected D-PHY Transmitter has been configured in continuous clock mode."
 
add_parameter DATA_TYPE STRING RGB_24bit
set_parameter_property DATA_TYPE DISPLAY_NAME "MIPI DSI-2 Data Type"
set_parameter_property DATA_TYPE AFFECTS_ELABORATION true
set_parameter_property DATA_TYPE AFFECTS_GENERATION true
set_parameter_property DATA_TYPE HDL_PARAMETER false
set_parameter_property DATA_TYPE DESCRIPTION "The data type to be handled at the MIPI D-PHY interface."
set_parameter_property DATA_TYPE ALLOWED_RANGES {
    RGB_16bit
    RGB_18bit
    RGB_18bit_Loose
    RGB_24bit
    RGB_30bit
    RGB_36bit
    YCbCr_12bit
    YCbCr_16bit
    YCbCr_20bit
    YCbCr_20bit_Loose
    YCbCr_24bit};
 
add_parameter TDATA_WIDTH INTEGER 32
set_parameter_property TDATA_WIDTH DISPLAY_NAME "AXI4-S TDATA width"
set_parameter_property TDATA_WIDTH DESCRIPTION "Total width of pixel interface TDATA in bits."
set_parameter_property TDATA_WIDTH UNITS bits
set_parameter_property TDATA_WIDTH AFFECTS_ELABORATION false
set_parameter_property TDATA_WIDTH HDL_PARAMETER false
set_parameter_property TDATA_WIDTH DERIVED true
set_parameter_property TDATA_WIDTH VISIBLE true
 
add_parameter PIXELS_IN_PARALLEL INTEGER 2
set_parameter_property PIXELS_IN_PARALLEL DISPLAY_NAME "Pixels in parallel"
set_parameter_property PIXELS_IN_PARALLEL AFFECTS_ELABORATION true
set_parameter_property PIXELS_IN_PARALLEL AFFECTS_GENERATION true
set_parameter_property PIXELS_IN_PARALLEL HDL_PARAMETER false
set_parameter_property PIXELS_IN_PARALLEL DESCRIPTION "Select the number of pixels in parallel on the video streaming interface."
set_parameter_property PIXELS_IN_PARALLEL ALLOWED_RANGES {1:1 2:2 4:4}
 
add_parameter CLOCKS_ARE_SAME BOOLEAN true
set_parameter_property CLOCKS_ARE_SAME DISPLAY_NAME "Use common clock for video input and MIPI output"
set_parameter_property CLOCKS_ARE_SAME HDL_PARAMETER false
set_parameter_property CLOCKS_ARE_SAME VISIBLE true
set_parameter_property CLOCKS_ARE_SAME ENABLED true
set_parameter_property CLOCKS_ARE_SAME DESCRIPTION "<html>When enabled <b><i>clk</i></b> must be connected to the MIPI D-PHY <b><i>LINKn_CK_TxWordClkHS</i></b>. When disabled <b><i>clk</i></b> may be connected to any clock. Using the MIPI D-PHY word clock for the AXI-S streaming video input interface reduces resources and removes the clock domain crossing and latency uncertainty on the video path within the IP.</html>"
 
add_parameter ENABLE_PASSTHROUGH BOOLEAN false
set_parameter_property ENABLE_PASSTHROUGH DISPLAY_NAME "Enable Passthrough mode"
set_parameter_property ENABLE_PASSTHROUGH AFFECTS_ELABORATION true
set_parameter_property ENABLE_PASSTHROUGH HDL_PARAMETER false
set_parameter_property ENABLE_PASSTHROUGH VISIBLE false
set_parameter_property ENABLE_PASSTHROUGH ENABLED false
set_parameter_property ENABLE_PASSTHROUGH DESCRIPTION "Choose between Passthrough and Altera Streaming Video mode"
 
add_parameter ENABLE_CSR BOOLEAN true
set_parameter_property ENABLE_CSR DISPLAY_NAME "Control and Status Registers (CSR)"
set_parameter_property ENABLE_CSR AFFECTS_ELABORATION true
set_parameter_property ENABLE_CSR AFFECTS_GENERATION true
set_parameter_property ENABLE_CSR HDL_PARAMETER false
set_parameter_property ENABLE_CSR DESCRIPTION "Turn off to disable Control and Status Register interface (CSR)."
 
add_parameter          SEPARATE_SLAVE_CLOCK  BOOLEAN                   false
set_parameter_property SEPARATE_SLAVE_CLOCK  DISPLAY_NAME              "Separate clock for Control and Status Register interface (CSR)."
set_parameter_property SEPARATE_SLAVE_CLOCK  HDL_PARAMETER             false
set_parameter_property SEPARATE_SLAVE_CLOCK  DISABLED_VALUE            false
set_parameter_property SEPARATE_SLAVE_CLOCK  DESCRIPTION               "Run the AVALON-MM control interface on a different clock domain"
set_parameter_property SEPARATE_SLAVE_CLOCK  AFFECTS_ELABORATION       true
set_parameter_property SEPARATE_SLAVE_CLOCK  AFFECTS_GENERATION        true
 
add_parameter ENABLE_CRC BOOLEAN true
set_parameter_property ENABLE_CRC DISPLAY_NAME "CRC insertion"
set_parameter_property ENABLE_CRC AFFECTS_ELABORATION true
set_parameter_property ENABLE_CRC AFFECTS_GENERATION true
set_parameter_property ENABLE_CRC HDL_PARAMETER false
set_parameter_property ENABLE_CRC DESCRIPTION "Turn off to disable CRC insertion. When disabled the output will not comply with the DSI-2 specification."
 
add_parameter ENABLE_ECC BOOLEAN true
set_parameter_property ENABLE_ECC DISPLAY_NAME "ECC insertion"
set_parameter_property ENABLE_ECC AFFECTS_ELABORATION true
set_parameter_property ENABLE_ECC AFFECTS_GENERATION true
set_parameter_property ENABLE_ECC HDL_PARAMETER false
set_parameter_property ENABLE_ECC DESCRIPTION "Turn off to disable Error Correction Code insertion. When disabled the output will not comply with the DSI-2 specification."
 
add_parameter TIMING_MODE STRING "non_burst_pulses"
set_parameter_property TIMING_MODE DISPLAY_NAME "MIPI DSI-2 Timing Mode"
set_parameter_property TIMING_MODE AFFECTS_ELABORATION true
set_parameter_property TIMING_MODE AFFECTS_GENERATION true
set_parameter_property TIMING_MODE HDL_PARAMETER false
set_parameter_property TIMING_MODE DESCRIPTION "The three timing modes for Video Mode Interface Timing."
set_parameter_property TIMING_MODE ALLOWED_RANGES { \
    "non_burst_pulses:Non-Burst Mode with Sync Pulses" \
    "non_burst_events:Non-Burst Mode with Sync Events" \
    "burst:Burst Mode"
};
 
add_parameter ENABLE_FIXED_LATENCY BOOLEAN true
set_parameter_property ENABLE_FIXED_LATENCY DISPLAY_NAME "Fixed latency mode"
set_parameter_property ENABLE_FIXED_LATENCY AFFECTS_ELABORATION true
set_parameter_property ENABLE_FIXED_LATENCY AFFECTS_GENERATION true
set_parameter_property ENABLE_FIXED_LATENCY HDL_PARAMETER false
set_parameter_property ENABLE_FIXED_LATENCY DISABLED_VALUE false
set_parameter_property ENABLE_FIXED_LATENCY DESCRIPTION "Turn on to add logic to ensure packets are produced strictly according to configured video timing.  When disabled horizontal video timing might vary slightly from the configured timing, but resource utilization will be lower."
set_parameter_update_callback TIMING_MODE update_fixed_latency
set_parameter_property ENABLE_FIXED_LATENCY VISIBLE false
 
add_parameter PLAYOUT_LATENCY INTEGER
set_parameter_property PLAYOUT_LATENCY DISPLAY_NAME "Fixed latency mode buffer latency"
set_parameter_property PLAYOUT_LATENCY DESCRIPTION "Latency through packet buffer in PPI word clock cycles when fixed latency is enabled."
set_parameter_property PLAYOUT_LATENCY UNITS cycles
set_parameter_property PLAYOUT_LATENCY DISPLAY_HINT READ_ONLY_TEXT
set_parameter_property PLAYOUT_LATENCY AFFECTS_ELABORATION true
set_parameter_property PLAYOUT_LATENCY HDL_PARAMETER false
set_parameter_property PLAYOUT_LATENCY DERIVED true
set_parameter_property PLAYOUT_LATENCY VISIBLE false
 
add_parameter BUFFER_DEPTH INTEGER 4096
set_parameter_property BUFFER_DEPTH DISPLAY_NAME "Buffer depth"
set_parameter_property BUFFER_DEPTH AFFECTS_ELABORATION true
set_parameter_property BUFFER_DEPTH AFFECTS_GENERATION true
set_parameter_property BUFFER_DEPTH HDL_PARAMETER false
set_parameter_property BUFFER_DEPTH DESCRIPTION "Select the depth of the video buffer. This is in units of (PPI bus width * number of lanes). It is recommended to ensure this buffer is large enough to hold at least 1.2 video lines."
set_parameter_property BUFFER_DEPTH ALLOWED_RANGES {256:256 512:512 1024:1024 2048:2048 3072:3072 4096:4096 5120:5120 6144:6144 7168:7168 8192:8192 16384:16384 32767:32767 65536:65536}
 
# Design Example Parameter
add_parameter SELECT_SUPPORTED_VARIANT INTEGER 3
set_parameter_property SELECT_SUPPORTED_VARIANT DISPLAY_NAME "Select Design"
set_parameter_property SELECT_SUPPORTED_VARIANT ALLOWED_RANGES { "1:MIPI DSI-2 Rx+Tx Simulation" "3:MIPI DSI-2 TX Synthesis" }
set_parameter_update_callback SELECT_SUPPORTED_VARIANT update_enable_ed_fileset_sim
set_parameter_property SELECT_SUPPORTED_VARIANT DESCRIPTION \
        "<html>Please select available design for Design Example generation.<br> \
        <br> \
        <b>MIPI DSI-2 Rx+Tx Subsystem</b>: <br> \
        This designs demonstrates the connection between one DSI-2 Tx, one MIPI D-PHY or loopback interface, and one DSI-2 Rx BFM in a Platform Designer subsystem for Simulation. \
        <br><br> \
        <b>MIPI DSI-2 TX Only</b>: <br> \
        This designs demonstrates the connection between one DSI-2 Tx and one MIPI D-PHY in a Platform Designer subsystem for Synthesis. \
        <br><br> </html>"
 
add_parameter ENABLE_ED_FILESET_SYNTHESIS BOOLEAN true
set_parameter_property ENABLE_ED_FILESET_SYNTHESIS ENABLED false
set_parameter_property ENABLE_ED_FILESET_SYNTHESIS DISPLAY_NAME "Synthesis"
set_parameter_property ENABLE_ED_FILESET_SYNTHESIS DESCRIPTION "When Synthesis box is checked, all files required for synthesis will be generated."
 
add_parameter ENABLE_ED_FILESET_SIM BOOLEAN false
set_parameter_property ENABLE_ED_FILESET_SIM ENABLED false
set_parameter_property ENABLE_ED_FILESET_SIM DISPLAY_NAME "Simulation"
set_parameter_property ENABLE_ED_FILESET_SIM DESCRIPTION "When Simulation box is checked, all files required for simulation will be generated."
 
add_parameter SELECT_ED_SIM_VARIANT STRING fast
set_parameter_property SELECT_ED_SIM_VARIANT ENABLED false
set_parameter_property SELECT_ED_SIM_VARIANT DISPLAY_NAME "Select Simulation Variant"
set_parameter_property SELECT_ED_SIM_VARIANT ALLOWED_RANGES { "fast:Fast Simulation" "full:Full Simulation" }
set_parameter_property SELECT_ED_SIM_VARIANT DESCRIPTION \
        "<html>Please select available option for Design Example simulation.<br> \
        <br> \
        <b>Fast Simulation</b>: <br> \
        This design simulates one DSI-2 TX and one DSI-2 RX, connected with a simple PPI loopback interface.\
        <br><br> \
        <b>Full Simulation</b>: <br> \
        This design simulates one DSI-2 TX, one DSI-2 RX and one 2 port MIPI D-PHY with a loopback connection at the Serial (Physical) interface.\
        <br><br> \
        </html>"
 
add_parameter SELECT_TARGETED_BOARD INTEGER 0
set_parameter_property SELECT_TARGETED_BOARD DISPLAY_NAME "Select Board"
set_parameter_property SELECT_TARGETED_BOARD DISABLED_VALUE 0
set_parameter_property SELECT_TARGETED_BOARD ALLOWED_RANGES { "0:No Development Kit" }
set_parameter_property SELECT_TARGETED_BOARD DESCRIPTION \
        "<html>This option provides supports for various Development Kits listed. The details of Altera FPGA Development Kits can be found on the Altera FPGA website \
        <a href='https://www.altera.com/products/development-kits'>https://www.altera.com/products/development-kits</a>. \
        If this menu is greyed out, it is because no board is supported for the options selected such as synthesis checked off. \
        If an Altera FPGA Development board is selected, the Target Device used for generation will be the one that matches the device on the Development Kit<br> \
        <br> \
        <b>No Development Kit:</b> This option excluding hardware aspects for the Design Example.
        <b>Any other selection:</b> Targets the specified board and FPGA device, and is tailored to the pinout and its supported interfaces.</html>"
 
# add_parameter SELECT_CUSTOM_DEVICE BOOLEAN false
# set_parameter_property SELECT_CUSTOM_DEVICE DISPLAY_NAME "Change Target Device"
# set_parameter_property SELECT_CUSTOM_DEVICE DESCRIPTION \
#         "<html>When selected, the user is able to select different device grade for Altera FPGA development kit. \
#         For device specific details look for Device data sheet on <a href='http://www.altera.com/'>www.altera.com</a></html>"
# set_parameter_property SELECT_CUSTOM_DEVICE VISIBLE true
# set_parameter_property SELECT_CUSTOM_DEVICE ENABLED false
 
add_parameter           VID_LIST     INTEGER                     0
set_parameter_property  VID_LIST     DISPLAY_NAME                "Video timing configuration values"
set_parameter_property  VID_LIST     ALLOWED_RANGES              {0:Manual}
set_parameter_property  VID_LIST     HDL_PARAMETER               false
set_parameter_property  VID_LIST     AFFECTS_ELABORATION         true
set_parameter_property  VID_LIST     DESCRIPTION                 "Select between manual and predefined video timing configuration values"
 
add_parameter           VALIDATE_TIMING BOOLEAN         true
set_parameter_property  VALIDATE_TIMING ENABLED         true
set_parameter_property  VALIDATE_TIMING HDL_PARAMETER   false
set_parameter_property  VALIDATE_TIMING DISPLAY_NAME    "Validate video timing parameters"
set_parameter_property  VALIDATE_TIMING DESCRIPTION     "When the Validate timing option is enabled the video timing parameters will be checked for validity and consistency. If this option is disabled then it is possible to configure the IP with timing values that will prevent the IP from passing video."
 
intel_cvg_parameters::add_CVG_integer_param "Dimensions"      C_TIM_HTOTAL      "Default value for HTOTAL"     2176  "0:65535" "The total number of pixels (active and blanking) per line"
intel_cvg_parameters::add_CVG_integer_param "Dimensions"      C_TIM_VTOTAL      "Default value for VTOTAL"     100   "0:65535" "The total number of lines (active and blanking) per frame"
 
intel_cvg_parameters::add_CVG_integer_param "Blanking Timing" C_TIM_HB_END      "Default value for HB_END"     2048  "0:65535" "The number of pixels of horizontal blanking at the start of a video line"
intel_cvg_parameters::add_CVG_integer_param "Blanking Timing" C_TIM_V1B_START   "Default value for V1B_START"  0     "0:65535" "First line of vertical blanking for field 1"
intel_cvg_parameters::add_CVG_integer_param "Blanking Timing" C_TIM_V1B_END     "Default value for V1B_END"    4     "0:65535" "First line of active video after vertical blanking for field 1"
 
intel_cvg_parameters::add_CVG_integer_param "Sync Timing"     C_TIM_HS_START    "Default Value for HS_START"   52    "0:65535" "First pixel of the horizontal sync pulse"
intel_cvg_parameters::add_CVG_integer_param "Sync Timing"     C_TIM_HS_END      "Default Value for HS_END"     100   "0:65535" "First pixel after the horizontal sync pulse"
intel_cvg_parameters::add_CVG_integer_param "Sync Timing"     C_TIM_V1S_VSTART  "Default Value for V1S_VSTART" 2     "0:65535" "Starting line of the field 1 vertical sync"
intel_cvg_parameters::add_CVG_integer_param "Sync Timing"     C_TIM_V1S_HSTART  "Default Value for V1S_HSTART" 52    "0:65535" "First pixel of the field 1 vertical sync"
intel_cvg_parameters::add_CVG_integer_param "Sync Timing"     C_TIM_V1S_VEND    "Default Value for V1S_VEND"   3     "0:65535" "Last line of the field 1 vertical sync"
intel_cvg_parameters::add_CVG_integer_param "Sync Timing"     C_TIM_V1S_HEND    "Default Value for V1S_HEND"   52    "0:65535" "First pixel after the field 1 vertical sync"
 
# +-----------------------------------
# | Example design fileset generation
# |
add_fileset example_design EXAMPLE_DESIGN generate_example
set_fileset_property example_design ENABLE_FILE_OVERWRITE_MODE true
 
proc generate_example {name} {
    if {[get_parameter_value SELECT_TARGETED_BOARD] == 0} {
        # no target board, so generate synth design
        generate_qsys_ed
    } else {
        # target hardware selected so generate tailored build for that board
        generate_hw_ed
    }
}
 
# +-----------------------------------
# | ELABORATION CALLBACK
# +-----------------------------------
proc update_ed_variant {arg} {
    set direction [get_parameter_value $arg]
 
    if { $direction == "tx" } {
        set_parameter_property SELECT_SUPPORTED_VARIANT ALLOWED_RANGES { "1:MIPI DSI-2 Tx+Rx Subsystem" "3:MIPI DSI-2 TX Only" }
    } else {
        set_parameter_property SELECT_SUPPORTED_VARIANT ALLOWED_RANGES { "1:MIPI DSI-2 Tx+Rx Subsystem" }
    }
}
 
proc update_fixed_latency {arg} {
    set timing_mode [get_parameter_value $arg]
 
    if { $timing_mode == "burst" } {
        set_parameter_value ENABLE_FIXED_LATENCY false
    } else {
        set_parameter_value ENABLE_FIXED_LATENCY true
    }
}
 
proc update_enable_ed_fileset_sim {arg} {
    set ed_variant [get_parameter_value $arg]
 
    if { $ed_variant == 1 } {  # TX+RX
        set_parameter_value ENABLE_ED_FILESET_SYNTHESIS false
        set_parameter_value ENABLE_ED_FILESET_SIM true
        set_parameter_property SELECT_ED_SIM_VARIANT ENABLED true
        set_parameter_property SELECT_TARGETED_BOARD ENABLED false
    } else {                   # TX-only
        set_parameter_value ENABLE_ED_FILESET_SYNTHESIS true
        set_parameter_value ENABLE_ED_FILESET_SIM false
        set_parameter_property SELECT_TARGETED_BOARD ENABLED true
    }
}
 
proc get_input_bits_per_symbol {data_type} {
    # Adapt bits per symbol to CVO form
    switch $data_type {
        "YCbCr_20bit_Loose" { set bits_per_symbol 12 }
        "YCbCr_24bit"       { set bits_per_symbol 12 }
        "YCbCr_16bit"       { set bits_per_symbol 8  }
        "YCbCr_20bit"       { set bits_per_symbol 10 }
        "RGB_30bit"         { set bits_per_symbol 10 }
        "RGB_36bit"         { set bits_per_symbol 12 }
        "YCbCr_12bit"       { set bits_per_symbol 8  }
        "RGB_16bit"         { set bits_per_symbol 8  }
        "RGB_18bit"         { set bits_per_symbol 8  }
        "RGB_18bit_Loose"   { set bits_per_symbol 8  }
        "RGB_24bit"         { set bits_per_symbol 8  }
        default             { set bits_per_symbol 8  }
    }
    return ${bits_per_symbol}
}
proc get_input_number_of_color_planes {data_type} {
    switch $data_type {
        "YCbCr_20bit_Loose" { set number_of_color_planes 2 }
        "YCbCr_24bit"       { set number_of_color_planes 2 }
        "YCbCr_16bit"       { set number_of_color_planes 2 }
        "YCbCr_20bit"       { set number_of_color_planes 2 }
        "RGB_30bit"         { set number_of_color_planes 3 }
        "RGB_36bit"         { set number_of_color_planes 3 }
        "YCbCr_12bit"       { set number_of_color_planes 3 }
        "RGB_16bit"         { set number_of_color_planes 3 }
        "RGB_18bit"         { set number_of_color_planes 3 }
        "RGB_24bit"         { set number_of_color_planes 3 }
        default             { set number_of_color_planes 3 }
    }
    return ${number_of_color_planes}
}
proc get_packed_bits_per_pixel {data_type} {
    switch $data_type {
        "YCbCr_20bit_Loose" { set packed_bits_per_pixel 24 }
        "YCbCr_24bit"       { set packed_bits_per_pixel 24 }
        "YCbCr_16bit"       { set packed_bits_per_pixel 16 }
        "YCbCr_20bit"       { set packed_bits_per_pixel 20 }
        "RGB_30bit"         { set packed_bits_per_pixel 30 }
        "RGB_36bit"         { set packed_bits_per_pixel 36 }
        "YCbCr_12bit"       { set packed_bits_per_pixel 12 }
        "RGB_16bit"         { set packed_bits_per_pixel 16 }
        "RGB_18bit"         { set packed_bits_per_pixel 18 }
        "RGB_18bit_Loose"   { set packed_bits_per_pixel 24 }
        "RGB_24bit"         { set packed_bits_per_pixel 24 }
    }
    return ${packed_bits_per_pixel}
}
 
# determine number of bits required to hold number
proc bits_required {value} {
    if {$value == 0} { return 1 }
    # log2(x) = log(x) / log(2)
    return [expr {int(floor(log($value) / log(2))) + 1}]
}
 
proc dsi2_validation_callback {} {
    set vid_list_val        [get_parameter_value VID_LIST]
    set data_type           [get_parameter_value DATA_TYPE]
    set frame_width_pixels  [get_parameter_value FRAME_WIDTH_PIXELS]
    set clocks_are_same     [get_parameter_value CLOCKS_ARE_SAME]
    set enable_csr          [get_parameter_value ENABLE_CSR]
    set family              [get_parameter_value FAMILY]
 
    if {${clocks_are_same}} {
        set_parameter_property  ENABLE_FIXED_LATENCY          ENABLED true
    } else {
        set_parameter_property  ENABLE_FIXED_LATENCY          ENABLED false
    }
 
    if {$data_type=="YCbCr_12bit"} {
       #In 420 format, two pixels are treated as one symbol.
       set c_tim_htotal_default [expr {$frame_width_pixels/2 + 2048}]
    } else {
       set c_tim_htotal_default [expr {$frame_width_pixels + 2048}]
    }
    if { $enable_csr } {
        set_parameter_property  SEPARATE_SLAVE_CLOCK      ENABLED  true
    } else {
        set_parameter_property  SEPARATE_SLAVE_CLOCK      ENABLED  false
    }
 
    if { $family == "Agilex 5" } {
        set_parameter_property SELECT_TARGETED_BOARD ALLOWED_RANGES { "0:No Development Kit" "4:Agilex 5 FPGA E-Series 065A Premium Development Kit" "5:Agilex 5 FPGA E-Series 065B Premium Development Kit" "1:Agilex 5 FPGA E-Series 065B (ES) Premium Development Kit"}
    } elseif { $family == "Agilex 3" } {
        set_parameter_property SELECT_TARGETED_BOARD ALLOWED_RANGES { "0:No Development Kit" "2:Agilex 3 FPGA C-Series Development Kit" "3:Agilex 3 SoC C-Series Development Kit"}
    } else {
        set_parameter_property SELECT_TARGETED_BOARD ALLOWED_RANGES { "0:No Development Kit" }
    }
 
    set vid_list_val  [get_parameter_value VID_LIST]
    if {${vid_list_val} == 0} {
        set_parameter_property  C_TIM_HTOTAL          DISABLED_VALUE $c_tim_htotal_default
 
        set_parameter_property  C_TIM_HTOTAL          ENABLED true
        set_parameter_property  C_TIM_VTOTAL          ENABLED true
        set_parameter_property  C_TIM_HB_END          ENABLED true
        set_parameter_property  C_TIM_V1B_START       ENABLED true
        set_parameter_property  C_TIM_V1B_END         ENABLED true
        set_parameter_property  C_TIM_HS_START        ENABLED true
        set_parameter_property  C_TIM_HS_END          ENABLED true
        set_parameter_property  C_TIM_V1S_VSTART      ENABLED true
        set_parameter_property  C_TIM_V1S_HSTART      ENABLED true
        set_parameter_property  C_TIM_V1S_VEND        ENABLED true
        set_parameter_property  C_TIM_V1S_HEND        ENABLED true
    } elseif {${vid_list_val} == 1} {
        set_parameter_property  C_TIM_HTOTAL          DISABLED_VALUE $c_tim_htotal_default
 
        set_parameter_property  C_TIM_HTOTAL          ENABLED false
        set_parameter_property  C_TIM_VTOTAL          ENABLED false
        set_parameter_property  C_TIM_HB_END          ENABLED false
        set_parameter_property  C_TIM_V1B_START       ENABLED false
        set_parameter_property  C_TIM_V1B_END         ENABLED false
        set_parameter_property  C_TIM_HS_START        ENABLED false
        set_parameter_property  C_TIM_HS_END          ENABLED false
        set_parameter_property  C_TIM_V1S_VSTART      ENABLED false
        set_parameter_property  C_TIM_V1S_HSTART      ENABLED false
        set_parameter_property  C_TIM_V1S_VEND        ENABLED false
        set_parameter_property  C_TIM_V1S_HEND        ENABLED false
    }
 
    # Buffer size calculations
    set bufdepth                [get_parameter_value BUFFER_DEPTH]
    set lanes                   [get_parameter_value LANE]
    set ppi_width               [expr [get_parameter_value BYTES_PER_LANE] * 8]
    set packed_bits_per_pixel   [get_packed_bits_per_pixel $data_type]
    set bufwidth                [expr $ppi_width * $lanes]
    set lines                   [format "%.1f" [expr double($bufdepth * $bufwidth) / ${packed_bits_per_pixel} / $frame_width_pixels]]
    if {$lines < 1.2} {
        send_message error "Packet buffer will hold around $lines video line[expr $lines!=1.0?{s}:{}]. Minimum recommended is 1.2 lines."
    } else {
        send_message info "Packet buffer will hold around $lines video line[expr $lines!=1.0?{s}:{}]. Minimum recommended is 1.2 lines."
    }
 
    # calculate safe fixed latency according to configuration (buffer one line of data)
    set pip [get_parameter_value PIXELS_IN_PARALLEL]
    set_parameter_value PLAYOUT_LATENCY [expr ($frame_width_pixels + $pip-1) / $pip ]
    if {[get_parameter_value ENABLE_FIXED_LATENCY]} {
        send_message info "Fixed latency through packet buffer is [get_parameter_value PLAYOUT_LATENCY] input video clock cycles."
    }
 
    # ------------------------
    # timing parameters checks
    # ------------------------
    set htotal      [get_parameter_value C_TIM_HTOTAL]
    set htotal_min  [expr (770 + ($packed_bits_per_pixel * $frame_width_pixels)/($lanes * $ppi_width)) * $pip]
    # round up to next highest multiple of PIP, with allowance for float errors
    set htotal_min  [expr int(($htotal_min + $pip - 0.01) / $pip) * $pip]
    if {[get_parameter_value VALIDATE_TIMING]} {
        set vtotal      [get_parameter_value C_TIM_VTOTAL]
        set hb_end      [get_parameter_value C_TIM_HB_END]
        set hs_start    [get_parameter_value C_TIM_HS_START]
        set hs_end      [get_parameter_value C_TIM_HS_END]
        set v1b_start   [get_parameter_value C_TIM_V1B_START]
        set v1b_end     [get_parameter_value C_TIM_V1B_END]
        set v1s_vstart  [get_parameter_value C_TIM_V1S_VSTART]
        set v1s_hstart  [get_parameter_value C_TIM_V1S_HSTART]
        set v1s_vend    [get_parameter_value C_TIM_V1S_VEND]
        set v1s_hend    [get_parameter_value C_TIM_V1S_HEND]
 
        # calculate minimum HTOTAL length
        if {$clocks_are_same} {
            if {$htotal < $htotal_min} {
                send_message error  "Video timing is out of range: C_TIM_HTOTAL is $htotal, but estimated minimum viable setting for this configuration is $htotal_min."
            } else {
                send_message info   "Video timing: C_TIM_HTOTAL is $htotal and estimated minimum for this configuration is $htotal_min."
            }
        } else {
            send_message info   "Video timing: C_TIM_HTOTAL is $htotal.  Check that this complies with estimated minimum viable setting for this configuration: ($htotal_min * MIPI_D-PHY_core_clock_period / AXI-S_clock_period)."
        }
        # Horizontal PIP-multiple checks
        if {ceil($htotal/$pip) * $pip != $htotal} {
            send_message error  "C_TIM_HTOTAL must be an integer multiple of PIXELS_IN_PARALLEL."
        }
        #if {(ceil($hb_end/$pip) * $pip != $hb_end) && ($data_type != "YCbCr_12bit")} {
        #    send_message error  "C_TIM_HB_END must be an integer multiple of PIXELS_IN_PARALLEL."
        #}
        if {ceil($hs_start/$pip) * $pip != $hs_start} {
            send_message error  "C_TIM_HS_START must be an integer multiple of PIXELS_IN_PARALLEL."
        }
        if {ceil($v1s_hstart/$pip) * $pip != $v1s_hstart} {
            send_message error  "C_TIM_V1S_HSTART must be an integer multiple of PIXELS_IN_PARALLEL."
        }
        if {ceil($v1s_hend/$pip) * $pip != $v1s_hend} {
            send_message error  "C_TIM_V1S_HEND must be an integer multiple of PIXELS_IN_PARALLEL."
        }
        # HACTIVE length check
        if {$data_type=="YCbCr_12bit"} {
            if {$htotal - $hb_end != $frame_width_pixels/2} {
                send_message error  "When YCbCr_12bit is selected C_TIM_HTOTAL - C_TIM_HB_END must equal FRAME_WIDTH_PIXELS/2."
            }
        } else {
            if {$htotal - $hb_end != $frame_width_pixels} {
                send_message error  "C_TIM_HTOTAL - C_TIM_HB_END must equal FRAME_WIDTH_PIXELS."
            }
        }
        # sync and blanking consistency checks
        if {$hb_end >= $htotal} {
            send_message error  "C_TIM_HB_END must be less than C_TIM_HTOTAL."
        }
        if {$hs_start > $hs_end} {
            send_message error  "C_TIM_HS_START must be less than C_TIM_HS_END."
        }
        if {$hs_start >= $htotal} {
            send_message error  "C_TIM_HS_START must be less than C_TIM_HTOTAL."
        }
        if {$hs_end > $hb_end} {
            send_message error  "C_TIM_HS_END must be less than C_TIM_HB_END."
        }
        if {$v1s_hstart > $hb_end} {
            send_message error  "C_TIM_V1S_HSTART must be less than C_TIM_HB_END."
        }
        if {$v1s_hend > $hb_end} {
            send_message error  "C_TIM_V1S_HEND must be less than C_TIM_HB_END."
        }
        if {$v1b_start > $v1b_end} {
            # VBLANK starts at end of frame and ends after start of next (i.e. in blanking at end of frame)
            if {$v1s_vstart > $v1b_end && $v1s_vstart < $v1b_start} {
                send_message error  "C_TIM_V1S_VSTART must be between C_TIM_V1B_START and C_TIM_V1B_END."
            }
            if {!(($v1s_vstart < $v1b_end && $v1s_vend > $v1s_vstart && $v1s_vend < $v1b_end) || ($v1s_vstart > $v1b_end && ($v1s_vend > $v1s_vstart || $v1s_vend < $v1b_end)))} {
                send_message error  "C_TIM_V1S_VEND must be between C_TIM_V1S_VSTART and C_TIM_V1B_END."
            }
        } else {
            # VBLANK starts and ends at the same end of the frame (i.e. in V active region at end of frame)
            if {$v1s_vstart < $v1b_start || $v1s_vstart > $v1b_end} {
                send_message error  "C_TIM_V1S_VSTART must be between C_TIM_V1B_START and C_TIM_V1B_END."
            }
            if {$v1s_vend < $v1s_vstart || $v1s_vend > $v1b_end} {
                send_message error  "C_TIM_V1S_VEND must be between C_TIM_V1S_VSTART and C_TIM_V1B_END."
            }
        }
        if {$v1s_vstart >= $vtotal} {
            send_message error  "C_TIM_V1S_VSTART must be less than C_TIM_VTOTAL."
        }
        if {$v1s_vend >= $vtotal} {
            send_message error  "C_TIM_V1S_VEND must be less than C_TIM_VTOTAL."
        }
        if {$v1b_start >= $vtotal} {
            send_message error  "C_TIM_V1B_START must be less than C_TIM_VTOTAL."
        }
        if {$v1b_end >= $vtotal} {
            send_message error  "C_TIM_V1B_END must be less than C_TIM_VTOTAL."
        }
    } else {
        # validation disabled so just display HTOTAL guidance as info
        if {$clocks_are_same} {
            send_message info   "Video timing: C_TIM_HTOTAL is $htotal and recommended minimum for this configuration is $htotal_min."
        } else {
            send_message info   "Video timing: C_TIM_HTOTAL is $htotal.  Check that this complies with minimum viable setting for this configuration: ($htotal_min * MIPI_D-PHY_core_clock_period / AXI-S_clock_period)."
        }
    }
 
    # ----------------------
    #    DEVICE CHECKER
    # ----------------------
    set device_part [get_parameter_value DEVICE]
    set device_family [get_parameter_value FAMILY]
    set_display_item_property target_dev TEXT "<html>Device Selected:     Family: $device_family Device $device_part<br><br></html>"
 
    if {($device_family == "Agilex 3") || ($device_family == "Agilex 5")} {
        if {[regexp {(^A[0-9])([CDE])([A-Z])([0-9]{3})([AB])([A-Z0-9]{4})([EI])([0-9])([A-Z])(.*)} \
           $device_part _ \
           family series spec product_line device_group packages temp_grade core_speed power ES_suffix]} {
 
           #send_message info "$family $series $spec $product_line $device_group $packages $temp_grade $core_speed $power $ES_suffix"
           if {$spec == "Z"} {
              send_message error "This part $device_part does not support MIPI D-PHY"
           }
           if {$lanes == 8 && $packages == "B18A"} {
              send_message info "This part $device_part does not support 8 Lane DSI-2 Design Example"
           }
        }
    }
}
 
# --------------------------------------------------------------------------------------------------
# --                                                                                              --
# -- Composition callback
# -- Instantiate 3d_lut core and slave_front_end
# --                                                                                              --
# --------------------------------------------------------------------------------------------------
proc composition_cb {} {
    set direction [get_parameter_value DIRECTION]
    set frame_width_pixels [get_parameter_value FRAME_WIDTH_PIXELS]
    set lane [get_parameter_value LANE]
    set bits_per_lane [get_parameter_value BYTES_PER_LANE]*8
    set enable_passthrough [expr {[get_parameter_value ENABLE_PASSTHROUGH] == "true"}]
    set pip [get_parameter_value PIXELS_IN_PARALLEL]
    set data_type [get_parameter_value DATA_TYPE]
    set enable_csr [get_parameter_value ENABLE_CSR]
    set separate_slave_clk [get_parameter_value SEPARATE_SLAVE_CLOCK]
 
    #CVO
    set c_tim_hb_end     [get_parameter_value C_TIM_HB_END]
    set c_tim_hs_start   [get_parameter_value C_TIM_HS_START]
    set c_tim_hs_end     [get_parameter_value C_TIM_HS_END]
    set c_tim_htotal     [get_parameter_value C_TIM_HTOTAL]
 
    set c_tim_v1b_start  [get_parameter_value C_TIM_V1B_START]
    set c_tim_v1b_end    [get_parameter_value C_TIM_V1B_END]
    set c_tim_v1s_vstart [get_parameter_value C_TIM_V1S_VSTART]
    set c_tim_v1s_hstart [get_parameter_value C_TIM_V1S_HSTART]
    set c_tim_v1s_vend   [get_parameter_value C_TIM_V1S_VEND]
    set c_tim_v1s_hend   [get_parameter_value C_TIM_V1S_HEND]
    set c_tim_vtotal     [get_parameter_value C_TIM_VTOTAL]
 
    if {$enable_passthrough} {
        set tdata_width [ expr $lane * $bits_per_lane]
    } else {
        set bits_per_symbol         [get_input_bits_per_symbol $data_type]
        set number_of_color_planes  [get_input_number_of_color_planes $data_type]
        set bytes_per_pixel         [expr ($bits_per_symbol * $number_of_color_planes + 7) / 8]
        set tdata_width_bytes       [expr $bytes_per_pixel * $pip]
        set tdata_width             [expr $tdata_width_bytes * 8]
    }
 
    set_parameter_value TDATA_WIDTH $tdata_width
 
    # ------------------------------------------------------------------------
    # --
    # -- Add components
    # --
    # ------------------------------------------------------------------------#
    add_instance clock_in altera_clock_bridge 19.*
    add_instance reset_in altera_reset_bridge 19.*
 
    add_instance cvo_reset altera_reset_controller 19.*
    set_instance_parameter_value cvo_reset NUM_RESET_INPUTS {2}
 
    #
    # -- DSI2
    #
    add_instance dsi2 intel_mipi_dsi2_core                  [get_module_property VERSION]
    set_instance_parameter_value dsi2 BYTES_PER_LANE        [get_parameter_value BYTES_PER_LANE]
    set_instance_parameter_value dsi2 DATA_TYPE             $data_type
    set_instance_parameter_value dsi2 DIRECTION             $direction
    set_instance_parameter_value dsi2 ENABLE_PASSTHROUGH    $enable_passthrough
    set_instance_parameter_value dsi2 FRAME_WIDTH_PIXELS    $frame_width_pixels
    set_instance_parameter_value dsi2 LANE                  $lane
    set_instance_parameter_value dsi2 PIXELS_IN_PARALLEL    $pip
    set_instance_parameter_value dsi2 CLOCKS_ARE_SAME       [get_parameter_value CLOCKS_ARE_SAME]
    set_instance_parameter_value dsi2 ENABLE_CSR            $enable_csr
    set_instance_parameter_value dsi2 ENABLE_CRC            [get_parameter_value ENABLE_CRC]
    set_instance_parameter_value dsi2 ENABLE_ECC            [get_parameter_value ENABLE_ECC]
    set_instance_parameter_value dsi2 USE_CONTINUOUS_CLK    [get_parameter_value USE_CONTINUOUS_CLK]
    set_instance_parameter_value dsi2 TIMING_MODE           [get_parameter_value TIMING_MODE]
    set_instance_parameter_value dsi2 ENABLE_FIXED_LATENCY  [get_parameter_value ENABLE_FIXED_LATENCY]
    set_instance_parameter_value dsi2 PLAYOUT_LATENCY       [get_parameter_value PLAYOUT_LATENCY]
    set_instance_parameter_value dsi2 BUFFER_DEPTH          [get_parameter_value BUFFER_DEPTH]
 
    #
    # -- CVO
    #
    add_instance cvo intel_vvp_cvo 25.*
    set_instance_parameter_value cvo BPS                        ${bits_per_symbol}
    set_instance_parameter_value cvo NUMBER_OF_COLOR_PLANES     ${number_of_color_planes}
    set_instance_parameter_value cvo PIXELS_IN_PARALLEL         ${pip}
    set_instance_parameter_value cvo VIRTUAL_FR_HAS_TREADY      {1}
    set_instance_parameter_value cvo VIRTUAL_INTERNAL_VTIMING   {1}
    set_instance_parameter_value cvo RUNTIME_CONTROL            ${enable_csr}
    set_instance_parameter_value cvo EXTERNAL_MODE              {0}
    set_instance_parameter_value cvo DISABLE_INFO_MSGS          {1}
    set_instance_parameter_value cvo C_VID_IS_ASYNC             {0}
    set_instance_parameter_value cvo C_DEFAULT_OUT_IS_BLANK     {0}
    set_instance_parameter_value cvo C_VID_FIFO_DEPTH           {512}
    set_instance_parameter_value cvo C_HSIZE                    [eval {bits_required $c_tim_htotal}]
    set_instance_parameter_value cvo C_VSIZE                    [eval {bits_required $c_tim_vtotal}]
    # horizontal timing
    set_instance_parameter_value cvo C_TIM_HB_END               ${c_tim_hb_end}
    set_instance_parameter_value cvo C_TIM_HS_START             ${c_tim_hs_start}
    set_instance_parameter_value cvo C_TIM_HS_END               ${c_tim_hs_end}
    set_instance_parameter_value cvo C_TIM_HTOTAL               ${c_tim_htotal}
    # vertical timing
    set_instance_parameter_value cvo C_TIM_V1B_START            ${c_tim_v1b_start}
    set_instance_parameter_value cvo C_TIM_V1B_END              ${c_tim_v1b_end}
    set_instance_parameter_value cvo C_TIM_V1S_VSTART           ${c_tim_v1s_vstart}
    set_instance_parameter_value cvo C_TIM_V1S_HSTART           ${c_tim_v1s_hstart}
    set_instance_parameter_value cvo C_TIM_V1S_VEND             ${c_tim_v1s_vend}
    set_instance_parameter_value cvo C_TIM_V1S_HEND             ${c_tim_v1s_hend}
    set_instance_parameter_value cvo C_TIM_VTOTAL               ${c_tim_vtotal}
    # set unused timing parameters to safe values
    set_instance_parameter_value cvo C_TIM_F2_START             {65535}
    set_instance_parameter_value cvo C_TIM_V2B_START            {65535}
    set_instance_parameter_value cvo C_TIM_V2B_END              {65535}
    set_instance_parameter_value cvo C_TIM_V2S_VSTART           {65535}
    set_instance_parameter_value cvo C_TIM_V2S_HSTART           {65535}
    set_instance_parameter_value cvo C_TIM_V2S_VEND             {65535}
    set_instance_parameter_value cvo C_TIM_V2S_HEND             {65535}
 
    add_connection cvo.axi4s_fr_vid_out dsi2.axis_in
    if { $enable_csr } {
        add_connection dsi2.av_mm_cvo cvo.av_mm_cpu_agent
    }
 
    # ------------------------------------------------------------------------
    # --
    # -- Add IO
    # --
    # ------------------------------------------------------------------------#
    add_interface clk   clock end
    add_interface reset reset end
    set_interface_property clk      EXPORT_OF clock_in.in_clk
    set_interface_property reset    EXPORT_OF reset_in.in_reset
 
    # reset bridge
    add_connection clock_in.out_clk     reset_in.clk
 
    # reset controller for CVO
    # use main reset but also hold off CVO until D-PHY is initialised
    add_connection clock_in.out_clk     cvo_reset.clk
    add_connection reset_in.out_reset   cvo_reset.reset_in0
    add_connection dsi2.dphy_not_ready  cvo_reset.reset_in1
 
    # DSI2
    add_connection clock_in.out_clk     dsi2.axis_in_clock
    add_connection reset_in.out_reset   dsi2.axis_in_reset
 
    # CVO
    add_connection clock_in.out_clk     cvo.fr_clock
    add_connection cvo_reset.reset_out  cvo.fr_reset
 
    if { $enable_csr } {
        # add avalon input bus
        add_interface control avalon slave
        add_connection clock_in.out_clk     cvo.cpu_clock
        add_connection reset_in.out_reset   cvo.cpu_reset
 
        add_instance                        irq_bridge   mipi_irq_bridge            1.0
        set_instance_parameter_value        irq_bridge   SEPARATE_SLAVE_CLOCK       $separate_slave_clk
 
        add_connection clock_in.out_clk     irq_bridge.in_clock
        add_connection reset_in.out_reset   irq_bridge.in_reset
 
        if ($separate_slave_clk) {
            add_instance   slave_clk_bridge           altera_clock_bridge     19.*
            add_instance   slave_reset_bridge         altera_reset_bridge     19.*
            add_connection slave_clk_bridge.out_clk   slave_reset_bridge.clk
 
            add_interface           slave_clock    clock             end
            add_interface           slave_reset    reset             end
            set_interface_property  slave_clock    export_of         slave_clk_bridge.in_clk
            set_interface_property  slave_reset    export_of         slave_reset_bridge.in_reset
 
            add_instance                  cc_bridge   mm_ccb                                 19.*
            set_instance_parameter_value  cc_bridge   DATA_WIDTH                             32
            set_instance_parameter_value  cc_bridge   SYMBOL_WIDTH                           8
            set_instance_parameter_value  cc_bridge   ADDRESS_WIDTH                          9
            set_instance_parameter_value  cc_bridge   USE_AUTO_ADDRESS_WIDTH                 0
            set_instance_parameter_value  cc_bridge   ADDRESS_UNITS                          "WORDS"
            set_instance_parameter_value  cc_bridge   MAX_BURST_SIZE                         1
            set_instance_parameter_value  cc_bridge   COMMAND_FIFO_DEPTH                     4
            set_instance_parameter_value  cc_bridge   RESPONSE_FIFO_DEPTH                    4
            set_instance_parameter_value  cc_bridge   MASTER_SYNC_DEPTH                      3
            set_instance_parameter_value  cc_bridge   SLAVE_SYNC_DEPTH                       3
            set_instance_parameter_value  cc_bridge   SYNC_RESET                             1
 
            add_connection slave_clk_bridge.out_clk      cc_bridge.s0_clk
            add_connection slave_reset_bridge.out_reset  cc_bridge.s0_reset
 
            add_connection clock_in.out_clk              cc_bridge.m0_clk
            add_connection reset_in.out_reset            cc_bridge.m0_reset
 
            add_connection cc_bridge.m0                  dsi2.control
 
            set_interface_property control export_of cc_bridge.s0
 
            add_connection slave_clk_bridge.out_clk      irq_bridge.out_clock
            add_connection slave_reset_bridge.out_reset  irq_bridge.out_reset
 
            add_interface        control_irq   interrupt   end slave_clock
        } else {
            set_interface_property control export_of dsi2.control
            add_interface        control_irq   interrupt   end clk
        }
 
        add_connection         irq_bridge.in_irq   dsi2.control_interrupt
        set_interface_property control_irq export_of irq_bridge.out_irq
    }
 
    add_interface frame_start conduit end
    set_interface_property frame_start EXPORT_OF cvo.frame_start
 
    # add video input bus
    add_interface axi4s_vid_in axi4stream slave
    set_interface_property axi4s_vid_in export_of cvo.axi4s_vid_in
 
    # DHPY PPI INTERFACE
    # ADD INDEPENDENT INTERFACES FOR TX & RX
    if { $direction == "rx" } {
        add_interface ck_ppi_rx_err       conduit end
        add_interface ck_ppi_rx_hs_srst   reset end
        for {set i 0}  {$i < $lane} {incr i} {
            add_interface d$i\_ppi_rx_err       conduit end
            add_interface d$i\_ppi_rx_hs_srst   reset end
        }
    } else {
        add_interface ck_ppi_tx_lp_clk  clock end
        for {set i 0}  {$i < $lane} {incr i} {
            add_interface d$i\_ppi_tx_lp_clk  clock end
        }
    }
 
    # Export Interfaces
    if { $direction == "rx" } {
        set_interface_property ck_ppi_rx_err       EXPORT_OF dsi2.i_ck_ppi_rx_err
        set_interface_property ck_ppi_rx_hs_srst   EXPORT_OF dsi2.ck_ppi_rx_hs_srst
        for {set i 0}  {$i < $lane} {incr i} {
            set_interface_property d$i\_ppi_rx_err       EXPORT_OF dsi2.i_d$i\_ppi_rx_err
            set_interface_property d$i\_ppi_rx_hs_srst   EXPORT_OF dsi2.d$i\_ppi_rx_hs_srst
        }
    } else {
        set_interface_property ck_ppi_tx_lp_clk     EXPORT_OF dsi2.ck_ppi_tx_lp_clk
        for {set i 0}  {$i < $lane} {incr i} {
            set_interface_property d$i\_ppi_tx_lp_clk     EXPORT_OF dsi2.d$i\_ppi_tx_lp_clk
        }
    }
 
    # ADD COMMON INTERFACE FOR BOTH TX & RX
    add_interface ck_ppi_ctrl       conduit end
    add_interface ck_ppi_hs         conduit end
    add_interface ck_ppi_hs_clk     clock end
    add_interface ck_ppi_lp         conduit end
    for {set i 0}  {$i < $lane} {incr i} {
        add_interface d$i\_ppi_ctrl       conduit end
        add_interface d$i\_ppi_hs         conduit end
        add_interface d$i\_ppi_hs_clk     clock end
        add_interface d$i\_ppi_lp         conduit end
    }
 
    # Export Interfaces
    set_interface_property ck_ppi_ctrl          EXPORT_OF dsi2.ck_ppi_ctrl
    set_interface_property ck_ppi_hs            EXPORT_OF dsi2.ck_ppi_hs
    set_interface_property ck_ppi_hs_clk        EXPORT_OF dsi2.ck_ppi_hs_clk
    set_interface_property ck_ppi_lp            EXPORT_OF dsi2.ck_ppi_lp
    for {set i 0}  {$i < $lane} {incr i} {
        set_interface_property d$i\_ppi_ctrl          EXPORT_OF dsi2.d$i\_ppi_ctrl
        set_interface_property d$i\_ppi_hs            EXPORT_OF dsi2.d$i\_ppi_hs
        set_interface_property d$i\_ppi_hs_clk        EXPORT_OF dsi2.d$i\_ppi_hs_clk
        set_interface_property d$i\_ppi_lp            EXPORT_OF dsi2.d$i\_ppi_lp
    }
}
