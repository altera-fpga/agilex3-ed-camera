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


# +-----------------------------------
# | MIPI Protocol Interfaces
# |
proc add_interface_port_with_desc {interface port_name port_type dir port_width {desc ""}} {
    # shortcut to add description property to port after construction
    add_interface_port     $interface $port_name $port_type $dir $port_width
    set_port_property      $port_name DESCRIPTION $desc
}

proc add_interface_ls_clk {} {
    add_interface                   ls_clk clock     end
    set_interface_property          ls_clk clockRate 0
    add_interface_port_with_desc    ls_clk ls_clk    clk  Input 1 "Continuous clock input"

    add_interface                   ls_rst reset            end
    set_interface_property          ls_rst associatedClock  ls_clk
    set_interface_property          ls_rst synchronousEdges DEASSERT
    add_interface_port_with_desc    ls_rst ls_rst           reset     Input 1  "Reset for continuous clock domain"
}

#
# COMMON PPI INTERFACE
#
proc get_lane_name {lane_num lanes} {
    if {$lane_num < $lanes} {
        return "d$lane_num"
    } else {
        return "ck"
    }
}

proc add_interface_ppi_tx_lp_clk {lanes} {
    for {set lane_num 0}  {$lane_num <= $lanes} {incr lane_num} {
        set lane_name [get_lane_name $lane_num $lanes]
        add_interface                   ${lane_name}_ppi_tx_lp_clk  clock                    end
        set_interface_property          ${lane_name}_ppi_tx_lp_clk  ENABLED                  true
        set_interface_property          ${lane_name}_ppi_tx_lp_clk  clockRate                0
        add_interface_port_with_desc    ${lane_name}_ppi_tx_lp_clk  tx_clk_esc_${lane_name}  clk        input  1 "PPI lane '$lane_name' clock for Tx LP.  Connect to DPHY IP."
    }
}

proc add_interface_ppi_rx_hs_srst {lanes} {
    for {set lane_num 0}  {$lane_num <= $lanes} {incr lane_num} {
        set lane_name [get_lane_name $lane_num $lanes]

        add_interface                   ${lane_name}_ppi_rx_hs_srst  reset                       end
        set_interface_property          ${lane_name}_ppi_rx_hs_srst  associatedClock             ${lane_name}_ppi_hs_clk
        set_interface_property          ${lane_name}_ppi_rx_hs_srst  synchronousEdges            DEASSERT
        set_interface_property          ${lane_name}_ppi_rx_hs_srst  ENABLED                     true
        add_interface_port_with_desc    ${lane_name}_ppi_rx_hs_srst  rx_srst_n_${lane_name}      reset_n    input  1 "PPI lane '$lane_name' reset for Rx HS clock.  Connect to DPHY IP."
    }
}

proc add_interface_ppi_rx_err {dir lanes} {
    for {set lane_num 0}  {$lane_num <= $lanes} {incr lane_num} {
        set lane_name [get_lane_name $lane_num $lanes]
        set index [string index $dir 0]
        if {$dir eq "input"} {
            set mode_text   "input"
            set dphy_text   "  Connect to DPHY IP."
        } else {
            set mode_text   "passthrough"
            set dphy_text   ""
        }
        add_interface                   ${index}_${lane_name}_ppi_rx_err conduit end
        set_interface_property          ${index}_${lane_name}_ppi_rx_err associatedReset   ${lane_name}_ppi_rx_hs_srst
        set_interface_property          ${index}_${lane_name}_ppi_rx_err ENABLED           true

        add_interface_port_with_desc    ${index}_${lane_name}_ppi_rx_err ${index}_err_sot_hs_${lane_name}           ErrSotHS            $dir 1 "PPI lane '${lane_name}' $mode_text DPHY Rx error flag ErrSotHS.$dphy_text"
        add_interface_port_with_desc    ${index}_${lane_name}_ppi_rx_err ${index}_err_sot_sync_hs_${lane_name}      ErrSotSyncHS        $dir 1 "PPI lane '${lane_name}' $mode_text DPHY Rx error flag ErrSotSyncHS.$dphy_text"
        add_interface_port_with_desc    ${index}_${lane_name}_ppi_rx_err ${index}_err_esc_${lane_name}              ErrEsc              $dir 1 "PPI lane '${lane_name}' $mode_text DPHY Rx error flag ErrEsc.$dphy_text"
        add_interface_port_with_desc    ${index}_${lane_name}_ppi_rx_err ${index}_err_sync_${lane_name}             ErrSyncEsc          $dir 1 "PPI lane '${lane_name}' $mode_text DPHY Rx error flag ErrSyncEsc.$dphy_text"
        add_interface_port_with_desc    ${index}_${lane_name}_ppi_rx_err ${index}_err_control_${lane_name}          ErrControl          $dir 1 "PPI lane '${lane_name}' $mode_text DPHY Rx error flag ErrControl.$dphy_text"
        add_interface_port_with_desc    ${index}_${lane_name}_ppi_rx_err ${index}_err_contention_lp0_${lane_name}   ErrContentionLP0    $dir 1 "PPI lane '${lane_name}' $mode_text DPHY Rx error flag ErrContentionLP0.$dphy_text"
        add_interface_port_with_desc    ${index}_${lane_name}_ppi_rx_err ${index}_err_contention_lp1_${lane_name}   ErrContentionLP1    $dir 1 "PPI lane '${lane_name}' $mode_text DPHY Rx error flag ErrContentionLP1.$dphy_text"
    }
}

