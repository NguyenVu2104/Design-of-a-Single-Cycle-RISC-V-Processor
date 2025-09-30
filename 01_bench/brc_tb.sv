`timescale 1ps/1ps

module brc_tb;

  logic [31:0] i_rs1_data, i_rs2_data;
  logic        i_br_un, o_br_less, o_br_equal;

  brc dut (
    .i_rs1_data(i_rs1_data),
    .i_rs2_data(i_rs2_data),
    .i_br_un(i_br_un),
    .o_br_less(o_br_less),
    .o_br_equal(o_br_equal)
  );

  logic exp_br_less;
  logic exp_br_equal;

  int num_tests = 50;

  function void check_expected(input logic [31:0] rs1, input logic [31:0] rs2, input logic br_un);
    exp_br_equal = (rs1 == rs2);
    if (br_un) begin // Signed comparison
      exp_br_less = $signed(rs1) < $signed(rs2);
    end else begin // Unsigned comparison
      exp_br_less = rs1 < rs2;
    end
  endfunction

  // Test procedure
  initial begin
    $display("Starting BRC Testbench...");

    // Testcase 1: C? hai b?ng nhau (signed và unsigned)
    i_rs1_data = 32'h00000005;
    i_rs2_data = 32'h00000005;
    i_br_un = 1'b1; // Signed
    #10;
    check_expected(i_rs1_data, i_rs2_data, i_br_un);
    $display("Test 1 (Signed): rs1=%h, rs2=%h, br_un=%b, o_br_less=%b (exp=%b), o_br_equal=%b (exp=%b)",
             i_rs1_data, i_rs2_data, i_br_un, o_br_less, exp_br_less, o_br_equal, exp_br_equal);
    assert(o_br_less == exp_br_less && o_br_equal == exp_br_equal) else $error("Test 1 Failed");

    i_br_un = 1'b0; // Unsigned
    #10;
    check_expected(i_rs1_data, i_rs2_data, i_br_un);
    $display("Test 2 (Unsigned): rs1=%h, rs2=%h, br_un=%b, o_br_less=%b (exp=%b), o_br_equal=%b (exp=%b)",
             i_rs1_data, i_rs2_data, i_br_un, o_br_less, exp_br_less, o_br_equal, exp_br_equal);
    assert(o_br_less == exp_br_less && o_br_equal == exp_br_equal) else $error("Test 2 Failed");

    // Testcase 2: S? d??ng, rs1 < rs2
    i_rs1_data = 32'h00000001;
    i_rs2_data = 32'h00000002;
    i_br_un = 1'b1; // Signed
    #10;
    check_expected(i_rs1_data, i_rs2_data, i_br_un);
    $display("Test 3 (Signed): rs1=%h, rs2=%h, br_un=%b, o_br_less=%b (exp=%b), o_br_equal=%b (exp=%b)",
             i_rs1_data, i_rs2_data, i_br_un, o_br_less, exp_br_less, o_br_equal, exp_br_equal);
    assert(o_br_less == exp_br_less && o_br_equal == exp_br_equal) else $error("Test 3 Failed");

    i_br_un = 1'b0; // Unsigned
    #10;
    check_expected(i_rs1_data, i_rs2_data, i_br_un);
    $display("Test 4 (Unsigned): rs1=%h, rs2=%h, br_un=%b, o_br_less=%b (exp=%b), o_br_equal=%b (exp=%b)",
             i_rs1_data, i_rs2_data, i_br_un, o_br_less, exp_br_less, o_br_equal, exp_br_equal);
    assert(o_br_less == exp_br_less && o_br_equal == exp_br_equal) else $error("Test 4 Failed");

    // Testcase 3: S? âm, rs1 < rs2
    i_rs1_data = 32'hFFFFFFFE; // -2
    i_rs2_data = 32'hFFFFFFFF; // -1
    i_br_un = 1'b1; // Signed
    #10;
    check_expected(i_rs1_data, i_rs2_data, i_br_un);
    $display("Test 5 (Signed): rs1=%h, rs2=%h, br_un=%b, o_br_less=%b (exp=%b), o_br_equal=%b (exp=%b)",
             i_rs1_data, i_rs2_data, i_br_un, o_br_less, exp_br_less, o_br_equal, exp_br_equal);
    assert(o_br_less == exp_br_less && o_br_equal == exp_br_equal) else $error("Test 5 Failed");

    // Testcase 4: S? d??ng vs s? âm
    i_rs1_data = 32'h00000001; // 1
    i_rs2_data = 32'hFFFFFFFF; // -1
    i_br_un = 1'b1; // Signed
    #10;
    check_expected(i_rs1_data, i_rs2_data, i_br_un);
    $display("Test 6 (Signed): rs1=%h, rs2=%h, br_un=%b, o_br_less=%b (exp=%b), o_br_equal=%b (exp=%b)",
             i_rs1_data, i_rs2_data, i_br_un, o_br_less, exp_br_less, o_br_equal, exp_br_equal);
    assert(o_br_less == exp_br_less && o_br_equal == exp_br_equal) else $error("Test 6 Failed");

    i_br_un = 1'b0; // Unsigned
    #10;
    check_expected(i_rs1_data, i_rs2_data, i_br_un);
    $display("Test 7 (Unsigned): rs1=%h, rs2=%h, br_un=%b, o_br_less=%b (exp=%b), o_br_equal=%b (exp=%b)",
             i_rs1_data, i_rs2_data, i_br_un, o_br_less, exp_br_less, o_br_equal, exp_br_equal);
    assert(o_br_less == exp_br_less && o_br_equal == exp_br_equal) else $error("Test 7 Failed");

    // Testcase 5: Giá tr? l?n không d?u
    i_rs1_data = 32'h80000000;
    i_rs2_data = 32'h80000001;
    i_br_un = 1'b0; // Unsigned
    #10;
    check_expected(i_rs1_data, i_rs2_data, i_br_un);
    $display("Test 8 (Unsigned): rs1=%h, rs2=%h, br_un=%b, o_br_less=%b (exp=%b), o_br_equal=%b (exp=%b)",
             i_rs1_data, i_rs2_data, i_br_un, o_br_less, exp_br_less, o_br_equal, exp_br_equal);
    assert(o_br_less == exp_br_less && o_br_equal == exp_br_equal) else $error("Test 8 Failed");

    // Testcase ng?u nhiên
    $display("\nRunning %0d random tests...", num_tests);
    for (int i = 0; i < num_tests; i++) begin
      i_rs1_data = $urandom();
      i_rs2_data = $urandom();
      i_br_un = $urandom_range(0, 1);
      #10;
      check_expected(i_rs1_data, i_rs2_data, i_br_un);
      $display("Test %0d: rs1=%h, rs2=%h, br_un=%b, o_br_less=%b (exp=%b), o_br_equal=%b (exp=%b)",
               i+9, i_rs1_data, i_rs2_data, i_br_un, o_br_less, exp_br_less, o_br_equal, exp_br_equal);
      assert(o_br_less == exp_br_less && o_br_equal == exp_br_equal) else $error("Random Test %0d Failed", i+9);
    end

    // K?t thúc
    $display("\nTestbench completed!");
  end

endmodule
