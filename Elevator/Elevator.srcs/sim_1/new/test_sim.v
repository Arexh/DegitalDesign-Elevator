`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/21 10:29:51
// Design Name: 
// Module Name: test_sim
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


module test_sim(
    
    );
    wire[1:0] floor,motion_state;
    wire[2:0] count;
    wire[0:0] beep;
    reg[0:0] inside_button_1,inside_button_2,inside_button_3,button_open,button_close,
    inside_button_4,outside_button_1,outside_button_2,outside_button_3,outside_button_4,outside_button_5,outside_button_6,clk,rst;
	Main_Program main(clk,rst,outside_button_1,outside_button_2,outside_button_3,outside_button_4,outside_button_5,outside_button_6,
        inside_button_1,inside_button_2,inside_button_3,inside_button_4,button_open,button_close,floor,motion_state,count,beep);
	initial
    begin
		clk = 1'b0;
		rst = 1'b0;
		inside_button_1 = 1'b0;
		inside_button_2 = 1'b0;
		inside_button_3 = 1'b0;
		inside_button_4 = 1'b0;
		outside_button_1 = 1'b0;
		outside_button_2 = 1'b0;
		outside_button_3 = 1'b0;
		outside_button_4 = 1'b0;
		outside_button_5 = 1'b0;
		outside_button_6 = 1'b0;
		button_open = 1'b0;
		button_close = 1'b0;
		forever #1 clk = ~clk;
	end
	initial fork
		#3 rst = 1'b1;
		#10 inside_button_3 = 1'b1;
		#13 inside_button_3 = 1'b0;
		#20 outside_button_5 = 1'b1;
        #23 outside_button_5 = 1'b0;
        #45 inside_button_4 =1'b1;
        #47 inside_button_4 =1'b0;
        #50 inside_button_1 =1'b1;
        #52 inside_button_2 = 1'b1;
        #55 inside_button_1 = 1'b0;
        #55 inside_button_2 = 1'b0;

	join
endmodule
