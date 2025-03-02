module instr_q #(parameter Q_LEGNTH = 8, OOO_TAG_SIZE = 10, CL_SIZE = 128) (
    //System     
    input clk,
    input rst,

    //From Sender
    input[31:0] addr_in,
    input [2:0] operation_in,
    input is_flush,
    input alloc,
    input [1:0] src,
    input [1:0] dest,

    //From reciever
    input dealloc,

    //output sender
    output full,

    //output reciever
    output [31:0] addr_out,
    output [2:0] operation_out, 
    output  valid,
    output [1:0] src_out,
    output [1:0] dest_out,
    output is_flush_out
    

);
assign valid = !valid_n;
qnm #(.N_WIDTH(32 + 8), .M_WIDTH(0), .Q_LENGTH(Q_LENGTH)) q1(
    .m_din(),
    .n_din({src, dest, is_flush, operation, addr_in}),
    .new_m_vector(0),
    .wr(alloc), 
    .rd(dealloc),
    .modify_vector(0),
    .rst(rst),
    .clk(clk),
    .full(full), 
    .empty(valid_n),
    .old_m_vector(),
    .dout({src_out, dest_out, is_flush_out,operation, addr_in})
);

endmodule 