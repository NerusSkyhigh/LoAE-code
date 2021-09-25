module	Module_Counter_8_bit	(	clk_in,
					limit,

					out,
					carry);

input		clk_in;
input	[7:0]	limit;

output	[7:0]	out;
output		carry;

reg	[7:0]	out;
reg		carry;

always @(posedge clk_in) begin
	if (out <= 0) begin
		out = limit-1;
		carry = 1;
	end else if (out == limit-1) begin
		out = limit - 2;
		carry = 0;
	end else
		out = out - 1;
end

endmodule
