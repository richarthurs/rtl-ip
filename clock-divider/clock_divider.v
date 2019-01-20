`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/20/2019 08:53:06 AM
// Design Name: 
// Module Name: clock-divider
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
// Inspired by: http://zipcpu.com/blog/2017/06/02/generating-timing.html
// 
//////////////////////////////////////////////////////////////////////////////////


module clock_divider(
    input clk,
    output clk_out
    );
    
    parameter INPUT_CLK_DIVISION_RATE = 4; // Divide the input clk by this value to get the output clk of this module
    localparam INCREMENT = 2**16 / INPUT_CLK_DIVISION_RATE;
    
    reg[15:0] counter;
    reg clk_stb;
    
    always@(posedge clk) begin
        {clk_stb, counter} <= counter + INCREMENT;
    end
    
    // Outputs
    assign clk_out = counter[15];
    
endmodule
