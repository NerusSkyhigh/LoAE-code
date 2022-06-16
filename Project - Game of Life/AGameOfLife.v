`define L 16 // Size of the grid
`define L2 256 // L*L

// This defines the default time between generations
//`define		defaultPeriod	30'b000001011111010111100001000000	//	25 10^6 ~ 1s
`define		defaultPeriod	30'b000000000001011111010111100001


module AGameOfLife(input CLK_50M,
									 input [3:0] SW,

									 input ROT_A,
									 input ROT_B,

									 output reg [3:0] VGA_R,
									 output reg [3:0] VGA_G,
									 output reg [3:0] VGA_B,
									 output VGA_HSYNC, // When to begin a new line
									 output VGA_VSYNC, // When to move on the right
									 output reg [7:0] LED
									 );

// Knob driver: it manages the zoom.
wire [2:0] wb_zoom;
VGA_ZOOM_KNOB zoomer(.clk_in(CLK_50M),
										 .ROT_A(ROT_A),
										 .ROT_B(ROT_B),

										 .zoom(wb_zoom));




// Wires going out of each cell.
// It represents the STATUS of the other cells
// There are L*L cells.

// `L2'b01000000_01000000_01000000_00000000_00000000_00000000_00000000_00000000
wire [`L2-1:0] w_initial_status = `L2'b0000000011001011000000010010011000000000101000000000000001000000000000000000000100000000000001110000000000001000000000000000010000000000000000110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
wire [`L2-1:0] w_status;



wire CLK_CA; // Evolution clock of the simulation

Module_FrequencyDivider	mod_fd(.clk_in(CLK_50M), .period(`defaultPeriod << SW),
															 .clk_out(CLK_CA));



wire set_state;
assign set_state = SW[3];
always @ (posedge CLK_50M) begin
	// https://stackoverflow.com/questions/53457788/most-significant-bit-operand-in-part-select-of-vector-wire-is-illegal
	//LED <= w_status[ `L*SW[2:0]+:5];
	LED[7:3] <= w_status[ `L*SW[2:0]+:8];
	LED[2:0] <= wb_zoom;
end

/*
 * Generate block to create the
 */
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
wire [9:0] w_vga_x, w_vga_y;

VGA_CLOCK_480p VGA_clock(.clk_in(CLK_50M),
												 .clk_out(w_clock_25MHz));

VGA_DRIVER_480p vga_driver(.clk_vga(w_clock_25MHz),// pixel clock
		    									 .rst(0),       		 // reset

													 .sx(w_vga_x),  			   // horizontal screen position
													 .sy(w_vga_y),  				 // vertical screen position
													 .hsync(VGA_HSYNC),      // horizontal sync
													 .vsync(VGA_VSYNC),      // vertical sync
													 .de(data_enabled) );    // data enable (low in blanking interval)



always @(posedge w_clock_25MHz) begin
	// w_status[`L*row + col]
	if( (w_status[`L2 - (`L*( (w_vga_y >> wb_zoom ) % `L) + ( (w_vga_x >> wb_zoom) % `L))] == 1'b1) & (w_vga_x<479) ) begin
		VGA_B[3:0] <= (data_enabled) ?  4'b0001 : 4'b0000;
		VGA_R[3:0] <= (data_enabled) ?  4'b0001 : 4'b0000;
		VGA_G[3:0] <= (data_enabled) ?  4'b0001 : 4'b0000;

	end else begin if( (w_vga_x[wb_zoom] ^ w_vga_y[wb_zoom]) & (w_vga_x<479)) begin
			VGA_B[3:0] <= (data_enabled) ?  4'b1100 : 4'b0000;
			VGA_R[3:0] <= (data_enabled) ?  4'b1100 : 4'b0000;
			VGA_G[3:0] <= (data_enabled) ?  4'b1100 : 4'b0000;

		end else if( ~(w_vga_x[wb_zoom] ^ w_vga_y[wb_zoom]) & (w_vga_x<479)) begin
			VGA_B[3:0] <= (data_enabled) ?  4'b1111 : 4'b0000;
			VGA_R[3:0] <= (data_enabled) ?  4'b1111 : 4'b0000;
			VGA_G[3:0] <= (data_enabled) ?  4'b1111 : 4'b0000;

		end else begin
			VGA_B[3:0] <= 4'b0000;
			VGA_R[3:0] <= 4'b0000;
			VGA_G[3:0] <= 4'b0000;
		end
	end

end


endmodule
