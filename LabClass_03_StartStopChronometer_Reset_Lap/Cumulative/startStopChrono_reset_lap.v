`define		100_Hz_Period	30'b000000000000111101000010010000	//	25 10^4

/**
 * As during the last lecture I was busy with the lab technician I wasn't able
 * to show my results for points 1 to 6. To compensate for that both all the
 * requests are provided in this file. It is possible to switch to the Toggle
 * Pushbutton assignment via the SW[1]. The BTN_WEST button acts as a toggle
 * button to showcase assignments 1 to 6. The rightmost led (LED[0]) shows
 * assignment 1-3. The second led from the right (LED[1]) shows assignments 4-5
 * while the third let (LED[2]) assignment 6. The stopwatch will continue to
 * work in background while in this mode.
 * NOTE: BTN_WEST, being in an awkward position was less used and therefore is
 * 		less prone to bouncing. I needed a few tries to see the effects on LED[0]
 */

module startStopChrono_reset_lap	(	CLK_50M,
						SW,
						BTN_WEST,
						BTN_SOUTH,
						BTN_EAST,
						BTN_NORTH,

						LED);

input		CLK_50M;
input	[1:0]	SW;
input   BTN_WEST;
input		BTN_SOUTH;	// stop
input		BTN_EAST;	// lap
input		BTN_NORTH;	// reset

output	[7:0]	LED;


wire		w_clock_100Hz;

wire [7:0] outputTB;
wire [7:0] outputSW;
wire [7:0] outputSW_RT;
wire [7:0] outputSW_LAP;

wire w_carry_c_t_d, w_carry_d_t_u, w_carry_u_t_d;
wire [7:0] w_centi, w_deci, w_unit, w_deca;

wire w_BTN_SOUTH, w_BTN_EAST;

reg OLD_BTN_SOUTH, OLD_BTN_EAST;

reg reset = 0;
reg pause = 1;
reg lap = 0;

reg[7:0] saved_c, saved_u;
reg[3:0] saved_d, saved_deca;

buf(outputTB[7:3], 0);


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
																						.input_tff(BTN_WEST),

																						.state(outputTB[0]) );

/*
ASSIGNMENTs:
	4) Implementation of a synchronous module monostable multivibrator.
	5) Implementation, by means of a monostable multivibrator and an improved
			toggle pushbutton, of a timer to switch on an LED for a given time
			(equal to 1 s, or programmable through the switches).
*/
Monostable_Multivibrator module_Monostable_Multivibrator(	.clk_ms(CLK_50M),
																													.clk_sl(w_clock_100Hz),
																													.pressed(BTN_WEST),
																													.ticks(8'b11001000), // Two seconds delay for easy testing
																													.longpulse(1),

																													.out(outputTB[1]));

/*
ASSIGNMENT 6:
	Implementation (by means of a toggle flip-flop) of an improved toggle
	pushbutton to switch on/off an LED, without bouncing effect.
*/
Improved_Toggle_Pushbutton debounced_toggle_pushbutton(	.clk_ms(CLK_50M),
																												.pressed(BTN_WEST),
																												.state(outputTB[2]));



/****************************************/
/***            STOPWATCH             ***/
/****************************************/
/* I exploit the fact that the counter is increated AFTER checking for the set
	 flag. If that wasn't possible I'd have to link CLK_50 with counter_cs.qzt_clk
	 via a wire/register that I can arbitrarly disconnect.
*/
Module_SynchroCounter_8_bit_SR	counter_cs(	.qzt_clk(CLK_50M), .clk_in(w_clock_100Hz),
																						.reset(reset), .set(pause), .presetValue(w_centi), .limit(8'b00001010),
																						.out(w_centi), .carry(w_carry_c_t_d));

Module_SynchroCounter_8_bit_SR	counter_ds(	.qzt_clk(CLK_50M), .clk_in(w_carry_c_t_d),
																						.reset(reset), .set(pause), .presetValue(w_deci), .limit(8'b00001010),
																						.out(w_deci), .carry(w_carry_d_t_u));

Module_SynchroCounter_8_bit_SR	counter_us(	.qzt_clk(CLK_50M), .clk_in(w_carry_d_t_u),
																						.reset(reset), .set(pause), .presetValue(w_unit), .limit(8'b00001010),
																						.out(w_unit), .carry(w_carry_u_t_d));

Module_SynchroCounter_8_bit_SR	counter_decas(	.qzt_clk(CLK_50M), .clk_in(w_carry_u_t_d),
																								.reset(reset), .set(pause), .presetValue(w_deca), .limit(8'b00001010),
																								.out(w_deca));


// Real time output
Module_Multiplexer_2_input_8_bit_sync	module_outputSW_RT	( .clk_in(CLK_50M), .address(SW[0]),
																														.input_0(w_deci<<4 | w_centi), .input_1(w_deca<<4 | w_unit),
																														.mux_output(outputSW_RT));



/****************************************/
/***     MULTIPLEXING FOR OUTPUT      ***/
/****************************************/

// Lap time output
Module_Multiplexer_2_input_8_bit_sync	module_outputSW_LAP	( .clk_in(CLK_50M), .address(SW[0]),
																													.input_0(saved_d<<4 | saved_c), .input_1(saved_deca<<4 | saved_u),
																													.mux_output(outputSW_LAP));

// Stopwatch output
Module_Multiplexer_2_input_8_bit_sync	module_outputSW	( .clk_in(CLK_50M), .address(lap),
																													.input_0(outputSW_RT), .input_1(outputSW_LAP),
																													.mux_output(outputSW));


Module_Multiplexer_2_input_8_bit_sync	output_driver(	.clk_in(CLK_50M), .address(SW[1]),
																											.input_0(outputSW), .input_1(outputTB),
																											.mux_output(LED[7:0]));



Improved_Toggle_Pushbutton	improved_BTN_S(	.clk_ms(CLK_50M), .pressed(BTN_SOUTH),
																				.state(w_BTN_SOUTH));

//Module_Monostable	improved_BTN_S(	.clk_in(CLK_50M), .monostable_input(BTN_SOUTH), .N(25000000), //0.2 sec
//																	.monostable_output(w_BTN_SOUTH));


Module_Monostable	improved_BTN_E(	.clk_in(CLK_50M), .monostable_input(BTN_EAST), .N(25000000), //0.2 sec
																	.monostable_output(w_BTN_EAST));

// ADD DEBOUNCING!!!
always @(posedge CLK_50M) begin

	if (w_BTN_SOUTH & ~OLD_BTN_SOUTH) begin // Start / Stop
		pause <= ~pause;

	end else if (w_BTN_EAST & ~OLD_BTN_EAST) begin // Lap
		// Save output value in a variable and display that value
		lap <= ~ lap;
    saved_c <= w_centi;
		saved_d <= w_deci;
		saved_u <= w_unit;
		saved_deca <= w_deca;

	end else if (BTN_NORTH) begin // reset
		// Here debouncing is not really needed.
		// There is no problem if I reset the counter twice
		reset <= 1;

	end else begin
		reset <= 0;
	end

	OLD_BTN_SOUTH <= w_BTN_SOUTH;
	OLD_BTN_EAST  <= w_BTN_EAST;
end


endmodule
