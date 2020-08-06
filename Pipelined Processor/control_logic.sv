`timescale 1ns/10ps

// Control Logic for the microprocessor.
// Based on the instruction, sets the control signals for MUXs, ALU, memory, etc. throughout the design.
// Also, breaks up instruction into its parts (opcode, Rn, Rm, Rd, etc.).
module control_logic (clk, ALU_Op, instruction, zero, negative, overflow, Reg2Loc, ALUSrc, MemToReg, RegWrite, 
			MemWrite, BrTaken, UncondBr, ADDIsignal,shift,Rd, Rn, Rm, BrAddr26, CondAddr19, SHAMT, ALU_Imm12, DT_Address9, carryout, instruct, CBZ_zeroFlag); 
output logic [2:0] ALU_Op;
input logic [31:0] instruction;
input logic zero, negative, overflow, carryout, clk, CBZ_zeroFlag;
output logic Reg2Loc, ALUSrc, MemToReg, RegWrite, MemWrite, BrTaken, UncondBr, ADDIsignal, shift;
output logic [10:0] instruct;
	output logic [4:0] Rd, Rm, Rn;
	output logic [8:0] DT_Address9;
	output logic [11:0] ALU_Imm12;
	output logic [18:0] CondAddr19;
	output logic [25:0] BrAddr26;
	output logic [5:0] SHAMT;
logic zeroFlag, negativeFlag, overflowFlag, carry_outFlag;
logic [10:0] Opcode_RF;
parameter 
ADDI = 11'b1001000100x,
ADDS = 11'b10101011000,
AND =  11'b10001010000,
B =    11'b000101xxxxx,
BLT = 11'b01010100xxx,
CBZ =  11'b10110100xxx,
EOR =  11'b11001010000,
LDUR = 11'b11111000010,
LSR =  11'b11010011010,
STUR = 11'b11111000000,
SUBS = 11'b11101011000;
assign Opcode_RF = instruction[31:21];

// split up instruction into opcode, operands, etc.
always_comb begin
Rd = instruction[4:0];
Rn = instruction[9:5];
Rm = instruction[20:16];
BrAddr26 = instruction[25:0];
CondAddr19 = instruction[23:5];
SHAMT = instruction[15:10];
ALU_Imm12 = instruction[21:10];
DT_Address9 = instruction[20:12];
instruct = instruction[31:21];
end


// control signals are set based on the instruction
always_comb begin
casex(instruct)
	ADDI: begin						//
		Reg2Loc = 1'bx;
		ALUSrc  = 1'b1;
		MemToReg = 1'b0;
		RegWrite = 1'b1;
		MemWrite = 1'b0;
		BrTaken  = 1'b0;
		UncondBr = 1'bx;
		ALU_Op  = 3'b010;
		ADDIsignal = 1'b1;
		shift = 0;
	end 
	
	ADDS: begin						//				
		Reg2Loc = 1'b1;
		ALUSrc  = 1'b0;
		MemToReg = 1'b0;
		RegWrite = 1'b1;
		MemWrite = 1'b0;
		BrTaken  = 1'b0;
		UncondBr = 1'bx;
		ALU_Op  = 3'b010;
		ADDIsignal = 1'b0;
		shift = 0;

	end 
	
	AND: begin					//
		Reg2Loc = 1'b1;
		ALUSrc  = 1'b0;
		MemToReg = 1'b0;
		RegWrite = 1'b1;
		MemWrite = 1'b0;
		BrTaken  = 1'b0;
		UncondBr = 1'bx;
		ALU_Op  = 3'b100;
		ADDIsignal = 1'b0;
		shift = 0;

	end 
	
	B: begin						//
		Reg2Loc = 1'bx;
		ALUSrc  = 1'bx;
		MemToReg = 1'bx;
		RegWrite = 1'b0;
		MemWrite = 1'b0;
		BrTaken  = 1'b1;
		UncondBr = 1'b1;
		ALU_Op  = 3'b010;
		ADDIsignal = 1'b0;
		shift = 0;
	end 
	
	BLT: begin				//
		Reg2Loc = 1'b1;
		ALUSrc  = 1'b0;
		MemToReg = 1'b0;
		RegWrite = 1'b0;
		MemWrite = 1'b0;
		BrTaken  = negative ^ overflow;
		UncondBr = 1'b0;
		ALU_Op  = 3'b010;
		ADDIsignal = 1'b0;
		shift = 0;
		
	end 
	
	CBZ: begin					//
		Reg2Loc = 1'b0;
		ALUSrc  = 1'b0;
		MemToReg = 1'bx;
		RegWrite = 1'b0;
		MemWrite = 1'b0;
		BrTaken  = zero; //CBZ_zeroFlag;
		UncondBr = 1'b0;
		ALU_Op  = 3'b000;
		ADDIsignal = 1'b0;
		shift = 0;
	end 
	
	EOR: begin					//
		Reg2Loc = 1'b1;
		ALUSrc  = 1'b0;
		MemToReg = 1'b0;
		RegWrite = 1'b1;
		MemWrite = 1'b0;
		BrTaken  = 1'b0;
		UncondBr = 1'bx;
		ALU_Op  = 3'b110;
		ADDIsignal = 1'b0;
		shift = 0;
	end 
	
	LDUR: begin				//
		Reg2Loc = 1'bx;
		ALUSrc  = 1'b1;
		MemToReg = 1'b1;
		RegWrite = 1'b1;
		MemWrite = 1'b0;
		BrTaken  = 1'b0;
		UncondBr = 1'bx;
		ALU_Op  = 3'b010;
		ADDIsignal = 1'b0;
		shift = 0;
	end 
	
	LSR: begin				//					
		Reg2Loc = 1'bx;
		ALUSrc  = 1'bx;
		MemToReg = 1'b0;
		RegWrite = 1'b1;
		MemWrite = 1'b0;
		BrTaken  = 1'b0;
		UncondBr = 1'bx;
		ALU_Op  = 3'bxxx;
		ADDIsignal = 1'bx;
		shift = 1;
	end 
	
	STUR: begin					//
		Reg2Loc = 1'b0;
		ALUSrc  = 1'b1;
		MemToReg = 1'bx;
		RegWrite = 1'b0;
		MemWrite = 1'b1;
		BrTaken  = 1'b0;
		UncondBr = 1'bx;
		ALU_Op  = 3'b010;
		ADDIsignal = 1'b0;
		shift = 0;
	end 
	
	SUBS: begin					//
		Reg2Loc = 1'b1;
		ALUSrc  = 1'b0;
		MemToReg = 1'b0;
		RegWrite = 1'b1;
		MemWrite = 1'b0;
		BrTaken  = 1'b0;
		UncondBr = 1'bx;
		ALU_Op  = 3'b011;
		ADDIsignal = 1'b0;
		shift = 0;
	end 
	
	default: begin
		Reg2Loc = 1'bx;
		ALUSrc  = 1'bx;
		MemToReg = 1'bx;
		RegWrite = 1'b0;
		MemWrite = 1'b0;
		BrTaken  = 1'b0;
		UncondBr = 1'b0;
		ALU_Op  = 3'bxxx;
		ADDIsignal = 1'bx;
		shift = 0;
	end
	
	endcase
	end
	
endmodule 