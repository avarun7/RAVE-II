module dinpq #(parameter Q_LENGTH = 8, DATA_SIZE = 32, OOO_TAG_SIZE = 10, OOO_ROB_SIZE = 10, CL_SIZE = 128) (

input clk,
input rst,
input resteer,

//FROM RSV
input alloc, //Data from RAS is valid or not

input [31:0] addr_in,
input [31:0] data_in,
input [1:0] size_in, //
input is_st_in, //Say whether input is ST or LD
input [OOO_TAG_SIZE-1:0] ooo_tag_in, //tag from register renaming
input [OOO_ROB_SIZE-1:0] ooo_rob_in,
input sext_in,

input dealloc,

output valid,

output [31:0] addr_out,
output [CL_SIZE-1:0] data_out,
output [1:0] size_out, //
output [2:0] operation_out, //Say whether input is ST or LD
output [OOO_TAG_SIZE-1:0] ooo_tag_out, //tag from register renaming
output [OOO_ROB_SIZE-1:0] ooo_rob_out,
output [1:0] src_out, dest_out,
output sext_out,

output full

);
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
wire[2:0] operation_in;
assign operation_in = is_st_in ? ST : LD;
assign valid = !valid_n & ~resteer;
qn #(.N_WIDTH(32 + 32 + 8 + 1 + OOO_TAG_SIZE + OOO_ROB_SIZE), .M_WIDTH(0), .Q_LENGTH(Q_LENGTH)) q1(
    .m_din(),
    .n_din({sext_in, ooo_rob_in, ooo_tag_in, 2'd0, 2'd0, 1'd0, operation_in, addr_in, data_in}),
    .new_m_vector(2'b0),
    .wr(alloc), 
    .rd(dealloc && valid),
    .modify_vector(8'b0),
    .rst(rst | resteer),
    .clk(clk),
    .full(full), 
    .empty(valid_n),
    .old_m_vector(),
    .dout({sext_out, ooo_rob_out, ooo_tag_out,src_out, dest_out, is_flush_out, operation_out, addr_out, data_out[31:0]})
);
assign data_out[127:32] = 0;
endmodule


