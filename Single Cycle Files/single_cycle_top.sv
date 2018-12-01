`timescale 1ps/1ps
module single_cycle_top (clk, startup);
	input logic clk, startup;
	
	logic [63:0] PC;
	logic [31:0] instruction;
	logic [2:0] ALUOp;
	logic UncondBr, BrTaken, Reg2Loc, RegWrite, MemWrite, MemToReg, ALUSrc, RightShift, weFlags, zero, negative, overflow, carry_out;

	single_cycle_datapath dpath (.clk, .instruction, .Reg2Loc, .RegWrite, .MemWrite, .MemToReg, .ALUSrc, .RightShift, .weFlags, .ALUOp, .zero, .negative, .overflow, .carry_out);
	single_cycle_instructionpath ipath (.clk, .startup, .instruction, .UncondBr, .BrTaken, .PC);
	system_control_signals signals (.instruction, .UncondBr, .BrTaken, .Reg2Loc, .RegWrite, .MemWrite, .MemToReg, .ALUSrc, .ALUOp, .weFlags, .zero, .negative, .overflow, .carry_out);
	
	instructmem instrMem (.address(PC), .instruction, .clk);
	
endmodule

/* To see the result of my custom testbench, go to instructmem.sv and un-comment 'mytestbench.arm' */
module single_cycle_top_testbench();
	logic clk, startup;
	
	single_cycle_top dut (.clk, .startup);
	
	parameter CLOCK_PERIOD = 1000000;
	
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end
	
	integer i;
	
	initial begin
		startup <= 1; @(posedge clk);
		startup <= 0;
		for (i = 0; i < 50; i++) begin
			@(posedge clk);
		end
		$stop;
	end
endmodule 