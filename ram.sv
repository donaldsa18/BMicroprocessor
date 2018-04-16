`include "params.svh"

module ram(data,addr,rdEn,wrEn,clk)

inout [DWIDTH-1:0] data;
input [AWIDTH-1:0] addr;
input rdEn,wrEn,clk;

tri [DWIDTH-1:0] data;

reg [DWIDTH-1:0] mem [MEMDEPTH-1:0];
assign data = (rdEn) ? mem[addr] : {DWIDTH{1'bz}};

integer i;
initial begin
	/*for(i = 0; i < MEMDEPTH; i++)
		mem[i] = 0;*/
	$readmemb("program.bin", data);
end

always @(posedge clk) begin
	if(wrEn && !rdEn)
		mem[addr] <= data;
end

endmodule