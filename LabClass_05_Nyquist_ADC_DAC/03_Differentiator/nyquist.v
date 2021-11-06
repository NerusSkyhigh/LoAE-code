module nyquist	(	input CLK_50M, input SW, input ADC_OUT,

									output DAC_CS, output DAC_CLR, output SPI_SCK,
									output AMP_CS, output SPI_MOSI,output AD_CONV);

wire		w_SPI_MOSI_preAmp;
wire		w_SPI_MOSI_DAC;
wire		w_dacNumber;

wire	[13:0]	wb_Va;
wire	[13:0]	wb_Vb;


buf(SPI_MOSI, ((AMP_CS & w_SPI_MOSI_DAC)|(!AMP_CS & w_SPI_MOSI_preAmp)));

buf(wb_Vb, 13'd0);

Module_Counter_8_bit	SPI_SCK_generator	(	.clk_in(CLK_50M),
																					.limit(((SW)? 30'd10 : 30'd4)),

																					.carry(SPI_SCK));

ADC_Driver		ADC_Driver		(	.qzt_clk(CLK_50M), .SPI_SCK(SPI_SCK),
															.enable(1), .ADC_OUT(ADC_OUT),
															.gainLabel(0), .waitTime({SW,4'b0000}),

															.AD_CONV(AD_CONV), .Va_Vb({wb_Va, wb_Vb}),
															.AMP_CS(AMP_CS), .SPI_MOSI(w_SPI_MOSI_preAmp));



/*
 h[n] = δ[n] − δ[n−1].
*/
wire [13:0]	wb_VaNm1;

// delta(N minus 1)
Module_Latch_14_bit	deltaNm1(	.clk_in(~SPI_SCK), .holdFlag(0), .twoByteInput(wb_Va),
															.twoByteOuput(wb_VaNm1) );

// Register of differentiator
wire  [13:0] wb_diff;
assign wb_diff = wb_Va - wb_VaNm1;

DAC_Driver		DAC_Driver		(	.CLK_50M(CLK_50M), .SPI_SCK(SPI_SCK),
															.Va({!wb_Va[13], wb_Va[12:2]}), // DAC A has to relay ADC A as before;
															.Vb({!wb_diff[13], wb_diff[12:2]}), // the differentiator has to be output on DAC B
															.startEnable(AD_CONV),

															.SPI_MOSI(w_SPI_MOSI_DAC), .DAC_CS(DAC_CS),
															.DAC_CLR(DAC_CLR), .dacNumber(w_dacNumber));

endmodule





/********************************************/
/*** Module_Latch_16_bit from chipStore.v ***/
/********************************************/
module	Module_Latch_14_bit	(	input clk_in, input holdFlag,
															input	[13:0] twoByteInput,

															output reg[13:0] twoByteOuput);

always @(posedge clk_in) begin
	if (!holdFlag) twoByteOuput <= twoByteInput;
end

endmodule
