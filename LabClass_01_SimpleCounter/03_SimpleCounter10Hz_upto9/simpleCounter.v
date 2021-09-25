/*
ASSIGNMENT:
	Development of an 8–bit, 10 Hz counter with an 8–LED array display,
	working from 0 to 9.

NOTE:
	It's as simple as changing defaultPeriod (remember that it needs 30 digits)
*/

`define		defaultPeriod	30'b000000000000111101000010010000  //  25 10^5


module simpleCounter	(	CLK_50M, LED);

input		CLK_50M;

output	[7:0]	LED;

wire		w_clock_10_Hz;


Module_FrequencyDivider		clock_10_Hz_generator	(	.clk_in(CLK_50M),
																									.period(`defaultPeriod),

																									.clk_out(w_clock_10_Hz));

Module_Counter_8_bit		counter			(	.clk_in(w_clock_10_Hz),
																			.limit(8'b00001010),

																			.out(LED));

endmodule
