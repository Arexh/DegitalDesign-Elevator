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
    output[1:0] floor,motion_state;//��ǰ¥��
    output[0:0] rst_timer_three_seconds,rst_timer_sixty_seconds,rst_door_control,input_temp;//��������״̬�������ʱ����λ�źţ���ʮ���ʱ����λ�źţ����ݿ����Ÿ�λ�ź�
	output[3:0] inside_request_out;//��һ��ʱ�̵����ڲ�������
	output[5:0] outside_request_out;//��һ��ʱ�̵����ⲿ������
    input[0:0] clk,rst,timer_three_seconds,timer_thirty_seconds,jug,timer_sixty_seconds,stop_and_wait;//ʱ���źţ���λ�źţ������ʱ���źţ���ʮ���ʱ���źţ����ݿ����ŷ����ź�
    input[3:0] inside_request;//�����ڲ�������
    input[5:0] outside_request;//�����ⲿ������
    reg[1:0] floor,motion_state;//¥�㣬״̬����״̬
	reg[4:0] state;
	reg[0:0] stop;
    reg[0:0] rst_timer_three_seconds,rst_timer_sixty_seconds,jugment,jugment_1,rst_jug,rst_door_control,input_temp;//�������е�״̬����λ�ź�
    reg[3:0] inside_request_out;//�ڲ�����
    reg[5:0] outside_request_out;//�ⲿ����
    parameter S0 = 5'b00001, S1 = 5'b00010, S2 = 5'b00100, S3 = 5'b01000, S4 = 5'b10000;
	//motion_state 00��ֹ��01������10�½�
    always @ (negedge clk,negedge rst)
        begin
            $monitor($time," inside_request=%b,outside_request=%b,state=%b",inside_request,outside_request,state);	
            if (~rst)
				begin//��λ
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
					outside_request_out <= outside_request;//***��ֹ��������ʱ������źű���©
				end
			else
            begin
                case (state)
					S0://״̬0:����ֹͣ��1¥
						begin
							if (inside_request[0] == 1'b1 | outside_request[0] == 1'b1)//��⵽�����ڲ�����1¥�����ߵ����ⲿ����1¥��
								begin
									inside_request_out = inside_request & 4'b1110;//��������ڲ�1¥�������ź�
									outside_request_out = outside_request & 6'b111110;//��������ⲿ1¥��¥�������ź�
									jugment = 1'b1;//�ж��Ƿ���
								end
							else if (jugment)//�ò�����ڲ������ⲿ����¥��������
								begin
									inside_request_out <= inside_request;
									outside_request_out <= outside_request;//***��ֹ��������ʱ������źű���©
									input_temp = 1'b0;
									rst_door_control = 1'b1;//������ݿ���ģ��
									if (jug)//�����ŷ����ѹغ���
										begin
											rst_door_control = 1'b0;
											jugment = 1'b0;//�Ѿ�����һ����
										end
								end
							else
								begin
									inside_request_out = inside_request & 4'b1110;
									outside_request_out = outside_request & 6'b111110;
									floor <= 2'b00;//���ݲ���Ϊ1
									if (inside_request_out == 4'b0000 & outside_request_out == 6'b000000)//���û���κ�����
										begin
											input_temp = 1'b1;//�������Ϊ�ر�״̬
											rst_door_control = 1'b1;//ʹ�ܵ�����
											motion_state <= 2'b00;//״̬��Ϊ��ֹ
											state <= S0;//״̬��Ϊ0
										end
									else//���ϲ�����󣬵�������
										begin
											rst_door_control = 1'b0;//��λ������
											motion_state <= 2'b01;//״̬��Ϊ����
											state <= S1;//״̬��תΪ1
										end
								end
						end
					S1://״̬1:����������������������
						begin
							inside_request_out <= inside_request;
							outside_request_out <= outside_request;//***��ֹ��������ʱ������źű���©
							rst_timer_three_seconds <= 1'b1;//ʹ�������ʱ��
							if (timer_three_seconds == 1'b1)//����ʱ������ź�Ϊ1ʱ
								begin
									rst_timer_three_seconds <= 1'b0;//��ʱ��ֹͣ��ʱ
									motion_state <= 2'b00;//״̬��Ϊ��ֹ
									floor <= floor + 1;//¥�������1
									state <= S3;//תΪ״̬3
								end                                                             
						end
					S2://״̬2:�����½���������������
						begin
							inside_request_out <= inside_request;
							outside_request_out <= outside_request;//***��ֹ��������ʱ������źű���©
							motion_state <= 2'b10;//״̬��Ϊ�½�
							rst_timer_three_seconds <= 1'b1;//��ʼ��ʱ
							if (timer_three_seconds == 1'b1)//����ʱ������ź�Ϊ1ʱ
								begin
									rst_timer_three_seconds <= 1'b0;//��ʱ��ֹͣ��ʱ
									floor = floor - 1;//¥�������1
									if (floor == 2'b00)//��¥�����Ϊ1¥ʱ
										begin
											motion_state <= 2'b00;//�˶�״̬Ϊ��ֹ
											state <= S0;//ת��Ϊ״̬0
										end
									else
										begin
											motion_state <= 2'b00;//״̬��Ϊ��ֹ
											state <= S4;//����ת��Ϊ״̬4
										end
								end
						end
					S3://״̬3:���ݸո�������ĳ��
						begin
							if(floor == 2'b01)//�����ݲ���Ϊ2ʱ**********************************************
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
													rst_timer_three_seconds <= 1'b0;//��ʱ��ֹͣ��ʱ
													floor = floor - 1;//¥�������1
													if (floor == 2'b00)//��¥�����Ϊ1¥ʱ
														begin
															motion_state <= 2'b00;//�˶�״̬Ϊ��ֹ
															stop <= 1'b0;
															state <= S0;//ת��Ϊ״̬0
														end
												end
										end
									else
										begin
											if (outside_request[2] == 1'b1)//�����ⲿ����ȥ������
												jugment_1 = 1'b1;
											if (inside_request[1] == 1'b1 | outside_request[1] == 1'b1)
												begin
													inside_request_out = inside_request & 4'b1101;//��������ڲ�2¥�������ź�
													outside_request_out = outside_request & 6'b111101;//��������ⲿ2¥��¥�������ź�
													jugment = 1'b1;
												end
											else if (jugment)//�ò�����ڲ������ⲿ����¥������
												begin
													inside_request_out <= inside_request;
													outside_request_out <= outside_request;//***��ֹ��������ʱ������źű���©
													input_temp = 1'b0;
													rst_timer_sixty_seconds = 1'b0;
													rst_door_control = 1'b1;//������ݿ���ģ��
													if (jug)//�����Ѿ��غ���
														begin
															rst_door_control = 1'b0;
															jugment = 1'b0;//�Ѿ�����һ����
														end
												end
											else
												begin
													inside_request_out = inside_request & 4'b1101;//��������ڲ�2¥�������ź�
													if(inside_request_out >= 4'b0100 | outside_request_out >= 6'b001000)//���ϲ��������źŵ�ʱ��
														begin
															motion_state = 2'b01;
															jugment = 1'b0;
															jugment_1 = 1'b0;
															rst_door_control = 1'b0;
															state = S1;//��������
														end
													else if(inside_request_out == 4'b0001 | (outside_request_out & 6'b111001) == 6'b000001)//���ϲ������źţ����²��������ź�
														begin
															if (jugment_1)//�����ⲿ����ȥ������
																begin
																	outside_request_out = outside_request & 6'b111001;//��������ⲿ2¥��¥����¥�������ź�
																	input_temp = 1'b0;
																	rst_timer_sixty_seconds = 1'b0;
																	rst_door_control = 1'b1;//������ݿ���ģ��
																	if (jug)
																		begin
																			jugment_1 = 1'b0;//�ڶ��ο��Ž���
																			rst_door_control = 1'b0;
																		end
																end
															else
																begin
																	outside_request_out <= outside_request;//***��ֹ��������ʱ������źű���©
																	motion_state = 2'b10;
																	jugment = 1'b0;
																	jugment_1 = 1'b0;
																	rst_door_control = 1'b0;
																	state = S2;//�����½�
																end
														end
													else //�������ź�
														begin
															outside_request_out <= outside_request & 6'b111001;//��������ⲿ2¥��¥�Լ���¥�������ź�
															motion_state <= 2'b00;
															if (jugment_1)//��������ȥ������
																begin
																	input_temp = 1'b0;
																	rst_timer_sixty_seconds = 1'b0;
																	rst_door_control = 1'b1;//������ݿ���ģ��
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
																	state = S3;//�����ȴ��ź�
																end
														end
											end
										end
								end
							else if(floor == 2'b10)//���ݲ���Ϊ3ʱ***************************************
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
													rst_timer_three_seconds <= 1'b0;//��ʱ��ֹͣ��ʱ
													floor = floor - 1;//¥�������1
													if (floor == 2'b00)//��¥�����Ϊ1¥ʱ
														begin
															motion_state <= 2'b00;//�˶�״̬Ϊ��ֹ
															stop <= 1'b0;
															rst_door_control = 1'b0;
															state <= S0;//ת��Ϊ״̬0
														end
												end
										end
									else 
										begin
											if (outside_request[4] == 1'b1)
												jugment_1 = 1'b1;
											if (inside_request[2] == 1'b1 | outside_request[3] == 1'b1)
												begin
													inside_request_out = inside_request & 4'b1011;//��������ڲ�3¥�������ź�
													outside_request_out = outside_request & 6'b110111;//��������ⲿ3¥��¥�������ź�
													jugment = 1'b1;
												end
											else if (jugment)//�ò�����ڲ������ⲿ����¥��������
												begin
													inside_request_out <= inside_request;
													outside_request_out <= outside_request;//***��ֹ��������ʱ������źű���©
													rst_timer_sixty_seconds = 1'b0;
													input_temp = 1'b0;
													rst_door_control = 1'b1;//������ݿ���ģ��
													if (jug)//�����Ѿ��غ���
														begin
															rst_door_control = 1'b0;
															jugment = 1'b0;//�Ѿ�����һ����
														end
												end
											else
												begin
													inside_request_out = inside_request & 4'b1011;//��������ڲ�3¥�������ź�
													if(inside_request_out >= 4'b1000 | outside_request_out >= 6'b100000)//���ϲ��������źŵ�ʱ��
														begin
															motion_state = 2'b01;
															jugment = 1'b0;
															jugment_1 = 1'b0;
															rst_door_control = 1'b0;
															state = S1;//��������
														end
													else if(inside_request_out > 4'b0000 | (outside_request_out & 6'b100111) > 6'b000000)//���ϲ������źţ����²������ź�
														begin
															if (jugment_1)//��������ȥ������
																begin
																	rst_timer_sixty_seconds = 1'b0;
																	outside_request_out = outside_request & 6'b100111;//��������ⲿ3¥��¥����¥�������ź�
																	input_temp = 1'b0;
																	rst_door_control = 1'b1;//������ݿ���ģ��
																	if (jug)//�ڶ��ο���
																		begin
																			jugment_1 = 1'b0;//�ڶ��ο��Ž���
																			rst_door_control = 1'b0;
																		end
																end
															else
																begin
																	outside_request_out = outside_request;//***��ֹ��������ʱ������źű���©
																	motion_state = 2'b10;
																	jugment = 1'b0;
																	jugment_1 = 1'b0;
																	rst_door_control = 1'b0;
																	state = S2;//�����½�
																end
														end
													else 
														begin
															outside_request_out = outside_request & 6'b100111;//��������ⲿ3¥��¥�Լ���¥�������ź�
															motion_state = 2'b00;
															if (jugment_1)//��������ȥ������
																begin
																	rst_timer_sixty_seconds = 1'b0;
																	input_temp = 1'b0;
																	rst_door_control = 1'b1;//������ݿ���ģ��
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
																	state = S3;//�����ȴ��ź�
																end
														end
												end
										end
								end//***********************************************************************************                                                
							else//���ݲ���Ϊ4ʱ*******************************************************************************
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
													rst_timer_three_seconds <= 1'b0;//��ʱ��ֹͣ��ʱ
													floor = floor - 1;//¥�������1
													if (floor == 2'b00)//��¥�����Ϊ1¥ʱ
														begin
															motion_state <= 2'b00;//�˶�״̬Ϊ��ֹ
															stop <= 1'b0;
															state <= S0;//ת��Ϊ״̬0
														end
												end
										end
									else
										begin
											if (inside_request[3] == 1'b1 | outside_request[5] == 1'b1)
												begin
													inside_request_out = inside_request & 4'b0111;//��������ڲ�4¥�������ź�
													outside_request_out = outside_request & 6'b011111;//��������ⲿ4¥��¥�������ź�
													jugment = 1'b1;
												end
											else if (jugment)//�ò�����ڲ������ⲿ����¥��������
												begin
													rst_timer_sixty_seconds = 1'b0;
													inside_request_out = inside_request;
													outside_request_out = outside_request;//***��ֹ��������ʱ������źű���©
													input_temp = 1'b0;
													rst_door_control = 1'b1;//������ݿ���ģ��
													if (jug)//�����Ѿ��غ���
														begin
															rst_door_control = 1'b0;
															jugment = 1'b0;//�Ѿ�����һ����
														end
												end
											else	
												begin
													inside_request_out = inside_request & 4'b0111;//��������ڲ�4¥�������ź�
													outside_request_out = outside_request & 6'b011111;//��������ⲿ4¥�������ź�
													if(inside_request_out > 4'b0000 | outside_request_out > 6'b000000)//���²��������ź�
														begin
															motion_state = 2'b10;
															jugment = 1'b0;
															rst_door_control = 1'b0;
															state = S2;//�����½�
														end
													else//�������ź�
														begin
															jugment = 1'b0;
															jugment_1 = 1'b0;
															input_temp = 1'b1;
															rst_door_control = 1'b1;//������ݿ���ģ��
															rst_timer_sixty_seconds = 1'b1;
															state = S3;//�����ȴ��ź�
														end
												end
										end
								end
						end
					S4://״̬4:���ݸո�������ĳ��************************************************
						begin
							if(floor == 2'b01)//���ݲ���Ϊ2
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
													rst_timer_three_seconds <= 1'b0;//��ʱ��ֹͣ��ʱ
													floor = floor - 1;//¥�������1
													if (floor == 2'b00)//��¥�����Ϊ1¥ʱ
														begin
															motion_state <= 2'b00;//�˶�״̬Ϊ��ֹ
															stop <= 1'b0;
															state <= S0;//ת��Ϊ״̬0
														end
												end
										end
									else
										begin
											if (outside_request[1] == 1'b1)
												jugment_1 = 1'b1;
											if (inside_request[1] == 1'b1 | outside_request[2] == 1'b1)
												begin
													inside_request_out = inside_request & 4'b1101;//��������ڲ�2¥�������ź�
													outside_request_out = outside_request & 6'b111011;//��������ⲿ2¥��¥�������ź�
													jugment = 1'b1;
												end
											else if (jugment)//�ò�����ڲ������ⲿ����¥������
												begin
													inside_request_out <= inside_request;
													outside_request_out <= outside_request;//***��ֹ��������ʱ������źű���©
													input_temp = 1'b0;
													rst_timer_sixty_seconds = 1'b0;
													rst_door_control = 1'b1;//������ݿ���ģ��
													if (jug)//�����Ѿ��غ���
														begin
															rst_door_control = 1'b0;
															jugment = 1'b0;//�Ѿ�����һ����
														end
												end
											else
												begin
													inside_request_out = inside_request & 4'b1101;//��������ڲ�2¥�������ź�
													//outside_request_out = outside_request & 6'b111011;//��������ⲿ2¥��¥�������ź�
													if( (inside_request_out & 4'b0001) == 4'b0001 | (outside_request_out & 6'b000001) == 6'b000001)//��1¥�������źŵ�ʱ��
														begin
															motion_state <= 2'b10;
															jugment = 1'b0;
															jugment_1 = 1'b0;
															rst_door_control = 1'b0;
															state <= S2;//�����½�
														end
													else if(inside_request_out >= 4'b0100 | outside_request_out >= 6'b0001000)//�ϲ��������źŵ�ʱ��
														begin
															if (jugment_1)//��������ȥ������
																begin
																	outside_request_out = outside_request & 6'b111001;//��������ⲿ2¥��¥����¥�������ź�
																	input_temp = 1'b0;
																	rst_timer_sixty_seconds = 1'b0;
																	rst_door_control = 1'b1;//������ݿ���ģ��
																	if (jug)//�ڶ��ο���
																		begin
																			jugment_1 = 1'b0;//�ڶ��ο��Ž���
																			rst_door_control = 1'b0;
																		end
																end
															else
																begin
																	outside_request_out <= outside_request;//***��ֹ��������ʱ������źű���©
																	motion_state <= 2'b01;
																	jugment = 1'b0;
																	jugment_1 = 1'b0;
																	rst_door_control = 1'b0;
																	state <= S1;//��������
																end
														end
													else//�������ź�
														begin
															outside_request_out <= outside_request & 6'b111001;//��������ⲿ2¥��¥�Լ���¥�������ź�
															motion_state <= 2'b00;
															if (jugment_1)//��������ȥ������
																begin
																	input_temp = 1'b0;
																	rst_timer_sixty_seconds = 1'b0;
																	rst_door_control = 1'b1;//������ݿ���ģ��
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
																	state = S4;//�����ȴ��ź�
																end
														end
												end
										end
								end
							else if(floor == 2'b10)//���ݲ���Ϊ3ʱ
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
													rst_timer_three_seconds <= 1'b0;//��ʱ��ֹͣ��ʱ
													floor = floor - 1;//¥�������1
													if (floor == 2'b00)//��¥�����Ϊ1¥ʱ
														begin
															motion_state <= 2'b00;//�˶�״̬Ϊ��ֹ
															stop <= 1'b0;
															state <= S0;//ת��Ϊ״̬0
														end
												end
										end
									else 
										begin
											if (outside_request[3] == 1'b1)
												jugment_1 = 1'b1;
											if (inside_request[2] == 1'b1 | outside_request[4] == 1'b1)
												begin
													inside_request_out = inside_request & 4'b1011;//��������ڲ�3¥�������ź�
													outside_request_out = outside_request & 6'b101111;//��������ⲿ3¥��¥�������ź�
													jugment = 1'b1;
												end
											else if (jugment)//�ò�����ڲ������ⲿ����¥��������
												begin
													rst_timer_sixty_seconds = 1'b0;
													inside_request_out <= inside_request;
													outside_request_out <= outside_request;//***��ֹ��������ʱ������źű���©
													input_temp = 1'b0;
													rst_door_control = 1'b1;//������ݿ���ģ��
													if (jug)//�����Ѿ��غ���
														begin
															rst_door_control = 1'b0;
															jugment = 1'b0;//�Ѿ�����һ����
														end
												end	
											else
												begin
													inside_request_out = inside_request & 4'b1011;//��������ڲ�3¥�������ź�
													//outside_request_out = outside_request & 6'b101111;//��������ⲿ3¥��¥�����ź�
													if( (inside_request_out & 4'b0011) > 4'b0000 | (outside_request_out & 6'b000111) > 6'b000000)//���²��������ź�
														begin
															motion_state <= 2'b10;
															jugment = 1'b0;
															jugment_1 = 1'b0;
															rst_door_control = 1'b0;
															state <= S2;//�����½�
														end
													else if(inside_request_out == 4'b1000 | (outside_request_out & 6'b100000) == 6'b100000)//���²������źţ����ϲ������ź�
														begin
															if (jugment_1)//��������ȥ������
																begin
																	rst_timer_sixty_seconds = 1'b0;
																	outside_request_out = outside_request & 6'b100111;//��������ⲿ3¥��¥����¥�����ź�
																	input_temp = 1'b0;
																	rst_door_control = 1'b1;//������ݿ���ģ��
																	if (jug)//�ڶ��ο���
																		begin
																			jugment_1 = 1'b0;//�ڶ��ο��Ž���
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
																	state = S1;//��������
																end
														end
													else//�������ź�
														begin
															outside_request_out = outside_request & 6'b100111;//��������ⲿ3¥��¥����¥�������ź�
															motion_state = 2'b00;
															if (jugment_1)//��������ȥ������
																begin
																	rst_timer_sixty_seconds = 1'b0;
																	input_temp = 1'b0;
																	rst_door_control = 1'b1;//������ݿ���ģ��
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
																	state = S4;//�����ȴ��ź�
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
