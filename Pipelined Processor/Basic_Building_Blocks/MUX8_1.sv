`timescale 1ns/10ps

// MUX outputs 1 selected bit of 8-bit input

module MUX8_1 (in, sel, out);   
	output logic  out;   
	input  logic [7:0] in;  
	input logic [2:0] sel;	
        logic  [1:0] o_i;//intermediate outputs of the 2 mux4_1, before output of final mux
	genvar i; 
	generate     
		for(i=0; i<2; i++) begin : each_mux16_1       
			MUX4_1 mux4_1 (.a(in[(4*i) +3 : 4*i]), .sel(sel[1:0]), .out(o_i[i]));     
		end   
	endgenerate 
	
	MUX2_1 lastmux (.a(o_i[0]), .b (o_i[1]), .sel(sel[2]), .out(out));
	
endmodule 


module MUX8_1_testbench();
 logic [7:0] in;
 logic [2:0] sel;
 logic out;
 
 MUX8_1 dut (.in, .sel, .out);
 
 integer i, j;
 initial 
 begin
 
	for (j = 0; j < 8; j = j + 1) begin
		sel = j; 
		for (i = 0; i < 256; i = i + 1) begin 
			in = i; #10;
		end
	end
	
 end
 
endmodule 