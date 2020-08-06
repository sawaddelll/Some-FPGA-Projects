// EE 371, Spring 2018

// DE1_SoC takes in the Clock, GPIO pins, HEX display feilds, KEYS and LEDR as inputs
// and outputs the VGA fields using VGA display. This module acts as the main module
// of the game: input signals received by the bluetooth shield via GPIO pins are sent to 
// other modules involved in game play such as userInput, ghostMode, scoreKeeper, snakeHead, gameSpace, 
// and the state of the game output via VGA fields to display on the VGA monitor.

module DE1_SoC (CLOCK_50, GPIO_0, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR,
				SW,VGA_R, VGA_G, VGA_B, VGA_BLANK_N, VGA_CLK,VGA_HS, VGA_SYNC_N, VGA_VS);

	input logic CLOCK_50; // 50MHz clock.
	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	output logic [9:0] LEDR;
	input logic [3:0] KEY; // True when not pressed, False when pressed
	input logic [9:0] SW;

	 
	logic [9:0] x;
	logic [8:0] y;
	logic [7:0] r, g, b;
	output logic [7:0] VGA_R;
	output logic [7:0] VGA_G;
	output logic [7:0] VGA_B;
	output logic VGA_BLANK_N;
	output logic VGA_CLK;
	output logic VGA_HS;
	output logic VGA_SYNC_N;
	output logic VGA_VS;
	 
	logic reset;
	assign reset = SW[9];
	
	logic start;
	assign start = SW[8]; 
	 
	localparam WIDTH = 32;
	localparam HEIGHT = 32;
	 
	// Generate clk off of CLOCK_50, whichClock picks rate.
	logic [31:0] clk;
	parameter whichClock = 21;//22 is standard used
	clock_divider cdiv (.reset(0), .clock(CLOCK_50), .divided_clocks(clk));	
	vgaDisplay #(.WIDTH(WIDTH), .HEIGHT(HEIGHT)) displays
	(.CLOCK_50, .reset, .x, .y, .r, .g, .b, .VGA_R, .VGA_G, .VGA_B, .VGA_BLANK_N, .VGA_CLK, 
	 .VGA_HS, .VGA_SYNC_N, .VGA_VS, .startup, .play, .gameOver); 
	
	// Originally planned to parameterize all necessary modules to make changing the number of players
	// before compiling easy, but this was not fully implemented.	
	localparam PLAYER_NUM = 3; 
	
	logic left1, right1, up1, down1;
	logic left2, right2, up2, down2;
	logic left3, right3, up3, down3;
	
	logic ileft1, iright1, iup1, idown1; //initial values from user input, before determining if player is active. 
	logic ileft2, iright2, iup2, idown2; //should be the outputs of userInput modules
	logic ileft3, iright3, iup3, idown3;
	
	always_comb //transfers user input for direction to other modules, unless it's input from a player not currently in the game 
	begin
		left1 = ileft1; right1 = iright1; up1 = iup1; down1 = idown1;
		if (PLAYER_NUM == 2)
		begin	
			left2 = ileft2; right2 = iright2; up2 = iup2; down2 = idown2;
			left3 = 0; right3 = 0; up3 = 0; down3 = 0;
		end
		else if (PLAYER_NUM == 3)
		begin
			 left2 = ileft2; right2 = iright2; up2 = iup2; down2 = idown2;
			 left3 = ileft3; right3 = iright3; up3 = iup3; down3 = idown3;
		end 
		else 
		begin
			left2 = 0; right2 = 0; up2 = 0; down2 = 0;
			 left3 = 0; right3 = 0; up3 = 0; down3 = 0;
		end
	end

