// Regfile

module regfile (
	input	logic			i_clk,
	input	logic			i_reset,
	input	logic	[4:0]	i_rs1_addr,
	input	logic	[4:0]	i_rs2_addr,
	output	logic	[31:0]	o_rs1_data,
	output	logic	[31:0]	o_rs2_data,
	input	logic	[4:0]	i_rd_addr,
	input	logic	[31:0]	i_rd_data,
	input	logic			i_rd_wren
);

	logic [31:0] reg_array [0:31];

	// READ
	assign o_rs1_data = (i_rs1_addr == 5'd0) ? 32'b0 : reg_array[i_rs1_addr];
	assign o_rs2_data = (i_rs2_addr == 5'd0) ? 32'b0 : reg_array[i_rs2_addr];

	// WRITE
	always_ff @(posedge i_clk or negedge i_reset) begin
		if (!i_reset) begin
			reg_array <= '{default:32'd0};
		end else begin
			if (i_rd_wren && (i_rd_addr != 5'd0)) begin
				reg_array[i_rd_addr] <= i_rd_data;
			end
		end
	end

endmodule
