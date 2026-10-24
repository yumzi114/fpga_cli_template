set root [file normalize [file join [file dirname [info script]] ..]]
proc program {} {
    global root
    set bit [file join $root build blink.bit]
    if {![file exists $bit]} { error "Missing $bit; run make build first" }
    open_hw_manager
    connect_hw_server
    # HS3 appears under Digilent. Use JTAG_TARGET to select a specific serial.
    set pattern "*/xilinx_tcf/Digilent/*"
    if {[info exists ::env(JTAG_TARGET)] && $::env(JTAG_TARGET) ne ""} {
        set pattern $::env(JTAG_TARGET)
    }
    set targets [get_hw_targets -quiet $pattern]
    if {[llength $targets] != 1} {
        error "Expected one Digilent target, found [llength $targets]: $targets. Set JTAG_TARGET to an exact target path."
    }
    current_hw_target [lindex $targets 0]
    set_property PARAM.FREQUENCY 10000000 [current_hw_target]
    open_hw_target
    set devices [get_hw_devices -quiet -filter {PART =~ xc7a100t*}]
    if {[llength $devices] != 1} { error "Expected one XC7A100T; found: $devices" }
    set device [lindex $devices 0]
    current_hw_device $device
    refresh_hw_device $device
    set_property PROGRAM.FILE $bit $device
    program_hw_devices $device
    close_hw_target
    disconnect_hw_server
    close_hw_manager
}
if {[catch {program} message options]} {
    puts stderr "ERROR: $message"
    puts stderr [dict get $options -errorinfo]
    exit 1
}
exit 0
