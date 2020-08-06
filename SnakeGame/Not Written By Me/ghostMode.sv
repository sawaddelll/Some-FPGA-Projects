/********************************************************************************
	Author: 		Haytham Shaban
	------------------------------------------------------------------------
	Project:		Ghost Mode module
	------------------------------------------------------------------------
	Description:	Module overhead for the powerup capability "ghost mode", granting the player
					using the power invulnerability to previous conditions of elimination
	------------------------------------------------------------------------
	Parameters:	CLK_IN			-	Frequency after clock division
				COOLDOWN_TIME 	-	number of seconds that the user must wait before they can use the power up again
				ACTIVE_TIME 	-	number of seconds that the effects of the power up are "active" for the player using it
				USES 			-	number of times that the player can use the power up
				clk				-	input clock
				reset			-	active-low reset, sets counter to 0
				ghostRequest	-	input request logic, set high when stimulus requests to have the power up activated
				ghostEnable		-	set high when a power up request was successful, granting the user the effects of the power
	------------------------------------------------------------------------
	EE371 Class, Spring 2018
********************************************************************************/
module ghostMode #(parameter CLK_IN = 12, COOLDOWN_TIME = 10, ACTIVE_TIME = 3, USES = 4)(ghostEnable, clk, reset, ghostRequest);
	parameter DISABLE = 1'b0, ENABLE = 1'b1;
	output logic ghostEnable; //request granted, power is on
	input logic clk, reset;
	input logic ghostRequest; //user requested power
	logic [2:0] usedCounter; //amount of times you can use the super power
	logic [31:0] coolDownCounter; //time remaining until you can use the super power again
	logic [31:0] activeCounter; //time remaining active during super power
	logic state, nextState;

	always_comb begin
		case(state)
			DISABLE: begin
				if(ghostRequest && (usedCounter != 0) && (coolDownCounter == 0) && (activeCounter == 0))  begin //check off conditions before turning power on
					ghostEnable = 1;
					nextState = ENABLE;
				end
				else begin
					ghostEnable = 0;
					nextState = DISABLE;
				end
			end
			ENABLE: begin
				if(activeCounter == 0 && ghostEnable) begin //turn off power if active runs out of time
					ghostEnable = 0;
					nextState = DISABLE;
				end // if(activeCounter == 0)
				else begin
					ghostEnable = 1;
					nextState = ENABLE;
				end
			end
		endcase
	end
	
	always_ff @(posedge clk or negedge reset) 
	begin
		if (!reset)
			state <= DISABLE;
		else 
			state <= nextState;
	end
	
	
	always_ff @(posedge clk or negedge reset) begin
		if(!reset) begin
			usedCounter <= USES;
			activeCounter <= 0;
			coolDownCounter <= 0;
		end
		else begin
			if(ghostRequest && (usedCounter > 0) && (coolDownCounter == 0) && (activeCounter == 0))  begin //check off conditions before turning power on
				activeCounter <= CLK_IN*ACTIVE_TIME;
				usedCounter <= usedCounter - 1;
			end
			if(ghostEnable && activeCounter > 0) begin //decrement time left with power if its on
				activeCounter <= activeCounter - 1;
			end
			if(activeCounter == 1 && ghostEnable) begin //turn off power if active runs out of time
				coolDownCounter <= CLK_IN*COOLDOWN_TIME;
			end // if(activeCounter == 0)
			if(coolDownCounter > 0) begin
				coolDownCounter <= coolDownCounter - 1;
			end
		end

	end


endmodule // ghostMode

module ghostMode_tb();
	logic ghostEnable; //request granted, power is on
	logic clk, reset;
	logic ghostRequest; //user requested power	

	ghostMode dut(.ghostEnable, .clk, .reset, .ghostRequest);


	parameter ClockDelay = 100;

	initial begin //clock initilazation utilizing the paramter for delay (sets rate of alternation)
		clk <= 0;
		repeat(500) begin
			#(ClockDelay/2) clk <= ~clk;
		end
		repeat(2000)
		begin
			#(ClockDelay/2) clk <= ~clk;
		end
	end

	initial begin
		@(posedge clk); reset <= 1;
		@(posedge clk); reset <= 0; //set reset low for a clock cycle in order to stimulate cyclic, specified behavior
		@(posedge clk); reset <= 1;
		@(posedge clk);
		@(posedge clk);
		@(posedge clk); ghostRequest <= 0;
		@(posedge clk); ghostRequest <= 1;
		@(posedge clk); ghostRequest <= 0;
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk); ghostRequest <= 0;
		@(posedge clk); ghostRequest <= 1;
		@(posedge clk); ghostRequest <= 0;
		@(posedge clk);
		@(posedge clk);
		repeat(50) begin
			@(posedge clk);
		end
		@(posedge clk); ghostRequest <= 0;
		@(posedge clk); ghostRequest <= 1;
		@(posedge clk); ghostRequest <= 0;
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		repeat(230) begin
			@(posedge clk);
		end
		@(posedge clk); ghostRequest <= 0;
		@(posedge clk); ghostRequest <= 1;
		@(posedge clk); ghostRequest <= 0;
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		repeat(230) begin
			@(posedge clk);
		end
		@(posedge clk); ghostRequest <= 0;
		@(posedge clk); ghostRequest <= 1;
		@(posedge clk); ghostRequest <= 0;
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		repeat(230) begin
			@(posedge clk);
		end
		@(posedge clk); ghostRequest <= 0;
		@(posedge clk); ghostRequest <= 1;
		@(posedge clk); ghostRequest <= 0;
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		repeat(230) begin
			@(posedge clk);
		end
		@(posedge clk); ghostRequest <= 0;
		@(posedge clk); ghostRequest <= 1;
		@(posedge clk); ghostRequest <= 0;
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		repeat(230) begin
			@(posedge clk);
		end
		@(posedge clk); ghostRequest <= 0;
		@(posedge clk); ghostRequest <= 1;
		@(posedge clk); ghostRequest <= 0;
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		repeat(230) begin
			@(posedge clk);
		end
		@(posedge clk); ghostRequest <= 0;
		@(posedge clk); ghostRequest <= 1;
		@(posedge clk); ghostRequest <= 0;
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		repeat(230) begin
			@(posedge clk);
		end
		@(posedge clk); ghostRequest <= 0;
		@(posedge clk); ghostRequest <= 1;
		@(posedge clk); ghostRequest <= 0;
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		repeat(230) begin
			@(posedge clk);
		end
		@(posedge clk); ghostRequest <= 0;
		@(posedge clk); ghostRequest <= 1;
		@(posedge clk); ghostRequest <= 0;
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		repeat(230) begin
			@(posedge clk);
		end
		@(posedge clk); ghostRequest <= 0;
		@(posedge clk); ghostRequest <= 1;
		@(posedge clk); ghostRequest <= 0;
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		repeat(230) begin
			@(posedge clk);
		end
	end
endmodule // ghostMode_tb