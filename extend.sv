module extend #(parameter WIDTH=9) (in, sign, out);
	input logic [WIDTH-1:0] in;
	input logic sign;
	output logic [63:0] out;
	
	assign out[WIDTH-1:0] = in;
	
	logic signCopy;
	and_gate_2_inputs signCheck (.a(sign), .b(in[WIDTH-1]), .out(signCopy));
	
	genvar i;
	generate
		for (i = WIDTH; i < 64; i++) begin: eachBit
			assign out[i] = signCopy; // assign rest of bits to match top bit of input
		end
	endgenerate
endmodule 

module extend_testbench();
	logic [8:0] in;
	logic sign;
	logic [64:0] out;
	
	extend dut (.in, .sign, .out);
	
	initial begin
		in = 9'b010101010; #10;
		in = 9'b101010101; #10;
	end
endmodule 