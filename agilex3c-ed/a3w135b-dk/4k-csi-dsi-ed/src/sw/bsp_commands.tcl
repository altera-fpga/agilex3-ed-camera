set cpu_name "niosv_subsystem_cpu"
set uart_name "niosv_subsystem_cpu_jtag_uart"
set memory_name "niosv_subsystem_cpu_ram"

set_setting hal.enable_instruction_related_exceptions_api 1
set_setting hal.enable_c_plus_plus 1
set_setting hal.enable_clean_exit 0
set_setting hal.enable_exit 1
set_setting hal.enable_lightweight_device_driver_api 0
set_setting hal.enable_reduced_device_drivers 0
set_setting hal.enable_runtime_stack_checking 0
set_setting hal.linker.use_picolibc 0
set_setting hal.enable_sim_optimize 0
set_setting hal.linker.allow_code_at_reset 1
set_setting hal.linker.enable_alt_load 1
set_setting hal.linker.enable_alt_load_copy_exceptions 0
set_setting hal.linker.enable_alt_load_copy_rodata 0
set_setting hal.linker.enable_alt_load_copy_rwdata 1
set_setting hal.linker.enable_exception_stack 0
set_setting hal.make.cflags_warnings "-Wall -Werror=format"

set_setting hal.linker.exception_stack_memory_region_name $memory_name

set_setting hal.stderr $uart_name
set_setting hal.stdin $uart_name
set_setting hal.stdout $uart_name
set_setting hal.sys_clk_timer $cpu_name
set_setting hal.timestamp_timer $cpu_name
