module	LCD_Driver_forChrono	(	qzt_clk,
						fourDigitInput,
						lapFlag,

						lcd_flags,
						lcd_data);

input		qzt_clk;
input	[15:0]	fourDigitInput;
input		lapFlag;

output	[1:0]	lcd_flags;
output	[3:0]	lcd_data;

endmodule
