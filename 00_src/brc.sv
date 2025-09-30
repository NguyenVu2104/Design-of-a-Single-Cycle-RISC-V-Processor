// Branch

module brc(
	input 	logic	[31:0]	i_rs1_data,
	input 	logic	[31:0]	i_rs2_data,
	input 	logic	      	i_br_un,    //1 = signed, 0 = unsigned
	output	logic	      	o_br_less,
	output	logic	      	o_br_equal
);

	logic [32:0] sub;

	assign sub = {1'b0, i_rs1_data} + {1'b0, ~i_rs2_data} + 1;
	assign o_br_equal = (i_rs1_data == i_rs2_data);

	always_comb begin
		case (i_br_un)
			1'b1: o_br_less = (i_rs1_data[31] == i_rs2_data[31]) ? sub[31] : i_rs1_data[31]; // condition in case of overflow
			1'b0: o_br_less = ~sub[32];
			default: o_br_less = 1'b0;
		endcase
	end

endmodule