proc add_interface_ppi_hs_clk {direction lanes} {
    for {set lane_num 0}  {$lane_num <= $lanes} {incr lane_num} {
        set lane_name [get_lane_name $lane_num $lanes]
        if {$direction eq "rx"} {
            set mode_text   "Rx"
        } else {
            set mode_text   "Tx"
        }
        add_interface                   ${lane_name}_ppi_hs_clk  clock                                    end
        set_interface_property          ${lane_name}_ppi_hs_clk  ENABLED                                  true
        add_interface_port_with_desc    ${lane_name}_ppi_hs_clk  ${direction}_word_clk_hs_${lane_name}    clk          input  1 "PPI lane '$lane_name' $mode_text HS word clock.  Connect to DPHY IP."
    }
}

proc add_interface_ppi_hs {direction lanes bits_per_lane} {
    for {set lane_num 0}  {$lane_num <= $lanes} {incr lane_num} {
        set lane_name [get_lane_name $lane_num $lanes]
        add_interface ${lane_name}_ppi_hs conduit end
        set_interface_property ${lane_name}_ppi_hs  associatedClock   ${lane_name}_ppi_hs_clk
        set_interface_property ${lane_name}_ppi_hs  ENABLED true

        if { $direction == "rx" } {
            add_interface_port_with_desc ${lane_name}_ppi_hs rx_data_width_hs_${lane_name}       RxDataWidthHS      output 2                 "PPI lane '$lane_name' Rx HS data width. Connect to DPHY IP."
            add_interface_port_with_desc ${lane_name}_ppi_hs rx_data_hs_${lane_name}             RxDataHS           input  $bits_per_lane    "PPI lane '$lane_name' Rx HS data. Connect to DPHY IP."
            add_interface_port_with_desc ${lane_name}_ppi_hs rx_valid_hs_${lane_name}            RxValidHS          input  $bits_per_lane/8  "PPI lane '$lane_name' Rx HS data word valid. Connect to DPHY IP."
            add_interface_port_with_desc ${lane_name}_ppi_hs rx_active_hs_${lane_name}           RxActiveHS         input  1                 "PPI lane '$lane_name' Rx HS active. Connect to DPHY IP."
            add_interface_port_with_desc ${lane_name}_ppi_hs rx_sync_hs_${lane_name}             RxSyncHS           input  1                 "PPI lane '$lane_name' Rx HS sync. Connect to DPHY IP."
            add_interface_port_with_desc ${lane_name}_ppi_hs rx_detect_eob_hs_${lane_name}       RxDetectEobHS      output 1                 "PPI lane '$lane_name' Rx HS end-of-burst detected. Connect to DPHY IP."
            add_interface_port_with_desc ${lane_name}_ppi_hs rx_clk_active_hs_${lane_name}       RxClkActiveHS      input  1                 "PPI lane '$lane_name' Rx HS clock active. Connect to DPHY IP."
            add_interface_port_with_desc ${lane_name}_ppi_hs rx_ddr_clk_hs_${lane_name}          RxDDRClkHS         input  1                 "PPI lane '$lane_name' Rx HS DDR clock as received. Connect to DPHY IP."
            add_interface_port_with_desc ${lane_name}_ppi_hs rx_skew_cal_hs_${lane_name}         RxSkewCalHS        input  1                 "PPI lane '$lane_name' Rx HS skew calibration active. Connect to DPHY IP."
            add_interface_port_with_desc ${lane_name}_ppi_hs rx_alternate_cal_hs_${lane_name}    RxAlternateCalHS   input  1                 "PPI lane '$lane_name' Rx HS alternate calibration active. Connect to DPHY IP."
            add_interface_port_with_desc ${lane_name}_ppi_hs rx_error_cal_hs_${lane_name}        RxErrorCalHS       input  1                 "PPI lane '$lane_name' Rx HS calibration error detected. Connect to DPHY IP."
            set_port_property rx_valid_hs_${lane_name} VHDL_TYPE "std_logic_vector"
        } else {
            add_interface_port_with_desc ${lane_name}_ppi_hs tx_data_width_hs_${lane_name}       TxDataWidthHS      output 2                 "PPI lane '$lane_name' Tx HS data width. Connect to DPHY IP."
            add_interface_port_with_desc ${lane_name}_ppi_hs tx_data_hs_${lane_name}             TxDataHS           output $bits_per_lane    "PPI lane '$lane_name' Tx HS data. Connect to DPHY IP."
            add_interface_port_with_desc ${lane_name}_ppi_hs tx_word_valid_hs_${lane_name}       TxWordValidHS      output $bits_per_lane/8  "PPI lane '$lane_name' Tx HS data word valid. Connect to DPHY IP."
            add_interface_port_with_desc ${lane_name}_ppi_hs tx_eq_active_hs_${lane_name}        TxEqActiveHS       output 1                 "PPI lane '$lane_name' Tx HS equalization active. Connect to DPHY IP."
            add_interface_port_with_desc ${lane_name}_ppi_hs tx_eq_level_hs_${lane_name}         TxEqLevelHS        output 1                 "PPI lane '$lane_name' Tx HS equalization level indicator. Connect to DPHY IP."
            add_interface_port_with_desc ${lane_name}_ppi_hs tx_request_hs_${lane_name}          TxRequestHS        output 1                 "PPI lane '$lane_name' Tx HS request. Connect to DPHY IP."
            add_interface_port_with_desc ${lane_name}_ppi_hs tx_ready_hs_${lane_name}            TxReadyHS          input  1                 "PPI lane '$lane_name' Tx HS ready. Connect to DPHY IP."
            add_interface_port_with_desc ${lane_name}_ppi_hs tx_data_transfer_en_hs_${lane_name} TxDataTransferEnHS output 1                 "PPI lane '$lane_name' Tx HS data transfer enable. Connect to DPHY IP."
            add_interface_port_with_desc ${lane_name}_ppi_hs tx_skew_cal_hs_${lane_name}         TxSkewCalHS        output 1                 "PPI lane '$lane_name' Tx HS skew calibration initiate. Connect to DPHY IP."
            add_interface_port_with_desc ${lane_name}_ppi_hs tx_alternate_cal_hs_${lane_name}    TxAlternateCalHS   output 1                 "PPI lane '$lane_name' Tx HS alternate calibration initiate. Connect to DPHY IP."
        }
    }
}

