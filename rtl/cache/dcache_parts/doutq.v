module doutq #(parameter Q_LENGTH = 8, DATA_SIZE = 32, OOO_TAG_SIZE = 10, OOO_ROB_SIZE = 10) (
    input clk, rst,

    input[31:0] addr_in,
    input [DATA_SIZE-1:0] data_in,
    input [2:0] operation_in,
    input is_flush_in,
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
    output is_st_out,
    output is_flush_out,
    output [OOO_TAG_SIZE-1:0] tag_out,
    output [OOO_ROB_SIZE-1:0] rob_line_out,
    output valid_out
);
wire [2:0] operation_out;
localparam  NO_OP= 0;
localparam LD = 1;
localparam ST = 2;
localparam RD = 3;
localparam  WR= 4;
localparam  INV = 5;
localparam  UPD= 6;
localparam RWITM = 7;
localparam RINV = 7;
localparam REPLY = 2;
assign is_st_out = operation_out == ST;

assign valid_out = !valid_n & ~resteer;
qn #(.N_WIDTH(32 + DATA_SIZE + 3 + 1 + OOO_TAG_SIZE + OOO_ROB_SIZE), .M_WIDTH(0), .Q_LENGTH(Q_LENGTH)) q1(
    .m_din(),
    .n_din({rob_line_in, tag_in, is_flush_in, operation_in, addr_in, data_in}),
    .new_m_vector(2'b0),
    .wr(alloc), 
    .rd(dealloc && valid_out),
    .modify_vector(8'b0),
    .rst(rst | resteer),
    .clk(clk),
    .full(full), 
    .empty(valid_n),
    .old_m_vector(),
    .dout({rob_line_out, tag_out, is_flush_out, operation_out, addr_out, data_out})
);


endmodule