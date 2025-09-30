`timescale 1ps/1ps

module alu_tb;

  // Khai báo tín hi?u
  logic [31:0] i_op_a;
  logic [31:0] i_op_b;
  logic [3:0]  i_alu_op;
  logic [31:0] o_alu_data;

  // Kh?i t?o module ALU
  alu dut (
    .i_op_a(i_op_a),
    .i_op_b(i_op_b),
    .i_alu_op(i_alu_op),
    .o_alu_data(o_alu_data)
  );

  // Bi?n ?? l?u giá tr? mong ??i
  logic [31:0] exp_alu_data;

  // S? l??ng testcase ng?u nhiên
  int num_random_tests = 50;

  // Hàm tính giá tr? mong ??i
  function void check_expected(input logic [31:0] op_a, input logic [31:0] op_b, input logic [3:0] alu_op);
    case (alu_op)
      4'b0000: exp_alu_data = op_a + op_b;                     // ADD
      4'b0001: exp_alu_data = op_a - op_b;                     // SUB
      4'b0010: exp_alu_data = ($signed(op_a) < $signed(op_b)) ? 32'h1 : 32'h0; // SLT
      4'b0011: exp_alu_data = (op_a < op_b) ? 32'h1 : 32'h0;   // SLTU
      4'b0100: exp_alu_data = op_a ^ op_b;                     // XOR
      4'b0101: exp_alu_data = op_a | op_b;                     // OR
      4'b0110: exp_alu_data = op_a & op_b;                     // AND
      4'b0111: exp_alu_data = op_a << op_b[4:0];               // SLL
      4'b1000: exp_alu_data = op_a >> op_b[4:0];               // SRL
      4'b1001: exp_alu_data = $signed(op_a) >>> op_b[4:0];     // SRA
      default: exp_alu_data = 32'h0;
    endcase
  endfunction

  // Test procedure
  initial begin
    $display("Starting ALU Testbench...");

    // Testcase 1: ADD
    i_op_a = 32'h00000005;
    i_op_b = 32'h00000003;
    i_alu_op = 4'b0000;
    #10;
    check_expected(i_op_a, i_op_b, i_alu_op);
    $display("Test 1 (ADD): op_a=%h, op_b=%h, alu_op=%b, o_alu_data=%h (exp=%h)",
             i_op_a, i_op_b, i_alu_op, o_alu_data, exp_alu_data);
    assert(o_alu_data == exp_alu_data) else $error("Test 1 Failed");

    // Testcase 2: SUB
    i_op_a = 32'h00000008;
    i_op_b = 32'h00000003;
    i_alu_op = 4'b0001;
    #10;
    check_expected(i_op_a, i_op_b, i_alu_op);
    $display("Test 2 (SUB): op_a=%h, op_b=%h, alu_op=%b, o_alu_data=%h (exp=%h)",
             i_op_a, i_op_b, i_alu_op, o_alu_data, exp_alu_data);
    assert(o_alu_data == exp_alu_data) else $error("Test 2 Failed");

    // Testcase 3: SLT (signed, positive vs negative)
    i_op_a = 32'h00000001; // 1
    i_op_b = 32'hFFFFFFFE; // -2
    i_alu_op = 4'b0010;
    #10;
    check_expected(i_op_a, i_op_b, i_alu_op);
    $display("Test 3 (SLT): op_a=%h, op_b=%h, alu_op=%b, o_alu_data=%h (exp=%h)",
             i_op_a, i_op_b, i_alu_op, o_alu_data, exp_alu_data);
    assert(o_alu_data == exp_alu_data) else $error("Test 3 Failed");

    // Testcase 4: SLTU (unsigned, large vs small)
    i_op_a = 32'h80000000;
    i_op_b = 32'h00000001;
    i_alu_op = 4'b0011;
    #10;
    check_expected(i_op_a, i_op_b, i_alu_op);
    $display("Test 4 (SLTU): op_a=%h, op_b=%h, alu_op=%b, o_alu_data=%h (exp=%h)",
             i_op_a, i_op_b, i_alu_op, o_alu_data, exp_alu_data);
    assert(o_alu_data == exp_alu_data) else $error("Test 4 Failed");

    // Testcase 5: XOR
    i_op_a = 32'h0000FFFF;
    i_op_b = 32'hFFFF0000;
    i_alu_op = 4'b0100;
    #10;
    check_expected(i_op_a, i_op_b, i_alu_op);
    $display("Test 5 (XOR): op_a=%h, op_b=%h, alu_op=%b, o_alu_data=%h (exp=%h)",
             i_op_a, i_op_b, i_alu_op, o_alu_data, exp_alu_data);
    assert(o_alu_data == exp_alu_data) else $error("Test 5 Failed");

    // Testcase 6: OR
    i_op_a = 32'h0000AAAA;
    i_op_b = 32'h55550000;
    i_alu_op = 4'b0101;
    #10;
    check_expected(i_op_a, i_op_b, i_alu_op);
    $display("Test 6 (OR): op_a=%h, op_b=%h, alu_op=%b, o_alu_data=%h (exp=%h)",
             i_op_a, i_op_b, i_alu_op, o_alu_data, exp_alu_data);
    assert(o_alu_data == exp_alu_data) else $error("Test 6 Failed");

    // Testcase 7: AND
    i_op_a = 32'hFFFF0000;
    i_op_b = 32'hFF00FF00;
    i_alu_op = 4'b0110;
    #10;
    check_expected(i_op_a, i_op_b, i_alu_op);
    $display("Test 7 (AND): op_a=%h, op_b=%h, alu_op=%b, o_alu_data=%h (exp=%h)",
             i_op_a, i_op_b, i_alu_op, o_alu_data, exp_alu_data);
    assert(o_alu_data == exp_alu_data) else $error("Test 7 Failed");

    // Testcase 8: SLL (shift left by 3)
    i_op_a = 32'h00000001;
    i_op_b = 32'h00000003;
    i_alu_op = 4'b0111;
    #10;
    check_expected(i_op_a, i_op_b, i_alu_op);
    $display("Test 8 (SLL): op_a=%h, op_b=%h, alu_op=%b, o_alu_data=%h (exp=%h)",
             i_op_a, i_op_b, i_alu_op, o_alu_data, exp_alu_data);
    assert(o_alu_data == exp_alu_data) else $error("Test 8 Failed");

    // Testcase 9: SRL (shift right logical by 2)
    i_op_a = 32'h0000000F;
    i_op_b = 32'h00000002;
    i_alu_op = 4'b1000;
    #10;
    check_expected(i_op_a, i_op_b, i_alu_op);
    $display("Test 9 (SRL): op_a=%h, op_b=%h, alu_op=%b, o_alu_data=%h (exp=%h)",
             i_op_a, i_op_b, i_alu_op, o_alu_data, exp_alu_data);
    assert(o_alu_data == exp_alu_data) else $error("Test 9 Failed");

    // Testcase 10: SRA (shift right arithmetic by 2)
    i_op_a = 32'h80000000; // -2^31
    i_op_b = 32'h00000002;
    i_alu_op = 4'b1001;
    #10;
    check_expected(i_op_a, i_op_b, i_alu_op);
    $display("Test 10 (SRA): op_a=%h, op_b=%h, alu_op=%b, o_alu_data=%h (exp=%h)",
             i_op_a, i_op_b, i_alu_op, o_alu_data, exp_alu_data);
    assert(o_alu_data == exp_alu_data) else $error("Test 10 Failed");

    // Testcase ng?u nhiên
    $display("\nRunning %0d random tests...", num_random_tests);
    for (int i = 0; i < num_random_tests; i++) begin
      i_op_a = $urandom();
      i_op_b = $urandom();
      i_alu_op = $urandom_range(0, 9); // T? 0000 ??n 1001
      #10;
      check_expected(i_op_a, i_op_b, i_alu_op);
      $display("Test %0d: op_a=%h, op_b=%h, alu_op=%b, o_alu_data=%h (exp=%h)",
               i+11, i_op_a, i_op_b, i_alu_op, o_alu_data, exp_alu_data);
      assert(o_alu_data == exp_alu_data) else $error("Random Test %0d Failed", i+11);
    end

    // K?t thúc
    $display("\nTestbench completed!");
  end

endmodule
