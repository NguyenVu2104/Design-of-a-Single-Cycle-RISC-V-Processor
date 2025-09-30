// module pc_debug (
	// input 	logic	      	i_clk,
	// input 	logic	      	i_reset,
	// output	logic	[31:0]	o_pc_debug
// );

	// pc pc(
		// .i_clk(i_clk),
		// .i_reset(i_reset),
		// .pc_next(),
		// .pc(o_pc_debug)
	// );

// endmodule

// module pc_debug(
	// input logic i_clk,
	// input logic i_rst,
	// input logic [31:0] pc_debug,
	// output logic [31:0] o_pc_debug
// );

// always @(posedge i_clk) begin
	// if (!i_rst) o_pc_debug <= 32'h00000000;
	// else o_pc_debug <= pc_debug;
	// end
// endmodule

module pc_debug (
  input  logic        i_clk,
  input  logic        i_reset,
  input  logic [31:0] i_pc,       
  output logic [31:0] o_pc_debug
);

always @(posedge i_clk) begin
	if (!i_reset) o_pc_debug <= 32'h00000000;
	else o_pc_debug <= i_pc;
end

endmodule
