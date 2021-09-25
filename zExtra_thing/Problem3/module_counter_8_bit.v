module	Module_Counter_8_bit	(	clk_in,
					limit,
					active,

					out,
					carry);

input		clk_in;
input	[7:0]	limit;
input 		active;

output	[7:0]	out;
output		carry;

reg	[7:0]	out;


always @(posedge clk_in) begin
	if(active) begin
		active = 0;
		if (out >= (limit - 8'b00000001)) begin
			out = 0;
			carry = 1;
		end else if (out == 0) begin
			out = 1;
			carry = 0;
		end else
			out = out + 1;
	end

end

endmodule