proc add_interface_ppi_lp {direction lanes} {
    for {set lane_num 0}  {$lane_num <= $lanes} {incr lane_num} {
        set lane_name [get_lane_name $lane_num $lanes]
        add_interface          ${lane_name}_ppi_lp  conduit end
        set_interface_property ${lane_name}_ppi_lp  associatedClock   ${lane_name}_ppi_tx_lp_clk
        set_interface_property ${lane_name}_ppi_lp  ENABLED true

        if { $direction == "rx" } {
            add_interface_port_with_desc ${lane_name}_ppi_lp rx_clk_esc_${lane_name}             RxClkEsc                  input  1 "PPI lane '$lane_name' Rx escape clock. Connect to DPHY IP."
            add_interface_port_with_desc ${lane_name}_ppi_lp rx_lpdt_esc_${lane_name}            RxLpdtEsc                 input  1 "PPI lane '$lane_name' Rx escape LP data active. Connect to DPHY IP."
            add_interface_port_with_desc ${lane_name}_ppi_lp rx_ulps_esc_${lane_name}            RxUlpsEsc                 input  1 "PPI lane '$lane_name' Rx ultra-low power state. Connect to DPHY IP."
            add_interface_port_with_desc ${lane_name}_ppi_lp rx_trigger_esc_${lane_name}         RxTriggerEsc              input  4 "PPI lane '$lane_name' Rx event triggered. Connect to DPHY IP."
            add_interface_port_with_desc ${lane_name}_ppi_lp rx_wake_up_${lane_name}             RxWakeup                  input  1 "PPI lane '$lane_name' Rx wakeup pulse detected. Connect to DPHY IP."
            add_interface_port_with_desc ${lane_name}_ppi_lp rx_data_esc_${lane_name}            RxDataEsc                 input  8 "PPI lane '$lane_name' Rx escape mode data. Connect to DPHY IP."
            add_interface_port_with_desc ${lane_name}_ppi_lp rx_valid_esc_${lane_name}           RxValidEsc                input  1 "PPI lane '$lane_name' Rx escape mode data valid. Connect to DPHY IP."
        } else {
            add_interface_port_with_desc ${lane_name}_ppi_lp tx_request_esc_${lane_name}         TxRequestEsc              output 1 "PPI lane '$lane_name' Tx escape request. Connect to DPHY IP."
            add_interface_port_with_desc ${lane_name}_ppi_lp tx_request_type_esc_${lane_name}    TxRequestTypeEsc          output 4 "PPI lane '$lane_name' Tx escape request type. Connect to DPHY IP."
            add_interface_port_with_desc ${lane_name}_ppi_lp tx_lpdt_esc_${lane_name}            TxLpdtEsc                 output 1 "PPI lane '$lane_name' Tx escape LP data active. Connect to DPHY IP."
            add_interface_port_with_desc ${lane_name}_ppi_lp tx_ulps_exit_${lane_name}           TxUlpsExit                output 1 "PPI lane '$lane_name' Tx ultra-low power state exit request. Connect to DPHY IP."
            add_interface_port_with_desc ${lane_name}_ppi_lp tx_ulps_esc_${lane_name}            TxUlpsEsc                 output 1 "PPI lane '$lane_name' Tx ultra-low power state entry request. Connect to DPHY IP."
            add_interface_port_with_desc ${lane_name}_ppi_lp tx_trigger_esc_${lane_name}         TxTriggerEsc              output 4 "PPI lane '$lane_name' Tx event trigger. Connect to DPHY IP."
            add_interface_port_with_desc ${lane_name}_ppi_lp tx_data_esc_${lane_name}            TxDataEsc                 output 8 "PPI lane '$lane_name' Tx escape mode data. Connect to DPHY IP."
            add_interface_port_with_desc ${lane_name}_ppi_lp tx_valid_esc_${lane_name}           TxValidEsc                output 1 "PPI lane '$lane_name' Tx escape mode data valid. Connect to DPHY IP."
            add_interface_port_with_desc ${lane_name}_ppi_lp tx_ready_esc_${lane_name}           TxReadyEsc                input  1 "PPI lane '$lane_name' Tx escape ready. Connect to DPHY IP."
        }
    }
}

