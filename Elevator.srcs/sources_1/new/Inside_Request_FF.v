`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/20 19:39:40
// Design Name: 
// Module Name: Inside_Request_FF
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


module Inside_Request_FF(
	inside_request,clk,inside_request_out,inside_button_1,inside_button_2,inside_button_3,inside_button_4,rst
    );
	input[0:0] clk,inside_button_1,inside_button_2,inside_button_3,inside_button_4,rst;
	input[3:0] inside_request_out;
	output[3:0] inside_request;
	reg[3:0] temp,inside_request;
	reg[0:0] check_1,check_2,check_3,check_4;
	// inside_button_1,2,3,4 分别对应电梯内部1,2,3,4层按钮
	always @ (posedge clk,negedge rst)
		begin
			if(~rst)
				inside_request = 4'b0000;
			else
				begin
					temp = inside_request_out;
					if(inside_button_1&~check_1)
						begin
							temp[0] = 1'b1;
							check_1 = 1'b1;
						end
					if(~inside_button_1)
						check_1 = 1'b0;
					if(inside_button_2&~check_2)
						begin
							temp[1] = 1'b1;
							check_2 = 1'b1;
						end
					if(~inside_button_2)
						check_2 = 1'b0;
					if(inside_button_3&~check_3)
						begin
							temp[2] = 1'b1;
							check_3 = 1'b1;
						end
					if(~inside_button_3)
						check_3 = 1'b0;
					if(inside_button_4&~check_4)
						begin
							temp[3] = 1'b1;
							check_4 = 1'b1;
						end
					if(~inside_button_4)
						check_4 = 1'b0;
					inside_request = temp;
				end			
		end
endmodule
