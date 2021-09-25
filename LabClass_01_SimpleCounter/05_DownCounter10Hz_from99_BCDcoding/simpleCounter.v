/*
ASSIGNMENT:
	Development of a 10 Hz down counter
*/
`define		defaultPeriod5	30'b0000000001001100010010110100000	//	25 10^5

module simpleCounter	(	CLK_50M, LED);

input		CLK_50M;

output	[7:0]	LED;


wire		w_clock_10_Hz;
wire		carry;

Module_FrequencyDivider		clock_10_Hz_generator	(	.clk_in(CLK_50M),
																									.period(`defaultPeriod5),

																									.clk_out(w_clock_10_Hz));



Module_DownCounter_8_bit		counterDX		(	.clk_in(w_clock_10_Hz),
																				.limit(8'b00001010),

																				.out(LED[3:0]),
																				.carry(carry));



Module_DownCounter_8_bit		counterSX		(	.clk_in(carry),
																				.limit(8'b00001010),

																				.out(LED[7:4]));


endmodule
