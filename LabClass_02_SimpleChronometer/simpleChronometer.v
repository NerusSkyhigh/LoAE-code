`define		defaultPeriod	30'b000001011111010111100001000000	//	25 10^6
`define		100_Hz_Period	30'd250000 // 25 10^4


module simpleChronometer	(	CLK_50M,
					SW,

					LED);

input		CLK_50M;
input		SW;

output	[7:0]	LED;

/****************************************/
/*** ... and hereafter what's left... ***/
/****************************************/
wire		w_clock_100_Hz,
		w_carry_c_t_d, // carry centi seconds to deciseconds
		w_carry_d_t_u, // carry deci seconds to unit seconds
		w_carry_u_t_d; // carry unit seconds to Deca seconds
		
// Wires for multiplexing
wire[7:0]	w_centi,
		w_deci,
		w_unit,
		w_deca;
		


// Clock 
Module_FrequencyDivider		clock_100_Hz_generator	(	.clk_in(CLK_50M),
								.period(`100_Hz_Period),

								.clk_out(w_clock_100_Hz));



// Let's have 4 counters, one for each digit. they are linked via carries like yesterday

// centi-Seconds = 1s/100
Module_Counter_8_bit		counter_cs		(	.clk_in(w_clock_100_Hz),
								.limit(8'b00001010),
								
								.carry(w_carry_c_t_d),
								.out(w_centi));

// deci-Seconds = 1s/10
Module_Counter_8_bit		counter_ds		(	.clk_in(w_carry_c_t_d),
								.limit(8'b00001010),
								
								.carry(w_carry_d_t_u),
								.out(w_deci));
								
// Unit-Seconds = 1s
Module_Counter_8_bit		counter_us		(	.clk_in(w_carry_d_t_u),
								.limit(8'b00001010),
								
								.carry(w_carry_u_t_d),
								.out(w_unit));

// Deca-Seconds = 1s
Module_Counter_8_bit		counter_decas		(	.clk_in(w_carry_u_t_d),
								.limit(8'b00001010),

								.out(w_deca));
								


// METHOD 1: Bit shift to add numbers
/*
Module_Multiplexer_2_input_8_bit_comb	outputLED	 (	.address(SW),
								.input_0(w_deci<<4 | w_centi),
								.input_1(w_deca<<4 | w_unit),

								.mux_output(LED));
*/

/*
Module_Multiplexer_2_input_8_bit_sync	outputLED	(	.clk_in(w_clock_100_Hz),
								.address(SW),
								.input_0(w_deci<<4 | w_centi),
								.input_1(w_deca<<4 | w_unit),
	
								.mux_output(LED));
*/


// METHOD 2: concatenate numbers with {}
Module_Multiplexer_2_input_8_bit_sync	outputLED	(	.clk_in(w_clock_100_Hz),
								.address(SW),
								.input_0({w_deci[3:0], w_centi[3:0]}),
								.input_1({w_deca[3:0], w_unit[3:0]}),
	
								.mux_output(LED));





endmodule
