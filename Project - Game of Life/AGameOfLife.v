`define L 8 // Size of the grid
`define L2 64

module AGameOfLife(input CLK_50M,
									 input [3:0] SW,

									 output reg [3:0] VGA_R,
									 output reg [3:0] VGA_G,
									 output reg [3:0] VGA_B,
									 output VGA_HSYNC, // When to begin a new line
									 output VGA_VSYNC, // When to move on the right
									 output reg [7:0] LED
									 );



// Wires going out of each cell.
// It represents the STATUS of the other cells
// There are L*L cells.
wire [`L2-1:0] w_initial_status = `L2'b00010000_00010000_00010000_00000000_00000000_00000000_00000000_00000000;
																		 //`L2'b00000000_01000000_11100000_01000000_00001000_00001000_00001000_00000000;
wire [`L2-1:0] w_status; // = `L2'b00000000_01000000_11100000_01000000_00001000_00001000_00001000_00000000;
/*
00000000 (7)
01000000 (6)
11100000 (5)
01000000 (4)
00001000 (3)
00001000 (2)
00001000 (1)
00000000 (0)
*/

wire CLK_CA; // Evolution of the simulation
`define		defaultPeriod	30'b000001011111010111100001000000	//	25 10^6
Module_FrequencyDivider	mod_fd(.clk_in(CLK_50M), .period(`defaultPeriod),
															 .clk_out(CLK_CA));



wire set_state;
assign set_state = SW[3];
always @ (posedge CLK_50M) begin
	// https://stackoverflow.com/questions/53457788/most-significant-bit-operand-in-part-select-of-vector-wire-is-illegal
	LED <= w_status[ `L*SW[2:0]+:8];
end

genvar row;
generate
	for(row=0; row<`L; row=row+1) begin: gen_rows
		genvar col;
		for(col=0; col<`L; col=col+1) begin: gen_col
			// Periodic boundary conditions
			CELLULAR_AUTOMATA ca(.qzt_clk(CLK_50M), .clk_in(CLK_CA),
													 .NW( w_status[`L*( (row == `L-1) ? 0		 : row+1) + ( (col == `L-1) ?    0 : col+1)]),
										 		 	 	.N( w_status[`L*( (row == `L-1) ? 0 	 : row+1) +    col]),
													 .NE( w_status[`L*( (row == `L-1) ? 0 	 : row+1) + ( (col ==    0) ? `L-1 : col-1)]),

										 		 	  .W( w_status[`L*row 												 		+ ( (col == `L-1) ?    0 : col+1)]),
										 		 	  .E( w_status[`L*row 														+ ( (col ==    0) ? `L-1 : col-1)]),

												 	 .SW( w_status[`L*( (row == 0) 		? `L-1 : row-1) + ( (col == `L-1) ?    0 : col+1)]),
										 		 		.S( w_status[`L*( (row == 0)		? `L-1 : row-1) +  col]),
													 .SE( w_status[`L*( (row == 0) 		? `L-1 : row-1) + ( (col ==    0) ? `L-1 : col-1)]),

													 .set_state(set_state),
 							 						 .initial_state(w_initial_status[`L*row + col]),

													 .state( w_status[`L*row + col] ));
		end
	end
endgenerate




wire w_clock_25MHz,
		 data_enabled;

VGA_CLOCK_480p VGA_clock(.clk_in(CLK_50M),
												 .clk_out(w_clock_25MHz));

wire [9:0] w_vga_x, w_vga_y;

always @(posedge w_clock_25MHz) begin

	//LED[3:0] <= SW[3:0];

	if( w_status[ (`L*w_vga_y + w_vga_x) % (`L*`L) ] ) begin
		// Draw white pixel for "alive" cell
		//LED[4] <= 1;
		VGA_B[3:0] <= (data_enabled) ?  4'b1111 : 4'b0000;
		VGA_R[3:0] <= (data_enabled) ?  4'b1111 : 4'b0000;
		VGA_G[3:0] <= (data_enabled) ?  4'b1111 : 4'b0000;
	end else if( SW[1]) begin
		VGA_R[3:0] <= (data_enabled && SW[0]) ?  4'b1111 : 4'b0000;
	end else if( w_vga_y%`L==0 && w_vga_x%`L==0 && SW[2]   ) begin
		// Draw white pixel for "alive" cell
		VGA_B[3:0] <= (data_enabled) ?  4'b1111 : 4'b0000;
	end else begin
		VGA_B[3:0] <= (data_enabled) ?  4'b1111 : 4'b0000;
		VGA_R[3:0] <= (data_enabled) ?  4'b1111 : 4'b0000;
		VGA_G[3:0] <= (data_enabled) ?  4'b1111 : 4'b0000;
	end

	/*
	if(SW[0]) begin
		LED[4] <=0;
	end */

