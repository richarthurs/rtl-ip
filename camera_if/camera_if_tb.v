`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Richard Arthurs
// 
// Create Date: 01/21/2019 07:11:13 PM
// Design Name: 
// Module Name: camera_if_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
/*
    - simple testbench to demonstrate the camera capture 
*/
//////////////////////////////////////////////////////////////////////////////////


module camera_if_tb(

);    
    reg clk;
    reg[9:0] data_fake;
    reg href;
    reg vsync;
    reg trigger;
    
    wire valid;
    wire[9:0] data_out; 
    reg vclk;
    
    // Camera Interface Instantiation
    camera_if#(
        30  // After this many pclks with href low, we will go idle again
    ) cam_inst(
        .clk(clk),
        .pclk(vclk),
        .data(data_fake),
        .href(href),
        .vsync(vsync),
        .valid(valid),
        .trigger(trigger),
        .data_out(data_out)     
    );
    
    // Generate the clocks
    // 50 MHz System Clock
    always begin
        clk <= 1'b1;
        #10;
        clk <= ~clk;
        #10;
    end
    
    // 32 MHz Pclk
    always begin
        vclk <= 1'b1;
        #15.625;
        vclk <= ~vclk;
        #15.625;
    end
    
    // Simulation Variables
    reg[3:0] img_count;
    reg[3:0] col_count;
    reg[3:0] row_count;
    reg[4:0] newline_href;
    reg[10:0] post_frame;
    
    // Main Testing Loop
    initial begin
        // Initialize
        vsync <= 1'b0;
        href <= 1'b0;
        data_fake <= 'b0;
        trigger <= 1'b0;
        
        // Slight delay
        repeat(3) @(posedge clk);
        
        // Loop through several image capture requests
        for(img_count = 0; img_count < 3; img_count = img_count + 1) begin
                    
            // Trigger
            trigger <= 1'b1;
            repeat(4) @(posedge vclk);
    
         
            // Image Loop
            // Vsync Pulse
            vsync <= 1'b0;
            repeat(3) @(posedge vclk);
            vsync <= 1'b1;
            // Pre-frame delay
            repeat(5) @(posedge vclk);
    
           // Send out a few lines
            for(row_count = 0; row_count < 3; row_count = row_count + 1) begin
                // Pixel Data - pump out a few pixels in the line
                for(col_count = 0; col_count < 5; col_count = col_count + 1) begin
                    href <= 1'b1;
                    data_fake <= data_fake + 1;
                    @(posedge vclk);
                end
            
                // Href low for a few clocks
                for(newline_href = 0; newline_href < 10; newline_href = newline_href + 1) begin
                    href <= 1'b0;
                    @(posedge vclk);
                end
            end
            
            // Post frame delay. The camera module parameter POST_FRAME_PCLK_THRESH sets the threshold for this. 50 for simulation, 500 IRL. 
            for(post_frame = 0; post_frame < 50; post_frame = post_frame + 1) begin
                @(posedge vclk);
            end
            
            // Deassert the trigger
            repeat(4) @(posedge clk);
            trigger <= 1'b0;
            repeat(5) @(posedge clk);
        
        end // Image loop
        repeat(5) @(posedge clk);

    end // testing loop
endmodule
