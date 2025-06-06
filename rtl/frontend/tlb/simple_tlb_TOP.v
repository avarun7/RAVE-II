module simple_tlb #(parameter XLEN = 32, CLC_WIDTH = 28)(
    input clk, rst,
    input [XLEN - 1 : 0] pc,
    input [CLC_WIDTH - 1 : 0] clc0_in,
    input [CLC_WIDTH - 1 : 0] clc1_in,
    input RW_in,            //check permissions, 0 is a read and 1 is a write
    input valid_in,         //if 1, then we are doing a memory request, else no exception should be thrown
    
    //outputs
    output reg pcd,             //don't cache MMIO
    output reg hit,
    output reg exception,
    output reg [2:0] exception_type,
    output reg [XLEN - 1 : 0] clc0_paddr,
    output reg [XLEN - 1 : 0] clc1_paddr,
    output reg clc0_paddr_valid,
    output reg clc1_paddr_valid
);

    // for a direct mapped TLB with only machine mode permissions

    always @(*) begin
        clc0_paddr <= {clc0_in, 4'b0};
        clc1_paddr <= {clc1_in, 4'b0};
        clc0_paddr_valid <= valid_in;
        clc1_paddr_valid <= valid_in;

        hit <= 1'b1;

        exception <= 1'b0;
        exception_type <= 3'b000;
    end

endmodule