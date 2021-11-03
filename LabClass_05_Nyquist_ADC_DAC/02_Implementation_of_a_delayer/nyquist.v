module nyquist	(	CLK_50M,
				SW,
				ADC_OUT,

				DAC_CS,
				DAC_CLR,
				SPI_SCK,
				AMP_CS,
				SPI_MOSI,
				AD_CONV);

input		CLK_50M;
input		SW;
input		ADC_OUT;

output		DAC_CS;
output		DAC_CLR;
output		SPI_SCK;
output		SPI_MOSI;
output		AMP_CS;
output		AD_CONV;

wire		w_SPI_MOSI_preAmp;
wire		w_SPI_MOSI_DAC;
wire		w_dacNumber;

// Wires bus ADC a/b
wire	[13:0]	wb_Va;
wire	[13:0]	wb_Vb;


buf(SPI_MOSI, ((AMP_CS & w_SPI_MOSI_DAC)|(!AMP_CS & w_SPI_MOSI_preAmp)));


Module_Counter_8_bit	SPI_SCK_generator	(	.clk_in(CLK_50M),
							.limit(((SW)? 30'd10 : 30'd4)),

							.carry(SPI_SCK)); // Sampling time


ADC_Driver		ADC_Driver		(	.qzt_clk(CLK_50M),
							.SPI_SCK(SPI_SCK),
							.enable(1),
							.ADC_OUT(ADC_OUT),
							.gainLabel(0),
							.waitTime({SW,4'b0000}),

							.AD_CONV(AD_CONV),
							.Va_Vb({wb_Va, wb_Vb}),
							.AMP_CS(AMP_CS),
							.SPI_MOSI(w_SPI_MOSI_preAmp));


// Delayer implemented through a latch
wire[13:0] wb_Va_delayed;
Module_Latch_16_bit	latch(	.clk_in(SPI_SCK),
														.holdFlag(0),
														.twoByteInput(wb_Va),
														.twoByteOuput(wb_Va_delayed));

DAC_Driver		DAC_Driver		(	.CLK_50M(CLK_50M),
							.SPI_SCK(SPI_SCK),
							.Va({!wb_Va[13], wb_Va[12:2]}),
							//.Vb({!wb_Vb[13], wb_Vb[12:2]}),
							.Vb({!wb_Va_delayed[13], wb_Va_delayed[12:2]}), // Same output for both
							.startEnable(AD_CONV),

							.SPI_MOSI(w_SPI_MOSI_DAC),
							.DAC_CS(DAC_CS),
							.DAC_CLR(DAC_CLR),
							.dacNumber(w_dacNumber));

endmodule
