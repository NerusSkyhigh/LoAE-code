/*
 * PROBLEM 03: DIFFERENTIATOR
 * By further modifying the project so that DAC A relays ADC A as before,
 * implement the differentiator h[n] = δ[n] − δ[n − 1]. Beware:
 *	– DAC A has to relay ADC A as before;
 * 	– the differentiator has to be output on DAC B as an additional option to
 *		the delayed relaying implemented above;
 *	– the output choice between differentiator and delayed relaying has to occur
 *		via a switch;
 *	– again, ADC B is not used.
 */
module nyquist	(	input CLK_50M, input[1:0]	SW, input		ADC_OUT,
									output DAC_CS, output	DAC_CLR, output	SPI_SCK,
									output SPI_MOSI, output	AMP_CS, output AD_CONV);

wire		w_SPI_MOSI_preAmp;
wire		w_SPI_MOSI_DAC;
wire		w_dacNumber;

wire	[13:0]	wb_Va;
wire	[13:0]	wb_Vb;

buf(SPI_MOSI, ((AMP_CS & w_SPI_MOSI_DAC)|(!AMP_CS & w_SPI_MOSI_preAmp)));

Module_Counter_8_bit	SPI_SCK_generator	(	.clk_in(CLK_50M),
																					.limit(((SW[0])? 30'd10 : 30'd4)),

																					.carry(SPI_SCK)); // Sampling time


ADC_Driver		ADC_Driver		(	.qzt_clk(CLK_50M),
															.SPI_SCK(SPI_SCK),
															.enable(1),
															.ADC_OUT(ADC_OUT),
															.gainLabel(0),
															.waitTime({SW[0],4'b0000}),

															.AD_CONV(AD_CONV),
															.Va_Vb({wb_Va, wb_Vb}),
															.AMP_CS(AMP_CS),
															.SPI_MOSI(w_SPI_MOSI_preAmp));

reg[13:0] DAC_OUT_B;
DAC_Driver		DAC_Driver		(	.CLK_50M(CLK_50M),
							.SPI_SCK(SPI_SCK),
							.Va({!wb_Va[13], wb_Va[12:2]}),
							.Vb({!DAC_OUT_B[13], DAC_OUT_B[12:2]}),
							.startEnable(AD_CONV),

							.SPI_MOSI(w_SPI_MOSI_DAC),
							.DAC_CS(DAC_CS),
							.DAC_CLR(DAC_CLR),
							.dacNumber(w_dacNumber));


reg[13:0] wb_Va_delayed;

// 'negedge w_dacNumber' should be the same as 'posedge ~w_dacNumber'
always @(negedge w_dacNumber ) begin
		DAC_OUT_B <= ( SW[1] ?  wb_Va_delayed : (wb_Va-wb_Va_delayed) );
		wb_Va_delayed <= wb_Va;
end

endmodule
