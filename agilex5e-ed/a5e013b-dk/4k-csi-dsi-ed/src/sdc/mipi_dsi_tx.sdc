# I2C
create_clock -name {mipi_dsi2_tx_i2c_clk} -period "400Khz" [get_ports {mipi_dsi2_tx_i2c_scl}]

set_input_delay -clock [get_clocks mipi_dsi2_tx_i2c_clk] 100.000 [get_ports mipi_dsi2_tx_i2c_sda]
set_output_delay -clock [get_clocks mipi_dsi2_tx_i2c_clk] 100 [get_ports mipi_dsi2_tx_i2c_sda]
set_output_delay -clock [get_clocks mipi_dsi2_tx_i2c_clk] 100 [get_ports mipi_dsi2_tx_i2c_scl]

set_clock_groups -exclusive -group [get_clocks mipi_dsi2_tx_i2c_clk]

# DPHY TX serial lanes; timing/skew guaranteed by hard PHY
set_false_path -to [get_ports {
  mipi_dsi2_tx_dphy_link0_io_c_p \
  mipi_dsi2_tx_dphy_link0_io_c_n \
  mipi_dsi2_tx_dphy_link0_io_d_p[*] \
  mipi_dsi2_tx_dphy_link0_io_d_n[*] \
}]
