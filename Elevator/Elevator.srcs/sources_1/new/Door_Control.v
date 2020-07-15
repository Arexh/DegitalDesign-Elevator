`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/22 12:13:41
// Design Name: 
// Module Name: Door_Control
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


module Door_Control(
    count,jug,rst_door_control,clk,button_open,button_close,input_temp,rst_door_control_timer,stop_and_wait,beep,rst_timer_half_second,timer_half_second,rst_timer_one_half_second,timer_one_half_second
    );
    output[2:0] count;
    output[0:0] jug,rst_door_control_timer,stop_and_wait,rst_timer_half_second,rst_timer_one_half_second;
	output beep;
    input[0:0] clk,rst_door_control,button_open,button_close,input_temp,timer_one_half_second,timer_half_second;
	reg[0:0] jug,rst_door_control_timer,stop_and_wait,buzzer_start,rst_buzzer,rst_timer_one_half_second,rst_timer_half_second;
	reg[1:0] state;
	//state 00静止，01开门，10关门
	reg[2:0] count;
	wire[0:0] temp;
	assign temp = input_temp;
	reg[0:0] jugment;
	always @ (posedge clk,negedge rst_door_control)
		begin
			if (~rst_door_control)
				begin
					state = 2'b00;
					jug = 1'b0;
					count = 3'b000;
					jugment = 1'b0;
					rst_door_control_timer = 1'b0;
					stop_and_wait = 1'b0;
					rst_buzzer = 1'b0;
					buzzer_start = 1'b0;
					rst_timer_half_second = 1'b0;
					rst_timer_one_half_second = 1'b0;
				end
			else if (temp == 1'b0 & ~jugment)//第一次开门开到底
					if(~buzzer_start)
						begin
							rst_buzzer = 1'b1;
							$display($time," doorcontrol %b",timer_one_half_second);
							rst_timer_one_half_second = 1'b1;
							if (timer_one_half_second)
								begin
									buzzer_start = 1'b1;
									rst_timer_one_half_second = 1'b0;
									rst_buzzer = 1'b0;
								end
						end
					else
						begin
						rst_timer_half_second = 1'b1;
						if (timer_half_second)
							begin
								rst_timer_half_second = 1'b0;
								if (count == 3'b101)
									begin
									    jugment = 1'b1;
										state = 2'b10;
									end
								else
									count = count + 1;			
							end
						end
			else if (state == 2'b00)//静止
				begin
					stop_and_wait = 1'b0;
					rst_door_control_timer = 1'b0;
					if (button_open)
						state = 2'b01;
					else
						state = 2'b00;
				end
			else if(state == 2'b01)//开门
				begin
					stop_and_wait = 1'b1;
					rst_door_control_timer = 1'b1;
					rst_timer_half_second = 1'b1;
					if (button_close)
						begin
							state = 2'b10;
							rst_timer_half_second = 1'b0;
						end
					else if (timer_half_second)
						begin
							rst_timer_half_second = 1'b0;
							if (count == 3'b101)
								state = 2'b10;
							else
								count = count + 1;
						end
				end
			else//关门
				begin
					rst_timer_half_second = 1'b1;
					if (button_open)
						begin
							state = 2'b01;
							rst_timer_half_second = 1'b0;
						end
					else if (timer_half_second)
						begin
							rst_timer_half_second = 1'b0;
							if (count == 3'b000)
								begin
									jug = 1'b1;
									state = 2'b00;
								end
							else 			
								count = count - 1;
						end
				end
		end

	Buzzer buzzer(rst_buzzer,clk,beep);
endmodule
