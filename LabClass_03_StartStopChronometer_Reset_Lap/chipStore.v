/*******************************/
/*** Module_FrequencyDivider ***/
/*******************************/

module	Module_FrequencyDivider	(	clk_in,
					period,

					clk_out);

input		clk_in;
input	[29:0]	period;

output		clk_out;

reg		clk_out;

reg	[29:0]	counter;

always @(posedge clk_in) begin
	if (counter >= (period - 1)) begin
		counter <= 0;
		clk_out <= ~clk_out;
	end else
		counter <= counter + 1;
end

endmodule

/****************************/
/*** Module_Counter_8_bit ***/
/****************************/

module	Module_Counter_8_bit	(	clk_in,
					limit,

					out,
					carry);

input		clk_in;
input	[7:0]	limit;

output	[7:0]	out;
output		carry;

reg	[7:0]	out;
reg		carry;

always @(posedge clk_in) begin
	if (out >= (limit - 8'b00000001)) begin
		out <= 0;
		carry <= 1;
	end else if (out == 0) begin
		out <= 1;
		carry <= 0;
	end else
		out <= out + 1;
end

endmodule

/**************************************/
/*** Module_SynchroCounter_8_bit_SR ***/
/**************************************/

module	Module_SynchroCounter_8_bit_SR	(	qzt_clk,
						clk_in,
						reset,
						set,
						presetValue,
						limit,

						out,
						carry);

input		qzt_clk;
input		clk_in;
input		reset;
input		set;
input	[7:0]	presetValue;
input	[7:0]	limit;

output	[7:0]	out;
output		carry;

reg	[7:0]	out;
reg		carry;

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

/*********************************************/
/*** Module_Multiplexer_2_input_8_bit_sync ***/
/*********************************************/

module	Module_Multiplexer_2_input_8_bit_sync	(	clk_in,
							address,
							input_0,
							input_1,

							mux_output);

input		clk_in;
input		address;
input	[7:0]	input_0;
input	[7:0]	input_1;

output	[7:0]	mux_output;

reg	[7:0]	mux_output;

always @(posedge clk_in) begin
	mux_output <= (address)? input_1 : input_0;
end

endmodule
