
`include "params.svh"

module MemControl(data,addr,clk,reset,rw,valid)
inout [DWIDTH-1:0] data;
input clk,reset,rw,valid;
input [CPUAWIDTH-1:0] addr;

reg [CPUAWIDTH-1:0] ramAddr;

//localparam N = 2^(CPUAWIDTH-AWIDTH);
reg rdEn, wrEn;
//Could add 15 more ram modules with for loop
ram mod(data,ramAddr,rdEn,wrEn,clk);
/*
generate
	genvar i;
	for(i = 0; i < N; i++) begin: gen_ram
		ram mod(ramData,ramAddr,rdEn[i],wrEn[i],clk);
	end
endgenerate*/

initial begin
	rdEn = 1'b0;
	wrEn = 1'b0;
	ramAddr = 0;

end

always @(posedge clk, negedge reset) begin
	if(reset == 0) begin
		data = 0;
		wrEn = 1'b1;
		rdEn = 1'b0;
		for(ramAddr = 0; ramAddr < MEMDEPTH; ramAddr++) begin
			wait(clk);
			wait(~clk);
		end
		data = {DWIDTH{1'bz}};
	end
	else begin
		if(valid == 1'b1) begin
			if(rw == 1'b0) begin //write operation
				//Not using first 2 bits because only address 32 bits
				ramAddr = addr[AWIDTH+2:2];
				wrEn[CPUAWIDTH-1:AWIDTH+3] = 1'b1;
				wait(~clk);
				wait(clk);
				wait(~clk);
				wait(clk);
				wrEn[CPUAWIDTH-1:AWIDTH+3] = 1'b0;
			end
			else if(rw == 1'b1) begin //read operation
				ramAddr = addr[AWIDTH+2:2];
				rdEn[CPUAWIDTH-1:AWIDTH+3] = 1'b1;
				wait(~clk);
				wait(clk);
				wait(~clk);
				wait(clk);
				rdEn[CPUAWIDTH-1:AWIDTH+3] = 1'b0;
			end
		end
	end
end

endmodule
