`timescale 1ns/10ps

// How many bytes are in our memory?  Must be a power of two.
`define INSTRUCT_MEM_SIZE		1024

//  Instruction Memory of processor. 
//Currently loads single set of instructions from one file (can't switch applications while running processor).

//instructmem was originally provided for the project. I've seen changed it slightly to make it synthesizable,
//allowing processor to run on FPGA (instead of simulating only).

module instructmem2(
	input		logic		[63:0]	address,
	output	logic		[31:0]	instruction,
	input		logic					clk	// Memory is combinational, but used for error-checking
	);
	
	// Force %t's to print in a nice format.
	initial $timeformat(-9, 2, " ns", 10);

	// Make sure size is a power of two and reasonable.
	initial assert((`INSTRUCT_MEM_SIZE & (`INSTRUCT_MEM_SIZE-1)) == 0 && `INSTRUCT_MEM_SIZE > 4);
	
	// Make sure accesses are reasonable.
	always_ff @(posedge clk) begin
		if (address !== 'x) begin // address or size could be all X's at startup, so ignore this case.
			assert(address[1:0] == 0);	// Makes sure address is aligned.
			assert(address + 3 < `INSTRUCT_MEM_SIZE);	// Make sure address in bounds.
		end
	end
	
	// The data storage itself.
	logic [31:0] mem [`INSTRUCT_MEM_SIZE/4-1:0];
	
	// Load the program - change the filename to pick a different program.
	initial begin
		$readmemb("test11_Sort.txt", mem);
		//$display("Running benchmark: ", `BENCHMARK);
	end
	
		// Handle the reads.
	integer i;
	always_comb begin
		if (address + 3 >= `INSTRUCT_MEM_SIZE)
			instruction = 'x;
		else
			instruction = mem[address/4];
	end
	
	
endmodule 