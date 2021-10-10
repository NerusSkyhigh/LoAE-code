`define		50_Hz_Period	30'b000000000011110100001001000000	//	10^6, 50Hz, 20 ms

/****************************************/
/***    Improved_Toggle_Pushbutton    ***/
/****************************************/
module Improved_Toggle_Pushbutton(	clk_ms, pressed,
																		state);
	/*
		This module is just a wrapper for the Monostable_Multivibrator module
		with the constant set such that the delay is just 100ms = 0.1s
	*/
	input clk_ms;
	input pressed;

	output state;


	wire w_clock_50Hz;

	Module_FrequencyDivider		clock_50_Hz_generator(	.clk_in(clk_ms), .period(`50_Hz_Period),
																										.clk_out(w_clock_50Hz));


	Monostable_Multivibrator module_MM(	.clk_ms(clk_ms), .clk_sl(w_clock_50Hz),
																			.pressed(pressed), .ticks(8'b00001010), // 200 ms=0.2 s relaxation time
																			.longpulse(0),
																			.out(state));

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
module	Monostable_Multivibrator(	clk_ms, clk_sl,
																	pressed,
																	ticks, longpulse,

																	out);

	input		clk_ms; // Master clock used to sync
	input 	clk_sl; // Slower clock
	input 	pressed; // Is the button pressed?
	input [7:0]		ticks; // Once enabled, disable input for n ticks of clk_sl
	input 	longpulse; // Should the pulse last for the whole time or only for a cycle?

	output		out;

	wire 	w_time_up; // Timer is over

	reg 	out = 0;
	reg		active = 1; // Does the Monostable_Multivibrator accepts inputs?
	reg 	reset = 1; // Reset the timer

	/*
	NDR: The code could be optimized by exploiting the relations between the
				various registers, e.g.:
					- reset <--> ~active (Will keep resetting the counter when not active)
					- out <--> ~state (If the MM does not accepts inputs it is high)

				These optimization will not be implemented for clarity.
	*/
	Module_SynchroCounter_8_bit_SR	sync_counter_8_bit(	.qzt_clk(clk_ms), .clk_in(clk_sl),
																											.reset(reset), .set(0), .presetValue(0),
																											.limit(ticks),
																											//.out(),
																											.carry(w_time_up) );

	always @(posedge clk_ms) begin
		if(active) begin
			if(pressed) begin
				// Start the count down from the next clk_ms tick
				out <= 1;
				active <= 0;
				reset <= 0;
			end
		end else begin
			reset <= 0;

			// and if the longpulse is not required disable the output
			if(~longpulse) begin	out <= 0;	end

			if(w_time_up) begin
				out <= 0; //If time is over disable output anyway
				active <= 1;
				reset <= 1;
			end
		end

	end

endmodule



/*******************************/
/*** Module_Toggle_FlipFlop  ***/
/*******************************/
module	Module_Toggle_FlipFlop	(	clk_ms, // master clock
																	input_tff,

																	state);

	input		clk_ms; // Master clock used to sync
	input 	input_tff; // Slower clock

	output		state;

	reg		state;
	reg		input_tff_old; // Check if the slower clock has changed state

	always @(posedge clk_ms) begin
		if( !input_tff_old & input_tff ) begin
			state <= ~state;
		end

		input_tff_old <= input_tff;
	end

endmodule
