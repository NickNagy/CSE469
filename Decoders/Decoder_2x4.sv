`timescale 1ps/1ps

module Decoder_2x4(regWrite, writeRegister, out);
	input logic regWrite;
	input logic [1:0] writeRegister;
	output logic [3:0] out;
	
	logic notR0, notR1;
	inverter inv0 (.in(writeRegister[0]), .out(notR0));
	inverter inv1 (.in(writeRegister[1]), .out(notR1));
	
	and_gate_3_inputs and0 (.a(notR0), .b(notR1), .c(regWrite), .out(out[0]));
	and_gate_3_inputs and1 (.a(writeRegister[0]), .b(notR1), .c(regWrite), .out(out[1]));
	and_gate_3_inputs and2 (.a(notR0), .b(writeRegister[1]), .c(regWrite), .out(out[2]));
	and_gate_3_inputs and3 (.a(writeRegister[0]), .b(writeRegister[1]), .c(regWrite), .out(out[3]));

endmodule

module Decoder_2x4_testbench();
	logic regWrite;
	logic [1:0] writeRegister;
	logic [3:0] out;
	
	Decoder_2x4 dut (.regWrite, .writeRegister, .out);
	
	integer i;
	initial begin
		regWrite = 1;
		for (i = 0; i < 2; i++) begin
			writeRegister = 2'b00; #50;
			writeRegister = 2'b01; #50;
			writeRegister = 2'b10; #50;
			writeRegister = 2'b11; #50;
			regWrite = ~regWrite; #50;
			#50;
		end
	end

endmodule 