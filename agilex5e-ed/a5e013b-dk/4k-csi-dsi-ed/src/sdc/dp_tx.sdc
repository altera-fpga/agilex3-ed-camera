# *********************************************************************
# Constraint DisplayPort Aux port, HPD
# - AUX interface is transferring at 1Mbps
# *********************************************************************
set_false_path -to [get_ports pin_dp_tx_aux_oe]
set_false_path -to [get_ports pin_dp_tx_aux_out]
set_false_path -from [get_ports pin_dp_tx_hpd] -to *

