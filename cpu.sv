/*
*
* B-Processor
*
* Authors: Anthony Donaldson, Matthew Erhardt
*
*/
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

task write_mem;
	rdEn <= 1'b0;
	wrEn <= 1'b1;
endtask

task read_mem;
	rdEn <= 1'b1;
	wrEn <= 1'b0;
endtask

task disable_mem;
	rdEn <= 1'b0;
	wrEn <= 1'b0;
endtask

assign data = (wrEn == 1'b1 && rdEn == 1'b0) ? MDR : {DWIDTH{1'bz}};


//Set the exception pointer
task invalidop_control;
	disable_mem;
	nextstate <= trap;
endtask

task invalidop_data;
	txbuf <= $sformatf("%sInvalid instruction opcode=%h PC=%d\n",txbuf,IR.regular.opcode,PC);
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
			txbuf <= txbuf.substr(1,txbuf.len()-1);
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

always @(negedge clk) begin
	state <= nextstate;
	printString;
end

always @(posedge reset) reset_cpu;

//Data path
//Sets registers based on current state
always @(posedge clk) begin
case(state)
	request_instruction: MAR <= PC;
	read_instruction: IR <= data;
	exec_instruction: 
	case(IR.bits[31:29])
		3'b000: PC <= (IR.literal.opcode == NOOP) ? (PC+4) : (PC);
		3'b011: begin //other instructions
			case(IR.literal.opcode)
			LD: MAR <= R[IR.literal.Ra] + IR.literal.lit;
			ST: begin
				MDR <= R[IR.literal.Rc];
				MAR <= R[IR.literal.Ra] + IR.literal.lit;
				PC <= PC + 4;
			end
			DISP: begin
				case(IR.literal.Rc)
					5'd1: txbuf <= $sformatf("%s%0d",txbuf,R[IR.literal.Ra]);
					5'd2: txbuf <= $sformatf("%s%0f",txbuf,R[IR.literal.Ra]);
					5'd3: MAR <= PC + 4 + (4*IR.literal.lit);
					default: txbuf <= "Invalid disp command ";
				endcase
				PC <= PC + 4;
			end
			JMP,BEQ,BNE: R[IR.literal.Rc] <= PC+4;
			DISPC: begin
				case(IR.str.datatype)
				2'd1,2'd2: MAR <= PC+4;
				2'd3: begin
					if(IR.str.charA != 0) begin
						if(IR.str.charB != 0) begin
							if(IR.str.charC != 0) begin
								txbuf <= $sformatf("%s%c%c%c",txbuf,IR.str.charA,IR.str.charB,IR.str.charC);
							end
							else begin
								txbuf <= $sformatf("%s%c%c",txbuf,IR.str.charA,IR.str.charB);
								PC <= PC + 4;
							end
						end
						else begin
							txbuf <= $sformatf("%s%c",txbuf,IR.str.charA);
							PC <= PC + 4;
						end
					end
					else begin
						txbuf <= "Invalid dispc command empty string\n";
					end
				end
				default: txbuf <= "Invalid dispc command type=0\n";
				endcase
			end
			LDR: MAR <= PC + 4 + (4*IR.literal.lit);
			default: invalidop_data;
			endcase
		end
		3'b100,3'b101: begin
			ARa <= R[IR.regular.Ra];
			ARb <= R[IR.regular.Rb];
			PC <= PC + 4;
		end
		3'b110,3'b111: begin
			ARa <= R[IR.literal.Ra];
			ARb <= {{8{IR.literal.lit[15]}},IR.literal.lit };
			PC <= PC + 4;
		end
		3'b000: case(IR.literal.opcode)
			EXIT,NOOP: PC <= PC;
			default: invalidop_data;
			endcase
		default: invalidop_data;
	endcase
	read_next_str,read_next_str_mem: MAR <= MAR+4;
	handle_bne: PC <= (R[IR.literal.Ra] != 0) ? (PC + 4 + (4*IR.literal.lit)) : (PC + 4);
	handle_beq: PC <= (R[IR.literal.Ra] == 0) ? (PC + 4 + (4*IR.literal.lit)) : (PC + 4);
	handle_jmp: PC <= R[IR.literal.Ra];
	handle_ld: begin
		R[IR.literal.Rc] <= data;
		PC <= PC + 4;
	end
	handle_alu: R[IR.regular.Rc] <= (IR.regular.Rc != 5'd31) ? ARc : 0;
	read_string: begin
		if(data[31:25] != 0) begin
			if(data[24:18] != 0) begin
				if(data[17:11] != 0) begin
					if(data[10:4] != 0) begin
						txbuf <= $sformatf("%s%c%c%c%c",txbuf,{1'b0,data[31:25]},{1'b0,data[24:18]},{1'b0,data[17:11]},{1'b0,data[10:4]});
					end
					else begin
						txbuf <= $sformatf("%s%c%c%c",txbuf,{1'b0,data[31:25]},{1'b0,data[24:18]},{1'b0,data[17:11]});
						PC <= MAR + 4;
					end
				end
				else begin
					txbuf <= $sformatf("%s%c%c",txbuf,{1'b0,data[31:25]},{1'b0,data[24:18]});
					PC <= MAR + 4;
				end
			end
			else begin
				txbuf <= $sformatf("%s%c",txbuf,{1'b0,data[31:25]});
				PC <= MAR + 4;
			end
		end
		else begin
			PC <= MAR + 4;
		end
	end
	read_string_mem: begin
		if(data[31:25] != 0) begin
			if(data[24:18] != 0) begin
				if(data[17:11] != 0) begin
					if(data[10:4] != 0)
						txbuf <= $sformatf("%s%c%c%c%c",txbuf,{1'b0,data[31:25]},{1'b0,data[24:18]},{1'b0,data[17:11]},{1'b0,data[10:4]});	
					else
						txbuf <= $sformatf("%s%c%c%c",txbuf,{1'b0,data[31:25]},{1'b0,data[24:18]},{1'b0,data[17:11]});
				end
				else begin
					txbuf <= $sformatf("%s%c%c",txbuf,{1'b0,data[31:25]},{1'b0,data[24:18]});
				end
			end
			else begin
				txbuf <= $sformatf("%s%c",txbuf,{1'b0,data[31:25]});
			end
		end
	end
	read_int: begin
		txbuf <= $sformatf("%s%0d",txbuf,data);
		PC <= PC + 8;
	end
	read_float: begin
		txbuf <= $sformatf("%s%0f",txbuf,data);
		PC <= PC + 8;
	end
	empty_cycle,trap: PC <= PC;
	default: invalidop_data;
endcase
end

//Controller
//Sets next state and flags
always @(posedge clk) begin
	case(state)
	trap: begin
		disable_mem;
		nextstate <= trap;
	end
	request_instruction: begin
		read_mem;
		nextstate <= read_instruction;
	end
	read_instruction: nextstate <= exec_instruction;
	exec_instruction: begin
		case(IR.bits[31:29])
		3'b011: begin //other instructions
			case(IR.literal.opcode)
			LD: begin
				read_mem;
				nextstate <= handle_ld;
			end
			ST: begin
				write_mem;
				nextstate <= empty_cycle;
			end
			DISP: begin
				case(IR.literal.Rc)
					5'd1,5'd2: begin
						disable_mem;
						nextstate <= empty_cycle;
					end
					5'd3: begin
						read_mem;
						nextstate <= read_string_mem;
					end
					default: invalidop_control;
				endcase
			end
			JMP: begin
				disable_mem;
				nextstate <= handle_jmp;
			end
			BEQ: begin
				disable_mem;
				nextstate <= handle_beq;
			end
			BNE: begin
				disable_mem;
				nextstate <= handle_bne;
			end
			DISPC: begin
				case(IR.str.datatype)
				2'd1: begin //print int
					read_mem;
					nextstate <= read_int;
				end
				2'd2: begin //print float
					read_mem;
					nextstate <= read_float;
				end
				2'd3: begin
					if(IR.str.charA != 0) begin
						if(IR.str.charB != 0 && IR.str.charC != 0) begin
							read_mem;
							nextstate <= read_next_str;
						end
						else begin
							read_mem;
							nextstate <= empty_cycle;
						end
					end
					else begin
						disable_mem;
						nextstate <= trap;
					end
				end
				default: begin
					disable_mem;
					nextstate <= trap;
				end
				endcase
			end
			LDR: begin
				read_mem;
				nextstate <= handle_ld;
			end
			default: invalidop_control;
			endcase
		end
		3'b100,3'b101,3'b110,3'b111: begin
			disable_mem;
			nextstate <= handle_alu;
		end
		3'b000: begin
			case(IR.literal.opcode)
			EXIT: nextstate <= trap;
			NOOP: nextstate <= empty_cycle;
			default: invalidop_control;
			endcase
			disable_mem;
		end
		default: invalidop_control;
		endcase
	end
	read_next_str: begin
		read_mem;
		nextstate <= read_string;
	end
	read_next_str_mem: begin
		read_mem;
		nextstate <= read_string_mem;
	end
	handle_bne,handle_beq,handle_jmp,handle_ld,read_int,read_float: nextstate <= request_instruction;
	read_string: nextstate <= (data[31:25] != 0 && data[24:18] != 0 && data[17:11] != 0 && data[10:4] != 0) ? read_next_str : request_instruction;
	read_string_mem: nextstate <= (data[31:25] != 0 && data[24:18] != 0 && data[17:11] != 0 && data[10:4] != 0) ? read_next_str_mem : request_instruction;
	handle_alu,empty_cycle: begin
		disable_mem;
		nextstate <= request_instruction;
	end
	default: invalidop_control;
	endcase
end

endmodule
