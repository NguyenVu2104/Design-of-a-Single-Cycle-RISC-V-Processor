// OUTPUT BUFFER

module output_buffer (
    input	logic	      	i_clk,
    input	logic	      	i_reset,
    input	logic	      	i_wren,
    input	logic	[31:0]	i_addr,
    input	logic	[31:0]	i_data,
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
    output	logic	[31:0]	o_io_lcd,

	// Out Buffer Reg
	output logic [31:0] out_buffer
);

    // Address ranges
    localparam RED_BASE_ADDR   = 6'b100000;		// 0x1000_0000 - 0x1000_0FFF
    localparam GREEN_BASE_ADDR = 6'b100001;		// 0x1000_1000 - 0x1000_1FFF
    localparam HEX03_BASE_ADDR = 6'b100010;		// 0x1000_2000 - 0x1000_2FFF
    localparam HEX47_BASE_ADDR = 6'b100011;		// 0x1000_3000 - 0x1000_3FFF
    localparam LCD_BASE_ADDR   = 6'b100100;     // 0x1000_4000 - 0x1000_4FFF

    always_ff @(posedge i_clk or negedge i_reset) begin
        if (!i_reset) begin
			out_buffer <= 32'h0;
        end else if (i_wren && i_addr[28] && ~i_addr[16]) out_buffer <= i_data;
    end
	
	always_latch begin
		case ({i_addr[28], i_addr[16:12]})
			// RED LEDS
			RED_BASE_ADDR:    o_io_ledr = out_buffer;
			
			// GREEN LEDS
			GREEN_BASE_ADDR:  o_io_ledg = out_buffer;
			
			// LCD
			LCD_BASE_ADDR:    o_io_lcd  = out_buffer;
			
			// HEX 0 - 3
			HEX03_BASE_ADDR: begin
				o_io_hex0 = out_buffer[6:0];
				o_io_hex1 = out_buffer[14:8];
				o_io_hex2 = out_buffer[22:16];
				o_io_hex3 = out_buffer[30:24];
			end
			
			// HEX 4 - 7
			HEX47_BASE_ADDR: begin
				o_io_hex4 = out_buffer[6:0];
				o_io_hex5 = out_buffer[14:8];
				o_io_hex6 = out_buffer[22:16];
				o_io_hex7 = out_buffer[30:24];
			end
			
			// Do nothing
			default: ;
		endcase
	end
	
endmodule
