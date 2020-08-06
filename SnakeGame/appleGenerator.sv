// This module outputs the x and y coordinates corresponding to where an apple is in the game arena/display.
// Parameters WIDTH and HEIGHT specify the size of the display, and STARTX and STARTY specify the coordinates where the first
// apple spawns at reset. The module takes in the x and y coordinates of each snake's head, and when one of those has reached
// the same coordinates as the apple, that apple has been "eaten", and a new one spawns at a random spot in the arena.

module appleGenerator #(parameter NUM = 1, parameter WIDTH = 32, parameter HEIGHT = 32, parameter STARTX, parameter STARTY)  (reset, clk, appleX, appleY, snake1X, snake2X, snake3X,
					   snake1Y, snake2Y, snake3Y); //Parameter NUM: 0 = not used, 1 = first apple (1-3 players), 2 = second apple (4 players)

	input logic reset, clk;
	input logic [6:0] snake1X, snake2X, snake3X;
	input logic [6:0] snake1Y, snake2Y, snake3Y;
	output logic [6:0] appleX;
	output logic [6:0] appleY; 
	logic [9:0] random;
 
	LFSR rand_generator (.clk, .reset, .random);
	
	always_ff @(posedge clk) 
	begin
		if (!reset)
		begin
			appleX[6:0] <= STARTX;
			appleY[6:0] <= STARTY;
		end

		else if (((snake1X == appleX) && (snake1Y == appleY)) || ((snake2X == appleX) && (snake2Y == appleY)) ||
				 ((snake3X == appleX) && (snake3Y == appleY)))
		begin
			appleX[6:5] <= 2'b00;
			appleY[6:5] <= 2'b00;
			appleX[4:0] <= random[4:0];
			appleY[4:0] <= random[9:5];
		end
	end 
	
 endmodule
