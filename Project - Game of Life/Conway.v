/*******************************/
/*** Module_FrequencyDivider ***/
/*******************************/
/* module	Conway(input clk_in,
							 29:0] period,

							 reg clk_out);
	reg	[29:0]	counter;

	always @(posedge clk_in) begin
		if (counter >= (period - 1)) begin
			counter <= 0;
			clk_out <= ~clk_out;
		end else
			counter <= counter + 1;
	end
endmodule */

module CELLULAR_AUTOMATA(input qzt_clk, input clk_in,
						// Nearest neighbours
						input NW, input N, input NE,
						input  W,  				 input  E,
						input SW, input S, input SE,

						input set_state,
						input initial_state,


						output reg state
						);

/*initial begin
	state <= initial_state;
end */

reg [3:0] nn_alive;

always @(posedge qzt_clk) begin
	// Even if this evaluation is faster than
	// the update time it's not a problem. The
	// status will be update based on clk_in!
	if(clk_in == 0) begin
		nn_alive = NW + N + NE +
							  W	+      E +
	  					 SW + S + SE;
	end
end


always @(posedge clk_in) begin     // This is a combinational circuit
	if(set_state) begin
		state <= initial_state;
	end else begin

    case (nn_alive)
			// Any live cell with fewer than two live neighbours dies,
			// as if by underpopulation.
			4'b0000,	4'b0001:
 				begin
            state <= 1'b0;
      	end

			// Any live cell with two or three live neighbours
			// lives on to the next generation.
			4'b0010:
				begin
					state <= state;
				end

			// Any dead cell with exactly three live neighbours
			// becomes a live cell, as if by reproduction.
			4'b0011: // nn_alive = 3
				begin
					state <= 1'b1;
				end

			// Any live cell with more than three live
			// neighbours dies, as if by overpopulation.
			4'b0100,	4'b0101, 4'b0110, 4'b0111, 4'b1000: // nn_alive = 4, 5, 6, 7, 8
				begin
					state <= 1'b0;
				end

    endcase
	end

end

endmodule
