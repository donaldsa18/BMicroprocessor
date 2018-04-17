module cpu_tb;

reg clk, reset;
wire [6:0] tx;

cpu(tx,clk,reset);

initial begin
	clk = 1'b1;
	forever #5 clk = !clk;
end

initial begin
	reset = 1'b1;
	#12 reset = 1'b0;
	#200 $stop;
end
	
initial begin
	if(tx != 0)
		$write("%c", tx);
end
endmodule