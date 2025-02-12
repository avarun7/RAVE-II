module mshr #(parameter Q_LEGNTH = 8) (
    //Global
    input clk,
    input rst,    

    //alloc from cache
    input alloc,
    input [2:0] operation_cache,
    input [25:0] addr_cache,

    //from l2
    input l22q_valid,
    input l2_ldst,
    input [25:0] addr_l2,

    //output to cache
    output mshr_hit,
    output reg [$clog2(Q_LEGNTH)-1:0] mshr_wr_ptr,
    output [$clog2(Q_LEGNTH)-1:0] mshr_fin_ptr,
    output mshr_fin,

    output mshr_full
);
wire[7:0] modify_vector;
wire [28*8-1:0] new_m_vector;
genvar i;
for(i = 0; i < 8; i = i + 1) begin
    assign modify_vector[i]  = {addr_l2, l2_ldst} == old_m_vector[27+i*8:1+8*i];
    assign new_m_vector[i*28] = 1;
    assign new_m_vector[i*28 + 27 : i*28 +1 ] = old_m_vector[1*28 + 27 : i * 28 + 1];
end

wire [28*8-1:0] old_m_vector;
wire[26:0] addr_out;
qnm #(.N_WIDTH(0), .M_WIDTH(1+1+26), .Q_LENGTH(8)) q1(
    .m_din({addr_cache, operation_cache == 2,0}),
    .n_din(),
    .new_m_vector(new_m_vector),
    .wr(alloc), 
    .rd(valid_out),
    .modify_vector(modify_vector),
    .rst(rst),
    .clk(clk),
    .full(mshr_full), 
    .empty(),
    .old_m_vector(old_m_vector),
    .dout({addr_out, ld_st_out, valid_out})
);
always @(posedge clk) begin
    if(rst) begin
        mshr_wr_ptr <= 0;
    end
    else begin
        if(alloc) begin 
            mshr_wr_ptr <= mshr_wr_ptr == 7 ? 0 : mshr_wr_ptr + 1;
        end
    end
end

endmodule