module control_unit (
    input logic [31:0] instr,
    input logic br_less,
    input logic br_equal,

    output logic pc_sel,
    output logic rd_wren,
    output logic o_insn_vld,
    output logic br_un,
    output logic opa_sel,
    output logic opb_sel,
    output logic mem_wren,
    output logic [1:0] wb_sel,
    output logic [3:0] alu_op,
    output logic [3:0] bmask,  // output for byte mask
    output logic u             // output for unsigned load
);

    logic [6:0] opcode;
    logic [2:0] funct3;
    logic funct7_5; // funct7[5] for distinguishing SUB/SRA from ADD/SRL

    assign opcode = instr[6:0];
    assign funct3 = instr[14:12];
    assign funct7_5 = instr[30]; // Used for R-type instructions

    always_comb begin
        // Default values (for invalid instructions)
        o_insn_vld = 1'b0;  // Instruction invalid by default
        pc_sel = 1'b0;      // PC = PC + 4
        rd_wren = 1'b0;     // Disable register write
        br_un = 1'b0;       // Signed comparison
        opa_sel = 1'b0;     // operand_a = rs1_data
        opb_sel = 1'b0;     // operand_b = rs2_data
        mem_wren = 1'b0;    // Disable memory write
        wb_sel = 2'b00;     // Default to ld_data (not used in most cases)
        alu_op = 4'b1111;   // Default ALU operation (invalid)
        bmask = 4'b0000;    // Default byte mask (no bytes accessed)
        u = 1'b0;           // Default to signed extension

        case (opcode)
            // R-type Instructions
            7'b0110011: begin
                o_insn_vld = 1'b1;  // Valid instruction
                pc_sel = 1'b0;      // PC = PC + 4
                rd_wren = 1'b1;     // Enable register write
                br_un = 1'b0;       // Signed comparison (not used)
                opa_sel = 1'b0;     // operand_a = rs1_data
                opb_sel = 1'b0;     // operand_b = rs2_data
                mem_wren = 1'b0;    // Disable memory write
                wb_sel = 2'b01;     // rd_data = alu_data
                bmask = 4'b0000;    // No memory access
                u = 1'b0;           // Not used

                case (funct3)
                    3'b000: begin // ADD or SUB
                        if (funct7_5) alu_op = 4'b0001; // SUB
                        else alu_op = 4'b0000;          // ADD
                    end
                    3'b001: alu_op = 4'b0010; // SLL
                    3'b010: alu_op = 4'b0011; // SLT
                    3'b011: alu_op = 4'b0100; // SLTU
                    3'b100: alu_op = 4'b0101; // XOR
                    3'b101: begin // SRL or SRA
                        if (funct7_5) alu_op = 4'b0111; // SRA
                        else alu_op = 4'b0110;          // SRL
                    end
                    3'b110: alu_op = 4'b1000; // OR
                    3'b111: alu_op = 4'b1001; // AND
                    default: alu_op = 4'b1111; // Invalid
                endcase
            end

            // I-type Instructions
            7'b0010011: begin
                o_insn_vld = 1'b1;  // Valid instruction
                pc_sel = 1'b0;      // PC = PC + 4
                rd_wren = 1'b1;     // Enable register write
                br_un = 1'b0;       // Signed comparison (not used)
                opa_sel = 1'b0;     // operand_a = rs1_data
                opb_sel = 1'b1;     // operand_b = imm
                mem_wren = 1'b0;    // Disable memory write
                wb_sel = 2'b01;     // rd_data = alu_data
                bmask = 4'b0000;    // No memory access
                u = 1'b0;           // Not used

                case (funct3)
                    3'b000: alu_op = 4'b0000; // ADDI
                    3'b001: alu_op = 4'b0010; // SLLI
                    3'b010: alu_op = 4'b0011; // SLTI
                    3'b011: alu_op = 4'b0100; // SLTIU
                    3'b100: alu_op = 4'b0101; // XORI
                    3'b101: begin // SRLI or SRAI
                        if (funct7_5) alu_op = 4'b0111; // SRAI
                        else alu_op = 4'b0110;          // SRLI
                    end
                    3'b110: alu_op = 4'b1000; // ORI
                    3'b111: alu_op = 4'b1001; // ANDI
                    default: alu_op = 4'b1111; // Invalid
                endcase
            end

            // I-type Instructions (Load: LB, LH, LW, LBU, LHU)
            7'b0000011: begin
                o_insn_vld = 1'b1;  // Valid instruction
                pc_sel = 1'b0;      // PC = PC + 4
                rd_wren = 1'b1;     // Enable register write
                br_un = 1'b0;       // Signed comparison (not used)
                opa_sel = 1'b0;     // operand_a = rs1_data
                opb_sel = 1'b1;     // operand_b = imm
                mem_wren = 1'b0;    // Disable memory write
                wb_sel = 2'b00;     // rd_data = ld_data
                alu_op = 4'b0000;   // ADD (for address calculation)

                case (funct3)
                    3'b000: begin // LB
                        bmask = 4'b0001; // Load byte
                        u = 1'b0;        // Sign-extend
                    end
                    3'b001: begin // LH
                        bmask = 4'b0011; // Load halfword
                        u = 1'b0;        // Sign-extend
                    end
                    3'b010: begin // LW
                        bmask = 4'b1111; // Load word
                        u = 1'b0;        // Not used (full word)
                    end
                    3'b100: begin // LBU
                        bmask = 4'b0001; // Load byte
                        u = 1'b1;        // Zero-extend
                    end
                    3'b101: begin // LHU
                        bmask = 4'b0011; // Load halfword
                        u = 1'b1;        // Zero-extend
                    end
                    default: begin
                        bmask = 4'b0000; // Invalid
                        u = 1'b0;        // Default to sign-extend
                    end
                endcase
            end

            // S-type Instructions (Store: SB, SH, SW)
            7'b0100011: begin
                o_insn_vld = 1'b1;  // Valid instruction
                pc_sel = 1'b0;      // PC = PC + 4
                rd_wren = 1'b0;     // Disable register write
                br_un = 1'b0;       // Signed comparison (not used)
                opa_sel = 1'b0;     // operand_a = rs1_data
                opb_sel = 1'b1;     // operand_b = imm
                mem_wren = 1'b1;    // Enable memory write
                wb_sel = 2'b00;     // rd_data = ld_data (not used)
                alu_op = 4'b0000;   // ADD (for address calculation)
                u = 1'b0;           // Not used for stores

                case (funct3)
                    3'b000: bmask = 4'b0001; // SB (store byte)
                    3'b001: bmask = 4'b0011; // SH (store halfword)
                    3'b010: bmask = 4'b1111; // SW (store word)
                    default: bmask = 4'b0000; // Invalid
                endcase
            end

            // B-type Instructions (Branches: BEQ, BNE, etc.)
            7'b1100011: begin
                o_insn_vld = 1'b1;  // Valid instruction
                rd_wren = 1'b0;     // Disable register write
                opa_sel = 1'b1;     // operand_a = pc
                opb_sel = 1'b1;     // operand_b = imm
                mem_wren = 1'b0;    // Disable memory write
                wb_sel = 2'b00;     // rd_data = ld_data (not used)
                alu_op = 4'b0000;   // ADD (for branch target calculation)
                bmask = 4'b0000;    // No memory access
                u = 1'b0;           // Not used

                case (funct3)
                    3'b000: begin // BEQ
                        br_un = 1'b0; // Signed comparison
                        pc_sel = br_equal ? 1'b1 : 1'b0; // PC = PC + imm if equal
                    end
                    3'b001: begin // BNE
                        br_un = 1'b0; // Signed comparison
                        pc_sel = (~br_equal) ? 1'b1 : 1'b0; // PC = PC + imm if not equal
                    end
                    3'b100: begin // BLT
                        br_un = 1'b0; // Signed comparison
                        pc_sel = br_less ? 1'b1 : 1'b0; // PC = PC + imm if less
                    end
                    3'b101: begin // BGE
                        br_un = 1'b0; // Signed comparison
                        pc_sel = (~br_less || br_equal) ? 1'b1 : 1'b0; // PC = PC + imm if greater or equal
                    end
                    3'b110: begin // BLTU
                        br_un = 1'b1; // Unsigned comparison
                        pc_sel = br_less ? 1'b1 : 1'b0; // PC = PC + imm if less (unsigned)
                    end
                    3'b111: begin // BGEU
                        br_un = 1'b1; // Unsigned comparison
                        pc_sel = (~br_less || br_equal) ? 1'b1 : 1'b0; // PC = PC + imm if greater or equal (unsigned)
                    end
                    default: begin
                        br_un = 1'b0;
                        pc_sel = 1'b0; // PC = PC + 4
                    end
                endcase
            end

            // J-type Instructions (JAL)
            7'b1101111: begin
                o_insn_vld = 1'b1;  // Valid instruction
                pc_sel = 1'b1;      // PC = PC + imm
                rd_wren = 1'b1;     // Enable register write
                br_un = 1'b0;       // Signed comparison (not used)
                opa_sel = 1'b1;     // operand_a = pc
                opb_sel = 1'b1;     // operand_b = imm
                mem_wren = 1'b0;    // Disable memory write
                wb_sel = 2'b10;     // rd_data = pc + 4
                alu_op = 4'b0000;   // ADD (for jump target calculation)
                bmask = 4'b0000;    // No memory access
                u = 1'b0;           // Not used
            end

            // I-type Instructions (JALR)
            7'b1100111: begin
                o_insn_vld = 1'b1;  // Valid instruction
                pc_sel = 1'b1;      // PC = rs1 + imm
                rd_wren = 1'b1;     // Enable register write
                br_un = 1'b0;       // Signed comparison (not used)
                opa_sel = 1'b0;     // operand_a = rs1_data
                opb_sel = 1'b1;     // operand_b = imm
                mem_wren = 1'b0;    // Disable memory write
                wb_sel = 2'b10;     // rd_data = pc + 4
                alu_op = 4'b0000;   // ADD (for jump target calculation)
                bmask = 4'b0000;    // No memory access
                u = 1'b0;           // Not used
            end

            // U-type Instructions (LUI)
            7'b0110111: begin
                o_insn_vld = 1'b1;  // Valid instruction
                pc_sel = 1'b0;      // PC = PC + 4
                rd_wren = 1'b1;     // Enable register write
                br_un = 1'b0;       // Signed comparison (not used)
                opa_sel = 1'b0;     // operand_a = rs1_data (not used)
                opb_sel = 1'b1;     // operand_b = imm
                mem_wren = 1'b0;    // Disable memory write
                wb_sel = 2'b01;     // rd_data = alu_data
                alu_op = 4'b1010;   // LUI (pass operand_b directly)
                bmask = 4'b0000;    // No memory access
                u = 1'b0;           // Not used
            end

            // U-type Instructions (AUIPC)
            7'b0010111: begin
                o_insn_vld = 1'b1;  // Valid instruction
                pc_sel = 1'b0;      // PC = PC + 4
                rd_wren = 1'b1;     // Enable register write
                br_un = 1'b0;       // Signed comparison (not used)
                opa_sel = 1'b1;     // operand_a = pc
                opb_sel = 1'b1;     // operand_b = imm
                mem_wren = 1'b0;    // Disable memory write
                wb_sel = 2'b01;     // rd_data = alu_data
                alu_op = 4'b0000;   // ADD (PC + imm)
                bmask = 4'b0000;    // No memory access
                u = 1'b0;           // Not used
            end

            // Default case for invalid instructions
            default: begin
                o_insn_vld = 1'b0;  // Invalid instruction
                pc_sel = 1'b0;      // PC = PC + 4
                rd_wren = 1'b0;     // Disable register write
                br_un = 1'b0;       // Signed comparison
                opa_sel = 1'b0;     // operand_a = rs1_data
                opb_sel = 1'b0;     // operand_b = rs2_data
                mem_wren = 1'b0;    // Disable memory write
                wb_sel = 2'b00;     // rd_data = ld_data
                alu_op = 4'b1111;   // Invalid ALU operation
                bmask = 4'b0000;    // No memory access
                u = 1'b0;           // Default to sign-extend
            end
        endcase
    end

endmodule
