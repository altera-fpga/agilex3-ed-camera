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


package require -exact qsys 24.3

namespace eval intel_cvg_parameters {

    # Copied from VVP
    # --------------------------------------------------------------------------------------------------
    # -- Master/Slave parameters                                                                      --
    # --------------------------------------------------------------------------------------------------
    # -- add_enable_debug_parameters                                                                  --
    # -- add_separate_slave_clock_parameters                                                          --
    # -- add_axi_slave_parameters                                                                     --
    # -- add_runtime_control_parameters   enable_debug_param dual_clock_param slave_protocol_param    --
    # --------------------------------------------------------------------------------------------------

    proc add_enable_debug_parameters {} {
        add_parameter             ENABLE_DEBUG          INTEGER                 0
        set_parameter_property    ENABLE_DEBUG          DISPLAY_NAME            "Debug features"
        set_parameter_property    ENABLE_DEBUG          ALLOWED_RANGES          0:1
        set_parameter_property    ENABLE_DEBUG          DISPLAY_HINT            boolean
        set_parameter_property    ENABLE_DEBUG          DESCRIPTION             "Enable debug features"
        set_parameter_property    ENABLE_DEBUG          HDL_PARAMETER           true
        set_parameter_property    ENABLE_DEBUG          AFFECTS_ELABORATION     true
    }

    proc add_separate_slave_clock_parameters {} {
        add_parameter             SEPARATE_SLAVE_CLOCK  INTEGER                   0
        set_parameter_property    SEPARATE_SLAVE_CLOCK  DISPLAY_NAME              "Separate clock for control interface"
        set_parameter_property    SEPARATE_SLAVE_CLOCK  ALLOWED_RANGES            0:1
        set_parameter_property    SEPARATE_SLAVE_CLOCK  HDL_PARAMETER             false
        set_parameter_property    SEPARATE_SLAVE_CLOCK  DISPLAY_HINT              boolean
        set_parameter_property    SEPARATE_SLAVE_CLOCK  DESCRIPTION               "Run the run-time control interface on a different clock domain"
        set_parameter_property    SEPARATE_SLAVE_CLOCK  AFFECTS_ELABORATION       true
    }

    proc add_axi_slave_parameters {} {
        add_parameter            SLAVE_PROTOCOL           STRING                    "Avalon"
        set_parameter_property   SLAVE_PROTOCOL           DISPLAY_NAME              "Control interface protocol"
        set_parameter_property   SLAVE_PROTOCOL           ALLOWED_RANGES            {"Avalon" "AXI"}
        set_parameter_property   SLAVE_PROTOCOL           HDL_PARAMETER             false
        set_parameter_property   SLAVE_PROTOCOL           AFFECTS_ELABORATION       true
        set_parameter_property   SLAVE_PROTOCOL           VISIBLE                   false
    }

    proc add_runtime_control_parameters {{add_enable_debug 0} {dual_clock 0} {add_slave_protocol 0}} {
        add_parameter             RUNTIME_CONTROL       INTEGER                 0
        set_parameter_property    RUNTIME_CONTROL       DISPLAY_NAME            "Memory-mapped control interface"
        set_parameter_property    RUNTIME_CONTROL       ALLOWED_RANGES          0:1
        set_parameter_property    RUNTIME_CONTROL       DISPLAY_HINT            boolean
        set_parameter_property    RUNTIME_CONTROL       DESCRIPTION             "Enable memory mapped run-time control interface"
        set_parameter_property    RUNTIME_CONTROL       HDL_PARAMETER           true
        set_parameter_property    RUNTIME_CONTROL       AFFECTS_ELABORATION     true

        if { $add_enable_debug > 0 } {
            add_enable_debug_parameters
        }
        if { $dual_clock > 0 } {
            add_separate_slave_clock_parameters
        }
        if { $add_slave_protocol > 0 } {
            add_axi_slave_parameters
        }

    }

