// EE469 LAB2

`timescale 1ns/10ps

//1-bit ALU with carry-in and carry-out
//Based on ctrl input, can do add, subtract, and, or, xor, or pass through b input
module ALU_1bit (a, b, cIn, cOut, ctrl, out);
	input logic a, b, cIn;
	input logic [2:0] ctrl;
	output logic cOut, out;
	parameter DELAY = 0.05;
	
	logic sum, ANDresult, ORresult, XORresult;
	logic adderBinput;
	logic notB;
	
	not #DELAY negateB (notB, b);
	
	MUX2_1 forSubtraction (.a(b), .b(notB), .sel(ctrl[0]), .out(adderBinput)); //B goes into Adder if subtraction (ctrl[0]) is false; for subtraction, use not(B)
	
	fullAdder_1bit adder (.a, .b(adderBinput), .cIn, .cOut, .s(sum));
	
	and #DELAY andInputs (ANDresult, a, b);
	or #DELAY orInputs (ORresult, a, b);
	xor #DELAY xorInputs (XORresult, a, b);
	
	logic [7:0] finalMUXinput ;

	assign finalMUXinput = {1'b0, XORresult, ORresult, ANDresult, sum, sum, 1'b0, b};
	
	MUX8_1 selectingOutput ( .in(finalMUXinput), .sel(ctrl), .out(out));
	
endmodule

module ALU_1bit_testbench();
 logic a, b, cIn, cOut, out;
 logic [2:0] ctrl;

 ALU_1bit dut (.a, .b, .cIn, .cOut, .ctrl, .out);

 initial begin
 
    ctrl = 3'b000; //#10;
	 a = 0; b = 0; cIn = 0; #10;
	 a = 0; b = 1; cIn = 0; #10;
	 a = 1; b = 0; cIn = 0; #10;
	 a = 1; b = 1; cIn = 0; #10;
	 a = 0; b = 0; cIn = 1; #10;
	 a = 0; b = 1; cIn = 1; #10;
	 a = 1; b = 0; cIn = 1; #10;
	 a = 1; b = 1; cIn = 1; #10;
	 ctrl = 3'b010; //#10;
	 a <= 0; b <= 0; cIn <= 0; #20;
	 a <= 0; b <= 1; cIn <= 0; #20; ///////
	 a <= 1; b <= 0; cIn <= 0; #20;
	 a <= 1; b <= 1; cIn <= 0; #20;
	 a <= 0; b <= 0; cIn <= 1; #20;
	 a <= 0; b <= 1; cIn <= 1; #20; //
	 a <= 1; b <= 0; cIn <= 1; #20; //
	 a <= 1; b <= 1; cIn <= 1; #20;
	 ctrl = 3'b011; //#10;
	 a = 0; b = 0; cIn = 0; #10;
	 a = 0; b = 1; cIn = 0; #10;
	 a = 1; b = 0; cIn = 0; #10;
	 a = 1; b = 1; cIn = 0; #10;
	 a = 0; b = 0; cIn = 1; #10;
	 a = 0; b = 1; cIn = 1; #10;
	 a = 1; b = 0; cIn = 1; #10;
	 a = 1; b = 1; cIn = 1; #10;
	 ctrl = 3'b100; //#10;
	 a = 0; b = 0; cIn = 0; #10;
	 a = 0; b = 1; cIn = 0; #10;
	 a = 1; b = 0; cIn = 0; #10;
	 a = 1; b = 1; cIn = 0; #10;
	 a = 0; b = 0; cIn = 1; #10;
	 a = 0; b = 1; cIn = 1; #10;
	 a = 1; b = 0; cIn = 1; #10;
	 a = 1; b = 1; cIn = 1; #10;
	 ctrl = 3'b101;// #10;
	 a = 0; b = 0; cIn = 0; #10;
	 a = 0; b = 1; cIn = 0; #10;
	 a = 1; b = 0; cIn = 0; #10;
	 a = 1; b = 1; cIn = 0; #10;
	 a = 0; b = 0; cIn = 1; #10;
	 a = 0; b = 1; cIn = 1; #10;
	 a = 1; b = 0; cIn = 1; #10;
	 a = 1; b = 1; cIn = 1; #10;
	 ctrl = 3'b110;// #10;
	 a = 0; b = 0; cIn = 0; #10;
	 a = 0; b = 1; cIn = 0; #10;
	 a = 1; b = 0; cIn = 0; #10;
	 a = 1; b = 1; cIn = 0; #10;
	 a = 0; b = 0; cIn = 1; #10;
	 a = 0; b = 1; cIn = 1; #10;
	 a = 1; b = 0; cIn = 1; #10;
	 a = 1; b = 1; cIn = 1; #10;
	 ctrl = 3'b001;// #10;
	 a = 0; b = 0; cIn = 0; #10;
	 a = 0; b = 1; cIn = 0; #10;
	 a = 1; b = 0; cIn = 0; #10;
	 a = 1; b = 1; cIn = 0; #10;
	 a = 0; b = 0; cIn = 1; #10;
	 a = 0; b = 1; cIn = 1; #10;
	 a = 1; b = 0; cIn = 1; #10;
	 a = 1; b = 1; cIn = 1; #10;
	 ctrl = 3'b111; //#10;
	 a = 0; b = 0; cIn = 0; #10;
	 a = 0; b = 1; cIn = 0; #10;
	 a = 1; b = 0; cIn = 0; #10;
	 a = 1; b = 1; cIn = 0; #10;
	 a = 0; b = 0; cIn = 1; #10;
	 a = 0; b = 1; cIn = 1; #10;
	 a = 1; b = 0; cIn = 1; #10;
	 a = 1; b = 1; cIn = 1; #10;
	 ctrl = 3'b000; //#10;
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