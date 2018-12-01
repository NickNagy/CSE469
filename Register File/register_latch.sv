`timescale 1ps/1ps

module register_latch (in, writeEnable, out, clk);
	input logic in, writeEnable, clk;
	output logic out;
	
	logic q1, d1, d2, notWE, outAndNotWE;
	
	inverter writeInv (.in(writeEnable), .out(notWE));
	//D_FF first(.q(q1), .d(in), .reset(notWE), .clk);
	and_gate_2_inputs ndi (.a(in), .b(writeEnable), .out(d1));
	and_gate_2_inputs ndo (.a(out), .b(notWE), .out(outAndNotWE));
	or_gate_2_inputs r (.a(d1), .b(outAndNotWE), .out(d2));
	D_FF second(.q(out), .d(d2), .reset(1'b0), .clk);

endmodule

module register_latch_testbench();
	logic in, writeEnable, clk, out;
	
	register_latch dut (.in, .writeEnable, .out, .clk);
	
	parameter CLOCK_PERIOD = 5000;
	
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~ clk;
	end
	
	initial begin
		writeEnable <= 1; in <= 1;	@(posedge clk);
		writeEnable <= 1; in <= 0; @(posedge clk);
		writeEnable <= 0; in <= 1;	@(posedge clk);
		writeEnable <= 0; in <= 0;	@(posedge clk);
		$stop;
	end
	
endmodule 