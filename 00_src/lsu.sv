// LSU

module lsu (
	input	logic	      	i_clk,
	input	logic	      	i_reset,
	input	logic	[31:0]	i_lsu_addr,
	input	logic	[31:0]	i_st_data,
	input	logic	      	i_lsu_wren,

	// Operation
	input	logic	[3:0]	i_bmask,

	// Unsigned signal
	input	logic			i_u,

	// Perps
	input 	logic	[31:0]	i_io_sw,
	output	logic	[31:0]	o_ld_data,
	output	logic	[31:0]	o_io_ledr,
	output	logic	[31:0]	o_io_ledg,
	output	logic	[6:0] 	o_io_hex0,
	output	logic	[6:0] 	o_io_hex1,
	output	logic	[6:0] 	o_io_hex2,
	output	logic	[6:0] 	o_io_hex3,
	output	logic	[6:0] 	o_io_hex4,
	output	logic	[6:0] 	o_io_hex5,
	output	logic	[6:0] 	o_io_hex6,
	output	logic	[6:0] 	o_io_hex7,
	output	logic	[31:0]	o_io_lcd
);

    // Internal wires
    logic [31:0] mem_rdata;
    logic [31:0] sw_rdata;
	logic [31:0] out_buffer;
	
    // Simple logic to determine target region
    logic  is_mem, is_inp, is_outp;
    assign is_mem  = (i_lsu_addr <= 32'h0000_07FF);
    assign is_inp  = (i_lsu_addr >= 32'h1001_0000 && i_lsu_addr <= 32'h1001_0FFF);
    assign is_outp = (i_lsu_addr >= 32'h1000_0000 && i_lsu_addr <= 32'h1000_4FFF);

    // Memory
    memory data_memory (
        .i_clk(i_clk),
        .i_reset(i_reset),
        .i_addr(i_lsu_addr),
        .i_wdata(i_st_data),
        .i_bmask(i_bmask),
        .i_wren(i_lsu_wren && is_mem),
        .u(i_u),
        .o_rdata(mem_rdata)
    );

    // Input Buffer
    input_buffer input_buffer (
        .i_clk(i_clk),
        .i_reset(i_reset),
        .i_sw_data(i_io_sw),
        .i_addr(i_lsu_addr),
        .in_buffer(sw_rdata)
    );

    // Output Buffer
    output_buffer output_buffer (
        .i_clk(i_clk),
        .i_reset(i_reset),
        .i_wren(i_lsu_wren && is_outp),
        .i_addr(i_lsu_addr),
        .i_data(i_st_data),
        .o_io_ledr(o_io_ledr),
        .o_io_ledg(o_io_ledg),
        .o_io_hex0(o_io_hex0),
        .o_io_hex1(o_io_hex1),
        .o_io_hex2(o_io_hex2),
        .o_io_hex3(o_io_hex3),
        .o_io_hex4(o_io_hex4),
        .o_io_hex5(o_io_hex5),
        .o_io_hex6(o_io_hex6),
        .o_io_hex7(o_io_hex7),
        .o_io_lcd(o_io_lcd),
		.out_buffer(out_buffer)
    );

    // Read MUX
    always_comb begin
        if (is_mem)
            o_ld_data = mem_rdata;
        else if (is_inp)
            o_ld_data = sw_rdata;
		else if (is_outp)
			o_ld_data = out_buffer;
        else
            o_ld_data = 32'hDEAD_BEEF;
    end

endmodule
