`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/22 15:42:04
// Design Name: 
// Module Name: Buzzer
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


`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/22 15:02:26
// Design Name: 
// Module Name: buzzer
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
module Buzzer
	(
		rst,
		clk,
		beep
	);
	input clk,rst;
	output beep;
	reg beep;
	wire clk;
	reg [15:0] cnt;
	reg [15:0] PreDiv;//每个音调需要分频的系数
	reg [12:0] Delay;//每个音调持续的时间		
	reg [0:0] jug;
	always @ (negedge rst or posedge clk)
		if(!rst)
			begin
                beep<=1'b0;
                cnt<=13'd0;
                Delay<=13'd0;
                PreDiv<=16'h2F74;//音调7
                jug<=1'b0;
			end
		else
		begin
            cnt<=cnt+1'b1;
            if (cnt >= PreDiv & ~jug)
                begin
                beep<=~beep;
                cnt<=16'd0;
                Delay<=Delay+1'd1;
                case(Delay)   //进行音调的切换
                    13'd1000:PreDiv<=16'h2F74;//7
                    13'd2000:PreDiv<=16'h2F74;//7
                    13'd3000:PreDiv<=16'h2F74;//7
                    13'd4000:PreDiv<=16'h3BCA;//5
                    13'd5000:PreDiv<=16'h3BCA;//5
                    13'd6000:PreDiv<=16'h3BCA;//5
                    13'd7000:PreDiv<=16'h3BCA;//5
                    13'd8000:    
                    begin
                        jug <= 1'b1;
                        PreDiv<=16'h5997;//音调1
                     end
                endcase
             end
    end
endmodule