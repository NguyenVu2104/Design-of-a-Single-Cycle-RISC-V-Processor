`timescale 1ps/1ps

module regfile_tb;

  // Khai báo tín hi?u
  logic        i_clk;
  logic        i_reset;
  logic [4:0]  i_rs1_addr;
  logic [4:0]  i_rs2_addr;
  logic [31:0] o_rs1_data;
  logic [31:0] o_rs2_data;
  logic [4:0]  i_rd_addr;
  logic [31:0] i_rd_data;
  logic        i_rd_wren;

  // Kh?i t?o module regfile
  regfile dut (
    .i_clk(i_clk),
    .i_reset(i_reset),
    .i_rs1_addr(i_rs1_addr),
    .i_rs2_addr(i_rs2_addr),
    .o_rs1_data(o_rs1_data),
    .o_rs2_data(o_rs2_data),
    .i_rd_addr(i_rd_addr),
    .i_rd_data(i_rd_data),
    .i_rd_wren(i_rd_wren)
  );

  // T?o clock
  initial begin
    i_clk = 0;
    forever #5 i_clk = ~i_clk; // Chu k? 10ns
  end

  // Bi?n ?? l?u giá tr? mong ??i
  logic [31:0] exp_rs1_data, exp_rs2_data;
  logic [31:0] shadow_regfile [0:31]; // M?ng shadow ?? theo dõi giá tr? mong ??i

  // Hàm kh?i t?o shadow_regfile
  function void init_shadow_regfile();
    for (int i = 0; i < 32; i++) begin
      shadow_regfile[i] = 32'b0;
    end
  endfunction

  // Hàm c?p nh?t shadow_regfile khi ghi
  function void update_shadow_regfile(input logic [4:0] addr, input logic [31:0] data, input logic wren);
    if (wren && (addr != 5'd0)) begin
      shadow_regfile[addr] = data;
    end
  endfunction

  // Hàm tính giá tr? mong ??i khi ??c
  function void check_expected(input logic [4:0] rs1_addr, input logic [4:0] rs2_addr);
    exp_rs1_data = (rs1_addr == 5'd0) ? 32'b0 : shadow_regfile[rs1_addr];
    exp_rs2_data = (rs2_addr == 5'd0) ? 32'b0 : shadow_regfile[rs2_addr];
  endfunction

  // Test procedure
  initial begin
    $display("Starting Regfile Testbench...");
    init_shadow_regfile(); // Kh?i t?o shadow_regfile

    // Testcase 1: Reset và ki?m tra x0
    i_reset = 0; i_rd_wren = 0; i_rs1_addr = 5'd0; i_rs2_addr = 5'd0;
    #10;
    i_reset = 1;
    #10;
    check_expected(i_rs1_addr, i_rs2_addr);
    $display("Test 1 (Reset, x0): rs1_addr=%0d, rs2_addr=%0d, o_rs1_data=%h (exp=%h), o_rs2_data=%h (exp=%h)",
             i_rs1_addr, i_rs2_addr, o_rs1_data, exp_rs1_data, o_rs2_data, exp_rs2_data);
    assert(o_rs1_data == exp_rs1_data && o_rs2_data == exp_rs2_data) 
      begin $display("Test 1 Passed"); end 
      else $error("Test 1 Failed");

    // Testcase 2: Ghi và ??c t? x1
    i_rd_addr = 5'd1; i_rd_data = 32'hDEADBEEF; i_rd_wren = 1;
    #10;
    i_rd_wren = 0; i_rs1_addr = 5'd1; i_rs2_addr = 5'd0;
    #10;
    update_shadow_regfile(i_rd_addr, i_rd_data, 1'b1);
    check_expected(i_rs1_addr, i_rs2_addr);
    $display("Test 2 (Write x1): rs1_addr=%0d, rs2_addr=%0d, o_rs1_data=%h (exp=%h), o_rs2_data=%h (exp=%h)",
             i_rs1_addr, i_rs2_addr, o_rs1_data, exp_rs1_data, o_rs2_data, exp_rs2_data);
    assert(o_rs1_data == exp_rs1_data && o_rs2_data == exp_rs2_data) 
      begin $display("Test 2 Passed"); end 
      else $error("Test 2 Failed");

    // Testcase 3: Ghi vào x0 (không thay ??i)
    i_rd_addr = 5'd0; i_rd_data = 32'h12345678; i_rd_wren = 1;
    #10;
    i_rd_wren = 0; i_rs1_addr = 5'd0; i_rs2_addr = 5'd1;
    #10;
    update_shadow_regfile(i_rd_addr, i_rd_data, 1'b1);
    check_expected(i_rs1_addr, i_rs2_addr);
    $display("Test 3 (Write x0): rs1_addr=%0d, rs2_addr=%0d, o_rs1_data=%h (exp=%h), o_rs2_data=%h (exp=%h)",
             i_rs1_addr, i_rs2_addr, o_rs1_data, exp_rs1_data, o_rs2_data, exp_rs2_data);
    assert(o_rs1_data == exp_rs1_data && o_rs2_data == exp_rs2_data) 
      begin $display("Test 3 Passed"); end 
      else $error("Test 3 Failed");

    // Testcase 4: Ghi và ??c t? x31
    i_rd_addr = 5'd31; i_rd_data = 32'hCAFEBABE; i_rd_wren = 1;
    #10;
    i_rd_wren = 0; i_rs1_addr = 5'd31; i_rs2_addr = 5'd1;
    #10;
    update_shadow_regfile(i_rd_addr, i_rd_data, 1'b1);
    check_expected(i_rs1_addr, i_rs2_addr);
    $display("Test 4 (Write x31): rs1_addr=%0d, rs2_addr=%0d, o_rs1_data=%h (exp=%h), o_rs2_data=%h (exp=%h)",
             i_rs1_addr, i_rs2_addr, o_rs1_data, exp_rs1_data, o_rs2_data, exp_rs2_data);
    assert(o_rs1_data == exp_rs1_data && o_rs2_data == exp_rs2_data) 
      begin $display("Test 4 Passed"); end 
      else $error("Test 4 Failed");

    // 50 testcase ng?u nhiên
    $display("\nRunning 50 random tests...");
    for (int i = 0; i < 50; i++) begin
      i_rd_addr = $urandom_range(0, 31);  // ??a ch? ng?u nhiên t? 0 ??n 31
      i_rd_data = $urandom();             // D? li?u ng?u nhiên 32-bit
      i_rd_wren = $urandom_range(0, 1);  // Write enable ng?u nhiên (0 ho?c 1)
      i_rs1_addr = $urandom_range(0, 31); // ??a ch? ??c 1 ng?u nhiên
      i_rs2_addr = $urandom_range(0, 31); // ??a ch? ??c 2 ng?u nhiên

      #10; // Ch? xung clock ?? ghi (n?u có)
      update_shadow_regfile(i_rd_addr, i_rd_data, i_rd_wren);
      check_expected(i_rs1_addr, i_rs2_addr);

      $display("Test %0d: rd_addr=%0d, rd_data=%h, wren=%b, rs1_addr=%0d, rs2_addr=%0d, o_rs1_data=%h (exp=%h), o_rs2_data=%h (exp=%h)",
               i+5, i_rd_addr, i_rd_data, i_rd_wren, i_rs1_addr, i_rs2_addr, o_rs1_data, exp_rs1_data, o_rs2_data, exp_rs2_data);
      assert(o_rs1_data == exp_rs1_data && o_rs2_data == exp_rs2_data) 
        begin $display("Test %0d Passed", i+5); end 
        else $error("Test %0d Failed", i+5);

      // T?t write enable sau m?i test ?? ki?m tra ??c
      i_rd_wren = 0;
      #10;
    end

    // K?t thúc
    $display("\nTestbench completed!");
    $finish;
  end

endmodule
