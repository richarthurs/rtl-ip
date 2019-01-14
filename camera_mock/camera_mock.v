`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/10/2019 12:15:20 PM
// Design Name: 
// Module Name: camera_mock
// Project Name: 
// Description: 
/*  Mocked output from a parallel camera. 
    
*/

// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module camera_mock#(
    // Image size parameters (units = pixels)
    parameter COLS = 12'd12,
    parameter ROWS = 12'd12,
    
    // Delay parameters - override these for simulation 
    parameter VSYNC_PULSE_CLKS = 15'd1000,  // 1000
    parameter PRE_FRAME_CLKS = 15'd27193,   // 27193
    parameter NEW_ROW_CLKS = 15'd322,       // 322
    parameter POST_FRAME_CLKS = 15'd30000  // 30000
)(
    input clk,
    output [9:0] image,
    output reg vsync,
    output href,
    input rst_n
    );
    
    parameter dummy_param = 234;    // Vivado sim is weird. Removing this parameter causes the cols parameter not to work. You don't need to use dummy_param, it just needs to be there. WTF

    
    // Image and current pixel tracking
    reg [9:0]               m_image;    // Image data output
    reg [$clog2(ROWS):0]    row;
    reg [$clog2(COLS):0]    col;
    
    // State machine
    parameter   s_IDLE = 3'b000;
    parameter   s_VSYNC_PULSE = 3'b001;   
    parameter   s_PRE_FRAME = 3'b010;     
    parameter   s_ROW = 3'b011;
    parameter   s_NEW_ROW = 3'b100;
    parameter   s_POST_FRAME = 3'b101;
    
    reg [2:0]   state;
    reg [14:0]  delay_ctr;  // Multi-purpose counter for various delays. Max value: 32767
    
    reg m_href; // Sensor HREF signal - could also use output reg
    
    // Output Assignments
    assign href = m_href;
    assign image = m_image;
    
    // Reset
    // TODO: async reset?
    always @(posedge clk) begin
       if(!rst_n) begin
         m_image <= 'b0;
         vsync <= 1'b0;
         m_href <= 1'b0; 
         row <= 'b0;
         col <= 'b0;
         delay_ctr <= 'h0;
         state <= s_IDLE;
       end
    end

    // Camera output logic    
    always @(posedge clk) begin
        case(state)
            s_IDLE: begin
                m_image <= 'b0;
                vsync <= 1'b0;
                m_href <= 1'b0;
                delay_ctr <= 'h0;
                row <= 'b0;
                col <= 'b0;
                
                // Just reset the signals and then do another vsync pulse
                state <= s_VSYNC_PULSE;
            end
            
            s_VSYNC_PULSE: begin
                if(delay_ctr < VSYNC_PULSE_CLKS) begin
                    delay_ctr <= delay_ctr + 1;  // delay 1000 clks
                    vsync <= 1'b1;
                end
                else begin
                    state <= s_PRE_FRAME;
                    vsync <= 1'b0;
                    delay_ctr <= 0;
                end
            end
            
            s_PRE_FRAME: begin
                if(delay_ctr != PRE_FRAME_CLKS) begin
                    delay_ctr <= delay_ctr + 1; // delay 27193 clks
                end
                else begin
                    state <= s_ROW; 
                    delay_ctr <= 'h0;
                    row <= 'b0;
                end
            end
            
            s_ROW: begin
                if(row != ROWS) begin
                    row <= row + 1;     // Increment row count
                    m_href <= 1'b1;     // HREF HIGH
                    m_image <= row;     // Dummy data: pixel value is just the row number
                    state <= s_ROW;
                end
                else begin
                    state <= s_NEW_ROW;
                    m_href <= 1'b0;     // HREF LOW
                    row <= 'b0;
                    m_image <= 'hz;     // Can remove - just for making it visible on the sim
                end
            end
            
            s_NEW_ROW: begin
                if(delay_ctr != NEW_ROW_CLKS) begin     // Delay 322 clks
                    delay_ctr <= delay_ctr + 1;
                end
                else begin
                    delay_ctr <= 0;
                    if(col != COLS-1) begin
                        col <= col + 1;     // Increment column count
                        state <= s_ROW;
                    end 
                    else begin
                        state <= s_POST_FRAME;
                    end
                end
            end
            
            s_POST_FRAME: begin
                if(delay_ctr != POST_FRAME_CLKS) begin   // Delay 28000 clks
                    delay_ctr <= delay_ctr + 1;
                end
                else begin
                    state <= s_IDLE;
                    delay_ctr <= 0;
                end    
            end
        endcase
      
    end
     
endmodule
