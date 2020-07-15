`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/20 20:31:46
// Design Name: 
// Module Name: Outside_Request_FF
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


module Outside_Request_FF(
    outside_request,clk,outside_request_out,outside_button_1,outside_button_2,outside_button_3,outside_button_4,outside_button_5,outside_button_6,rst
    );
	input[0:0] clk,outside_button_1,outside_button_2,outside_button_3,outside_button_4,outside_button_5,outside_button_6,rst;
	input[5:0] outside_request_out;
	output[5:0] outside_request;
	reg[5:0] temp,outside_request;
	reg[0:0] check_1,check_2,check_3,check_4,check_5,check_6;
	//button_1,2,3,4,5,6 分别对应1楼的上按钮，2楼的上按钮，2楼的下按钮，3楼的上按钮，3楼的下按钮，4楼的下按钮
	always @ (posedge clk,negedge rst)
		begin
			if(~rst)
				outside_request = 6'b000000;
			else
				begin
					temp = outside_request_out;
					if(outside_button_1&~check_1)
						begin
							temp[0] = 1'b1;
							check_1 = 1'b1;
						end
					if(~outside_button_1)
						check_1 = 1'b0;
					if(outside_button_2&~check_2)
						begin
							temp[1] = 1'b1;
							check_2 = 1'b1;
						end
					if(~outside_button_2)
						check_2 = 1'b0;
					if(outside_button_3&~check_3)
						begin
							temp[2] = 1'b1;
							check_3 = 1'b1;
						end
					if(~outside_button_3)
						check_3 = 1'b0;
					if(outside_button_4&~check_4)
						begin
							temp[3] = 1'b1;
							check_4 = 1'b1;
						end
					if(~outside_button_4)
						check_4 = 1'b0;
					if(outside_button_5&~check_5)
						begin
							temp[4] = 1'b1;
							check_5 = 1'b1;
						end
					if(~outside_button_5)
						check_5 = 1'b0;
					if(outside_button_6&~check_6)
						begin
							temp[5] = 1'b1;
							check_6 = 1'b1;
						end
					if(~outside_button_6)
						check_6 = 1'b0;
					outside_request = temp;
				end
		end
endmodule
