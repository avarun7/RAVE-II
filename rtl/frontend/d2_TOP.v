module d2_TOP(
    input clk, rst,

    //inputs
    input [31:0] pc_in, //TODO
    input exception_in,
    input [1:0] uop_count,
    input [4:0] opcode_format, //TODO
    input [31:0] instruction_in,

    //outputs
    output [31:0] uop, //TODO
    output eoi,
    output [4:0] dr, sr1, sr2,
    output [31:0] imm,
    output use_imm,
    output [31:0] pc_out,
    output exception_out
);

endmodule