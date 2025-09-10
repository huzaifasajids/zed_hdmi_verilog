module clock_divider#(
    parameter DIVIDEBY = 2
)(
    input i_clk,
    input i_rst,
    output o_clk
);
    
reg [$clog2(DIVIDEBY):0] count = 0;
reg clk_out;

always@(posedge i_clk)
begin
	if (i_rst)
	begin
		clk_out <= 0;
		count <= 0;
	end
	else
	begin
		if (count == DIVIDEBY-1)
			count <= 0;
		else
			count <= count + 1;
		clk_out <= (count < DIVIDEBY/2) ? 1'b1 : 1'b0;
	end
end

assign o_clk = clk_out;

endmodule
