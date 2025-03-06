module data_q #(parameter Q_LENGTH = 8, CL_SIZE = 128) (
    //System     
    input clk,
    input rst,

    //From Sender
    input[31:0] addr_in,
    input [CL_SIZE-1:0] data_in,
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
    output [CL_SIZE-1:0] data_out,
    output [2:0] operation_out,
    output  valid,
    output [1:0] src_out,
    output [1:0] dest_out,
    output is_flush_out

);
assign valid = !valid_n;
qn #(.N_WIDTH(32 + CL_SIZE + 8), .M_WIDTH(0), .Q_LENGTH(Q_LENGTH)) q1(
    .m_din(),
    .n_din({src, dest, is_flush, operation_in, addr_in, data_in}),
    .new_m_vector(2'b0),
    .wr(alloc), 
    .rd(dealloc && valid),
    .modify_vector(8'b0),
    .rst(rst),
    .clk(clk),
    .full(full), 
    .empty(valid_n),
    .old_m_vector(),
    .dout({src_out, dest_out, is_flush_out, operation_out, addr_out, data_out})
);

endmodule 