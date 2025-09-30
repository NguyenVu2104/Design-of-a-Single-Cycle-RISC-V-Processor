module pc4(
	input logic [31:0] pc,
	output logic [31:0] pc4
);

assign pc4 = 32'h4 + pc;
endmodule
