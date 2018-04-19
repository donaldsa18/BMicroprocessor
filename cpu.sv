
module cpu(tx,clk,reset);

import InstructionStruct::*;

//Can print characters using this output
output [6:0] tx;
reg [6:0] tx;

//Serial output buffer
string txbuf = "";

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

reg isExecuting;//,hasNextInstruction;

//for loops
integer i;

//Submodules - memory controller has a memory module
//ALU has registers for Ra&Rb input and wire Rc for ouput
//MemControl mc(data,MAR,clk,reset,rw,valid);
ram mod(data,MAR,rdEn,wrEn,reset,clk);
alu math(ARc,ARa,ARb,IR.regular.opcode);

initial begin
	reset_cpu;
end

task reset_cpu;
	//rw = 0;
	//valid = 0;
	//hasNextInstruction = 0;
	rdEn = 0;
	wrEn = 0;
	MAR = 0;
	MDR = 0;
	PC = 0;
	ARa = 0;
	ARb = 0;
	IR = 0;
	tx = 0;
	isExecuting = 1'b0;
	for(i = 0; i < NUM_REGS; i++)
		R[i] = 0;
endtask

//Reads the memory location in MAR and writes to MDR
task readMem;
	//wrEn = 1'b0;
	rdEn = 1'b1;
	wait(~clk);
	//valid = 1'b1;
	//rw = 1'b1;
	
	wait(clk);
	MDR = data;
	wait(~clk);
	rdEn = 1'b0;
	//valid = 1'b0;
endtask

assign data = (wrEn == 1'b1 && rdEn == 1'b0) ? MDR : {DWIDTH{1'bz}};

//Writes data in MDR to main memory
task writeMem;
	wrEn = 1'b1;
	//rdEn = 1'b0;
	wait(~clk);
	//valid = 1'b1;
	//rw = 1'b0;
	wait(clk);
	wrEn = 1'b0;
	//valid = 1'b0;
endtask
	
//Reads the instruction in PC and writes to IR
task readInstruction;
	//isReadingInstruction = 1'b1;
	MAR = PC;
	//valid = 1'b1;
	//rw = 1'b1;
	rdEn = 1'b1;
	wait(~clk);
	wait(clk);
	IR = data;
	wait(~clk);
	rdEn = 1'b0;
	//isReadingInstruction = 1'b0;
	//hasNextInstruction = 1'b1;
	//valid = 1'b0;
	
endtask

//Does an ALU instruction
task regular_alu_instruction;
	ARa = R[IR.regular.Ra];
	ARb = R[IR.regular.Rb];
	wait(~clk);
	wait(clk);
	if(IR.literal.Rc != 5'd31)
		R[IR.regular.Rc] = ARc;
	PC = PC + 4;
endtask

//Does an ALU instruction with a constant in the instruction
task constant_alu_instruction;
	ARa = R[IR.literal.Ra];
	ARb = IR.literal.lit;
	wait(~clk);
	wait(clk);
	if(IR.literal.Rc != 5'd31)
		R[IR.literal.Rc] = ARc;
	PC = PC + 4;
endtask

task invalidop;
	R[30] = 1;
	txbuf = $sformatf("Invalid instruction opcode=%h PC=%d",IR.regular.opcode,PC);
endtask
always @(negedge reset)
	reset_cpu;

always @(posedge clk) begin
	//Check if in error state before executing
	if(R[30] == 0 && !isExecuting) begin
		isExecuting = 1'b1;
		//if(!isReadingInstruction && !hasNextInstruction)
		readInstruction;
		//if(hasNextInstruction) begin
		//	hasNextInstruction = 0;
			//Handle invalid opcodes the case statements can't detect
		if(IR.bits[28:26] == 3'b111 && IR.bits[31:29] != 3'b011)
			invalidop;
		else begin
			case(IR.bits[31:29])
			3'b011: begin //other instructions
				case(IR.literal.opcode)
				LD: begin
					MAR = R[IR.literal.Ra] + IR.literal.lit;
					readMem;
					R[IR.literal.Rc] = MDR;
					PC = PC + 4;
				end
				ST: begin
					MDR = R[IR.literal.Rc];
					MAR = R[IR.literal.Ra] + IR.literal.lit;
					writeMem;
					PC = PC + 4;
				end
				DISP: begin
					tx = R[IR.literal.Rc][6:0];
					PC = PC + 4;
				end
				JMP: begin
					R[IR.literal.Rc] = PC+4;
					PC = R[IR.literal.Ra];
				end
				BEQ: begin
					R[IR.literal.Rc] = PC+4;
					if(R[IR.literal.Ra] == 5'd0)
						PC = PC + (4*IR.literal.lit);
					else
						PC = PC + 4;
				end
				BNE: begin
					R[IR.literal.Rc] = PC+4;
					if(R[IR.literal.Ra] != 5'd0)
						PC = PC + 4 + (4*IR.literal.lit);
					else
						PC = PC + 4;
				end
				DISPC: begin
					tx = IR.literal.lit[6:0];
					PC = PC + 4;
				end
				LDR: begin
					MAR = PC + 4 + (4*IR.literal.lit);
					readMem;
					R[IR.literal.Rc] = MDR;
					PC = PC + 4;
				end
				default: invalidop;
				endcase
			end
			3'b100: regular_alu_instruction;
			3'b101: regular_alu_instruction;
			3'b110: constant_alu_instruction;
			3'b111: constant_alu_instruction;
			default: invalidop;
			endcase
		end
		//end
	end
	if(txbuf.len() != 0) begin
		tx = txbuf[0];
		txbuf = txbuf.substr(1,txbuf.len()-1);
	end
	else
		tx = 0;
	isExecuting = 1'b0;
	

end

endmodule
