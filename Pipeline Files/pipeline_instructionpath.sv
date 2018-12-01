`timescale 1ps/1ps

/*
	Instruction after a branch ALWAYS executes!
	PC updated @ end of Reg/Dec stage
*/
module pipeline_instructionpath(clk, startup, UncondBr, BrTaken, instruction, PC);
	input logic clk, startup, UncondBr, BrTaken;
	input logic [31:0] instruction;
	output logic [63:0] PC;
	
	logic [63:0] plusFour, plusBr, prevBrTarget, tempNextPC, prevPC, nextPC, CondAddr, UncondAddr, BrAddr, BrAddrShifted;
	
	extend #(19) CondSE (.in(instruction[23:5]), .sign(1'b1), .out(CondAddr));
	extend #(26) BrSE (.in(instruction[25:0]), .sign(1'b1), .out(UncondAddr));
	
	genvar i;
	generate
		for (i = 0; i < 64; i++) begin: eachBit
			// initialize PC to 0 @ startup, otherwise assign to nextPC
			mux_2to1 initPCMux (.in({1'b0, nextPC[i]}), .sel(startup), .out(PC[i]));
			// branch check logic
			mux_2to1 UncondBrMux (.in({UncondAddr[i], CondAddr[i]}), .sel(UncondBr), .out(BrAddr[i]));
			mux_2to1 BrTakenMux (.in({plusBr[i], plusFour[i]}), .sel(BrTaken), .out(tempNextPC[i]));
			// keep track of previous PC for accelerated branching
			D_FF prevPCDFF (.q(prevPC[i]), .d(PC[i]), .reset(1'b0), .clk);
			// set nextPC to tempNextPC @posedge
			
		end
	endgenerate
	
	shifter brShifter (.value(BrAddr), .direction(1'b0), .distance(6'b000010), .result(BrAddrShifted));
	
	adder64Bit AddBr (.a(PC), .b(64'd4), .out(plusFour));
	adder64Bit Add4 (.a(prevPC), .b(BrAddrShifted), .out(plusBr));
	
	always_ff @(posedge clk) begin
		if (startup)
			nextPC <= 64'd4;
		else
			nextPC <= tempNextPC;
	end
	
endmodule 

module adder64Bit (a, b, out);
	input logic [63:0] a, b;
	output logic [63:0] out;
	
	logic [63:0] cout; // assumes we won't need cout for control path
	
	bitAdder bA0 (.a(a[0]), .b(b[0]), .cin(1'b0), .out(out[0]), .cout(cout[0]));
	
	genvar i;
	generate
		for (i = 1; i < 64; i++) begin: eachBit
			bitAdder bA (.a(a[i]), .b(b[i]), .cin(cout[i-1]), .out(out[i]), .cout(cout[i]));
		end
	endgenerate
endmodule 

module pipeline_instructionpath_testbench();
	logic clk, startup, UncondBr, BrTaken;
	logic [31:0] instruction;
	logic [63:0] PC;
	
	pipeline_instructionpath dut (.clk, .startup, .UncondBr, .BrTaken, .instruction, .PC);
	
	parameter CLOCK_PERIOD = 100000;
	
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end
	
	initial begin
		
		$stop;
	end
endmodule 