module Module_LowPassFilter(input qzt_clk,
													  input clk_in,
														input [3:0] k,
														input signed [19:0] Vin,

														output reg signed [19:0] Vout);

//reg	signed [19:0] Vout_old = 0;
reg		clk_in_old;
// Insert below the necessary reg's and lines
always @(posedge qzt_clk) begin
	/*
		NOTES:
			1) The operator >>> works as intended only for SIGNED reg(s)
			2) When a negative number is padded with >>(>) it should be padded with zeros
			3) Performing the computation with some "two-complements" in-between may lead
				 to overflows (that was what I was seeing!!!). In that case a workaround
				 needs to be implemented.

		Solution with two-complements *without* workarounds:
	Vout <= Vout
					+ ( (Vout[19])? ( (~Vout+1) >> k) 			: (~(Vout >> k) + 1) ) // - (Vout>>k)
					+ ( (Vin[19]) ? ( (~(~Vin+1)>> k)+1)	: (  Vin >> k ) );//(Vin>>k);
 	 */
 	if(clk_in & !clk_in_old) begin
		Vout <= (Vin >>> k) + Vout - (Vout >>> k);
	end
	clk_in_old <= clk_in;


end

endmodule
