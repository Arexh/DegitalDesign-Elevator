`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/20 21:50:58
// Design Name: 
// Module Name: Main_Program
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


module Main_Program(
	clk,rst,outside_button_1,outside_button_2,outside_button_3,outside_button_4,outside_button_5,outside_button_6,
	inside_button_1,inside_button_2,inside_button_3,inside_button_4,button_open,button_close,floor,motion_state,count,beep
    );
    wire[0:0] rst_timer_three_seconds,rst_timer_thirty_seconds,stop_and_wait,rst_timer_half_second,rst_timer_one_half_second,timer_half_second,timer_one_half_second;
	output[1:0] floor,motion_state;
	wire[3:0] inside_request;
	wire[3:0] inside_request_out;
	output[2:0] count;
	output beep;
	wire[5:0] outside_request;
	wire[5:0] outside_request_out;
	input[0:0] inside_button_1,inside_button_2,inside_button_3,
	inside_button_4,outside_button_1,outside_button_2,outside_button_3,outside_button_4,outside_button_5,outside_button_6,button_close,button_open,clk,rst;
	wire[0:0] timer_three_seconds,timer_thirty_seconds,rst_timer_sixty_seconds,timer_sixty_seconds;
	Timer#(2) three_seconds_timer(clk,rst_timer_three_seconds,timer_three_seconds);
    Timer#(2) thirty_seconds_timer(clk,rst_timer_thirty_seconds,timer_thirty_seconds);
    wire[0:0] jug,rst_door_control,input_temp,rst_door_control_timer;
    Main_Control main_control(input_temp,floor,motion_state,rst_door_control,inside_request_out,outside_request_out,rst_timer_sixty_seconds,rst_timer_three_seconds,clk,rst,inside_request,outside_request
            ,timer_three_seconds,timer_thirty_seconds,timer_sixty_seconds,jug,stop_and_wait);
	Inside_Request_FF inside_a(inside_request,clk,inside_request_out,inside_button_1,inside_button_2,inside_button_3,inside_button_4,rst);
	Outside_Request_FF outside_b(outside_request,clk,outside_request_out,outside_button_1,outside_button_2,outside_button_3,outside_button_4,outside_button_5,outside_button_6,rst);
	Door_Control door_control(count,jug,rst_door_control,clk,button_open,button_close,input_temp,rst_door_control_timer,stop_and_wait,beep,rst_timer_half_second,timer_half_second,rst_timer_one_half_second,timer_one_half_second);
	Timer_60 sixty_seconds_timer(clk,rst_timer_sixty_seconds, rst_door_control_timer, timer_sixty_seconds);
    Timer#(1) one_second(clk,rst_timer_half_second,timer_half_second);
    Timer#(1) one_and_half_second(clk,rst_timer_one_half_second,timer_one_half_second);
endmodule