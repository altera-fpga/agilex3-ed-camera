package require -exact qsys 20.1

set_module_property NAME vfb_reset_ctrl
set_module_property DISPLAY_NAME "VFB Reset controller"
set_module_property DESCRIPTION "Reset controller for an intel_main_vfb instance"
set_module_property VERSION 99.0


add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL vfb_reset_ctrl
add_fileset_file vfb_reset_ctrl.sv SYSTEM_VERILOG PATH "src_hdl/vfb_reset_ctrl.sv" TOP_LEVEL_FILE
add_fileset_file vfb_reset_ctrl_synchronizer.sv SYSTEM_VERILOG PATH "src_hdl/vfb_reset_ctrl_synchronizer.sv"

add_fileset SIM_VERILOG QUARTUS_SYNTH "" ""
set_fileset_property SIM_VERILOG TOP_LEVEL vfb_reset_ctrl
add_fileset_file vfb_reset_ctrl.sv SYSTEM_VERILOG PATH "src_hdl/vfb_reset_ctrl.sv" TOP_LEVEL_FILE
add_fileset_file vfb_reset_ctrl_synchronizer.sv SYSTEM_VERILOG PATH "src_hdl/vfb_reset_ctrl_synchronizer.sv"

add_fileset SIM_VHDL QUARTUS_SYNTH "" ""
set_fileset_property SIM_VHDL TOP_LEVEL vfb_reset_ctrl
add_fileset_file vfb_reset_ctrl.sv SYSTEM_VERILOG PATH "src_hdl/vfb_reset_ctrl.sv" TOP_LEVEL_FILE
add_fileset_file vfb_reset_ctrl_synchronizer.sv SYSTEM_VERILOG PATH "src_hdl/vfb_reset_ctrl_synchronizer.sv"

add_parameter          RESET_CNTR_BITS INTEGER             8
set_parameter_property RESET_CNTR_BITS DISPLAY_NAME        "Bits used on reset extender counter"
set_parameter_property RESET_CNTR_BITS DESCRIPTION         "Extends reset for at least 2**RESET_CNTR_BITS cycles"
set_parameter_property RESET_CNTR_BITS HDL_PARAMETER       true
set_parameter_property RESET_CNTR_BITS AFFECTS_ELABORATION false

add_interface mem_clock clock end
add_interface_port mem_clock mem_clk clk Input 1

add_interface main_clock clock end
add_interface_port main_clock main_clk clk Input 1

add_interface          mem_reset_in reset            end
add_interface_port     mem_reset_in mem_rst_in       reset Input 1
set_interface_property mem_reset_in associatedClock  mem_clock
set_interface_property mem_reset_in synchronousEdges deassert

add_interface          mem_reset_out reset            start
add_interface_port     mem_reset_out mem_rst_out      reset output 1
set_interface_property mem_reset_out associatedClock  mem_clock
set_interface_property mem_reset_out synchronousEdges deassert
set_interface_property mem_reset_out associatedDirectReset "mem_reset_in"
set_interface_property mem_reset_out associatedResetSinks { "main_reset_in" "mem_reset_in" }

add_interface          main_reset_in reset            end
add_interface_port     main_reset_in main_rst_in      reset Input 1
set_interface_property main_reset_in associatedClock  main_clock
set_interface_property main_reset_in synchronousEdges deassert

add_interface          main_reset_out reset            start
add_interface_port     main_reset_out main_rst_out     reset output 1
set_interface_property main_reset_out associatedClock  main_clock
set_interface_property main_reset_out synchronousEdges deassert
set_interface_property main_reset_out associatedDirectReset "mem_reset_in"
set_interface_property main_reset_out associatedResetSinks { "main_reset_in" "mem_reset_in" }
