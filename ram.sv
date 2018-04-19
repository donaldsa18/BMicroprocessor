
module ram(data,addr,rdEn,wrEn,reset,clk);
import InstructionStruct::*;
inout [DWIDTH-1:0] data;
input [AWIDTH-1:0] addr;
input rdEn,wrEn,reset,clk;

tri [DWIDTH-1:0] data;

reg [DWIDTH-1:0] mem [MEMDEPTH-1:0];
assign data = (rdEn) ? mem[addr] : {DWIDTH{1'bz}};

integer i;

task reset_mem;
	for(i = 0; i < MEMDEPTH; i++)
		mem[i] = i;
	$readmemb("program.bin", mem);//, 0, MEMDEPTH-1);
endtask

initial
	reset_mem;

always @(negedge reset)
	reset_mem;

always @(posedge clk) begin
	if(wrEn && !rdEn)
		mem[addr] <= data;
end

endmodule
