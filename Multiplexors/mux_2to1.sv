`timescale 1ps/1ps

module mux_2to1(in, sel, out);
	input logic [1:0] in;
	input logic sel;
	output logic out;
	
	logic notSel, seland1, notSelandZero;
	inverter invsel (.in(sel), .out(notSel));
	and_gate_2_inputs and0 (.a(notSel), .b(in[0]), .out(notSelandZero));
	and_gate_2_inputs and1 (.a(sel), .b(in[1]), .out(seland1));
	or_gate_2_inputs outgate (.a(seland1), .b(notSelandZero), .out);
	
endmodule 

module mux_2to1_testbench();
	logic [1:0] in;
	logic sel, out;
	
	mux_2to1 dut (.in, .sel, .out);
	
	integer i;
	initial begin
		sel = 0;
		for (i = 0; i < 2; i++) begin
			in = 2'b00; #200;
			in = 2'b01; #200;
			in = 2'b10; #200;
			in = 2'b11; #200;
			sel = ~sel; #200;
		end
	end
	
endmodule 