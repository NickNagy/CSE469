`timescale 1ps/1ps
module pipeline_top(clk, startup, PC);
	input logic clk, startup;
	output logic [63:0] PC;

	logic [31:0] instruction, decoded_instruction;
	logic [2:0] ALUOp;
	logic UncondBr, BrTaken, Reg2Loc, RegWrite, MemWrite, MemToReg, ALUSrc, weFlags, earlyZero, zero, negative, overflow, carry_out;
		
	// handles IFetch
	instructmem instrMem (.address(PC), .instruction, .clk);
	pipeline_instructionpath ipath (.clk, .startup, .UncondBr, .BrTaken, .instruction(decoded_instruction), .PC);
	
	// should be a clock cycle delay b/w instruction path and system controls (Ifetch --> Decode)
	genvar i;
	generate
		for (i = 0; i < 64; i++) begin: eachPCBit
			D_FF PCdff (.q(decoded_instruction[i]), .d(instruction[i]), .reset(1'b0), .clk);
		end
	endgenerate
	
	logic conditionZero;
	or_gate_2_inputs CBZ (.a(zero), .b(earlyZero), .out(conditionZero));
	
	// represents decode
	system_control_signals signals (.instruction(decoded_instruction), .ALUOp, .zero(earlyZero), .negative, .overflow, .carry_out, .UncondBr, .BrTaken, .Reg2Loc, .RegWrite, .MemWrite, .MemToReg, .ALUSrc, .weFlags);
	
	// handles decode -> write
	pipeline_datapath dpath (.clk, .instruction(decoded_instruction), .Reg2Loc, .RegWrite, .MemWrite, .MemToReg, .ALUSrc, .weFlags, .ALUOp, .earlyZero, .zero, .negative, .overflow, .carry_out);
	
endmodule 

module pipeline_top_testbench();
	logic clk, startup;
	logic [63:0]	PC;
	
	pipeline_top dut (.clk, .startup, .PC);
	
	parameter CLOCK_PERIOD = 100000;
	
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end
	
	// logic for stopping the testbench
	logic [63:0] nextToLastPC, lastPC;
	logic endSim;

	always_ff @(posedge clk) begin
		nextToLastPC <= lastPC;
		lastPC <= PC;
		endSim <= (nextToLastPC == PC);
	end
	
	initial begin
		startup <= 1; @(posedge clk);
		startup <= 0;
		while(1) begin
			if (endSim)
				break;
			@(posedge clk);
		end
		$stop;
	end
endmodule 