/*
ASSIGNMENT:
	Development of a 10 Hz counter, working from 0 to 99, with a 2–digits BCD coding
	and a 2 x 4–LED array display.
*/
`define		defaultPeriod4	30'b000000000000111101000010010000	//	25 10^4
`define		defaultPeriod5	30'b000000000000111101000010010000  //  25 10^5

module simpleCounter_10Hz_upto99_BCDcoding(input	CLK_50M,

																					output [7:0] LED);


wire		w_clock_10_Hz;


Module_FrequencyDivider		clock_10_Hz_generator	(	.clk_in(CLK_50M),
																									.period(`defaultPeriod5),

																									.clk_out(w_clock_10_Hz));



Module_Counter_8_bit		counterDX		(	.clk_in(w_clock_10_Hz),
																			.limit(8'b00001010),

																			.out(LED[3:0]),
																			.carry(carry));



Module_Counter_8_bit		counterSX		(	.clk_in(carry),
																			.limit(8'b00001010),

																			.out(LED[7:4]));


endmodule
