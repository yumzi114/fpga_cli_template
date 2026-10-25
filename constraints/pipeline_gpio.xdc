# QMTECH Artix-7 XC7A100T FGG676

# 50MHz System Clock
set_property PACKAGE_PIN U22 [get_ports clk_50mhz]
set_property IOSTANDARD LVCMOS33 [get_ports clk_50mhz]

create_clock -name clk_50mhz -period 20.000 [get_ports clk_50mhz]

# GPIO Stage 1 - U2 Pin 5
set_property PACKAGE_PIN D26 [get_ports {gpio[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {gpio[0]}]

# GPIO Stage 2 - U2 Pin 6
set_property PACKAGE_PIN E26 [get_ports {gpio[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {gpio[1]}]

# GPIO Stage 3 - U2 Pin 7
set_property PACKAGE_PIN D25 [get_ports {gpio[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {gpio[2]}]

# GPIO Stage 4 - U2 Pin 8
set_property PACKAGE_PIN E25 [get_ports {gpio[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {gpio[3]}]