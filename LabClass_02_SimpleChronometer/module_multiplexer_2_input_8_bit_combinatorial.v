module	Module_Multiplexer_2_input_8_bit_comb	(	address,
							input_0,
							input_1,

							mux_output);

input		address;
input	[7:0]	input_0;
input	[7:0]	input_1;

output	[7:0]	mux_output;

//assign	mux_output = (address)? input_1 : input_0;
assign		mux_output = ((!address) * input_0) | (address * input_1);

endmodule
