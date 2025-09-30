// INPUT BUFFER

module input_buffer (
    input 	logic	      	i_clk,
    input 	logic	      	i_reset,
    input 	logic	[31:0]	i_sw_data,
    input 	logic	[31:0]	i_addr,
    output	logic	[31:0]	in_buffer
);

    // Address range for switches: 0x1001_0000 to 0x1001_0FFF
    localparam SWITCH_BASE_ADDR = 32'h1001_0000;
    localparam SWITCH_TOP_ADDR  = 32'h1001_0FFF;

    always_ff @ (posedge i_clk or negedge i_reset) begin
		if (!i_reset) begin	
			in_buffer <= 32'h0;
		end else if ((i_addr >= SWITCH_BASE_ADDR) && (i_addr <= SWITCH_TOP_ADDR)) begin
            in_buffer <= i_sw_data;
		end
	end
	
endmodule
