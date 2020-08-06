// Samson Waddell, EE 371, Spring 2018

// This module keeps track of where the entire body of a snake is, based on the 
// directions controlling the snake, whether the snake is dead, the coordinates of the snake's head, and the coordinates of the apple.
// It outputs an array the size of the display, specified by the parameters WIDTH and HEIGHT, where a 1 at a certain index
// means the snake is there, while 0 means that spot is empty. STARTX and STARTY specify the starting location of the snakehead,
// used at reset, and these parameters should match those of the snakeHead module.

module snakeBody #(parameter WIDTH = 32, parameter HEIGHT = 32, parameter STARTX = 2, parameter STARTY = 2) //X & Y must be from 0 to WIDTH-1 or HEIGHT-1 respectively
				  (reset, clk, left, right, up, down, snakeX, snakeY, appleX, appleY, body, dead);
				  
	input logic reset, clk, left, right, up, down, dead;
	input logic [6:0] snakeX, snakeY, appleX, appleY;
	output logic [WIDTH-1:0][HEIGHT-1:0] body;	
	logic [6:0] tailX, tailY;
	logic [WIDTH-1:0][HEIGHT-1:0][1:0] directions;
	logic [1:0] new_direction;
	logic [1:0] tail_direction;
	logic gameStart;
	
	assign gameStart = left || right || up || down;
	
   	always_comb 
	begin 
		if (left && ~right)
			new_direction = 2'b10;
		else if (right && ~left)
			new_direction = 2'b01;
		else if (up && ~down)
			new_direction = 2'b00;
		else if (down && ~up)
			new_direction = 2'b11;
		else 
			new_direction = 2'b00;
	end
	
	assign tail_direction = directions[tailX][tailY];//try this combin. logic instead of inside DFF
	
	integer i1, i2, i3;
	always_ff @(posedge clk) 
	begin 
		if (!reset) 
		begin
			body[STARTX][STARTY+2:STARTY] <= 3'b111; //-1
			tailX <= STARTX;
			tailY <= STARTY+3; 
			for (i1=STARTX+1; i1 <= WIDTH-1; i1 = i1+1) begin
				body[i1][HEIGHT-1:0] <= 1'b0;//body[WIDTH-1:STARTX+1][HEIGHT-1:0] <= 0;
			end
			
			
			for (i2=0; i2 <= STARTX-1; i2 = i2+1) begin 
				body[i2][HEIGHT-1:0] <= 1'b0;//[STARTX-1:0][HEIGHT-1:0]
			end
			body[STARTX][HEIGHT-1:STARTY+3] <= 1'b0;//[2][32-1:2+3]
			body[STARTX][STARTY-1:0] <= 1'b0;//[2][2-1:0] 
			
			for (i3=STARTY; i3 <= STARTY+3; i3 = i3+1) begin
				directions[STARTX][i3][1:0] <= 2'b00;//[STARTX][STARTY+3:STARTY][1:0]
			end
			//tail_direction <= 2'b00;
		end
		else if (dead)
		begin
			body <= '0;
		end
		else 
		begin
			body[snakeX][snakeY] <= 1;
			body[tailX][tailY] <= 0;
			directions[snakeX][snakeY][1:0] <= new_direction;
			if (gameStart && !((snakeX == appleX) && (snakeY == appleY)))
			begin
				if (tail_direction == 2'b00)//up
				begin 
					tailX <= tailX;
					if (tailY == 7'b0000000) 
						tailY <= 7'b0011111; //20 is 0010100
					else 
						tailY <= tailY - 1'b1;
				end
				else if (tail_direction == 2'b01) //right
				begin
					tailY <= tailY;
					if (tailX == 7'b0011111)
						tailX <= 7'b0000000;
					else 
						tailX <= tailX + 1'b1;
					
				end
				else if (tail_direction == 2'b10) //left
				begin
					tailY <= tailY;
					if (tailX == 7'b0000000) 
						tailX <= 7'b0011111;
					else 
						tailX <= tailX - 1'b1;
					
				end
				else if (tail_direction == 2'b11) //down
				begin
					tailX <= tailX;
					if (tailY == 7'b0011111)
						tailY <= 7'b0000000;
					else 
						tailY <= tailY + 1'b1;
				end

			end
		end
	end
	
endmodule
