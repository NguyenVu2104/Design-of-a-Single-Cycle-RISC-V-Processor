module shift_right(
	input 	logic	[31:0]	i_op_a, i_op_b,
	input 	logic	[3:0] 	i_alu_op,
	output	logic	[31:0]	o_shift_right
);

	logic [31:0] sign_extend, shift_right_1, shift_right_2, shift_right_4, shift_right_8;

	always_comb begin
		case ({i_op_a[31], i_alu_op})
		5'b1_1001: sign_extend = 32'hFFFFFFFF;
		default: sign_extend = 32'b0;
		endcase

		case (i_op_b[0])
			1'b1: shift_right_1 = {sign_extend[31], i_op_a[31:1]};
			default: shift_right_1 = i_op_a;
		endcase

		case (i_op_b[1])
			1'b1: shift_right_2 = {sign_extend[31:30], shift_right_1[31:2]};
			default: shift_right_2 = shift_right_1;
		endcase

		case (i_op_b[2])
			1'b1: shift_right_4 = {sign_extend[31:28], shift_right_2[31:4]};
			default: shift_right_4 = shift_right_2;
		endcase

		case (i_op_b[3])
			1'b1: shift_right_8 = {sign_extend[31:24], shift_right_4[31:8]};
			default: shift_right_8 = shift_right_4;
		endcase

		case (i_op_b[4])
			1'b1: o_shift_right = {sign_extend[31:16], shift_right_8[31:16]};
			default: o_shift_right = shift_right_8;
		endcase
	end
	
endmodule
