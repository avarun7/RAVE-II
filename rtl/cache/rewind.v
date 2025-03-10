module rewind #(parameter OOO_TAG_SIZE= 10) (
    //Global
    input clk, 
    input rst,

    //From ROB
    input [OOO_TAG_SIZE-1:0] rob_ret_tag_in,
    input rob_valid,
    input rob_resteer,

    //From Cache
    input [31:0] addr_in,
    input [31:0] data_repl,
    input [2:0] operation,
    input [OOO_TAG_SIZE-1:0] cache_ooo_tag_in,
    input [1:0] size,

    //To Cache
    output valid_rewind,
    output [31:0] addr_out,
    output [31:0] data_out,
    output [2:0] operation_out,
    output [OOO_TAG_SIZE-1:0] cache_ooo_tag_out,
    output [1:0] size_out,
    output rewind_full
);

//Opeartion Names
localparam  NO_OP= 0;
localparam LD = 1;
localparam ST = 2;
localparam RD = 3;
localparam  WR= 4;
localparam  INV = 5;
localparam  UPD= 6;
localparam WR_LD = 7;

//State Names
localparam I = 1; //Invalid
localparam  PL= 11; //Pending Load
localparam  PS= 9; //Pending Store
localparam  PM= 10; //Pending Modified 
localparam  M= 4; //Modified
localparam  S= 2; //Shared
localparam PLS = 15; //Pending Load Store (edge case where store comes after load but before write)

wire [(1+1+1+OOO_TAG_SIZE)*8-1:0] old_m_vector;
wire [(1+1+1+OOO_TAG_SIZE)*8-1:0] new_m_vector;
reg[7:0] wr_ptr, rd_ptr;
wire[Q_LENGTH-1:0] modify_vector;
qnm #(.N_WIDTH(32+32+3+2), .M_WIDTH(1+1+1+OOO_TAG_SIZE), .Q_LENGTH(8)) q1(
    .m_din({1'b1, 1'b0,1'b0, cache_ooo_tag_in}),
    .n_din({addr_in,data_repl, operation, size}),
    .new_m_vector(new_m_vector),
    .wr(operation == ST), 
    .rd(rd),
    .modify_vector(modify_vector),
    .rst(rst),
    .clk(clk),
    .full(rewind_full), 
    .empty(empty),
    .old_m_vector(old_m_vector),
    .dout({addr_out, data_out, operation_out, size_out, valid_out, flush_out, ret_out, cache_ooo_tag_out})
);
assign valid_rewind = valid_out && flush_out;
assign rd = valid_out && (flush_out || ret_out) && ~empty;


initial begin
    wr_ptr = 1;
    rd_ptr = 1;
end

always @(posedge clk) begin
    if(rst) begin
        wr_ptr = 1;
        rd_ptr = 1;
    end
    if(operation == ST) wr_ptr <= wr_ptr[7] == 1 ? 1 : wr_ptr<<1;
end

genvar i;
for(i = 0; i < 8; i = i + 1) begin
    
    assign new_m_vector[i*(OOO_TAG_SIZE+3) +: OOO_TAG_SIZE] = old_m_vector[i*(OOO_TAG_SIZE+3) +: OOO_TAG_SIZE];
    
    assign modify_vector[i] = old_m_vector[i*(OOO_TAG_SIZE+3) +: OOO_TAG_SIZE] == rob_ret_tag_in || rob_resteer; 
    
    assign new_m_vector[i*(OOO_TAG_SIZE+3)+OOO_TAG_SIZE] = (old_m_vector[i*(OOO_TAG_SIZE+3) +: OOO_TAG_SIZE] == rob_ret_tag_in)&&rob_valid;
    
    assign new_m_vector[i*(OOO_TAG_SIZE+3)+OOO_TAG_SIZE+1] = rob_resteer && old_m_vector[i*(OOO_TAG_SIZE+3)+OOO_TAG_SIZE+2];
    
    assign new_m_vector[i*(OOO_TAG_SIZE+3)+OOO_TAG_SIZE+2] = old_m_vector[i*(OOO_TAG_SIZE+3)+OOO_TAG_SIZE+2];
end
endmodule