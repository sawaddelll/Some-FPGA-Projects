
// extends input of WIDTH bits to 64 bit output (assumes WIDTH < 64)
// replicates top bit of input to fill new bits on output  (i.e. sign extension)

module extendem #(parameter WIDTH = 64)(Imm, out);
input logic [WIDTH-1:0] Imm;
output logic [63:0] out;


assign out[WIDTH -1:0] = Imm; 
 genvar i;
 
  generate 
  for(i=0; i<64-WIDTH; i++) begin: extender 
  assign out[i+WIDTH] = Imm[WIDTH-1];
  end 
  endgenerate 	

endmodule



