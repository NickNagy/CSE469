`timescale 1ps/1ps

module inverter(in, out);
	input logic in;
	output logic out;
	assign #50 out = ~in;
endmodule 

module inverter_testbench();
	logic in, out;
	inverter dut (.in, .out);
	
	initial begin
		in = 0; #100;
		in = 1; #100;
	end
endmodule 