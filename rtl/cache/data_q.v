module data_q #(parameter Q_LEGNTH = 8, OOO_TAG_SIZE = 10, CL_SIZE = 128) (
    //System     
    input clk,
    input rst,

    //From Sender
    input[31:0] addr_in,
    input [CL_SIZE-1:0] data_in,
    input [2:0] operation_in,
    input alloc,

    //From reciever
    input dealloc,

    //output sender
    output full,

    //output reciever
    output [31:0] addr_out,
    output [CL_SIZE-1:0] data_out,
    output [2:0] operation_out,
    output  valid

);
assign valid = !valid_n;
qnm #(.N_WIDTH(32 + CL_SIZE + 3), .M_WIDTH(0), .Q_LENGTH(Q_LENGTH)) q1(
    .m_din(),
    .n_din({operation, addr_in, data_in}),
    .new_m_vector(0),
    .wr(alloc), 
    .rd(dealloc),
    .modify_vector(0),
    .rst(rst),
    .clk(clk),
    .full(full), 
    .empty(valid_n),
    .old_m_vector(),
    .dout({operation, addr_in, data_out})
);

endmodule 