proc add_interface_ppi_ctrl {lanes} {
    for {set lane_num 0}  {$lane_num <= $lanes} {incr lane_num} {
        set lane_name [get_lane_name $lane_num $lanes]
        add_interface ${lane_name}_ppi_ctrl conduit end
        set_interface_property ${lane_name}_ppi_ctrl ENABLED true

        add_interface_port_with_desc ${lane_name}_ppi_ctrl turn_request_${lane_name}           TurnRequest               output 1 "PPI lane '$lane_name' turnaround request. Connect to DPHY IP."
        add_interface_port_with_desc ${lane_name}_ppi_ctrl direction_${lane_name}              Direction                 input  1 "PPI lane '$lane_name' direction. Connect to DPHY IP."
        add_interface_port_with_desc ${lane_name}_ppi_ctrl turn_disable_${lane_name}           TurnDisable               output 1 "PPI lane '$lane_name' disable turnaround. Connect to DPHY IP."
        add_interface_port_with_desc ${lane_name}_ppi_ctrl force_rx_mode_${lane_name}          ForceRxmode               output 1 "PPI lane '$lane_name' force to Rx mode. Connect to DPHY IP."
        add_interface_port_with_desc ${lane_name}_ppi_ctrl force_tx_stop_mode_${lane_name}     ForceTxStopmode           output 1 "PPI lane '$lane_name' force to Tx stop mode. Connect to DPHY IP."
        add_interface_port_with_desc ${lane_name}_ppi_ctrl stop_state_${lane_name}             Stopstate                 input  1 "PPI lane '$lane_name' lane is in stop state. Connect to DPHY IP."
        add_interface_port_with_desc ${lane_name}_ppi_ctrl enable_${lane_name}                 Enable                    output 1 "PPI lane '$lane_name' enable. Connect to DPHY IP."
        add_interface_port_with_desc ${lane_name}_ppi_ctrl alp_mode_${lane_name}               AlpMode                   output 1 "PPI lane '$lane_name' ALP mode selected. Connect to DPHY IP."
        add_interface_port_with_desc ${lane_name}_ppi_ctrl tx_ulps_clk_${lane_name}            TxUlpsClk                 output 1 "PPI lane '$lane_name' force Tx clock lane into ULPS. Connect to DPHY IP."
        add_interface_port_with_desc ${lane_name}_ppi_ctrl rx_ulps_clk_not_${lane_name}        RxUlpsClkNot              input  1 "PPI lane '$lane_name' Rx clock lane is in ULPS. Connect to DPHY IP."
        add_interface_port_with_desc ${lane_name}_ppi_ctrl ulps_active_not_${lane_name}        UlpsActiveNot             input  1 "PPI lane '$lane_name' ULPS inactive. Connect to DPHY IP."
        add_interface_port_with_desc ${lane_name}_ppi_ctrl tx_hsidle_clk_hs_${lane_name}       TxHSIdleClkHS             output 1 "PPI lane '$lane_name' initiate HS idle. Connect to DPHY IP."
        add_interface_port_with_desc ${lane_name}_ppi_ctrl tx_hsidle_clk_ready_hs_${lane_name} TxHSIdleClkReadyHS        input  1 "PPI lane '$lane_name' ready for HS idle initiation. Connect to DPHY IP."
    }
}

#
# AVALON-MM CONTROL INTERFACE
#
proc add_interface_avalon_mm {enable separate_slave_clock} {
    add_interface          avalon_mm_control_interface           avalon                         INPUT
    set_interface_property avalon_mm_control_interface           ENABLED                        ${enable}
    if {$separate_slave_clock} {
        set_interface_property avalon_mm_control_interface           associatedClock                slave_clock
        set_interface_property avalon_mm_control_interface           associatedReset                slave_reset
    } else {
        set_interface_property avalon_mm_control_interface           associatedClock                axi4s_clk
        set_interface_property avalon_mm_control_interface           associatedReset                axi4s_rst
    }

    set_interface_property avalon_mm_control_interface           setupTime                      0
    set_interface_property avalon_mm_control_interface           holdTime                       0
    set_interface_property avalon_mm_control_interface           timingUnits                    Cycles
    set_interface_property avalon_mm_control_interface           readWaitTime                   0
    set_interface_property avalon_mm_control_interface           writeWaitTime                  0
    set_interface_property avalon_mm_control_interface           alwaysBurstMaxBurst            words
    set_interface_property avalon_mm_control_interface           burstcountUnits                words
    set_interface_property avalon_mm_control_interface           burstOnBurstBoundariesOnly     false
    set_interface_property avalon_mm_control_interface           linewrapBursts                 false
    set_interface_property avalon_mm_control_interface           isMemoryDevice                 false
    set_interface_property avalon_mm_control_interface           isNonVolatileStorage           false
    set_interface_property avalon_mm_control_interface           minimumUninterruptedRunLength  1
    set_interface_property avalon_mm_control_interface           printableDevice                false
    set_interface_property avalon_mm_control_interface           readLatency                    0
    set_interface_property avalon_mm_control_interface           maximumPendingReadTransactions 1

    add_interface_port_with_desc     avalon_mm_control_interface           control_write                  write                       Input     1   "Write"
    add_interface_port_with_desc     avalon_mm_control_interface           control_read                   read                        Input     1   "Read"
    add_interface_port_with_desc     avalon_mm_control_interface           control_address                address                     Input     10  "Address"
    add_interface_port_with_desc     avalon_mm_control_interface           control_writedata              writedata                   Input     32  "Write data"
    add_interface_port_with_desc     avalon_mm_control_interface           control_readdata               readdata                    Output    32  "Read data"
    add_interface_port_with_desc     avalon_mm_control_interface           control_readdatavalid          readdatavalid               Output    1   "Read data valid"
    add_interface_port_with_desc     avalon_mm_control_interface           control_waitrequest            waitrequest                 Output    1   "Wait request"
    add_interface_port_with_desc     avalon_mm_control_interface           control_byteenable             byteenable                  Input     4   "Byte enable"

    add_interface          avalon_mm_control_interface_interrupt interrupt                      sender                      axi4s_clk
    set_interface_property avalon_mm_control_interface_interrupt associatedAddressablePoint     avalon_mm_control_interface
    add_interface_port_with_desc     avalon_mm_control_interface_interrupt control_irq                    irq                         Output    1   "Interrupt request"
}

