module DE1_SOC(

//	//////////// ADC //////////
//	output		          		ADC_CONVST,
//	output		          		ADC_DIN,
//	input 		          		ADC_DOUT,
//	output		          		ADC_SCLK,
//
//	//////////// Audio //////////
//	input 		          		AUD_ADCDAT,
//	inout 		          		AUD_ADCLRCK,
//	inout 		          		AUD_BCLK,
//	output		          		AUD_DACDAT,
//	inout 		          		AUD_DACLRCK,
//	output		          		AUD_XCK,

	//////////// CLOCK //////////
//	input 		          		CLOCK2_50,
//	input 		          		CLOCK3_50,
//	input 		          		CLOCK4_50,
	input 		          		CLOCK_50,

//	//////////// SDRAM //////////
//	output		    [12:0]		DRAM_ADDR,
//	output		     [1:0]		DRAM_BA,
//	output		          		DRAM_CAS_N,
//	output		          		DRAM_CKE,
//	output		          		DRAM_CLK,
//	output		          		DRAM_CS_N,
//	inout 		    [15:0]		DRAM_DQ,
//	output		          		DRAM_LDQM,
//	output		          		DRAM_RAS_N,
//	output		          		DRAM_UDQM,
//	output		          		DRAM_WE_N,
//
//	//////////// I2C for Audio and Video-In //////////
//	output		          		FPGA_I2C_SCLK,
//	inout 		          		FPGA_I2C_SDAT,

	//////////// SEG7 //////////
	output		     [6:0]		HEX0,
	output		     [6:0]		HEX1,
	output		     [6:0]		HEX2,
	output		     [6:0]		HEX3,
	output		     [6:0]		HEX4,
	output		     [6:0]		HEX5,

//	//////////// IR //////////
//	input 		          		IRDA_RXD,
//	output		          		IRDA_TXD,

	//////////// KEY //////////
	input 		     [3:0]		KEY,

	//////////// LED //////////
	output		     [9:0]		LEDR,

//	//////////// PS2 //////////
//	inout 		          		PS2_CLK,
//	inout 		          		PS2_CLK2,
//	inout 		          		PS2_DAT,
//	inout 		          		PS2_DAT2,

	//////////// SW //////////
	input 		     [9:0]		SW	//,

//	//////////// Video-In //////////
//	input 		          		TD_CLK27,
//	input 		     [7:0]		TD_DATA,
//	input 		          		TD_HS,
//	output		          		TD_RESET_N,
//	input 		          		TD_VS,
//
//	//////////// VGA //////////
//	output		          		VGA_BLANK_N,
//	output		     [7:0]		VGA_B,
//	output		          		VGA_CLK,
//	output		     [7:0]		VGA_G,
//	output		          		VGA_HS,
//	output		     [7:0]		VGA_R,
//	output		          		VGA_SYNC_N,
//	output		          		VGA_VS
);



//=======================================================
//  REG/WIRE declarations
//=======================================================

logic [31:0] clk;



//=======================================================
//  Structural coding
//=======================================================


clock_divider slowingClock (.reset(0), .clock(CLOCK_50), .divided_clocks(clk));

//so far only basic connections between the CPU and inputs/outputs of DE1_SoC, as simple checks that the code executed correctly.
pipinghotCPU cpu (.clk(CLOCK_50), .reset(SW[9]), .HEX0(HEX0), .HEX1(HEX1), 
						.HEX2(HEX2), .HEX3(HEX3), .HEX4(HEX4), .HEX5(HEX5));

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

