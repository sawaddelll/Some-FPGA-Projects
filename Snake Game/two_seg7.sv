module seg7 (bcd, leds);
 input logic [3:0] bcd;
 output logic [6:0] leds;

 always_comb begin
 case (bcd)
          // Light: 6543210
 4'b0000: leds = 7'b0111111; // 0
 4'b0001: leds = 7'b0000110; // 1
 4'b0010: leds = 7'b1011011; // 2
 4'b0011: leds = 7'b1001111; // 3
 4'b0100: leds = 7'b1100110; // 4
 4'b0101: leds = 7'b1101101; // 5
 4'b0110: leds = 7'b1111101; // 6
 4'b0111: leds = 7'b0000111; // 7
 4'b1000: leds = 7'b1111111; // 8
 4'b1001: leds = 7'b1101111; // 9
 default: leds = 7'bX;
 endcase
 leds= ~leds;
 end
endmodule 

module two_seg7 (HEX0, HEX1, in1, in2);
	output logic [6:0] HEX0, HEX1;
	input logic [3:0] in1, in2;
	
	seg7 first (.bcd(in1), .leds(HEX0));
	seg7 second (.bcd(in2), .leds(HEX1));
	
endmodule 

module two_seg7_testbench();   
logic  [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;    
logic  [9:0] LEDR;    
logic  [3:0] KEY;    
logic [9:0] SW;
logic  [3:0] in1, in2;     
two_seg7 dut (.HEX0, .HEX1, .in1(SW[7:4]), .in2(SW[3:0]));    
 //Try all combinations of inputs.   
integer i;  
 initial begin 
	SW[9] = 1'b0;    
	SW[8] = 1'b0; 

	for(i = 0; i <256; i++) begin    
		{SW[7:4],SW[3:0]} = i;
		#10;    
	end   
 end  
 endmodule