proc add_interface_avalon_mm_dsi2_slave {enable control_name addr_width} {
    add_interface                  $control_name           avalon                         slave
    set_interface_property         $control_name           ENABLED                        ${enable}

    set_interface_property         $control_name           associatedClock                axis_in_clock
    set_interface_property         $control_name           associatedReset                axis_in_reset

    set_interface_property         $control_name           setupTime                      0
    set_interface_property         $control_name           holdTime                       0
    set_interface_property         $control_name           timingUnits                    Cycles
    set_interface_property         $control_name           readWaitTime                   0
    set_interface_property         $control_name           writeWaitTime                  0
    set_interface_property         $control_name           alwaysBurstMaxBurst            words
    set_interface_property         $control_name           burstcountUnits                words
    set_interface_property         $control_name           burstOnBurstBoundariesOnly     false
    set_interface_property         $control_name           linewrapBursts                 false
    set_interface_property         $control_name           isMemoryDevice                 false
    set_interface_property         $control_name           isNonVolatileStorage           false
    set_interface_property         $control_name           minimumUninterruptedRunLength  1
    set_interface_property         $control_name           printableDevice                false
    set_interface_property         $control_name           readLatency                    0
    set_interface_property         $control_name           maximumPendingReadTransactions 1

    add_interface_port_with_desc   $control_name           ${control_name}_write           write                       Input     1            "Write"
    add_interface_port_with_desc   $control_name           ${control_name}_read            read                        Input     1            "Read"
    add_interface_port_with_desc   $control_name           ${control_name}_address         address                     Input     $addr_width  "Address"
    add_interface_port_with_desc   $control_name           ${control_name}_writedata       writedata                   Input     32           "Write data"
    add_interface_port_with_desc   $control_name           ${control_name}_readdata        readdata                    Output    32           "Read data"
    add_interface_port_with_desc   $control_name           ${control_name}_readdatavalid   readdatavalid               Output    1            "Read data valid"
    add_interface_port_with_desc   $control_name           ${control_name}_waitrequest     waitrequest                 Output    1            "Wait request"
    add_interface_port_with_desc   $control_name           ${control_name}_byteenable      byteenable                  Input     4            "Byte enable"

    add_interface                  ${control_name}_interrupt interrupt                     sender                      axis_in_clock
    set_interface_property         ${control_name}_interrupt associatedAddressablePoint    $control_name
    add_interface_port_with_desc   ${control_name}_interrupt ${control_name}_irq           irq                         Output    1            "Interrupt request"
}

proc add_interface_avalon_mm_dsi2_master {enable control_name addr_width} {
    add_interface                  $control_name           avalon                         master
    set_interface_property         $control_name           ENABLED                        ${enable}

    set_interface_property         $control_name           associatedClock                axis_in_clock
    set_interface_property         $control_name           associatedReset                axis_in_reset

    set_interface_property         $control_name           setupTime                      0
    set_interface_property         $control_name           holdTime                       0
    set_interface_property         $control_name           timingUnits                    Cycles
    set_interface_property         $control_name           readWaitTime                   0
    set_interface_property         $control_name           writeWaitTime                  0
    set_interface_property         $control_name           alwaysBurstMaxBurst            words
    set_interface_property         $control_name           burstcountUnits                words
    set_interface_property         $control_name           burstOnBurstBoundariesOnly     false
    set_interface_property         $control_name           linewrapBursts                 false
    set_interface_property         $control_name           readLatency                    0
    set_interface_property         $control_name           maximumPendingReadTransactions 1

    add_interface_port_with_desc   $control_name           ${control_name}_write           write                       Output     1            "Write"
    add_interface_port_with_desc   $control_name           ${control_name}_read            read                        Output     1            "Read"
    add_interface_port_with_desc   $control_name           ${control_name}_address         address                     Output     $addr_width  "Address"
    add_interface_port_with_desc   $control_name           ${control_name}_writedata       writedata                   Output     32           "Write data"
    add_interface_port_with_desc   $control_name           ${control_name}_readdata        readdata                    Input      32           "Read data"
    add_interface_port_with_desc   $control_name           ${control_name}_readdatavalid   readdatavalid               Input      1            "Read data valid"
    add_interface_port_with_desc   $control_name           ${control_name}_waitrequest     waitrequest                 Input      1            "Wait request"
    add_interface_port_with_desc   $control_name           ${control_name}_byteenable      byteenable                  Output     4            "Byte enable"
}

proc add_interface_axis_clk_reset {enable} {
    add_interface          axi4s_clk clock            end
    set_interface_property axi4s_clk clockRate        0
    set_interface_property axi4s_clk ENABLED          $enable
    add_interface_port_with_desc     axi4s_clk axi4s_clk        clk       Input 1   "Clock used for video streaming and control interfaces.  Refer to the user guide for detailed restrictions on the rate of this clock depending on configuration."

    add_interface          axi4s_rst reset            end
    set_interface_property axi4s_rst associatedClock  axi4s_clk
    set_interface_property axi4s_rst synchronousEdges DEASSERT
    set_interface_property axi4s_rst ENABLED          $enable
    add_interface_port_with_desc     axi4s_rst axi4s_rst        reset     Input 1   "Reset for axi4s_clk domain."
}

proc add_interface_avalon_clk_reset {enable} {
    add_interface          slave_clock clock            end
    set_interface_property slave_clock clockRate        0
    set_interface_property slave_clock ENABLED          $enable
    add_interface_port_with_desc     slave_clock slave_clock        clk       Input 1   "Clock used for AVALON-MM control interfaces. "

    add_interface          slave_reset reset            end
    set_interface_property slave_reset associatedClock  slave_clock
    set_interface_property slave_reset synchronousEdges DEASSERT
    set_interface_property slave_reset ENABLED          $enable
    add_interface_port_with_desc     slave_reset slave_reset        reset     Input 1   "Reset for slave_clock domain."
}

