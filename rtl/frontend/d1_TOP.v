module d1_TOP(
    input clk, rst,

    //inputs
    input exception_in,
    input [31:0] IBuff_in,
    input resteer,
    input [31:0] resteer_target_BR,
    input [31:0] resteer_target_ROB,

    input bp_update, //1b
    input bp_update_taken, //1b
    input [31:0] bp_update_target, //32
    input [9:0] pcbp_update_bhr,

    //outputs
    output [31:0] pc,
    output exception_out,
    output [4:0] opcode_format, //TODO
    output [31:0] instruction_out,
    
    output resteer_D1,
    output [31:0] resteer_target_D1,
    output resteer_taken,
    output [9:0] clbp_update_bhr_D1,

    output ras_push,
    output ras_pop,
    output [31:0] ras_ret_addr

);

endmodule
