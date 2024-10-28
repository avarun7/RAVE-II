module f2_TOP(
    input clk, rst,

    //inputs
    input [31:0] clc_paddr, //TODO
    input [31:0] clc_vaddr, //TODO

    input pcd,         //don't cache MMIO
    input hit,
    input [1:0] way, //TODO
    input exceptions,

    input [31:0] bppf_paddr, //TODO
    input bppf_valid,

    input [31:0] nlpf_paddr, //TODO
    input nlpf_valid,

    //TAG_STORE
    input [31:0] tag_evict, //TODO

    //DATASTORE
    input [2:0] icache_l2_op, 
    input [2:0] icache_l2_state,
    input [31:0] icache_l2_addr,
    input [511:0] icache_l2_data_in,

    //outputs
    output exceptions_out,

    //Tag Store Overwrite
    output [31:0] tag_ovrw, //TODO
    output [1:0] way_ovrw,  //TODO

    output [31:0] IBuff_out,

    output prefetch_valid,
    output [31:0] prefetch_addr,

    //Datastore
    output [2:0] icache_l2_op_out,
    output [2:0] icache_l2_state_out,
    output [31:0] icache_l2_addr_out,
    output [511:0] icache_l2_data_out
);

endmodule