module f1_TOP #(parameter XLEN=32) (
    input clk, rst,
    //inputs
    input [25:0] clc_in,
    input [25:0] nlpf,
    
    //outputs
    output pcd,         //don't cache MMIO
    output hit,
    output exceptions,
    
    output [XLEN - 1:0] clc_paddr, //TODO
    output clc_valid,
        
    output [XLEN - 1:0] nlpf_paddr, //TODO
    output nlpf_valid,

    output reg [XLEN - 1:0] addr_even,
    output reg [XLEN - 1:0] addr_odd
);

    simple_tlb #(.XLEN(XLEN), .CLC_WIDTH(26)) tlb (
        .clk(clk), .rst(rst),
        .pc(),
        .clc0_in(clc_in),
        .clc1_in(nlpf),
        .RW_in(1'b0),
        .valid_in(1'b1),
        
        //outputs
        .pcd(pcd),
        .hit(hit),
        .exception(),
        .exception_type(),
        .clc0_paddr(clc_paddr),
        .clc1_paddr(nlpf_paddr),
        .clc0_paddr_valid(clc_valid),
        .clc1_paddr_valid(nlpf_valid)
    );

    // logic to check if the address is even or odd, and generate the even and odd addresses
    always @(*) begin
        if (clc_in[0] == 1'b0) begin
            addr_even <= clc_paddr;
            addr_odd <= clc_paddr + 1;
        end else begin
            addr_even <= clc_paddr - 1;
            addr_odd <= clc_paddr;
        end
    end

endmodule