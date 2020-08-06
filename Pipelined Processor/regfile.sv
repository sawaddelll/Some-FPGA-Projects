// EE469
`timescale 1ns/10ps

// Register file for processor, w/ 32 registers (0-31). Register 31 is always 0.
// Has 2 read ports and 1 write port.
module regfile (ReadData1, ReadData2, WriteData, ReadRegister1, ReadRegister2, 
WriteRegister,  RegWrite, clk, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);

 input logic [4:0] ReadRegister1, ReadRegister2, WriteRegister;
 input logic [63:0] WriteData;
 input logic clk, RegWrite;
 output logic [63:0] ReadData1, ReadData2;
 output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
 logic [31:0][63:0]regout ;
 logic [31:0] decoded;
		
			

 decoder_5to32 decode (.in5(WriteRegister[4:0]), .out32(decoded[31:0]), .enabler(RegWrite));
 
  genvar i;
 
  generate 
  for(i=0; i<31; i++) begin: registers 
  REGISTER register (.q(regout[i][63:0]), .d(WriteData[63:0]), .enable(decoded[i]), .clk(clk));
  end 
  endgenerate 	
  
  assign regout[31][63:0] = 0;
  
  MUX32by64_64 mux1 (.regout, .sel(ReadRegister1), .out(ReadData1));
  MUX32by64_64 mux2 (.regout, .sel(ReadRegister2), .out(ReadData2));
  
  
  // Only connected registers to HEX display as experiment with implementing processor 
  // in hardware and connecting it to outputs on the on DE1_SoC
  // While running "test11_Sort", HEX will display 1 2 3 4 5 6.
  two_seg7 displayingRegisters (.HEX0, .HEX1, .in1(regout[16][3:0]), .in2(regout[15][3:0]));
  two_seg7 displayingRegisters2 (.HEX0(HEX2), .HEX1(HEX3), .in1(regout[14][3:0]), .in2(regout[13][3:0]));
  two_seg7 displayingRegisters3 (.HEX0(HEX4), .HEX1(HEX5), .in1(regout[12][3:0]), .in2(regout[11][3:0]));
  endmodule 
  
  
  
  
  
  
// Test bench for Register file
module regstim(); 		

	parameter ClockDelay = 5000;

	logic	[4:0] 	ReadRegister1, ReadRegister2, WriteRegister;
	logic [63:0]	WriteData;
	logic 			RegWrite, clk;
	logic [63:0]	ReadData1, ReadData2;

	integer i;

	// Your register file MUST be named "regfile".
	// Also you must make sure that the port declarations
	// match up with the module instance in this stimulus file.
	regfile dut (.ReadData1, .ReadData2, .WriteData, 
					 .ReadRegister1, .ReadRegister2, .WriteRegister,
					 .RegWrite, .clk);

	// Force %t's to print in a nice format.
	initial $timeformat(-9, 2, " ns", 10);

	initial begin // Set up the clock
		clk <= 0;
		forever #(ClockDelay/2) clk <= ~clk;
	end

	initial begin
		// Try to write the value 0xA0 into register 31.
		// Register 31 should always be at the value of 0.
		RegWrite <= 5'd0;
		ReadRegister1 <= 5'd0;
		ReadRegister2 <= 5'd0;
		WriteRegister <= 5'd31;
		WriteData <= 64'h00000000000000A0;
		@(posedge clk);
		
		$display("%t Attempting overwrite of register 31, which should always be 0", $time);
		RegWrite <= 1;
		@(posedge clk);

		// Write a value into each  register.
		$display("%t Writing pattern to all registers.", $time);
		for (i=0; i<31; i=i+1) begin
			RegWrite <= 0;
			ReadRegister1 <= i-1;
			ReadRegister2 <= i;
			WriteRegister <= i;
			WriteData <= i*64'h0000010204080001;
			@(posedge clk);
			
			RegWrite <= 1;
			@(posedge clk);
		end

		// Go back and verify that the registers
		// retained the data.
		$display("%t Checking pattern.", $time);
		for (i=0; i<32; i=i+1) begin
			RegWrite <= 0;
			ReadRegister1 <= i-1;
			ReadRegister2 <= i;
			WriteRegister <= i;
			WriteData <= i*64'h0000000000000100+i;
			@(posedge clk);
		end
		$stop;
	end
endmodule