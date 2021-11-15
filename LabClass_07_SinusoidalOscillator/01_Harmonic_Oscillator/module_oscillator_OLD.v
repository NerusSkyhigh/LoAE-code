module Module_Oscillator	(	clk_in,
					k,
					loadBoundaryCondition,
					boundaryCondition,

					wave);

input		clk_in;
input	[3:0]	k; // from 0 to 15
input		loadBoundaryCondition; // wheter I have to load the BC or not
input	[16:0]	boundaryCondition;

output	[11:0]	wave;

// Insert below the necessary reg's and lines

// 17 bits internal storage
reg[16:0] y; // y[n-1]
reg[16:0] yold; // y[n-2]




always @(posedge clk_in) begin
		if(loadBoundaryCondition) begin
			// This is fine
			y <= boundaryCondition;
			yold <= ( ((boundaryCondition << 1) - (boundaryCondition>>k)) >>1 );
		end else begin
			// This is not, k could be even 15
			// NOTE: I have TWO different subtraction and I have to handle both of them
			y <= ( (y<<1)-(y>>k) ) + (~yold+1);
			yold <= y;
		end
end

assign wave = y[16:5];



endmodule
