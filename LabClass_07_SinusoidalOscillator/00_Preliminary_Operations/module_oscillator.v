module Module_Oscillator	(
		input		clk_in,
		input	[3:0]	k,
		input		loadBoundaryCondition,
		input	[16:0]	boundaryCondition,
		output	[11:0]	wave);

reg	signed [16:0]	y;
reg	signed [16:0]	yOld;

buf(wave, y >> 4);


/* always @(posedge clk_in) begin
	if (loadBoundaryCondition) begin
		y <= boundaryCondition;
		yOld <= (boundaryCondition >> (k+1)) - boundaryCondition;
	end else begin
		yOld <= -y ;

		y <= (y << 1) - (y >> k) + yOld + 1;
	end
end
*/

always @(posedge clk_in) begin
	if (loadBoundaryCondition) begin
		y <= boundaryCondition;
		yOld <= (boundaryCondition >> (k+1)) + ~boundaryCondition;
	end else begin
		y <= (y << 1) + yOld + (
															(y[16]) ? ((~y + 1) >> k) : (~(y >> k) + 1)
														);
		yOld <= ~y;
	end
end

endmodule


//////////////////////
// unsigned version //
//////////////////////

// always @(posedge clk_in) begin
//	if (loadBoundaryCondition) begin
//		y <= boundaryCondition;
//		yOld <= (boundaryCondition >> (k+1)) + ~boundaryCondition;
//	end else begin
//		yOld <= ~y;
//		y <= (y << 1) + yOld + ((y[16])? ((~y + 1) >> k) : (~(y >> k) + 1));
//	end
// end
