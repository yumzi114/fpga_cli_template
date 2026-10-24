set root [file normalize [file join [file dirname [info script]] ..]]
set out [file join $root build]
file mkdir $out
proc build {} {
    global root out
    # Never leave an older bitstream available after a failed rebuild.
    file delete -force [file join $out blink.bit]
    if {![string match "2025.2*" [version -short]]} {
        error "Vivado 2025.2 is required; found [version -short]"
    }
    create_project -force blink [file join $out project] -part xc7a100tfgg676-1
    set_property target_language Verilog [current_project]
    add_files [file join $root rtl blink.v]
    add_files -fileset constrs_1 [file join $root constraints blink.xdc]
    set_property top blink [current_fileset]
    create_ip -name clk_wiz -vendor xilinx.com -library ip -version 6.0 -module_name clk_wiz_0
    set_property -dict [list CONFIG.PRIM_IN_FREQ {50.000} \
        CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {200.000} \
        CONFIG.USE_RESET {true} CONFIG.RESET_TYPE {ACTIVE_HIGH} \
        CONFIG.USE_LOCKED {true}] [get_ips clk_wiz_0]
    generate_target all [get_ips clk_wiz_0]
    update_compile_order -fileset sources_1
    launch_runs synth_1 -jobs 4
    wait_on_run synth_1
    if {[get_property PROGRESS [get_runs synth_1]] ne "100%"} {
        error "Synthesis failed: [get_property STATUS [get_runs synth_1]]"
    }
    launch_runs impl_1 -to_step route_design -jobs 4
    wait_on_run impl_1
    if {[get_property PROGRESS [get_runs impl_1]] ne "100%"} {
        error "Implementation failed: [get_property STATUS [get_runs impl_1]]"
    }
    open_run impl_1
    report_timing_summary -delay_type min_max -check_timing_verbose -file [file join $out timing_summary.rpt]
    report_utilization -file [file join $out utilization.rpt]
    report_drc -file [file join $out drc.rpt]
    foreach delay {max min} {
        set paths [get_timing_paths -quiet -delay_type $delay -max_paths 1 -slack_lesser_than 0]
        if {[llength $paths]} { error "Timing violation ($delay); see build/timing_summary.rpt" }
    }
    set pulse [report_pulse_width -return_string]
    set f [open [file join $out pulse_width.rpt] w]
    puts $f $pulse
    close $f
    # Pulse-width table rows end with Slack(ns), Location, Pin.
    foreach line [split $pulse "\n"] {
        set fields [regexp -all -inline {\S+} $line]
        set slack [lindex $fields end-2]
        if {[string is double -strict $slack] && $slack < 0} {
            error "Pulse-width timing violation: $line"
        }
    }
    write_bitstream -force [file join $out blink.bit]
    close_project
}
if {[catch {build} message options]} {
    puts stderr "ERROR: $message"
    puts stderr [dict get $options -errorinfo]
    exit 1
}
exit 0
