`timescale 1ns / 1ps

module tb_single_cycle;

    // Inputs
    logic        i_clk;
    logic        i_reset;
    logic [31:0] i_io_sw;

    // Outputs
    logic [31:0] o_io_lcd;
    logic [31:0] o_io_ledg;
    logic [31:0] o_io_ledr;
    logic [6:0]  o_io_hex0, o_io_hex1, o_io_hex2, o_io_hex3;
    logic [6:0]  o_io_hex4, o_io_hex5, o_io_hex6, o_io_hex7;
    logic [31:0] o_pc_debug;
    logic        o_insn_vld;



    // Instantiate the single_cycle CPU
    single_cycle dut (
        .i_clk(i_clk),
        .i_reset(i_reset),
        .i_io_sw(i_io_sw),
        .o_io_lcd(o_io_lcd),
        .o_io_ledg(o_io_ledg),
        .o_io_ledr(o_io_ledr),
        .o_io_hex0(o_io_hex0),
        .o_io_hex1(o_io_hex1),
        .o_io_hex2(o_io_hex2),
        .o_io_hex3(o_io_hex3),
        .o_io_hex4(o_io_hex4),
        .o_io_hex5(o_io_hex5),
        .o_io_hex6(o_io_hex6),
        .o_io_hex7(o_io_hex7),
        .o_pc_debug(o_pc_debug),
        .o_insn_vld(o_insn_vld)
    );

    // Clock generation (10ns period)
    initial begin
        i_clk = 0;
        forever #5 i_clk = ~i_clk;
    end

    // Reset and simulation control
    initial begin
        // Initialize signals
        i_reset = 0;
        i_io_sw = 32'h0;
        // Apply reset for one full clock cycle
        #15;
        i_reset = 1;

        // Skip initial instructions (addi), check PC after branch instructions
        #100000; // Skip 4 addi instructions (t=55End simulation
        $finish;
    end

    // Debug output at each clock edge
    always @(posedge i_clk) begin
        if (i_reset) begin
            $display("\n--- Cycle %0t ---", $time);
            $display("PC: %h | Instr: %h | Immediate: %h", dut.pc, dut.instr, dut.imm);
            $display("PC_debug: %h | Instruction Valid: %b", o_pc_debug, o_insn_vld);
            $display("Control Signals: pc_sel=%b, rd_wren=%b, o_insn_vld=%b, br_un=%b, opa_sel=%b, opb_sel=%b, mem_wren=%b, wb_sel=%b, alu_op=%b",
                     dut.pc_sel, dut.rd_wren, dut.o_insn_vld, dut.br_un, dut.opa_sel, dut.opb_sel, dut.mem_wren, dut.wb_sel, dut.alu_op);
            $display("Register File: rs1_addr=%d, rs2_addr=%d, rs1_data=%h, rs2_data=%h", dut.regs_inst.i_rs1_addr, dut.regs_inst.i_rs2_addr, dut.regs_inst.o_rs1_data, dut.regs_inst.o_rs2_data);
            $display("ALU Inputs: op_a=%h, op_b=%h | ALU Output: %h", dut.alu_op_a, dut.alu_op_b, dut.alu_data);
            $display("Branch Comparator: br_less=%b, br_equal=%b", dut.br_less, dut.br_equal);
            $display("LSU: ld_data=%h", dut.ld_data);
            $display("Registers: x1=%h, x2=%h, x3=%h, x4=%h, x5=%h, x6=%h, x7=%h, x8=%h, x9=%h, x10=%h, x11=%h, x12=%h, x13=%h, x14=%h, x15=%h, x16=%h, x17=%h, x18=%h, x19=%h, x20=%h, x21=%h, x22=%h, x23=%h, x24=%h, x25=%h, x26=%h, x27=%h, x28=%h, x29=%h, x30=%h, x31=%h, x32=%h",
                     dut.regs_inst.reg_array[1], dut.regs_inst.reg_array[2], dut.regs_inst.reg_array[3], dut.regs_inst.reg_array[4], 
                     dut.regs_inst.reg_array[5], dut.regs_inst.reg_array[6], dut.regs_inst.reg_array[7], dut.regs_inst.reg_array[8], 
                     dut.regs_inst.reg_array[9], dut.regs_inst.reg_array[10], dut.regs_inst.reg_array[11], dut.regs_inst.reg_array[12],
		     dut.regs_inst.reg_array[13], dut.regs_inst.reg_array[14], dut.regs_inst.reg_array[15], dut.regs_inst.reg_array[16],
		     dut.regs_inst.reg_array[17], dut.regs_inst.reg_array[18], dut.regs_inst.reg_array[19], dut.regs_inst.reg_array[20],
                     dut.regs_inst.reg_array[21], dut.regs_inst.reg_array[22], dut.regs_inst.reg_array[23], dut.regs_inst.reg_array[24],
                     dut.regs_inst.reg_array[25], dut.regs_inst.reg_array[26], dut.regs_inst.reg_array[27], dut.regs_inst.reg_array[28],
                     dut.regs_inst.reg_array[29], dut.regs_inst.reg_array[30], dut.regs_inst.reg_array[31], dut.regs_inst.reg_array[32]);
            end

    end

endmodule
