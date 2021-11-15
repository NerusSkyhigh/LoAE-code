module	Module_4Digit_BCD_Converter	(	clk_in,
						fourteenBitsUnsignedInteger,

						fourDigitOutput);

input		clk_in;
input	[13:0]	fourteenBitsUnsignedInteger;

output	[15:0]	fourDigitOutput;

reg	[15:0]	fourDigitOutput;

reg		busy;
reg	[13:0]	fourteenBitsUnsignedIntegerOld;
reg	[15:0]	counterBCD;
reg	[13:0]	counter;


always @(posedge clk_in) begin
	if (!busy & (fourteenBitsUnsignedIntegerOld != fourteenBitsUnsignedInteger)) begin
		busy = 1;
	end else begin
		if  (fourteenBitsUnsignedInteger > 14'b10011100001111) begin	// 9999
			fourDigitOutput = 16'b1001100110011001;
		end else begin
			if (counter == fourteenBitsUnsignedInteger) begin
				fourDigitOutput = counterBCD;
				busy = 0;
				counterBCD = 0;
				counter = 0;
			end else begin
				counter = counter + 1;

				if (counterBCD[3:0] == 4'b1001) begin
					counterBCD[3:0] = 0;
					if (counterBCD[7:4] == 4'b1001) begin
						counterBCD[7:4] = 0;
						if (counterBCD[11:8] == 4'b1001) begin
							counterBCD[11:8] = 0;
							if (counterBCD[15:12] == 4'b1001) begin
								counterBCD[15:12] = 0;
							end else begin
								counterBCD[15:12] = counterBCD[15:12] + 1;
							end
						end else begin
							counterBCD[11:8] = counterBCD[11:8] + 1;
						end
					end else begin
						counterBCD[7:4] = counterBCD[7:4] + 1;
					end
				end else begin
					counterBCD[3:0] = counterBCD[3:0] + 1;
				end
			end
		end
	end

	fourteenBitsUnsignedIntegerOld = fourteenBitsUnsignedInteger;
end

endmodule
