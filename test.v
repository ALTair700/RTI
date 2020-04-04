`timescale 1ns/1ps

module test;
reg clk   = 1'b0;
reg ce    = 1'b0;
reg reset = 1'b0;
wire signed [9:0] sin_out;
wire signed [9:0] tx_out;

always # 10 clk = !clk;
initial
	begin
	#10 reset = 1'b1;
	#20 reset = 1'b0;
	#20  ce = 1'b1;
	end

bpsk test_dev(.clk(clk), .ce(ce), .reset(reset), .sin_out(sin_out), .tx_out(tx_out));
endmodule
