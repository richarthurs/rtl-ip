`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Richard Arthurs
// 
// Create Date: 01/21/2019 05:28:22 PM
// Design Name: 
// Module Name: camera_if
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


module camera_if#(
    POST_FRAME_PCLK_THRESH = 500
    )(
    input clk,
    input pclk,
    input [9:0] data,
    input vsync,
    input href,
    input trigger,
    output [9:0] data_out,
    output valid
    );
    
    
    // Capture State Machine
    // idle
        // if trigger is 1 - wait for vsync
    // wait for vsync
        // wait for vsync pulse to go high. Then go to wait for href
   // pre frame
       // wait for href to go high, then go to line
       // register the first pixel 
   // Wait for href
       // when href goes high, capture the first pixel and go to ROW
       // count the number of clocks, if it is more than 322, go to idle
  // line
      // every clock, register the new image data, if href goes low, go to wait for href
      
    reg[2:0] capture_state;
    parameter IDLE = 3'b000;
    parameter WAIT_VSYNC = 3'b001;
    parameter PRE_FRAME = 3'b010;
    parameter WAIT_HREF = 3'b011;
    parameter LINE = 3'b100;
    
    // Capture Variables
    reg trigger_safe;   // Synchronized to pclk domain
    reg trigger_metastable; // Potentially metastable
    reg vsync_d;
    reg href_d;
    reg[8:0] href_clk_count;    // Must be able to count to 322
    
    // Data synchronization
    // Data comes in on pclk domain, 32 MHz roughly. It needs to be synchronized to clk (50 MHz)
    // There will be data outputs and valid outputs. We set the valid output when the pixel data is something useful. 
    reg[9:0] data_pclk;         // First stage of input synchronization
    reg[9:0] data_metastable;
    reg[9:0] data_out_clk;
    reg valid_pclk;
    reg valid_metastable;
    reg valid_clk;

    // Output Assignments
    assign data_out = data_out_clk;
    assign valid = valid_clk;    
  
    // Initialization
    initial begin
        capture_state <= IDLE;
        vsync_d <= 1'b0;
        href_d <= 1'b0;
        href_clk_count <= 9'b0;
        valid_pclk <= 1'b0;
        valid_metastable <= 1'b0;
        valid_clk <= 1'b0;
     end
     
     
    // Trigger Synchronizer - sync from clk to pclk domain
    // Since trigger stays high, don't need to worry about the fast -> slow domain transition (I think)
    always @(posedge pclk)
        {trigger_safe, trigger_metastable} <= {trigger_metastable, trigger};
     
        
    // Data Synchronizer
    always @(posedge clk) begin
        {valid_clk, valid_metastable} <= {valid_metastable, valid_pclk};
        {data_out_clk[9:0], data_metastable[9:0]} <= {data_metastable[9:0], data_pclk[9:0]}; 
    end
     
    // Capture State Machine
    always @(posedge pclk) begin
    case(capture_state)
        IDLE: begin
            if(trigger_safe == 1'b1) capture_state <= WAIT_VSYNC;
            else capture_state <= IDLE;
            
            vsync_d <= vsync;
            valid_pclk <= 1'b0;
        end
        
        WAIT_VSYNC: begin
            if(vsync_d == 1'b0 && vsync == 1'b1) capture_state <= PRE_FRAME;    // Capture the rising edge of vsync
            else capture_state <= WAIT_VSYNC;
            vsync_d <= vsync;
            href_d <= href;
        end
        
        PRE_FRAME: begin
            if(href_d == 1'b0 && href == 1'b1) begin
                // Register First Pixel
                data_pclk[9:0] <= data[9:0];
                valid_pclk <= 1'b1;
                capture_state <= LINE;
            end
            else capture_state <= PRE_FRAME;
            
            href_d <= href;
        end
        
        WAIT_HREF: begin
            // When the href low times are more than 322 pclks, it is the end of the frame
            href_clk_count <= href_clk_count + 1;
            
            if(href_d == 1'b0 && href == 1'b1 && href_clk_count < POST_FRAME_PCLK_THRESH) begin    
                // register first pixel
                data_pclk[9:0] <= data[9:0];
                valid_pclk <= 1'b1;
                
                capture_state <= LINE;
                href_clk_count <= 9'b0;
            end
            else if(href_clk_count >= POST_FRAME_PCLK_THRESH) begin // end of the frame, go to IDLE
                capture_state <= IDLE;
                href_clk_count <= 9'b0;
            end
            else capture_state <= WAIT_HREF;
            
            href_d <= href;
        end
        
        LINE: begin
            if(href == 1'b1) begin
              // Register the Pixels
              // TODO: might need to count these since it may assert valid for a false clock
              data_pclk[9:0] <= data[9:0];
              valid_pclk <= 1'b1;
            end
            
            // End of line, HREF low 
            else if(href == 1'b0) begin 
                valid_pclk <= 1'b0;
                href_d <= 1'b0;
                href_clk_count <= 9'b0;
                capture_state <= WAIT_HREF;
           end
        end
        
        default: capture_state <= IDLE;
    endcase
    end
endmodule
