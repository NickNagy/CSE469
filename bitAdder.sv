`timescale 1ps/1ps
module bitAdder (a, b, cin, cout, out);
	input logic a, b, cin;
	output logic cout, out;
	
	logic notA, notB, notCin, onlyA, onlyB, onlyCin, allTrue, onlyNotA, onlyNotB, onlyNotCin;
	
	inverter invA (.in(a), .out(notA));
	inverter invB (.in(b), .out(notB));
	inverter invCin (.in(cin), .out(notCin));
	
	and_gate_3_inputs oA (.a, .b(notB), .c(notCin), .out(onlyA));
	and_gate_3_inputs oB (.a(notA), .b, .c(notCin), .out(onlyB));
	and_gate_3_inputs oC (.a(notA), .b(notB), .c(cin), .out(onlyCin));
	and_gate_3_inputs oNA (.a(notA), .b, .c(cin), .out(onlyNotA));
	and_gate_3_inputs oNB (.a, .b(notB), .c(cin), .out(onlyNotB));
	and_gate_3_inputs oNC (.a, .b, .c(notCin), .out(onlyNotCin));
	and_gate_3_inputs all (.a, .b, .c(cin), .out(allTrue));
	
	or_gate_4_inputs outLogic (.a(onlyA), .b(onlyB), .c(onlyCin), .d(allTrue), .out);
	or_gate_4_inputs cOutLogic (.a(onlyNotA), .b(onlyNotB), .c(onlyNotCin), .d(allTrue), .out(cout));
	
endmodule 

module bitAdder_testbench();
	logic a, b, cin, cout, out;
	
	bitAdder dut (.a, .b, .cin, .cout, .out);
	
	initial begin
		cin = 0; a = 0; b = 0; #500;
		cin = 0; a = 0; b = 1; #500;
		cin = 0; a = 1; b = 0; #500;
		cin = 0; a = 1; b = 1; #500;
		cin = 1; a = 0; b = 0; #500;
		cin = 1; a = 0; b = 1; #500;
		cin = 1; a = 1; b = 0; #500;
		cin = 1; a = 1; b = 1; #500;
	end
endmodule 	