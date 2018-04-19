

module MemControl(data,addr,clk,reset,rw,valid);
import InstructionStruct::*;
inout [DWIDTH-1:0] data;
input clk,reset,rw,valid;
input [CPUAWIDTH-1:0] addr;

reg [AWIDTH-1:0] ramAddr;

//localparam N = 2^(CPUAWIDTH-AWIDTH);
reg rdEn, wrEn;
//Could add 15 more ram modules with for loop
ram mod(data,ramAddr,rdEn,wrEn,reset,clk);
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

always @(negedge clk) begin
	if(valid) begin
		if(rw) begin //read operation
			ramAddr = addr[AWIDTH+2:2];
			rdEn = 1'b1;
			wait(~clk);
			wait(clk);
			rdEn = 1'b0;
		end
		else begin //write operation
			//Not using first 2 bits because only address 32 bits
			ramAddr = addr[AWIDTH+2:2];
			wrEn = 1'b1;
			wait(~clk);
			wait(clk);
			wrEn = 1'b0;
		end
	end
end

endmodule
