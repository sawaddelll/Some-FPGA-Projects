// Samson Waddell, EE 371 Spring 2018
//
// gameSpace keeps track of where each of the snakes is in the game area, and outputs r,g,b values 
// for the pixel block at the input (x,y) accordingly. WIDTH and HEIGHT specify the size of the game area
// and PLAYERS is currently unused. In addition to outputting color values, it also outputs a signal
// for each snake that's true when that snake is dead because of a collision. 

module gameSpace #(parameter WIDTH = 32, parameter HEIGHT = 32, parameter PLAYERS = 2)
				  (reset, clk, snake1X, snake2X, snake3X, 
				  snake1Y, snake2Y, snake3Y,
				  apple1X, apple1Y,
				  gracePeriod1, gracePeriod2, gracePeriod3,
				  snakeLength1, snakeLength2, snakeLength3,
				  left1, right1, up1, down1,
				  left2, right2, up2, down2,
				  moveclk1, moveclk2,
				  collisionclk,
				  ghost1, ghost2, ghost3,
				   left3, right3, up3, down3,
				  dead1, dead2, dead3,  x, y, r, g, b);
	
	input logic reset, clk, gracePeriod1, gracePeriod2, gracePeriod3;
	input logic ghost1, ghost2,ghost3; 
	input logic [9:0] x;
	input logic [8:0] y;
	input logic [6:0] snake1X, snake2X, snake1Y, snake2Y, snake3X, snake3Y;
	input logic [6:0] apple1X, apple1Y;
	input logic [6:0] snakeLength1, snakeLength2, snakeLength3;
	input logic left1, right1, up1, down1;
	input logic left2, right2, up2, down2;
	input logic left3, right3, up3, down3;
	output logic [7:0] r,g,b;
	output logic dead1, dead2, dead3;
	logic [WIDTH-1:0][HEIGHT-1:0] body1, body2, body3;
	input logic moveclk1, moveclk2;

	//snakeBody makes the body array that shows where a snake is in the game area
	snakeBody #(.WIDTH(32), .HEIGHT(32), .STARTX(3), .STARTY(3)) snake1	
				  (.reset, .clk(moveclk1), .left(left1), .right(right1), .up(up1), .down(down1), 
					.snakeX(snake1X), .snakeY(snake1Y),.body(body1), .appleX(apple1X), .appleY(apple1Y), .dead(dead1));

	snakeBody #(.WIDTH(32), .HEIGHT(32), .STARTX(3), .STARTY(28)) snake2	
				  (.reset, .clk(moveclk2), .left(left2), .right(right2), .up(up2), .down(down2), 
				   .snakeX(snake2X), .snakeY(snake2Y),.body(body2), .appleX(apple1X), .appleY(apple1Y), .dead(dead2));

	snakeBody #(.WIDTH(32), .HEIGHT(32), .STARTX(28), .STARTY(28)) snake3	
				   (.reset, .clk, .left(left3), .right(right3), .up(up3), .down(down3), 
					 .snakeX(snake3X), .snakeY(snake3Y),.body(body3), .appleX(apple1X), .appleY(apple1Y), .dead(dead3));
	
	// logic for deciding what color to pass to VGA display at current pixel.
	always_comb 
	begin
		if (snake1X == x && snake1Y == y) //snake heads are different colors from the body
		begin
			r = 8'b11111111;
			g = 8'b00000000;
			b = 8'b11111111;
		end
		else if (body1[x][y]) 
		begin
			r = 8'b00011111;
			g = 8'b00000000;
			b = 8'b00111111;
		end
		else if (snake2X == x && snake2Y == y)
		begin
			r = 8'b11111111;
			g = 8'b11111111;
			b = 8'b00000000;
		end
		else if (body2[x][y])
		begin
			r = 8'b11111111; 
			g = 8'b11100111; 
			b = 8'b00000000;
		end
		else if (snake3X == x && snake3Y == y)
		begin
			r = 8'b00000000;
			g = 8'b11111111;
			b = 8'b00000000;
		end
		else if (body3[x][y])
		begin
			r = 8'b00111111; 
			g = 8'b11001101;
			b = 8'b00011000;
		end
		else if ((apple1X == x) && (apple1Y == y))
		begin
			r = 8'b11111111; 
			g = 8'b00010011;
			b = 8'b00010011;
		end
		else 
		begin
			r = 8'b11110000;
			g = 8'b11110000;
			b = 8'b11110000;
		end
	end
	
	
	input logic collisionclk;
	
	//module for tracking when snakes die from collisions
	collisionDetection #(.WIDTH(32), .HEIGHT(32)) collisions (.reset, .clk(collisionclk), .body1, .body2, .body3, 
						.head1x(snake1X), .head2x(snake2X), .head3x(snake3X),
						.head1y(snake1Y), .head2y(snake2Y), .head3y(snake3Y),.dead1, .dead2, .dead3,
						.gracePeriod1, .gracePeriod2,  .gracePeriod3,
						.ghost1, .ghost2, .ghost3);

endmodule 
