module f1_TOP #(parameter XLEN=32, CLC_WIDTH=26) (
    input clk, rst,
    //inputs
    input [CLC_WIDTH - 1:0] clc_even_in,
    input [CLC_WIDTH - 1:0] clc_odd_in,
    
    //outputs
    output pcd,         //don't cache MMIO
    output hit,
    output exceptions,
    
    output addr_even_valid,
    output addr_odd_valid,
    output wire [XLEN - 1:0] addr_even,
    output wire [XLEN - 1:0] addr_odd
);

    simple_tlb #(.XLEN(XLEN), .CLC_WIDTH(26)) tlb (
        .clk(clk), .rst(rst),
        .pc(),
        .clc0_in(clc_even_in),
        .clc1_in(clc_odd_in),
        .RW_in(1'b0),
        .valid_in(1'b1),
        
        //outputs
        .pcd(pcd),
        .hit(hit),
        .exception(),
        .exception_type(),
        .clc0_paddr(addr_even),
        .clc1_paddr(addr_odd),
        .clc0_paddr_valid(addr_even_valid),
        .clc1_paddr_valid(addr_odd_valid)
    );


endmodule