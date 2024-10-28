module c_TOP(
    input clk, rst,

    //inputs
    input stall_in,
    input resteer,
    
    input bp_update_D1, //1b
    input [31:0] resteer_target_D1,
    input resteer_taken_D1,
    input [9:0] clbp_update_bhr_D1,  

    input bp_update_BR, //1b
    input [31:0] resteer_target_BR,
    input resteer_taken_BR,
    input [9:0] clbp_update_bhr_BR,  

    input bp_update_ROB, //1b
    input [31:0] resteer_target_ROB,
    input resteer_taken_ROB,
    input [9:0] clbp_update_bhr_ROB,

    input ras_push,
    input ras_pop,
    input [31:0] ras_ret_addr,
    
    //outputs
    output [25:0] clc, //cacheline counter 
    output [25:0] nlpf, //next-line prefetch
    output [25:0] bppf  //branch-predictor prefetch
);

endmodule

