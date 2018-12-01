`timescale 1ps/1ps

module and_gate_3_inputs (a, b, c, out);
	input logic a, b, c;
	output logic out;
	
	assign #50 out = a&b&c;
endmodule

module and_gate_3_inputs_testbench();
	logic a, b, c, out;
	
	and_gate_3_inputs dut (.a, .b, .c, .out);
	
	initial begin
		for (int i = 0; i < 2; i++) begin
			for (int j = 0; j < 2; j++) begin
				for (int k = 0; k < 2; k++) begin
					a = i; b = j; c = k; #100;
				end
			end
		end
	end
	
endmodule 