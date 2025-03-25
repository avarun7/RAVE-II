module lsq #(parameter Q_LENGTH = 8, OOO_TAG_BITS = 6, OOO_ROB_BITS = 6) (
    input clk,
    input rst,

    //From cache
    input rd,
    input wr,
    input [2:0] operation_in, 
    input [31:0] addr_in,
    input [31:0] data_in,
    input [OOO_TAG_BITS-1:0] ooo_tag_in,
    input [OOO_ROB_BITS-1:0] ooo_rob_in,
    input [1:0] size_in,
    
    //From MSHR  x
    input [2:0] mshr_wr_idx, //next location to be allocated into mshr
    input mshr_fin,
    input [2:0] mshr_fin_idx ,// location being deallocated from mshr

    //outputs 
    output [OOO_TAG_BITS-1:0] ooo_tag_out,
    output [31:0] data_out,
    output [31:0] addr_out,
    output [2:0] operation_out,
    output [1:0] size_out,
    output valid_out,
    output lsq_full
);

wire[2:0] mshr_wr_idx_out;  
wire[(3+1)*Q_LENGTH-1:0] new_m_vector;
wire[Q_LENGTH-1:0] modify_vector;
wire [(3+1)*Q_LENGTH-1:0] old_m_vector;

qnm #(.N_WIDTH(32+32+3+3+2+OOO_ROB_BITS), .M_WIDTH(1+OOO_TAG_BITS), .Q_LENGTH(8)) q1(
    .m_din({mshr_wr_idx, mshr_fin && mshr_fin_idx == mshr_wr_idx}),
    .n_din({ooo_rob_in, size_in,operation, addr_in, data_in, ooo_tag_in}),
    .new_m_vector(new_m_vector),
    .wr(wr), 
    .rd(rd),
    .modify_vector(modify_vector),
    .rst(rst),
    .clk(clk),
    .full(lsq_full), 
    .empty(),
    .old_m_vector(old_m_vector),
    .dout({ooo_rob_out, size_out, opeartion, addr_out, data_out, ooo_tag_out, mshr_wr_idx_out, valid_out})
);

genvar i;
for(i = 0; i < Q_LENGTH; i = i + 1) begin : hmm
    always @(*) begin
        if(old_m_vector[i*4]==0 && mshr_fin) begin
            new_m_vector[i*4] <= old_m_vector[i*5-1:i*4 + 1] == mshr_fin_idx;
            new_m_vector[i*5-1:i*4+1] <= old_m_vector[i*5-1:i*4 + 1];
            modify_vector <=  old_m_vector[i*5-1:i*4 + 1] == mshr_fin_idx;
        end
    end
end

endmodule