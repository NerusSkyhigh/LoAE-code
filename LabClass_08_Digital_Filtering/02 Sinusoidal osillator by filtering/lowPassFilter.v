module lowPassFilter(input CLK_50M,
										 input ADC_OUT,
									 	 input [3:0] SW,

										 output DAC_CS,
										 output DAC_CLR,
										 output SPI_SCK,
										 output AMP_CS,
										 output SPI_MOSI,
										 output AD_CONV);

wire		w_SPI_MOSI_preAmp;
wire		w_SPI_MOSI_DAC;
wire		w_dacNumber;

wire	[13:0]	wb_Va;
wire	[13:0]	wb_Vb;

wire	[19:0]	wb_Va_filtered;

buf(SPI_MOSI, ((AMP_CS & w_SPI_MOSI_DAC)|(!AMP_CS & w_SPI_MOSI_preAmp)));

Module_Counter_8_bit	SPI_SCK_generator	(	.clk_in(CLK_50M),
							.limit(30'd10),

							.carry(SPI_SCK));


/******************************
 * 			LOW PASS CASCADE		 	*
 ******************************/
wire	[19:0]	wb_Va_filtered12;
Module_LowPassFilter	LPF1		(	.qzt_clk(CLK_50M),
						.clk_in(~w_dacNumber),
						.k(SW),
						.Vin({wb_Va[13:0], 6'b000000}),

						.Vout(wb_Va_filtered12));


wire	[19:0]	wb_Va_filtered23;
Module_LowPassFilter	LPF2		(	.qzt_clk(CLK_50M),
						.clk_in(~w_dacNumber),
						.k(SW),
						.Vin(wb_Va_filtered12),

						.Vout(wb_Va_filtered23));


wire	[19:0]	wb_Va_filtered34;
Module_LowPassFilter	LPF3		(	.qzt_clk(CLK_50M),
						.clk_in(~w_dacNumber),
						.k(SW),
						.Vin(wb_Va_filtered23),

						.Vout(wb_Va_filtered));
/*
wire	[19:0]	wb_Va_filtered45;
Module_LowPassFilter	LPF4		(	.qzt_clk(CLK_50M),
						.clk_in(~w_dacNumber),
						.k(SW),
						.Vin(wb_Va_filtered34),

						.Vout(wb_Va_filtered45));

Module_LowPassFilter	LPF5		(	.qzt_clk(CLK_50M),
						.clk_in(~w_dacNumber),
						.k(SW),
						.Vin(wb_Va_filtered45),

						.Vout(wb_Va_filtered));
*/
/******************************
 * 	END OF LOW PASS CASCADE	 	*
 ******************************/



ADC_Driver		ADC_Driver		(	.qzt_clk(CLK_50M),
							.SPI_SCK(SPI_SCK),
							.enable(1),
							.ADC_OUT(ADC_OUT),
							.gainLabel(0),
							.waitTime(5'b10000),

							.AD_CONV(AD_CONV),
							.Va_Vb({wb_Va, wb_Vb}),
							.AMP_CS(AMP_CS),
							.SPI_MOSI(w_SPI_MOSI_preAmp));

DAC_Driver		DAC_Driver		(	.CLK_50M(CLK_50M),
							.SPI_SCK(SPI_SCK),
							.Va({!wb_Va[13], wb_Va[12:2]}),
							.Vb({!wb_Va_filtered[19], wb_Va_filtered[18:8]}),
							.startEnable(AD_CONV),

							.SPI_MOSI(w_SPI_MOSI_DAC),
							.DAC_CS(DAC_CS),
							.DAC_CLR(DAC_CLR),
							.dacNumber(w_dacNumber));

endmodule
