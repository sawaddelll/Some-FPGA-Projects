/********************************************************************************
	Author: 	Samson Waddell
	------------------------------------------------------------------------
	Module:		Scorekeeper
	------------------------------------------------------------------------
	Description:	This module tracks the score for a single snake, and displays it using 
			two HEXs. The score goes up by 1 each time an apple is consumed by the snake
	------------------------------------------------------------------------
	Ports:			
					clk			-	input clock
					reset			- 	when 0, resets the module to score of 0.
					gameOver		-	input specifying when only one or zero snakes remain
					snakeX			-	x coordinate of the snake's head
					snakeY			- 	y coordinate of the snake's head
					apple1X			- 	x coordinate of the apple
					apple1Y			- 	y coordinate of the apple
					snakelength		- 	outputs how long the snake's body is, starting at 3
					HEX0			- 	the 7 segment display for the ones place of the score
					HEX1			- 	the 7 segment display for the tens place of the score
	------------------------------------------------------------------------
	EE 371, Spring 2018
********************************************************************************/
module scorekeeper (reset, clk, gameOver, snakeX, snakeY, apple1X, apple1Y, snakelength, HEX0, HEX1);
 input logic reset, clk;
 input logic [6:0] snakeX;
 input logic [6:0] snakeY;
 input logic [6:0] apple1X;
 input logic [6:0] apple1Y;
 input logic gameOver;
 output logic [6:0] HEX0, HEX1;
 output logic [6:0] snakelength;
 
 // currently unused; for storage of a score (instead of only displaying it) 
 logic [6:0] score;
 assign score = snakelength - 7'b0000011;
 
 logic incr, carryover, carryover1;
 
 enum {incr_yes, incr_no} ps, ns;
 
 always_comb begin
	case(ps)
		incr_yes: if (gameOver) begin
						ns = incr_no;
						incr = 0;
					 end
					 else
					 begin
						ns = incr_yes;
						incr = ((snakeX == apple1X) & (snakeY == apple1Y)); 
					 end
		incr_no : begin 
						ns = incr_no;
						incr = 0; end 
	endcase
 end
	
 
 logic [3:0] out, out1;
 
 counterToNine ones (.reset, .clk, .incr, .out, .carryover_out(carryover));
 counterToNine tens (.reset, .clk, .incr(carryover), .out(out1), .carryover_out(carryover1));
 two_seg7 pointDisplay (.HEX0, .HEX1, .in1(out), .in2(out1)); 
 
 always_ff @(posedge clk) begin
	if (!reset) begin 
		snakelength <= 7'b0000011;
		ps <= incr_yes; end
	else if (((snakeX == apple1X) && (snakeY == apple1Y))) begin 
		snakelength <= snakelength + 7'b0000001;
		ps <= ns; end
	else 
		ps <= ns;
 end
	
endmodule 




//module scorekeeper_testbench ();
//	logic reset, clk, gameOver;
//	logic [9:0] snakeX, apple1X;
//	logic [8:0] snakeY, apple1Y;
//	logic [6:0] snakelength;
//	logic [6:0] HEX0, HEX1;
//	
//	scorekeeper dut (.reset, .clk, .gameOver, .snakeX, .snakeY, .apple1X, .apple1Y, .snakelength, .HEX0, .HEX1);
//	
//	parameter CLOCK_PERIOD=100;
//	initial begin
//	clk <= 0;
//	forever #(CLOCK_PERIOD/2) clk <= ~clk;
//	end
//		
//	initial begin 
//	@(posedge clk);
//	@(posedge clk); reset = 0;
//	@(posedge clk);
//	@(posedge clk);
//	@(posedge clk);
//	@(posedge clk); reset = 1; snakeX = 10'b0000000000; snakeY = 9'b000000000; 
//						 apple1Y = 9'b000000000; apple1X = 10'b0000000100; gameOver = 0;
//	@(posedge clk);
//	@(posedge clk);
//	@(posedge clk); snakeX = 10'b0000000100;
//	@(posedge clk);
//	@(posedge clk);
//	@(posedge clk);
//	@(posedge clk);
//	@(posedge clk);
//	@(posedge clk);
//	@(posedge clk);
//	@(posedge clk);
//	@(posedge clk); snakeX = 10'b0000000000;
//	@(posedge clk);
//	@(posedge clk);
//	$stop;
//	end
//endmodule 	
