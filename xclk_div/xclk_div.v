`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Richard Arthurs
// 
// Create Date: 01/18/2019 08:30:03 AM
// Design Name: 
// Module Name: xclk_div
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


module xclk_div(
    input clk,
    output xclk
    );
    
    reg xclk_o;
    reg[1:0] xcount;
    
    
    assign xclk = xclk_o;
    
    initial xclk_o <= 1'b0; 
    initial xcount <= 2'b00;
        
    always@(posedge clk) begin
    
        if(xcount == 2) begin
           xclk_o <= ~xclk_o;
            xcount <= 2'b00;
        end else begin
            xcount <= xcount + 1;
        end
    
    end
endmodule