    # Add a nicely formatted integer parameter
    proc add_CVG_integer_param {tab name text value {range "0:9999"} {description ""} } {
        if {${description} == ""} {
            set description ${text}
        }
        add_parameter           ${name} INTEGER               ${value}
        set_parameter_property  ${name} DISPLAY_NAME          ${text}
        set_parameter_property  ${name} ALLOWED_RANGES        ${range}
        set_parameter_property  ${name} HDL_PARAMETER         true
        set_parameter_property  ${name} AFFECTS_ELABORATION   true
        set_parameter_property  ${name} DESCRIPTION           ${description}
        add_display_item        ${tab} ${name} parameter
    }

    # Add a nicely formatted boolean parameter with a "true/false" drop-down
    proc add_CVG_bool_param {tab name text value {description ""} } {
        if {${description} == ""} {
            set description ${text}
        }
        add_parameter           ${name} INTEGER               ${value}
        set_parameter_property  ${name} DISPLAY_NAME          ${text}
        set_parameter_property  ${name} ALLOWED_RANGES        {"0:False" "1:True"}
        set_parameter_property  ${name} HDL_PARAMETER         true
        set_parameter_property  ${name} AFFECTS_ELABORATION   true
        set_parameter_property  ${name} DESCRIPTION           ${description}
        add_display_item        ${tab} ${name} parameter
    }


    proc add_CVG_FR_tReady {{GUITab "Video Configuration"}} {

        add_parameter           VIRTUAL_FR_HAS_TREADY INTEGER               1
        set_parameter_property  VIRTUAL_FR_HAS_TREADY DISPLAY_NAME          "AXI4-S FR interface TREADY"
        set_parameter_property  VIRTUAL_FR_HAS_TREADY ALLOWED_RANGES        {"0:False" "1:True"}
        set_parameter_property  VIRTUAL_FR_HAS_TREADY HDL_PARAMETER         false
        set_parameter_property  VIRTUAL_FR_HAS_TREADY AFFECTS_ELABORATION   true
        set_parameter_property  VIRTUAL_FR_HAS_TREADY DESCRIPTION           "Enable the TREADY signal as part of the AXI4-S FR interface"
        add_display_item        ${GUITab} VIRTUAL_FR_HAS_TREADY parameter

    }

    proc add_CVG_RAM_depth_param {tab name text value {description ""} } {
        if {${description} == ""} {
            set description ${text}
        }
        add_parameter           ${name} INTEGER               ${value}
        set_parameter_property  ${name} DISPLAY_NAME          ${text}
        set_parameter_property  ${name} ALLOWED_RANGES        {512 1024 2048 4096}
        set_parameter_property  ${name} HDL_PARAMETER         true
        set_parameter_property  ${name} AFFECTS_ELABORATION   true
        set_parameter_property  ${name} DESCRIPTION           ${description}
        add_display_item        ${tab} ${name} parameter
    }

    # create a pair of parameters, a "virtual" one for the user on the GUI, and one a derived parameter for the HDL
    # an elab proc then derives the HDL parameter
    proc add_CVG_derived_param {tab name text min max {defaultValue ""} {description ""} } {
        if {${description} == ""} {
            set description ${text}
        }
        if {${defaultValue} == ""} {
            set defaultValue ${min}
        }


        add_parameter           VIRTUAL_${name} INTEGER               ${defaultValue}
        set_parameter_property  VIRTUAL_${name} DISPLAY_NAME          ${text}
        set_parameter_property  VIRTUAL_${name} ALLOWED_RANGES        ${min}:${max}
        set_parameter_property  VIRTUAL_${name} HDL_PARAMETER         false
        set_parameter_property  VIRTUAL_${name} AFFECTS_ELABORATION   true
        set_parameter_property  VIRTUAL_${name} DESCRIPTION           ${description}
        add_display_item        ${tab} VIRTUAL_${name} parameter

        add_parameter           ${name} INTEGER                     1
        set_parameter_property  ${name} VISIBLE             FALSE
        set_parameter_property  ${name} DERIVED             true
        set_parameter_property  ${name} HDL_PARAMETER       true

    }


