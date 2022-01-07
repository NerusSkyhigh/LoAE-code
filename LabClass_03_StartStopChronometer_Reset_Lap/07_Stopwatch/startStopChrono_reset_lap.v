`define		100_Hz_Period	30'b000000000000111101000010010000	//	25 10^4

/****************************************/
/***            STOPWATCH             ***/
/****************************************/
module startStopChrono_reset_lap(input CLK_50M. input SW,
																 input BTN_SOUTH, // Start-stop
																 input BTN_EAST,	// lap
																 input BTN_NORTH, // reset

																 output [7:0] LED);

	wire [7:0] outputSW_RT, outputSW_LAP;
	wire [7:0] w_centi, w_deci, w_unit, w_deca;

	wire w_carry_c_t_d, w_carry_d_t_u, w_carry_u_t_d;
	wire w_BTN_SOUTH, w_BTN_EAST;
	wire w_clock_100Hz;


	reg OLD_BTN_SOUTH, OLD_BTN_EAST;
	reg reset = 0;
	reg pause = 1;
	reg lap = 0;

	reg[7:0] saved_c, saved_u;
	reg[3:0] saved_d, saved_deca;




	Module_FrequencyDivider		clock_100_Hz_generator	(	.clk_in(CLK_50M),
																											.period(`100_Hz_Period),

																											.clk_out(w_clock_100Hz));


	/*
		 					COUNTERS
		 I exploit the fact that the counter is increated AFTER checking for the set
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





	Improved_Toggle_Pushbutton	improved_BTN_S(	.clk_ms(CLK_50M), .pressed(BTN_SOUTH),
																					.state(w_BTN_SOUTH));

	Improved_Toggle_Pushbutton	improved_BTN_E(	.clk_ms(CLK_50M), .pressed(BTN_EAST),
																					.state(w_BTN_EAST));


	//Module_Monostable	improved_BTN_S(	.clk_in(CLK_50M), .monostable_input(BTN_SOUTH), .N(25000000), //0.2 sec
	//																	.monostable_output(w_BTN_SOUTH));

	//Module_Monostable	improved_BTN_E(	.clk_in(CLK_50M), .monostable_input(BTN_EAST), .N(25000000), //0.2 sec
	//																	.monostable_output(w_BTN_EAST));



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




	/*
		 					MULTIPLEXING FOR OUTPUT
	*/

	// Real time output
	Module_Multiplexer_2_input_8_bit_sync	module_outputSW_RT	( .clk_in(CLK_50M), .address(SW),
																															.input_0(w_deci<<4 | w_centi), .input_1(w_deca<<4 | w_unit),
																															.mux_output(outputSW_RT));


	// Lap time output
	Module_Multiplexer_2_input_8_bit_sync	module_outputSW_LAP	( .clk_in(CLK_50M), .address(SW),
																														.input_0(saved_d<<4 | saved_c), .input_1(saved_deca<<4 | saved_u),
																														.mux_output(outputSW_LAP));

	// Stopwatch output
	Module_Multiplexer_2_input_8_bit_sync	module_outputSW	( .clk_in(CLK_50M), .address(lap),
																														.input_0(outputSW_RT), .input_1(outputSW_LAP),
																														.mux_output(LED[7:0]));


endmodule
