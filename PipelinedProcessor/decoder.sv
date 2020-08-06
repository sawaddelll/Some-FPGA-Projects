`timescale 1ns/10ps

// 3-bit input decoded to 8-bit output (e.g. 010 --> 00000100; 100 --> 00010000)
module decoder_3to8 (in3, out8, en);
	input logic [2:0] in3; 
	input logic en;
	output logic [7:0] out8;
	parameter DELAY = 0.05;
	
	
	and #DELAY output1 (out8[0], ~in3[0],  ~in3[1], ~in3[2], en);
	and #DELAY output2 (out8[1],  in3[0],  ~in3[1], ~in3[2], en);
	and #DELAY output3 (out8[2], ~in3[0],   in3[1], ~in3[2], en);
	and #DELAY output4 (out8[3],  in3[0],   in3[1], ~in3[2], en);
	and #DELAY output5 (out8[4], ~in3[0],  ~in3[1],  in3[2], en);
	and #DELAY output6 (out8[5],  in3[0],  ~in3[1],  in3[2], en);
	and #DELAY output7 (out8[6], ~in3[0],   in3[1],  in3[2], en);
	and #DELAY output8 (out8[7],  in3[0],   in3[1],  in3[2], en);
	
	
	endmodule 
	
// decodes 4-bit input to 32-bit output
module decoder_5to32(in5, out32, enabler);
	input logic [4:0] in5;
	input logic enabler;
	output logic [31:0] out32;
	logic a, b, c, d;
	parameter DELAY = 0.05;

	and #DELAY logicA (a, ~in5[3], ~in5[4], enabler);
	and #DELAY logicB (b,  in5[3], ~in5[4], enabler);
	and #DELAY logicC (c, ~in5[3],  in5[4], enabler);
	and #DELAY logicD (d,  in5[3],  in5[4], enabler);
		
	
	decoder_3to8   one(.in3(in5[2:0]), .out8(out32[7:0]), .en(a));
	decoder_3to8   two(.in3(in5[2:0]), .out8(out32[15:8]), .en(b));
	decoder_3to8 three(.in3(in5[2:0]), .out8(out32[23:16]), .en(c));
	decoder_3to8  four(.in3(in5[2:0]), .out8(out32[31:24]), .en(d));
	
	endmodule
	
	
	
module decoder_5to32_testbench();
	logic [4:0] in5;
	logic enabler;
	logic [31:0] out32;
	logic a, b, c, d;
	
	decoder_5to32 dut (.in5, .out32, .enabler);
	
	initial begin
		
		integer i;
		enabler = 1;
		for(i = 0; i < 32; i++) begin
			in5 = i;
			#1;
		end
		
	end
endmodule 
		