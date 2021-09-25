`define		defaultPeriod6	30'b0000000010011000100101101000000	//	25 10^6
`define		defaultPeriod5	30'b0000000001001100010010110100000	//	25 10^5

module simpleCounter	(	CLK_50M,

				LED);

input		CLK_50M;

output	[7:0]	LED;


wire		w_clock_10_Hz;
wire		carry;
wire		active;

Module_FrequencyDivider		clock_10_Hz_generator	(	.clk_in(CLK_50M),
								.period(`defaultPeriod6),

								.clk_out(w_clock_10_Hz));


Module_Slower_Clock		slow_clock		(	.clk_in(clock_10_Hz_generator),
								.active(active));

Module_Counter_8_bit		counterDX		(	.clk_ms(CLK_50M),
								.limit(8'b00001010),
								.active(active),
								
								.out(LED[3:0]),
								.carry(carry));

endmodule
