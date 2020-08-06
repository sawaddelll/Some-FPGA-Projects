# Basic Pipelined Processor

This is a basic 64-bit, pipelined ARM CPU I worked on in a Computer Architecture Course.

It Has 5 pipeline stages (Instruction Fetch, Register/Decode, Execute, Memory, Writeback), and can execute 11 ARM Assembly instructions (ADDI, ADDS, AND, B, BLT, CBZ, EOR, LDUR, LSR, STUR, and SUBS). [This](./Rough Diagram of Pipelined Processor.png) is a block diagram showing the general layout of the pipelined processor.
