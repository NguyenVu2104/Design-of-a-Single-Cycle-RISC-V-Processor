module single_cycle(
	input	logic			i_clk,
	input	logic			i_reset,
	input	logic	[31:0]	i_io_sw,
	output	logic	[31:0]	o_io_lcd,
	output	logic	[31:0]	o_io_ledg,
	output	logic	[31:0]	o_io_ledr,
	output	logic	[6:0]	o_io_hex0,
	output	logic	[6:0]	o_io_hex1,
	output	logic	[6:0]	o_io_hex2,
	output	logic	[6:0]	o_io_hex3,
	output	logic	[6:0]	o_io_hex4,
	output	logic	[6:0]	o_io_hex5,
	output	logic	[6:0]	o_io_hex6,
	output	logic	[6:0]	o_io_hex7,
	output	logic	[31:0]	o_pc_debug,
	output	logic		o_insn_vld
);

	//PC wires
	logic [31:0] pc1, pc4;
	logic [31:0] pc_next;

	//IMEM wire
	logic [31:0] instr;

	//Regfile wires
	logic [31:0] rs1_data, rs2_data;

	//Immediate generator wire
	logic [31:0] imm;

	//ALU wire
	logic [31:0] operand_a, operand_b, alu_data;

	//LSU wires
	logic [31:0] ld_data;

	//WBMUX wire
	logic [31:0] wb_data;

	//Control unit wires
	logic br_less, br_equal, rd_wren, br_unsigned, opa_sel, opb_sel, mem_wren, u, insn_vld, pc_sel;
	logic [1:0] wb_sel;
	logic [3:0] alu_op, bmask;

	//Module zone
	// PC
	
	pc prg_cnt(
		i_clk,
		i_reset,
		pc_next,		// Modified here
		pc1
	);

	pc4 prg_cnt_4(
		pc1,
		pc4
	);

	pc_debug prg_cnt_debug(
		i_clk,
		i_reset,
		pc1,
		o_pc_debug
	);

	imem ins_mem(
		pc1,
		instr
	);

	regfile regs(
		i_clk, 
		i_reset, 
		instr[19:15], 
		instr[24:20], 
		rs1_data, 
		rs2_data, 
		instr[11:7], 
		wb_data, 
		rd_wren
	);

	immgen imm_gen(
		instr,
		imm
	);

	brc branch(
		rs1_data,
		rs2_data,
		br_unsigned, 
		br_less, 
		br_equal
	);

	alu arithmetic_logic_unit(
		operand_a, 
		operand_b, 
		alu_op, 
		alu_data
	);

	lsu load_store_unit(
		.i_clk(i_clk), 
		.i_reset(i_reset), 
		.i_lsu_addr(alu_data), 
		.i_st_data(rs2_data), 
		.i_lsu_wren(mem_wren), 
		.i_bmask(bmask), 
		.i_u(u), 
		.i_io_sw(i_io_sw), 
		.o_ld_data(ld_data), 
		.o_io_lcd(o_io_lcd), 
		.o_io_ledr(o_io_ledr), 
		.o_io_ledg(o_io_ledg), 
		.o_io_hex0(o_io_hex0), 
		.o_io_hex1(o_io_hex1), 
		.o_io_hex2(o_io_hex2), 
		.o_io_hex3(o_io_hex3), 
		.o_io_hex4(o_io_hex4), 
		.o_io_hex5(o_io_hex5), 
		.o_io_hex6(o_io_hex6), 
		.o_io_hex7(o_io_hex7)
	);

	control_unit ctrl_u(
		instr,
		br_less,
		br_equal,
		pc_sel,
		rd_wren,
		insn_vld,
		br_unsigned,
		opa_sel,
		opb_sel,
		mem_wren,
		wb_sel,
		alu_op,
		bmask,
		u
	);
	
	insn_vld instruction_valid(
		i_clk,
		insn_vld,
		o_insn_vld
	);
	
	pc_sel prg_cnt_sel(
		pc_sel,
		alu_data,
		pc4,
		pc_next
	);

	always_comb begin
		//ALU operand sel
		case(opa_sel)
			1'd1: operand_a = pc1;
			default: operand_a = rs1_data;
		endcase

		case(opb_sel)
			1'd1: operand_b = imm;
			default: operand_b = rs2_data;
		endcase

		//Write back mux
		case(wb_sel)
			2'd0: wb_data = ld_data;
			2'd2: wb_data = pc1 + 32'd4;
			default: wb_data = alu_data;
		endcase
	end

endmodule
