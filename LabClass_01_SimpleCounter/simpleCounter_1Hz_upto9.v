/*
ASSIGNMENT:
	Development of an 8–bit, 11 Hz counter with an 8–LED array display,
	working from 0 to 255.

NOTE:
	It's as simple as changing the limit
*/

`define		defaultPeriod	30'b000001011111010111100001000000	//	25 10^6


module simpleCounter_1Hz_upto9(input	CLK_50M,

															output [7:0] LED);

wire		w_clock_10_Hz;


Module_FrequencyDivider		clock_10_Hz_generator	(	.clk_in(CLK_50M),
																									.period(`defaultPeriod),

																									.clk_out(w_clock_10_Hz));

// b00001010 = 10. Remember that 0, 1, ..., 8, 9 --> mod 10
Module_Counter_8_bit		counter			(	.clk_in(w_clock_10_Hz),
																			.limit(8'b00001010),

																			.out(LED));

endmodule
