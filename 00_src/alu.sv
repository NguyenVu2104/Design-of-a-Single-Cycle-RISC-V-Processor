// ALU

module alu(
  input 	logic	[31:0]	i_op_a,
  input 	logic	[31:0]	i_op_b,
  input 	logic	[3:0] 	i_alu_op,
  output	logic	[31:0]	o_alu_data
);

	logic [31:0] ADD, AND, OR, XOR, SLT, SLTU, SLL, SRL, SRA;
	logic [32:0] SUB;
	logic [31:0] shift_left, shift_right;

	assign ADD  = i_op_a + i_op_b;
	assign SUB  = {1'b0, i_op_a} + {1'b0, ~i_op_b} + 33'h1;	// 33-bit for carry-out
	assign AND  = i_op_a & i_op_b;
	assign OR   = i_op_a | i_op_b;
	assign XOR  = (i_op_a & ~i_op_b) | (~i_op_a & i_op_b);
	assign SLT  = (i_op_a[31] == i_op_b[31]) ? {31'b0, SUB[31]} : {31'b0, i_op_a[31]}; // use signed bit 
	assign SLTU = {31'b0, ~SUB[32]}; // unsigned: no carry-out means a < b
	assign SLL  = shift_left;
	assign SRL  = shift_right;
	assign SRA  = shift_right;

	shift_left SL(
		.i_op_a(i_op_a),
		.i_op_b(i_op_b),
		.o_shift_left(shift_left)
	);

	shift_right SR(
		.i_alu_op(i_alu_op),
		.i_op_a(i_op_a),
		.i_op_b(i_op_b),
		.o_shift_right(shift_right)
	);

	always_comb begin
		case (i_alu_op)
			4'b0000: o_alu_data = ADD;
			4'b0001: o_alu_data = SUB[31:0];
			4'b0010: o_alu_data = SLT;
			4'b0011: o_alu_data = SLTU;
			4'b0100: o_alu_data = XOR;
			4'b0101: o_alu_data = OR;
			4'b0110: o_alu_data = AND;
			4'b0111: o_alu_data = SLL;
			4'b1000: o_alu_data = SRL;
			4'b1001: o_alu_data = SRA;
			default: o_alu_data = 32'b0;
		endcase
	end

endmodule

// module shift_left(
	// input 	logic	[31:0]	i_op_a,
	// input 	logic	[31:0]	i_op_b,
	// output	logic	[31:0]	o_shift_left
// );

	// logic [31:0] shift_left_1, shift_left_2, shift_left_4, shift_left_8;

	// always_comb begin
		// case (i_op_b[0])
			// 1'b1: shift_left_1 = {i_op_a[30:0], 1'b0};
			// default: shift_left_1 = i_op_a;
		// endcase

		// case (i_op_b[1])
			// 1'b1: shift_left_2 = {shift_left_1[29:0], 2'b00};
			// default: shift_left_2 = shift_left_1;
		// endcase

		// case (i_op_b[2])
			// 1'b1: shift_left_4 = {shift_left_2[27:0], 4'b0000};
			// default: shift_left_4 = shift_left_2;
		// endcase

		// case (i_op_b[3])
			// 1'b1: shift_left_8 = {shift_left_4[23:0], 8'b00000000};
			// default: shift_left_8 = shift_left_4;
		// endcase

		// case (i_op_b[4])
			// 1'b1: o_shift_left = {shift_left_8[15:0], 16'b0000000000000000};
			// default: o_shift_left = shift_left_8;
		// endcase
	// end
	
// endmodule

// module shift_right(
	// input 	logic	[31:0]	i_op_a, i_op_b,
	// input 	logic	[3:0] 	i_alu_op,
	// output	logic	[31:0]	o_shift_right
// );

	// logic [31:0] sign_extend, shift_right_1, shift_right_2, shift_right_4, shift_right_8;

	// always_comb begin
		// case ({i_op_a[31], i_alu_op})
		// 5'b1_1001: sign_extend = 32'hFFFFFFFF;
		// default: sign_extend = 32'b0;
		// endcase

		// case (i_op_b[0])
			// 1'b1: shift_right_1 = {sign_extend[31], i_op_a[31:1]};
			// default: shift_right_1 = i_op_a;
		// endcase

		// case (i_op_b[1])
			// 1'b1: shift_right_2 = {sign_extend[31:30], shift_right_1[31:2]};
			// default: shift_right_2 = shift_right_1;
		// endcase

		// case (i_op_b[2])
			// 1'b1: shift_right_4 = {sign_extend[31:28], shift_right_2[31:4]};
			// default: shift_right_4 = shift_right_2;
		// endcase

		// case (i_op_b[3])
			// 1'b1: shift_right_8 = {sign_extend[31:24], shift_right_4[31:8]};
			// default: shift_right_8 = shift_right_4;
		// endcase

		// case (i_op_b[4])
			// 1'b1: o_shift_right = {sign_extend[31:16], shift_right_8[31:16]};
			// default: o_shift_right = shift_right_8;
		// endcase
	// end
	
// endmodule
