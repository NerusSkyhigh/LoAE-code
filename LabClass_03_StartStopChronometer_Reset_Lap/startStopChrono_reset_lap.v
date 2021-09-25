`define		100_Hz_Period	30'b000000000000111101000010010000	//	25 10^4

module startStopChrono_reset_lap	(	CLK_50M,
						SW,
						BTN_SOUTH,
						BTN_EAST,
						BTN_NORTH,

						LED);

input		CLK_50M;
input	[1:0]	SW;
input		BTN_SOUTH;	// stop
input		BTN_EAST;	// lap
input		BTN_NORTH;	// reset

output	[7:0]	LED;

/****************************************/
/*** ... and hereafter what's left... ***/
/****************************************/

wire		w_clock_100Hz;


buf(LED[7:1], 0);

Module_FrequencyDivider		clock_100_Hz_generator	(	.clk_in(CLK_50M),
								.period(`100_Hz_Period),

								.clk_out(w_clock_100_Hz));



Module_Toggle_FlipFlop		flip_flop		(	.clk_ms(CLK_50M), // master clock
								.clk_sl(BTN_SOUTH),

								.state(LED[0]) );
								


endmodule
