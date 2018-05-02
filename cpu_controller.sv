
module cpu_controller(MARop,IRop,MDRop,PCop,TXBUFop,RCop,ARAop,ARBop,rdEn,wrEn,IR,RaZero,charsZero,clk,reset);
import InstructionStruct::*;

output MARop;
MAR_OP_t MARop;

output IRop;
IR_OP_t IRop;

output MDRop;
MDR_OP_t MDRop;

output PCop;
PC_OP_t PCop;

output TXBUFop;
TXBUF_OP_t TXBUFop;

output RCop;
RC_OP_t RCop;

output ARAop;
ARA_OP_t ARAop;

output ARBop;
ARB_OP_t ARBop;

output rdEn;
read_t rdEn;

output wrEn;
write_t wrEn;

input instruction_t IR;
input RaZero;
input [3:0] charsZero;
input clk,reset;

cpu_state_t state;
cpu_state_t nextstate;

task reset_cpu;
	state <= request_instruction;
	nextstate <= request_instruction;
	{MARop,IRop,MDRop,PCop,TXBUFop,RCop,ARAop,ARBop,rdEn,wrEn} = {mar_noop,ir_noop,mdr_noop,pc_noop,txbuf_noop,rc_noop,ara_noop,arb_noop,read_off,write_off};
endtask

always @(posedge reset) reset_cpu;

initial reset_cpu;

