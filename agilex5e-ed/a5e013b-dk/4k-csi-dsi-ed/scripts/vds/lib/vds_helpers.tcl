###############################################################################
# vds_helpers.tcl
#
# Small library to wrap vds::* API calls, and encapsulates VDS quirks such as
# connecting/exporting bus interfaces vs pins, and weird hierarchy syntax
#
# ----------------------------------------------------------------------------
#
# vh::new_system        - create/recreate the system
# vh::create_cell       - create IP instance
# vh::connect           - wire every clock/reset/plain pin
# vh::connect_if        - connect bus interfaces
# vh::sync              - sync_system_info + validate + save
#
# vh::assign_base_address - wire bus interfaces and
#                           pin explicit addresses
# vh::export_pin / vh::export_if - expose top-level boundary ports
# vh::sync               - final validate + save
###############################################################################

package require ::quartus::project

if {![info exists ::vds_helpers_loaded]} {
  load_package vds
  set ::vds_helpers_loaded 1
}

namespace eval ::vh {
  variable system_name ""
}

# Creates a new system, deleting any leftover artifacts first
proc ::vh::new_system {name} {
  variable system_name
  set system_name $name

  set project_dir [get_project_directory]
  foreach d [list "${project_dir}/src/vds/${name}" "${project_dir}/gen/vds/${name}"] {
    if {[file exists $d]} {
      file delete -force $d
    }
  }

  vds::create_system -force $name
  return $name
}

# Sync system info + validate + save
proc ::vh::sync {} {
  vds::sync_system_info
  vds::validate_system
  vds::save_system
  vds::sync_system_info
}

proc ::vh::generate {args} {
  vds::generate_system -simulation verilog {*}$args
  vds::generate_system -synthesis verilog {*}$args
}

# ---------------------------------------------------------------------------
# Instance naming
# ---------------------------------------------------------------------------

# Build a pin reference "<inst>|<port>" from a (possibly short) instance name
# and a port name.
proc ::vh::pin {local_name port} {
  return "${local_name}|${port}"
}

# ---------------------------------------------------------------------------
# Cell creation / parameters
# ---------------------------------------------------------------------------

# Create a cell - optional parameters list (without parameters: prefix)
# and optional properties list (fully qualified with prop_type:name value).
#
# Beware that Tcl does not permit variable substitution when using curly braces
# list syntax, e.g. {$var1 $var2} will not work; Use [list $var1 $var2] or
# [subst {$var1 $var2}] instead
#
#   vh::cell input_clk_bridge altera_clock_bridge {
#       EXPLICIT_CLOCK_RATE 100000000
#       NUM_CLOCK_OUTPUTS   1
#   }
#
proc ::vh::create_cell {local_name vlnv {params {}} {other_props {}}} {
  set full_name $local_name
  set props {}

  if {[llength $params] > 0} {
    foreach {key value} $params {
      lappend props "parameters:${key}" $value
    }
  }
  if {[llength $other_props] > 0} {
    lappend props {*}$other_props
  }

  if {[llength $props] > 0} {
    vds::create_cell -vlnv $vlnv $full_name -properties $props
  } else {
    vds::create_cell -vlnv $vlnv $full_name
  }

  return $full_name
}

# Set (or update) a single parameter on an already-created instance.
proc ::vh::set_param {local_name key value} {
  vds::set_property "parameters:${key}" $value $local_name
}

proc ::vh::set_params {local_name kv_pairs} {
  set props {}
  foreach {key value} $kv_pairs {
    lappend props "parameters:${key}" $value
  }
  vds::set_properties $props $local_name
}

# Connect two plain pins, given as {local_inst port} pairs.
#   vh::connect_pin {input_clk_bridge out_clk} {input_rst_ctrl clk}
proc ::vh::connect_pin {src dest} {
  set src_pin  [::vh::pin {*}$src]
  set dest_pin [::vh::pin {*}$dest]
  vds::connect_net -src $src_pin -dest $dest_pin
}

# Export a plain pin {local_inst port} as a top-level port.
#   vh::export_pin {input_clk_bridge in_clk} i_ref_clk
proc ::vh::export_pin {src top_name} {
  set src_pin [::vh::pin {*}$src]
  vds::export_pin $src_pin $top_name
}


# Connect two bus interfaces, given as {local_inst if_name} pairs.
#   vh::connect_if {jtag_0 master} {pio_0 s1}
proc ::vh::connect_if {src dest} {
  set src_if [::vh::pin {*}$src]
  set dest_if [::vh::pin {*}$dest]
  vds::connect_interface_net -src $src_if -dest $dest_if
}

# Export a bus interface {local_inst if_name} as a top-level interface port.
proc ::vh::export_if {src top_name} {
  set src_if [::vh::pin {*}$src]
  vds::export_interface_pins $src_if $top_name
}

# Pin an explicit base address on a manager/agent connection, given as
# {local_inst if_name} pairs, mirroring MDT's deliberate (non-auto-assigned)
# address map, since the Nios V software has hardcoded addresses.
#   vh::assign_base_address {host_0 data_master} {agent_0 s1} 0x00001000
proc ::vh::assign_base_address {manager agent addr} {
  set conn "[lindex $manager 0].[lindex $manager 1]/[lindex $agent 0].[lindex $agent 1]"
  vds::assign_base_address -connection $conn $addr
}

proc ::vh::lock_base_address {agent} {
  set temp "[lindex $agent 0]|[lindex $agent 1]"
  vds::lock_base_address -interface $temp
}

proc ::vh::system_cell {name} {
  vds::create_cell -type system -ref $name $name
  return $name
}

proc ::vh::set_interrupt_irq {manager agent irq} {
  set conn "[lindex $manager 0].[lindex $manager 1]/[lindex $agent 0].[lindex $agent 1]"
  vds::set_interrupt_irq -connection $conn $irq
}

proc ::vh::set_domain_property {domain_if prop value} {
  set domain "[lindex $domain_if 0].[lindex $domain_if 1]"
  vds::set_domain_property $prop $value $domain
}

# Returns 1 if {inst port} is a plain pin, 0 if it is a bus-typed
# interface_pin. Errors out if neither matches (typo / bad name).
proc ::vh::is_plain_pin {ref} {
  set p [::vh::pin {*}$ref]
  if {[llength [vds::get_pins $p]] > 0} {
    return 1
  }
  if {[llength [vds::get_interface_pins $p]] > 0} {
    return 0
  }
}

proc ::vh::auto_connect {src dest} {
  if {[::vh::is_plain_pin $src]} {
    ::vh::connect_pin $src $dest
  } else {
    ::vh::connect_if $src $dest
  }
}

proc ::vh::auto_export {src top_name} {
  if {[::vh::is_plain_pin $src]} {
    ::vh::export_pin $src $top_name
  } else {
    ::vh::export_if $src $top_name
  }
}
