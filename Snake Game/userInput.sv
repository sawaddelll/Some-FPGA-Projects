// userInput takes in the clk and reset, and 4 button inputs for the 4 different directions the snake can move
// (these inputs are treated like KEYs). It outputs signals for each of the four directions (up, down, left, right).
// After dealing with metastability, the module takes the inputs and uses them to traverse a state machine that ensures
// only one output can be true at a time (so the snake can only be moving in one direction at a time), and that 
// the snake cannot reverse directions (go left when it was going right, etc.). The module resets to an initial state,
// where down must be pressed before any outputs are true, and then another button besides down (button4)
// must be pressed to start outputting directions (press button4 to start, but outputs won't be true until the next press
// that is not button4).
module userInput (clk, reset, button1, button2, button3, button4, out1, out2, out3, out4);
 input logic clk, reset, button1, button2, button3, button4;
 logic q1, q2, q3, q4, in1, in2, in3, in4;
 output logic out1, out2, out3, out4;
 enum { initial_state, not_pressed, goLeft, goRight, goUp, goDown } ps, ns;
 // 1 = left, 2 = right, 3 = up, 4 = down
 
 always_ff @(posedge clk) begin
	q1 <= button1;
	q2 <= button2;
	q3 <= button3;
	q4 <= button4;
 end
 
 always_ff @(posedge clk) begin
	in1 <= q1;
	in2 <= q2;
	in3 <= q3;
	in4 <= q4;
 end
 
 // Next State logic
 always_comb begin
 case (ps)
  initial_state: begin 
  					 out1 = 0;
					 out2 = 0;
					 out3 = 0;
					 out4 = 0;
					if (in3 & in2 & in1 & ~in4) begin
				    ns = not_pressed;
					 end
					 else begin
						ns = initial_state;
					 end
  end
  not_pressed: if (in4 & in3 & in2 & ~in1) begin
					 ns = goLeft;
					 out1 = 1; 
					 out2 = 0;
					 out3 = 0;
					 out4 = 0; end
				  else if (in4 & in3 & in1 & ~in2) begin
				    ns = goRight;
					 out1 = 0;
					 out2 = 1;
					 out3 = 0;
					 out4 = 0; end
				  else if (in4 & in2 & in1 & ~in3) begin
				    ns = goUp;
					 out1 = 0;
					 out2 = 0;
					 out3 = 1;
					 out4 = 0; end
				  else begin
				    ns = not_pressed;
					 out1 = 0; out2 = 0; out3 = 0; out4 = 0; end
  goLeft: if (in3 & ~in4) begin
			    ns = goDown;
			    out1 = 0; out2 = 0; out3 = 0; out4 = 1; end
			 else if (in4 & ~in3) begin
				 ns = goUp;
				 out1 = 0; out2 = 0; out3 = 1; out4 = 0; end
			 else begin
			   ns = goLeft;
			   out1 = 1;
				out2 = 0;
				out3 = 0;
				out4 = 0; end

  goRight: if (in3 & ~in4) begin
			    ns = goDown;
			    out1 = 0; out2 = 0; out3 = 0; out4 = 1; end
			 else if (in4 & ~in3) begin
				 ns = goUp;
				 out1 = 0; out2 = 0; out3 = 1; out4 = 0; end
			 else begin
			   ns = goRight;
			   out1 = 0;
				out2 = 1;
				out3 = 0;
				out4 = 0; end
				
	goUp: if (in2 & ~in1) begin
			    ns = goLeft;
			    out1 = 1; out2 = 0; out3 = 0; out4 = 0; end
			 else if (in1 & ~in2) begin
				 ns = goRight;
				 out1 = 0; out2 = 1; out3 = 0; out4 = 0; end
			 else begin
			   ns = goUp;
			   out1 = 0;
				out2 = 0;
				out3 = 1;
				out4 = 0; end
				
	goDown: if (in2 & ~in1) begin
			    ns = goLeft;
			    out1 = 1; out2 = 0; out3 = 0; out4 = 0; end
			 else if (in1 & ~in2) begin
				 ns = goRight;
				 out1 = 0; out2 = 1; out3 = 0; out4 = 0; end
			 else begin
			   ns = goDown;
			   out1 = 0;
				out2 = 0;
				out3 = 0;
				out4 = 1; end

 
 endcase
 end

 // DFFs
 always_ff @(posedge clk) begin
 if (!reset)
 ps <= initial_state;
 else
 ps <= ns;
 end

