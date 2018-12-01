`timescale 1ps/1ps

module or_gate_4_inputs(a, b, c, d, out);
	input logic a, b, c, d;
	output logic out;
	assign #50 out = a|b|c|d;
endmodule 