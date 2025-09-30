`timescale 1ps / 1ps

module control_unit_tb;

    // Inputs
    logic [31:0] instr;
    logic br_less;
    logic br_equal;

    // Outputs
    logic pc_sel;
    logic rd_wren;
    logic o_insn_vld;
    logic br_un;
    logic opa_sel;
    logic opb_sel;
    logic mem_wren;
    logic [1:0] wb_sel;
    logic [3:0] alu_op;
    logic [3:0] bmask;
    logic u;

    // Instantiate the control_unit module
    control_unit dut (
        .instr(instr),
        .br_less(br_less),
        .br_equal(br_equal),
        .pc_sel(pc_sel),
        .rd_wren(rd_wren),
        .o_insn_vld(o_insn_vld),
        .br_un(br_un),
        .opa_sel(opa_sel),
        .opb_sel(opb_sel),
        .mem_wren(mem_wren),
        .wb_sel(wb_sel),
        .alu_op(alu_op),
        .bmask(bmask),
        .u(u)
    );

    // Test variables
    integer test_count = 0;
    integer pass_count = 0;

    // Task to check outputs
    task check_outputs;
        input logic exp_pc_sel;
        input logic exp_rd_wren;
        input logic exp_o_insn_vld;
        input logic exp_br_un;
        input logic exp_opa_sel;
        input logic exp_opb_sel;
        input logic exp_mem_wren;
        input logic [1:0] exp_wb_sel;
        input logic [3:0] exp_alu_op;
        input logic [3:0] exp_bmask;
        input logic exp_u;
        input string test_name;

        begin
            #1; // Wait for outputs to settle
            test_count = test_count + 1;
            $display("Test %0d: %s", test_count, test_name);
            $display("  Inputs: instr=0x%h, br_less=%b, br_equal=%b", instr, br_less, br_equal);
            $display("  Outputs: pc_sel=%b, rd_wren=%b, o_insn_vld=%b, br_un=%b, opa_sel=%b, opb_sel=%b, mem_wren=%b, wb_sel=%b, alu_op=%h, bmask=%b, u=%b",
                     pc_sel, rd_wren, o_insn_vld, br_un, opa_sel, opb_sel, mem_wren, wb_sel, alu_op, bmask, u);

            if (pc_sel === exp_pc_sel &&
                rd_wren === exp_rd_wren &&
                o_insn_vld === exp_o_insn_vld &&
                br_un === exp_br_un &&
                opa_sel === exp_opa_sel &&
                opb_sel === exp_opb_sel &&
                mem_wren === exp_mem_wren &&
                wb_sel === exp_wb_sel &&
                alu_op === exp_alu_op &&
                bmask === exp_bmask &&
                u === exp_u) begin
                $display("  PASS: Outputs match expected values");
                pass_count = pass_count + 1;
            end else begin
                $display("  FAIL: Expected pc_sel=%b, rd_wren=%b, o_insn_vld=%b, br_un=%b, opa_sel=%b, opb_sel=%b, mem_wren=%b, wb_sel=%b, alu_op=%h, bmask=%b, u=%b",
                         exp_pc_sel, exp_rd_wren, exp_o_insn_vld, exp_br_un, exp_opa_sel, exp_opb_sel, exp_mem_wren, exp_wb_sel, exp_alu_op, exp_bmask, exp_u);
            end
            $display("");
        end
    endtask

    // Initial block for test stimulus
    initial begin
        // Initialize inputs
        instr = 32'h0;
        br_less = 1'b0;
        br_equal = 1'b0;

        // Wait for a few cycles
        #10;

        // Test 1: R-type - ADD (funct3=000, funct7[5]=0)
        instr = 32'h00000033; // ADD x0, x0, x0
        br_less = 1'b0;
        br_equal = 1'b0;
        check_outputs(
            1'b0,        // pc_sel: PC+4
            1'b1,        // rd_wren: Enable
            1'b1,        // o_insn_vld: Valid
            1'b0,        // br_un: Not used
            1'b0,        // opa_sel: rs1_data
            1'b0,        // opb_sel: rs2_data
            1'b0,        // mem_wren: Disable
            2'b01,       // wb_sel: alu_data
            4'b0000,     // alu_op: ADD
            4'b0000,     // bmask: No memory access
            1'b0,        // u: Not used
            "R-type ADD"
        );

        // Test 2: R-type - SUB (funct3=000, funct7[5]=1)
        instr = 32'h40000033; // SUB x0, x0, x0
        check_outputs(
            1'b0,        // pc_sel: PC+4
            1'b1,        // rd_wren: Enable
            1'b1,        // o_insn_vld: Valid
            1'b0,        // br_un: Not used
            1'b0,        // opa_sel: rs1_data
            1'b0,        // opb_sel: rs2_data
            1'b0,        // mem_wren: Disable
            2'b01,       // wb_sel: alu_data
            4'b0001,     // alu_op: SUB
            4'b0000,     // bmask: No memory access
            1'b0,        // u: Not used
            "R-type SUB"
        );

        // Test 3: I-type - ADDI (funct3=000)
        instr = 32'h00000013; // ADDI x0, x0, 0
        check_outputs(
            1'b0,        // pc_sel: PC+4
            1'b1,        // rd_wren: Enable
            1'b1,        // o_insn_vld: Valid
            1'b0,        // br_un: Not used
            1'b0,        // opa_sel: rs1_data
            1'b1,        // opb_sel: imm
            1'b0,        // mem_wren: Disable
            2'b01,       // wb_sel: alu_data
            4'b0000,     // alu_op: ADD
            4'b0000,     // bmask: No memory access
            1'b0,        // u: Not used
            "I-type ADDI"
        );

        // Test 4: Load - LB (funct3=000)
        instr = 32'h00000003; // LB x0, 0(x0)
        check_outputs(
            1'b0,        // pc_sel: PC+4
            1'b1,        // rd_wren: Enable
            1'b1,        // o_insn_vld: Valid
            1'b0,        // br_un: Not used
            1'b0,        // opa_sel: rs1_data
            1'b1,        // opb_sel: imm
            1'b0,        // mem_wren: Disable
            2'b00,       // wb_sel: ld_data
            4'b0000,     // alu_op: ADD
            4'b0001,     // bmask: Load byte
            1'b0,        // u: Sign-extend
            "Load LB"
        );

        // Test 5: Load - LH (funct3=001)
        instr = 32'h00001003; // LH x0, 0(x0)
        check_outputs(
            1'b0,        // pc_sel: PC+4
            1'b1,        // rd_wren: Enable
            1'b1,        // o_insn_vld: Valid
            1'b0,        // br_un: Not used
            1'b0,        // opa_sel: rs1_data
            1'b1,        // opb_sel: imm
            1'b0,        // mem_wren: Disable
            2'b00,       // wb_sel: ld_data
            4'b0000,     // alu_op: ADD
            4'b0011,     // bmask: Load halfword
            1'b0,        // u: Sign-extend
            "Load LH"
        );

        // Test 6: Load - LW (funct3=010)
        instr = 32'h00002003; // LW x0, 0(x0)
        check_outputs(
            1'b0,        // pc_sel: PC+4
            1'b1,        // rd_wren: Enable
            1'b1,        // o_insn_vld: Valid
            1'b0,        // br_un: Not used
            1'b0,        // opa_sel: rs1_data
            1'b1,        // opb_sel: imm
            1'b0,        // mem_wren: Disable
            2'b00,       // wb_sel: ld_data
            4'b0000,     // alu_op: ADD
            4'b1111,     // bmask: Load word
            1'b0,        // u: Not used
            "Load LW"
        );

        // Test 7: Load - LBU (funct3=100)
        instr = 32'h00004003; // LBU x0, 0(x0)
        check_outputs(
            1'b0,        // pc_sel: PC+4
            1'b1,        // rd_wren: Enable
            1'b1,        // o_insn_vld: Valid
            1'b0,        // br_un: Not used
            1'b0,        // opa_sel: rs1_data
            1'b1,        // opb_sel: imm
            1'b0,        // mem_wren: Disable
            2'b00,       // wb_sel: ld_data
            4'b0000,     // alu_op: ADD
            4'b0001,     // bmask: Load byte
            1'b1,        // u: Zero-extend
            "Load LBU"
        );

        // Test 8: Load - LHU (funct3=101)
        instr = 32'h00005003; // LHU x0, 0(x0)
        check_outputs(
            1'b0,        // pc_sel: PC+4
            1'b1,        // rd_wren: Enable
            1'b1,        // o_insn_vld: Valid
            1'b0,        // br_un: Not used
            1'b0,        // opa_sel: rs1_data
            1'b1,        // opb_sel: imm
            1'b0,        // mem_wren: Disable
            2'b00,       // wb_sel: ld_data
            4'b0000,     // alu_op: ADD
            4'b0011,     // bmask: Load halfword
            1'b1,        // u: Zero-extend
            "Load LHU"
        );

        // Test 9: Store - SB (funct3=000)
        instr = 32'h00000023; // SB x0, 0(x0)
        check_outputs(
            1'b0,        // pc_sel: PC+4
            1'b0,        // rd_wren: Disable
            1'b1,        // o_insn_vld: Valid
            1'b0,        // br_un: Not used
            1'b0,        // opa_sel: rs1_data
            1'b1,        // opb_sel: imm
            1'b1,        // mem_wren: Enable
            2'b00,       // wb_sel: Not used
            4'b0000,     // alu_op: ADD
            4'b0001,     // bmask: Store byte
            1'b0,        // u: Not used
            "Store SB"
        );

        // Test 10: Store - SH (funct3=001)
        instr = 32'h00001023; // SH x0, 0(x0)
        check_outputs(
            1'b0,        // pc_sel: PC+4
            1'b0,        // rd_wren: Disable
            1'b1,        // o_insn_vld: Valid
            1'b0,        // br_un: Not used
            1'b0,        // opa_sel: rs1_data
            1'b1,        // opb_sel: imm
            1'b1,        // mem_wren: Enable
            2'b00,       // wb_sel: Not used
            4'b0000,     // alu_op: ADD
            4'b0011,     // bmask: Store halfword
            1'b0,        // u: Not used
            "Store SH"
        );

        // Test 11: Store - SW (funct3=010)
        instr = 32'h00002023; // SW x0, 0(x0)
        check_outputs(
            1'b0,        // pc_sel: PC+4
            1'b0,        // rd_wren: Disable
            1'b1,        // o_insn_vld: Valid
            1'b0,        // br_un: Not used
            1'b0,        // opa_sel: rs1_data
            1'b1,        // opb_sel: imm
            1'b1,        // mem_wren: Enable
            2'b00,       // wb_sel: Not used
            4'b0000,     // alu_op: ADD
            4'b1111,     // bmask: Store word
            1'b0,        // u: Not used
            "Store SW"
        );

        // Test 12: Branch - BEQ (funct3=000, taken)
        instr = 32'h00000063; // BEQ x0, x0, 0
        br_less = 1'b0;
        br_equal = 1'b1;
        check_outputs(
            1'b1,        // pc_sel: PC+imm (branch taken)
            1'b0,        // rd_wren: Disable
            1'b1,        // o_insn_vld: Valid
            1'b0,        // br_un: Signed
            1'b1,        // opa_sel: pc
            1'b1,        // opb_sel: imm
            1'b0,        // mem_wren: Disable
            2'b00,       // wb_sel: Not used
            4'b0000,     // alu_op: ADD
            4'b0000,     // bmask: No memory access
            1'b0,        // u: Not used
            "Branch BEQ (taken)"
        );

        // Test 13: Branch - BEQ (funct3=000, not taken)
        instr = 32'h00000063; // BEQ x0, x0, 0
        br_less = 1'b0;
        br_equal = 1'b0;
        check_outputs(
            1'b0,        // pc_sel: PC+4 (branch not taken)
            1'b0,        // rd_wren: Disable
            1'b1,        // o_insn_vld: Valid
            1'b0,        // br_un: Signed
            1'b1,        // opa_sel: pc
            1'b1,        // opb_sel: imm
            1'b0,        // mem_wren: Disable
            2'b00,       // wb_sel: Not used
            4'b0000,     // alu_op: ADD
            4'b0000,     // bmask: No memory access
            1'b0,        // u: Not used
            "Branch BEQ (not taken)"
        );

        // Test 14: Branch - BLTU (funct3=110, taken)
        instr = 32'h00006063; // BLTU x0, x0, 0
        br_less = 1'b1;
        br_equal = 1'b0;
        check_outputs(
            1'b1,        // pc_sel: PC+imm (branch taken)
            1'b0,        // rd_wren: Disable
            1'b1,        // o_insn_vld: Valid
            1'b1,        // br_un: Unsigned
            1'b1,        // opa_sel: pc
            1'b1,        // opb_sel: imm
            1'b0,        // mem_wren: Disable
            2'b00,       // wb_sel: Not used
            4'b0000,     // alu_op: ADD
            4'b0000,     // bmask: No memory access
            1'b0,        // u: Not used
            "Branch BLTU (taken)"
        );

        // Test 15: Jump - JAL
        instr = 32'h0000006F; // JAL x0, 0
        check_outputs(
            1'b1,        // pc_sel: PC+imm
            1'b1,        // rd_wren: Enable
            1'b1,        // o_insn_vld: Valid
            1'b0,        // br_un: Not used
            1'b1,        // opa_sel: pc
            1'b1,        // opb_sel: imm
            1'b0,        // mem_wren: Disable
            2'b10,       // wb_sel: pc+4
            4'b0000,     // alu_op: ADD
            4'b0000,     // bmask: No memory access
            1'b0,        // u: Not used
            "Jump JAL"
        );

        // Test 16: Jump - JALR
        instr = 32'h00000067; // JALR x0, x0, 0
        check_outputs(
            1'b1,        // pc_sel: rs1+imm
            1'b1,        // rd_wren: Enable
            1'b1,        // o_insn_vld: Valid
            1'b0,        // br_un: Not used
            1'b0,        // opa_sel: rs1_data
            1'b1,        // opb_sel: imm
            1'b0,        // mem_wren: Disable
            2'b10,       // wb_sel: pc+4
            4'b0000,     // alu_op: ADD
            4'b0000,     // bmask: No memory access
            1'b0,        // u: Not used
            "Jump JALR"
        );

        // Test 17: U-type - LUI
        instr = 32'h00000037; // LUI x0, 0
        check_outputs(
            1'b0,        // pc_sel: PC+4
            1'b1,        // rd_wren: Enable
            1'b1,        // o_insn_vld: Valid
            1'b0,        // br_un: Not used
            1'b0,        // opa_sel: Not used
            1'b1,        // opb_sel: imm
            1'b0,        // mem_wren: Disable
            2'b01,       // wb_sel: alu_data
            4'b1010,     // alu_op: LUI
            4'b0000,     // bmask: No memory access
            1'b0,        // u: Not used
            "U-type LUI"
        );

        // Test 18: U-type - AUIPC
        instr = 32'h00000017; // AUIPC x0, 0
        check_outputs(
            1'b0,        // pc_sel: PC+4
            1'b1,        // rd_wren: Enable
            1'b1,        // o_insn_vld: Valid
            1'b0,        // br_un: Not used
            1'b1,        // opa_sel: pc
            1'b1,        // opb_sel: imm
            1'b0,        // mem_wren: Disable
            2'b01,       // wb_sel: alu_data
            4'b0000,     // alu_op: ADD
            4'b0000,     // bmask: No memory access
            1'b0,        // u: Not used
            "U-type AUIPC"
        );

        // Test 19: Invalid Instruction
        instr = 32'hFFFFFFFF; // Invalid opcode
        check_outputs(
            1'b0,        // pc_sel: PC+4
            1'b0,        // rd_wren: Disable
            1'b0,        // o_insn_vld: Invalid
            1'b0,        // br_un: Not used
            1'b0,        // opa_sel: rs1_data
            1'b0,        // opb_sel: rs2_data
            1'b0,        // mem_wren: Disable
            2'b00,       // wb_sel: ld_data
            4'b1111,     // alu_op: Invalid
            4'b0000,     // bmask: No memory access
            1'b0,        // u: Not used
            "Invalid Instruction"
        );

        // Summary
        $display("Test Summary: %0d/%0d tests passed", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("All tests passed successfully!");
        end else begin
            $display("Some tests failed. Check the output for details.");
        end

        // Finish simulation
        $finish;
    end

endmodule
