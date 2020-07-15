`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/20 21:56:38
// Design Name: 
// Module Name: Timer
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

module Timer
    #(parameter N=1)
    (
        input clk,rst_n,
        output clk_out
        );
    reg clk_p,clk_n;
    integer cnt_n;
    integer cnt_p;
    assign clk_out=clk_p|(N&1?clk_n:0);
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) cnt_p<=0;
        else if (cnt_p==N-1) cnt_p<=0;
        else cnt_p<=cnt_p+1;
    end
      
    always @(negedge clk or negedge rst_n) begin
        if (!rst_n) cnt_n<=0;
        else if (cnt_n==(N&1?N-1:N/2-1)) cnt_n<=0;
        else cnt_n<=cnt_n+1;
    end
      
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) clk_p<=0;
        else if (cnt_p==(N&1?(N-1)/2:N/2-1)) clk_p<=~clk_p;
        else if (cnt_p==(N-1)) clk_p<=~clk_p;
    end
    
    always @(negedge clk or negedge rst_n) begin
        if (!rst_n) clk_n<=0;
        else if (cnt_n==(N-1)/2) clk_n<=~clk_n;
        else if (cnt_n==(N-1)) clk_n<=~clk_n;
    end
endmodule

