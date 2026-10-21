set_false_path -from [get_ports {rst_pb_n}]

set user_pb_col [get_ports user_pb_col -nowarn]
if {[get_collection_size $user_pb_col] > 0} {
  set_false_path -from $user_pb_col
}

set user_led_col [get_ports user_led -nowarn]
if {[get_collection_size $user_led_col] > 0} {
  set_false_path -to $user_led_col
}
