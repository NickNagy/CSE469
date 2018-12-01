`timescale 1ps/1ps
module AB_arithmetic (a, b, aShifted, ctrl, cin, out, cout);
	input logic a, b, aShifted, cin;
	input logic [1:0] ctrl;
	output logic out, cout;
	
	logic [1:0] finalMuxIn;
	
	// logic for bottom bit of b
	// separated from generate block b/c different handles for add or subtract
	
	logic [1:0] bMuxBus;
	logic bMuxOut;
	assign bMuxBus[0] = b; // constant wire connection, for module formatting purposes
	inverter invB (.in(b), .out(bMuxBus[1]));
	mux_2to1 shiftMux (.in({aShifted, b}), .sel(ctrl[0]), .out(finalMuxIn[0]));
	mux_2to1 subMux (.in(bMuxBus), .sel(ctrl[0]), .out(bMuxOut));
	bitAdder adder (.a, .b(bMuxOut), .cin, .out(finalMuxIn[1]), .cout);
	
	mux_2to1 finalMux (.in(finalMuxIn), .sel(ctrl[1]), .out);

endmodule 

module AB_arithmetic_testbench();
	logic a, b, cin, cout, out;
	logic [1:0] ctrl;
	
	AB_arithmetic dut (.a, .b, .ctrl, .cin, .out, .cout);
	
	parameter delay = 1000;
	
	// b/c subtraction for 1-bit only works if cin is 1, only need to make sure those
	// conditions are right
	// if (cin)
	//		if a = 0, b = 0: out = 0
	//		if a = 0, b = 1; out = 1
	//		if a = 1, b = 0; out = 1
	//		if a = 1, b = 1; out = 0
	initial begin
		ctrl = 0; cin = 0; #delay;
		for (int i = 0; i < 4; i++) begin
			cin = 0; a = 0; b = 0; #delay;
			cin = 0; a = 0; b = 1; #delay;
			cin = 0; a = 1; b = 0; #delay;
			cin = 0; a = 1; b = 1; #delay;
			cin = 1; a = 0; b = 0; #delay;
			cin = 1; a = 0; b = 1; #delay;
			cin = 1; a = 1; b = 0; #delay;
			cin = 1; a = 1; b = 1; #delay;
			ctrl += 1; #delay;
		end
	end	
endmodule 