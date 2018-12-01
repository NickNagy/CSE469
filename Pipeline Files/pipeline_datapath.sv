`timescale 1ps/1ps
module pipeline_datapath(clk, instruction, Reg2Loc, RegWrite, MemWrite, MemToReg, ALUSrc, weFlags, ALUOp, earlyZero, zero, negative, overflow, carry_out);
	input logic [31:0] instruction;
	input logic [2:0] ALUOp;
	input logic clk, Reg2Loc, RegWrite, MemWrite, MemToReg, ALUSrc, weFlags; 
	output logic earlyZero, zero, negative, overflow, carry_out;

	logic [63:0] address, ALUResult, resultHold, result_min1, result_min2, mem_min1, mem_min2, mem_wr_data_min2, mem_wr_data_min1, DbVIResult, ALUa, ALUbTemp, ALUb, Da, Db, DAddr9Extend, Imm12Extend, ALUConst, WriteData, WriteDataNext, memOut, memORALUres;
	logic [4:0] Ab, Rm, Rn, Rd, Rd_min1, Rd_min2, Rd_min3;
	logic lowClk, RW_min1, RW_min2, RW_min3, MTR_min1, MTR_min2, MemRead, isMemConst, MW_min1, MW_min2, nextNegative, nextCarryout, nextOverflow, nextZero;
	
	logic reset;
	assign reset = 1'b0; // change to startup?
	
	// define the 3 registers
	assign Rm = instruction[20:16];
	assign Rn = instruction[9:5];
	assign Rd = instruction[4:0];
	
	inverter clkInv (.in(clk), .out(lowClk));
	inverter memInv (.in(MW_min2), .out(MemRead));
	
	// for accelerated branches
	zeroCheck acceleratedZeroCheck (.in(ALUbTemp), .out(earlyZero));
	
	// forwarding control logic
	forwarding_logic FL (.lastRes(ALUResult), .nextToLastRes(WriteDataNext), .lastSTUR(MW_min1), .nextToLastSTUR(MW_min2), .Aa(Rn), .Ab, .Da, .Db, .Rd_min1, .Rd_min2, .ALUa, .ALUb(ALUbTemp));
	
	// constants for ALU
	extend DURSE (.in(instruction[20:12]), .sign(1'b1), .out(DAddr9Extend));
	extend #(12) ADDIE (.in(instruction[21:10]), .sign(1'b0), .out(Imm12Extend));

	or_gate_2_inputs wrORreg (.a(MemWrite), .b(MemToReg), .out(isMemConst));
	
	// latches for ALU flags
	register_latch ovrLatch (.in(nextOverflow), .writeEnable(weFlags), .out(overflow), .clk);
	register_latch negLatch (.in(nextNegative), .writeEnable(weFlags), .out(negative), .clk);
	register_latch carLatch (.in(nextCarryout), .writeEnable(weFlags), .out(carry_out), .clk);
	register_latch zeroLatch (.in(nextZero), .writeEnable(weFlags), .out(zero), .clk);
	
	// control logic sends MemWrite signal forward 2 cycles
	D_FF MWDff1 (.q(MW_min1), .d(MemWrite), .reset, .clk);
	D_FF MWDff2 (.q(MW_min2), .d(MW_min1), .reset, .clk);
	D_FF mtrDff1 (.q(MTR_min1), .d(MemToReg), .reset, .clk);
	D_FF mtrDff2 (.q(MTR_min2), .d(MTR_min1), .reset, .clk);
	// control logic sends RegWrite signal forward 3 cycles
	D_FF rwDff1 (.q(RW_min1), .d(RegWrite), .reset, .clk);
	D_FF rwDff2 (.q(RW_min2), .d(RW_min1), .reset, .clk);
	D_FF rwDff3 (.q(RW_min3), .d(RW_min2), .reset, .clk);		
	
	genvar i;
	generate
		for (i = 0; i < 5; i++) begin: eachInstrBit
			mux_2to1 reg2LocMux(.in({Rm[i], Rd[i]}), .sel(Reg2Loc), .out(Ab[i]));
			// keep track of last two destination registers, for forwarding logic
			D_FF rdDff1 (.q(Rd_min1[i]), .d(Rd[i]), .reset, .clk);
			D_FF rdDff2 (.q(Rd_min2[i]), .d(Rd_min1[i]), .reset, .clk);
			// for write cycle @ regfile
			D_FF rdDff3 (.q(Rd_min3[i]), .d(Rd_min2[i]), .reset, .clk);
		end
	endgenerate
	
	genvar j;
	generate
		for (j = 0; j < 64; j++) begin: eachBit
		// ALU logic
			mux_2to1 constantMux(.in({DAddr9Extend[j],Imm12Extend[j]}), .sel(isMemConst), .out(ALUConst[j]));
			mux_2to1 ALUSrcMux (.in({ALUConst[j],ALUbTemp[j]}), .sel(ALUSrc), .out(ALUb[j]));
			D_FF ALUDff (.q(ALUResult[j]), .d(resultHold[j]), .reset, .clk);
			D_FF prevResDff (.q(result_min1[j]), .d(ALUResult[j]), .reset, .clk);
		// data mem logic
			D_FF AddrDff (.q(address[j]), .d(ALUResult[j]), .reset, .clk);
			// data in comes from register/decode
			D_FF memDataDff1 (.q(mem_wr_data_min1[j]), .d(ALUbTemp[j]), .reset, .clk);
			D_FF memDataDff2 (.q(mem_wr_data_min2[j]), .d(mem_wr_data_min1[j]), .reset, .clk);
		// regfile logic
			mux_2to1 memToRegMux (.in({memOut[j], result_min1[j]}), .sel(MTR_min2), .out(WriteDataNext[j]));
			D_FF wDataDff (.q(WriteData[j]), .d(WriteDataNext[j]), .reset, .clk);	
		end
	endgenerate
	
	// ALU
	alu sysALU (.A(ALUa), .B(ALUb), .shamt(instruction[15:10]), .cntrl(ALUOp), .zero(nextZero), .overflow(nextOverflow), .carry_out(nextCarryout), .negative(nextNegative), .result(resultHold));
	
	// Data MEM
	datamem sysData (.address, .write_enable(MW_min2), .read_enable(MTR_min2), .write_data(mem_wr_data_min2), .clk, .xfer_size(4'b1000), .read_data(memOut));
	
	// RegFile
	regfile sysRegs (.ReadData1(Da), .ReadData2(Db), .WriteData, .ReadRegister1(Rn), .ReadRegister2(Ab), .WriteRegister(Rd_min3), .RegWrite(RW_min3), .clk(lowClk));
	
endmodule 

module forwarding_logic (lastRes, nextToLastRes, lastSTUR, nextToLastSTUR, Aa, Ab, Da, Db, Rd_min1, Rd_min2, ALUa, ALUb);
	input logic [63:0] lastRes, nextToLastRes, Da, Db;
	input logic [4:0] Aa, Ab, Rd_min1, Rd_min2;
	input logic lastSTUR, nextToLastSTUR;
	output logic [63:0] ALUa, ALUb;
	
	logic AaEqualsRdMin1, AaEqualsRdMin2, AbEqualsRdMin1, AbEqualsRdMin2, AisReg31, BisReg31, AisNotReg31, BisNotReg31, notLastSTUR, notNextToLastSTUR, afwd1, afwd2, bfwd1, bfwd2;
	
	and_gate_5_inputs AReg31Ander (.a(Aa[0]), .b(Aa[1]), .c(Aa[2]), .d(Aa[3]), .e(Aa[4]), .out(AisReg31));
	and_gate_5_inputs BReg31Ander (.a(Ab[0]), .b(Ab[1]), .c(Ab[2]), .d(Ab[3]), .e(Ab[4]), .out(BisReg31));
	
	inverter inv1 (.in(AisReg31), .out(AisNotReg31));
	inverter inv2 (.in(BisReg31), .out(BisNotReg31));
	inverter	inv3 (.in(lastSTUR), .out(notLastSTUR));
	inverter inv4 (.in(nextToLastSTUR), .out(notNextToLastSTUR));
	
	equal_addresses ar1 (.addr1(Aa), .addr2(Rd_min1), .out(AaEqualsRdMin1));
	equal_addresses ar2 (.addr1(Aa), .addr2(Rd_min2), .out(AaEqualsRdMin2));
	equal_addresses br1 (.addr1(Ab), .addr2(Rd_min1), .out(AbEqualsRdMin1));
	equal_addresses br2 (.addr1(Ab), .addr2(Rd_min2), .out(AbEqualsRdMin2));
	
	and_gate_3_inputs AregAnd1 (.a(AaEqualsRdMin1), .b(AisNotReg31), .c(notLastSTUR), .out(afwd1));
	and_gate_3_inputs AregAnd2 (.a(AaEqualsRdMin2), .b(AisNotReg31), .c(notNextToLastSTUR), .out(afwd2));
	and_gate_3_inputs BregAnd1 (.a(AbEqualsRdMin1), .b(BisNotReg31), .c(notLastSTUR), .out(bfwd1));
	and_gate_3_inputs BregAnd2 (.a(AbEqualsRdMin2), .b(BisNotReg31), .c(notNextToLastSTUR), .out(bfwd2));
	
	always_comb begin
		if (afwd1)
			ALUa = lastRes;
		else if (afwd2)
			ALUa = nextToLastRes;
		else
			ALUa = Da;
	end
	
	always_comb begin
		if (bfwd1)
			ALUb = lastRes;
		else if (bfwd2)
			ALUb = nextToLastRes;
		else
			ALUb = Db;
	end
	
endmodule

module forwarding_logic_testbench();
	logic [63:0] lastRes, nextToLastRes, Da, Db, ALUa, ALUb;
	logic [4:0] Aa, Ab, Rd_min1, Rd_min2;
	logic lastSTUR, nextToLastSTUR;
	
	forwarding_logic dut (.lastRes, .nextToLastRes, .lastSTUR, .nextToLastSTUR, .Da, .Db, .ALUa, .ALUb, .Aa, .Ab, .Rd_min1, .Rd_min2);
	
	parameter delay = 500;
	
	integer i;
	initial begin
		Aa = 5'b0; Ab = 5'd10; lastRes = 50; lastSTUR = 0; nextToLastSTUR = 0; nextToLastRes = 100; Rd_min1 = 5'b101; Rd_min2 = 5'b011; Da = 63'd20; Db = 63'd30; #delay; 
		for (i = 0; i < 10; i++) begin
			Aa = Aa + 1'b1; #delay;
			Ab = Ab - 1'b1; #delay;
		end
		// check case where current register was used in both of last two cycles
		Rd_min2 = 5'b101; Aa = 5'b101; #delay;
		lastSTUR = 1; Rd_min1 = 5'b100; Ab = 5'b100; #delay;
		lastSTUR = 0; #delay;
		Rd_min1 = 5'd14; lastRes = 64'd5; Rd_min2 = 5'd3; nextToLastRes = 64'd8; Aa = 5'b11111; Ab = 5'b0; Da = 64'd0; Db = 64'd0; #delay;
		Rd_min1 = 5'd1; lastRes = 64'd8; Rd_min2 = 5'd14; nextToLastRes = 64'd5; Ab = 5'd1; #delay;
		#delay;
	end
endmodule 

module equal_addresses(addr1, addr2, out);
	input logic [4:0] addr1, addr2;
	output logic out;
	
	logic [4:0] tempOut;
	
	genvar i;
	generate
		for (i = 0; i < 5; i++) begin: eachAND
			logic addr1Inv, addr2Inv, both, neither;
			inverter invAddr1 (.in(addr1[i]), .out(addr1Inv));
			inverter invAddr2 (.in(addr2[i]), .out(addr2Inv));
			and_gate_2_inputs chkboth (.a(addr1[i]), .b(addr2[i]), .out(both));
			and_gate_2_inputs chkneith (.a(addr1Inv), .b(addr2Inv), .out(neither));
			or_gate_2_inputs same (.a(both), .b(neither), .out(tempOut[i]));
		end
	endgenerate
	
	logic tempOut2;
	
	and_gate_3_inputs chk2 (.a(tempOut[0]), .b(tempOut[1]), .c(tempOut[2]), .out(tempOut2));
	and_gate_3_inputs chkFinal (.a(tempOut2), .b(tempOut[3]), .c(tempOut[4]), .out);
	
endmodule

module pipeline_datapath_testbench();
	logic [31:0] instruction;
	logic [2:0] ALUOp;
	logic clk, Reg2Loc, RegWrite, MemWrite, MemToReg, ALUSrc, weFlags, zero, negative, overflow, carry_out;
	
	pipeline_datapath dut (.instruction, .ALUOp, .clk, .Reg2Loc, .RegWrite, .MemWrite, .MemToReg, .ALUSrc, .weFlags, .zero, .negative, .overflow, .carry_out);
	
	parameter CLOCK_PERIOD = 100000;
	
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end
	
	/*
		Things to test:
			Shifting
			ALU operations are used 1 clk cycle later
			Mem operations are used 2 clk cycles later
			Reg operations are used 3 clk cycles later
			What happens if read & write to RegFile simultaneously?
			Forwarding logic
			Timing of flags
	*/
	initial begin
		instruction <= 32'b10010001000000000000011111100000; ALUOp <= 3'b010; Reg2Loc <= 0; RegWrite <= 1; MemWrite <= 0; MemToReg <= 0; ALUSrc <= 1; weFlags <= 0; @(posedge clk); // ADDI X0, X31, #1 // X0 = 1
		// ALU should know that X0 will = 1, even though it's not yet written to regFile
		instruction <= 32'b10101011000000000000000000000001; ALUSrc <= 0; Reg2Loc <= 1; weFlags <= 1; @(posedge clk); // ADDS X1, X0, X0 // X1 = 2
		instruction <= 32'b10101011000000010000000000100001; @(posedge clk); // ADDS X1, X1, X1 // X1 = 4
		instruction <= 32'b11010011100000000000100000100010; ALUSrc <= 1; ALUOp <= 3'b001; @(posedge clk); // LSR X2, X1, #2 // X2 = 1 // regFile[X0] = 1
		instruction <= 32'b11111000000000000000000000100010; ALUOp <= 3'b010; Reg2Loc <= 0; MemWrite <= 1; RegWrite <= 0; @(posedge clk); // STUR X2, [X1, #0] //  // regFile[X1] = 2
		instruction <= 32'b11111000010000000000000000100011; MemToReg <= 1; RegWrite <= 1; MemWrite <= 0; @(posedge clk); // LDUR X3, [X1, #0] // X3 = 1, // regFile[X1] = 4
		// test of a control hazard --> trying to read X3 while it's loaded into should not work!!
		instruction <= 32'b10010001000000000000010001100100; MemToReg <= 0; @(posedge clk); // ADDI X4, X3, #1 // " X4 = 2 "  // regFile[X2] = 1, Mem[4] = 1
		@(posedge clk); 
		@(posedge clk); // regFile[X3] = 1
		@(posedge clk); // regFile[X4] = ?? // control hazard check
		$stop;
	end
endmodule 