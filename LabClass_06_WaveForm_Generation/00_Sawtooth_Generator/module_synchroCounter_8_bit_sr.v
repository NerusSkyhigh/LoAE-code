module	Module_SynchroCounter_8_bit_SR	(	qzt_clk,
						clk_in,
						reset,
						set,
						presetValue,
						limit,

						out,
						carry);

input		qzt_clk;
input		clk_in;
input		set;
input		reset;
input	[7:0]	presetValue;
input	[7:0]	limit;

output	[7:0]	out;
output		carry;

reg	[7:0]	out;
reg		carry;

reg		clk_in_old;


always @(posedge qzt_clk) begin
	if (reset) begin
		out = 0;
		carry = 0;
	end else if (set) begin
		out = presetValue;
		carry = 0;
	end else if (!clk_in_old & clk_in) begin
		if (out >= (limit - 8'b00000001)) begin
			out = 0;
			carry = 1;
		end else if (out == 0) begin
			out = 1;
			carry = 0;
		end else
			out = out + 1;
	end

	clk_in_old = clk_in;
end

endmodule
