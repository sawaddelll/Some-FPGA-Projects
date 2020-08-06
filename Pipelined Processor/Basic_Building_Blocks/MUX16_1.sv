
// MUX outputs 1 selected bit of 16-bit input

module MUX16_1 (in, sel, out);   
	output logic  out;   
	input  logic [15:0] in;  
	input logic [3:0] sel;	 
   logic  [3:0] o_i; //intermediate outputs of the 4 mux4_1, before output of final mux
	genvar i; 
	generate     
		for(i=0; i<4; i++) begin : each_mux16_1       
			MUX4_1 mux4_1 (.a(in[(4*i) +3 : 4*i]), .sel(sel[1:0]), /* clk,*/ .out(o_i[i]));     
		end   
	endgenerate 
	
	//generate statement achieves the following: 
	//MUX4_1 mux4_1 (.a(in[3:0]), .sel(sel[1:0]), .out(o_i[0])); 
	//MUX4_1 mux4_1 (.a(in[7:4]), .sel(sel[1:0]), .out(o_i[1])); 
	//MUX4_1 mux4_1 (.a(in[11:8]), .sel(sel[1:0]), .out(o_i[2])); 
	//MUX4_1 mux4_1 (.a(in[15:12]), .sel(sel[1:0]), .out(o_i[3])); 
	
	MUX4_1 lastmux (.a(o_i), .sel(sel[3:2]), .out(out));
	
endmodule 


module MUX16_1_testbench();
 logic [15:0] in;
 logic [3:0] sel;
 logic out;
 
 MUX16_1 dut (.in, .sel, .out);
 
 integer i, j;
 initial 
 begin
 
	for (j = 0; j < 16; j = j + 1) begin
		sel = j; 
		for (i = 0; i < 65536; i = i + 1) begin 
			in = i; #10;
		end
	end
	
 end
 
endmodule 