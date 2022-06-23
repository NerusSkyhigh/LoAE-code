`define L 16 // Size of the grid, has to be a power of 2.
						 // Due to FPGA's limitations only L = 2, 4, 8, 16 is supported
`define L2 256 // Has to be L2=L*L

// This defines the default time between generations
//`define		defaultPeriod	30'b000001011111010111100001000000	//	25 10^6 ~ 1s
`define		defaultPeriod	30'b000000000000010111110101111000


module AGameOfLife(input CLK_50M,
									 input [3:0] SW,

									 input ROT_A, // Knob
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


// Initial condition encoded as a bit string. 1 = alive, 0 = dead
wire [`L2-1:0] wb_initial_status = `L2'b1100000000000011010000000000001001010000000010100011000000001100000000000000000000000111111000000000000000000000001100000000110001010000000010100100000000000010110000000000001100000000000000000000000000000000000000000000000000000000000000000000000000000000;
wire [`L2-1:0] wb_status; // Current status


// Evolution clock of the simulation. It can be set with the switches
wire CLK_CA;
Module_FrequencyDivider	mod_fd(.clk_in(CLK_50M), .period(`defaultPeriod << SW),
															 .clk_out(CLK_CA));


always @ (posedge CLK_50M) begin
	// Useful syntax found, it is not essential at this stage of the projectf
	// but i wanted to keep it nevertheless
	// https://stackoverflow.com/questions/53457788/most-significant-bit-operand-in-part-select-of-vector-wire-is-illegal
	LED <= wb_status[ `L*SW[2:0]+:8];
end


wire w_set_state;
assign w_set_state = SW[3];

// Generate block:
//	It allows to parametrize the instatiation of module
// reference: https://www.chipverify.com/verilog/verilog-generate-block
genvar row;
generate
	for(row=0; row<`L; row=row+1) begin: gen_rows
		genvar col;
		// In future runs I may use non squared grids but then I would need to
		// implement a different way to compute division and modulus later.
		for(col=0; col<`L; col=col+1) begin: gen_col
			// Periodic boundary conditions
			CELLULAR_AUTOMATA ca(.qzt_clk(CLK_50M), .clk_in(CLK_CA),
													 .NW( wb_status[`L*( (row == `L-1) ? 0	 : row+1) + ( (col == `L-1) ?    0 : col+1)]),
										 		 	 	.N( wb_status[`L*( (row == `L-1) ? 0 	 : row+1) +    col]),
													 .NE( wb_status[`L*( (row == `L-1) ? 0 	 : row+1) + ( (col ==    0) ? `L-1 : col-1)]),

										 		 	  .W( wb_status[`L*row 												 		+ ( (col == `L-1) ?    0 : col+1)]),
										 		 	  .E( wb_status[`L*row 														+ ( (col ==    0) ? `L-1 : col-1)]),

												 	 .SW( wb_status[`L*( (row == 0) 		? `L-1 : row-1) + ( (col == `L-1) ?    0 : col+1)]),
										 		 		.S( wb_status[`L*( (row == 0)		? `L-1 : row-1) +  col]),
													 .SE( wb_status[`L*( (row == 0) 		? `L-1 : row-1) + ( (col ==    0) ? `L-1 : col-1)]),

													 .set_state(w_set_state),
 							 						 .initial_state(wb_initial_status[`L*row + col]),

													 .state(wb_status[`L*row + col] ));
		end
	end
endgenerate




wire w_clock_25MHz,
		 data_enabled;

wire [9:0] wb_vga_x, wb_vga_y;

VGA_CLOCK_480p VGA_clock(.clk_in(CLK_50M),
												 .clk_out(w_clock_25MHz));

VGA_DRIVER_480p vga_driver(.clk_vga(w_clock_25MHz),// pixel clock
		    									 .rst(0),       		 		 // reset

													 .sx(wb_vga_x),  			   // horizontal screen position
													 .sy(wb_vga_y),  				 // vertical screen position
													 .hsync(VGA_HSYNC),      // horizontal sync
													 .vsync(VGA_VSYNC),      // vertical sync
													 .de(data_enabled) );    // data enable (low in blanking interval)



always @(posedge w_clock_25MHz) begin
	// wb_status[`L*row + col]

	if( (wb_status[`L2 - (`L*( (wb_vga_y >> wb_zoom ) % `L) + ( (wb_vga_x >> wb_zoom) % `L)) ] == 1'b1) & (wb_vga_x<479) ) begin
		VGA_B[3:0] <= (data_enabled) ?  4'b0001 : 4'b0000;
		VGA_R[3:0] <= (data_enabled) ?  4'b0001 : 4'b0000;
		VGA_G[3:0] <= (data_enabled) ?  4'b0001 : 4'b0000;

	end else begin if( (wb_vga_x[wb_zoom] ^ wb_vga_y[wb_zoom]) & (wb_vga_x<479)) begin
			// Background squares gray
			VGA_B[3:0] <= (data_enabled) ?  4'b1100 : 4'b0000;
			VGA_R[3:0] <= (data_enabled) ?  4'b1100 : 4'b0000;
			VGA_G[3:0] <= (data_enabled) ?  4'b1100 : 4'b0000;

		end else if( ~(wb_vga_x[wb_zoom] ^ wb_vga_y[wb_zoom]) & (wb_vga_x<479)) begin
			// Background squares white
			VGA_B[3:0] <= (data_enabled) ?  4'b1111 : 4'b0000;
			VGA_R[3:0] <= (data_enabled) ?  4'b1111 : 4'b0000;
			VGA_G[3:0] <= (data_enabled) ?  4'b1111 : 4'b0000;

		end else begin
			// The rest should be black
			VGA_B[3:0] <= 4'b0000;
			VGA_R[3:0] <= 4'b0000;
			VGA_G[3:0] <= 4'b0000;
		end
	end

end


endmodule
