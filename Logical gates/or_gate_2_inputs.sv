`timescale 1ps/1ps

module or_gate_2_inputs(a, b, out);
	input logic a, b;
	output logic out;
	
	assign #50 out = a|b;
endmodule 

module or_gate_2_inputs_testbench();
	logic a, b, out;
	
	or_gate_2_inputs dut (.a, .b, .out);
	
	initial begin
		a = 0; b = 0; #100;
		a = 0; b = 1; #100;
		a = 1; b = 0; #100;
		a = 1; b = 1; #100;
	end

endmodule