module and_gate_5_inputs (a, b, c, d, e, out);
	input logic a, b, c, d, e;
	output logic out;
	
	logic outTemp;
	
	and_gate_3_inputs firstAnd (.a, .b, .c, .out(outTemp));
	and_gate_3_inputs nextAnd (.a(outTemp), .b(d), .c(e), .out);
	
endmodule