    proc elab_CVG_pow2_param {name } {
        set size [get_parameter_value VIRTUAL_${name}]
        set bits 4
        set test 1
        for {set i 0} {$i<32} {incr i} {
            if { ${test} > ${size} } {
            set bits ${i}
            break;
            }
            set test [expr $test * 2]
        }
        set_parameter_value    ${name} ${bits}
    }

    proc add_cv_style_parameters {} {
        add_parameter           CV_STYLE STRING               "Lite"
        set_parameter_property  CV_STYLE DISPLAY_NAME         "CV bus style"
        set_parameter_property  CV_STYLE ALLOWED_RANGES       {"Lite" "CVI" "CVO"}
        set_parameter_property  CV_STYLE HDL_PARAMETER        true
        set_parameter_property  CV_STYLE AFFECTS_ELABORATION  true
        set_parameter_property  CV_STYLE DESCRIPTION          "Select the style of Clocked Video bus"
    }

    proc add_cv_lite_parameters { { tab_name "CV Lite Parameters" } } {

        add_parameter           LITE_USE_VALID            INTEGER                     0
        set_parameter_property  LITE_USE_VALID            ALLOWED_RANGES              {"0:Off" "1:On"}
        set_parameter_property  LITE_USE_VALID            HDL_PARAMETER               false
        set_parameter_property  LITE_USE_VALID            AFFECTS_ELABORATION         true
        set_parameter_property  LITE_USE_VALID            DISPLAY_NAME                "Valid signal"

        add_parameter           LITE_USE_READY            INTEGER                     0
        set_parameter_property  LITE_USE_READY            ALLOWED_RANGES              {"0:Off" "1:On"}
        set_parameter_property  LITE_USE_READY            HDL_PARAMETER               false
        set_parameter_property  LITE_USE_READY            AFFECTS_ELABORATION         true
        set_parameter_property  LITE_USE_READY            DISPLAY_NAME                "Ready signal"

        add_parameter           LITE_HV_MODE              STRING                      sync
        set_parameter_property  LITE_HV_MODE              ALLOWED_RANGES              {sync blank both}
        set_parameter_property  LITE_HV_MODE              HDL_PARAMETER               false
        set_parameter_property  LITE_HV_MODE              AFFECTS_ELABORATION         true
        set_parameter_property  LITE_HV_MODE              DISPLAY_NAME                "Timing signals"


        add_display_item ${tab_name} "Parameters"         GROUP
        add_display_item "Parameters" LITE_USE_VALID          parameter
        add_display_item "Parameters" LITE_USE_READY          parameter
        add_display_item "Parameters" LITE_HV_MODE            parameter

    }