#
# VIDEO STREAMING INTERFACES
#
proc add_interface_video_axi {enable direction} {
    set number_of_video_streaming_interfaces [get_parameter_value NUMBER_OF_VIDEO_STREAMING_INTERFACES]

    if { $direction == "rx" } {
        for {set i 0}  {$i < $number_of_video_streaming_interfaces} {incr i} {
            add_interface          video_streaming_interface_$i axi4stream                 start
            set_interface_property video_streaming_interface_$i associatedClock            axi4s_clk
            set_interface_property video_streaming_interface_$i associatedReset            axi4s_rst
            set_interface_property video_streaming_interface_$i ENABLED                    $enable
            add_interface_port_with_desc     video_streaming_interface_$i axi4s_vid_out_${i}_tdata  tdata  Output "VVP_DATA_WIDTH"   "Rx video channel $i pixel data.  See the Intel FPGA Streaming Video Protocol specification for details."
            add_interface_port_with_desc     video_streaming_interface_$i axi4s_vid_out_${i}_tvalid tvalid Output 1                  "Rx video channel $i data valid."
            add_interface_port_with_desc     video_streaming_interface_$i axi4s_vid_out_${i}_tready tready Input  1                  "Rx video channel $i TREADY."
            add_interface_port_with_desc     video_streaming_interface_$i axi4s_vid_out_${i}_tlast  tlast  Output 1                  "Rx video channel $i TLAST."
            add_interface_port_with_desc     video_streaming_interface_$i axi4s_vid_out_${i}_tuser  tuser  Output "VVP_USER_WIDTH"   "Rx video channel $i TUSER."
        }
    } else {
        for {set i 0}  {$i < $number_of_video_streaming_interfaces} {incr i} {
            add_interface          video_streaming_interface_$i axi4stream                 end
            set_interface_property video_streaming_interface_$i associatedClock            axi4s_clk
            set_interface_property video_streaming_interface_$i associatedReset            axi4s_rst
            set_interface_property video_streaming_interface_$i ENABLED                    $enable
            add_interface_port_with_desc     video_streaming_interface_$i axi4s_vid_in_${i}_tdata   tdata  Input  "VVP_DATA_WIDTH"   "Tx video channel $i pixel data.  See the Intel FPGA Streaming Video Protocol specification for details."
            add_interface_port_with_desc     video_streaming_interface_$i axi4s_vid_in_${i}_tvalid  tvalid Input  1                  "Tx video channel $i data valid."
            add_interface_port_with_desc     video_streaming_interface_$i axi4s_vid_in_${i}_tready  tready Output 1                  "Tx video channel $i TREADY."
            add_interface_port_with_desc     video_streaming_interface_$i axi4s_vid_in_${i}_tlast   tlast  Input  1                  "Tx video channel $i TLAST."
            add_interface_port_with_desc     video_streaming_interface_$i axi4s_vid_in_${i}_tuser   tuser  Input  "VVP_USER_WIDTH"   "Tx video channel $i TUSER."
        }
    }
}

#
# AUX PACKET INTERFACES
#
proc add_interface_aux_packet {enable direction} {
    set aux_data_width 32
    set aux_user_width 32
    set number_of_video_streaming_interfaces [get_parameter_value NUMBER_OF_VIDEO_STREAMING_INTERFACES]

    if { $direction == "tx" } {
        for {set i 0}  {$i < 4} {incr i} {
            add_interface          aux_packet_interface_$i axi4stream             end
            set_interface_property aux_packet_interface_$i associatedClock        axi4s_clk
            set_interface_property aux_packet_interface_$i associatedReset        axi4s_rst
            if { $number_of_video_streaming_interfaces > $i } {
                set_interface_property aux_packet_interface_$i ENABLED            $enable
            } else {
                set_interface_property aux_packet_interface_$i ENABLED            false
            }
            add_interface_port_with_desc     aux_packet_interface_$i axi4s_aux_in_${i}_tdata  tdata  Input  $aux_data_width       "Tx aux channel $i MIPI packet data input.  See the user guide for details."
            add_interface_port_with_desc     aux_packet_interface_$i axi4s_aux_in_${i}_tvalid tvalid Input  1                     "Tx aux channel $i MIPI packet data valid."
            add_interface_port_with_desc     aux_packet_interface_$i axi4s_aux_in_${i}_tready tready Output 1                     "Tx aux channel $i MIPI packet TREADY."
            add_interface_port_with_desc     aux_packet_interface_$i axi4s_aux_in_${i}_tlast  tlast  Input  1                     "Tx aux channel $i MIPI packet TLAST."
            add_interface_port_with_desc     aux_packet_interface_$i axi4s_aux_in_${i}_tkeep  tkeep  Input "MIPI_DATA_WIDTH/8"    "Tx aux channel $i MIPI packet TKEEP."
            add_interface_port_with_desc     aux_packet_interface_$i axi4s_aux_in_${i}_tuser  tuser  Input  $aux_user_width       "Tx aux channel $i MIPI packet TUSER."
        }
    } else {
        # rx ports
        for {set i 0}  {$i < 4} {incr i} {
            add_interface          aux_packet_interface_$i axi4stream             start
            set_interface_property aux_packet_interface_$i associatedClock        axi4s_clk
            set_interface_property aux_packet_interface_$i associatedReset        axi4s_rst
            if { $number_of_video_streaming_interfaces > $i } {
                set_interface_property aux_packet_interface_$i ENABLED            $enable
            } else {
                set_interface_property aux_packet_interface_$i ENABLED            false
            }
            add_interface_port_with_desc     aux_packet_interface_$i axi4s_aux_out_${i}_tdata  tdata  Output $aux_data_width     "Rx aux channel $i MIPI packet data output.  See the user guide for details."
            add_interface_port_with_desc     aux_packet_interface_$i axi4s_aux_out_${i}_tvalid tvalid Output 1                   "Rx aux channel $i MIPI packet data valid."
            add_interface_port_with_desc     aux_packet_interface_$i axi4s_aux_out_${i}_tready tready Input  1                   "Rx aux channel $i MIPI packet TREADY."
            add_interface_port_with_desc     aux_packet_interface_$i axi4s_aux_out_${i}_tlast  tlast  Output 1                   "Rx aux channel $i MIPI packet TLAST."
            add_interface_port_with_desc     aux_packet_interface_$i axi4s_aux_out_${i}_tkeep  tkeep  Output "MIPI_DATA_WIDTH/8" "Rx aux channel $i MIPI packet TKEEP."
            add_interface_port_with_desc     aux_packet_interface_$i axi4s_aux_out_${i}_tuser  tuser  Output $aux_user_width     "Rx aux channel $i MIPI packet TUSER."
        }
    }
}

