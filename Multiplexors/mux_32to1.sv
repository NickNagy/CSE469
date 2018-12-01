`timescale 1ps/1ps
module mux_32to1(in, sel, out);
	input logic [4:0] sel;
	input logic [31:0] in;
	output logic out;
	
	// need to map readRegister to a number 0 -> 31... how?
	
	logic [1:0] temp;
	
	// if ~(readRegister[4]|readRegister[3]|readRegister[2]|readRegister[1]) -> 
	mux_16to1 sixteens (.in(in[15:0]), .sel(sel[3:0]), .out(temp[0]));
	mux_16to1 thirttwos (.in(in[31:16]), .sel(sel[3:0]), .out(temp[1]));
	
	mux_2to1 result (.in(temp), .sel(sel[4]), .out(out));
	
endmodule

module mux_32to1_testbench();
	logic [4:0] sel;
	logic [31:0] in;
	logic out;
	
	mux_32to1 dut (.in, .sel, .out);
	
	// most values less than 16 are handled in mux_16:1 testbench
	// here I mostly test values >= 16
	initial begin
		sel = 5'b10000; in = 0; #1000;
		in[16] = 1;					#1000;
		sel = 5'b11000;			#1000;
		in[24] = 1;					#1000;
		sel = 5'b11100;			#1000;
		in[28] = 1;					#1000;
		sel = 5'b11110;			#1000;
		in[30] = 1;					#1000;
		sel = 5'b11111;			#1000;
		in[31] = 1;					#1000;
		sel = 5'b01111;			#1000;
		in[15] = 1;					#1000;
	end
	
endmodule