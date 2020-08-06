// EE469

`timescale 1ns/10ps

// MUX that selects between 2 64-bit inputs (by default) for one 64-bit output.
// The width of the inputs/output can be adjusted
module MUX2by64_64 #(parameter WIDTH = 64) (regA, regB, sel, out);
	input logic [WIDTH - 1:0] regA, regB;
	input logic sel;
	output logic [WIDTH - 1:0] out;
	
	genvar i; 
	generate     
		for(i=0; i<WIDTH; i++) begin : eachbitMUX       
			MUX2_1 mux2_1 (.a(regA[i]), .b(regB[i]), .sel, .out(out[i]));
		end   
	endgenerate 
	
endmodule 