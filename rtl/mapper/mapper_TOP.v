module mapper_TOP(
    input clk, rst,

    //inputs
    input [31:0] uop, //TODO
    input eoi,
    input [4:0] dr, sr1, sr2,
    input [31:0] imm,
    input use_imm,
    input [31:0] pc,
    input exception_in, //TODO

    input [31:0] rob_write_ptr, //comes from ROB
    input rob_full,

    input [4:0] fu_full, //one hot, one for each FU

    //outputs
    output [4:0] fu_target, //tells which func unit this instruction is using
    output [31:0] rob_entry, //index into ROB to be used for this uop
    output src1_valid
    output [] src1_tag,
    output src2_valid,
    output [] src2_tag,

    output eoi_out,
    output exception_out
);

endmodule