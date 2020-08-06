// Samson Waddell, EE 371, Spring 2018
//
// collisionDetection takes in arrays that show where the full snake is on the display, for each snake, as well as
// each snake's head coordinates, and whether that snake is in its grace period at the start of the game. Signals for each
// snake's ghost mode are also input. The arrays passed in must be the proper size, matching the WIDTH and HEIGHT parameters 
// that represent the size of the display.
// Using these inputs, the module checks for a snake either colliding with itself, or another snake,
// and when that happens the dead output for that snake becomes true, unless ghost is active.

module collisionDetection #(parameter WIDTH = 32, parameter HEIGHT =32) 
						   (reset, clk, body1, body2, body3, head1x, head2x, head3x, head1y, head2y, head3y,
							dead1, dead2, dead3, gracePeriod1, gracePeriod2, gracePeriod3,
							ghost1, ghost2, ghost3);
	
	input logic reset, clk;
	input logic ghost1, ghost2, ghost3;
	input logic [WIDTH-1:0][HEIGHT-1:0] body1, body2, body3;
	input logic gracePeriod1, gracePeriod2, gracePeriod3;
	input logic [6:0] head1x, head1y, head2x, head2y, head3x, head3y;
	output logic dead1, dead2, dead3;
	enum {alive, dead} ps1, ps2, ps3, ns1, ns2, ns3;
	
	always_comb
	begin
		case(ps1)
			alive: 
				if ( ( (head1x == head2x && head1y == head2y && !ghost1) || (head1x == head3x && head1y == head3y && !ghost1) ||
						(body2[head1x][head1y] && !ghost1) || (body1[head1x][head1y]) || (body3[head1x][head1y] && !ghost1)) && !gracePeriod1)
				begin
					ns1 = dead; dead1 = 1;
				end
				else 
				begin
					ns1 = alive; dead1 = 0;
				end
			dead:
			begin	
				ns1 = dead; dead1 = 1;
			end
		endcase
		
		case(ps2)
			
			alive:
				if ( ( (head1x == head2x && head1y == head2y && !ghost2) || (head2x == head3x && head2y == head3y && !ghost2) ||
						(body1[head2x][head2y] && !ghost2) || (body2[head2x][head2y]) || (body3[head2x][head2y]&& !ghost2)) && !gracePeriod2 ) 
				begin
					ns2 = dead; dead2 = 1;
				end
				else 
				begin
					ns2 = alive; dead2 = 0;
				end
					
			dead:
			begin	
				ns2 = dead; dead2 = 1;
			end
		endcase
		
		case(ps3)
			alive:
				if (((head3x == head2x && head3y == head2y && !ghost3) || (head1x == head3x && head1y == head3y && !ghost3) ||
						(body2[head3x][head3y] && !ghost3) || (body1[head3x][head3y] && !ghost3) || (body3[head3x][head3y])) && !gracePeriod3)
				begin
					ns3 = dead; dead3 = 1;
				end
				else 
				begin
					ns3 = alive; dead3 = 0;
				end
					
			dead:
			begin	
				ns3 = dead; dead3 = 1;
			end
		endcase
	end
	
	always_ff @(posedge clk)
	begin	
		if (!reset) 
		begin	
			ps1 <= alive; ps2 <= alive; ps3 <= alive;
		end
		else 
		begin
			ps1 <= ns1; ps2 <= ns2; ps3 <= ns3;
		end
	end
endmodule
			
