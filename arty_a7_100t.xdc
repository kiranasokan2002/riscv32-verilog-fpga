## ============================================================
## Arty A7-100T XDC — Official Digilent Pins
## Shows led_result on 8 LEDs + led_opcode on 4 RGB red
## ============================================================

## Clock 100MHz
set_property -dict { PACKAGE_PIN E3 IOSTANDARD LVCMOS33 } [get_ports { clk }];
create_clock -add -name sys_clk_pin -period 10.00 [get_ports { clk }];

## led_result[7:0] — 4 plain green LEDs + 4 RGB green channels
set_property -dict { PACKAGE_PIN H5  IOSTANDARD LVCMOS33 } [get_ports { led_result[0] }];
set_property -dict { PACKAGE_PIN J5  IOSTANDARD LVCMOS33 } [get_ports { led_result[1] }];
set_property -dict { PACKAGE_PIN T9  IOSTANDARD LVCMOS33 } [get_ports { led_result[2] }];
set_property -dict { PACKAGE_PIN T10 IOSTANDARD LVCMOS33 } [get_ports { led_result[3] }];
set_property -dict { PACKAGE_PIN F6  IOSTANDARD LVCMOS33 } [get_ports { led_result[4] }];
set_property -dict { PACKAGE_PIN J4  IOSTANDARD LVCMOS33 } [get_ports { led_result[5] }];
set_property -dict { PACKAGE_PIN J2  IOSTANDARD LVCMOS33 } [get_ports { led_result[6] }];
set_property -dict { PACKAGE_PIN H6  IOSTANDARD LVCMOS33 } [get_ports { led_result[7] }];

## led_opcode[3:0] — 4 RGB red channels
set_property -dict { PACKAGE_PIN G6 IOSTANDARD LVCMOS33 } [get_ports { led_opcode[0] }];
set_property -dict { PACKAGE_PIN G3 IOSTANDARD LVCMOS33 } [get_ports { led_opcode[1] }];
set_property -dict { PACKAGE_PIN J3 IOSTANDARD LVCMOS33 } [get_ports { led_opcode[2] }];
set_property -dict { PACKAGE_PIN K1 IOSTANDARD LVCMOS33 } [get_ports { led_opcode[3] }];

## Configuration
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]
