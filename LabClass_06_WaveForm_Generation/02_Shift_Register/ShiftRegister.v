module ShiftRegister	(input CLK_50M, input BTN_SOUTH, input SW,
											 output reg[7:0] LED);

`define		defaultPeriod	30'b000001011111010111100001000000	//	25 10^6

wire w_clock_1_Hz;
Module_FrequencyDivider	clock_1_Hz_generator(.clk_in(CLK_50M),
																						.period(`defaultPeriod),

																						.clk_out(w_clock_1_Hz));

wire w_button;
`define		defaultN 	28'b0000000011110100001001000000	//	10^6 ===> 20 ms
Module_Monostable	button(	.clk_in(CLK_50M), .monostable_input(BTN_SOUTH),
													.N(`defaultPeriod), .monostable_output(w_button));


reg[7:0] register = 8'd0;
reg old_clock_1_Hz;

/*always @(posedge CLK_50M) begin
	if(~old_clock_1_Hz & w_clock_1_Hz) begin
		register[7:1] <= register[6:0];
		register[0] <= w_button;
	end
	old_clock_1_Hz <= w_clock_1_Hz;
	LED <= register;
end */

reg last_of_moicans;
always @(posedge CLK_50M) begin

	if(~old_clock_1_Hz & w_clock_1_Hz) begin

		register[7:1] <= register[6:0];
		register[0] <= (w_button | ( SW ? register[7] : 0));
	end
	old_clock_1_Hz <= w_clock_1_Hz;
	LED <= register;

end



endmodule





/*****************************/
/*** Module_MonostableHold ***/
/*****************************/
module Module_Monostable	(	clk_in,
					monostable_input,
					N,

					monostable_output);

input		clk_in;
input		monostable_input;
input	[27:0]	N;

output		monostable_output;

reg		monostable_output;

reg		monostable_input_old;
reg 	[27:0]	counter;

always @(posedge clk_in) begin
	if (counter == 0) begin
		if (!monostable_input_old & monostable_input) begin
			counter <= ((N)? N : `defaultN) - 1;
			monostable_output <= 1;
		end else
			monostable_output <= 0;
	end else
		counter <= counter - 1;

	monostable_input_old <= monostable_input;
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
