/*
 * PROBLEM 04: PSEUDORANDOM GENERATOR ON LEDs
 *	Implement a 31-bit pseudorandom number generator and display its function by
 ∗  	- Implementing a 31–bit shift register (SR),
 ∗ 		- Feeding–back the serial input (i.e. the 0th bit) with the XOR of the
 *			30th and the 27th bit,
 ∗ 		- Clocking the SR with a 1 or 2 Hz source and connecting eight randomly
 *			selected flip–flop outputs to the eight LEDs;
 */
module ShiftRegister	(input CLK_50M,
											 output reg[7:0] LED);

`define		defaultPeriod	30'b000001011111010111100001000000	//	25 10^6


wire w_clock_1_Hz;
Module_FrequencyDivider	clock_1_Hz_generator(.clk_in(CLK_50M),
																						.period(`defaultPeriod),

																						.clk_out(w_clock_1_Hz));

reg[31:0] register = 32'd1;
reg old_clock_1_Hz;

always @(posedge CLK_50M) begin

	if(~old_clock_1_Hz & w_clock_1_Hz) begin
		register[31:1] <= register[30:0];
		register[0] <= (register[30] ^ register[27]);
	end

	old_clock_1_Hz <= w_clock_1_Hz;
	// The leds chosen are not actually random, but this allows me to
	// test the output knowing the initial seed.
	LED <= register[7:0];
end



endmodule




/*************************************************/
/*** Module_FrequencyDivider from chipstore.v ***/
/************************************************/
module	Module_FrequencyDivider	(input clk_in, input[29:0] period,
																 output reg clk_out);

	reg	[29:0]	counter;

	always @(posedge clk_in) begin
		if (counter >= (period - 1)) begin
			counter <= 0;
			clk_out <= ~clk_out;
		end else
			counter <= counter + 1;
	end

endmodule
