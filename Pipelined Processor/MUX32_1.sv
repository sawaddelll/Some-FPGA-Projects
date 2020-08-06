// MUX selects 1-bit of 32-bit input.

module MUX32_1 (in, sel, out);   
	output logic  out;   
	input  logic [31:0] in;  
	input logic [4:0] sel;	
   logic  [1:0] o_i;//intermediate outputs of the 2 mux16_1, before output of final mux
	
	MUX16_1 muxfor_X0to15 (.in(in[15:0]), .sel(sel[3:0]), .out(o_i[0]));
	MUX16_1 muxfor_X16to31 (.in(in[31:16]), .sel(sel[3:0]), .out(o_i[1]));
	
	MUX2_1 lastmux (.a(o_i[0]), .b(o_i[1]), .sel(sel[4]), .out(out));
	
endmodule 


module MUX32_1_testbench();
 logic [31:0] in;
 logic [4:0] sel;
 logic out;
 
 MUX32_1 dut (.in, .sel, .out);
 
 integer i, j;
 initial 
 begin
    in = 0;
	for (j = 0; j < 32; j = j + 1) begin
		sel = j; 
		for (i = 0; i < 65536; i = i + 1) begin 
			in[15:0] = i; #10;
		end
		in[j] = 1; #20;
		in[j] = 0; #10;
		in[j] = 1; #10;
	end
	
 end
 
endmodule 