/*---------------------------------------------------------------------*/
//LOGIC BLOCK FOR 2 PLAYERS INPUTTING COMMANDS FROM BLUETOOTH MODULE

	input logic [35:0] GPIO_0;
	logic rx_serial, completeBit;
	logic ghost_1, ghost_2;
	logic [7:0] rx_byte;
	logic up_p1, left_p1, right_p1, down_p1, up_p2, left_p2, right_p2, down_p2;
	logic dleft1, dright1, dup1, ddown1;
	logic dleft2, dright2, dup2, ddown2;

	uart_receiver uartRx(.clk(CLOCK_50), .rx_serial(GPIO_0[0]), .completeBit, .rx_out(rx_byte));

	
	

	/* The following code is what was used normally, to allow two players to be controlled by an app,
		sending data to the SoC via bluetooth connected to GPIO pins */
	/*
	assign down_p1 = !(rx_byte == 8'b00000001);
	assign left_p1 = !(rx_byte == 8'b00000011);
	assign right_p1 = !(rx_byte == 8'b00000010);
	assign up_p1 = !(rx_byte == 8'b00000100);
	assign up_p2 = !(rx_byte == 8'b00000101);
	assign left_p2 = !(rx_byte == 8'b00000110);
	assign right_p2 = !(rx_byte == 8'b00000111);
	assign down_p2 = !(rx_byte == 8'b00001000);
	assign ghost_1 = (rx_byte == 8'b00001001);
	assign ghost_2 = (rx_byte == 8'b00000000);
	*/
	
	/* Using the following code instead to have some control over these 2 players without having the bluetooth app
		or hardware (instead using only inputs on the DE1_SoC). */
	//
	assign down_p1 = ~SW[4];
	assign left_p1 = ~SW[7];
	assign right_p1 = ~SW[6];
	assign up_p1 = ~SW[5];
	assign up_p2 = ~SW[4];
	assign left_p2 = ~SW[7];
	assign right_p2 = ~SW[6];
	assign down_p2 = ~SW[5];
	assign ghost_1 = ~SW[2];
	assign ghost_2 = ~SW[1];
	//
	
	userInput player1 (.clk(clk[whichClock]), .reset(reset), .button1(left_p1), .button2(right_p1), .button3(up_p1), .button4(down_p1), 
						.out1(ileft1), .out2(iright1), .out3(iup1), .out4(idown1)); 
	userInput player2 (.clk(clk[whichClock]), .reset(reset), .button1(left_p2), .button2(right_p2), .button3(up_p2), .button4(down_p2), 
						.out1(ileft2), .out2(iright2), .out3(iup2), .out4(idown2)); 
	

