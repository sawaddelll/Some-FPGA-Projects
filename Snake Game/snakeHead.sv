// Samson Waddell, EE 371, Spring 2018
//
// snakeHead takes in signals for each possible direction of movement, and whether the snake is dead. 
// Based on these inputs, the module moves the snake head and outputs the head's x and y coordinates.
// Parameters WIDTH and HEIGTH specify the size of the arena (the valid area that the head can be in), 
// and STARTX and STARTY specify where the head is when the module is reset. If the snake dies,
// the head is moved outside the valid area.

module snakeHead #(parameter PLAYER = 1, parameter WIDTH = 32, parameter HEIGHT = 32, parameter STARTX = 3, parameter STARTY = 3) 
						(reset, clk, left, right, up, down, x, y, dead);
						
	input logic reset, clk, left, right, up, down, dead;
	
	output logic [6:0] x;
	output logic [6:0] y;

	always_ff @(posedge clk)
	begin
		if (!reset)
			begin
				x <= STARTX;//These parameters now replace the function that the PLAYER parameter used to have
				y <= STARTY;	
			end
			
		else 
			begin
			if (dead)
				begin
				x <= 7'b1111111;
				y <= 7'b1111111;
				end
			else
				begin
				if (left && ~right)
					begin
					if (x == 7'b0000000) 
						x <= WIDTH - 1;
					else 
						x <= x - 1'b1; //change these to 1 bit 
					end
				else if (right && ~left)
					begin 
					if (x == WIDTH - 1)
						x <= 7'b0000000;
					else 
						x <= x + 1'b1;
					end
				if (up && ~down) 
					begin
					if (y == 7'b0000000) 
						y <= HEIGHT - 1; //20 is 0010100
					else 
						y <= y - 1'b1;
					end
				else if (down && ~up)
					begin 
					if (y == HEIGHT - 1)
						y <= 7'b0000000;
					else 
						y <= y + 1'b1;
					end
				end
			end
	end

endmodule 

module snakeHead_testbench ();
 logic reset, clk, left, right, up, down, dead;
 logic [6:0] x;
 logic [6:0] y;
 
 snakeHead #(.PLAYER(1), .WIDTH(16), .HEIGHT(16), .STARTX(3), .STARTY(3)) dut (.reset, .clk, .left, .right, .up , .down, .dead, .x, .y);
 
 parameter CLOCK_PERIOD=100;
 initial begin
 clk <= 0;
 forever #(CLOCK_PERIOD/2) clk <= ~clk;
 end

 // Set up the inputs to the design. Each line is a clock cycle.
 initial begin
 @(posedge clk); reset <= 0; dead <= 0;
 @(posedge clk); reset <= 1; left <= 0; right <= 0; up <= 0; down <= 0;
 @(posedge clk); 
 @(posedge clk); left <= 1; 
 @(posedge clk); 
 @(posedge clk); right <= 1; 
 @(posedge clk); 
 @(posedge clk); 
 @(posedge clk); left <= 0;
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
 @(posedge clk); up <= 1;
 @(posedge clk);
 @(posedge clk);
 @(posedge clk);
 @(posedge clk); left <= 1;
 @(posedge clk);
 @(posedge clk); right <= 0;
 @(posedge clk); 
 @(posedge clk);
 @(posedge clk);
 @(posedge clk);
 @(posedge clk); 
 @(posedge clk); down <= 1;
 @(posedge clk);
 @(posedge clk);
 @(posedge clk); up <= 0;
 @(posedge clk); down <= 0; right <= 0;
 @(posedge clk); dead <= 1;
 @(posedge clk);
 @(posedge clk);
 @(posedge clk);
 $stop;
 end
 
endmodule 
