// PC

module pc (
	input 	logic	      	i_clk,
	input 	logic	      	i_reset,
	input 	logic	[31:0]	pc_next,
	output	logic	[31:0]	pc
);

	logic [31:0] pc_reg;
	
	always_ff @(posedge i_clk or negedge i_reset) begin
		if (!i_reset)
	          pc_reg <= 32'h0;
		else pc_reg <= pc_next;
	end

	assign pc = pc_reg;

endmodule
