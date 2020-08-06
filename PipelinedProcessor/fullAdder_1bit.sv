`timescale 1ns/10ps

// 1-bit adder with carry-in and carry-out signals.

module fullAdder_1bit (a, b, cIn, cOut, s );   
	output logic  s, cOut;   
	input  logic  a, b, cIn;   
	logic ab, bc, ac; //AND results of a, b, cIn;
	parameter DELAY = 0.05;
	
	
	and #DELAY andAB (ab, a, b);
	and #DELAY andBC (bc, b, cIn);
	and #DELAY andAC (ac, a, cIn);
	
	// or1 and following 2 OR gates are used to get cOut from 2-input gates
	// logic or1;                           
	// or #DELAY firstOR (or1, ab, bc);     //
	// or #DELAY cOutResult (cOut, or1, ac);// 
	
	
	or  #DELAY cOutResult (cOut, ab, bc, ac); //cOut from 1 OR gate w/ 3 inputs
	
	xor #DELAY sumResult (s, a, b, cIn);
	
	
endmodule 


module fullAdder_1bit_testbench();
 logic a, b, cIn, cOut, s;

 fullAdder_1bit dut (.a, .b, .cIn, .cOut, .s);

 initial begin
	 a = 0; b = 0; cIn = 0; #10;
	 a = 0; b = 1; cIn = 0; #10;
	 a = 1; b = 0; cIn = 0; #10;
	 a = 1; b = 1; cIn = 0; #10;
	 a = 0; b = 0; cIn = 1; #10;
	 a = 0; b = 1; cIn = 1; #10;
	 a = 1; b = 0; cIn = 1; #10;
	 a = 1; b = 1; cIn = 1; #10;
 end
 
endmodule 