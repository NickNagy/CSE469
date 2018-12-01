`timescale 1ps/1ps
module system_control_signals(instruction, zero, negative, overflow, carry_out, UncondBr, BrTaken, Reg2Loc, RegWrite, MemWrite, MemToReg, ALUSrc, weFlags, ALUOp);
	input logic [31:0] instruction;
	input logic zero, negative, overflow, carry_out;
	output logic UncondBr, BrTaken, Reg2Loc, RegWrite, MemWrite, MemToReg, ALUSrc, weFlags;
	output logic [2:0] ALUOp;
	
	logic negXORoverflow;
	XOR_gate_2_inputs nXORo (.a(negative), .b(overflow), .out(negXORoverflow));
	
	always_comb begin
		if (instruction[31]) begin
			UncondBr = 0;
			if (instruction[30]) begin
				BrTaken = 0;
				if (instruction[29]) begin
					if (instruction[28]) begin
						weFlags = 0;
						ALUOp = 3'b010;
						ALUSrc = 1;
						Reg2Loc = 0;
						if (instruction[22]) begin // LDUR
							MemToReg = 1;
							RegWrite = 1;
							MemWrite = 0;
						end else begin // STUR
							RegWrite = 0;
							MemWrite = 1;
							MemToReg = 0;
						end
					end else begin // SUBS
						Reg2Loc = 1;
						MemToReg = 0;
						RegWrite = 1;
						MemWrite = 0;
						BrTaken = 0;
						ALUOp = 3'b011;
						ALUSrc = 0;
						weFlags = 1;
					end
				end else begin // LSR AND EOR, bit 28 affects which in other logic
					weFlags = 0;
					Reg2Loc = 1;
					ALUSrc = 0;
					MemToReg = 0;
					RegWrite = 1;
					MemWrite = 0;
					UncondBr = 0;
					if (instruction[28]) begin // LSR
						ALUOp = 3'b001;
					end else begin
						// XOR
						ALUOp = 3'b110;
					end
				end
			end else begin
				MemWrite = 0;
				MemToReg = 0;
				if (instruction [29]) begin
					ALUSrc = 0;
					if (instruction[26]) begin // CBZ
						Reg2Loc = 0;
						RegWrite = 0;
						BrTaken = zero;
						weFlags = 0;
						ALUOp = 3'b000; // testB
					end else begin // ADDS
						Reg2Loc = 1;
						RegWrite = 1;
						BrTaken = 0;
						weFlags = 1;
						ALUOp = 3'b010;
					end
				end else begin
					weFlags = 0;
					Reg2Loc = 1;
					RegWrite = 1;
					BrTaken = 0;
					if (instruction[28]) begin // ADDI
						ALUSrc = 1;
						ALUOp = 3'b010;
					end else begin // AND
						ALUSrc = 0;
						ALUOp = 3'b100; // &
					end
				end
			end
		end else begin // B or B.LT
			weFlags = 0;
			RegWrite = 0;
			Reg2Loc = 0;
			MemWrite = 0;
			MemToReg = 0;
			ALUSrc = 0;
			if (instruction[30]) begin // B.LT
				BrTaken = negXORoverflow;
				UncondBr = 0;
				ALUOp = 3'b011; // sub
			end else begin // B
				BrTaken = 1;
				UncondBr = 1;
				ALUOp = 3'b010; // add
			end
		end
	end
endmodule

module system_control_signals_testbench();
	logic [31:0] instruction;
	logic [2:0] ALUOp;
	logic zero, negative, overflow, carry_out, UncondBr, BrTaken, Reg2Loc, RegWrite, MemWrite, MemToReg, ALUSrc;
	
	system_control_signals dut (.instruction, .zero, .negative, .overflow, .carry_out, .UncondBr, .BrTaken, .Reg2Loc, .RegWrite, .MemWrite, .MemToReg, .ALUSrc, .ALUOp);
	
	parameter delay = 1000;
	
	// for this module, not concerned with any part of instruction besides opcode
	initial begin
		instruction = 32'b1001000100xxxxxxxxxxxxxxxxxxxxxx; #delay; //ADDI 
		instruction = 32'b10101011000xxxxxxxxxxxxxxxxxxxxx; #delay; //ADDS	
		instruction = 32'b10001010000xxxxxxxxxxxxxxxxxxxxx; #delay; //AND
		instruction = 32'b000101xxxxxxxxxxxxxxxxxxxxxxxxxx; #delay; //B
		instruction = 32'b01010100xxxxxxxxxxxxxxxxxxxxxxxx; 		   //B.LT
		negative = 0; overflow = 0; 								 #delay; 
		negative = 0; overflow = 1;								 #delay;
		negative = 1; overflow = 0;								 #delay;
		negative = 1; overflow = 1;								 #delay;
		instruction = 32'b10110100xxxxxxxxxxxxxxxxxxxxxxxx;         //CBZ
		zero = 0;														 #delay; 
		zero = 1;													    #delay;
		instruction = 32'b11001010000xxxxxxxxxxxxxxxxxxxxx; #delay; //EOR
		instruction = 32'b11111000010xxxxxxxxxxxxxxxxxxxxx; #delay; //LDUR
		instruction = 32'b11010011100xxxxxxxxxxxxxxxxxxxxx; #delay; //LSR
		instruction = 32'b11111000000xxxxxxxxxxxxxxxxxxxxx; #delay; //STUR
		instruction = 32'b11101011000xxxxxxxxxxxxxxxxxxxxx; #delay; //SUBS
	end
endmodule