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

set_max_skew  -from [get_keepers -nowarn "u0|board_subsystem|rst_controller|alt_rst_sync_uq1|altera_reset_synchronizer_int_chain_out"] -to [get_keepers -nowarn "u0|emif_subsystem|ddr4_emif|ddr4_emif|emif_arch_top|arch_emif_0.arch0_1ch_per_io.arch_0|lock_sync_inst|dreg[*]"] -get_skew_value_from_clock_period src_clock_period -skew_value_multiplier 0.8
set_max_delay -from [get_keepers -nowarn "u0|board_subsystem|rst_controller|alt_rst_sync_uq1|altera_reset_synchronizer_int_chain_out"] -to [get_keepers -nowarn "u0|emif_subsystem|ddr4_emif|ddr4_emif|emif_arch_top|arch_emif_0.arch0_1ch_per_io.arch_0|lock_sync_inst|dreg[*]"] 100
set_min_delay -from [get_keepers -nowarn "u0|board_subsystem|rst_controller|alt_rst_sync_uq1|altera_reset_synchronizer_int_chain_out"] -to [get_keepers -nowarn "u0|emif_subsystem|ddr4_emif|ddr4_emif|emif_arch_top|arch_emif_0.arch0_1ch_per_io.arch_0|lock_sync_inst|dreg[*]"] -100
set_net_delay -from [get_keepers -nowarn "u0|board_subsystem|rst_controller|alt_rst_sync_uq1|altera_reset_synchronizer_int_chain_out"] -to [get_keepers -nowarn "u0|emif_subsystem|ddr4_emif|ddr4_emif|emif_arch_top|arch_emif_0.arch0_1ch_per_io.arch_0|lock_sync_inst|dreg[*]"] -max -get_value_from_clock_period dst_clock_period -value_multiplier 0.8
