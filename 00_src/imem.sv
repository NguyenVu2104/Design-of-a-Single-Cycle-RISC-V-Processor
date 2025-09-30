// Imem

module imem (
	input	logic	[31:0]	imem_addr,
	output	logic	[31:0]	imem_data
);

	logic [31:0] imem [0:2048];
	initial $readmemh ("D:\switch2hex2.dump", imem);
	// initial $readmemh ("/home/cpa/ca109/Desktop/sc-test/02_test/isa.mem", imem);
	
	always_comb begin
          imem_data = imem[imem_addr[13:2]];
        end
	
endmodule
