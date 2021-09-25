module	Module_Multiplexer_2_input_8_bit_sync	(	clk_in,
							address,
							input_0,
							input_1,

							mux_output);

input		clk_in;
input		address;
input	[7:0]	input_0;
input	[7:0]	input_1;

output	[7:0]	mux_output;

reg	[7:0]	mux_output;

always @(posedge clk_in) begin
	mux_output = (address)? input_1 : input_0;
end

endmodule
