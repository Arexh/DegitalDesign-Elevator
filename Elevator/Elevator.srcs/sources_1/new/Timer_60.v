`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/23 13:14:49
// Design Name: 
// Module Name: Timer_60
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


module Timer_60
(
    input clk,rst_n,rst_door_control_timer,
    output reg clk_out
    );
integer cnt_p;
integer times;
parameter N=1000_000_000;

always@(posedge clk,negedge rst_n,posedge rst_door_control_timer) begin
	if (rst_door_control_timer|!rst_n) begin
		cnt_p<=0;
		times<=0;
		clk_out<=0;
	end
	else if (times=='d2 && cnt_p==N-1) begin
		cnt_p<=0;
		times<=0;
		clk_out<=~clk_out;
	end else if (cnt_p==N-1) begin
		cnt_p<=0;
		times<=times+1;
	end else cnt_p<=cnt_p+1;
end

endmodule
