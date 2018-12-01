`timescale 1ps/1ps
module mux_16to1 (in, sel, out);
	input logic [15:0] in;
	input logic [3:0] sel;
	output logic out;
	
	logic [3:0] temp;
	
	mux_4to1 fours (.in(in[3:0]), .sel(sel[1:0]), .out(temp[0]));
	mux_4to1 eights (.in(in[7:4]), .sel(sel[1:0]), .out(temp[1]));
	mux_4to1 twelves (.in(in[11:8]), .sel(sel[1:0]), .out(temp[2]));
	mux_4to1 sixteens (.in(in[15:12]), .sel(sel[1:0]), .out(temp[3]));
	
	mux_4to1 result (.in(temp), .sel(sel[3:2]), .out(out));

endmodule 

module mux_16to1_testbench();
	logic [15:0] in;
	logic [3:0] sel;
	logic out;
	
	mux_16to1 dut (.in, .sel, .out);
	
	initial begin
		sel = 0; in = 0;	#500;
		in[0] = 1;			#500;
		sel[2] = 1;			#500; // sel = 0100 -> 4
		in[4] = 1;			#500;
		sel[3] = 1;			#500; // sel = 1100 -> 12
		in[11] = 1;			#500;
		in[13] = 1;			#500;
		in[12] = 1;			#500;
		in[12] = 0; in[11] = 0; in[0] = 0; #500;
		sel[0] = 1;			#500; // sel -> 13
		sel[1] = 1;			#500; // sel -> 15
		in[15] = 1;			#500;
	end

endmodule 