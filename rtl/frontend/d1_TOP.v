module d1_TOP #(parameter XLEN=32) (
    input clk, rst,

    //inputs
    input exception_in,
    input [511:0] IBuff_in,
    input [31:0] pc_in,
    input resteer,
    input [XLEN - 1:0] resteer_target_BR,
    input [XLEN - 1:0] resteer_target_ROB,

    input bp_update, //1b
    input bp_update_taken, //1b
    input [XLEN - 1:0] bp_update_target, //32
    input [9:0] bp_update_bhr,

    //outputs
    output [XLEN - 1:0] pc,
    output exception_out,
    output [2:0] opcode_format, //TODO
    output [XLEN - 1:0] instruction_out,
    output compressed_inst,
    
    output resteer_D1,
    output [XLEN - 1:0] resteer_target_D1,
    output resteer_taken,

    output ras_push,
    output ras_pop,
    output [XLEN - 1:0] ras_ret_addr

);

byte_rotator #(.XLEN(XLEN)) rotator (
    .data_in(IBuff_in),
    .shift(pc_in[5:0]),
    .data_out(instruction_out)
);

endmodule

module byte_rotator #(parameter XLEN=32) (
    input wire [511:0] data_in,         // 512-bit input (64 bytes)
    input wire [5:0] shift,             // Byte-wise shift (0 to 63)
    output wire [XLEN-1:0] data_out     // Output slice of rotated data
);
    wire [511:0] rotated_data;

    assign rotated_data = (data_in << (shift * 8)) | (data_in >> ((64 - shift) * 8));
    assign data_out = rotated_data[511 -: XLEN]; // cleaner slice syntax

endmodule
