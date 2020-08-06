`timescale 1ns/10ps

// checks if 64-bit input is all zero; outputs true if so.
module check_zero(in_64, zero_flag);
input logic [63:0] in_64;
output logic zero_flag;
logic [63:0] flag;
logic flag1, flag2, flag3, flag4;
parameter DELAY = 0.05;


genvar j; 
	generate     
		for(j=0; j<64; j = j + 4) begin : zeroFlags       
			nor #DELAY zero_flags (flag[j], in_64[j], in_64[j+1], in_64[j+2], in_64[j+3]); 

		end   
	endgenerate 
	
	and #DELAY zero_flag1 (flag1, flag[0],  flag[4],  flag[8],  flag[12]); 
	and #DELAY zero_flag2 (flag2, flag[16], flag[20], flag[24], flag[28]); 
	and #DELAY zero_flag3 (flag3, flag[32], flag[36], flag[40], flag[44]); 
	and #DELAY zero_flag4 (flag4, flag[48], flag[52], flag[56], flag[60]); 
	and #DELAY zero_flag6 (zero_flag, flag1, flag2, flag3, flag4); 

endmodule 