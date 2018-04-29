
`timescale 1ns / 1ns

module cpu_tb;

reg clk, reset;
wire [6:0] tx;
reg startTx;
string txbuf = "";
cpu c(tx,clk,reset);

initial begin
	clk = 1'b0;
	forever #5 clk = !clk;
end

initial begin
	startTx = 0;
	reset = 0;
	#1 reset = 1;
	#1 reset = 0;
	#10000 $stop;
end
	
always @(posedge clk) begin
	if(startTx && tx != 7'b1111111 && tx != 0) begin
		$write("%c", tx);
		txbuf <= $sformatf("%s%c",txbuf,tx);
	end
	if(tx == 0)
		startTx = 1;
	else if(tx == 7'b1111111)
		startTx = 0;
end
endmodule
