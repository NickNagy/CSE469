`timescale 1ps/1ps
module alu (A, B, shamt, cntrl, zero, overflow, carry_out, negative, result);
	input logic [63:0] A, B;
	input logic [5:0] shamt;
	input logic [2:0] cntrl;
	output logic [63:0] result;
	output logic zero, overflow, carry_out, negative;
	
	logic [63:0] cout;
	
	zeroCheck z (.in(result), .out(zero));
	XOR_gate_2_inputs XOR (.a(cout[63]), .b(cout[62]), .out(overflow));
	assign negative = result[63]; // check that we can do this
	assign carry_out = cout[63]; // check that we can do this
	
	logic [63:0] AShifted;
	shifter shiftA (.value(A), .direction(1'b1), .distance(shamt), .result(AShifted));

	// separate from generate block because of cin[0] for addition and subtraction logic
	logic [1:0] finalMuxIn0;
	AB_arithmetic mth0 (.a(A[0]), .b(B[0]), .aShifted(AShifted[0]), .ctrl(cntrl[1:0]), .cin(cntrl[0]), .cout(cout[0]), .out(finalMuxIn0[0]));
	AB_gates gates0 (.a(A[0]), .b(B[0]), .ctrl(cntrl[1:0]), .out(finalMuxIn0[1]));
	mux_2to1 finalMux0 (.in(finalMuxIn0), .sel(cntrl[2]), .out(result[0]));
	
	genvar i;
	generate
		for (i = 1; i < 64; i++) begin: eachIndex
			logic [1:0] finalMuxIn;
			AB_arithmetic mth (.a(A[i]), .b(B[i]), .aShifted(AShifted[i]), .ctrl(cntrl[1:0]), .cin(cout[i-1]), .cout(cout[i]), .out(finalMuxIn[0]));
			AB_gates gates (.a(A[i]), .b(B[i]), .ctrl(cntrl[1:0]), .out(finalMuxIn[1]));
			mux_2to1 finalMux (.in(finalMuxIn), .sel(cntrl[2]), .out(result[i]));
		end
	endgenerate 
	
endmodule 