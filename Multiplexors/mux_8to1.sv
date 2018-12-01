`timescale 1ps/1ps
module mux_8to1 (in, sel, out);
	input logic [7:0] in;
	input logic [2:0] sel;
	output logic out;
	
	logic [1:0] temp;
	
	mux_4to1 fours (.in(in[3:0]), .sel(sel[1:0]), .out(temp[0]));
	mux_4to1 eights (.in(in[7:0]), .sel(sel[1:0]), .out(temp[1]));
	
	mux_2to1 result (.in(temp), .sel(sel[2]), .out(out));
endmodule 

module mux_8to1_testbench();
	logic [7:0] in;
	logic [2:0] sel;
	logic out;
	
	mux_8to1 dut (.in, .sel, .out);
	
	initial begin
		sel = 3'b000; in = 8'b00000000; #100;
		in = 8'b00000001; #100;
		for (int i = 1; i < 8; i++) begin
			sel += 1; #100;
			in = in << 1; #100;
		end
	end
	
endmodule 