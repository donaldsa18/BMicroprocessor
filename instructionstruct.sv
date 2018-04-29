package InstructionStruct;
`include "params.svh"
typedef enum bit [5:0] {
	LD     = 6'b011000,
	ST     = 6'b011001,
	DISP   = 6'b011110, //a new instruction for displaying text
	JMP    = 6'b011011,
	BEQ    = 6'b011100,
	BNE    = 6'b011101,
	DISPC  = 6'b011010, //a new instruction for displaying constant text
	LDR    = 6'b011111,
	ADD    = 6'b100000,
	SUB    = 6'b100001,
	MUL    = 6'b100010,
	DIV    = 6'b100011,
	CMPEQ  = 6'b100100,
	CMPLT  = 6'b100101,
	CMPLE  = 6'b100110,
	AND    = 6'b101000,
	OR     = 6'b101001,
	XOR    = 6'b101010,
	XNOR   = 6'b101011,
	SHL    = 6'b101100,
	SHR    = 6'b101101,
	SRA    = 6'b101110,
	ADDC   = 6'b110000,
	SUBC   = 6'b110001,
	MULC   = 6'b110010,
	DIVC   = 6'b110011,
	CMPEQC = 6'b110100,
	CMPLTC = 6'b110101,
	CMPLEC = 6'b110110,
	ANDC   = 6'b111000,
	ORC    = 6'b111001,
	XORC   = 6'b111010,
	XNORC  = 6'b111011,
	SHLC   = 6'b111100,
	SHRC   = 6'b111101,
	SRAC   = 6'b111110,
	EXIT   = 6'b000001,
	NOOP   = 6'b000000
} opcode_t;

typedef enum {
	request_instruction,
	read_instruction,
	exec_instruction,
	handle_ld,
	disable_mem_st,
	handle_ldr,
	handle_alu,
	trap,
	empty_cycle,
	read_string,
	read_int,
	read_float,
	read_string_mem,
	read_next_str_mem,
	handle_jmp,
	handle_beq,
	handle_bne,
	read_next_str
} cpu_state_t;

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

typedef struct packed {
	opcode_t opcode;
	bit [1:0] datatype;
	bit [6:0] charA;
	bit [6:0] charB;
	bit [6:0] charC;
	bit [2:0] unused;
} instruction_str_t;

typedef union packed {
	instruction_reg_t regular;
	instruction_lit_t literal;
	instruction_str_t str;
	bit [31:0] bits;
} instruction_t;

endpackage : InstructionStruct