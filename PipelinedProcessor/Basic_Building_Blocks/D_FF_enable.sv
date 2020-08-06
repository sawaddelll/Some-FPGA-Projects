`timescale 1ns/10ps
// 1 bit DFF with an enable signal
module D_FF_enable (q, d, enable, clk);
 output reg q;
 input d, clk, enable;
 logic d1, q1;
 
 D_FF dff (.q(q1),  .d(d1), .reset(1'b0), .clk);
 
 MUX2_1 mux2_1 (.a(q1), .b(d), .sel(enable), .out(d1));
 
 assign q = q1;
 
 
 endmodule 