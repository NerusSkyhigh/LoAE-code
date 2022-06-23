/*
 * The FPGA has a 50 MHz base clock
 * The VGA standard for 640x480@60fps expects a 25.2MHz+-0.5% clock
 *				25.2MHz * 0.5% = 0.125 MHz
 *
 * This would imply that a 25 MHz clock would not be compatible with
 * the standard, but my monitor seems to accept it anyway. This may
 * be a source of error if I change monitor.
 */
module	VGA_CLOCK_480p(input clk_in,

											 output reg clk_out);
  // This is just a frequency halver
	always @(posedge clk_in) begin
			clk_out <= ~clk_out;
	end
endmodule


// Readapted from https://projectf.io/posts/fpga-graphics/
module VGA_DRIVER_480p(input  wire clk_vga,   // pixel clock
    							     input  wire rst,       // reset

        					 		 output reg [9:0] sx,  // horizontal screen position
        					 		 output reg [9:0] sy,  // vertical screen position
        					 		 output reg hsync,     // horizontal sync
        					 		 output reg vsync,     // vertical sync
        					 		 output reg de);        // data enable (low in blanking interval)


    // horizontal timings
    parameter HA_END = 639;           // end of active pixels
    parameter HS_STA = HA_END + 16;   // sync starts after front porch
    parameter HS_END = HS_STA + 96;   // sync ends
    parameter LINE   = 799;           // last pixel on line (after back porch)

    // vertical timings
    parameter VA_END = 479;           // end of active pixels
    parameter VS_STA = VA_END + 10;   // sync starts after front porch
    parameter VS_END = VS_STA + 2;    // sync ends
    parameter SCREEN = 524;           // last line on screen (after back porch)

    always @(*) begin
        hsync = ~(sx >= HS_STA && sx < HS_END);  // invert: negative polarity
        vsync = ~(sy >= VS_STA && sy < VS_END);  // invert: negative polarity
        de = (sx <= HA_END && sy <= VA_END);
    end

    // calculate horizontal and vertical screen position
    always @(posedge clk_vga) begin
        if (sx == LINE) begin  // last pixel on line?
            sx <= 0;
            sy <= (sy == SCREEN) ? 0 : sy + 1;  // last line on screen?
        end else begin
            sx <= sx + 1;
        end
        if (rst) begin
            sx <= 0;
            sy <= 0;
        end
    end
endmodule


/*
 *
 */
`define	decay 	28'b0011110100001001000000000000	//	1280 ms
module VGA_ZOOM_KNOB(input clk_in,
										 input ROT_A,
										 input ROT_B,

										 output reg[2:0] zoom
	);


wire w_wait;
reg active = 1;

Module_Monostable	ms_timer( .clk_in(clk_in),
														.monostable_input(~active),
														.N(`decay),

														.monostable_output(w_wait));


always @ (posedge clk_in) begin
	if(active & ROT_A & ~ROT_B ) begin // Clockwise
		if(zoom < 3'b111) begin
			// This is a nested if to avoid bounces at maximum
			// and minimum zoom.
			zoom <= zoom + 1;
		end
		active <= 0;

	end else if(active & ~ROT_A & ROT_B ) begin
		if( zoom > 3'b000) begin
			zoom <= zoom - 1;
		end
		active <= 0;

	end else if(w_wait == 0) begin
		active <= 1;
	end

end

endmodule