#
# MIPI PACKET INTERFACES
#
proc add_interface_mipi_packet {enable direction number_of_video_streaming_interfaces} {
    set mipi_data_width [get_parameter_value MIPI_DATA_WIDTH]
    set mipi_tuser_width [get_parameter_value MIPI_TUSER_WIDTH]

    if { $direction == "rx" } {
        if {$enable} {
            add_interface          mipi_packet_interface axi4stream             start
            set_interface_property mipi_packet_interface associatedClock        axi4s_clk
            set_interface_property mipi_packet_interface associatedReset        axi4s_rst
            set_interface_property mipi_packet_interface ENABLED                true
            add_interface_port_with_desc     mipi_packet_interface axi4s_mipi_out_tdata   tdata  Output "MIPI_DATA_WIDTH"   "Rx MIPI packet passthrough data output.  See the user guide for details."
            add_interface_port_with_desc     mipi_packet_interface axi4s_mipi_out_tvalid  tvalid Output 1                   "Rx MIPI packet passthrough data valid."
            add_interface_port_with_desc     mipi_packet_interface axi4s_mipi_out_tready  tready Input  1                   "Rx MIPI packet passthrough TREADY."
            add_interface_port_with_desc     mipi_packet_interface axi4s_mipi_out_tlast   tlast  Output 1                   "Rx MIPI packet passthrough TLAST."
            add_interface_port_with_desc     mipi_packet_interface axi4s_mipi_out_tkeep   tkeep  Output "MIPI_DATA_WIDTH/8" "Rx MIPI packet passthrough TKEEP."
            add_interface_port_with_desc     mipi_packet_interface axi4s_mipi_out_tuser   tuser  Output "MIPI_TUSER_WIDTH"  "Rx MIPI packet passthrough TUSER."
        }
    } else {
        if {$enable} {
            for {set i 0}  {$i < $number_of_video_streaming_interfaces} {incr i} {
                add_interface          mipi_packet_interface_$i axi4stream             end
                set_interface_property mipi_packet_interface_$i associatedClock        axi4s_clk
                set_interface_property mipi_packet_interface_$i associatedReset        axi4s_rst
                set_interface_property mipi_packet_interface_$i ENABLED                true
                add_interface_port_with_desc     mipi_packet_interface_$i axi4s_mipi_in_${i}_tdata  tdata   input   $mipi_data_width    "Tx MIPI packet passthrough channel $i data output.  See the user guide for details."
                add_interface_port_with_desc     mipi_packet_interface_$i axi4s_mipi_in_${i}_tvalid tvalid  input   1                   "Tx MIPI packet passthrough channel $i data valid."
                add_interface_port_with_desc     mipi_packet_interface_$i axi4s_mipi_in_${i}_tready tready  output  1                   "Tx MIPI packet passthrough channel $i TREADY."
                add_interface_port_with_desc     mipi_packet_interface_$i axi4s_mipi_in_${i}_tlast  tlast   input   1                   "Tx MIPI packet passthrough channel $i TLAST."
                add_interface_port_with_desc     mipi_packet_interface_$i axi4s_mipi_in_${i}_tkeep  tkeep   input   $mipi_data_width/8  "Tx MIPI packet passthrough channel $i TKEEP."
                add_interface_port_with_desc     mipi_packet_interface_$i axi4s_mipi_in_${i}_tuser  tuser   input   $mipi_tuser_width   "Tx MIPI packet passthrough channel $i TUSER."
                set tdata_start_bit [expr { ($i+1)*$mipi_data_width-1 }]
                set tdata_end_bit   [expr {  $i*$mipi_data_width }]
                set_port_property axi4s_mipi_in_${i}_tdata fragment_list "axi4s_mipi_in_tdata(${tdata_start_bit}:${tdata_end_bit})"
                set tkeep_start_bit [expr { ($i+1)*($mipi_data_width/8)-1 }]
                set tkeep_end_bit   [expr {  $i*($mipi_data_width/8) }]
                set_port_property axi4s_mipi_in_${i}_tkeep fragment_list "axi4s_mipi_in_tkeep(${tkeep_start_bit}:${tkeep_end_bit})"
                set tuser_start_bit [expr { ($i+1)*$mipi_tuser_width-1 }]
                set tuser_end_bit   [expr {  $i*$mipi_tuser_width }]
                set_port_property axi4s_mipi_in_${i}_tuser fragment_list "axi4s_mipi_in_tuser(${tuser_start_bit}:${tuser_end_bit})"
                set_port_property axi4s_mipi_in_${i}_tvalid fragment_list "axi4s_mipi_in_tvalid($i)"
                set_port_property axi4s_mipi_in_${i}_tlast fragment_list "axi4s_mipi_in_tlast($i)"
                set_port_property axi4s_mipi_in_${i}_tready fragment_list "axi4s_mipi_in_tready($i)"
            }
        }
    }
}

# --------------------------------------------------------------------------------------------------
# --                                                                                              --
# -- Port declarations for the most common port types used by by our IPs                          --
# --                                                                                              --
# --------------------------------------------------------------------------------------------------
namespace eval intel_mtm_interfaces {

