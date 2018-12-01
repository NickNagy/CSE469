`timescale 1ps/1ps
module XOR_gate_2_inputs (a, b, out);
	input logic a, b;
	output logic out;
	
	logic notA, notB;
	
	inverter invA (.in(a), .out(notA));
	inverter invB (.in(b), .out(notB));
	
	logic aNotB, bNotA;
	
	and_gate_2_inputs andANotB (.a, .b(notB), .out(aNotB));
	and_gate_2_inputs andBNotA (.a(notA), .b, .out(bNotA));
	
	or_gate_2_inputs finalOR (.a(aNotB), .b(bNotA), .out);
	
endmodule 