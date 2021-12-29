/*
 This module implements a simple counter up to 2^8-1 (255)
 The counter is increased at each rise of clk_in
*/
module	Module_Counter_8_bit(input clk_in, input	[7:0] limit,
														 output	reg [7:0] out, output reg carry);

always @(posedge clk_in) begin
	if (out >= (limit - 8'b00000001)) begin
		out = 0;
		carry = 1;
	end else if (out == 0) begin
		out = 1;
		carry = 0;
	end else
		out = out + 1;
end

endmodule