    # --------------------------------------------------------------------------------------------------
    # -- Generic clock with synchronous reset
    # --------------------------------------------------------------------------------------------------
    # add_clock_reset_intf {string}
    # Add clock and reset interfaces to the component
    # \param     intf_name, basename for the two interfaces
    #            sig_pref, optional prefix for the wire names (${sig_pref}_clk and ${sig_pref}_rst)
    #                      the wires are assumed to be clk and rst if sig_pref is not provided
    # output: Create two top-level interfaces: ${intf_name}_clock and ${intf_name}_reset with
    #         associated wires ${sig_pref}_clk and ${sig_pref}_rst
    proc add_clock_reset_intf { intf_name {sig_pref ""} } {
        add_interface          ${intf_name}_clock   clock                    end
        add_interface          ${intf_name}_reset   reset                    end
        set_interface_property ${intf_name}_reset   associatedClock          ${intf_name}_clock
        set_interface_property ${intf_name}_reset   synchronousEdges         BOTH

        if { $sig_pref == "" } {
            add_interface_port     ${intf_name}_clock   clk                      clk      Input    1
            add_interface_port     ${intf_name}_reset   rst                      reset    Input    1
        } else {
            add_interface_port     ${intf_name}_clock   ${sig_pref}_clk          clk      Input    1
            add_interface_port     ${intf_name}_reset   ${sig_pref}_rst          reset    Input    1
        }
    }

    # --------------------------------------------------------------------------------------------------
    # -- Generic AXI Streaming
    # --------------------------------------------------------------------------------------------------

    # add_axi_st_port
    # Add an axi4 streaming port (master or slave) to the component
    # \param     interface_name,      name of the axi streaming interface
    # \param     direction            master or slave
    # \param     clock_intf,          clock/reset interfaces associated with the axi4 streaming interface
    # \param     num_data_bytes,      number of bytes in the data bus
    # \param     use_tready           whether the tready signal exists to allow a sink to apply backpressure
    # \param     use_tlast            whether the tlast signal exists to delimit packet boundaries
    # \param     use_tkeep            whether the tkeep signal exists to indicate null bytes (can be used to indicate empty)
    # \param     use_tstrb            whether the tstrb signal exists to indicate position bytes (can be used as byte enable)
    # \param     tid_bits,            number of bits for tid (1 to 8, 0 to disable the port)
    # \param     tdest_bits,          number of bits for tdest (1 to 4, 0 to disable the port)
    # \param     tuser_bits_per_byte, number of tuser bits *per byte of data* (1 to 8, 0 to disable the port)
    proc add_axi_st_port { interface_name direction clock_intf num_data_bytes use_tready use_tlast use_tkeep use_tstrb tid_bits tdest_bits tuser_bits_per_byte } {
        add_interface            $interface_name     axi4stream            $direction
        set_interface_property   $interface_name     associated_clock      ${clock_intf}_clock

        set data_dir             [expr {($direction == "master") ? "output" :  "input"}]
        set ready_dir            [expr {($direction == "master") ?  "input" : "output"}]

        add_interface_port           $interface_name     ${interface_name}_tdata   tdata       $data_dir     [expr {$num_data_bytes * 8}]
        add_interface_port           $interface_name     ${interface_name}_tvalid  tvalid      $data_dir     1
        if {$use_tready} {
            add_interface_port       $interface_name     ${interface_name}_tready   tready     $ready_dir    1
        }
        if {$use_tlast} {
            add_interface_port       $interface_name     ${interface_name}_tlast    tlast      $data_dir     1
        }
        if {$use_tkeep} {
            add_interface_port       $interface_name     ${interface_name}_tkeep    tkeep      $data_dir     $num_data_bytes
        }
        if {$use_tstrb} {
            add_interface_port       $interface_name     ${interface_name}_tstrb    tstrb      $data_dir     $num_data_bytes
        }
        if {$tid_bits} {
            add_interface_port       $interface_name     ${interface_name}_tid      tid        $data_dir     $tid_bits
        }
        if {$tdest_bits} {
            add_interface_port       $interface_name     ${interface_name}_tdest    tdest      $data_dir     $tdest_bits
        }
        if {$tuser_bits_per_byte} {
            add_interface_port       $interface_name     ${interface_name}_tuser    tuser      $data_dir     [expr {$num_data_bytes * $tuser_bits_per_byte}]
        }
    }

    # add_axi_st_input_port/add_axi_st_slave_port
    # Add an axi4 streaming input port (slave) to the component
    # \see add_axi_st_port
    proc add_axi_st_input_port { input_name clock_intf num_data_bytes use_tready use_tlast use_tkeep use_tstrb tid_bits tdest_bits tuser_bits_per_byte } {
        add_axi_st_slave_port  $input_name   $clock_intf  $num_data_bytes  $use_tready  $use_tlast  $use_tkeep  $use_tstrb  $tid_bits  $tdest_bits  $tuser_bits_per_byte
    }
    proc add_axi_st_slave_port { slave_name clock_intf num_data_bytes use_tready use_tlast use_tkeep use_tstrb tid_bits tdest_bits tuser_bits_per_byte } {
        add_axi_st_port  $slave_name  slave  $clock_intf  $num_data_bytes  $use_tready  $use_tlast  $use_tkeep  $use_tstrb  $tid_bits  $tdest_bits  $tuser_bits_per_byte
    }

    # add_axi_st_output_port/add_axi_st_master_port
    # Add an axi4 streaming output port (master) to the component
    # \see add_axi_st_port
    proc add_axi_st_output_port { output_name clock_intf num_data_bytes use_tready use_tlast use_tkeep use_tstrb tid_bits tdest_bits tuser_bits_per_byte } {
        add_axi_st_master_port $output_name  $clock_intf  $num_data_bytes  $use_tready  $use_tlast  $use_tkeep  $use_tstrb  $tid_bits  $tdest_bits  $tuser_bits_per_byte
    }
    proc add_axi_st_master_port { master_name clock_intf num_data_bytes use_tready use_tlast use_tkeep use_tstrb tid_bits tdest_bits tuser_bits_per_byte } {
        add_axi_st_port  $master_name  master  $clock_intf  $num_data_bytes  $use_tready  $use_tlast  $use_tkeep  $use_tstrb  $tid_bits  $tdest_bits  $tuser_bits_per_byte
    }
}
