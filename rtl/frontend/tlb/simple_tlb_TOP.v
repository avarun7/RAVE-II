module tlb_TOP #(parameter XLEN = 32, CLC_WIDTH = 26)(
    input clk, rst,
    input [XLEN - 1 : 0] pc,
    input [CLC_WIDTH - 1 : 0] clc0_in,
    input [CLC_WIDTH - 1 : 0] clc1_in,
    input RW_in,            //check permissions, 0 is a read and 1 is a write
    input valid_in,         //if 1, then we are doing a memory request, else no exception should be thrown
    
    //outputs
    output pcd,             //don't cache MMIO
    output hit,
    output exception,
    output [2:0] exception_type,
    output [CLC_WIDTH - 1 : 0] clc0_paddr,
    output [CLC_WIDTH - 1 : 0] clc1_paddr,
    output clc0_paddr_valid,
    output clc1_paddr_valid
);

    // for a direct mapped TLB with only machine mode permissions

    assign clc0_paddr = clc0_in;
    assign clc1_paddr = clc1_in;
    assign clc0_paddr_valid = valid_in;
    assign clc1_paddr_valid = valid_in;

    assign hit = 1'b1;

    assign exception = 1'b0;
    assign exception_type = 3'b000;


endmodule