`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/22 13:20:01
// Design Name: 
// Module Name: test_door
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


module test_door(

    );
	wire[2:0] count;
	wire[0:0] jug;
	reg[0:0] rst_door_control,clk,button_open,button_close;
	Door_Control a(count,jug,rst_door_control,clk,button_open,button_close);
	initial
	begin
		rst_door_control = 1'b0;
		clk = 1'b0;
		button_close = 1'b0;
		button_open = 1'b0;
	end
	initial
		#1 forever #1 clk = ~clk;
	initial
	begin
		#5 rst_door_control = 1'b1;
	end
endmodule
