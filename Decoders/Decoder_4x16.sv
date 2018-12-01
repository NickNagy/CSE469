`timescale 1ps/1ps

module Decoder_4x16 (regWrite, writeRegister, out);
	input logic regWrite;
	input logic [3:0] writeRegister;
	output logic [15:0] out;

	logic notR2, notR3;
	
	inverter inv2 (.in(writeRegister[2]), .out(notR2));
	inverter inv3 (.in(writeRegister[3]), .out(notR3));
	
	logic foursRegWrite, eightsRegWrite, twelvsRegWrite, sixteenRegWrite;
	and_gate_3_inputs and4 (.a(regWrite), .b(notR2), .c(notR3), .out(foursRegWrite));
	and_gate_3_inputs and8 (.a(regWrite), .b(writeRegister[2]), .c(notR3), .out(eightsRegWrite));
	and_gate_3_inputs and12 (.a(regWrite), .b(notR2), .c(writeRegister[3]), .out(twelvsRegWrite));
	and_gate_3_inputs and16 (.a(regWrite), .b(writeRegister[2]), .c(writeRegister[3]), .out(sixteenRegWrite));
	
	Decoder_2x4 fours (.regWrite(foursRegWrite), .writeRegister(writeRegister[1:0]), .out(out[3:0]));
	Decoder_2x4 eights (.regWrite(eightsRegWrite), .writeRegister(writeRegister[1:0]), .out(out[7:4]));
	Decoder_2x4 twelvs (.regWrite(twelvsRegWrite), .writeRegister(writeRegister[1:0]), .out(out[11:8]));
	Decoder_2x4 sixteens (.regWrite(sixteenRegWrite), .writeRegister(writeRegister[1:0]), .out(out[15:12]));

endmodule

module Decoder_4x16_testbench();
	logic regWrite;
	logic [3:0] writeRegister;
	logic [15:0] out;

	Decoder_4x16 dut (.regWrite, .writeRegister, .out);
	
	integer i,j,k,l;
	
	initial begin
		regWrite = 1; writeRegister = 4'b000; #50;
		for(i = 0; i <= 1; i++) begin
			for(j = 0; j<=1; j++) begin
				for(k = 0; k <= 1; k++) begin
					for(l = 0; l <= 1; l++) begin
						writeRegister[3] = i;
						writeRegister[2] = j;
						writeRegister[1] = k;
						writeRegister[0] = l;
						#200;
					end
				end
			end
		end
	end

endmodule 