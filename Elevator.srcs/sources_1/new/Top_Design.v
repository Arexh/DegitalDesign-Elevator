`timescale 1ns / 1ps
module Top_Design(
    input           clk,
    input           rst,
    input      [3:0] row,                 // ¾ØÕó¼üÅÌ ĞĞ
    output     [3:0] col,                 // ¾ØÕó¼üÅÌ ÁĞ
    output     [7:0] seg_an,
    output     [7:0] seg_out,
	output [11:0] led,
	output beep
);
	
	wire[3:0] keyboard_val;
	wire flag;
    Key_Input KI(clk,rst,row,col,keyboard_val,flag);
	
	wire[2:0] count;
	wire[1:0] floor,state;
	heyheyhey HHH(clk,rst,floor,state,count,seg_out,seg_an);
	
	
	reg outside_button[1:6],inside_button[1:4];
	reg button_open,button_close;
	
	Main_Program MP(clk,rst,
		outside_button[1],outside_button[2],outside_button[3],
		outside_button[4],outside_button[5],outside_button[6],
		inside_button[1],inside_button[2],inside_button[3],inside_button[4],
		button_open,button_close,floor,state,count,beep
	);
	
	wire key_clk;
	Timer#(200000) fd(clk,rst,key_clk);
	
	always@(posedge key_clk) begin
	   {	outside_button[1],
			outside_button[2],
			outside_button[3],
			outside_button[4],
			outside_button[5],
			outside_button[6],
			inside_button[1],
			inside_button[2],
			inside_button[3],
			inside_button[4],
			button_open,
			button_close
        }='b0000_0000_0000;
		if (flag==1) begin
			case(keyboard_val)
				'h1: begin 
					inside_button[1]=1;
				end
				'h2: begin
					inside_button[2]=1;
				end
				'h3: begin
					inside_button[3]=1;
				end
				'h4: begin
					inside_button[4]=1;
				end
				'hb: begin
					button_open=1;
				end
				'hc: begin
					button_close=1;
				end
				'he: begin
					outside_button[1]=1;
				end
				'h8: begin
					outside_button[2]=1;//up
				end
				'h0: begin
					outside_button[3]=1;//down
				end
				'h9: begin
					outside_button[4]=1;//up
				end
				'hf: begin
					outside_button[5]=1;//down
				end
				'hd: begin
					outside_button[6]=1;
				end
				
			endcase
		end
	end
	
	assign led={	count[0],
			count[1],
			count[2],
			outside_button[4],
			outside_button[5],
			outside_button[6],
			inside_button[1],
			inside_button[2],
			inside_button[3],
			inside_button[4],
			button_open,
			button_close
        };
	
endmodule
