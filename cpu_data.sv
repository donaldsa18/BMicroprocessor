/*
*
* B-Processor
*
* Authors: Anthony Donaldson, Matthew Erhardt
*
*/
`timescale 1ns / 1ns

module cpu_data(tx,clk,reset);

import InstructionStruct::*;

//Can print characters using this output
output [6:0] tx;
reg [6:0] tx;

//Serial output buffer
string txbuf = "";
string txbufnxt = "";

reg tx_status;
reg tx_first;

//External clock and active high reset
input clk,reset;

//registers
reg signed [DWIDTH-1:0] R [NUM_REGS-1:0];
reg signed [DWIDTH-1:0] Rnxt;

//data bus to memory controller
tri signed [DWIDTH-1:0] data;

//memory address register
reg [CPUAWIDTH-1:0] MAR;
reg [CPUAWIDTH-1:0] MARnxt;

//memory data register
reg [DWIDTH-1:0] MDR;
reg [DWIDTH-1:0] MDRnxt;

//instruction register
instruction_t IR;
instruction_t IRnxt;

//control signals for memory controller
//reg rw,valid;
//program counter
reg [CPUAWIDTH-1:0] PC;
reg [CPUAWIDTH-1:0] PCnxt;

//ALU registers
reg [DWIDTH-1:0] ARa,ARb;
reg [DWIDTH-1:0] ARanxt,ARbnxt;
wire [DWIDTH-1:0] ARc;

//for loops
integer i;

//Flags for controller
reg RaZero;
reg [3:0] charsZero;

//Flags from controller
wire [2:0] MARop;
wire IRop;
wire MDRop;
wire [2:0] PCop;
wire [3:0] TXBUFop;
wire [1:0] RCop;
wire ARAop;
wire [1:0] ARBop;
wire rdEnnxt;
wire wrEnnxt;
reg rdEn;
reg wrEn;

reg clk_del;

//Submodules - memory controller has a memory module
//ALU has registers for Ra&Rb input and wire Rc for ouput
//MemControl mc(data,MAR,clk,reset,rw,valid);
ram mod(data,MAR[AWIDTH+1:2],rdEn,wrEn,reset,clk);
alu math(ARc,ARa,ARb,IR.bits[DWIDTH-1:DWIDTH-6]);
cpu_controller control(MARop,IRop,MDRop,PCop,TXBUFop,RCop,ARAop,ARBop,rdEnnxt,wrEnnxt,IR.bits,RaZero,charsZero,clk,reset);

task reset_cpu;
	MAR = 0;
	MDR = 0;
	PC = 0;
	ARa = 0;
	ARb = 0;
	IR = 0;
	MARnxt = 0;
	MDRnxt = 0;
	PCnxt = 0;
	ARanxt = 0;
	ARbnxt = 0;
	IRnxt = 0;
	tx = 0;
	tx_status = 1;
	tx_first = 0;
	for(i = 0; i < NUM_REGS; i++)
		R[i] = 0;
endtask

assign data = (wrEn == 1'b1 && rdEn == 1'b0) ? MDR : {DWIDTH{1'bz}};

initial
	reset_cpu;

always @(clk)
	clk_del <= #1 clk;
	
//Print each character in the buffer one by one until it is empty
//Follows UART protocol
always @(negedge clk) begin
	if(txbuf.len() > 0) begin
		//Start each message with a 0
		if(tx_status) begin
			tx = 0;
			tx_status = 0;
			tx_first = 1;
		end
		else begin
			tx = txbuf[0];
			txbuf = txbuf.substr(1,txbuf.len()-1);
		end
	end
	//End each message with all 1's
	else begin
		tx = 7'b1111111;
		tx_status = 1;
	end
end

always @(posedge reset) reset_cpu;

//Flags for control path
assign RaZero = (R[IR.regular.Ra] === 0);
assign charsZero = {(data[31:25] !== 0),(data[24:18] !== 0),(data[17:11] !== 0),(data[10:4] !== 0)};

always @(posedge clk_del) begin
	#1 rdEn = rdEnnxt;
end

always @(posedge clk_del) begin
	#1 wrEn = wrEnnxt;
end


//Data path
//Sets registers based flags
//always @(MARop,IRop,MDRop,PCop,TXBUFop,RCop,ARAop,ARBop) begin
always @(posedge clk_del) begin
	case(MARop)
		mar_noop: MARnxt = MAR;
		mar_pc: MARnxt = PC;
		mar_pc_incr: MARnxt = PC + 4;
		mar_ra: MARnxt = R[IR.literal.Ra] + IR.literal.lit;
		mar_jmp: MARnxt = PC + 4 + (4*IR.literal.lit);
		mar_incr: MARnxt = MAR + 4;
		//default: txbuf <= $sformatf("%sInvalid MARop\n",txbuf);
	endcase
	MAR = MARnxt;
end

always @(posedge clk_del) begin
	case(IRop)
		ir_noop: IRnxt = IR;
		ir_data: IRnxt = data;
		//default: txbuf <= $sformatf("%sInvalid IRop\n",txbuf);
	endcase
	IR = IRnxt;
end
	
always @(posedge clk_del) begin
	case(MDRop)
		mdr_noop: MDRnxt = MDR;
		mdr_rc: MDRnxt = R[IR.literal.Rc];
		//default: txbuf <= $sformatf("%sInvalid MDRop\n",txbuf);
	endcase
	MDR = MDRnxt;
end

always @(posedge clk_del) begin
	case(PCop)
		pc_noop: PCnxt = PC;
		pc_incr: PCnxt = PC + 4;
		pc_jmp: PCnxt = PC + 4 + (4*IR.literal.lit);
		pc_ra: PCnxt = R[IR.literal.Ra];
		pc_mar: PCnxt = MAR + 4;
		pc_incr2: PCnxt = PC + 8;
		//default: txbuf <= $sformatf("%sInvalid PCop\n",txbuf);
	endcase
	PC = PCnxt;
end

always @(posedge clk_del) begin
	case(TXBUFop)
		txbuf_noop: txbufnxt = txbuf;
		txbuf_data_1: txbufnxt = $sformatf("%s%c",txbuf,{1'b0,data[31:25]});
		txbuf_data_2: txbufnxt = $sformatf("%s%c%c",txbuf,{1'b0,data[31:25]},{1'b0,data[24:18]});
		txbuf_data_3: txbufnxt = $sformatf("%s%c%c%c",txbuf,{1'b0,data[31:25]},{1'b0,data[24:18]},{1'b0,data[17:11]});
		txbuf_data_4: txbufnxt = $sformatf("%s%c%c%c%c",txbuf,{1'b0,data[31:25]},{1'b0,data[24:18]},{1'b0,data[17:11]},{1'b0,data[10:4]});
		txbuf_chars_1: txbufnxt = $sformatf("%s%c",txbuf,IR.str.charA);
		txbuf_chars_2: txbufnxt = $sformatf("%s%c%c",txbuf,IR.str.charA,IR.str.charB);
		txbuf_chars_3: txbufnxt = $sformatf("%s%c%c%c",txbuf,IR.str.charA,IR.str.charB,IR.str.charC);
		txbuf_err: txbufnxt = $sformatf("%sInvalid instruction opcode=%h PC=%d\n",txbuf,IR.regular.opcode,PC);
		txbuf_int: txbufnxt = $sformatf("%s%0d",txbuf,data);
		txbuf_float: txbufnxt = $sformatf("%s%0f",txbuf,data);
		txbuf_int_ra: txbufnxt = $sformatf("%s%0d",txbuf,R[IR.literal.Ra]);
		txbuf_float_ra: txbufnxt = $sformatf("%s%0f",txbuf,R[IR.literal.Ra]);
		//default: txbuf <= $sformatf("%sInvalid TXBUFop\n",txbuf);
	endcase
	txbuf = txbufnxt;
end

always @(posedge clk_del) begin
	case(RCop)
		rc_noop: Rnxt = R[IR.literal.Rc];
		rc_pc_incr: Rnxt = PC + 4;
		rc_data: Rnxt = data;
		rc_arc: Rnxt = (IR.regular.Rc != 5'd31) ? ARc : 0;
		//default: txbuf <= $sformatf("%sInvalid RCop\n",txbuf);
	endcase
	R[IR.literal.Rc] = Rnxt;
end

always @(posedge clk_del) begin
	case(ARAop)
		ara_noop: ARanxt = ARa;
		ara_ra: ARanxt = R[IR.regular.Ra];
		//default: txbuf <= $sformatf("%sInvalid ARAop\n",txbuf);
	endcase
	ARa = ARanxt;
end

always @(posedge clk_del) begin
	case(ARBop)
		arb_noop: ARbnxt = ARb;
		arb_rb: ARbnxt = R[IR.regular.Rb];
		arb_lit: ARbnxt = {{8{IR.literal.lit[15]}},IR.literal.lit };
	endcase
	ARb = ARbnxt;
end

endmodule
