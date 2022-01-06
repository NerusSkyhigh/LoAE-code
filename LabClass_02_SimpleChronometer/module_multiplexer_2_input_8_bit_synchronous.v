module	Module_Multiplexer_2_input_8_bit_sync	(input clk_in, input address,
																							 input	[7:0] input_0, input	[7:0] input_1,

																							 output reg [7:0] mux_output);

always @(posedge clk_in) begin
	// A more complex multiplexer could be realized with
	// a series of if-else or with the switch construct.
	mux_output = (address)? input_1 : input_0;
end

endmodule