endmodule 

module userInput_testbench();
 logic clk, reset, leftIn, rightIn, upIn, downIn;
 logic left, right, up, down;

 userInput dut (.clk(clk) ,.reset(reset), .button1(leftIn), .button2(rightIn), .button3(upIn), .button4(downIn),
	.out1(left), .out2(right), .out3(up), .out4(down));

 // Set up the clock.
 parameter CLOCK_PERIOD=100;
 initial begin
 clk <= 0;
 forever #(CLOCK_PERIOD/2) clk <= ~clk;
 end

 // Set up the inputs to the design. Each line is a clock cycle.
 initial begin
 @(posedge clk); reset <= 0; 
 @(posedge clk); reset <= 1; leftIn <= 1; rightIn <= 1; upIn <= 1; downIn <= 1;
 @(posedge clk);
 @(posedge clk); leftIn <= 1; rightIn <= 0; upIn <= 1; downIn <= 1;
 @(posedge clk); leftIn <= 0; rightIn <= 1; upIn <= 1; downIn <= 1;
 @(posedge clk); leftIn <= 1; rightIn <= 1; upIn <= 0; downIn <= 1;
 @(posedge clk);	 
 @(posedge clk); leftIn <= 1; rightIn <= 1; upIn <= 1; downIn <= 0;
 @(posedge clk); 
 @(posedge clk); leftIn <= 1; rightIn <= 1; upIn <= 1; downIn <= 0;
 @(posedge clk); leftIn <= 0; rightIn <= 0; upIn <= 1; downIn <= 1;
 @(posedge clk);
 @(posedge clk); leftIn <= 0; rightIn <= 1; upIn <= 1; downIn <= 1; //switch to left
 @(posedge clk);
 @(posedge clk); leftIn <= 1; rightIn <= 0; upIn <= 1; downIn <= 1;
 @(posedge clk);
 @(posedge clk); leftIn <= 1; rightIn <= 1; upIn <= 0; downIn <= 0;
 @(posedge clk);
 @(posedge clk); leftIn <= 1; rightIn <= 1; upIn <= 0; downIn <= 1; //switch to up
 @(posedge clk);
 @(posedge clk); leftIn <= 1; rightIn <= 1; upIn <= 0; downIn <= 0;
 @(posedge clk); 
 @(posedge clk); leftIn <= 0; rightIn <= 0; upIn <= 1; downIn <= 1;
 @(posedge clk); 
 @(posedge clk); leftIn <= 1; rightIn <= 1; upIn <= 1; downIn <= 0;
 @(posedge clk);
 @(posedge clk); leftIn <= 1; rightIn <= 0; upIn <= 1; downIn <= 1; //switch to right
 @(posedge clk);
 @(posedge clk); leftIn <= 0; rightIn <= 1; upIn <= 1; downIn <= 1;
 @(posedge clk);
 @(posedge clk); leftIn <= 1; rightIn <= 1; upIn <= 0; downIn <= 0;
 @(posedge clk);
 @(posedge clk); leftIn <= 0; rightIn <= 0; upIn <= 1; downIn <= 1;
 @(posedge clk);
 @(posedge clk); leftIn <= 0; rightIn <= 0; upIn <= 1; downIn <= 0; //switch to down
 @(posedge clk);
 @(posedge clk); leftIn <= 0; rightIn <= 0; upIn <= 1; downIn <= 1;
 @(posedge clk);
 @(posedge clk); leftIn <= 1; rightIn <= 1; upIn <= 0; downIn <= 1;
 @(posedge clk);
 @(posedge clk); leftIn <= 1; rightIn <= 1; upIn <= 1; downIn <= 1;
 @(posedge clk);
 @(posedge clk); leftIn <= 0; rightIn <= 0; upIn = 0; downIn = 0;

 $stop; // End the simulation.
 end
endmodule 
