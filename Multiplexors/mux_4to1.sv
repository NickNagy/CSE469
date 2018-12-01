`timescale 1ps/1ps
module mux_4to1 (in, sel, out); 
	input logic [3:0] in;
	input logic [1:0] sel;
	output logic out;
	
	logic [1:0] temp;
	
	mux_2to1 twos (.in(in[1:0]), .sel(sel[0]), .out(temp[0]));
	mux_2to1 fours (.in(in[3:2]), .sel(sel[0]), .out(temp[1]));
	
	mux_2to1 result (.in(temp), .sel(sel[1]), .out(out));
	
endmodule 

module mux_4to1_testbench();
	logic [3:0] in;
	logic [1:0] sel;
	logic out;
	
	mux_4to1 dut (.in, .sel, .out);
	
	initial begin
		sel = 2'b00; in = 4'b0000; #200;
		in = 4'b0001; 					#200;
		sel = 2'b01; 					#200;		
		in = 4'b0010; 					#200;
		sel = 2'b10;				 	#200;
		in = 4'b0110; 					#200;
		in = 4'b0100; 					#200;
		sel = 2'b11;					#200;
		in = 4'b1111;					#200;
		in = 4'b0111;					#200;
		in = 4'b1000;					#200;
	end

endmodule 