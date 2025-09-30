module shift_left(
	input 	logic	[31:0]	i_op_a,
	input 	logic	[31:0]	i_op_b,
	output	logic	[31:0]	o_shift_left
);

	logic [31:0] shift_left_1, shift_left_2, shift_left_4, shift_left_8;

	always_comb begin
		case (i_op_b[0])
			1'b1: shift_left_1 = {i_op_a[30:0], 1'b0};
			default: shift_left_1 = i_op_a;
		endcase

		case (i_op_b[1])
			1'b1: shift_left_2 = {shift_left_1[29:0], 2'b00};
			default: shift_left_2 = shift_left_1;
		endcase

		case (i_op_b[2])
			1'b1: shift_left_4 = {shift_left_2[27:0], 4'b0000};
			default: shift_left_4 = shift_left_2;
		endcase

		case (i_op_b[3])
			1'b1: shift_left_8 = {shift_left_4[23:0], 8'b00000000};
			default: shift_left_8 = shift_left_4;
		endcase

		case (i_op_b[4])
			1'b1: o_shift_left = {shift_left_8[15:0], 16'b0000000000000000};
			default: o_shift_left = shift_left_8;
		endcase
	end
	
endmodule
