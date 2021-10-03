`define		1000_Hz_Period	30'b000000000000000110000110101000	//	25 10^3

/****************************************/
/***    Improved_Toggle_Pushbutton    ***/
/****************************************/
module Improved_Toggle_Pushbutton(	clk_ms,
																		pressed,
																		state);
/*
	This module is just a wrapper for the Monostable_Multivibrator module
	with the constant set such that the delay is just 100ms = 0.1s
*/
input clk_ms;
input pressed;

output state;

wire w_clock_1000Hz;
wire w_toggle;

Module_FrequencyDivider		clock_1000_Hz_generator	(	.clk_in(clk_ms), .period(`1000_Hz_Period),
																										.clk_out(w_clock_1000Hz));


Monostable_Multivibrator module_MM(	.clk_ms(clk_ms), .clk_sl(w_clock_1000Hz),
																		.pressed(pressed), .ticks(8'b00001010), // 100 ms relaxation time
																		.out(w_toggle));

Module_Toggle_FlipFlop	flip_flop_T(	.clk_ms(clk_ms), .clk_sl(w_toggle),
																			.state(state));



endmodule

/****************************************/
/*** Module_Monostable_Multivibrator  ***/
/****************************************/
/*
A Monostable Multivibrator
	https://en.wikipedia.org/wiki/Monostable_multivibrator
is a circuit that, once activated, refuses to recive new
inputs until a predefined delay has passed.
*/
module	Monostable_Multivibrator(	clk_ms, // master clock
																	clk_sl,
																	pressed,
																	ticks,

																	out);

input		clk_ms; // Master clock used to sync
input 	clk_sl; // Slower clock
input 	pressed; // Is the button pressed?
input [7:0]		ticks; // Once enabled, disable input for n ticks of clk_sl

output		out;

reg 	out;
reg		state; // Does the Monostable_Multivibrator accepts inputs?
wire 	time_up; // Timer is over
reg 	reset; // Reset the timer

/*
NDR: The code could be optimized by exploiting the relations between the
			various registers, e.g.:
				- reset <--> ~state (Will keep resetting the counter when not active)
				- out <--> ~state (If the MM does not accepts inputs it is high)

			These optimization will not be implemented for clarity.
*/


Module_SynchroCounter_8_bit_SR	sync_counter_8_bit(	.qzt_clk(clk_ms), .clk_in(clk_sl), .reset(reset),
																										.set(0), .presetValue(0), .limit(ticks),
																										//.out(),
																										.carry(time_up) );


always @(posedge clk_ms) begin

	if(pressed & state) begin
		// If the button is pressed and the Monostable_Multivibrator
		// is active (=accepts inputs) set the output to high for the
		// specified time
		out <= 1;
		state <= 0;

		// reset the counter
		reset <= 1;
	end else if(~state) begin
		// If the MM is not active wait for the time to be over
		reset <= 0;
		if(time_up) begin
			state <= 1;
			out <= 0;
		end
	end

end

endmodule



/*******************************/
/*** Module_Toggle_FlipFlop  ***/
/*******************************/
module	Module_Toggle_FlipFlop	(	clk_ms, // master clock
																	clk_sl,

																	state);

input		clk_ms; // Master clock used to sync
input 	clk_sl; // Slower clock

output		state;

reg		state;
reg		clk_sl_old; // Check if the slower clock has changed state

always @(posedge clk_ms) begin
	if( !clk_sl_old & clk_sl ) begin
		state <= ~state;
	end

	clk_sl_old <= clk_sl;
end

endmodule
