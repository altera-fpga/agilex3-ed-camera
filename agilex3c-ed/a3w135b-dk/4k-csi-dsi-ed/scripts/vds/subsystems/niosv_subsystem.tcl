package require ::quartus::project

set script_dir [file dirname [file normalize [info script]]]
set project_dir [file normalize "${script_dir}/../../.."]

if {![is_project_open]} {
  cd $project_dir
  project_open top -revision top
}

# Force "IP Generation" to regenerate files on system change
file delete -force "${project_dir}/gen/vds/niosv_subsystem"

source "${project_dir}/scripts/vds/lib/vds_helpers.tcl"

# ---------------------------------------------------------------------------
# Subsystem parameters
# ---------------------------------------------------------------------------

set MEMORY_SIZE 0x40000
set TIMER_PERIOD 1
set TIMER_UNITS USEC
set JTAG_UART_EN 1
set CPU_TIMER_EN 1
set UART_IRQ_PRIORITY 0
set TIMER_IRQ_PRIORITY 1
set CPU_VARIANT "m"
set INIT_FILE "../../../../../../../src/sw/mem_init/niosv_subsystem_cpu_ram.hex"

set IRQ_BRIDGE_WIDTH 5
set IRQ_BRIDGE_PRIORITIES {2 3 4 5 6}

puts "niosv_subsystem: creating system"
set params_str "niosv_subsystem: subsystem parameters:"
append params_str " CPU_VARIANT=V/${CPU_VARIANT},"
append params_str " MEMORY_SIZE=$MEMORY_SIZE, IRQ_BRIDGE_WIDTH=$IRQ_BRIDGE_WIDTH"

puts "$params_str"
::vh::new_system niosv_subsystem

# ---------------------------------------------------------------------------
# Instances
# ---------------------------------------------------------------------------

puts "niosv_subsystem: creating cells"
::vh::create_cell cpu_clk_bridge altera_clock_bridge {
    EXPLICIT_CLOCK_RATE 100000000.0
    NUM_CLOCK_OUTPUTS   1
}

::vh::create_cell cpu_rst_bridge altera_reset_bridge {
    ACTIVE_LOW_RESET  0
    SYNCHRONOUS_EDGES deassert
    NUM_RESET_OUTPUTS 1
    USE_RESET_REQUEST 0
    SYNC_RESET        0
}

::vh::create_cell cpu_mm_bridge altera_avalon_mm_bridge {
    SYNC_RESET             0
    DATA_WIDTH             32
    SYMBOL_WIDTH           8
    USE_AUTO_ADDRESS_WIDTH 1
    ADDRESS_UNITS          SYMBOLS
    MAX_BURST_SIZE         1
    LINEWRAPBURSTS         0
    MAX_PENDING_RESPONSES  4
    PIPELINE_COMMAND       1
    PIPELINE_RESPONSE      1
    USE_RESPONSE           0
}

if {$CPU_VARIANT == "m"} {
  ::vh::create_cell cpu intel_niosv_m {
    enableDebug 1
    numGpr      32
    resetOffset 0
    resetSlave  cpu_ram.axi_s1
  }
} else {
  send_message error "Unsupported Nios V variant V/${CPU_VARIANT}"
  error "Unsupported Nios V variant V/${CPU_VARIANT}"
}

::vh::create_cell cpu_ram intel_onchip_memory [subst {
  AXI_interface 1
  interfaceType 1
  idWidth 2
  memorySize $MEMORY_SIZE
  initMemContent 1
  useNonDefaultInitFile 1
  initializationFileName $INIT_FILE
  dataWidth 32
}]

if {$JTAG_UART_EN} {
  ::vh::create_cell cpu_jtag_uart altera_avalon_jtag_uart {
    writeBufferDepth           1024
    writeIRQThreshold          8
    useRegistersForWriteBuffer 0
    readBufferDepth            1024
    readIRQThreshold           8
    useRegistersForReadBuffer  0
  }
}

if {$CPU_TIMER_EN} {
  ::vh::create_cell cpu_timer altera_avalon_timer [subst {
    alwaysRun false
    fixedPeriod false
    resetOutput false
    snapshot true
    counterSize 32
    period $TIMER_PERIOD
    periodUnits $TIMER_UNITS
  }]
}

if {$IRQ_BRIDGE_WIDTH >= 1} {
  ::vh::create_cell irq_bridge altera_irq_bridge [subst {
    IRQ_WIDTH $IRQ_BRIDGE_WIDTH
    IRQ_N {Active High}
    SYNC_RESET 0
  }]
}

# -----------------------------------------------------------------------------
# Wiring
# -----------------------------------------------------------------------------

puts "niosv_subsystem: wiring up cells"

# Clocks + resets
::vh::connect_pin {cpu_clk_bridge out_clk} {cpu_rst_bridge clk}
::vh::connect_pin {cpu_clk_bridge out_clk} {cpu_mm_bridge clk}
::vh::connect_pin {cpu_clk_bridge out_clk} {cpu clk}
::vh::connect_pin {cpu_clk_bridge out_clk} {cpu_ram clk1}
if {$JTAG_UART_EN} {
  ::vh::connect_pin {cpu_clk_bridge out_clk} {cpu_jtag_uart clk}
}
if {$CPU_TIMER_EN} {
  ::vh::connect_pin {cpu_clk_bridge out_clk} {cpu_timer clk}
}

