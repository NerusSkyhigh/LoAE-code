module startStopLapReset_LCD	(	CLK_50M,
					//SW,
					PUSH_BTN_SS, PUSH_BTN_LR,

					LED,
					LCD_DB,
					LCD_E, LCD_RS, LCD_RW);

input		CLK_50M;
//input		SW;
input		PUSH_BTN_SS;
input		PUSH_BTN_LR;

output	[7:0]	LED;
output	[7:0]	LCD_DB;
output		LCD_E;
output		LCD_RS;
output		LCD_RW;


//wire	[15:0]	wb_counter;
wire	[15:0]	wb_counter_toShow;

wire		w_startStop;
wire		w_lapFlag;
wire		w_reset;

buf(LCD_RW, 0);
buf(LCD_DB[3:0], 4'b1111);

LCD_Driver_forChrono	lcd_driver	(	.qzt_clk(CLK_50M),
						.fourDigitInput(wb_counter_toShow),
						.lapFlag(w_lapFlag),

						.lcd_flags({LCD_RS, LCD_E}),
						.lcd_data(LCD_DB[7:4]));

/****************************************/
/*** ... and hereafter what's left... ***/
/****************************************/
buf(LED[6], 0);
buf(LED[3], 0);

// Wirest to connect monostable output
wire w_SS, w_LR;


Module_Monostable	module_monostable_SS(	.clk_in(CLK_50M), .monostable_input(PUSH_BTN_SS),
																				.N(50000000),
																				.monostable_output(w_SS));

Module_Monostable	module_monostable_LR(	.clk_in(CLK_50M), .monostable_input(PUSH_BTN_LR),
																				.N(50000000),
																				.monostable_output(w_LR));

// I want to keep showing the STATE via the LED so i use the LED as a buffer
// to perform operations
StateMachine module_state_machine(.clk_in(CLK_50M), .PULSE_A(w_SS), .PULSE_B(w_LR),
                    							.state(LED[2:0]), .reset_pulse(LED[7]));

assign w_reset = LED[7];
assign w_startStop = (LED[2:0] == 2) || (LED[2:0] == 3);
assign w_lapFlag = (LED[2:0] == 3) || (LED[2:0] == 4);

// Led 4 and 5 are used to show the state of w_startStop and w_lapFlag
assign LED[4] = w_startStop;
assign LED[5] = w_lapFlag;



/****************************************/
/***           STOPWATCH              ***/
/****************************************/
`define		100_Hz_Period	30'b000000000000111101000010010000	//	25 10^4
wire w_clock_100Hz;
Module_FrequencyDivider		clock_100_Hz_generator	(	.clk_in(CLK_50M), .period(`100_Hz_Period),
																										.clk_out(w_clock_100Hz));

wire [3:0] w_centi, w_deci, w_unit, w_deca;
wire w_carry_c_t_d, w_carry_d_t_u, w_carry_u_t_d;

reg[3:0] saved_c, saved_u, saved_d, saved_deca;
reg OLD_lapFlag;

Module_SynchroCounter_8_bit_SR	counter_100Hz(	.qzt_clk(CLK_50M), .clk_in(w_clock_100Hz),
																								.reset(w_reset), .set(~w_startStop), .presetValue(w_centi), .limit(8'b00001010),
																								.out(w_centi), .carry(w_carry_c_t_d));

Module_SynchroCounter_8_bit_SR	counter_10Hz(	.qzt_clk(CLK_50M), .clk_in(w_carry_c_t_d),
																							.reset(w_reset), .set(~w_startStop), .presetValue(w_deci), .limit(8'b00001010),
																							.out(w_deci), .carry(w_carry_d_t_u));

Module_SynchroCounter_8_bit_SR	counter_1Hz(	.qzt_clk(CLK_50M), .clk_in(w_carry_d_t_u),
																							.reset(w_reset), .set(~w_startStop), .presetValue(w_unit), .limit(8'b00001010),
																							.out(w_unit), .carry(w_carry_u_t_d));

Module_SynchroCounter_8_bit_SR	counter_01Hz(	.qzt_clk(CLK_50M), .clk_in(w_carry_u_t_d),
																							.reset(w_reset), .set(~w_startStop), .presetValue(w_deca), .limit(8'b00001010),
																							.out(w_deca), .carry());


// Stopwatch output
Module_Multiplexer_2_input_16_bit_sync	module_outputSW	( .clk_in(CLK_50M), .address(w_lapFlag),
																													.input_0({w_deca, w_unit, w_deci, w_centi}),
																													.input_1({saved_deca, saved_u, saved_d, saved_c}),
																													.mux_output(wb_counter_toShow));



always @(posedge CLK_50M) begin

	if (w_lapFlag & ~OLD_lapFlag) begin // Lap
		// Save output value in a variable and display that value
		saved_c <= w_centi;
		saved_d <= w_deci;
		saved_u <= w_unit;
		saved_deca <= w_deca;
	end

	OLD_lapFlag <= w_lapFlag;
end


endmodule




/****************************************/
/***  COPY AND ADAPT FROM CHIPSTORE   ***/
/****************************************/
module	Module_Multiplexer_2_input_16_bit_sync	(	clk_in,
							address,
							input_0,
							input_1,

							mux_output);

input		clk_in;
input		address;
input	[15:0]	input_0;
input	[15:0]	input_1;

output	[15:0]	mux_output;

reg	[15:0]	mux_output;

always @(posedge clk_in) begin
	mux_output <= (address)? input_1 : input_0;
end

endmodule
