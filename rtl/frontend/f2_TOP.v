module f2_TOP #(parameter XLEN=32) (
    input clk, rst,

    //inputs
    input [XLEN - 1:0] clc_paddr, //TODO
    input [XLEN - 1:0] clc_vaddr, //TODO

    input pcd,         //don't cache MMIO
    input hit,
    input [1:0] way, //TODO
    input exceptions,

    input [XLEN - 1:0] bppf_paddr, //TODO
    input bppf_valid,

    input [XLEN - 1:0] nlpf_paddr, //TODO
    input nlpf_valid,

    //TAG_STORE
    input [XLEN - 1:0] tag_evict, //TODO

    //DATASTORE
    input [2:0] l2_icache_op, 
    input [2:0] l2_icache_state,
    input [XLEN - 1:0] l2_icache_addr,
    input [511:0] l2_icache_data_in,

    //outputs
    output exceptions_out,

    //Tag Store Overwrite
    output [XLEN - 1:0] tag_ovrw, //TODO
    output [1:0] way_ovrw,  //TODO

    output [XLEN - 1:0] IBuff_out,

    output prefetch_valid,
    output [XLEN - 1:0] prefetch_addr,

    //Datastore
    output [2:0] icache_l2_op,
    output [2:0] icache_l2_state,
    output [XLEN - 1:0] icache_l2_addr,
    output [511:0] icache_l2_data_out
);

endmodule
