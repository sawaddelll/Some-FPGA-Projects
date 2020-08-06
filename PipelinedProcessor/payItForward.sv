`timescale 1ns/10ps

// Forwarding logic for pipelined processor.
// Handles forwarding to RF stage when instruction in RF stage tries accessing registers that are 
// still being written by previous instructions (data forwarded from EX or MEM stages). 
// Can't forward results of LDUR instruction from 1 cycle ago (results don't exist yet--load delay slot).
// Module also handles sending flags from the ALU to the processor's control logic (which exists in RF stage)
module payItForward (Rn_RF, Rm_RF, Rd_EX, Rd_MEM, Rd_RF, negative, zero, overflow,
 carry_out, Opcode_RF, OPcode_MEM, Opcode_EX, CBZ_zeroFlag, zero_control, overflow_control, 
 carryout_control, negative_control, ExecStageOutput_EX, ExecStageOutput_MEM, clk, Output_LogicA, Output_LogicB, flagA, flagB, DataFromMem);

 
 
input logic negative, zero, overflow, carry_out, CBZ_zeroFlag, clk; 
input logic [10:0] Opcode_RF, Opcode_EX, OPcode_MEM;
input logic [63:0] ExecStageOutput_EX, ExecStageOutput_MEM, DataFromMem;
output logic [63:0] Output_LogicA, Output_LogicB;
output logic flagA, flagB, zero_control, overflow_control, carryout_control, negative_control; 
input logic [4:0] Rn_RF, Rm_RF, Rd_EX, Rd_MEM, Rd_RF;
logic EX_forwardA, EX_forwardB,  MEM_forwardA, MEM_forwardB;
logic [63:0] EX_LogicA, EX_LogicB, MEM_LogicA, MEM_LogicB; 
logic negative_Flag, zero_Flag, overflow_Flag, carryout_Flag;

parameter 
ADDI = 11'b1001000100x,
ADDS = 11'b10101011000,
AND =  11'b10001010000,
B =    11'b000101xxxxx,
BLT =  11'b01010100xxx,
CBZ =  11'b10110100xxx,
EOR =  11'b11001010000,
LDUR = 11'b11111000010,
LSR =  11'b11010011010,
STUR = 11'b11111000000,
SUBS = 11'b11101011000;


always_ff @(posedge clk) begin // storing flags from SUBS and ADDS operations
	if((Opcode_EX == SUBS) || (Opcode_EX == ADDS)) begin
		negative_Flag <= negative;
		zero_Flag <= zero;
		overflow_Flag <= overflow;
		carryout_Flag <= carry_out;
	end
end


always_comb begin //Logic for sending flags from ALU to control logic

	if(Opcode_RF[10:3] == 8'b10110100)begin //Remember, this did NOT work w/ CBZ benchmark //FIXED Now
		zero_control = CBZ_zeroFlag; 
	end
	else if((Opcode_EX == 11'b11101011000) || (Opcode_EX == 11'b10101011000))begin //SUBS, ADDS
		zero_control = zero;
	end
	else begin
		zero_control = zero_Flag;
	end
	
	if((Opcode_EX == 11'b11101011000) || (Opcode_EX == 11'b10101011000))begin //SUBS, ADDS
		//zero_control = zero;
		overflow_control = overflow;
		carryout_control = carry_out;
		negative_control = negative;
		

	end
	else begin
		//zero_control = zero_Flag;
		overflow_control = overflow_Flag;
		carryout_control = carryout_Flag;
		negative_control = negative_Flag;
	end
	
end
	
	

//defining from what stage something will possibly be forwarded
//(i.e. deciding if the forwarded data will be from EX or MEM stages,  
// but not deciding whether that data actually needs to/will be forwarded
always_comb begin 
	if((Opcode_RF[10:3] == 8'b10110100) || (Opcode_RF == STUR)) begin //CBZ, STUR
		if(Rd_RF == Rd_EX)begin 
			if (Rd_RF == 5'b11111) begin //If accessing X31, can just forward 0 (reg. 31 is always 0).
				Output_LogicB = 64'b0;
			end 
			else begin
				Output_LogicB = EX_LogicB;
			end
			//Output_LogicB = EX_LogicB;
			flagB = EX_forwardB;
			end
		else if (Rd_RF == Rd_MEM)begin
			if (Rd_RF == 5'b11111) begin ////////
				Output_LogicB = 64'b0;
			end 
			else begin
				Output_LogicB = MEM_LogicB;
			end
			//Output_LogicB = MEM_LogicB;
			flagB = MEM_forwardB;
			end
		else begin
			flagB = 0;
			Output_LogicB = 64'bx;
			end
	end 

	else begin
		if(Rm_RF == Rd_EX)begin 
			if (Rm_RF == 5'b11111) begin /////////////
				Output_LogicB = 64'b0;
			end 
			else begin
				Output_LogicB = EX_LogicB;
			end
			//Output_LogicB = EX_LogicB;
			flagB = EX_forwardB;
			end
		else if (Rm_RF == Rd_MEM)begin
			if (Rm_RF == 5'b11111) begin////////
				Output_LogicB = 64'b0;
			end 
			else begin
				Output_LogicB = MEM_LogicB;
			end
			//Output_LogicB = MEM_LogicB;
			flagB = MEM_forwardB;
			end
		else begin
			flagB = 0;
			Output_LogicB = 64'bx;
		end
	end
	
	if(Rn_RF == Rd_EX)begin 
		flagA = EX_forwardA;
		if (Rn_RF == 5'b11111) begin////////
			Output_LogicA = 64'b0;
		end 
		else begin
			Output_LogicA = EX_LogicA;
		end
	end
	else if (Rn_RF == Rd_MEM)begin
		if (Rn_RF == 5'b11111) begin////////////
			Output_LogicA = 64'b0;
		end 
		else begin
			Output_LogicA = MEM_LogicA;
		end
		//Output_LogicA = MEM_LogicA;
		flagA = MEM_forwardA;
	end
	else begin
		flagA = 0;
		Output_LogicA = 64'bx;

	end
end
	
always_comb begin
	//compares operations and operands in EX and RF stages 
	//to determine whether something must be forwarded from EX stage
	casex(Opcode_EX)
		//these instructions allow for potentially forwarding to next instruction (EX to RF)
		ADDI, ADDS, AND, EOR, LSR, SUBS: begin 
		
				casex(Opcode_RF) 
				CBZ:begin
						EX_forwardA = 0;
						EX_LogicA  = 64'bx;
			
						if(Rd_RF == Rd_EX)begin
						EX_forwardB = 1;
					
						EX_LogicB = ExecStageOutput_EX;
						end
					
						else begin
						EX_forwardB = 0;
						EX_LogicB = 64'bx; 
						end
				end
		
				LSR, LDUR, ADDI: begin
						EX_forwardB = 0;
						EX_LogicB = 64'bx;
				
						if(Rn_RF == Rd_EX)begin
							EX_forwardA = 1;
							EX_LogicA = ExecStageOutput_EX;
						end
						else begin
						EX_forwardA = 0;
						EX_LogicA = 64'bx;
						end
			
				end
			
				STUR: begin
						if(Rd_RF == Rd_EX)begin
							EX_forwardB = 1;		
							EX_LogicB = ExecStageOutput_EX;
						end
		
						else begin
							EX_forwardB = 0;
							EX_LogicB = 64'bx;
						end
					
						if(Rn_RF == Rd_EX)begin
							EX_forwardA = 1;			
							EX_LogicA = ExecStageOutput_EX;
						end
						
						else begin
							EX_forwardA = 0;
							EX_LogicA = 64'bx;
						end
				end
			
			
				default: begin
					if(Rm_RF == Rd_EX)begin
						EX_forwardB = 1;		
						EX_LogicB = ExecStageOutput_EX;
					end
					
					else begin
						EX_forwardB = 0;
						EX_LogicB = 64'bx;
					end
				
					if(Rn_RF == Rd_EX)begin ///////
						EX_forwardA = 1;			
						EX_LogicA = ExecStageOutput_EX;
					end
					
					else begin
						EX_forwardA = 0;
						EX_LogicA = 64'bx;
					end
				end

			endcase
			end
		
		//Can't forward from EX to RF stages if EX is carrying out LDUR operation (load delay slot)	
		LDUR: begin 
			EX_forwardA = 0;
			EX_LogicA  = 64'bx;
			EX_forwardB = 0;
			EX_LogicB = 64'bx;
			end
			
		default: begin
			EX_forwardA = 0;
			EX_LogicA  = 64'bx;
			EX_forwardB = 0;
			EX_LogicB = 64'bx;
			end

	endcase

	
	//compares operations between RF and MEM stages
	//to determine whether something from MEM stage must be forwarded to RF stage
	//(forwarding ALU output that is in MEM stage after passing through register wall from EX stage,
	//or data from memory operations)
	casex(OPcode_MEM)
		ADDI, ADDS, AND, EOR, LSR, SUBS: begin 
				casex(Opcode_RF)
					CBZ:begin
							MEM_forwardA = 0;
							MEM_LogicA  = 64'bx;
		
						if(Rd_RF == Rd_MEM)begin
							MEM_forwardB = 1;
							MEM_LogicB = ExecStageOutput_MEM;
						end
					
						else begin
							MEM_forwardB = 0;
							MEM_LogicB = 64'bx;
						end
					end
		
					LSR, LDUR, ADDI: begin
							MEM_forwardB = 0;
							MEM_LogicB = 64'bx;
			
						if(Rn_RF == Rd_MEM)begin
							MEM_forwardA = 1;
							MEM_LogicA = ExecStageOutput_MEM;
						end
			
						else begin
							MEM_forwardA = 0;
							MEM_LogicA = 64'bx;
						end
					end
		
		
					STUR: begin
						if(Rd_RF == Rd_MEM)begin
							MEM_forwardB = 1;		
							MEM_LogicB = ExecStageOutput_MEM;
						end
					
						else begin
							MEM_forwardB = 0;
							MEM_LogicB = 64'bx;
						end
				
						if(Rn_RF == Rd_MEM)begin
							MEM_forwardA = 1;			
							MEM_LogicA = ExecStageOutput_MEM;
						end
				
						else begin
							MEM_forwardA = 0;
							MEM_LogicA = 64'bx;
						end
					end
			
					default: begin
						if(Rm_RF == Rd_MEM)begin
							MEM_forwardB = 1;		
							MEM_LogicB = ExecStageOutput_MEM;
						end
					
						else begin
							MEM_forwardB = 0;
							MEM_LogicB = 64'bx;
						end
				
						if(Rn_RF == Rd_MEM)begin
							MEM_forwardA = 1;			
							MEM_LogicA = ExecStageOutput_MEM;
						end
				
						else begin
							MEM_forwardA = 0;
							MEM_LogicA = 64'bx;
						end
					end
				endcase
		end
		
		LDUR:begin //MEM to RF forwarding of LDUR results is fine (load delay slot is respected)
				casex(Opcode_RF)
					CBZ:begin
							MEM_forwardA = 0;
							MEM_LogicA  = 64'bx;
			
						if(Rd_RF == Rd_MEM)begin
							MEM_forwardB = 1;
							MEM_LogicB = DataFromMem; //
						end
					
						else begin
							MEM_forwardB = 0;
							MEM_LogicB = 64'bx;
						end
					end
		
					LSR, LDUR, ADDI: begin
							MEM_forwardB = 0;
							MEM_LogicB = 64'bx;
				
						if(Rn_RF == Rd_MEM)begin
							MEM_forwardA = 1;
							MEM_LogicA = DataFromMem; //
						end
					
						else begin
							MEM_forwardA = 0;
							MEM_LogicA = 64'bx;
						end
					end
				
					STUR: begin
						if(Rd_RF == Rd_MEM)begin
							MEM_forwardB = 1;		
							MEM_LogicB = DataFromMem;
						end
					
						else begin
							MEM_forwardB = 0;
							MEM_LogicB = 64'bx;
						end
				
						if(Rn_RF == Rd_MEM)begin
							MEM_forwardA = 1;			
							MEM_LogicA = DataFromMem;
						end
				
						else begin
							MEM_forwardA = 0;
							MEM_LogicA = 64'bx;
						end
					end
		
					default: begin
						if(Rm_RF == Rd_MEM)begin
							MEM_forwardB = 1;		
							MEM_LogicB = DataFromMem;
						end
					
						else begin
							MEM_forwardB = 0;
							MEM_LogicB = 64'bx;
						end
				
						if(Rn_RF == Rd_MEM)begin
							MEM_forwardA = 1;			
							MEM_LogicA = DataFromMem;
						end
				
						else begin
							MEM_forwardA = 0;
							MEM_LogicA = 64'bx;
						end
					end
				endcase
		end
		
		default: begin
			MEM_forwardA = 0;
			MEM_LogicA  = 64'bx;
			MEM_forwardB = 0;
			MEM_LogicB = 64'bx;
		end

	endcase
	
end

endmodule
