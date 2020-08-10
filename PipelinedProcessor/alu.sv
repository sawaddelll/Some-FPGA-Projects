// EE469 LAB2

`timescale 1ns/10ps

//64-bit ALU, capable of add, sub, and, or, xor, or passing b input straight to output
//Along with result of operation, also outputs carry_out, overflow, negative, and zero flags (1-bit each).
module alu (A, B, ctrl, result, negative, zero, overflow, carry_out);
input logic [63:0] A, B;
input logic [2:0] ctrl;
output logic [63:0] result;
output logic negative, zero, overflow, carry_out;
logic [63:0] cOut, flag, out;
logic [64:0] cIn;
logic flag1, flag2, flag3, flag4;

parameter DELAY = 0.05;

assign cIn[0] = ctrl[0];

genvar i; 
	generate     
		for(i=0; i<64; i++) begin : adder       
	ALU_1bit adder (A[i], B[i], cIn[i], cOut[i], ctrl, out[i]);
	assign cIn[i+1] = cOut[i];
			
		end   
	endgenerate 

	xor #DELAY (overflow, cOut[63], cOut[62]);
	assign negative = out[63];
	
	genvar j; 
	generate     
		for(j=0; j<64; j = j + 4) begin : zeroFlags       
			nor #DELAY zero_flags (flag[j], out[j], out[j+1], out[j+2], out[j+3]); 

		end   
	endgenerate 
	
	and #DELAY zero_flag1 (flag1, flag[0],  flag[4],  flag[8],  flag[12]); 
	and #DELAY zero_flag2 (flag2, flag[16], flag[20], flag[24], flag[28]); 
	and #DELAY zero_flag3 (flag3, flag[32], flag[36], flag[40], flag[44]); 
	and #DELAY zero_flag4 (flag4, flag[48], flag[52], flag[56], flag[60]); 
	and #DELAY zero_flag6 (zero, flag1, flag2, flag3, flag4); 

	assign result = out;
	assign carry_out = cOut[63];

endmodule 


// Test bench for ALU

// Meaning of signals in and out of the ALU:

// Flags:
// negative: whether the result output is negative if interpreted as 2's comp.
// zero: whether the result output was a 64-bit zero.
// overflow: on an add or subtract, whether the computation overflowed if the inputs are interpreted as 2's comp.
// carry_out: on an add or subtract, whether the computation produced a carry-out.

// cntrl			Operation						Notes:
// 000:			result = B						value of overflow and carry_out unimportant
// 010:			result = A + B
// 011:			result = A - B
// 100:			result = bitwise A & B		value of overflow and carry_out unimportant
// 101:			result = bitwise A | B		value of overflow and carry_out unimportant
// 110:			result = bitwise A XOR B	value of overflow and carry_out unimportant

module alustim();

	parameter delay = 100000;

	logic		[63:0]	A, B;
	logic		[2:0]		cntrl;
	logic		[63:0]	result;
	logic					negative, zero, overflow, carry_out;

	parameter ALU_PASS_B=3'b000, ALU_ADD=3'b010, ALU_SUBTRACT=3'b011, ALU_AND=3'b100, ALU_OR=3'b101, ALU_XOR=3'b110;
	

	alu dut (.A, .B, .ctrl(cntrl), .result, .negative, .zero, .overflow, .carry_out);

	// Force %t's to print in a nice format.
	initial $timeformat(-9, 2, " ns", 10);

	integer i;
	logic [63:0] test_val;
	initial begin
	
		$display("%t testing PASS_A operations", $time);
		cntrl = ALU_PASS_B;
		for (i=0; i<100; i++) begin
			A = $random(); B = $random();
			#(delay);
			assert(result == B && negative == B[63] && zero == (B == '0));
		end
		
		$display("%t testing addition", $time);
		cntrl = ALU_ADD;
		A = 64'h0000000000000001; B = 64'h0000000000000001; // 1 + 1 = 2
		#(delay);
		assert(result == 64'h0000000000000002 && carry_out == 0 && overflow == 0 && negative == 0 && zero == 0);
		
		A = 64'hFFFFFFFFFFFFFFFF; B = 64'h0000000000000001; // -1 + 1 = 0
		#(delay);
		assert(result == 64'h0000000000000000 && carry_out == 1 && overflow == 0 && negative == 0 && zero == 1);
		
		A = 64'hFFFFFFFFFFFFFFFF; B = 64'hFFFFFFFFFFFFFFFF;  // -1 + -1 = -2
		#(delay);
		assert(result == 64'hFFFFFFFFFFFFFFFE && carry_out == 1 && overflow == 0 && negative == 1 && zero == 0);
		
		A = 64'h7FFFFFFFFFFFFFFF; B = 64'h7FFFFFFFFFFFFFFF;  // overflow
		       
		#(delay);
		assert(result == 64'hFFFFFFFFFFFFFFFE && carry_out == 0 && overflow == 1 && negative == 1 && zero == 0);
		
		for (i=0; i<10; i++) begin
			A = $random(); B = $random();
			#(delay);
			end
			
		$display("%t testing subtraction", $time);
		cntrl = ALU_SUBTRACT;
		A = 64'h0000000000000001; B = 64'h0000000000000001; // 1 - 1 = 0
		#(delay);
		
		A = 64'hFFFFFFFFFFFFFFFF; B = 64'h0000000000000001; // -1 - 1 = -2
		#(delay);
		
		A = 64'hFFFFFFFFFFFFFFFF; B = 64'hFFFFFFFFFFFFFFFF;  // -1 - -1 = 0
		#(delay);
		
		A = 64'h7FFFFFFFFFFFFFFF; B = 64'h7FFFFFFFFFFFFFFF;  // 0
		#(delay);
		
		A = 64'h7FFFFFFFFFFFFFFF; B = 64'h0000000000000000;  // large# - 0 = large positive
		#(delay);
		
		A = 64'h0000000000000000; B = 64'h7FFFFFFFFFFFFFFF;  // 0 - large# = large negative
		#(delay);
		
		A = 64'hFFFFFFFFFFFFFFFF; B = 64'hFFFFFFFFFFFFFFFD;  // -1 - -3 = 2
		#(delay);
		
		A = 64'h0000000000000001; B = 64'h0000000000000003;  // 1 - 3 = 2
		#(delay);
		
		for (i=0; i<10; i++) begin
			A = $random(); B = $random();
			#(delay);
			end
			
		$display("%t testing AND gate", $time);
		cntrl = ALU_AND;
		A = 64'h0000000000000001; B = 64'h0000000000000001; 
		#(delay);
		
		A = 64'hFFFFFFFFFFFFFFFF; B = 64'h0000000000000000; 
		#(delay);
		
		A = 64'h0000000000000000; B = 64'h0000000000000000;  
		#(delay);
		
		A = 64'h7FFFFFFFFFFFFFFF; B = 64'h7FFFFFFFFFFFFFFF; 
		#(delay);
		
		A = 64'hFFFFFFFFFFFFFFFF; B = 64'hFFFFFFFF0FFFFFFF; 
		#(delay);
		
		for (i=0; i<10; i++) begin
			A = $random(); B = $random();
			#(delay);
			end
			
	$display("%t testing OR gate", $time);
		cntrl = ALU_OR;
		A = 64'h0000000000000001; B = 64'h0000000000000001; 
		#(delay);
		
		A = 64'hFFFFFFFFFFFFFFFF; B = 64'h0000000000000000; 
		#(delay);
		
		A = 64'h0000000000000000; B = 64'h0000000000000000;  
		#(delay);
		
		A = 64'h7FFFFFFFFFFFFFFF; B = 64'h7FFFFFFFFFFFFFFF; 
		#(delay);
		
		A = 64'hFFFFFFFFFFFFFFFF; B = 64'hFFFFFFFF0FFFFFFF; 
		#(delay);
		
		for (i=0; i<10; i++) begin
			A = $random(); B = $random();
			#(delay);
			end
			
	$display("%t testing XOR gate", $time);
		cntrl = ALU_XOR;
		A = 64'h0000000000000001; B = 64'h0000000000000001; 
		#(delay);
		
		A = 64'hFFFFFFFFFFFFFFFF; B = 64'h0000000000000000; 
		#(delay);
		
		A = 64'h0000000000000000; B = 64'h0000000000000000;  
		#(delay);
		
		A = 64'h7FFFFFFFFFFFFFFF; B = 64'h7FFFFFFFFFFFFFFF; 
		#(delay);
		
		A = 64'hFFFFFFFFFFFFFFFF; B = 64'hFFFFFFFF0FFFFFFF; 
		#(delay);
		
		for (i=0; i<10; i++) begin
			A = $random(); B = $random();
			#(delay);
			end
		

	end
endmodule 
