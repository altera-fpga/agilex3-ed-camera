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




# ------------------------------------------------------------------------------------
#   Function to generate the final content based on specified terp file
# ------------------------------------------------------------------------------------
proc get_terp_content { filepath param_value } {
    # Open and read terp file
    set terp_path     $filepath
    set terp_fd       [open $terp_path]
    set terp_contents [read $terp_fd]
    close $terp_fd

    for {set i 0} {$i < [llength $param_value]} {incr i} {
        set terp_params(param$i)  [lindex $param_value $i]
    }

    # Expand terp w/ parameters into design file
    set top_file_contents [altera_terp $terp_contents terp_params]
    return $top_file_contents
    # set filename [file tail $filepath]
    # set output_name [regsub {.terp} $filename ""]
    # add_fileset_file "$dest_dir/$output_name"  SYSTEM_VERILOG  TEXT    $top_file_contents
}

# ------------------------------------------------------------------------------------
#   Function to propagate file to user specified dir
# ------------------------------------------------------------------------------------
proc add_file_to_user { full_path dest_dir } {
    set filename [file tail $full_path]

    if {[regexp {.*\.vh[do]} $full_path] } {
        set file_type "VHDL"
    } elseif {[regexp {.*\.v} $full_path] } {
        set file_type "VERILOG"
    } elseif {[regexp {.*\.hex} $full_path]} {
        set file_type "HEX"
    } elseif {[regexp {.*\.sdc} $full_path]} {
        set file_type "SDC"
    } elseif {[regexp {.*\.sv} $full_path]} {
        set file_type "SYSTEM_VERILOG"
    } else {
        set file_type "OTHER"
    }
    if { ![regexp {.*\.terp$} $filename] } {
        add_fileset_file [file join $dest_dir $filename] $file_type PATH $full_path
    }
}

# ------------------------------------------------------------------------------------
#   Function to glob through all the subdirectories and add files to dest dir
# ------------------------------------------------------------------------------------
proc glob_recursive {src_dir dest_dir} {
    set contents [glob -nocomplain -directory $src_dir *]

    foreach item $contents {
        set filename [file tail $item]
        # go into subdirectories
        if { [file isdirectory $item] } {
            glob_recursive $item [file join $dest_dir $filename]
        } elseif { [file isfile $item] } {
            add_file_to_user $item $dest_dir
        }
    }
}

# ------------------------------------------------------------------------------------
#   Function to propagate files to user specified dir
# ------------------------------------------------------------------------------------
proc add_files_to_user {src_dir_list dest_dir_name} {
    foreach dir $src_dir_list {
        set file_lst [glob -nocomplain -directory $dir *]

        foreach file ${file_lst} {
            if {[file isfile $file]} {
                set file_string [split $file /]
                set file_name [lindex $file_string end]

                if {[regexp {.sv$} $file_name]} {
                    add_fileset_file "$dest_dir_name/$file_name" SYSTEM_VERILOG PATH ${file}
                } elseif {[regexp {.v$} $file_name]} {
                    add_fileset_file "$dest_dir_name/$file_name" VERILOG PATH ${file}
                } elseif {[regexp {.ocp$} $file_name]} {
                    add_fileset_file "$dest_dir_name/$file_name" OTHER PATH ${file}
                } elseif {[regexp {.sdc$} $file_name]} {
                    add_fileset_file "$dest_dir_name/$file_name" SDC_ENTITY PATH ${file}
                }
            }
        }
    }
}

proc add_filelist_to_user {src_file_list dest_dir_name} {
    foreach file ${src_file_list} {
        if {[file isfile $file]} {
            set file_string [split $file /]
            set file_name [lindex $file_string end]

            if {[regexp {.sv$} $file_name]} {
                add_fileset_file "$dest_dir_name/$file_name" SYSTEM_VERILOG PATH ${file}
            } elseif {[regexp {.v$} $file_name]} {
                add_fileset_file "$dest_dir_name/$file_name" VERILOG PATH ${file}
            } elseif {[regexp {.ocp$} $file_name]} {
                add_fileset_file "$dest_dir_name/$file_name" OTHER PATH ${file}
            } elseif {[regexp {.sdc$} $file_name]} {
                add_fileset_file "$dest_dir_name/$file_name" SDC_ENTITY PATH ${file}
            }
        }
    }
}
