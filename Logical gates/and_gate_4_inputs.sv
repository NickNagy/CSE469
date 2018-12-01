`timescale 1ps/1ps

module and_gate_4_input(a, b, c, d, out);
	input logic a, b, c, d;
	output logic out;
	assign #50 out = a & b & c & d;
endmodule 