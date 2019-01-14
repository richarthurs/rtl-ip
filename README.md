
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

1. Clone this repo into `fpga/rtl-ip`. From now on, assume the following directory structure:

```
fpga/
    rtl-ip/
        ...
    axi-counter-demo/

```
2. Inside the `fpga` directory, create a new folder to contain the project. Open up Vivado and choose `Create new project`. Give it the same name as the new directory (axi-counter-demo). Since you already created a directory, uncheck `Create new Directory` in the project creation window. 

3. In Vivado settings > IP, add the `rtl-ip` clone as an IP repository. 

![Add IP repository in Vivado](/doc/git-add-ip-repo.png)

4. In the sidebar `IP Integrator` tab, create a new block design for your project and add the Zynq PS IP to it. Don't configure the PS yet. 

![Create block design and add Zynq](/doc/create-block-design.png)

5. Double click the Zynq block to bring up its configuration. 

6. Apply a board preset by choosing _Presets > Apply Configuration_. Navigate to _rtl-ip/board-settings/Cora Z7-10/cora-preset.tcl_ and apply this preset.

7. Run block automation, you should see `DDR` and `FIXED_IO` ports in the diagram now. 

![Block design with Zynq PS](/doc/block-design-1.png)

8. In the block design, click the `+` button and search for "counter." Add the `axi_counter_blink_v1.0` IP block to the design. 

9. Run Connection Automation. The block diagram should look something like this:

![Block design with AXI counter](/doc/block-design-2.png)

10. In the `Sources` tab under `Design Sources`, right click the only item that's there and choose `Create HDL Wrapper`

![Generate HDL Wrapper](/doc/gen-hdl-wrapper.png)

11. Save the project. 


12. In the block diagram, right click the `leds[5:0]` output port of the AXI counter block and choose `Make External`

![Make External](/doc/make-external.png)


13. Now it is time to elaborate and synthesize the design . Right click on the wrapper under Sources/Design sources and choose `Generate Output Products`. The default settings are fine. 

![Generate output products](/doc/gen-output-products.png)

14. Wait for the generation to complete.  

15. When the output products are generated, it's time to set up the LED outputs. In the sidebar, under RTL Analysis, click `Open Elaborated Design`. 

16. Click the `# IO Ports` button to open up the IO listing at the bottom of the screen. 

17. Use the search button and search for `led`. For any/all of the LED output bits, assign the `Package Pin` to an LED on the Cora board, which can be found in its [technical manual](https://reference.digilentinc.com/reference/programmable-logic/cora-z7/reference-manual). Set the `I/O Std` to `LVCMOS33`.  

![Setup the IO](/doc/cora-led-io.png)


18. File > Save the constraints file in the project. 

19. In the sidebar under `PROGRAM AND DEBUG`, select `Generate Bitstream`

20. Wait for bitstream generation to finish. When it finishes, check `View Reports` and click OK. 

21. File > Export > Export Hardware. Default settings are fine, as long as `Include Bitstream` is checked.

![Export hardware](/doc/export-hardware.png) 







