/*
*
* Memory Controller Testbench
*
* Authors: Anthony Donaldson, Matthew Erhardt
*
*/
module MemControl_tb;

import InstructionStruct::*;

tri [DWIDTH-1:0] data;
reg [DWIDTH-1:0] datareg;

reg clk,reset,rw,valid;
reg [CPUAWIDTH-1:0] addr;

MemControl mc(data,addr,clk,reset,rw,valid);

initial begin
	clk = 1;
	forever
		#5 clk = ~clk;
end

assign data = (!rw && valid) ? datareg : {DWIDTH{1'bz}};

initial begin
	rw = 1;
	valid = 0;
	addr = 0;
	datareg = 0;
	reset = 1;
	#2 reset = 0;
	#5 valid = 1;
	#20 addr = 4;
	#20 addr = 8;
	#20 rw = 0;
		addr = 0;
		datareg = $random;
	#20 addr = 4;
		datareg = $random;
	#20 addr = 8;
		datareg = $random;
	#20 rw = 1;
		addr = 0;
	#20 rw = 1;
		addr = 4;
	#20 rw = 1;
		addr = 8;
	#20 $stop;
end

endmodule
