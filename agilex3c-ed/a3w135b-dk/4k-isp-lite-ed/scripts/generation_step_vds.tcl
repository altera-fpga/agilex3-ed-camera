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
package require ::quartus::vds

# scripts directory
set scripts_dir [file dirname [info script]]

puts [pwd]

# Go to .qsf project
set prj_path [file normalize [file join $scripts_dir ..]]
cd $prj_path
puts "########################################################"
puts "# INFO : generation_step_vds -> .QSF location          #"
puts "########################################################"
post_message [pwd]

# Project handling
set need_to_close_project 0

if {[is_project_open]} {
    if {[string compare $quartus(project) "top"]} {
        error "Wrong project open"
    }
} else {
    if {[project_exists top]} {
        project_open -revision top top
    } else {
        error "Project does not exist"
    }
    set need_to_close_project 1
}

# Check if the VDS project has been built before.
# If so, do not rebuild it again.
set dirname_vds [file normalize [file join gen vds]]
if {[file isdirectory $dirname_vds]} {
    puts "Directory already exists, hence just compile the project in its current form"
} else {
    puts "Directory does not exist, hence we need to create the VDS project"
    # Go to RTL
    set vds_path [file normalize [file join src vds]]
    cd $vds_path
    puts "########################################################"
    puts "# INFO : generation_step_vds -> VDS location           #"
    puts "########################################################"
    post_message [pwd]

    # Generate the VDS project
    set quartus_sh [auto_execok quartus_sh]
    if {$quartus_sh eq ""} {
       error "quartus_sh not found"
    }
    exec -ignorestderr -- $quartus_sh -t top_subsystem.tcl

    # Return to scripts dir
    set scripts_path [file normalize [file join .. .. scripts]]
    cd $scripts_path
    post_message [pwd]

    # Close project
    if {$need_to_close_project} {
       project_close
    }

   puts "########################################################"
   puts "# INFO : SW APP build                                  #"
   puts "########################################################"
   source [file join swapp_gen.tcl]      

	set prj_path [file normalize [file join ..]]
	cd $prj_path
	post_message [pwd]

	set temp1 "set_global_assignment -name SDC_FILE src/sdc/board.sdc"
	set temp2 "set_global_assignment -name SDC_FILE src/sdc/jtag.sdc"
	set temp3 "set_global_assignment -name SDC_FILE src/sdc/mipi_csi_rx.sdc"
	set temp4 "set_global_assignment -name SDC_FILE src/sdc/dp_tx.sdc"

	set filename "top.qsf"
	set fileId [open $filename "a"]
	puts $fileId $temp1
	puts $fileId $temp2
	puts $fileId $temp3
	puts $fileId $temp4
	flush $fileId 
	close $fileId

	set scripts_path [file normalize [file join scripts]]
	cd $scripts_path
	
	puts "########################################################"
	puts "# INFO : VDS Generation is Done           			 #"
	puts "########################################################"
	post_message [pwd]   
   
}





