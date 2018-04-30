/*
*
* Memory Controller
*
* Authors: Anthony Donaldson, Matthew Erhardt
*
*/

module MemControl(data,addr,clk,reset,rw,valid);
import InstructionStruct::*;
inout [DWIDTH-1:0] data;
input [CPUAWIDTH-1:0] addr;
input clk,reset,rw,valid;

localparam N = 2^(CPUAWIDTH-AWIDTH);

//Translate high 4 bits into enables for each module
reg [N-1:0] rdEn,wrEn;
assign rdEn = (valid && rw) ? (1 << addr[CPUAWIDTH-1:AWIDTH+3]) : 0;
assign wrEn = (valid && !rw) ? (1 << addr[CPUAWIDTH-1:AWIDTH+3]) : 0;

//Generate RAM modules
generate
	genvar i;
	for(i = 0; i < N; i++) begin: gen_ram
		ram mod(data,addr[AWIDTH+2:2],rdEn[i],wrEn[i],reset,clk);
	end
endgenerate

endmodule
