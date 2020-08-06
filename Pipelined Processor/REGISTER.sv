`timescale 1ns/10ps

//basic register with default width of 64 bits (i.e. 64 bit DFF)

module REGISTER #(parameter WIDTH=64) (q, d, enable, clk);   
	output logic  [WIDTH-1:0]  q;   
	input  logic  [WIDTH-1:0]  d;   
	input  logic               enable, clk; 

	genvar i; 
	generate     
		for(i=0; i<WIDTH; i++) begin : ind_Dff       
			D_FF_enable enabledDFF (.q(q[i]),  .d(d[i]), .enable,  .clk);  //make this DFF and MUX2_1
			
		end   
	endgenerate 
	
endmodule 