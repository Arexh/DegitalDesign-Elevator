`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/20 14:11:55
// Design Name: 
// Module Name: Main_Control
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


module Main_Control(
        input_temp,floor,motion_state,rst_door_control,inside_request_out,outside_request_out,rst_timer_sixty_seconds,rst_timer_three_seconds,clk,rst,inside_request,outside_request
            ,timer_three_seconds,timer_thirty_seconds,timer_sixty_seconds,jug,stop_and_wait
    );
    output[1:0] floor,motion_state;//当前楼层
    output[0:0] rst_timer_three_seconds,rst_timer_sixty_seconds,rst_door_control,input_temp;//电梯运行状态，三秒计时器复位信号，三十秒计时器复位信号，电梯开关门复位信号
	output[3:0] inside_request_out;//下一个时刻电梯内部的请求
	output[5:0] outside_request_out;//下一个时刻电梯外部的请求
    input[0:0] clk,rst,timer_three_seconds,timer_thirty_seconds,jug,timer_sixty_seconds,stop_and_wait;//时钟信号，复位信号，三秒计时器信号，三十秒计时器信号，电梯开关门反馈信号
    input[3:0] inside_request;//电梯内部的请求
    input[5:0] outside_request;//电梯外部的请求
    reg[1:0] floor,motion_state;//楼层，状态机的状态
	reg[4:0] state;
	reg[0:0] stop;
    reg[0:0] rst_timer_three_seconds,rst_timer_sixty_seconds,jugment,jugment_1,rst_jug,rst_door_control,input_temp;//电梯运行的状态，复位信号
    reg[3:0] inside_request_out;//内部请求
    reg[5:0] outside_request_out;//外部请求
    parameter S0 = 5'b00001, S1 = 5'b00010, S2 = 5'b00100, S3 = 5'b01000, S4 = 5'b10000;
	//motion_state 00静止，01上升，10下降
    always @ (negedge clk,negedge rst)
        begin
            $monitor($time," inside_request=%b,outside_request=%b,state=%b",inside_request,outside_request,state);	
            if (~rst)
				begin//复位
					rst_timer_three_seconds <= 1'b0;
                    rst_timer_sixty_seconds <= 1'b0;
					rst_door_control <= 1'b0;
                    floor <= 2'b00;
                    inside_request_out <= 4'b0000;
                    outside_request_out <= 6'b000000;
                    state <= S0;
					jugment <= 1'b0;
					jugment_1 <= 1'b0;
					rst_jug <= 1'b0;
					input_temp <= 1'b0;
					rst_timer_sixty_seconds <= 1'b0;
					stop <= 1'b0;
                end
            else if(stop_and_wait)
				begin
					inside_request_out <= inside_request;
					outside_request_out <= outside_request;//***防止电梯上升时输入的信号被遗漏
				end
			else
            begin
                case (state)
					S0://状态0:电梯停止于1楼
						begin
							if (inside_request[0] == 1'b1 | outside_request[0] == 1'b1)//检测到电梯内部按了1楼，或者电梯外部按了1楼上
								begin
									inside_request_out = inside_request & 4'b1110;//清除电梯内部1楼的请求信号
									outside_request_out = outside_request & 6'b111110;//清除电梯外部1楼上楼的请求信号
									jugment = 1'b1;//判断是否开门
								end
							else if (jugment)//该层电梯内部或者外部有上楼的有请求
								begin
									inside_request_out <= inside_request;
									outside_request_out <= outside_request;//***防止电梯上升时输入的信号被遗漏
									input_temp = 1'b0;
									rst_door_control = 1'b1;//激活电梯开门模块
									if (jug)//电梯门反馈已关好门
										begin
											rst_door_control = 1'b0;
											jugment = 1'b0;//已经开过一次门
										end
								end
							else
								begin
									inside_request_out = inside_request & 4'b1110;
									outside_request_out = outside_request & 6'b111110;
									floor <= 2'b00;//电梯层数为1
									if (inside_request_out == 4'b0000 & outside_request_out == 6'b000000)//如果没有任何请求
										begin
											input_temp = 1'b1;//设电梯门为关闭状态
											rst_door_control = 1'b1;//使能电梯门
											motion_state <= 2'b00;//状态设为静止
											state <= S0;//状态仍为0
										end
									else//有上层的请求，电梯上升
										begin
											rst_door_control = 1'b0;//置位电梯门
											motion_state <= 2'b01;//状态设为上升
											state <= S1;//状态跳转为1
										end
								end
						end
					S1://状态1:电梯上升，整个过程三秒
						begin
							inside_request_out <= inside_request;
							outside_request_out <= outside_request;//***防止电梯上升时输入的信号被遗漏
							rst_timer_three_seconds <= 1'b1;//使能三秒计时器
							if (timer_three_seconds == 1'b1)//当计时器输出信号为1时
								begin
									rst_timer_three_seconds <= 1'b0;//计时器停止计时
									motion_state <= 2'b00;//状态设为静止
									floor <= floor + 1;//楼层层数加1
									state <= S3;//转为状态3
								end                                                             
						end
					S2://状态2:电梯下降，整个过程三秒
						begin
							inside_request_out <= inside_request;
							outside_request_out <= outside_request;//***防止电梯上升时输入的信号被遗漏
							motion_state <= 2'b10;//状态设为下降
							rst_timer_three_seconds <= 1'b1;//开始计时
							if (timer_three_seconds == 1'b1)//当计时器输出信号为1时
								begin
									rst_timer_three_seconds <= 1'b0;//计时器停止计时
									floor = floor - 1;//楼层层数减1
									if (floor == 2'b00)//当楼层层数为1楼时
										begin
											motion_state <= 2'b00;//运动状态为静止
											state <= S0;//转变为状态0
										end
									else
										begin
											motion_state <= 2'b00;//状态设为静止
											state <= S4;//否则转变为状态4
										end
								end
						end
					S3://状态3:电梯刚刚上升到某层
						begin
							if(floor == 2'b01)//当电梯层数为2时**********************************************
								begin
									if (timer_sixty_seconds|stop)
										begin
											stop <= 1'b1;
											rst_door_control = 1'b0;
											rst_timer_sixty_seconds <= 1'b0;
											jugment <= 1'b0;
											jugment_1 <= 1'b0;
											motion_state <= 2'b10;
											rst_timer_three_seconds <= 1'b1;
											if(timer_three_seconds)
												begin
													rst_timer_three_seconds <= 1'b0;//计时器停止计时
													floor = floor - 1;//楼层层数减1
													if (floor == 2'b00)//当楼层层数为1楼时
														begin
															motion_state <= 2'b00;//运动状态为静止
															stop <= 1'b0;
															state <= S0;//转变为状态0
														end
												end
										end
									else
										begin
											if (outside_request[2] == 1'b1)//电梯外部有下去的请求
												jugment_1 = 1'b1;
											if (inside_request[1] == 1'b1 | outside_request[1] == 1'b1)
												begin
													inside_request_out = inside_request & 4'b1101;//清除电梯内部2楼的请求信号
													outside_request_out = outside_request & 6'b111101;//清除电梯外部2楼上楼的请求信号
													jugment = 1'b1;
												end
											else if (jugment)//该层电梯内部或者外部有上楼的请求
												begin
													inside_request_out <= inside_request;
													outside_request_out <= outside_request;//***防止电梯上升时输入的信号被遗漏
													input_temp = 1'b0;
													rst_timer_sixty_seconds = 1'b0;
													rst_door_control = 1'b1;//激活电梯开门模块
													if (jug)//电梯已经关好门
														begin
															rst_door_control = 1'b0;
															jugment = 1'b0;//已经开过一次门
														end
												end
											else
												begin
													inside_request_out = inside_request & 4'b1101;//清除电梯内部2楼的请求信号
													if(inside_request_out >= 4'b0100 | outside_request_out >= 6'b001000)//当上层有请求信号的时候
														begin
															motion_state = 2'b01;
															jugment = 1'b0;
															jugment_1 = 1'b0;
															rst_door_control = 1'b0;
															state = S1;//电梯上升
														end
													else if(inside_request_out == 4'b0001 | (outside_request_out & 6'b111001) == 6'b000001)//无上层请求信号，有下层请求是信号
														begin
															if (jugment_1)//电梯外部有下去的请求
																begin
																	outside_request_out = outside_request & 6'b111001;//清除电梯外部2楼上楼及下楼的请求信号
																	input_temp = 1'b0;
																	rst_timer_sixty_seconds = 1'b0;
																	rst_door_control = 1'b1;//激活电梯开门模块
																	if (jug)
																		begin
																			jugment_1 = 1'b0;//第二次开门结束
																			rst_door_control = 1'b0;
																		end
																end
															else
																begin
																	outside_request_out <= outside_request;//***防止电梯上升时输入的信号被遗漏
																	motion_state = 2'b10;
																	jugment = 1'b0;
																	jugment_1 = 1'b0;
																	rst_door_control = 1'b0;
																	state = S2;//电梯下降
																end
														end
													else //无情求信号
														begin
															outside_request_out <= outside_request & 6'b111001;//清除电梯外部2楼上楼以及下楼的请求信号
															motion_state <= 2'b00;
															if (jugment_1)//电梯有下去的请求
																begin
																	input_temp = 1'b0;
																	rst_timer_sixty_seconds = 1'b0;
																	rst_door_control = 1'b1;//激活电梯开门模块
																	if (jug)
																		begin
																			rst_door_control = 1'b0;
																			jugment_1 = 1'b0;
																		end
																end
															else
																begin
																	jugment = 1'b0;
																	jugment_1 = 1'b0;
																	input_temp = 1'b1;
																	rst_door_control = 1'b1;
																	rst_timer_sixty_seconds = 1'b1;
																	state = S3;//继续等待信号
																end
														end
											end
										end
								end
							else if(floor == 2'b10)//电梯层数为3时***************************************
								begin
									if (timer_sixty_seconds|stop)
										begin
											stop <= 1'b1;
											rst_timer_sixty_seconds <= 1'b0;
											jugment <= 1'b0;
											jugment_1 <= 1'b0;
											motion_state <= 2'b10;
											rst_timer_three_seconds <= 1'b1;
											if(timer_three_seconds)
												begin
													rst_timer_three_seconds <= 1'b0;//计时器停止计时
													floor = floor - 1;//楼层层数减1
													if (floor == 2'b00)//当楼层层数为1楼时
														begin
															motion_state <= 2'b00;//运动状态为静止
															stop <= 1'b0;
															rst_door_control = 1'b0;
															state <= S0;//转变为状态0
														end
												end
										end
									else 
										begin
											if (outside_request[4] == 1'b1)
												jugment_1 = 1'b1;
											if (inside_request[2] == 1'b1 | outside_request[3] == 1'b1)
												begin
													inside_request_out = inside_request & 4'b1011;//清除电梯内部3楼的请求信号
													outside_request_out = outside_request & 6'b110111;//清除电梯外部3楼上楼的请求信号
													jugment = 1'b1;
												end
											else if (jugment)//该层电梯内部或者外部有上楼的有请求
												begin
													inside_request_out <= inside_request;
													outside_request_out <= outside_request;//***防止电梯上升时输入的信号被遗漏
													rst_timer_sixty_seconds = 1'b0;
													input_temp = 1'b0;
													rst_door_control = 1'b1;//激活电梯开门模块
													if (jug)//电梯已经关好门
														begin
															rst_door_control = 1'b0;
															jugment = 1'b0;//已经开过一次门
														end
												end
											else
												begin
													inside_request_out = inside_request & 4'b1011;//清除电梯内部3楼的请求信号
													if(inside_request_out >= 4'b1000 | outside_request_out >= 6'b100000)//当上层有请求信号的时候
														begin
															motion_state = 2'b01;
															jugment = 1'b0;
															jugment_1 = 1'b0;
															rst_door_control = 1'b0;
															state = S1;//电梯上升
														end
													else if(inside_request_out > 4'b0000 | (outside_request_out & 6'b100111) > 6'b000000)//无上层请求信号，有下层请求信号
														begin
															if (jugment_1)//电梯有下去的请求
																begin
																	rst_timer_sixty_seconds = 1'b0;
																	outside_request_out = outside_request & 6'b100111;//清除电梯外部3楼上楼及下楼的请求信号
																	input_temp = 1'b0;
																	rst_door_control = 1'b1;//激活电梯开门模块
																	if (jug)//第二次开门
																		begin
																			jugment_1 = 1'b0;//第二次开门结束
																			rst_door_control = 1'b0;
																		end
																end
															else
																begin
																	outside_request_out = outside_request;//***防止电梯上升时输入的信号被遗漏
																	motion_state = 2'b10;
																	jugment = 1'b0;
																	jugment_1 = 1'b0;
																	rst_door_control = 1'b0;
																	state = S2;//电梯下降
																end
														end
													else 
														begin
															outside_request_out = outside_request & 6'b100111;//清除电梯外部3楼上楼以及下楼的请求信号
															motion_state = 2'b00;
															if (jugment_1)//电梯有下去的请求
																begin
																	rst_timer_sixty_seconds = 1'b0;
																	input_temp = 1'b0;
																	rst_door_control = 1'b1;//激活电梯开门模块
																	if (jug)
																		begin
																			rst_door_control = 1'b0;
																			jugment_1 = 1'b0;
																		end
																end
															else
																begin
																	jugment = 1'b0;
																	jugment_1 = 1'b0;
																	input_temp = 1'b1;
																	rst_door_control = 1'b1;
																	rst_timer_sixty_seconds = 1'b1;
																	state = S3;//继续等待信号
																end
														end
												end
										end
								end//***********************************************************************************                                                
							else//电梯层数为4时*******************************************************************************
								begin
									if (timer_sixty_seconds|stop)
										begin
											rst_door_control = 1'b0;
											stop <= 1'b1;
											rst_timer_sixty_seconds <= 1'b0;
											jugment <= 1'b0;
											jugment_1 <= 1'b0;
											motion_state <= 2'b10;
											rst_timer_three_seconds <= 1'b1;
											if(timer_three_seconds)
												begin
													rst_timer_three_seconds <= 1'b0;//计时器停止计时
													floor = floor - 1;//楼层层数减1
													if (floor == 2'b00)//当楼层层数为1楼时
														begin
															motion_state <= 2'b00;//运动状态为静止
															stop <= 1'b0;
															state <= S0;//转变为状态0
														end
												end
										end
									else
										begin
											if (inside_request[3] == 1'b1 | outside_request[5] == 1'b1)
												begin
													inside_request_out = inside_request & 4'b0111;//清除电梯内部4楼的请求信号
													outside_request_out = outside_request & 6'b011111;//清除电梯外部4楼下楼的请求信号
													jugment = 1'b1;
												end
											else if (jugment)//该层电梯内部或者外部有下楼的有请求
												begin
													rst_timer_sixty_seconds = 1'b0;
													inside_request_out = inside_request;
													outside_request_out = outside_request;//***防止电梯上升时输入的信号被遗漏
													input_temp = 1'b0;
													rst_door_control = 1'b1;//激活电梯开门模块
													if (jug)//电梯已经关好门
														begin
															rst_door_control = 1'b0;
															jugment = 1'b0;//已经开过一次门
														end
												end
											else	
												begin
													inside_request_out = inside_request & 4'b0111;//清除电梯内部4楼的请求信号
													outside_request_out = outside_request & 6'b011111;//清除电梯外部4楼的请求信号
													if(inside_request_out > 4'b0000 | outside_request_out > 6'b000000)//当下层有请求信号
														begin
															motion_state = 2'b10;
															jugment = 1'b0;
															rst_door_control = 1'b0;
															state = S2;//电梯下降
														end
													else//无请求信号
														begin
															jugment = 1'b0;
															jugment_1 = 1'b0;
															input_temp = 1'b1;
															rst_door_control = 1'b1;//激活电梯开门模块
															rst_timer_sixty_seconds = 1'b1;
															state = S3;//继续等待信号
														end
												end
										end
								end
						end
					S4://状态4:电梯刚刚下升到某层************************************************
						begin
							if(floor == 2'b01)//电梯层数为2
								begin
									if (timer_sixty_seconds|stop)
										begin
											rst_door_control = 1'b0;
											stop <= 1'b1;
											rst_timer_sixty_seconds <= 1'b0;
											jugment <= 1'b0;
											jugment_1 <= 1'b0;
											motion_state <= 2'b10;
											rst_timer_three_seconds <= 1'b1;
											if(timer_three_seconds)
												begin
													rst_timer_three_seconds <= 1'b0;//计时器停止计时
													floor = floor - 1;//楼层层数减1
													if (floor == 2'b00)//当楼层层数为1楼时
														begin
															motion_state <= 2'b00;//运动状态为静止
															stop <= 1'b0;
															state <= S0;//转变为状态0
														end
												end
										end
									else
										begin
											if (outside_request[1] == 1'b1)
												jugment_1 = 1'b1;
											if (inside_request[1] == 1'b1 | outside_request[2] == 1'b1)
												begin
													inside_request_out = inside_request & 4'b1101;//清除电梯内部2楼的请求信号
													outside_request_out = outside_request & 6'b111011;//清除电梯外部2楼下楼的请求信号
													jugment = 1'b1;
												end
											else if (jugment)//该层电梯内部或者外部有上楼的请求
												begin
													inside_request_out <= inside_request;
													outside_request_out <= outside_request;//***防止电梯上升时输入的信号被遗漏
													input_temp = 1'b0;
													rst_timer_sixty_seconds = 1'b0;
													rst_door_control = 1'b1;//激活电梯开门模块
													if (jug)//电梯已经关好门
														begin
															rst_door_control = 1'b0;
															jugment = 1'b0;//已经开过一次门
														end
												end
											else
												begin
													inside_request_out = inside_request & 4'b1101;//清除电梯内部2楼的请求信号
													//outside_request_out = outside_request & 6'b111011;//清除电梯外部2楼下楼的请求信号
													if( (inside_request_out & 4'b0001) == 4'b0001 | (outside_request_out & 6'b000001) == 6'b000001)//当1楼有请求信号的时候
														begin
															motion_state <= 2'b10;
															jugment = 1'b0;
															jugment_1 = 1'b0;
															rst_door_control = 1'b0;
															state <= S2;//电梯下降
														end
													else if(inside_request_out >= 4'b0100 | outside_request_out >= 6'b0001000)//上层有请求信号的时候
														begin
															if (jugment_1)//电梯有上去的请求
																begin
																	outside_request_out = outside_request & 6'b111001;//清除电梯外部2楼上楼及下楼的请求信号
																	input_temp = 1'b0;
																	rst_timer_sixty_seconds = 1'b0;
																	rst_door_control = 1'b1;//激活电梯开门模块
																	if (jug)//第二次开门
																		begin
																			jugment_1 = 1'b0;//第二次开门结束
																			rst_door_control = 1'b0;
																		end
																end
															else
																begin
																	outside_request_out <= outside_request;//***防止电梯上升时输入的信号被遗漏
																	motion_state <= 2'b01;
																	jugment = 1'b0;
																	jugment_1 = 1'b0;
																	rst_door_control = 1'b0;
																	state <= S1;//电梯上升
																end
														end
													else//无请求信号
														begin
															outside_request_out <= outside_request & 6'b111001;//清除电梯外部2楼上楼以及下楼的请求信号
															motion_state <= 2'b00;
															if (jugment_1)//电梯有下去的请求
																begin
																	input_temp = 1'b0;
																	rst_timer_sixty_seconds = 1'b0;
																	rst_door_control = 1'b1;//激活电梯开门模块
																	if (jug)
																		begin
																			rst_door_control = 1'b0;
																			jugment_1 = 1'b0;
																		end
																end
															else
																begin
																	jugment = 1'b0;
																	jugment_1 = 1'b0;
																	input_temp = 1'b1;
																	rst_door_control = 1'b1;
																	rst_timer_sixty_seconds = 1'b1;
																	state = S4;//继续等待信号
																end
														end
												end
										end
								end
							else if(floor == 2'b10)//电梯层数为3时
								begin
									if (timer_sixty_seconds|stop)
										begin
											rst_door_control = 1'b0;
											stop <= 1'b1;
											rst_timer_sixty_seconds <= 1'b0;
											jugment <= 1'b0;
											jugment_1 <= 1'b0;
											motion_state <= 2'b10;
											rst_timer_three_seconds <= 1'b1;
											if(timer_three_seconds)
												begin
													rst_timer_three_seconds <= 1'b0;//计时器停止计时
													floor = floor - 1;//楼层层数减1
													if (floor == 2'b00)//当楼层层数为1楼时
														begin
															motion_state <= 2'b00;//运动状态为静止
															stop <= 1'b0;
															state <= S0;//转变为状态0
														end
												end
										end
									else 
										begin
											if (outside_request[3] == 1'b1)
												jugment_1 = 1'b1;
											if (inside_request[2] == 1'b1 | outside_request[4] == 1'b1)
												begin
													inside_request_out = inside_request & 4'b1011;//清除电梯内部3楼的请求信号
													outside_request_out = outside_request & 6'b101111;//清除电梯外部3楼下楼的请求信号
													jugment = 1'b1;
												end
											else if (jugment)//该层电梯内部或者外部有下楼的有请求
												begin
													rst_timer_sixty_seconds = 1'b0;
													inside_request_out <= inside_request;
													outside_request_out <= outside_request;//***防止电梯上升时输入的信号被遗漏
													input_temp = 1'b0;
													rst_door_control = 1'b1;//激活电梯开门模块
													if (jug)//电梯已经关好门
														begin
															rst_door_control = 1'b0;
															jugment = 1'b0;//已经开过一次门
														end
												end	
											else
												begin
													inside_request_out = inside_request & 4'b1011;//清除电梯内部3楼的请求信号
													//outside_request_out = outside_request & 6'b101111;//清除电梯外部3楼下楼请求信号
													if( (inside_request_out & 4'b0011) > 4'b0000 | (outside_request_out & 6'b000111) > 6'b000000)//当下层有请求信号
														begin
															motion_state <= 2'b10;
															jugment = 1'b0;
															jugment_1 = 1'b0;
															rst_door_control = 1'b0;
															state <= S2;//电梯下降
														end
													else if(inside_request_out == 4'b1000 | (outside_request_out & 6'b100000) == 6'b100000)//无下层请求信号，有上层请求信号
														begin
															if (jugment_1)//电梯有上去的请求
																begin
																	rst_timer_sixty_seconds = 1'b0;
																	outside_request_out = outside_request & 6'b100111;//清除电梯外部3楼上楼及下楼请求信号
																	input_temp = 1'b0;
																	rst_door_control = 1'b1;//激活电梯开门模块
																	if (jug)//第二次开门
																		begin
																			jugment_1 = 1'b0;//第二次开门结束
																			rst_door_control = 1'b0;
																		end
																end
															else
																begin
																	outside_request_out = outside_request;
																	motion_state = 2'b01;
																	jugment = 1'b0;
																	jugment_1 = 1'b0;
																	rst_door_control = 1'b0;
																	state = S1;//电梯上升
																end
														end
													else//无请求信号
														begin
															outside_request_out = outside_request & 6'b100111;//清除电梯外部3楼下楼及上楼的请求信号
															motion_state = 2'b00;
															if (jugment_1)//电梯有下去的请求
																begin
																	rst_timer_sixty_seconds = 1'b0;
																	input_temp = 1'b0;
																	rst_door_control = 1'b1;//激活电梯开门模块
																	if (jug)
																		begin
																			rst_door_control = 1'b0;
																			jugment_1 = 1'b0;
																		end
																end
															else
																begin
																	jugment = 1'b0;
																	jugment_1 = 1'b0;
																	input_temp = 1'b1;
																	rst_door_control = 1'b1;
																	rst_timer_sixty_seconds = 1'b1;
																	state = S4;//继续等待信号
																end
														end
												end
										end
								end
						end
			   endcase
            end
        end 
endmodule
