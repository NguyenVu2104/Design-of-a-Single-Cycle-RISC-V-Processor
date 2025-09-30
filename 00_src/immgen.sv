// Imm Gen

module immgen(
	input 	logic	[31:0]	i_ins,
	output	logic	[31:0]	o_imm
);

    logic [6:0] opcode;
    logic [2:0] funct3;
    assign opcode = i_ins[6:0];
    assign funct3 = i_ins[14:12];

    always_comb begin
        case (opcode)
            // U-type: LUI, AUIPC
            7'b0110111, 7'b0010111: 
                o_imm = {i_ins[31:12], 12'b0};
				
            // J-type: JAL
            7'b1101111: 
                o_imm = {{12{i_ins[31]}}, i_ins[19:12], i_ins[20], i_ins[30:21], 1'b0};
            
			// B-type: Branch
            7'b1100011: 
                o_imm = {{19{i_ins[31]}}, i_ins[31], i_ins[7], i_ins[30:25], i_ins[11:8], 1'b0};
            
			// S-type: Store
            7'b0100011: 
                o_imm = {{20{i_ins[31]}}, i_ins[31:25], i_ins[11:7]};
            
			// I-type: Load, JALR, Arithmetic
            7'b0000011, 7'b1100111, 7'b0010011: begin
                if (opcode == 7'b0010011 && (funct3 == 3'b001 || funct3 == 3'b101)) begin
                    // Shift inss (SLLI, SRLI, SRAI): no extending
                    o_imm = {27'b0, i_ins[24:20]};
                end else begin
                    // Other I-type: extending
                    o_imm = {{20{i_ins[31]}}, i_ins[31:20]};
                end
            end

            default: 
                o_imm = 32'b0;
        endcase
    end

endmodule
