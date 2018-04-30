/*
*
* RAM Module Testbench
*
* Authors: Anthony Donaldson, Matthew Erhardt
*
*/
module ram_tb;
import InstructionStruct::*;
tri [DWIDTH-1:0] data;
reg [DWIDTH-1:0] datareg;
reg rdEn,wrEn,reset,clk;
reg [AWIDTH-1:0] addr;
ram r0(data,addr,rdEn,wrEn,reset,clk);

initial begin
	clk = 1;
	forever
		#5 clk = ~clk;
end

assign data = (wrEn) ? datareg : {DWIDTH{1'bz}};

initial begin
	rdEn = 0;
	wrEn = 0;
	reset = 1;
	addr = 0;
	#2 reset = 0;
	#5 rdEn = 1;
	#10 addr = 1;
	#10 addr = 2;
	#10 rdEn = 0;
		wrEn = 1;
		datareg = $random;
		addr = 0;
	#10 datareg = $random;
		addr = 1;
	#10 datareg = $random;
		addr = 2;
	#10 wrEn = 0;
		rdEn = 1;
		addr = 0;
	#10 addr = 1;
	#10 addr = 2;
	#10 $stop;
	
end

endmodule
