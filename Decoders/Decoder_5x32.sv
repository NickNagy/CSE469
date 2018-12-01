`timescale 1ps/1ps
module Decoder_5x32(regWrite,writeRegister,out);
	input logic regWrite;
	input logic [4:0] writeRegister;
	output logic [31:0] out;
	
	logic notR4;
	inverter inv4 (.in(writeRegister[4]), .out(notR4));
	logic sixteenRegWrite, thirtytwoRegWrite;
	and_gate_2_inputs and16 (.a(regWrite), .b(notR4), .out(sixteenRegWrite));
	and_gate_2_inputs and32 (.a(regWrite), .b(writeRegister[4]), .out(thirtytwoRegWrite));
	
	Decoder_4x16 sixteens (.regWrite(sixteenRegWrite), .writeRegister(writeRegister[3:0]), .out(out[15:0]));
	Decoder_4x16 thirtytwos (.regWrite(thirtytwoRegWrite), .writeRegister(writeRegister[3:0]), .out(out[31:16]));

endmodule

module Decoder_5x32_testbench();
	logic regWrite;
	logic [4:0] writeRegister;
	logic [31:0] out;

	Decoder_5x32 dut (.regWrite, .writeRegister, .out);
	
	integer i,j,k,l,m;
	
	initial begin
		regWrite = 1;
		for (i = 0; i <= 1; i++) begin
			for (j = 0; j <= 1; j++) begin
				for (k = 0; k <= 1; k++) begin
					for (l = 0; l <= 1; l++) begin
						for (m = 0; m <= 1; m++) begin
							writeRegister[4] = i;
							writeRegister[3] = j;
							writeRegister[2] = k;
							writeRegister[1] = l;
							writeRegister[0] = m;
							#500;
						end
					end
				end
			end
		end
	end
	
endmodule 