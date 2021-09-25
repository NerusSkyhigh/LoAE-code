`define		defaultPeriod4	30'b0000000000000111101000010010000	//	25 10^4
`define		defaultPeriod5	30'b000000001001100010010110100000	//	25 10^5

module simpleCounter	(	CLK_50M,

				LED);

input		CLK_50M;

output	[7:0]	LED;


wire		w_clock_1_Hz;


Module_FrequencyDivider		clock_10_Hz_generator	(	.clk_in(CLK_50M),
								.period(`defaultPeriod5),

								.clk_out(w_clock_1_Hz));


Module_FrequencyDivider		clock_100_Hz_generator	(	.clk_in(CLK_50M),
								.period(`defaultPeriod4),

								.clk_out(w_clock_1_Hz));


Module_Counter_8_bit		counter			(	.clk_in(w_clock_1_Hz),
								.limit(8'b00000000),

								.out(LED));

endmodule