end

VGA_DRIVER_480p vga_driver(.clk_vga(w_clock_25MHz),// pixel clock
		    									 .rst(0),       		 // reset

													 .sx(w_vga_x),  			   // horizontal screen position
													 .sy(w_vga_y),  				 // vertical screen position
													 .hsync(VGA_HSYNC),      // horizontal sync
													 .vsync(VGA_VSYNC),      // vertical sync
													 .de(data_enabled) );    // data enable (low in blanking interval)





/*
// TEST PER LA SINGOLA CELLA
wire w_clock_25MHz,
		 data_enabled;

VGA_CLOCK_480p VGA_clock(.clk_in(CLK_50M),
												 .clk_out(w_clock_25MHz));


wire [9:0] w_vga_x, w_vga_y;


always @(posedge w_clock_25MHz) begin
	LED[3:0] <= SW[3:0];

	if( (w_vga_x == w_vga_y) && SW[0] ) begin
		// Draw oblique black line
		VGA_B[3:0] <= 4'b0000;
		VGA_R[3:0] <= 4'b0000;
		VGA_G[3:0] <= 4'b0000;

		// Draw square on first pixel
	end else if( (w_vga_x == 1) & SW[1]) begin
		VGA_B[3:0] <= (data_enabled) ?  4'b1111 : 4'b0000;
		VGA_R[3:0] <= 4'b0000;
		VGA_G[3:0] <= 4'b0000;
	end else if( (w_vga_y == 1) & SW[1] ) begin
		VGA_B[3:0] <= (data_enabled) ?  4'b1111 : 4'b0000;
		VGA_R[3:0] <= 4'b0000;
		VGA_G[3:0] <= 4'b0000;

	end else if( (w_vga_x == 200) & SW[2] ) begin
		VGA_B[3:0] <= 4'b0000;
		VGA_R[3:0] <= (data_enabled) ?  4'b1111 : 4'b0000;
		VGA_G[3:0] <= 4'b0000;

	end else if( (w_vga_y == 200) & SW[2] ) begin
		VGA_B[3:0] <= 4'b0000;
		VGA_R[3:0] <= (data_enabled) ?  4'b1111 : 4'b0000;
		VGA_G[3:0] <= 4'b0000;

	end else if( (w_vga_x == 479) & SW[3] ) begin
		VGA_B[3:0] <= 4'b0000;
		VGA_R[3:0] <= 4'b0000;
		VGA_G[3:0] <= (data_enabled) ?  4'b1111 : 4'b0000;

	end else if( (w_vga_y == 479) & SW[3] ) begin
		VGA_B[3:0] <= 4'b0000;
		VGA_R[3:0] <= 4'b0000;
		VGA_G[3:0] <= (data_enabled) ?  4'b1111 : 4'b0000;

	end else begin
		VGA_B[3:0] <= (data_enabled) ?  4'b1111 : 4'b0000;
		VGA_R[3:0] <= (data_enabled) ?  4'b1111 : 4'b0000;
		VGA_G[3:0] <= (data_enabled) ?  4'b1111 : 4'b0000;
	end
end

VGA_DRIVER_480p vga_driver(.clk_vga(w_clock_25MHz),// pixel clock
													 .rst(0),       		 // reset

													 .sx(w_vga_x),  			   // horizontal screen position
													 .sy(w_vga_y),  				 // vertical screen position
													 .hsync(VGA_HSYNC),      // horizontal sync
													 .vsync(VGA_VSYNC),      // vertical sync
													 .de(data_enabled) );    // data enable (low in blanking interval)

													 wire status_cell;


wire set_state;
assign set_state = SW[3];

CELLULAR_AUTOMATA my_cell(.qzt_clk(CLK_50M), .clk_in(CLK_CA),
	 					.NW(0), .N(SW[0]), .NE(SW[1]),
						.W(0),		  			 .E(0),
						.SW(0), .S(1), .SE(SW[2]),

						.set_state(set_state),
						.initial_state(1),

						.state(status_cell)
						);

always @ (posedge CLK_50M) begin
	LED[4] <= status_cell;
end
*/
endmodule
