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

# I2C
create_clock -name {cam_i2c_clk} -period "400Khz" [get_ports {cam_i2c_scl}]
set_input_delay -clock [get_clocks cam_i2c_clk] 100 [get_ports cam_i2c_sda]
set_output_delay -clock [get_clocks cam_i2c_clk] 100 [get_ports cam_i2c_sda]

# set_clock_groups -exclusive -group [get_clocks cam_i2c_clk]
set_false_path -from {get_clocks u0|clock_subsystem|iopll_0|iopll_0_refclk} -to {get_clocks cam_i2c_clk}
set_false_path -from {get_clocks cam_i2c_clk}   -to {get_clocks u0|clock_subsystem|iopll_0|iopll_0_refclk}