/*---------------------------------------------------------------------*/

	
	//USER INPUT FROM FPGA FOR PLAYER 3
	userInput player3 (.clk(clk[whichClock]), .reset, .button1(KEY[3]), .button2(KEY[2]), .button3(KEY[1]), .button4(KEY[0]),
						 .out1(ileft3), .out2(iright3), .out3(iup3), .out4(idown3)); 

	logic [6:0] snake1X, snake2X, snake3X, snake1Y, snake2Y, snake3Y;
	logic [6:0] apple1X, apple1Y;
	logic [6:0] snakeLength1, snakeLength2, snakeLength3;
	logic startup, play, gameOver, dead1, dead2, dead3;

	logic ghost1;
	logic ghost2;
	logic ghost3;
	
	ghostMode #(.CLK_IN(12), .COOLDOWN_TIME(10), .ACTIVE_TIME(3), .USES(4)) ghostsnake1 (.ghostEnable(ghost1), .clk(clk[whichClock]), .reset, .ghostRequest(ghost_1)); 
	ghostMode #(.CLK_IN(12), .COOLDOWN_TIME(10), .ACTIVE_TIME(3), .USES(4)) ghostsnake2 (.ghostEnable(ghost2), .clk(clk[whichClock]), .reset, .ghostRequest(ghost_2)); 
	ghostMode #(.CLK_IN(12), .COOLDOWN_TIME(10), .ACTIVE_TIME(3), .USES(4)) ghostsnake3 (.ghostEnable(ghost3), .clk(clk[whichClock]), .reset, .ghostRequest(SW[0]));
	
	assign LEDR[2] = ghost3;
	assign LEDR[1] = ghost2;
	assign LEDR[0] = ghost1;

	gameState #(.PLAYERS(3)) stateOfGame (.reset, .clk(clk[whichClock]), .start, .dead1, .dead2, .dead3, .startup, .play, .gameOver);	 
	
	
	//Still need module/logic for how to display all 3 player scores
	scorekeeper lengthAndScore1 (.reset, .clk(clk[whichClock]), .gameOver,  .snakeX(snake1X), .snakeY(snake1Y),
								 .apple1X, .apple1Y, .snakelength(snakeLength1), .HEX0(HEX0), .HEX1(HEX1));
	scorekeeper lengthAndScore2 (.reset, .clk(clk[whichClock]), .gameOver,  .snakeX(snake2X), .snakeY(snake2Y),
								 .apple1X, .apple1Y, .snakelength(snakeLength2), .HEX0(HEX2), .HEX1(HEX3));
	scorekeeper lengthAndScore3 (.reset, .clk(clk[whichClock]), .gameOver,  .snakeX(snake3X), .snakeY(snake3Y),
								 .apple1X, .apple1Y,.snakelength(snakeLength3), .HEX0(HEX4), .HEX1(HEX5));

	appleGenerator #(.NUM(1), .WIDTH(WIDTH), .HEIGHT(HEIGHT), .STARTX(15), .STARTY(15)) apple1  (.reset, .clk(clk[whichClock]), .appleX(apple1X), .appleY(apple1Y), .snake1X, .snake2X, .snake3X,
					   .snake1Y, .snake2Y, .snake3Y);

	snakeHead #(.PLAYER(1), .WIDTH(WIDTH), .HEIGHT(HEIGHT), .STARTX(3), .STARTY(3)) snake1	
				(.reset, .clk(clk[whichClock]), .left(left1), .right(right1), .up(up1), .down(down1), .x(snake1X), .y(snake1Y), .dead(dead1));
	snakeHead #(.PLAYER(2), .WIDTH(WIDTH), .HEIGHT(HEIGHT), .STARTX(3), .STARTY(28)) snake2	
				(.reset, .clk(clk[whichClock]), .left(left2), .right(right2), .up(up2), .down(down2), .x(snake2X), .y(snake2Y), .dead(dead2));
	snakeHead #(.PLAYER(3), .WIDTH(WIDTH), .HEIGHT(HEIGHT), .STARTX(28), .STARTY(28)) snake3
				(.reset, .clk(clk[whichClock]), .left(left3), .right(right3), .up(up3), .down(down3), .x(snake3X), .y(snake3Y), .dead(dead3));

	gameSpace #(.WIDTH(WIDTH), .HEIGHT(HEIGHT), .PLAYERS(3)) gameLogic
				  (.reset, .clk(clk[whichClock]), .snake1X, .snake2X, .snake3X,
				  .snake1Y, .snake2Y, .snake3Y,
				  .apple1X, .apple1Y,
				  .gracePeriod1, .gracePeriod2, .gracePeriod3,
				  .snakeLength1, .snakeLength2, .snakeLength3,
				  .left1, .right1, .up1, .down1,
				  .left2, .right2, .up2, .down2,
				  .moveclk1(clk[whichClock]), .moveclk2(clk[whichClock]),
				  .collisionclk(clk[whichClock]),
				  .ghost1, .ghost2, .ghost3,
				  .left3, .right3, .up3, .down3,
				  .dead1, .dead2, .dead3,.x, .y, .r, .g, .b);

	logic [1:0] s_count1, s_count2, s_count3;
	logic gracePeriod1, gracePeriod2, gracePeriod3;
	enum {starting, normal}  ps1, ps2, ps3, ns1, ns2, ns3;
	logic go1, go2, go3;

	// A state machine for starting the game as each snake begins movement.
	// Controls a grace period to prevent snakes from colliding with themselves as they start moving and grow to correct starting length. 
	always_comb
	begin
		case(ps1)
			starting: 
				if (go1)
				begin	
					ns1 = normal;
					gracePeriod1 = 0;
				end
				else
				begin
					ns1 = starting;
					gracePeriod1 = 1;
				end
			normal: 
				begin
					ns1 = normal;
					gracePeriod1 = 0;
				end
		endcase 
		
		case(ps2)
			starting: 
				if (go2)
				begin	
					ns2 = normal;
					gracePeriod2 = 0;
				end
				else
				begin
					ns2 = starting;
					gracePeriod2 = 1;
					end
			normal: 
				begin
					ns2 = normal;
					gracePeriod2 = 0;
				end
		endcase 
		
		case(ps3)
			starting: 
				if (go3)
				begin	
					ns3 = normal;
					gracePeriod3 = 0;
				end
				else
				begin
					ns3 = starting;
					gracePeriod3 = 1;
				end
			normal: 
				begin
					ns3 = normal;
					gracePeriod3 = 0;
				end
		endcase 
	end
	
	always_ff @(posedge clk[whichClock])
	begin	
		if (!reset) 
		begin	
			ps1 <= starting; ps2 <= starting;
		end
		else 
		begin
			ps1 <= ns1; ps2 <= ns2;
		end
	end
	
	always_ff @(posedge clk[whichClock]) 
	begin 
		if (!reset)
		begin
			s_count1 <= 2'b00;
			go1 <= 0;
		end
		else if (s_count1 >= 2'b11) begin
			go1 <= 1;
		end
		else if ( left1 || right1 || up1 || down1) begin
			s_count1 <= s_count1 + 1'b1;   
		end
	end
 
	always_ff @(posedge clk[whichClock]) 
	begin 
		if (!reset)
		begin
			s_count2 <= 2'b00;
			go2 <= 0;
		end
		else if (s_count2 >= 2'b11) begin
			go2 <= 1;
		end
		else if ( left2 || right2 || up2 || down2) begin
			s_count2 <= s_count2 + 1'b1;   
		end
	end
	
	always_ff @(posedge clk[whichClock]) 
	begin 
		if (!reset)
		begin
			s_count3 <= 2'b00;
			go3 <= 0;
		end
		else if (s_count3 >= 2'b11) begin
			go3 <= 1;
		end
		else if ( left3 || right3 || up3 || down3) begin
			s_count3 <= s_count3 + 1'b1;   
		end
	end

endmodule


// divided_clocks[0] = 25MHz, [1] = 12.5Mhz, ... [23] = 3Hz, [24] = 1.5Hz,
//[25] = 0.75Hz, ...
module clock_divider (reset, clock, divided_clocks); 
  input logic clock, reset; 
  output logic [31:0] divided_clocks;

  always_ff @(posedge clock) begin 
    if(reset) begin
      divided_clocks <= 0;
    end else begin
      divided_clocks <= divided_clocks + 1;
    end
  end 
endmodule
