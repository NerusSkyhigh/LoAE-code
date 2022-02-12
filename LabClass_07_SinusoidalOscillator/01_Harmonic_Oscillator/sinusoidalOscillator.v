`define		boundaryCondition			17'b00110000000000000
`define		counterLimit				14'd10000

module sinusoidalOscillator	(	CLK_50M,
					pushButton, SW, brake,

					SPI_SCK, SPI_MOSI, DAC_CS, DAC_CLR,

					LCD_DB,
					LCD_E, LCD_RS, LCD_RW);

input		CLK_50M;
input		pushButton;
input	[3:0]	SW;
input		brake;	// also a pushButton

output		SPI_SCK;
output		SPI_MOSI;
output		DAC_CS;
output		DAC_CLR;

output	[7:0]	LCD_DB;
output		LCD_E;
output		LCD_RS;
output		LCD_RW;

wire		w_DAC_driving_pulse;
wire		w_dacNumber;

wire		w_clock_unbraked;
wire		w_clock;

wire	signed [11:0]	wb_Va;
wire	signed [11:0]	wb_Vb;

wire	[13:0]	wb_time;

wire	[15:0]	wb_fourDigitBCD_t;
wire	[15:0]	wb_fourDigitBCD_y;

buf(LCD_RW, 0);
buf(LCD_DB[3:0], 4'b1111);

/************************/
/*** CLOCK GENERATION ***/
/************************/
Module_Counter_8_bit		SPI_SCK_generator	(	.clk_in(CLK_50M),
								.limit(8'd4),		// 4x20 ns = 80 ns <===> 50/4 MHz = 12.5 MHz

								.carry(SPI_SCK));

Module_Counter_8_bit		clock_50_kHz		(	.clk_in(SPI_SCK),
								.limit(8'd250),		// 80x250 ns = 20 us <===> 12.5/250 MHz = 50 kHz

								.carry(w_DAC_driving_pulse));

Module_Counter_8_bit		oscillatorClockUnbraked		(	.clk_in(w_dacNumber),
								.limit(8'd250),		// 20x250 us = 5 ms <===> 50/250 kHz = 200 Hz

								.carry(w_clock_unbraked));

Module_Counter_8_bit		oscillatorClock		(	.clk_in(w_clock_unbraked),
								.limit((brake)? 8'd200 : 8'd2),

								.carry(w_clock));

Module_SynchroCounter_14_bit_SR	timeCounter		(	.qzt_clk(CLK_50M),
								.clk_in(w_clock),
								.reset(pushButton),
								.limit(`counterLimit),

								.out(wb_time));

/******************/
/*** DAC DRIVER ***/
/******************/
DAC_Driver			DAC_Driver		(	.CLK_50M(CLK_50M),
								.Va({!wb_Va[11],wb_Va[10:0]}),.Vb({!wb_Vb[11],wb_Vb[10:0]}),
								.startEnable(w_DAC_driving_pulse),

								.SPI_SCK(SPI_SCK),
								.SPI_MOSI(SPI_MOSI),
								.DAC_CS(DAC_CS),
								.DAC_CLR(DAC_CLR),
								.dacNumber(w_dacNumber));

/******************/
/*** LCD DRIVER ***/
/******************/
Module_4Digit_BCD_Converter	binary_2_BCD_t		(	.clk_in(CLK_50M),
								.fourteenBitsUnsignedInteger(wb_time),
								.fourDigitOutput(wb_fourDigitBCD_t));

Module_4Digit_BCD_Converter	binary_2_BCD_y		(	.clk_in(CLK_50M),
								.fourteenBitsUnsignedInteger( {3'b000, (!wb_Va[11])? wb_Va[10:0] : wb_Vb[10:0]} ),
								.fourDigitOutput(wb_fourDigitBCD_y));

LCD_Driver_x_y_pm10to4		lcd_driver		(	.qzt_clk(CLK_50M),
								.fourDigitInputX(wb_fourDigitBCD_t),
								.fourDigitInputY(wb_fourDigitBCD_y),
								.signXFlag(0),
								.signYFlag(wb_Va[11]),

								.lcd_flags({LCD_RS, LCD_E}),
								.lcd_data(LCD_DB[7:4]));

/***************************************/
/*** ... AND FINALLY, THE OSCILLATOR ***/
/***************************************/
Module_Oscillator		pendulumInPhase		(	.clk_in(w_clock),
								.k(SW),
								.loadBoundaryCondition(pushButton),
								.boundaryCondition(`boundaryCondition),

								.wave(wb_Va));

Module_Quadrature_Oscillator		pendulumInQuadrature	(	.clk_in(w_clock),
								.sin(wb_Va),
								.k(SW),
								.loadBoundaryCondition(pushButton),
								.boundaryCondition(`boundaryCondition),

								.wave(wb_Vb));

endmodule
