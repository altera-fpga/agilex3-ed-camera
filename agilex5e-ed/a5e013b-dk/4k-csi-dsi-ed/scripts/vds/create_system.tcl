package require ::quartus::project
load_package vds

set ::orchestrator_dir [file dirname [file normalize [info script]]]
set project_dir [file normalize "${::orchestrator_dir}/../.."]
cd $project_dir

if {![is_project_open]} {
    project_open top -revision top -force
}

namespace eval ::create_system {
    variable leaf_subsystems {
        clock_subsystem
        board_subsystem
        emif_subsystem
        niosv_subsystem
        mipi_rx_subsystem
        isp_lite_in_subsystem
        isp_lite_subsystem
        isp_lite_out_subsystem
        pre_dsi_subsystem
        mipi_dsi2_tx_subsystem
        dp_tx_subsystem
    }
    variable failed {}
}

foreach ::create_system::current $::create_system::leaf_subsystems {
    puts "=============================================================="
    puts "create_system.tcl: building $::create_system::current"
    puts "=============================================================="
    catch {vds::close_system $::create_system::current}
    if {[catch {source "${::orchestrator_dir}/subsystems/${::create_system::current}.tcl"} ::create_system::err]} {
        puts "ERROR building $::create_system::current: $::create_system::err"
        lappend ::create_system::failed $::create_system::current
    }
    catch {vds::close_system $::create_system::current}
    flush stdout
}

if {[llength $::create_system::failed] > 0} {
    puts "=============================================================="
    puts "create_system.tcl: FAILED subsystems: $::create_system::failed"
    puts "=============================================================="
    error "One or more leaf subsystems failed to build: $::create_system::failed"
}

puts "=============================================================="
puts "create_system.tcl: building top_subsystem"
puts "=============================================================="
catch {vds::close_system top_subsystem}
if {[catch {source "${::orchestrator_dir}/subsystems/top_subsystem.tcl"} ::create_system::top_err]} {
    puts "ERROR building top_subsystem: $::create_system::top_err"
    error "top_subsystem failed to build: $::create_system::top_err"
}
catch {vds::close_system top_subsystem}

puts "=============================================================="
puts "create_system.tcl: all subsystems built successfully."
puts "=============================================================="
