
module cpu(tx,clk,reset);

import InstructionStruct::*;

//Can print characters using this output
output [6:0] tx;
reg [6:0] tx;

//Serial output buffer
string txbuf = "";

reg tx_status;
reg tx_first;

//External clock and active high reset
input clk,reset;

//registers
reg [CPUAWIDTH-1:0] R [NUM_REGS-1:0];

//data bus to memory controller
tri [DWIDTH-1:0] data;

//memory address register
reg [CPUAWIDTH-1:0] MAR;

//memory data register
reg [DWIDTH-1:0] MDR;

//instruction register
instruction_t IR;

//control signals for memory controller
//reg rw,valid;
reg rdEn,wrEn;
//program counter
reg [CPUAWIDTH-1:0] PC;

//ALU registers
reg [DWIDTH-1:0] ARa,ARb;
wire [DWIDTH-1:0] ARc;

//reg isExecuting;//,hasNextInstruction;

//for loops
integer i;

cpu_state_t state;
cpu_state_t nextstate;

//Submodules - memory controller has a memory module
//ALU has registers for Ra&Rb input and wire Rc for ouput
//MemControl mc(data,MAR,clk,reset,rw,valid);
ram mod(data,MAR[AWIDTH+2:3],rdEn,wrEn,reset,clk);
alu math(ARc,ARa,ARb,IR.regular.opcode);



task reset_cpu;
	rdEn <= 0;
	wrEn <= 0;
	MAR <= 0;
	MDR <= 0;
	PC <= 0;
	ARa <= 0;
	ARb <= 0;
	IR <= 0;
	tx <= 0;
	tx_status <= 1;
	tx_first <= 0;
	state <= request_instruction;
	for(i = 0; i < NUM_REGS; i++)
		R[i] <= 0;
endtask


assign data = (wrEn == 1'b1 && rdEn == 1'b0) ? MDR : {DWIDTH{1'bz}};

//Does an ALU instruction
task regular_alu_instruction;
	ARa <= R[IR.regular.Ra];
	ARb <= R[IR.regular.Rb];
	PC <= PC + 4;
	rdEn <= 1'b0;
	wrEn <= 1'b0;
	nextstate <= handle_alu;
endtask

//Does an ALU instruction with a constant in the instruction
task constant_alu_instruction;
	ARa <= R[IR.literal.Ra];
	ARb <= IR.literal.lit;
	PC <= PC + 4;
	rdEn <= 1'b0;
	wrEn <= 1'b0;
	nextstate <= handle_alu;
endtask

//Set the exception pointer
task invalidop;
	txbuf <= $sformatf("Invalid instruction opcode=%h PC=%d\n ",IR.regular.opcode,PC);
	nextstate <= trap;
endtask

//Print each character in the buffer one by one until it is empty
//Follows UART protocol
task printString;
	if(txbuf.len() > 0) begin
		//Start each message with a 0
		if(tx_status) begin
			tx = 0;
			tx_status = 0;
			tx_first = 1;
		end
		else begin
			tx = txbuf[0];
			//Accomidate for the first skipped tx buf
			if(tx_first && txbuf.len() == 2) begin
				txbuf = txbuf.substr(2,txbuf.len()-1);
			tx_first = 0;
			end
			else
				txbuf = txbuf.substr(1,txbuf.len()-1);
		end
	end
	//End each message with all 1's
	else begin
		tx <= 7'b1111111;
		tx_status <= 1;
	end
endtask

initial
	reset_cpu;

//always @(negedge clk)
//	printString;

always @(posedge clk, posedge reset) begin
	if(reset) reset_cpu;
	else begin
		case(state)
		trap: nextstate <= trap;
		request_instruction: begin
			MAR <= PC;
			rdEn <= 1'b1;
			wrEn <= 1'b0;
			nextstate <= read_instruction;
		end
		read_instruction: begin
			IR <= data;
			nextstate <= exec_instruction;
		end
		exec_instruction: begin
			case(IR.bits[31:29])
				3'b011: begin //other instructions
					case(IR.literal.opcode)
					LD: begin
						MAR <= R[IR.literal.Ra] + IR.literal.lit;
						rdEn <= 1'b1;
						wrEn <= 1'b0;
						PC <= PC + 4;
						nextstate <= handle_ld;
					end
					ST: begin
						MDR <= R[IR.literal.Rc];
						MAR <= R[IR.literal.Ra] + IR.literal.lit;
						rdEn <= 1'b0;
						wrEn <= 1'b1;
						PC <= PC + 4;
						nextstate <= disable_mem_st;
					end
					DISP: begin
						txbuf = $sformatf("%s%c",txbuf,R[IR.literal.Rc][6:0]);
						rdEn <= 1'b0;
						wrEn <= 1'b0;
						PC <= PC + 4;
						nextstate <= two_empty_cycles;
					end
					JMP: begin
						R[IR.literal.Rc] <= PC+4;
						rdEn <= 1'b0;
						wrEn <= 1'b0;
						PC <= R[IR.literal.Ra];
						nextstate <= two_empty_cycles;
					end
					BEQ: begin
						R[IR.literal.Rc] = PC+4;
						rdEn <= 1'b0;
						wrEn <= 1'b0;
						PC <= (R[IR.literal.Ra] == 0) ? (PC + (4*IR.literal.lit)) : (PC + 4);
						nextstate <= two_empty_cycles;
					end
					BNE: begin
						R[IR.literal.Rc] = PC+4;
						rdEn <= 1'b0;
						wrEn <= 1'b0;
						PC <= (R[IR.literal.Ra] != 0) ? (PC + 4 + (4*IR.literal.lit)) : (PC + 4);
						nextstate <= two_empty_cycles;
					end
					DISPC: begin
						txbuf = $sformatf("%s%c",txbuf,IR.literal.lit[6:0]);
						//tx <= IR.literal.lit[6:0];
						rdEn <= 1'b0;
						wrEn <= 1'b0;
						PC <= PC + 4;
						nextstate <= two_empty_cycles;
					end
					LDR: begin
						MAR <= PC + 4 + (4*IR.literal.lit);
						rdEn <= 1'b0;
						wrEn <= 1'b0;
						PC <= PC + 4;
						nextstate <= handle_ld;
					end
					default: invalidop;
					endcase
				end
				3'b100: regular_alu_instruction;
				3'b101: regular_alu_instruction;
				3'b110: constant_alu_instruction;
				3'b111: constant_alu_instruction;
				3'b000: begin
					if(IR.literal.opcode == EXIT)
						nextstate = trap;
					else
						invalidop;
				end
				default: invalidop;
			endcase
		end
		handle_ld: begin
			R[IR.literal.Rc] <= MDR;
			nextstate <= disable_mem_ld;
		end
		disable_mem_ld: begin
			rdEn <= 1'b0;
			wrEn <= 1'b0;
			nextstate <= request_instruction;
		end
		disable_mem_st: begin
			rdEn <= 1'b0;
			wrEn <= 1'b0;
			nextstate <= empty_cycle;
		end
		handle_alu: begin
			R[IR.regular.Rc] <= (IR.literal.Rc != 5'd31) ? ARc : 0;
			rdEn <= 1'b0;
			wrEn <= 1'b0;
			nextstate <= empty_cycle;
		end
		two_empty_cycles: begin
			rdEn <= 1'b0;
			wrEn <= 1'b0;
			nextstate <= empty_cycle;
		end
		empty_cycle: begin
			rdEn <= 1'b0;
			wrEn <= 1'b0;
			nextstate <= request_instruction;
		end
		endcase
		state = nextstate;
		printString;
	end
end

endmodule
