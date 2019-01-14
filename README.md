
# Board Settings

This directory contains board setup files for some development boards, generally lifted from the manufacturer.

# Cora Z7-10

- **cora-preset.tcl:** a Zynq-preset file to configure the PS when building projects upon the Cora Z7-10. 
- **board.xml:** board settings file used in new Vivado project creation
- **preset.xml:** when is this used?

# IP Cores List

**axi_counter_blink_1.0**

This is a basic example of AXI-enabled IP. It features a counter that can be read over AXI and several outputs for the counter MSBs intended to be hooked up to LEDs on a dev board. It also exposes a read-only register to grab counter values from a FIFO, and some control registers to set fill-ups of the FIFO. See comments in _hdl/axi_counter_blink_v1.0.v_. 

**camera_mock**

This core is a simple mock of a parallel CMOS camera interface. It features configurable settings for image size and other parameters. Given a pixel clock `clk`, it will output the current row (x pixel) on the data interface, and assert `vsync` and `href` identically to a parallel camera such as the OV2640. 

Includes a simple testbench to allow manual verification of correct IP functionality by waveform inspection. 

**camcontrol**

WIP
