/********************************************************************************
	Author: 		Nguyen Lai
	------------------------------------------------------------------------
	Module:		UART Receiver
	------------------------------------------------------------------------
	Description:	module that interpret signal sent from Bluetooth Module 
	------------------------------------------------------------------------
	Ports:			
					clk				-	input clock
					rx_serial		-	input from Bluetooth module
					completeBit		-	set high when finish interpreting the signal
					rx_out			-	result from interpreting the UART signal
	------------------------------------------------------------------------
	EE371 Class, Spring 2018
********************************************************************************/

module uart_receiver(clk, rx_serial, completeBit, rx_out);
	input logic clk, rx_serial;
	output logic completeBit;
	output logic [7:0] rx_out;
	
	logic [7:0] rx_byte;
	
	enum {idle, startBit, dataBits, endBit, restart} state;
	parameter CYCLES_PER_BIT = 434; // (50 MHz / 115200)
	
	logic [8:0] counter;
	logic [2:0] dataIndex;
	
	always_ff @(posedge clk)
		begin
			case (state)
			
				idle: // Idle state. If there is no signal input, stay at this state forever.
					  // If there is signal sent from Bluetooth module -> go to next state: startBit
					begin
						completeBit <= 0;
						counter <= 9'd0;
						dataIndex <= 3'd0;
						//rx_byte <= 8'b11111111;
						if(rx_serial == 1'b0)
							state <= startBit;
						else
							state <= idle;
					end
					
				startBit: // startBit state. Sample the signal until the middle point. 
						  // If the signal is still low as expected -> go to next state
						  // If somehow the signal is not low -> there is an error -> go back to idle state
					begin
						if (counter == (CYCLES_PER_BIT-1)/2) // Looking for the middle bit
							begin
								if (rx_serial == 0) // If it's still low
									begin
										counter <= 0; // Found the middle, reset counter
										state <= dataBits; // Going into dataBits
									end
								else
									begin
										state <= idle;
									end
							end
						else
							begin
								counter <= counter + 1;
								state <= startBit;
							end
					end
					
				dataBits: // Begin sampling the 8-bit signal. Sample until the middle point of the signal. 
					begin
						if (counter < (CYCLES_PER_BIT-1)) 
							begin
								counter <= counter + 1;
								state <= dataBits;
							end
						else 
							begin
								counter <= 0; // Reset count
								rx_byte[dataIndex] <= rx_serial;
								
								if (dataIndex < 7) 
									begin
										dataIndex <= dataIndex + 1;
										state <= dataBits;
									end
								else
									begin
										dataIndex <= 0;
										state <= endBit;
									end
							end
					end
								
				endBit: // Sample the endBit
					begin
						if (counter < (CYCLES_PER_BIT-1))
							begin
								counter <= counter + 1;
								state <= endBit;
							end
						else
							begin
								completeBit <= 1;
								counter <= 0;
								rx_out <= rx_byte;
								state <= restart;
							end
					end
					
				restart: // A restart state is implemented to prevent timing issues. 
					begin
						state <= idle;
						completeBit <= 0;
					end			
			endcase 
		end

endmodule

module uart_receiver_tb();
	logic clk, rx_serial;
	logic completeBit;
	logic [7:0] rx_out;
	
	uart_receiver dut(.clk, .rx_serial, .completeBit, .rx_out);
	
// Takes in input byte and serializes it 
  task UART_WRITE_BYTE;
    input [7:0] Data;
    integer     i;
    begin
      
      // Send Start Bit
      rx_serial <= 1'b0;
      #8600;
      #1000;
      
      // Send Data Byte
      for (i=0; i<8; i=i+1)
        begin
          rx_serial <= Data[i];
          #8600;
        end
      
      // Send Stop Bit
      rx_serial <= 1'b1;
      #8600;
     end
  endtask // UART_WRITE_BYTE
	
	parameter CLOCK_PERIOD=20;
	initial begin
	clk <= 0;
	forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end
	
	initial begin
	@(posedge clk); 
	@(posedge clk); 
	@(posedge clk); UART_WRITE_BYTE(8'd99);
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
	@(posedge clk); UART_WRITE_BYTE(8'd20);
	@(posedge clk); 
	@(posedge clk); 
	@(posedge clk);
	@(posedge clk); 
	@(posedge clk); 
	$stop;
	end
endmodule

