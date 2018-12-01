`timescale 1ps/1ps
module single_cycle_instructionpath(clk, startup, UncondBr, BrTaken, instruction, PC);
	input logic clk, startup, UncondBr, BrTaken;
	input logic [31:0] instruction;
	output logic [63:0] PC;
	
	logic [63:0] plusFour, plusBr, nextPC, CondAddr, UncondAddr, BrAddr, BrAddrShifted;
	
	extend #(19) CondSE (.in(instruction[23:5]), .sign(1'b1), .out(CondAddr));
	extend #(26) BrSE (.in(instruction[25:0]), .sign(1'b1), .out(UncondAddr));
	
	genvar i;
	generate
		for (i = 0; i < 64; i++) begin: eachBit
			mux_2to1 UncondBrMux (.in({UncondAddr[i], CondAddr[i]}), .sel(UncondBr), .out(BrAddr[i]));
			mux_2to1 BrTakenMux (.in({plusBr[i],plusFour[i]}), .sel(BrTaken), .out(nextPC[i]));
		end
	endgenerate
	
	shifter brShifter (.value(BrAddr), .direction(1'b0), .distance(6'b000010), .result(BrAddrShifted));
	
	adder64Bit AddBr (.a(PC), .b(64'd4), .out(plusFour));
	adder64Bit Add4 (.a(PC), .b(BrAddrShifted), .out(plusBr));
	
	always_ff @(posedge clk) begin
		if (startup)
			PC <= 0;
		else
			PC <= nextPC;
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

module single_cycle_instructionpath_testbench();
	logic clk, startup, UncondBr, BrTaken; 
	logic [31:0] instruction;
	logic [63:0] PC;
	
	single_cycle_instructionpath dut (.clk, .startup, .UncondBr, .BrTaken, .instruction, .PC);
	
	parameter CLOCK_PERIOD = 100000;
	
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end
	
	integer i;
	initial begin
		startup <= 1; UncondBr <= 0; BrTaken <= 0; 			  @(posedge clk);
		startup <= 0;
		instruction <= 32'b10010001000000000000011111100000; @(posedge clk); // standard instructions, PC = 4
		instruction <= 32'b10010001000000000000011111100000; @(posedge clk); // PC = 8
		instruction <= 32'b10101011000000000000000000000001; @(posedge clk); // PC = 12
		instruction <= 32'b00010100000000000000000000000111; // PC = 7<<2 = 28 + 12 = 40
		// unconditional branch example. Logic for whether to take branch is in another module
		BrTaken <= 1; UncondBr <= 1; @(posedge clk);
		instruction <= 32'b10110100111111111111111111100000; // PC = -1<<2 = -4 + 40 = 36
		// conditional branch example. Logic for whether to take branch is in another module
		UncondBr <= 0; @(posedge clk);
		@(posedge clk);
		$stop;
	end
endmodule