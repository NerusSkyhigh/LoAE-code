module AGameOfLife(input CLK_50M,
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
