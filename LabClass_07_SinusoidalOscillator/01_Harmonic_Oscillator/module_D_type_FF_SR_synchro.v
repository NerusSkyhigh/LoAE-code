module	Module_D_type_FF_SR_Synchro	(	qzt_clk,
						clk_in,
						D,
						R,
						S,

						Q);

input		qzt_clk;
input		clk_in;
input		D;
input		S;
input		R;

output		Q;

reg		Q;

reg		clk_in_old;


always @(posedge qzt_clk) begin
	if (R)
		Q = 0;
	else if (S)
		Q = 1;
	else if (!clk_in_old & clk_in)
		Q = D;

	clk_in_old = clk_in;
end

endmodule