::vh::connect_pin {cpu_rst_bridge out_reset} {cpu_mm_bridge reset}
::vh::connect_pin {cpu_rst_bridge out_reset} {cpu reset}
::vh::connect_pin {cpu_rst_bridge out_reset} {cpu_ram reset1}

if {$JTAG_UART_EN} {
  ::vh::connect_pin {cpu_rst_bridge out_reset} {cpu_jtag_uart reset}
}

if {$CPU_TIMER_EN} {
  ::vh::connect_pin {cpu_rst_bridge out_reset} {cpu_timer reset}
}

if {$IRQ_BRIDGE_WIDTH >= 1} {
  ::vh::connect_pin {cpu_clk_bridge out_clk} {irq_bridge clk}
  ::vh::connect_pin {cpu_rst_bridge out_reset} {irq_bridge clk_reset}
}

# Main data manager interconnect_pin
::vh::connect_if {cpu data_manager} {cpu_mm_bridge s0}
::vh::connect_if {cpu data_manager} {cpu dm_agent}
::vh::connect_if {cpu data_manager} {cpu timer_sw_agent}
::vh::connect_if {cpu data_manager} {cpu_ram axi_s1}

if {$JTAG_UART_EN} {
  ::vh::connect_if {cpu data_manager} {cpu_jtag_uart avalon_jtag_slave}
}
if {$CPU_TIMER_EN} {
  ::vh::connect_if {cpu data_manager} {cpu_timer s1}
}

# Instruction manager
::vh::connect_if {cpu instruction_manager} {cpu dm_agent}
::vh::connect_if {cpu instruction_manager} {cpu_ram axi_s1}

# Interrupts
if {$JTAG_UART_EN && $UART_IRQ_PRIORITY != "X"} {
  ::vh::connect_if {cpu platform_irq_rx} {cpu_jtag_uart irq}
  ::vh::set_interrupt_irq {cpu platform_irq_rx} {cpu_jtag_uart irq} $UART_IRQ_PRIORITY
}
if {$CPU_TIMER_EN && $TIMER_IRQ_PRIORITY != "X"} {
  ::vh::connect_if {cpu platform_irq_rx} {cpu_timer irq}
  ::vh::set_interrupt_irq {cpu platform_irq_rx} {cpu_timer irq} $TIMER_IRQ_PRIORITY
}

if {$IRQ_BRIDGE_WIDTH >= 1} {
  for {set i 0} {$i < $IRQ_BRIDGE_WIDTH} {incr i} {
    set priority [lindex $IRQ_BRIDGE_PRIORITIES $i]
    ::vh::connect_if {cpu platform_irq_rx} [list irq_bridge sender${i}_irq]
    ::vh::set_interrupt_irq {cpu platform_irq_rx} [list irq_bridge sender${i}_irq] $priority
  }
}

# -----------------------------------------------------------------------------
# Assign base addresses
# -----------------------------------------------------------------------------

puts "niosv_subsystem: assigning base addresses"

# Lock down addresses for CPU subsystem; keep MM bridge at end to allow
# for width expansion

::vh::assign_base_address {cpu data_manager} {cpu_ram axi_s1} 0x00000000
::vh::assign_base_address {cpu data_manager} {cpu dm_agent} 0x00400000
::vh::assign_base_address {cpu data_manager} {cpu timer_sw_agent} 0x00410000

if {$CPU_TIMER_EN} {
  ::vh::assign_base_address {cpu data_manager} {cpu_timer s1} 0x00410040
}
if {$JTAG_UART_EN} {
  ::vh::assign_base_address {cpu data_manager} {cpu_jtag_uart avalon_jtag_slave} 0x00410060
}
::vh::assign_base_address {cpu data_manager} {cpu_mm_bridge s0} 0x00420000

::vh::assign_base_address {cpu instruction_manager} {cpu_ram axi_s1} 0x00000000
::vh::assign_base_address {cpu instruction_manager} {cpu dm_agent} 0x00400000

# CPU configured to reset from first address of RAM, i.e. 0,
# do not let auto assign overwrite this.
::vh::lock_base_address {cpu_ram axi_s1}
::vh::lock_base_address {cpu dm_agent}
::vh::lock_base_address {cpu timer_sw_agent}
::vh::lock_base_address {cpu_timer s1}
::vh::lock_base_address {cpu_jtag_uart avalon_jtag_slave}
::vh::lock_base_address {cpu_mm_bridge s0}

::vh::sync

# -----------------------------------------------------------------------------
# Exports
# -----------------------------------------------------------------------------

puts "niosv_subsystem: exporting pins/interfaces"

::vh::export_pin {cpu_clk_bridge in_clk}   i_clk_cpu
::vh::export_pin {cpu_rst_bridge in_reset} i_reset_cpu

::vh::export_if {cpu_mm_bridge m0} o_cpu_mm_master

if {$IRQ_BRIDGE_WIDTH >= 1} {
  ::vh::export_if {irq_bridge receiver_irq} ia_cpu_irq_receiver
} else {
  ::vh::export_if {cpu platform_irq_rx} ia_cpu_irq_receiver
}

::vh::sync

puts "niosv_subsystem: build complete"
