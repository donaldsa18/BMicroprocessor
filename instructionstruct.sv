package InstructionStruct;
typedef enum opcode[5:0] {
	LD = 6'b011000,
	ST = 6'b011001,
	JMP = 6'b011011,
	BEQ = 6'b011100,
	BNE = 6'b011101,
	LDR = 6'b011111,
	ADD = 6'b100000,
	SUB = 6'b100001,
	MUL = 6'b100010,
	DIV = 6'b100011,
	CMPEQ = 6'b100100,
	CMPLT = 6'b100101,
	CMPLE = 6'b100110,
	AND = 6'b101000,
	OR = 6'b101001,
	XOR = 6'b101010,
	XNOR = 6'b101011,
	SHL = 6'b101100,
	SHR = 6'b101101,
	SRA = 6'b101110,
	ADDC = 6'b101000,
	SUBC = 6'b110001,
	MULC = 6'b110010,
	DIVC = 6'b110011,
	CMPEQC = 6'b110100,
	CMPLTC = 6'b110101,
	CMPLEC = 6'b110110,
	ANDC = 6'b111000,
	ORC = 6'b111001,
	XORC = 6'b111010,
	XNORC = 6'b111011,
	SHLC = 6'b111100,
	SHRC = 6'b111101,
	SRAC = 6'b111110
} opcode_t;

typedef struct packed {
	opcode_t opcode;
	bit [4:0] Rc;
	bit [4:0] Ra;
	bit [4:0] Rb;
	bit [10:0] unused;
} instruction_reg_t;

typedef struct packed {
	opcode_t opcode;
	bit [4:0] Rc;
	bit [4:0] Ra;
	bit [15:0] lit;
} instruction_lit_t;

typedef union packed {
	instruction_reg_t regular;
	instruction_lit_t literal;
	bit [31:0] bits;
} instruction_t;

endpackage