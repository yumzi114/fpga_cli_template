set root [file normalize [file join [file dirname [info script]] ..]]
set out [file join $root build]

file mkdir $out

create_project -force pipeline_gpio \
    [file join $out project_gpio] \
    -part xc7a100tfgg676-1

set_property target_language Verilog [current_project]

# RTL
add_files [file join $root rtl pipeline_gpio.sv]

# XDC
add_files -fileset constrs_1 \
    [file join $root constraints pipeline_gpio.xdc]

set_property top pipeline_gpio [current_fileset]

update_compile_order -fileset sources_1

# Synthesis
launch_runs synth_1 -jobs 4
wait_on_run synth_1

if {[get_property PROGRESS [get_runs synth_1]] ne "100%"} {
    error "GPIO synthesis failed"
}

# Implementation + Bitstream
launch_runs impl_1 -to_step write_bitstream -jobs 4
wait_on_run impl_1

if {[get_property PROGRESS [get_runs impl_1]] ne "100%"} {
    error "GPIO implementation failed"
}

# Copy generated bitstream
set bitfile [file join $out project_gpio \
    pipeline_gpio.runs impl_1 pipeline_gpio.bit]

if {![file exists $bitfile]} {
    error "GPIO bitstream not found: $bitfile"
}

file copy -force $bitfile [file join $out pipeline_gpio.bit]

puts "GPIO bitstream generated successfully"

close_project