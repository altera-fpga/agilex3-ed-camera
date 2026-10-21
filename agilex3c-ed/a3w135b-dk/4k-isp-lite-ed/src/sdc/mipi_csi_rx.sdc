# I2C
create_clock -name {mipi_csi2_rx_i2c_clk} -period "400Khz" [get_ports {mipi_csi2_rx_i2c_scl}]
set_input_delay -clock [get_clocks mipi_csi2_rx_i2c_clk] 100 [get_ports mipi_csi2_rx_i2c_sda]
set_output_delay -clock [get_clocks mipi_csi2_rx_i2c_clk] 100 [get_ports mipi_csi2_rx_i2c_sda]

set_false_path -from {get_clocks u0|clock_subsystem|iopll_0|iopll_0_refclk} -to {get_clocks mipi_csi2_rx_i2c_clk}
set_false_path -from {get_clocks mipi_csi2_rx_i2c_clk} -to {get_clocks u0|clock_subsystem|iopll_0|iopll_0_refclk}
