#  ###############################################################################
#   
#  ALTERA CONFIDENTIAL
#  
#  Copyright 2020-2021 Altera Corporation.
#  
#  This software and the related documents are Altera copyrighted materials, and
#  your use of them is governed by the express license under which they were
#  provided to you ("License"). Unless the License provides otherwise, you may
#  not use, modify, copy, publish, distribute, disclose or transmit this software
#  or the related documents without Altera's prior written permission.
#  
#  This software and the related documents are provided as is, with no express or
#  implied warranties, other than those that are expressly stated in the License.
#  
#  ###############################################################################
package require ::quartus::project
package require ::quartus::flow

# Get scripts directory
set scripts_dir [file dirname [info script]]

puts [pwd]

# Go to quartus directory
set prj_path [file normalize [file join $scripts_dir ..]]
cd $prj_path
post_message [pwd]

# Project handling
set need_to_close_project 0

if {[is_project_open]} {
    if {[string compare $quartus(project) "top"]} {
        error "Project top is not open"
    }
} else {
    if {[project_exists top]} {
        project_open -revision top top
    } else {
        error "Project top does not exist"
    }
    set need_to_close_project 1
}

# Go to scripts directory
set scripts_path [file normalize [file join scripts]]
cd $scripts_path
post_message [pwd]

post_message "##############################################"
post_message "# INFO : Nios project generation             #"
post_message "##############################################"

# Cross-platform quartus_py
set quartus_py [auto_execok quartus_py]
if {$quartus_py eq ""} {
    error "quartus_py not found in PATH"
}

exec -ignorestderr -- $quartus_py build_niosv_sw.py -d -b

# Go to root
set root_path [file normalize [file join ..]]
cd $root_path
post_message [pwd]

post_message "##############################################"
post_message "# INFO : Integrating Nios .elf(.hex) in .sof #"
post_message "##############################################"
set src_hex [file join src sw app build mem_init niosv_subsystem_cpu_ram_cpu_ram.hex]
set dst_hex [file join gen vds niosv_subsystem ip niosv_subsystem_cpu_ram intel_onchip_memory_200 synth niosv_subsystem_cpu_ram_cpu_ram.hex]

file copy -force -- $src_hex $dst_hex

if {[catch {execute_module -tool cdb -args "-update_mif"} result]} {
    error "Error in cdb: $result"
}

if {[catch {execute_module -tool asm} result]} {
    error "Error in asm: $result"
}

# Close project if needed
if {$need_to_close_project} {
    project_close
}

# Return to scripts dir
set scripts_path [file normalize [file join scripts]]
cd $scripts_path
post_message [pwd]







