module f1_TOP(
    input clk, rst,
    //inputs
    input [25:0] cacheline_counter_in,
    input [25:0] nlpf,
    input [25:0] bppf,
    
    //TAG_STORE
    input [31:0] tag_in,  //TODO
    input [1:0] way_in,   //TODO
    input [1:0] evict_in, //TODO 

    //outputs
    output [31:0] clc_paddr, //TODO
    output [31:0] clc_vaddr,
    output pcd,         //don't cache MMIO
    output hit,
    output [1:0] way, //TODO
    output exceptions,
    
    output [31:0] bppf_paddr, //TODO
    output bppf_valid,        
    
    output [31:0] nlpf_paddr, //TODO
    output nlpf_valid,
    
    //TAG_STORE
    output [31:0] tag_out
);

endmodule