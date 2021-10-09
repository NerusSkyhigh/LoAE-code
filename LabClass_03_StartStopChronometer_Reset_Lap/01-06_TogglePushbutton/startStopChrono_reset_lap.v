`define		100_Hz_Period	30'b000000000000111101000010010000	//	25 10^4

/**
 * The BTN_SOUTH button acts as a toggle button to showcase assignments 1 to 6.
 * 	The rightmost led (LED[0]) shows assignment 1-3.
 * 	The second led from the right (LED[1]) shows assignments 4-5.
 * 	The third led (LED[2]) shows assignment 6.
 */

module startStopChrono_reset_lap	(	CLK_50M,
						BTN_SOUTH,

						LED);

input		CLK_50M;
input		BTN_SOUTH;
output	[2:0]	LED;


wire		w_clock_100Hz;


/****************************************/
/***        ASSIGNMENT 1 to 6         ***/
/****************************************/
Module_FrequencyDivider		clock_100_Hz_generator	(	.clk_in(CLK_50M),
																										.period(`100_Hz_Period),

																										.clk_out(w_clock_100Hz));

/*
ASSIGNMENTs:
	1) Implementation of a synchronous module toggle flip-flop
	2) Implementation (by means of a toggle flip-flop) of a toggle pushbutton
			to switch on/off an LED.
	3) Observation of the bouncing effect in a pushbutton
*/
Module_Toggle_FlipFlop module_flip_flop		(	.clk_ms(CLK_50M), // master clock
																						.input_tff(BTN_SOUTH),

																						.state(LED[0]) );

/*
ASSIGNMENTs:
	4) Implementation of a synchronous module monostable multivibrator.
	5) Implementation, by means of a monostable multivibrator and an improved
			toggle pushbutton, of a timer to switch on an LED for a given time
			(equal to 1 s, or programmable through the switches).
*/
Monostable_Multivibrator module_Monostable_Multivibrator(	.clk_ms(CLK_50M),
																													.clk_sl(w_clock_100Hz),
																													.pressed(BTN_SOUTH),
																													.ticks(8'b11001000), // Two seconds delay for easy testing
																													.longpulse(1),

																													.out(LED[1]));

/*
ASSIGNMENT 6:
	Implementation (by means of a toggle flip-flop) of an improved toggle
	pushbutton to switch on/off an LED, without bouncing effect.
*/
Improved_Toggle_Pushbutton debounced_toggle_pushbutton(	.clk_ms(CLK_50M),
																												.pressed(BTN_SOUTH),
																												.state(LED[2]));



endmodule
