set_property PACKAGE_PIN U22 [get_ports clk_50mhz]
set_property IOSTANDARD LVCMOS33 [get_ports clk_50mhz]
create_clock -name clk_50mhz -period 20.000 [get_ports clk_50mhz]

set_property PACKAGE_PIN T23 [get_ports {led[0]}]
set_property PACKAGE_PIN R23 [get_ports {led[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[*]}]
# LEDs are asynchronous visual outputs with no external capture clock.
set_false_path -to [get_ports {led[*]}]
