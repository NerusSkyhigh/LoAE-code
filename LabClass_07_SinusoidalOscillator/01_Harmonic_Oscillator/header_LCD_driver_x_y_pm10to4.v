module	LCD_Driver_x_y_pm10to4	(	qzt_clk,
					fourDigitInputX,
					fourDigitInputY,
					signXFlag,
					signYFlag,

					lcd_flags,
					lcd_data);

input		qzt_clk;
input	[15:0]	fourDigitInputX;
input	[15:0]	fourDigitInputY;
input		signXFlag;
input		signYFlag;

output	[1:0]	lcd_flags;
output	[3:0]	lcd_data;

endmodule
