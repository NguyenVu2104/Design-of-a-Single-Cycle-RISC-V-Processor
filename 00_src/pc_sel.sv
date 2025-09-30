module pc_sel(
	input logic pc_sel,
	input logic [31:0] alu_data, pc4,
	output logic [31:0] pc_next
);
assign pc_next = (pc_sel)? alu_data : pc4;
endmodule
