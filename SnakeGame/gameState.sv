
// This module takes in reset, clk, start, and dead signals for each snake
// and outputs signals for startup, play, and gameOver. 
// The module uses a basic state machine to track the state of the game between starting,
// playing, and finished. At reset it’s in the starting state, and remains there until start 
// is true, at which point it switches to playing. It stays in playing until only one 
// or fewer dead signals is false (meaning one or zero snakes are alive).

module gameState #(parameter PLAYERS = 2) (reset, clk, start, dead1, dead2, dead3, startup, play, gameOver);	 

	input logic reset, clk, start, dead1, dead2, dead3;
	output logic startup, play, gameOver;
	
	enum {starting, playing, finished} ps, ns;
	
	always_comb 
	begin 
		case(ps)
			starting: 
			begin
				startup = 1;
				play = 0;
				gameOver = 0;
				if (start)
					ns = playing;
				else 
					ns = starting;
			end
			playing:
			begin
				if ((PLAYERS == 1) && (dead1))
				begin 
					ns = finished; gameOver = 1;
				end
				else if ((PLAYERS == 2) && (dead1 || dead2))
				begin
					ns = finished; gameOver = 1;
				end
				else if ((PLAYERS == 3) && ((dead1 && dead2) || (dead1 && dead3) || (dead2 && dead3)))
				begin
					ns = finished; gameOver = 1;
				end
				else 
				begin
					ns = playing; gameOver = 0; 
				end
				play = 1; startup = 0;
			end
			finished:
			begin
				ns = finished; gameOver = 1; startup = 0; play = 0;
			end
		endcase
	end 
	
	always_ff @(posedge clk) 
	begin
		if (!reset)
			ps <= starting;
		else 
			ps <= ns;
	end
	
endmodule 