    proc add_cvi_legacy_parameters { {direction "input"} {display_target "CVI Parameters"} } {


        add_parameter CVI_EXTRACT_TOTAL_RESOLUTION  INTEGER 1

        set_parameter_property CVI_EXTRACT_TOTAL_RESOLUTION HDL_PARAMETER false
        set_parameter_property CVI_EXTRACT_TOTAL_RESOLUTION DISPLAY_HINT boolean
        set_parameter_property CVI_EXTRACT_TOTAL_RESOLUTION AFFECTS_ELABORATION true
        set_parameter_property CVI_EXTRACT_TOTAL_RESOLUTION AFFECTS_GENERATION true
        if {${direction} == "input"} {
            set_parameter_property CVI_EXTRACT_TOTAL_RESOLUTION ALLOWED_RANGES {"0:Use External Signals" "1:Use Extra Logic"}
            set_parameter_property CVI_EXTRACT_TOTAL_RESOLUTION DISPLAY_NAME "Source for total resolution"
            set_parameter_property CVI_EXTRACT_TOTAL_RESOLUTION DESCRIPTION  "Defines how the core determines the total resolution for the video stream"
        } else {
            set_parameter_property CVI_EXTRACT_TOTAL_RESOLUTION ALLOWED_RANGES {"1:No Export" "0:Add Signals for Export"}
            set_parameter_property CVI_EXTRACT_TOTAL_RESOLUTION DISPLAY_NAME "Export the total resolution"
            set_parameter_property CVI_EXTRACT_TOTAL_RESOLUTION DESCRIPTION  "Include the total resolution from the CPU in the CV bus"
        }


        add_display_item ${display_target} "CVI Core Parameters" GROUP
        add_display_item "CVI Core Parameters" CVI_EXTRACT_TOTAL_RESOLUTION   parameter


        add_display_item ${display_target} "CVI Legacy Tie Offs" GROUP

        add_CVG_bool_param    "CVI Legacy Tie Offs" CVI_USE_VID_HD_SDN            "Include the vid_hd_sdn signal"        0
        add_CVG_bool_param    "CVI Legacy Tie Offs" CVI_USE_VID_STD               "Include the vid_std signal"           0
        add_CVG_integer_param "CVI Legacy Tie Offs" CVI_VID_STD_WIDTH             "Width of vid_std" 1 {"1:16"}          0
        add_CVG_bool_param    "CVI Legacy Tie Offs" CVI_USE_VID_HDMI_DUPLICATION  "Include the hdmi_duplication signal"  0

        set_parameter_property  CVI_USE_VID_HD_SDN            HDL_PARAMETER         false
        set_parameter_property  CVI_USE_VID_STD               HDL_PARAMETER         false
        set_parameter_property  CVI_VID_STD_WIDTH             HDL_PARAMETER         false
        set_parameter_property  CVI_USE_VID_HDMI_DUPLICATION  HDL_PARAMETER         false

    }

    proc add_cvo_legacy_parameters { {direction "output" } {display_target "CVO Parameters"} } {

        add_display_item ${display_target} "CVO Legacy Tie Offs" GROUP

        if {${direction} == "input"} {
            add_CVG_bool_param "CVO Legacy Tie Offs" CVO_USE_VID_CLK "Drive CV output clock" 1 "Drive the video clock onto the CV bus"
        } else {
            add_CVG_bool_param "CVO Legacy Tie Offs" CVO_USE_VID_CLK "Use CV clock" 1 "Use the video clock embedded in the CVO output bus"
        }

        add_CVG_bool_param    "CVO Legacy Tie Offs" CVO_USE_UNDERFLOW            "Include the underflow signal"       1
        add_CVG_bool_param    "CVO Legacy Tie Offs" CVO_USE_VID_MODE_CHANGE      "Include the vid_mode_change signal" 0
        add_CVG_bool_param    "CVO Legacy Tie Offs" CVO_USE_FRAME_LOCK           "Include frame lock signals"         0 "Include the vid_vcoclk_div, vid_sof_locked and vid_sof signals"
        add_CVG_bool_param    "CVO Legacy Tie Offs" CVO_USE_VID_STD              "Include the vid_std signal"         0
        add_CVG_integer_param "CVO Legacy Tie Offs" CVO_VID_STD_WIDTH            "Width of vid_std" 1 {"1:16"}        1

        set_parameter_property  CVO_USE_VID_CLK                       HDL_PARAMETER         false
        set_parameter_property  CVO_USE_UNDERFLOW                     HDL_PARAMETER         false
        set_parameter_property  CVO_USE_VID_MODE_CHANGE               HDL_PARAMETER         false
        set_parameter_property  CVO_USE_FRAME_LOCK                    HDL_PARAMETER         false
        set_parameter_property  CVO_USE_VID_STD                       HDL_PARAMETER         false
        set_parameter_property  CVO_VID_STD_WIDTH                     HDL_PARAMETER         false

    }
}