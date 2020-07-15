`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/20 20:09:28
// Design Name: 
// Module Name: sim
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


module sim(
    );
	reg[0:0] clk,rst,inside_button_1,inside_button_2,inside_button_3,inside_button_4,
	outside_button_1,outside_button_2,outside_button_3,outside_button_4,outside_button_5,outside_button_6;
	wire[1:0] floor,motion_state;
	wire[3:0] inside_request;
	test_module main(inside_request,outside_request,floor,motion_state,clk,rst,outside_button_1,outside_button_2,outside_button_3,outside_button_4,outside_button_5,outside_button_6,
	inside_button_1,inside_button_2,inside_button_3,inside_button_4);
    initial
    begin
		clk = 1'b0;
		rst = 1'b0;
		outside_button_1 =  1'b0;
		outside_button_2 =  1'b0;
		outside_button_3 =  1'b0;
		outside_button_4 =  1'b0;
		outside_button_5 =  1'b0;
		outside_button_6 =  1'b0;
		inside_button_1 =  1'b0;
		inside_button_2 =  1'b0;
		inside_button_3 =  1'b0;
		inside_button_4 =  1'b0;
		forever #1 clk = ~clk;
	end
	initial fork
		#2 rst = 1'b1;
		#10 inside_button_1 = 1'b1;
		#13 inside_button_1 = 1'b0;
	join
endmodule
