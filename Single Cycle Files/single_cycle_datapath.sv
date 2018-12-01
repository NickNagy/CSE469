`timescale 1ps/1ps
module single_cycle_datapath (clk, instruction, Reg2Loc, RegWrite, MemWrite, MemToReg, ALUSrc, RightShift, weFlags, ALUOp, zero, negative, overflow, carry_out);
	input logic clk, Reg2Loc, RegWrite, MemWrite, MemToReg, ALUSrc, RightShift, weFlags;
	input logic [2:0]  ALUOp;
	input logic [31:0] instruction;
	output logic zero, negative, overflow, carry_out;

	logic [63:0] ALUResult, ALUb, Da, Db, DAddr9Extend, Imm12Extend, ALUConst, WriteData, memOut, DaShifted, memORALUres;
	logic [4:0] Ab;
	logic isMemConst, nextNegative, nextCarryout, nextOverflow;
	
	extend DURSE (.in(instruction[20:12]), .sign(1'b1), .out(DAddr9Extend));
	extend #(12) ADDIE (.in(instruction[21:10]), .sign(1'b0), .out(Imm12Extend));

	or_gate_2_inputs wrORreg (.a(MemWrite), .b(MemToReg), .out(isMemConst));
	
	shifter LSRShifter (.value(Da), .direction(1'b1), .distance(instruction[15:10]), .result(DaShifted));
	
	genvar i;
	generate
		for (i = 0; i < 5; i++) begin: eachInstrBit
			mux_2to1 reg2LocMux(.in({instruction[i+16], instruction[i]}), .sel(Reg2Loc), .out(Ab[i]));
		end
	endgenerate
	
	genvar j;
	generate
		for (j = 0; j < 64; j++) begin: eachBit
			mux_2to1 constantMux(.in({DAddr9Extend[j],Imm12Extend[j]}), .sel(isMemConst), .out(ALUConst[j]));
			mux_2to1 memToRegMux(.in({memOut[j],ALUResult[j]}), .sel(MemToReg), .out(memORALUres[j]));
			mux_2to1 ALUSrcMux (.in({ALUConst[j],Db[j]}), .sel(ALUSrc), .out(ALUb[j]));
			mux_2to1 shiftMux (.in({DaShifted[j], memORALUres[j]}), .sel(RightShift), .out(WriteData[j]));
		end
	endgenerate
	
	regfile sysRegs (.ReadData1(Da), .ReadData2(Db), .WriteData, .ReadRegister1(instruction[9:5]), .ReadRegister2(Ab), .WriteRegister(instruction[4:0]), .RegWrite, .clk);
	alu sysALU (.A(Da), .B(ALUb), .cntrl(ALUOp), .zero, .overflow(nextOverflow), .carry_out(nextCarryout), .negative(nextNegative), .result(ALUResult));
	datamem sysData (.address(ALUResult), .write_enable(MemWrite), .read_enable(1'b1), .write_data(Db), .clk, .xfer_size(4'b1000), .read_data(memOut)); 
	
	// flags thru dff
	always_ff @(posedge clk) begin
		if (weFlags) begin
			overflow <= nextOverflow;
			negative <= nextNegative;
		end
	end
	
endmodule

module single_cycle_datapath_testbench();
	logic clk, Reg2Loc, RegWrite, MemWrite, MemToReg, ALUSrc, RightShift, zero, negative, overflow, carry_out;
	logic [2:0] ALUOp;
	logic [31:0] instruction;
	
	single_cycle_datapath dut (.clk, .Reg2Loc, .RegWrite, .MemWrite, .MemToReg, .ALUSrc, .RightShift, .zero, .negative, .overflow, .carry_out, .ALUOp, .instruction);
	
	parameter CLOCK_PERIOD = 100000;
	
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end
	
	initial begin
		Reg2Loc <= 0; RegWrite <= 0; MemWrite <= 0; RightShift <= 0; MemToReg <= 0; ALUSrc <= 0; ALUOp <= 3'b000; @(posedge clk);
		instruction <= 32'b10010001000000000000011111100000; // ADDI X0, X31, #1		X0 = 1
		RegWrite <= 1; ALUSrc <= 1; ALUOp <= 3'b010; @(posedge clk);
		instruction <= 32'b10101011000000000000000000000001; // ADDS X1, X0, X0   X1 = 2
		ALUSrc <= 0; Reg2Loc <= 1; @(posedge clk);
		instruction <= 32'b11001010000000000000000000100011; // EOR X3, X0, X1		X3 = X0 ^ X1 = 3
		Reg2Loc <= 1; ALUOp <= 3'b110; @(posedge clk);
		instruction <= 32'b11111000000000000001000001100011; // STUR X3 [X3, #1]	Mem[4] = 3
		Reg2Loc <= 0; ALUOp <= 3'b010; ALUSrc <= 1; RegWrite <= 0; MemWrite <= 1; @(posedge clk);
		instruction <= 32'b11010011100000000000010001100101; // LSR X5, X3, >>1		X5 = 1
		MemToReg <= 0; RightShift <= 1; RegWrite <= 1; MemWrite <= 0; @(posedge clk); 
		instruction <= 32'b11111000010000000001000001100100; // LDUR X4, [X3, #1]	X4 = Mem[4] = 3
		ALUOp <= 3'b010; RightShift <= 0; ALUSrc <= 1; MemToReg <= 1; @(posedge clk);
		instruction <= 32'b11101011000001000000000010100110; // SUBS X6, X5, X4		X6 = 1-3 = -2
		ALUOp <= 3'b011; ALUSrc <= 0; MemToReg <= 0; Reg2Loc <= 1; @(posedge clk);
		// flag checks
		instruction <= 32'b10101011000111110000001111111111; // ADDS X31, X31 X31
		ALUOp <= 3'b010; @(posedge clk); // expect zero flag to be true
		instruction <= 32'b10010001001111111111110000011111; // ADDI X31, X0, #big ol Imm12, 
		ALUSrc <= 1; @(posedge clk); // expect overflow and or carryout to be true
		instruction <= 32'b11101011000000010000000000011111; // SUBS X31, X0, X1
		ALUSrc <= 0; ALUOp <= 3'b011; @(posedge clk); // expect negative flag to be true
		@(posedge clk);
		$stop;
	end
endmodule 