module icache #(parameter SET_CNT = 1024,parameter CACHE_LINE = 512, parameter ADDR_SZ = 32) (
    //Global
    input clk,
    input rst,

    //Inputs from F1
    input [31:0] f1_address_in,
    input [2:0] f1_op_in,

    //Outputs from F1
    output [31:0] f1_v_addr_out,
    output [31:0] f1_p_addr_out,
    output [3:0] f1_exception_out,
    output [CACHE_LINE * 4 - 1: 0] f1_data_out,
    output [(ADDR_SZ - $clog2(SET_CNT) - $clog2(CACHE_LINE)) * 4 - 1:0] f1_tag_out,
    output [4*4-1:0] f1_meta_out,
    output [31:0] f1_lru_out,
    output [3:0] f1_hit_out,
    output f1_is_l2_req,
    

    //Inputs from F2
    input f2_op_in,
    input [31:0] f2_v_addr_in,
    input [31:0] f2_p_addr_in,
    input [3:0] f2_exception_in,
    input [CACHE_LINE * 4 - 1: 0] f2_data_in,
    input [(ADDR_SZ - $clog2(SET_CNT) - $clog2(CACHE_LINE)) * 4 - 1:0] f2_tag_in,
    input [4*4-1:0] f2_meta_in,
    input [31:0] f2_lru_in,
    input [3:0] f2_hit_in,
    input f2_is_l2_req,

    //Outputs from F2
    output [1:0] f2_hit_out,
    output [CACHE_LINE-1:0] f2_cache_line_out,


    //Inputs from L2
    input [2:0] l2_icache_op, // (R, W, RWITM, flush, update)
    input [31:0] l2_icache_addr, 
    input [CACHE_LINE-1:0]l2_icache_data, 
    input [3:0] l2_icache_state, 

    //Outputs to L2
    output [2:0]  icache_l2_op, 
    output [31:0] icache_l2_addr, 
    output [CACHE_LINE-1:0] icache_l2_data_out, 
    output [3:0]  icache_l2_state
);

    itag_store()

    idata_store()

    iupdate_logic()

    tlb_TOP #(32, 26)();

    tlb()
endmodule 