always @(negedge clk) state <= nextstate;
//Controller
//Sets next state and flags
always @(posedge clk) begin
	case(state)
	trap: begin
		{MARop,IRop,MDRop,PCop,TXBUFop,RCop,ARAop,ARBop,rdEn,wrEn} = {mar_noop,ir_noop,mdr_noop,pc_noop,txbuf_noop,rc_noop,ara_noop,arb_noop,read_off,write_off};
		nextstate <= trap;
	end
	request_instruction: begin
		nextstate <= read_instruction;
		{MARop,IRop,MDRop,PCop,TXBUFop,RCop,ARAop,ARBop,rdEn,wrEn} = {mar_pc,ir_noop,mdr_noop,pc_noop,txbuf_noop,rc_noop,ara_noop,arb_noop,read_on,write_off};
	end
	read_instruction: begin
		{MARop,IRop,MDRop,PCop,TXBUFop,RCop,ARAop,ARBop,rdEn,wrEn} = {mar_noop,ir_data,mdr_noop,pc_noop,txbuf_noop,rc_noop,ara_noop,arb_noop,read_on,write_off};
		nextstate <= exec_instruction;
	end
	exec_instruction: begin
		case(IR.bits[31:29])
		3'b011: begin //other instructions
			case(IR.literal.opcode)
			LD: begin
				{MARop,IRop,MDRop,PCop,TXBUFop,RCop,ARAop,ARBop,rdEn,wrEn} = {mar_ra,ir_noop,mdr_noop,pc_noop,txbuf_noop,rc_noop,ara_noop,arb_noop,read_on,write_off};
				nextstate <= handle_ld;
			end
			ST: begin
				{MARop,IRop,MDRop,PCop,TXBUFop,RCop,ARAop,ARBop,rdEn,wrEn} = {mar_ra,ir_noop,mdr_rc,pc_incr,txbuf_noop,rc_noop,ara_noop,arb_noop,read_off,write_on};
				nextstate <= empty_cycle;
			end
			DISP: begin
				case(IR.literal.Rc)
					5'd1: begin
						{MARop,IRop,MDRop,PCop,TXBUFop,RCop,ARAop,ARBop,rdEn,wrEn} = {mar_noop,ir_noop,mdr_noop,pc_incr,txbuf_int_ra,rc_noop,ara_noop,arb_noop,read_off,write_off};
						nextstate <= empty_cycle;
					end
					5'd2: begin
						{MARop,IRop,MDRop,PCop,TXBUFop,RCop,ARAop,ARBop,rdEn,wrEn} = {mar_noop,ir_noop,mdr_noop,pc_incr,txbuf_float_ra,rc_noop,ara_noop,arb_noop,read_off,write_off};
						nextstate <= empty_cycle;
					end
					5'd3: begin
						{MARop,IRop,MDRop,PCop,TXBUFop,RCop,ARAop,ARBop,rdEn,wrEn} = {mar_jmp,ir_noop,mdr_noop,pc_incr,txbuf_noop,rc_noop,ara_noop,arb_noop,read_on,write_off};
						nextstate <= read_string_mem;
					end
					default: begin
						{MARop,IRop,MDRop,PCop,TXBUFop,RCop,ARAop,ARBop,rdEn,wrEn} = {mar_noop,ir_noop,mdr_noop,pc_noop,txbuf_noop,rc_noop,ara_noop,arb_noop,read_off,write_off};
						nextstate <= trap;
					end
				endcase
			end
			JMP: begin
				{MARop,IRop,MDRop,PCop,TXBUFop,RCop,ARAop,ARBop,rdEn,wrEn} = {mar_noop,ir_noop,mdr_noop,pc_jmp,txbuf_noop,rc_pc_incr,ara_noop,arb_noop,read_off,write_off};
				nextstate <= handle_jmp;
			end
			BEQ: begin
				{MARop,IRop,MDRop,PCop,TXBUFop,RCop,ARAop,ARBop,rdEn,wrEn} = {mar_noop,ir_noop,mdr_noop,pc_noop,txbuf_noop,rc_pc_incr,ara_noop,arb_noop,read_off,write_off};
				nextstate <= handle_beq;
			end
			BNE: begin
				{MARop,IRop,MDRop,PCop,TXBUFop,RCop,ARAop,ARBop,rdEn,wrEn} = {mar_noop,ir_noop,mdr_noop,pc_noop,txbuf_noop,rc_pc_incr,ara_noop,arb_noop,read_off,write_off};
				nextstate <= handle_bne;
			end
			DISPC: begin
				case(IR.str.datatype)
				2'd1: begin //print int
					{MARop,IRop,MDRop,PCop,TXBUFop,RCop,ARAop,ARBop,rdEn,wrEn} = {mar_pc_incr,ir_noop,mdr_noop,pc_noop,txbuf_noop,rc_noop,ara_noop,arb_noop,read_on,write_off};
					nextstate <= read_int;
				end
				2'd2: begin //print float
					{MARop,IRop,MDRop,PCop,TXBUFop,RCop,ARAop,ARBop,rdEn,wrEn} = {mar_pc_incr,ir_noop,mdr_noop,pc_noop,txbuf_noop,rc_noop,ara_noop,arb_noop,read_on,write_off};
					nextstate <= read_float;
				end
				2'd3: begin
					if(IR.str.charA != 0) begin
						if(IR.str.charB != 0) begin
							if(IR.str.charC != 0) begin
								{MARop,IRop,MDRop,PCop,TXBUFop,RCop,ARAop,ARBop,rdEn,wrEn} = {mar_noop,ir_noop,mdr_noop,pc_noop,txbuf_chars_3,rc_noop,ara_noop,arb_noop,read_off,write_off};
								nextstate <= read_next_str;
							end
							else begin
								{MARop,IRop,MDRop,PCop,TXBUFop,RCop,ARAop,ARBop,rdEn,wrEn} = {mar_noop,ir_noop,mdr_noop,pc_incr,txbuf_chars_2,rc_noop,ara_noop,arb_noop,read_off,write_off};
								nextstate <= empty_cycle;
							end
						end
						else begin
							{MARop,IRop,MDRop,PCop,TXBUFop,RCop,ARAop,ARBop,rdEn,wrEn} = {mar_noop,ir_noop,mdr_noop,pc_incr,txbuf_chars_1,rc_noop,ara_noop,arb_noop,read_off,write_off};
							nextstate <= empty_cycle;
						end
					end
					else begin
						{MARop,IRop,MDRop,PCop,TXBUFop,RCop,ARAop,ARBop,rdEn,wrEn} = {mar_noop,ir_noop,mdr_noop,pc_noop,txbuf_err,rc_noop,ara_noop,arb_noop,read_off,write_off};
						nextstate <= trap;
					end
				end
				default: begin
					{MARop,IRop,MDRop,PCop,TXBUFop,RCop,ARAop,ARBop,rdEn,wrEn} = {mar_noop,ir_noop,mdr_noop,pc_noop,txbuf_noop,rc_noop,ara_noop,arb_noop,read_off,write_off};
					nextstate <= trap;
				end
				endcase
			end
			LDR: begin
				{MARop,IRop,MDRop,PCop,TXBUFop,RCop,ARAop,ARBop,rdEn,wrEn} = {mar_jmp,ir_noop,mdr_noop,pc_noop,txbuf_noop,rc_noop,ara_noop,arb_noop,read_on,write_off};
				nextstate <= handle_ld;
			end
			default: begin
				{MARop,IRop,MDRop,PCop,TXBUFop,RCop,ARAop,ARBop,rdEn,wrEn} = {mar_noop,ir_noop,mdr_noop,pc_noop,txbuf_noop,rc_noop,ara_noop,arb_noop,read_off,write_off};
				nextstate <= trap;
			end
			endcase
		end
		3'b100,3'b101: begin
			{MARop,IRop,MDRop,PCop,TXBUFop,RCop,ARAop,ARBop,rdEn,wrEn} = {mar_noop,ir_noop,mdr_noop,pc_incr,txbuf_noop,rc_arc,ara_ra,arb_rb,read_off,write_off};
			nextstate <= handle_alu;
		end
		3'b110,3'b111: begin
			{MARop,IRop,MDRop,PCop,TXBUFop,RCop,ARAop,ARBop,rdEn,wrEn} = {mar_noop,ir_noop,mdr_noop,pc_incr,txbuf_noop,rc_arc,ara_ra,arb_lit,read_off,write_off};
			nextstate <= handle_alu;
		end
		3'b000: begin
			case(IR.literal.opcode)
			EXIT: begin
				nextstate <= trap;
				{MARop,IRop,MDRop,PCop,TXBUFop,RCop,ARAop,ARBop,rdEn,wrEn} = {mar_noop,ir_noop,mdr_noop,pc_noop,txbuf_noop,rc_noop,ara_noop,arb_noop,read_off,write_off};
			end
			NOOP: begin
				nextstate <= empty_cycle;
				{MARop,IRop,MDRop,PCop,TXBUFop,RCop,ARAop,ARBop,rdEn,wrEn} = {mar_noop,ir_noop,mdr_noop,pc_incr,txbuf_noop,rc_noop,ara_noop,arb_noop,read_off,write_off};
			end
			default: begin
				{MARop,IRop,MDRop,PCop,TXBUFop,RCop,ARAop,ARBop,rdEn,wrEn} = {mar_noop,ir_noop,mdr_noop,pc_noop,txbuf_noop,rc_noop,ara_noop,arb_noop,read_off,write_off};
				nextstate <= trap;
			end
			endcase
		end
		default: begin
			{MARop,IRop,MDRop,PCop,TXBUFop,RCop,ARAop,ARBop,rdEn,wrEn} = {mar_noop,ir_noop,mdr_noop,pc_noop,txbuf_noop,rc_noop,ara_noop,arb_noop,read_off,write_off};
			nextstate <= trap;
		end
		endcase
	end
	read_next_str: begin
		{MARop,IRop,MDRop,PCop,TXBUFop,RCop,ARAop,ARBop,rdEn,wrEn} = {mar_incr,ir_noop,mdr_noop,pc_noop,txbuf_noop,rc_noop,ara_noop,arb_noop,read_on,write_off};
		nextstate <= read_string;
	end
	read_next_str_mem: begin
		{MARop,IRop,MDRop,PCop,TXBUFop,RCop,ARAop,ARBop,rdEn,wrEn} = {mar_incr,ir_noop,mdr_noop,pc_noop,txbuf_noop,rc_noop,ara_noop,arb_noop,read_on,write_off};
		nextstate <= read_string_mem;
	end
	handle_bne: begin
		nextstate <= request_instruction;
		{MARop,IRop,MDRop,PCop,TXBUFop,RCop,ARAop,ARBop,rdEn,wrEn} = {mar_noop,ir_noop,mdr_noop,(RaZero) ? pc_incr : pc_jmp,txbuf_noop,rc_noop,ara_noop,arb_noop,read_off,write_off};
	end
	handle_beq: begin
		nextstate <= request_instruction;
		{MARop,IRop,MDRop,PCop,TXBUFop,RCop,ARAop,ARBop,rdEn,wrEn} = {mar_noop,ir_noop,mdr_noop,(RaZero) ? pc_jmp : pc_incr,txbuf_noop,rc_noop,ara_noop,arb_noop,read_off,write_off};
	end
	handle_jmp: begin
		nextstate <= request_instruction;
		{MARop,IRop,MDRop,PCop,TXBUFop,RCop,ARAop,ARBop,rdEn,wrEn} = {mar_noop,ir_noop,mdr_noop,pc_ra,txbuf_noop,rc_noop,ara_noop,arb_noop,read_off,write_off};
	end
	handle_ld: begin
		nextstate <= request_instruction;
		{MARop,IRop,MDRop,PCop,TXBUFop,RCop,ARAop,ARBop,rdEn,wrEn} = {mar_noop,ir_noop,mdr_noop,pc_incr,txbuf_noop,rc_data,ara_noop,arb_noop,read_off,write_off};
	end
	read_int: begin
		nextstate <= request_instruction;
		{MARop,IRop,MDRop,PCop,TXBUFop,RCop,ARAop,ARBop,rdEn,wrEn} = {mar_noop,ir_noop,mdr_noop,pc_incr2,txbuf_int,rc_noop,ara_noop,arb_noop,read_on,write_off};
	end
	read_float: begin
		nextstate <= request_instruction;
		{MARop,IRop,MDRop,PCop,TXBUFop,RCop,ARAop,ARBop,rdEn,wrEn} = {mar_noop,ir_noop,mdr_noop,pc_incr2,txbuf_float,rc_noop,ara_noop,arb_noop,read_on,write_off};
	end
	read_string: begin
		nextstate <= (&charsZero) ? read_next_str : request_instruction;
		if(charsZero[3]) begin
			if(charsZero[2]) begin
				if(charsZero[1]) begin
					if(charsZero[0]) begin
						{MARop,IRop,MDRop,PCop,TXBUFop,RCop,ARAop,ARBop,rdEn,wrEn} = {mar_noop,ir_noop,mdr_noop,pc_noop,txbuf_data_4,rc_noop,ara_noop,arb_noop,read_on,write_off};
					end
					else begin
						{MARop,IRop,MDRop,PCop,TXBUFop,RCop,ARAop,ARBop,rdEn,wrEn} = {mar_noop,ir_noop,mdr_noop,pc_mar,txbuf_data_3,rc_noop,ara_noop,arb_noop,read_on,write_off};
					end
				end
				else begin
					{MARop,IRop,MDRop,PCop,TXBUFop,RCop,ARAop,ARBop,rdEn,wrEn} = {mar_noop,ir_noop,mdr_noop,pc_mar,txbuf_data_2,rc_noop,ara_noop,arb_noop,read_on,write_off};
				end
			end
			else begin
				{MARop,IRop,MDRop,PCop,TXBUFop,RCop,ARAop,ARBop,rdEn,wrEn} = {mar_noop,ir_noop,mdr_noop,pc_mar,txbuf_data_1,rc_noop,ara_noop,arb_noop,read_on,write_off};
			end
		end
		else begin
			{MARop,IRop,MDRop,PCop,TXBUFop,RCop,ARAop,ARBop,rdEn,wrEn} = {mar_noop,ir_noop,mdr_noop,pc_mar,txbuf_noop,rc_noop,ara_noop,arb_noop,read_on,write_off};
		end
	end
	read_string_mem: begin
		nextstate <= (&charsZero) ? read_next_str_mem : request_instruction;
		if(charsZero[3]) begin
			if(charsZero[2]) begin
				if(charsZero[1]) begin
					if(charsZero[0]) begin
						{MARop,IRop,MDRop,PCop,TXBUFop,RCop,ARAop,ARBop,rdEn,wrEn} = {mar_noop,ir_noop,mdr_noop,pc_noop,txbuf_data_4,rc_noop,ara_noop,arb_noop,read_on,write_off};
					end
					else begin
						{MARop,IRop,MDRop,PCop,TXBUFop,RCop,ARAop,ARBop,rdEn,wrEn} = {mar_noop,ir_noop,mdr_noop,pc_noop,txbuf_data_3,rc_noop,ara_noop,arb_noop,read_on,write_off};
					end
				end
				else begin
					{MARop,IRop,MDRop,PCop,TXBUFop,RCop,ARAop,ARBop,rdEn,wrEn} = {mar_noop,ir_noop,mdr_noop,pc_noop,txbuf_data_2,rc_noop,ara_noop,arb_noop,read_on,write_off};
				end
			end
			else begin
				{MARop,IRop,MDRop,PCop,TXBUFop,RCop,ARAop,ARBop,rdEn,wrEn} = {mar_noop,ir_noop,mdr_noop,pc_noop,txbuf_data_1,rc_noop,ara_noop,arb_noop,read_on,write_off};
			end
		end
		else begin
			{MARop,IRop,MDRop,PCop,TXBUFop,RCop,ARAop,ARBop,rdEn,wrEn} = {mar_noop,ir_noop,mdr_noop,pc_noop,txbuf_noop,rc_noop,ara_noop,arb_noop,read_on,write_off};
		end
	end
	handle_alu: begin
		{MARop,IRop,MDRop,PCop,TXBUFop,RCop,ARAop,ARBop,rdEn,wrEn} = {mar_noop,ir_noop,mdr_noop,pc_noop,txbuf_noop,rc_arc,ara_noop,arb_noop,read_off,write_off};
		nextstate <= request_instruction;
	end
	empty_cycle: begin
		{MARop,IRop,MDRop,PCop,TXBUFop,RCop,ARAop,ARBop,rdEn,wrEn} = {mar_noop,ir_noop,mdr_noop,pc_noop,txbuf_noop,rc_noop,ara_noop,arb_noop,read_off,write_off};
		nextstate <= request_instruction;
	end
	default: begin
		{MARop,IRop,MDRop,PCop,TXBUFop,RCop,ARAop,ARBop,rdEn,wrEn} = {mar_noop,ir_noop,mdr_noop,pc_noop,txbuf_err,rc_noop,ara_noop,arb_noop,read_off,write_off};
		nextstate <= trap;
	end
	endcase
end

endmodule