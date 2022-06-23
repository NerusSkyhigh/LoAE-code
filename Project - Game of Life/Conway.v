module CELLULAR_AUTOMATA(input qzt_clk, input clk_in,
						// Nearest neighbours
						input NW, input N, input NE,
						input  W,  				 input  E,
						input SW, input S, input SE,

						input set_state,
						input initial_state,


						output reg state
						);

// Useful syntax found, it is not used in the project
// but i wanted to keep it nevertheless
/*initial begin
	state <= initial_state;
end */

reg [3:0] nn_alive; // Number of neighbours alive
always @(posedge qzt_clk) begin
	// Update the number of neighbours only if
	// the state is not changing
	if(clk_in == 0) begin
		nn_alive = NW + N + NE +
							  W	+      E +
	  					 SW + S + SE;
	end
end


always @(posedge clk_in) begin
	// If state_state is high, the initial state
	// will be set only on the next positive edge of clk_in
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
			// I could have used a default clause but i
			// want to be warned of edge cases.
			4'b0100,	4'b0101, 4'b0110, 4'b0111, 4'b1000: // nn_alive = 4, 5, 6, 7, 8
				begin
					state <= 1'b0;
				end
    endcase
	end

end

endmodule
