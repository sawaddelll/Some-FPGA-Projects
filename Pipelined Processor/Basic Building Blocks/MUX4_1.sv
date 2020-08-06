`timescale 1ns/10ps

// MUX between the 4 bits of the input, for 1-bit output

module MUX4_1 (a, sel, out);   
	output logic  out;   
	input  logic [3:0] a;  
	input logic [1:0] sel;	
   logic  [1:0] o_i;//intermediate outputs of the 2 mux2_1, before output of final mux
	genvar i; 
	generate     
		for(i=0; i<2; i++) begin : each_mux2_1       
			MUX2_1 mux2_1 (.a(a[i]), .b(a[i+2]), .sel(sel[1]), .out(o_i[i]));     
		end   
	endgenerate 
	
	MUX2_1 lastmux (.a(o_i[0]), .b(o_i[1]), .sel(sel[0]), .out(out));
	
endmodule 

module MUX4_1_testbench();
 logic [3:0] in;
 logic [1:0] sel;
 logic out;
 
 MUX4_1 dut (.a(in), .sel, .out);
 
 integer i;
 initial 
 begin
	sel = 2'b00; 
	for (i = 0; i <16; i = i + 1) begin 
		in = i; #10;
	end
	sel = 2'b01; 
	for (i = 0; i <16; i = i + 1) begin 
		in = i; #10;
	end
	sel = 2'b10; 
	for (i = 0; i <16; i = i + 1) begin 
		in = i; #10;
	end
	sel = 2'b11; 
	for (i = 0; i <16; i = i + 1) begin 
		in = i; #10;
   end
 end
 
endmodule 