module insn_vld(
input logic i_clk,
input logic insn_vld,
output logic o_insn_vld
);

always @(posedge i_clk) begin 
  o_insn_vld <= insn_vld;
  end
endmodule
