/*
ASSIGNMENT:
	Development of an 8–bit, 1 Hz counter with an 8–LED array display,
	working from 0 to 255.
*/
`define		defaultPeriod	30'b000001011111010111100001000000	//	25 10^6


module simpleCounter	(	CLK_50M, LED);

input		CLK_50M;

output	[7:0]	LED;

wire		w_clock_1_Hz;

// 50M Hz base clock frequency is divided by 25M.
// Where does the factor 2 end?
Module_FrequencyDivider		clock_1_Hz_generator	(	.clk_in(CLK_50M),
																									.period(`defaultPeriod),

																									.clk_out(w_clock_1_Hz));

// Limit is to 0 because 0-1=255 (mod 256)
Module_Counter_8_bit		counter			(	.clk_in(w_clock_1_Hz),
																			.limit(8'b00000000),

																			.out(LED));

endmodule
