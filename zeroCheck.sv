`timescale 1ps/1ps
module zeroCheck(in, out);
	input logic [63:0] in;
	output logic out;
	
	logic [15:0] temp1;
	logic [3:0] temp2;
	logic notzero;
	
	genvar i, j;
	generate
		for (i = 0; i < 16; i++) begin: eachOrLayer1
			// can I do this?
			or_gate_4_inputs og16 (.a(in[4*i]), .b(in[4*i+1]), .c(in[4*i+2]), .d(in[4*i+3]), .out(temp1[i]));
		end
	endgenerate
	
	generate
		for (i = 0; i < 4; i++) begin: eachOrLayer2
			or_gate_4_inputs og4 (.a(temp1[4*i]), .b(temp1[4*i+1]), .c(temp1[4*i+2]), .d(temp1[4*i+3]), .out(temp2[i])); 
		end	
	endgenerate
	
	or_gate_4_inputs orout (.a(temp2[0]), .b(temp2[1]), .c(temp2[2]), .d(temp2[3]), .out(notzero));
	
	inverter inv (.in(notzero), .out);
endmodule 
	
module zeroCheck_testbench();
	logic [63:0] in;
	logic out;
	
	zeroCheck dut (.in, .out);
	
	initial begin
		in = 1; #500;
		for (int i = 0; i < 63; i++) begin
			in = in << 1; #500;
		end
		in = 0; #500;
	end
endmodule
