`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/10/2019 04:07:14 PM
// Design Name: 
// Module Name: tb
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
//////////////////////////////////////////////////////////////////////////////////



module tb();
    
    parameter CLK_PERIOD_NS = 2'd2;
    reg clk;
    reg rst_n;
    
    wire [9:0] image;
    wire href;
    wire vsync;

    // Instantiate the mock camera   
    camera_mock#(
        // Set up the image size: 12x12
        .ROWS(12'd12),
        .COLS(12'd12),
        
        // Shorten the delays for simulation
       .VSYNC_PULSE_CLKS(15'd1),
        .PRE_FRAME_CLKS(15'd1),
        .NEW_ROW_CLKS(15'd1),
        .POST_FRAME_CLKS(15'd1)   
    ) cam_inst(
        .clk(clk),
        .rst_n(rst_n),
        .image(image),
        .href(href),
        .vsync(vsync)
    );
    
    // Generate clock signal
    always begin
        clk <= 1'b1;
        #1;
        clk <= ~clk;
        #1;
    end
    
    // Simulation Variables
    reg[2:0] picture_num;
    reg [7:0] row_num;
    reg [7:0] col_num;
    
    // Main testing loop
    initial begin
        // Reset the DUT
        rst_n <= 1'b0;  
        @(clk);
        @(clk);
        rst_n <= 1'b1;
       
       @(vsync) // Wait for vsync to assert
       @(vsync) // Wait for vsync to deassert
       
       // Initialize variables
       picture_num <= 0;
       row_num <= 0;
       col_num <= 0;
       
       @(posedge href);
       @(posedge clk);
       
       for(col_num = 0; col_num < 12; col_num = col_num + 1) begin
           for(row_num = 0; row_num < 12; row_num = row_num + 1) begin
             if(href == 1'b1) $display("Href high");
             $display("Row: %d", image);
             @(posedge clk);
            end
            // 3x z
            for(row_num = 0; row_num < 3; row_num = row_num + 1) begin
                if(image === 10'bZZZZZZZZ) $display("Correct Z");
                else $display("Incorrect Z");
                @(posedge clk);
            end
       end
       
       
       $display("Row: %d", image);
       @(posedge clk);
       $display("Row: %d", image);
       @(posedge clk);
       $display("Row: %d", image);
       @(posedge clk);
       $display("Row: %d", image);
       @(posedge clk);
       $display("Row: %d", image);
            @(posedge clk);
         $display("Row: %d", image);
         @(posedge clk);
         $display("Row: %d", image);
         @(posedge clk);
         $display("Row: %d", image);
         @(posedge clk);
         $display("Row: %d", image);
       

//       for(picture_num = 0; picture_num < 2; picture_num = picture_num + 1) begin
//        @(href);
//            for(col_num = 0; col_num < 12; col_num = col_num + 1) begin
//                for(row_num = 0; row_num < 12; row_num = row_num + 1) begin
//                    if(href == 1'b1) $display("Href high");
//                    $display("Row: %d", image);
////                    if (image == row_num) $display("Matching image: %d", image);
//                    @(posedge clk);     
//                end
//                @(href);
//                $display("COLUMN INCREMENT");
//            end
//       end
       
        // NOTE: set the Vivado simulation timeout setting by right clicking SIMULATION > Simulation Settings > Simulation > xsim.simulate.runtime
        #1000000000;   // irrelevant with a simulator-controlled timeout
    
    end
endmodule
