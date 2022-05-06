module Module_LowPassFilter(input qzt_clk,
													  input clk_in,
														input [3:0] k,
														input signed [19:0] Vin,

														output reg signed [19:0] Vout);

reg		clk_in_old;

reg signed [19:0] Vout_1; // Vout[n-1]
reg signed [19:0] Vout_2; // Vout[n-2]

reg signed [19:0] Vin_1; // Vin[n-1]
reg signed [19:0] Vin_2; // Vin[n-2]

// Insert below the necessary reg's and lines
always @(posedge qzt_clk) begin

	if(clk_in & !clk_in_old) begin
		Vout <= Vin + Vin_2 - Vout_2 + (Vout_2>>k);

		// This is always one cycle behind
		Vout_1 <= Vout;
		Vin_1 <= Vin;

		Vout_2 <= Vout_1;
		Vin_2 <= Vin_1;
	end
	clk_in_old <= clk_in;
end

endmodule
