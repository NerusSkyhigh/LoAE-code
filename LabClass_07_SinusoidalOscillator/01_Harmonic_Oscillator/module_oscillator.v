/*
 * PROBLEM 01:
 *	Implementation of a harmonic oscillator:
 * 		- development of the oscillator;
 *		- characterization of operation of the oscillator as a function
 *			of the input parameter k.
 */
module Module_Oscillator	(
		input		clk_in,
		input	[3:0]	k,
		input		loadBoundaryCondition,
		input	[16:0]	boundaryCondition,
		output	[11:0]	wave);

reg	signed [16:0]	y;
reg	signed [16:0]	yOld;

buf(wave, y >> 4);


/*
always @(posedge clk_in) begin
	if (loadBoundaryCondition) begin
		y <= boundaryCondition;
		yOld <= (boundaryCondition >> (k+1)) - boundaryCondition;
	end else begin
		yOld <= y ;

		y <= (y << 1) - (y >> k) - yOld + 1;
	end
end
*/

// always @(posedge clk_in) begin
//	if (loadBoundaryCondition) begin
//		y <= boundaryCondition;
//		yOld <= (boundaryCondition >> (k+1)) + ~boundaryCondition;
//	end else begin
//		yOld <= ~y;
//		y <= (y << 1) + yOld + ((y[16])? ((~y + 1) >> k) : (~(y >> k) + 1));
//	end
// end

/*
	NON FUNZIONA ANCORA BENE, DEVO RIVEDERLO INSIEME AL LC05 - Improved Differentiator
 */
always @(posedge clk_in) begin
	if (loadBoundaryCondition) begin
		y <= boundaryCondition;
		yOld <= (boundaryCondition >> (k+1)) + ~boundaryCondition;
	end else begin
		y <= (y << 1) + yOld + (
		// As we are dealing with both positive and negative numbers we need to be
		// sure to bitshift correctly. In this case the bitshift is performed when
		// the number is positive. This is to avoid adding trailing zeros to a two's
		// complement number
															(y[16]) ? ((~y + 1) >> k) : (~(y >> k) + 1)
														);
		yOld <= ~y;
	end
end

endmodule
