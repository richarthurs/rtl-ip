
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

# Starting a New Project

These are the steps to create a new Zynq-based project. 

1. Assume the following directory structure:

```
fpga
    rtl-ip
        ...
    project-dir

```
2. Inside project-dir, create a new Vivado project. Uncheck `Create new Directory` if you already have a directory to contain the project. 

3. In Vivado settings > IP, add the `rtl-ip` clone as an IP repository. 

![Add IP repository in Vivado](/doc/git-add-ip-repo.png)

4. In the sidebar `IP Integrator` tab, create a new block design for your project and add the Zynq PS IP to it. Don't configure the PS yet. 

![Create block design and add Zynq](/doc/create-block-design.png)

5. Double click the Zynq block to bring up its configuration. 

6. Apply a board preset by choosing _Presets > Apply Configuration_. Navigate to _rtl-ip/board-settings/Cora Z7-10/cora-preset.tcl_ and apply this preset.

7. Run block automation, you should see `DDR` and `FIXED_IO` ports in the diagram now. 

![Create block design and add Zynq](/doc/block-design-1.png)




