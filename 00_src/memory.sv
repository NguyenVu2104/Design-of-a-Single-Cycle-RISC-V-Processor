// Memory

module memory #(
	parameter	MEM_DEPTH = 512
) (
	input	logic         	i_clk,
	input	logic     		i_reset,
	input	logic	[31:0]	i_addr,
	input	logic	[31:0]	i_wdata,
	input	logic	[3:0]	i_bmask,
	input	logic			i_wren,

	input	logic			u,			// 1 for unsigned, 0 for signed
	
	output 	logic  	[31:0] 	o_rdata
);	
	localparam MEM_TOP_ADDR = 32'h0000_07FF;

	// 2KiB memory = 512 words
	logic [31:0] mem [0:MEM_DEPTH-1];	// 512 row array, 32bit/row
    
	// Word address (addr[10:2] gives 9-bit index)
    logic [8:0] addr_index;
    assign addr_index = i_addr[10:2];

	// LOAD
	always_comb begin
		o_rdata = 32'h0;
		if (i_addr <= MEM_TOP_ADDR) begin
			case (i_bmask)
				// LB / LBU
				4'b0001: o_rdata = (u) ? {24'b0, mem[addr_index][7:0]} : {{24{mem[addr_index][7]}},  mem[addr_index][7:0]};
				
				// LH / LHU
				4'b0011: o_rdata = (u) ? {16'b0, mem[addr_index][15:0]} : {{16{mem[addr_index][15]}}, mem[addr_index][15:0]};
				
				// LW
				4'b1111: o_rdata = mem[addr_index];
				
				default: o_rdata = 32'h0;
			endcase
		end else o_rdata = 32'hDEAD_BEEF;	// Invalid address
	end
	
	// STORE
	always_ff @(posedge i_clk or negedge i_reset) begin
		if (!i_reset) begin
			mem <= '{default: 32'h0};
		end else if (i_wren && (i_addr <= MEM_TOP_ADDR)) begin
			// SB / SH / SW
			case (i_bmask)
				// SB
				4'b0001: mem[addr_index][7:0] <= i_wdata[7:0];
				
				// SH
				4'b0011: mem[addr_index][15:0] <= i_wdata[15:0];
				
				// SW
				4'b1111: mem[addr_index] <= i_wdata;
				
				default: ;
			endcase
		end
	end
	
endmodule
