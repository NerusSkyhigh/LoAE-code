module waveformGenerator	(	CLK_50M,
			SPI_SCK, SPI_MOSI, DAC_CS, DAC_CLR
			);

input		CLK_50M;
input[3:0] SW;

output		SPI_SCK;
output		SPI_MOSI;
output		DAC_CS;
output		DAC_CLR;

wire		w_clock;

wire	[11:0]	wb_Va;
wire	[11:0]	wb_Vb;




Module_Counter_8_bit		SPI_SCK_generator	(	.clk_in(CLK_50M),
								.limit(30'd4),		// 4x20 ns = 80 ns <===> 50/4 MHz = 12.5 MHz

								.carry(SPI_SCK));

DAC_Driver			DAC_Driver		(	.CLK_50M(CLK_50M),
								.Va(wb_Va),.Vb(wb_Vb),
								.startEnable(1),

								.SPI_SCK(SPI_SCK),
								.SPI_MOSI(SPI_MOSI),
								.DAC_CS(DAC_CS),
								.DAC_CLR(DAC_CLR),
								.dacNumber(w_clock));


// Slower clock
`define		defaultPeriod	30'b000000000000000110000110101000 // 25 10^3

wire w_clock_1_kHz;
Module_FrequencyDivider	clock_1_kHz_generator(.clk_in(CLK_50M),
																						  .period(`defaultPeriod),

  																						.clk_out(w_clock_1_kHz));

// PSEUDORANDOM
reg[31:0] register = 32'd1;
reg old_clock_1_kHz;

always @(posedge CLK_50M) begin
	if(~old_clock_1_kHz & w_clock_1_kHz) begin
		register[31:1] <= register[30:0];
		register[0] <= (register[30] ^ register[27]);
	end

	old_clock_1_kHz <= w_clock_1_kHz;
end

assign wb_Va = wb_Vb;
assign wb_Vb = register[11:0];


endmodule





/*************************************************/
/*** Module_FrequencyDivider from chipstore.v ***/
/************************************************/
module	Module_FrequencyDivider	(input clk_in, input[29:0] period,
																 output reg clk_out);

	reg	[29:0]	counter;

	always @(posedge clk_in) begin
		if (counter >= (period - 1)) begin
			counter <= 0;
			clk_out <= ~clk_out;
		end else
			counter <= counter + 1;
	end

endmodule
