`timescale 1ps/1ps
module AB_gates (a, b, ctrl, out);
	input logic a, b;
	input logic [1:0] ctrl;
	output logic out;
	
	logic [3:0] finalMuxIn;
	
	and_gate_2_inputs AND (.a, .b, .out(finalMuxIn[0]));
	or_gate_2_inputs OR (.a, .b, .out(finalMuxIn[1]));
	XOR_gate_2_inputs XOR (.a, .b, .out(finalMuxIn[2]));

	assign finalMuxIn[3] = 0; // don't care, but don't want X
	
	mux_4to1 finalMux (.in(finalMuxIn), .sel(ctrl), .out);
	
endmodule 

module AB_gates_testbench();
	logic a, b, out;
	logic [1:0] ctrl;
	
	AB_gates dut (.a, .b, .ctrl, .out);
	
	initial begin
		ctrl = 0; #500;
		for (int i = 0; i < 4; i++) begin
			a = 0; b = 0; #500;
			a = 0; b = 1; #500;
			a = 1; b = 0; #500;
			a = 1; b = 1; #500;
			ctrl += 1; # 500;
		end
	end
endmodule 