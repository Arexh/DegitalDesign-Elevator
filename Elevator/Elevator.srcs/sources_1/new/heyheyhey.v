`timescale 1ns / 1ps
module heyheyhey(
    input clk,rst,
    input[1:0] level,state,
	input[2:0] count,
    output reg[7:0] seg_out,seg_an
    );
	wire clk_out,clk_flash;
    Timer#(200000) fd(clk,rst,clk_out);
	Timer#(25000000) fd1(clk,rst,clk_flash);
    integer cnt;
	integer flash;
	
    parameter s0='hfe,
                s1='hfd,
                s2='hfb,
                s3='hf7,
                s4='hef,
                s5='hdf,
                s6='hbf,
                s7='h7f;
    wire [7:0] u[0:9],uUP,uDO,uL,uR,u_;
    assign u[0] = 8'b01000000,//0
            u[1]= 8'b01111001, // 1
            u[2] = 8'b00100100, // 2
            u[3] = 8'b00110000, // 3
            u[4] = 8'b00011001,//4
            u[5] = 8'b00010010,//5
            u[6] = 8'b00000010,//6
            u[7] = 8'b01111000,//7
            u[8] = 8'b00000000,//8
            u[9] = 8'b00010000,//9
            uL =   8'b11001111,
			uR =   8'b11111001,
			u_ =   8'b10111111,
			uUP =  8'b11011100|(flash==0?'b11_011_111:(flash==1?'b11_111_110:'b11_111_101)),
			uDO =  8'b11100011|(flash==0?'b11_101_111:(flash==1?'b11_110_111:'b11_111_011));
    
	
    always@(posedge clk_out,negedge rst) begin
        if (!rst) begin
			cnt<=0;
		end
        else begin
            if (cnt=='d7) cnt<=0;
            else cnt<=cnt+1;
			
        end
    end
	always@(posedge clk_flash,negedge rst) begin
		if (!rst) flash<=0;
		else 
			if (flash=='d2) flash<=0;
			else flash=flash+1;
	end
	
    always @(posedge clk_out) begin
        case(cnt)
            'd0:seg_an=s0;
            'd1:seg_an=s1;
            'd2:seg_an=s2;
            'd3:seg_an=s3;
            'd4:seg_an=s4;
            'd5:seg_an=s5;
            'd6:seg_an=s6;
            'd7:seg_an=s7;
            default: seg_an='hff;
            endcase
    end
    
    always @(posedge clk_out) begin
            case (cnt)
                'd0: begin
                    seg_out<=u[level+1];
                end
                'd1: begin
                    if (state=='b00) seg_out<='hff;
					else if (state=='b01) seg_out<=uUP;
					else seg_out<=uDO;
                end
                'd2: begin
					if (state!='b00 || count<'d4) seg_out<=u_;
					else seg_out<=(count==4?uL:uR);
				end
                'd3: begin
                    if (state!='b00 || count<'d2) seg_out<=u_;
                    else if (count>'d3) seg_out<='hff;
					else seg_out<=(count==2?uL:uR);
                end
                'd4: begin
                    if (state!='b00) seg_out<=uL;
                    else if (count>'d1) seg_out<='hff;
					else seg_out<=(count==0?uL:uR);
                end
                'd5: begin
                    if (state!='b00) seg_out<=uR;
                    else if (count>'d1) seg_out<='hff;
					else seg_out<=(count==0?uR:uL);
                end
                'd6: begin
                    if (state!='b00 ||  count<'d2) seg_out<=u_;
                    else if (count>'d3) seg_out<='hff;
					else seg_out<=(count==2?uR:uL);
                end
                'd7: begin
                    if (state!='b00 || count<'d4) seg_out<=u_;
					else seg_out<=(count==4?uR:uL);
                end
                default: seg_out<=u_;
            endcase
        end
    
endmodule
