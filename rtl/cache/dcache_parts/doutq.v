module doutq #(parameter Q_LENGTH = 8, DATA_SIZE = 32, OOO_TAG_SIZE = 10, OOO_ROB_SIZE = 10) (
    input clk, rst,

    input[31:0] addr_in,
    input [DATA_SIZE-1:0] data_in,
    input [2:0] operation_in,
    input is_flush,
    input [OOO_TAG_SIZE-1:0] tag_in,
    input [OOO_ROB_SIZE-1:0] rob_line_in,
    input alloc,

    //From ROB
    input dealloc,
    input resteer,

    //TO CACHE
    output full,

    //TO ROB
    output[31:0] addr_out,
    output [DATA_SIZE-1:0] data_out,
    output [2:0] operation_out,
    output is_flush_out,
    output [OOO_TAG_SIZE-1:0] tag_out,
    output [OOO_ROB_SIZE-1:0] rob_line_out,
    output valid_out
);

endmodule