/****************************************/
/*** Module_Monostable_Multivibrator  ***/
/****************************************/

module	Monostable_Multivibrator(	clk_ms, // master clock
					clk_sl,
					pressed,

					out);

input		clk_ms; // Master clock used to sync
input 		clk_sl; // Slower clock
input		pressed;


output		out;


reg		pressed; // This variable check if the button is pressed
reg		state;
reg		clk_sl_old; // Check if the slower clock has changed state

reg		state

always @(posedge clk_ms) begin

	// Se viene premuto e prima non lo era
	if( (!clk_sl_old & clk_sl) & !state) begin
		out <= 1;
		state = 1
	end else if () begin
	
	
	clk_sl_old <= clk_sl;
end

endmodule



/*******************************/
/*** Module_Toggle_FlipFlop  ***/
/*******************************/

module	Module_Toggle_FlipFlop	(	clk_ms, // master clock
					clk_sl,

					state);

input		clk_ms; // Master clock used to sync
input 		clk_sl; // Slower clock


output		state;


reg		state;
reg		clk_sl_old; // Check if the slower clock has changed state

always @(posedge clk_ms) begin
	if( !clk_sl_old & clk_sl ) begin
		state <= ~state;
	end
	
	clk_sl_old <= clk_sl;
end

endmodule
