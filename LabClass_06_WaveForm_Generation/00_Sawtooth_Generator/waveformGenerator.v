/*
 * PROBLEM 0: SAWTOOTH WAVE GENERATOR
 * 	Implement a simple sawtooth waveform generator by connecting a counter to a
 *  DAC;
 *	by using the leftmost switch, implement the option that allows to change the
 *	sign of the waveform slope;
 *	by using the other switches, implement an option that allows to change the
 *	absolute value of the waveform slope, and thus of the frequency.
 */

module waveformGenerator(input CLK_50M, input[3:0] SW,
												 output SPI_SCK, output SPI_MOSI, output DAC_CS, output DAC_CLR);

wire		w_clock;

wire	[11:0]	wb_Va;
wire	[11:0]	wb_Vb;

Module_Counter_8_bit		SPI_SCK_generator	(	.clk_in(CLK_50M),
								.limit(30'd4),		// 4x20 ns = 80 ns <===> 50/4 MHz = 12.5 MHz

								.carry(SPI_SCK));

DAC_Driver			DAC_Driver		(	.CLK_50M(CLK_50M),
								.Va(wb_Va),.Vb(wb_Vb),
								.startEnable(1),

								.SPI_SCK(SPI_SCK),
								.SPI_MOSI(SPI_MOSI),
								.DAC_CS(DAC_CS),
								.DAC_CLR(DAC_CLR),
								.dacNumber(w_clock));


// Slower clock
wire w_clock_10_Hz;
wire [11:0] w_DAC;
wire [2:0] defaultPeriod;
assign defaultPeriod = {SW[3], SW[2], SW[1]};

Module_FrequencyDivider	clock_10_Hz_generator(.clk_in(CLK_50M),
																							.period(defaultPeriod),

																							.clk_out(w_clock_10_Hz));

`define maximumDAC {12{1'b1}}
// The DAC is a 12 bits; the maximum is 12'b111111111111
Module_SynchroCounter_12_bit_SR	counter ( .qzt_clk(CLK_50M), .clk_in(w_clock_10_Hz),
																					.reset(0), .set(0),
																					.presetValue(11'd0), .limit(`maximumDAC),

																					.out(w_DAC), .carry());

// The first bit drives the sign of the slope
assign wb_Vb = SW[0] ? w_DAC : ~w_DAC;


endmodule



/*******************************************************/
/*** Module_SynchroCounter_8_bit_SR from chipstore.v ***/
/*******************************************************/
module	Module_SynchroCounter_12_bit_SR	(	input qzt_clk, input clk_in,
																					input reset, input set,
																					input [12:0] presetValue, input [12:0] limit,

																					output reg[12:0] out, output reg carry);

	reg		clk_in_old;

	always @(posedge qzt_clk) begin
		if (reset) begin
			out <= 0;
			carry <= 0;
		end else if (set) begin
			out <= presetValue;
			carry <= 0;
		end else if (!clk_in_old & clk_in) begin
			if (out >= (limit - 8'b00000001)) begin
				out <= 0;
				carry <= 1;
			end else if (out == 0) begin
				out <= 1;
				carry <= 0;
			end else
				out <= out + 1;
		end

		clk_in_old <= clk_in;
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
