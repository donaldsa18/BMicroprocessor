
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
reg signed [DWIDTH-1:0] R [NUM_REGS-1:0];

//data bus to memory controller
tri signed [DWIDTH-1:0] data;

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
ram mod(data,MAR[AWIDTH+1:2],rdEn,wrEn,reset,clk);
alu math(ARc,ARa,ARb,IR.bits[DWIDTH-1:DWIDTH-6]);



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
	nextstate <= request_instruction;
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
	ARb <= {{8{IR.literal.lit[15]}},IR.literal.lit };
	PC <= PC + 4;
	rdEn <= 1'b0;
	wrEn <= 1'b0;
	nextstate <= handle_alu;
endtask

//Set the exception pointer
task invalidop;
	txbuf <= $sformatf("Invalid instruction opcode=%h PC=%d\n ",IR.regular.opcode,PC);
	nextstate <= trap;
	rdEn <= 1'b0;
	wrEn <= 1'b0;
endtask

//Print each character in the buffer one by one until it is empty
//Follows UART protocol
task printString;
	if(txbuf.len() > 0) begin
		//Start each message with a 0
		if(tx_status) begin
			tx <= 0;
			tx_status <= 0;
			tx_first <= 1;
		end
		else begin
			tx <= txbuf[0];
			//Accomidate for the first skipped tx buf
			/*if(tx_first && txbuf.len() == 2) begin
				txbuf <= txbuf.substr(2,txbuf.len()-1);
				tx_first <= 0;
			end
			else*/
			txbuf <= txbuf.substr(1,txbuf.len()-1);
		end
	end
	//End each message with all 1's
	else begin
		tx <= 7'b1111111;
		tx_status <= 1;
	end
endtask

task trimString;
	if(txbuf.len() > 0 && !tx_status)
		txbuf <= txbuf.substr(1,txbuf.len()-1);
endtask

initial
	reset_cpu;

always @(negedge clk) begin
	state <= nextstate;
	printString;
end

always @(posedge reset) reset_cpu;

