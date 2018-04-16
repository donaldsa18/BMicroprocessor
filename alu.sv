`include "instructions.svh"
`include "params.svh"

module alu(Rc,Ra,Rb,opcode)
	output [DWIDTH-1:0] Rc;
	input signed [DWIDTH-1:0] Ra,Rb;
	input [5:0] opcode;
	//TODO: use memory controller to access registers
	always @(*) begin
		case(opcode)
			ADD: Rc <= Ra + Rb;
			SUB: Rc <= Ra - Rb;
			MUL: Rc <= Ra * Rb;
			DIV: Rc <= Ra / Rb;
			CMPEQ: Rc <= (Ra == Rb);
			CMPLT: Rc <= (Ra < Rb);
			CMPLE: Rc <= (Ra <= Rb);
			AND: Rc <= Ra & Rb;
			OR: Rc <= Ra | Rb;
			XOR: Rc <= Ra ^ Rb;
			XNOR: Rc <= Ra ~^ Rb;
			SHL: Rc <= Ra << Rb;
			SHR: Rc <= Ra >> Rb;
			SRA: Rc <= Ra >>> Rb;
			ANDC: Rc <= Ra & Rb;
			ORC: Rc <= Ra | Rb;
			XORC: Rc <= Ra ^ Rb;
			XNORC: Rc <= Ra ~^ Rb;
			SHLC: Rc <= Ra << Rb;
			SHRC: Rc <= Ra >> Rb;
			SRAC: Rc <= Ra >>> Rb;
		endcase
	end
endmodule