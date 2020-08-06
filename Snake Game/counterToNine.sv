// counter from 0 to 9, that increments based on the incr input signal.
// Counting past 9 returns to 0, with a carryover_out signal to flag that 10 was hit
// Use multiple instantiations for a multi-digit counter for HEX displays.

module counterToNine (reset, clk,incr, out, carryover_out);
	input logic reset, clk, incr;
	output logic [3:0] out;
	output logic carryover_out;
	logic [3:0] ps, ns;
	enum {normal, carry_out} ps_carry, ns_carry;
	logic carryover;
	
	always_comb begin
		case (ps)
			4'b0000: begin ns = 4'b0001; out = 4'b0000; carryover = 0; end        // 0
			4'b0001: begin ns = 4'b0010; out = 4'b0001; carryover = 0; end        // 1
			4'b0010: begin ns = 4'b0011; out = 4'b0010; carryover = 0; end        // 2
			4'b0011: begin ns = 4'b0100; out = 4'b0011; carryover = 0; end        // 3
			4'b0100: begin ns = 4'b0101; out = 4'b0100; carryover = 0; end        // 4
			4'b0101: begin ns = 4'b0110; out = 4'b0101; carryover = 0; end        // 5
			4'b0110: begin ns = 4'b0111; out = 4'b0110; carryover = 0; end        // 6
			4'b0111: begin ns = 4'b1000; out = 4'b0111; carryover = 0; end        // 7
			4'b1000: begin ns = 4'b1001; out = 4'b1000; carryover = 0; end        // 8
			4'b1001: begin ns = 4'b0000; out = 4'b1001; carryover = 1; end        // 9
		default: out = 4'bX;                            
		endcase
	
		case (ps_carry)
			normal: if (carryover & incr) begin 
						carryover_out = 1; ns_carry = carry_out; end
					else  begin
						carryover_out = 0; ns_carry = normal; end
			
			carry_out: if (carryover) begin
								carryover_out = 0; ns_carry = carry_out; end
							else begin
								carryover_out = 0; ns_carry = normal;end 
		endcase 
		
	end 
	
	always_ff @(posedge clk) begin
		if (!reset) begin 
			ps <= 4'b0000;
			ps_carry <= normal; end 
		else if (incr) begin 
			ps <= ns; 
		ps_carry <= ns_carry; end
	end 

endmodule 

module counterToNine_testbench ();
 logic reset, clk, incr, carryover_out;
 logic [3:0] out;
 
 
 counterToNine dut (.reset, .clk, .incr, .out, .carryover_out);
 
 parameter CLOCK_PERIOD=100;
 initial begin
 clk <= 0;
 forever #(CLOCK_PERIOD/2) clk <= ~clk;
 end

 // Set up the inputs to the design. Each line is a clock cycle.
 initial begin
 @(posedge clk); reset <= 1; 
 @(posedge clk);
 @(posedge clk);
 @(posedge clk); reset <= 0; incr = 1; 
 @(posedge clk);
 @(posedge clk); 
 @(posedge clk); 
 @(posedge clk);  
 @(posedge clk); 
 @(posedge clk); 
 @(posedge clk); 
 @(posedge clk); incr = 0;
 @(posedge clk); 
 @(posedge clk);
 @(posedge clk);
 @(posedge clk); incr = 1;
 @(posedge clk);
 @(posedge clk);
 @(posedge clk);
 @(posedge clk);
 @(posedge clk);
 @(posedge clk);
 @(posedge clk);
 @(posedge clk);
 @(posedge clk);
 @(posedge clk);
 @(posedge clk);
 @(posedge clk);
 @(posedge clk); 
 @(posedge clk);
 @(posedge clk);
 @(posedge clk);
 @(posedge clk); 

 $stop;
 end
 
endmodule 