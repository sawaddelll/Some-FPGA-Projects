// linear feedback shift register for randomization 
module LFSR (clk, reset, random);
 input logic clk, reset;
 output logic [9:0] random;
 logic d0, q1, q2, q3, q4, q5, q6, q7, q8, q9, q10; //10, 7 should be xnored

 
 always_ff @(posedge clk) begin
	if (!reset) begin 
		random = 10'b0000000000;
		q1 <= 0;
		q2 <= 0;
		q3 <= 0;
		q4 <= 0;
		q5 <= 0;
		q6 <= 0;
		q7 <= 0;
		q8 <= 0;
		q9 <= 0;
		q10 <= 0;
	end 
   else begin 
		/* random[9] <= q10;
		random[8] <= q9;
		random[7] <= q8;
		random[6] <= q7;
		random[5] <= q6;
		random[4] <= q5;
		random[3] <= q4;
		random[2] <= q3;
		random[1] <= q2;
		random[0] <= q1; */
		random <= {q10, q9, q8, q7, q6, q5, q4, q3, q2, q1};
		q1 <= d0; 
		q2 <= q1;
		q3 <= q2;
		q4 <= q3;
		q5 <= q4;
		q6 <= q5;
		q7 <= q6;
		q8 <= q7;
		q9 <= q8;
		q10 <= q9;
	end
 end 
  
 assign d0 = (random[6] & random[9]) | ((~random[6]) & (~random[9]));

 endmodule 
 
 module LFSR_testbench();
 logic clk, reset;
 logic [9:0] random;

 LFSR dut (.clk(clk), .reset(reset), .random(random));

 // Set up the clock.
 parameter CLOCK_PERIOD=100;
 initial begin
 clk <= 0;
 forever #(CLOCK_PERIOD/2) clk <= ~clk;
 end

 // Set up the inputs to the design. Each line is a clock cycle.
 initial begin
 @(posedge clk); reset = 1;
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
 @(posedge clk); reset = 0;
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
 @(posedge clk);
 @(posedge clk);
 @(posedge clk);
 @(posedge clk);

 $stop; // End the simulation.
 end
endmodule 
 