
module alu(Rc,Ra,Rb,opcode);
	import InstructionStruct::*;
	output [DWIDTH-1:0] Rc;
	reg [DWIDTH-1:0] Rc;
	input signed [DWIDTH-1:0] Ra,Rb;
	input [5:0] opcode;
	
	initial
		Rc = 0;
	
	always @(*) begin
		case(opcode)
			ADD: Rc <= Ra + Rb;
			SUB: Rc <= Ra - Rb;
			MUL: Rc <= Ra * Rb;
			DIV: Rc <= (Rb != 0) ? (Ra / Rb) : 0;
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
			CMPEQC: Rc <= (Ra == Rb);
			CMPLTC: Rc <= (Ra < Rb);
			CMPLEC: Rc <= (Ra <= Rb);
			default: Rc <= {32{1'bz}};
		endcase
	end
endmodule