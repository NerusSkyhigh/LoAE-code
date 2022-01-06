module	Module_Multiplexer_2_input_8_bit_comb(input address,
																							input [7:0] input_0, input [7:0] input_1,

																							output [7:0] mux_output);

// Using the ternary operator
//assign	mux_output = (address)? input_1 : input_0;

// Using logic gates. I think this is actual underlying implementation
// of the ternary operator
assign mux_output = ((!address) & input_0) | (address & input_1);

endmodule
