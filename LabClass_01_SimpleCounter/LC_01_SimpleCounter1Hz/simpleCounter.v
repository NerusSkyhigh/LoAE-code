`define		defaultPeriod	30'b000001011111010111100001000000	//	25 10^6


module simpleCounter	(	CLK_50M,

				LED);

input		CLK_50M;

output	[7:0]	LED;


wire		w_clock_1_Hz;


Module_FrequencyDivider		clock_1_Hz_generator	(	.clk_in(CLK_50M),
								.period(`defaultPeriod),

								.clk_out(w_clock_1_Hz));

Module_Counter_8_bit		counter			(	.clk_in(w_clock_1_Hz),
								.limit(8'b00000000),

								.out(LED));

endmodule
