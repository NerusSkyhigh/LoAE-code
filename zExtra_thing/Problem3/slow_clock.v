module	Module_Slower_Clock	(	clk_in,

					active);
					
					
input		clk_in;

output		active;

reg		active;



always @(posedge clk_in) begin
	active = 1;
end

endmodule
