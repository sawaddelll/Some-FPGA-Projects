`timescale 1ns/10ps
//Sam Waddell, Jon Champion EE 469

// ARM Pipelined CPU
// Currently handles {ADDI, ADDS, AND, B, BLT, CBZ, EOR, LDUR, LSR, STUR, and SUBS} ARM instructions.
// Features forwarding from EX/MEM stages to RF stage. 
// Uses branch delay slot (instruction after branch always executed), and
// uses load delay slot (instruction immediately after load can't access register being loaded).
// This was the top-level of the processor as originally simulated. 
// Only inputs are a clock and reset. 4 HEX displays are basic output.
module pipinghotCPU (clk, reset, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);
input logic clk, reset;
output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;

// Control Signals, register and memory values, instructions, instruction components, the program counter,
// and the walls of registers between pipeline stages...

logic [4:0] Rn_RF, Rm_RF, Rd_EX, Rm_EX, Rn_EX, Rd_MEM, Rd_RF, Ab, Rd_WB, Rm_MEM, Rn_MEM;
logic negative, zero, overflow, carry_out, CBZ_zeroFlag, zero_control, overflow_control, carryout_control, negative_control;
logic Reg2Loc_RF, ALUSrc_RF, MemToReg_RF, RegWrite_RF, MemWrite_RF, BrTaken_RF_immediateResult, UncondBr_RF, ADDIsignal_RF, shift_RF;
logic inverse_clk, flagA, flagB, MemWrite_MEM, read_enable_MEM, MemToReg_MEM, RegWrite_MEM, shift_EX, RegWrite_EX, MemWrite_EX, MemToReg_EX;
logic [10:0] Opcode_RF, Opcode_EX, Opcode_MEM;
logic [63:0] currentPC, lastPC, Imm9Extended, Imm19Extended, BrAddr26Extended, DataA, DataB, DataToReg_RF, Imm12Extended, extendedImmediateForALU;
logic [63:0] RegisterDataB_RF, Operand2_RF, Output_LogicA, Operand1_RF, Output_LogicB, FullBranchAmount, ShiftedBranchAmount;
logic [63:0] incremPCAddress, BranchAddress_immediateResult, BranchAddress_RF, DataB_EX, Operand2_EX, Operand1_EX, SHAMTextended, ALUoutput_EX;
logic [63:0] ShiftedDataA, ExecStageOutput_MEM, ExecStageOutput_EX, DataB_MEM, DataFromMem, DataToReg_MEM, middle_PC;
logic [31:0] InstructionFromMemory, currentlyExecutingInstruction_RF;
logic [2:0] ALUOp_RF, ALUOp_EX;
logic [25:0] BrAddr26;
logic [18:0] Imm19;
logic [5:0] SHAMT_RF, SHAMT_EX, SHAMT_MEM;
logic [11:0] Imm12;
logic [8:0] Imm9;

	//forwarding logic, for forwarding from EXecute or MEMory stages to earlier stages of the pipeline
	payItForward forward (.Rn_RF, .Rm_RF, .Rd_EX, .Rd_MEM, .Rd_RF, .negative, .zero, .overflow, .carry_out, .Opcode_RF(currentlyExecutingInstruction_RF[31:21]), .OPcode_MEM(Opcode_MEM), //added cEInstruction for opcode RF
						.Opcode_EX, .CBZ_zeroFlag, .zero_control, .overflow_control, .carryout_control, .negative_control, .ExecStageOutput_EX,
						.ExecStageOutput_MEM, .clk, .Output_LogicA, .Output_LogicB, .flagA, .flagB, .DataFromMem);

 	MUX2by64_64 reset_em (.regA(currentPC), .regB(64'b0), .sel(reset), .out(middle_PC));


	parameter DELAY = 0.05;
	parameter ADD = 3'b010; //used for defining adders for updating PC
	
	
	//Instruction Fetch Stage -- IF
	
	instructmem2 InstructionMemory ( .address(middle_PC), .instruction(InstructionFromMemory), .clk); 

	// IF_RF registers --- Transitioning between IFetch and Reg/Dec stages
	REGISTER #(.WIDTH(64)) IF_RF_PC (.q(lastPC), .d(middle_PC), .enable(1'b1), .clk); ///
	REGISTER #(.WIDTH(32)) IF_RF_instruction (.q(currentlyExecutingInstruction_RF), .d(InstructionFromMemory), .enable(1'b1), .clk); ///
	
	
	
	//Register & Decode Stage -- RF -- decode instruction, run control logic, and fetch register data as needed

   logic RegWrite_initial;
		
	control_logic craftingControlSignals (.clk, .ALU_Op(ALUOp_RF), .instruction(currentlyExecutingInstruction_RF), .zero(zero_control), .negative(negative_control), .overflow(overflow_control), .carryout(carryout_control),
										  .Reg2Loc(Reg2Loc_RF), .ALUSrc(ALUSrc_RF), .MemToReg(MemToReg_RF), .RegWrite(RegWrite_initial), .MemWrite(MemWrite_RF), .BrTaken(BrTaken_RF_immediateResult), .UncondBr(UncondBr_RF), 
										  .ADDIsignal(ADDIsignal_RF), .shift(shift_RF), .Rd(Rd_RF), .Rn(Rn_RF), .Rm(Rm_RF), .CBZ_zeroFlag, 
										  .BrAddr26(BrAddr26), .CondAddr19(Imm19), .SHAMT(SHAMT_RF), .ALU_Imm12(Imm12), .DT_Address9(Imm9), .instruct(Opcode_RF)); 
	
	//these immediates are only used in RF stage, until final output for ALU B is passed through registers, therefore don't need to be passed on through registers
	assign Imm12Extended = {52'b0, Imm12};
	extendem #(.WIDTH(9)) extend9(.Imm(Imm9), .out(Imm9Extended));
	extendem #(.WIDTH(19)) extend19(.Imm(Imm19), .out(Imm19Extended));
	extendem #(.WIDTH(26)) extend26(.Imm(BrAddr26), .out(BrAddr26Extended));
	
	//choose whether value Rd or Rn will be output from Db
	MUX2byX_X #(.WIDTH(5)) RdorRmIntoAb (.regA(Rd_RF), .regB(Rm_RF), .sel(Reg2Loc_RF), .out(Ab)); 
	
	not #DELAY write (inverse_clk, clk);
	
	//REGISTER MEMORY HERE
	regfile RegisterMemory (.ReadData1(DataA), .ReadData2(DataB), .WriteData(DataToReg_RF), .ReadRegister1(Rn_RF), .ReadRegister2(Ab), 	// DataA, DataB, Ab are internal signals just for RF stage
							.WriteRegister(Rd_WB), .RegWrite(RegWrite_RF), .clk(inverse_clk), .HEX0, .HEX1, .HEX2, .HEX3, .HEX4, .HEX5); 		
	
	//selecting register data, or appropriate immediate, to send to ALU...
	//extendedImmediateForALU is only used in RF stage between MUXes, so passing onto next stage is not necessary
	MUX2by64_64 whichImmediateToUse (.regA(Imm9Extended), .regB(Imm12Extended), .sel(ADDIsignal_RF), .out(extendedImmediateForALU)); 
	MUX2by64_64 usingDataB_orImmediate (.regA(RegisterDataB_RF), .regB(extendedImmediateForALU), .sel(ALUSrc_RF), .out(Operand2_RF)); 
	
	//checking zero condition for CBZ instruction
	check_zero RF_zero (.in_64(RegisterDataB_RF), .zero_flag(CBZ_zeroFlag));
	
	//MUXes for selecting forwarded values sent by forwarding logic, if necessary
	//Output_LogicA/B are forwarded data from EX or MEM stages
	MUX2by64_64 logicA (.regA(DataA), .regB(Output_LogicA), .sel(flagA), .out(Operand1_RF));
	MUX2by64_64	logicB (.regA(DataB), .regB(Output_LogicB), .sel(flagB), .out(RegisterDataB_RF));
	
	
	//Updating PC, either incrementing by 4 or branching to new address
	MUX2by64_64 isUnCondBranchTaken (.regA(Imm19Extended), .regB(BrAddr26Extended), .sel(UncondBr_RF), .out(FullBranchAmount)); // FullBranchAmount doesn't need to be forwarded

	shifter shiftingAddressesBy2 (.value(FullBranchAmount), .direction(1'b0), .distance(2), .result(ShiftedBranchAmount)); 
	
	//immediateResult calculated immmediately, but a register value is updated on clock edge, 
	//this register value is what is used for a new PC in case of branch
	alu adder1(.A(ShiftedBranchAmount), .B(lastPC), .ctrl(ADD), .result(BranchAddress_immediateResult)); 
	
	//Increment program counter by 4; standard incrementation for moving to next instruction
	alu adder2 (.A(lastPC), .B(64'd4), .ctrl(ADD), .result(incremPCAddress)); 
	
	logic BrTaken_RF;
	MUX2by64_64 isABranchTaken (.regA(incremPCAddress), .regB(BranchAddress_RF), .sel(BrTaken_RF), .out(currentPC)); ///	//this MUX outputs currentPC, which goes straight to the Instruct Memory as the new instruction address
															//This BranchAddress is updated on clk edge, i.e. this <= BranchAddress_immediateResult

	// RF_EX registers
	REGISTER #(.WIDTH(8)) RF_EX_controlSignals (.q({ALUOp_EX, shift_EX, MemToReg_EX, MemWrite_EX, RegWrite_EX, BrTaken_RF}), 
											   .d({ALUOp_RF, shift_RF, MemToReg_RF, MemWrite_RF, RegWrite_initial, BrTaken_RF_immediateResult}) , .enable(1'b1), .clk); /// 		//remaining control signals needed in EX or beyond
	
	REGISTER #(.WIDTH(64)) RF_EX_BranchedPCAddress (.q(BranchAddress_RF), .d(BranchAddress_immediateResult), .enable(1'b1), .clk);
	
	//This is likely DATA A from regfile, or data forwarded from different stage, is the 1st (a) input to ALU
	REGISTER #(.WIDTH(64)) RF_EX_FirstOperand (.q(Operand1_EX), .d(Operand1_RF), .enable(1'b1), .clk); 
	
	//2nd operand for ALU---either forwarded data, or DATA_B, or number from immediates
	REGISTER #(.WIDTH(64)) RF_EX_SecondOperand (.q(Operand2_EX), .d(Operand2_RF), .enable(1'b1), .clk); 
	
	//this is data b from register or forwarding, bypassing the mux to obtain immediates (this is used for Din in STUR)
	REGISTER #(.WIDTH(64)) RF_EX_DataB (.q(DataB_EX), .d(RegisterDataB_RF), .enable(1'b1), .clk); 
	
	//Rd, Rm, Rn, SHAMT, and Opcode, which are given in instruction
	REGISTER #(.WIDTH(32)) RF_EX_fromInstruction (.q({Rd_EX, Rm_EX, Rn_EX, SHAMT_EX, Opcode_EX}), 
																 .d({Rd_RF, Rm_RF, Rn_RF, SHAMT_RF, Opcode_RF}), .enable(1'b1), .clk); 
	
	
	
	//EXecute Stage -- EX -- ALU operations

	alu mainALU (.A(Operand1_EX), .B(Operand2_EX), .ctrl(ALUOp_EX), .result(ALUoutput_EX), .negative, .zero, .overflow, .carry_out); //need these flags to correspond to the "combinational" flags,
																															//once this step is complete, based on Opcode_EX set the "sequential" flags (zeroseq <= zerocomb) when correct to do so
	// ShiftedDataA is only used between shifter and mux for final exec output, no need to pass on
	shifter RightShiftingDataA (.value(Operand1_EX), .direction(1'b1), .distance(SHAMT_EX), .result(ShiftedDataA)); 

	//ExecStageOutput is either ALU output or shifter output
	MUX2by64_64 usingALUorShifterOutput (.regA(ALUoutput_EX), .regB(ShiftedDataA), .sel(shift_EX), .out(ExecStageOutput_EX)); 


	// EX_MEM registers
	REGISTER #(.WIDTH(64)) EX_MEM_ExecOutput (.q(ExecStageOutput_MEM), .d(ExecStageOutput_EX), .enable(1'b1), .clk); ///
	
	//remaining control signals needed in MEM or beyond
	REGISTER #(.WIDTH(3)) EX_MEM_controlSignals (.q({MemToReg_MEM, MemWrite_MEM, RegWrite_MEM}), 
																.d({MemToReg_EX, MemWrite_EX, RegWrite_EX}), .enable(1'b1), .clk); ///		

	REGISTER #(.WIDTH(64)) EX_MEM_DataB (.q(DataB_MEM), .d(DataB_EX), .enable(1'b1), .clk); ///		

	//Rd, Rm, Rn, SH
	REGISTER #(.WIDTH(32)) EX_MEM_fromInstruction (.q({Rd_MEM, Rm_MEM, Rn_MEM, SHAMT_MEM, Opcode_MEM}), 
																  .d({Rd_EX, Rm_EX, Rn_EX, SHAMT_EX, Opcode_EX}), .enable(1'b1), .clk); 
	
	
	
	//MEMory stage -- MEM -- reading or writing to DATA MEM
	
	//HERE is DATA MEMORY
	not #DELAY writes (read_enable_MEM, MemWrite_MEM);
	datamem data(.address(ExecStageOutput_MEM), .write_enable(MemWrite_MEM), .read_enable(read_enable_MEM), 
					 .write_data(DataB_MEM), .clk, .xfer_size(8), .read_data(DataFromMem)); //DataFromMem is Dout of datamem, goes into MUX before registers, not passed on

	MUX2by64_64 memoryORexecDataToRegFile (.regA(ExecStageOutput_MEM), .regB(DataFromMem), .sel(MemToReg_MEM), .out(DataToReg_MEM)); ///

	

	//Writeback -- WB -- register memory's write enable is set, data is written to a register, or not
	
	// MEM_WB registers
	REGISTER #(.WIDTH(64)) MEM_WB_DataToRegister (.q(DataToReg_RF), .d(DataToReg_MEM), .enable(1'b1), .clk); ///
	REGISTER #(.WIDTH(1))  MEM_WB_RegWrite 		 (.q(RegWrite_RF), .d(RegWrite_MEM), .enable(1'b1), .clk); ///
	REGISTER #(.WIDTH(5))  MEM_WB_Rd 		 (.q(Rd_WB), .d(Rd_MEM), .enable(1'b1), .clk); ///

	


endmodule

module pipinghotCPU_testbench();

	parameter ClockDelay = 2500;

	logic clk, reset;
	
	pipinghotCPU dut(.clk, .reset);
	
	initial begin 
		clk<=0;
		forever #(ClockDelay/2) clk <= ~clk;
	end
	
	
	initial begin
	@(posedge clk);
	reset <= 1;
	@(posedge clk);
	reset <= 0;
	@(posedge clk);
	@(posedge clk);
	
	
	for(int i = 0; i < 800; i++) begin //700 for lab 3
	@(posedge clk);
	@(posedge clk);
	
end

$stop;

end

endmodule 
