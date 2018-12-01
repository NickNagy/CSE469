// DO NOT MODIFY!!!

module D_FF (q, d, reset, clk);
	output reg q;
	input d, reset, clk;
 
	always_ff @(posedge clk)
		if (reset)
			q <= 0; // On reset, set to 0
		else
			q <= d; // Otherwise out = d
	
endmodule

module D_FF_testbench();

endmodule 
