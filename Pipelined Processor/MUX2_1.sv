`timescale 1ns/10ps

// MUX between 2 1-bit inputs

module MUX2_1 (a, b, sel,/* clk,*/ out);   
	output logic  out;   
	input  logic  a, b, sel;   
	logic i_a, i_b, not_sel; //intermediate a and b
	parameter DELAY = 0.05;
	
	
	not #DELAY negateSel (not_sel, sel);
	and #DELAY ANDa (i_a, a, not_sel);
	and #DELAY ANDb (i_b, b, sel);
	or  #DELAY OR4out (out, i_a, i_b); //out = (b & sel) | (a & ~sel); a is output when sel is 0, b when sel is 1
	
endmodule 


module MUX2_1_testbench();
 logic i0, i1, sel;
 logic out;

 MUX2_1 dut (.a(i0), .b(i1), .sel, .out);

 initial begin
	 sel=0; i0=0; i1=0; #10;
	 sel=0; i0=0; i1=1; #10;
	 sel=0; i0=1; i1=0; #10;
	 sel=0; i0=1; i1=1; #10;
	 sel=1; i0=0; i1=0; #10;
	 sel=1; i0=0; i1=1; #10;
	 sel=1; i0=1; i1=0; #10;
	 sel=1; i0=1; i1=1; #10;
 end
 
endmodule 