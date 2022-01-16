/********************
 *	Reference_Lines	*
 ********************
 * This test will print the diagonal of the square 480x480,
 * a line on the first pixel (both horizontal and vertical)
 * and a line on the pixel 479x479
 * NOTICE that due to the risetime of FF x=1 --> pixel=2
 */
module ReferenceLines(input CLK_50M,
									 	 input [3:0] SW,

									 	 output reg [3:0] VGA_R,
									 	 output reg [3:0] VGA_G,
									 	 output reg [3:0] VGA_B,
									 	 output VGA_HSYNC, // When to begin a new line
									 	 output VGA_VSYNC, // When to move on the right
									 	 output reg [3:0] LED
									   );

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
endmodule



/****************
 *	WHITE_GRID	*
 ****************
 * This test will print a grid on the screen.
 * The spacing of the grid is choosen via the
 * switches.
 * For some reason the pixels in the first column
 * are shifted by one pixel.
 */
module WHITE_GRID(input CLK_50M,
									 input [3:0] SW,

									 output reg [3:0] VGA_R,
									 output reg [3:0] VGA_G,
									 output reg [3:0] VGA_B,
									 output VGA_HSYNC, // When to begin a new line
									 output VGA_VSYNC, // When to move on the right
									 output reg [3:0] LED
									 );

	wire w_clock_25MHz,
			 data_enabled;

	VGA_CLOCK_480p VGA_clock(.clk_in(CLK_50M),
													 .clk_out(w_clock_25MHz));


	wire [9:0] w_vga_x, w_vga_y;
	reg [9:0] vga_x, vga_y;
	reg [3:0] counter_x, counter_y;


	always @(posedge w_clock_25MHz) begin
		LED[3:0] <= SW[3:0];

		// SW = 3'b100 is enough to be seen
		if(vga_x==0 | counter_x==SW) begin
			counter_x <= 0;
		end else begin
			counter_x <= counter_x+1;
		end

		if(vga_x == 0) begin
			if(vga_y==0 | counter_y== SW) begin
				counter_y <= 0;
			end else begin
				counter_y <= counter_y+1;
			end
		end


		// Actual DRAW
		if( counter_x == SW || counter_y == SW) begin
			VGA_B[3:0] <= (data_enabled) ?  4'b1111 : 4'b0000;
			VGA_R[3:0] <= (data_enabled) ?  4'b1111 : 4'b0000;
			VGA_G[3:0] <= (data_enabled) ?  4'b1111 : 4'b0000;
		end else begin
			VGA_B[3:0] <= 4'b0000;
			VGA_R[3:0] <= 4'b0000;
			VGA_G[3:0] <= 4'b0000;
		end

		vga_x <= w_vga_x;
		vga_y <= w_vga_y;
	end


	VGA_DRIVER_480p vga_driver(.clk_vga(w_clock_25MHz),// pixel clock
			    									 .rst(0),       		 // reset

														 .sx(w_vga_x),  			   // horizontal screen position
														 .sy(w_vga_y),  				 // vertical screen position
														 .hsync(VGA_HSYNC),      // horizontal sync
														 .vsync(VGA_VSYNC),      // vertical sync
														 .de(data_enabled) );    // data enable (low in blanking interval)
endmodule



/****************
 *	RGB_SCREEN	*
 ****************
 * This test colors the whole screen in a single
 * color:
 *		SW[3] --> RED
 *		SW[2] --> GREEN
 *		SW[1] --> BLUE
 *		SW[0] --> Reset screen
 * 							(This flag is supposed to reset the driver but a Human can NOT
 *							 be that fast. For any practical purpose this is a on/off switch)
 */
module RGB_SCREEN(input CLK_50M,
									input [3:0] SW,

									output reg [3:0] VGA_R,
									output reg [3:0] VGA_G,
									output reg [3:0] VGA_B,
									output VGA_HSYNC, // When to begin a new line
									output VGA_VSYNC, // When to move on the right
									output reg [3:0] LED
								);

	wire w_clock_25MHz,
			 data_enabled;

	always @(posedge w_clock_25MHz) begin
		// For some reason, if I do not include the data_enabled flag, the driver does
		// not work. My hypothesis is that at the end of each line the screen resets
		// the "ground level" of the signal and therefore sees every color as off.
		VGA_R[3:0] <= (data_enabled & SW[3] & 0) ?  4'b1111 : 4'b0000;
		VGA_G[3:0] <= (data_enabled & SW[2] & 0) ?  4'b1111 : 4'b0000;
		VGA_B[3:0] <= (data_enabled & SW[1]) ?  4'b1111 : 4'b0000;
		LED[3:0]   <= SW[3:0];

	end


	VGA_DRIVER_480p vga_driver(.clk_vga(w_clock_25MHz),// pixel clock
			    									 .rst(SW[0]),       		 // reset

														 .sx(w_vga_x),  			   // horizontal screen position
														 .sy(w_vga_y),  				 // vertical screen position
														 .hsync(VGA_HSYNC),      // horizontal sync
														 .vsync(VGA_VSYNC),      // vertical sync
														 .de(data_enabled) );    // data enable (low in blanking interval)
endmodule
