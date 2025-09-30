`timescale 1ps/1ps

module immgen_tb;

    // Khai báo tín hi?u
    logic [31:0] i_ins;
    logic [31:0] o_imm;
    logic [31:0] exp_imm; // Giá tr? mong ??i

    // Kh?i t?o module immgen
    immgen dut (
        .i_ins(i_ins),
        .o_imm(o_imm)
    );

    // Test procedure
    initial begin
        $display("Starting Immgen Testbench...");

        // Testcase 1: I-type (Load - LW)
        i_ins = 32'b111111111111_00001_010_00010_0000011; // opcode=0000011, imm=-1 (0xFFF)
        exp_imm = 32'hFFFF_FFFF; // -1 m? r?ng d?u
        #10;
        $display("Test 1 (I-type Load): instr=%h, o_imm=%h (exp=%h)", i_ins, o_imm, exp_imm);
        assert(o_imm == exp_imm) 
            begin $display("Test 1 Passed"); end 
            else $error("Test 1 Failed");

        // Testcase 2: I-type (Shift - SLLI)
        i_ins = 32'b0000000_00101_00001_001_00010_0010011; // opcode=0010011, funct3=001, imm=5
        exp_imm = 32'h0000_0005; // 5 không m? r?ng d?u
        #10;
        $display("Test 2 (I-type SLLI): instr=%h, o_imm=%h (exp=%h)", i_ins, o_imm, exp_imm);
        assert(o_imm == exp_imm) 
            begin $display("Test 2 Passed"); end 
            else $error("Test 2 Failed");

        // Testcase 3: S-type (Store - SW)
        i_ins = 32'b0000001_00100_00011_010_00101_0100011; // opcode=0100011, imm=37 (0x25)
        exp_imm = 32'h0000_0025; // imm = [31:25]=0000001, [11:7]=00101
        #10;
        $display("Test 3 (S-type Store): instr=%h, o_imm=%h (exp=%h)", i_ins, o_imm, exp_imm);
        assert(o_imm == exp_imm) 
            begin $display("Test 3 Passed"); end 
            else $error("Test 3 Failed");

        // Testcase 4: B-type (Branch - BEQ)
        i_ins = 32'b1111111_00100_00011_000_11100_1100011; // opcode=1100011, imm=-8 (0xFF8)
        exp_imm = 32'hFFFF_FFF8; // imm = [31]=1, [7]=0, [30:25]=111111, [11:8]=1100, +0
        #10;
        $display("Test 4 (B-type Branch): instr=%h, o_imm=%h (exp=%h)", i_ins, o_imm, exp_imm);
        assert(o_imm == exp_imm) 
            begin $display("Test 4 Passed"); end 
            else $error("Test 4 Failed");

        // Testcase 5: U-type (LUI)
        i_ins = 32'b00000000000100000000_00010_0110111; // opcode=0110111, imm=0x1000
        exp_imm = 32'h0000_1000; // imm = [31:12]=00000000000100000000, +12 zeros
        #10;
        $display("Test 5 (U-type LUI): instr=%h, o_imm=%h (exp=%h)", i_ins, o_imm, exp_imm);
        assert(o_imm == exp_imm) 
            begin $display("Test 5 Passed"); end 
            else $error("Test 5 Failed");

        // Testcase 6: J-type (JAL)
        i_ins = 32'b111111111110_11111_1_00000_1101111; // opcode=1101111, imm=-2 (0xFFE)
        exp_imm = 32'hFFFF_FFFE; // imm = [31]=1, [19:12]=11111111, [20]=1, [30:21]=1111111110, +0
        #10;
        $display("Test 6 (J-type JAL): instr=%h, o_imm=%h (exp=%h)", i_ins, o_imm, exp_imm);
        assert(o_imm == exp_imm) 
            begin $display("Test 6 Passed"); end 
            else $error("Test 6 Failed");

        // 50 testcase ng?u nhiên
        $display("\nRunning 50 random tests...");
        for (int i = 0; i < 50; i++) begin
            i_ins = $urandom(); // L?nh ng?u nhiên 32-bit
            #10;

            // Tính giá tr? mong ??i d?a trên opcode và funct3
            case (i_ins[6:0])
                7'b0000011, 7'b1100111: // I-type (Load, JALR)
                    exp_imm = {{20{i_ins[31]}}, i_ins[31:20]};
                7'b0010011: begin // I-type (Arithmetic)
                    if (i_ins[14:12] == 3'b001 || i_ins[14:12] == 3'b101)
                        exp_imm = {27'b0, i_ins[24:20]}; // Shift
                    else
                        exp_imm = {{20{i_ins[31]}}, i_ins[31:20]};
                end
                7'b0100011: // S-type
                    exp_imm = {{20{i_ins[31]}}, i_ins[31:25], i_ins[11:7]};
                7'b1100011: // B-type
                    exp_imm = {{19{i_ins[31]}}, i_ins[31], i_ins[7], i_ins[30:25], i_ins[11:8], 1'b0};
                7'b0110111, 7'b0010111: // U-type
                    exp_imm = {i_ins[31:12], 12'b0};
                7'b1101111: // J-type
                    exp_imm = {{11{i_ins[31]}}, i_ins[19:12], i_ins[20], i_ins[30:21], 1'b0};
                default:
                    exp_imm = 32'b0;
            endcase

            $display("Test %0d: instr=%h, o_imm=%h (exp=%h)", i+7, i_ins, o_imm, exp_imm);
            assert(o_imm == exp_imm) 
                begin $display("Test %0d Passed", i+7); end 
                else $error("Test %0d Failed", i+7);
        end

        // K?t thúc
        $display("\nTestbench completed!");
        $finish;
    end

endmodule
