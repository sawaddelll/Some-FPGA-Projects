# Basic Pipelined Processor

This is a basic 64-bit, pipelined ARM CPU I worked on in a Computer Architecture Course. Most of the components are written implemented with gate-level Verilog, with the control and forwarding logic written in RTL. 

It Has 5 pipeline stages (Instruction Fetch, Register/Decode, Execute, Memory, Writeback), and can execute 11 ARM Assembly instructions (ADDI, ADDS, AND, B, BLT, CBZ, EOR, LDUR, LSR, STUR, and SUBS). [This block diagram](./RoughDiagram_PipelinedProcessor.png) shows the general layout of the processor and its pipeline stages. Originally, the processor was only simulated ModelSim, but since then I have updated everything to synthesizable SystemVerilog to allow for running on an FPGA (DE1_SoC). 

[pipinghotCPU.sv](./pipinghotCPU.sv) is primary module where the pipelined processor is defined. It's connected to a top-level module, DE1_SOC.sv, to connect to inputs and outputs on the FPGA, but there's not yet any significant interaction between the processor and those external signals. The [Basic Building Blocks](./Basic_Building_Blocks) folder contains some of the smaller, mostly gate-level modules used to make up the larger components. The [Testing](./Testing) folder has some of the basic ARM Assembly programs run on the processor. 
