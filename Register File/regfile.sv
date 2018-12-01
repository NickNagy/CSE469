`timescale 1ps/1ps
module regfile(ReadData1, ReadData2, WriteData, ReadRegister1, ReadRegister2, WriteRegister, RegWrite, clk);
	input logic RegWrite, clk;
	input logic [4:0] ReadRegister1, ReadRegister2, WriteRegister;
	input logic [63:0] WriteData;
	output logic [63:0] ReadData1, ReadData2;
	
	logic [31:0] whichRegister;
	
	Decoder_5x32 decodr (.regWrite(RegWrite), .writeRegister(WriteRegister), .out(whichRegister));
	
	logic [63:0] reg32x64 [0:31];
	assign reg32x64[31] = 64'b0;
	
	genvar i, j, k, l;
	generate
		for (i = 0; i < 31; i++) begin: eachReg
			for (j = 0; j < 64; j++) begin: eachBit
				register_latch r (.in(WriteData[j]), .writeEnable(whichRegister[i]), .out(reg32x64[i][j]), .clk);
			end
		end
		for (k = 0; k < 64; k++) begin: eachMuxBit
			logic [31:0] muxInput;
			for (l = 0; l < 32; l++) begin: eachMuxAddr
				assign muxInput[l] = reg32x64[l][k];
			end
			mux_32to1 mux1(.in(muxInput), .sel(ReadRegister1), .out(ReadData1[k]));
			mux_32to1 mux2(.in(muxInput), .sel(ReadRegister2), .out(ReadData2[k]));
		end
	endgenerate
	
endmodule

module regfile_testbench();

endmodule