always @(posedge clk) begin
		case(state)
		trap: begin
			nextstate <= trap;
			rdEn <= 1'b0;
			wrEn <= 1'b0;
		end
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
						case(IR.literal.Rc)
							5'd1: begin
								rdEn <= 1'b0;
								wrEn <= 1'b0;
								txbuf <= $sformatf("%s%0d",txbuf,R[IR.literal.Ra]);
								nextstate <= two_empty_cycles;
							end
							5'd2: begin
								rdEn <= 1'b0;
								wrEn <= 1'b0;
								txbuf <= $sformatf("%s%0f",txbuf,R[IR.literal.Ra]);
								nextstate <= two_empty_cycles;
							end
							5'd3: begin
								rdEn <= 1'b1;
								wrEn <= 1'b0;
								nextstate <= read_string_mem;
							end
							default: begin
								txbuf <= "Invalid disp command ";
								nextstate <= trap;
							end
						endcase
						PC <= PC + 4;
					end
					JMP: begin
						R[IR.literal.Rc] <= PC+4;
						rdEn <= 1'b0;
						wrEn <= 1'b0;
						nextstate <= handle_jmp;
					end
					BEQ: begin
						R[IR.literal.Rc] <= PC+4;
						rdEn <= 1'b0;
						wrEn <= 1'b0;
						nextstate <= handle_beq;
					end
					BNE: begin
						R[IR.literal.Rc] <= PC+4;
						rdEn <= 1'b0;
						wrEn <= 1'b0;
						nextstate <= handle_bne;
					end
					DISPC: begin
						case(IR.str.datatype)
						2'd1: begin //print int
							MAR <= PC+4;
							rdEn <= 1'b1;
							wrEn <= 1'b0;
							nextstate <= read_int;
						end
						2'd2: begin
							MAR <= PC+4;
							rdEn <= 1'b1;
							wrEn <= 1'b0;
							nextstate <= read_float;
						end
						2'd3: begin
							if(IR.str.charA != 0) begin
								if(IR.str.charB != 0) begin
									if(IR.str.charC != 0) begin
										txbuf <= $sformatf("%s%c%c%c",txbuf,IR.str.charA,IR.str.charB,IR.str.charC);
										nextstate <= read_next_str;
										rdEn <= 1'b1;
										wrEn <= 1'b0;
									end
									else begin
										txbuf <= $sformatf("%s%c%c",txbuf,IR.str.charA,IR.str.charB);
										PC <= PC + 4;
										rdEn <= 1'b0;
										wrEn <= 1'b0;
										nextstate <= two_empty_cycles;
									end
								end
								else begin
									txbuf <= $sformatf("%s%c",txbuf,IR.str.charA);
									rdEn <= 1'b0;
									wrEn <= 1'b0;
									PC <= PC + 4;
									nextstate <= two_empty_cycles;
								end
							end
							else begin
								rdEn <= 1'b0;
								wrEn <= 1'b0;
								txbuf <= "Invalid dispc command empty string ";
								nextstate <= trap;
							end
						end
						default: begin
								txbuf <= "Invalid dispc command type=0 ";
								nextstate <= trap;
							end
						endcase
					end
					LDR: begin
						MAR <= PC + 4 + (4*IR.literal.lit);
						rdEn <= 1'b1;
						wrEn <= 1'b0;
						nextstate <= handle_ld;
					end
					default: invalidop;
					endcase
				end
				3'b100: regular_alu_instruction;
				3'b101: regular_alu_instruction;
				3'b110: constant_alu_instruction;
				3'b111: constant_alu_instruction;
				3'b000: case(IR.literal.opcode)
					EXIT: nextstate <= trap;
					NOOP: begin
						nextstate <= two_empty_cycles;
						PC <= PC + 4;
					end
					default: invalidop;
					endcase
				default: invalidop;
			endcase
		end
		read_next_str: begin
			MAR <= MAR+4;
			rdEn <= 1'b1;
			wrEn <= 1'b0;
			nextstate <= read_string;
		end
		handle_bne: begin
			PC <= (R[IR.literal.Ra] != 0) ? (PC + 4 + (4*IR.literal.lit)) : (PC + 4);
			nextstate <= empty_cycle;
		end
		handle_beq: begin
			PC <= (R[IR.literal.Ra] == 0) ? (PC + 4 + (4*IR.literal.lit)) : (PC + 4);
			nextstate <= empty_cycle;
		end
		handle_jmp: begin
			PC <= R[IR.literal.Ra];
			nextstate <= empty_cycle;
		end
		handle_ld: begin
			R[IR.literal.Rc] <= data;
			PC <= PC + 4;
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
			nextstate = empty_cycle;
		end
		handle_alu: begin
			R[IR.regular.Rc] <= (IR.regular.Rc != 5'd31) ? ARc : 0;
			rdEn <= 1'b0;
			wrEn <= 1'b0;
			nextstate <= empty_cycle;
		end
		read_string: begin
			if(data[31:25] != 0) begin
				if(data[24:18] != 0) begin
					if(data[17:11] != 0) begin
						if(data[10:4] != 0) begin
							txbuf <= $sformatf("%s%c%c%c%c",txbuf,{1'b0,data[31:25]},{1'b0,data[24:18]},{1'b0,data[17:11]},{1'b0,data[10:4]});
							nextstate <= read_next_str;
						end
						else begin
							txbuf <= $sformatf("%s%c%c%c",txbuf,{1'b0,data[31:25]},{1'b0,data[24:18]},{1'b0,data[17:11]});
							PC <= MAR + 4;
							nextstate <= request_instruction;
						end
					end
					else begin
						txbuf <= $sformatf("%s%c%c",txbuf,{1'b0,data[31:25]},{1'b0,data[24:18]});
						PC <= MAR + 4;
						nextstate <= request_instruction;
					end
				end
				else begin
					txbuf <= $sformatf("%s%c",txbuf,{1'b0,data[31:25]});
					PC <= MAR + 4;
					nextstate <= request_instruction;
				end
			end
			else begin
				PC <= MAR + 4;
				nextstate <= request_instruction;
			end
		end
		read_string_mem: begin
			if(data[31:25] != 0) begin
				if(data[24:18] != 0) begin
					if(data[17:11] != 0) begin
						if(data[10:4] != 0) begin
							txbuf <= $sformatf("%s%c%c%c%c",txbuf,{1'b0,data[31:25]},{1'b0,data[24:18]},{1'b0,data[17:11]},{1'b0,data[10:4]});
							MAR <= MAR + 4;
							nextstate <= read_string;
						end
						else begin
							txbuf <= $sformatf("%s%c%c%c",txbuf,{1'b0,data[31:25]},{1'b0,data[24:18]},{1'b0,data[17:11]});
							nextstate <= request_instruction;
						end
					end
					else begin
						txbuf <= $sformatf("%s%c%c",txbuf,{1'b0,data[31:25]},{1'b0,data[24:18]});
						nextstate <= request_instruction;
					end
				end
				else begin
					txbuf <= $sformatf("%s%c",txbuf,{1'b0,data[31:25]});
					nextstate <= request_instruction;
				end
			end
			else begin
				nextstate <= request_instruction;
			end
		end
		read_int: begin
			txbuf <= $sformatf("%s%0d",txbuf,data);
			nextstate <= empty_cycle;
			PC <= PC + 8;
		end
		read_float: begin
			txbuf <= $sformatf("%s%0f",txbuf,data);
			nextstate <= empty_cycle;
			PC <= PC + 8;
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
		default: invalidop;
		endcase
		//state = nextstate;
		//printString;
end

endmodule
