// EE469

`timescale 1ns/10ps

// MUX takes array of 32 64-bit values, selects 1 64-bit value to output

module MUX32by64_64 #(parameter WIDTH = 64) (regout, sel, out);
	input logic [31:0][63:0]regout;
	input logic [4:0] sel;
	output logic [63:0] out;
	logic [63:0][31:0]NEWregout;
	
	genvar k, j;
	generate 
		for(k=0; k<64; k++) begin : SwapEm
			for(j=0; j<32; j++) begin : good
			assign NEWregout[k][j] = regout[j][k];
			end
			end
		endgenerate
	
	
	
	
	genvar i; 
	generate     
		for(i=0; i<WIDTH; i++) begin : eachMUX       
			MUX32_1 mux32_1 (.in(NEWregout[i][31:0]), .sel, .out(out[i])); 
		end   
	endgenerate 
	
endmodule 