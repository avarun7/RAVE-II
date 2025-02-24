module mshr #(parameter Q_LEGNTH = 8) (
    //Global
    input clk,
    input rst,    

    //alloc from cache
    input alloc,
    input [2:0] operation_cache,
    input [27:0] addr_cache,

    //from l2
    input l22q_valid,
    input l2_ldst,
    input [27:0] addr_l2,

    //output to cache
    output mshr_hit, //done
    output reg [$clog2(Q_LEGNTH)-1:0] mshr_wr_ptr, //done
    output [$clog2(Q_LEGNTH)-1:0] mshr_fin_ptr, //done
    output mshr_fin,//done

    output mshr_full //done
);
assign mshr_hit = |hit_vector;
assign mshr_fin = |modify_vector && l22q_valid;
wire[7:0] modify_vector, hit_vector;
wire [30*8-1:0] new_m_vector;
genvar i;
for(i = 0; i < 8; i = i + 1) begin
    assign modify_vector[i]  = {addr_l2, l2_ldst} == old_m_vector[29+i*8:1+8*i];
    assign new_m_vector[i*30] = 1;
    assign new_m_vector[i*30 + 27 : i*30 +1 ] = old_m_vector[1*30 + 27 : i * 30 + 1];
    assign hit_vector[i] = {addr_cache, operation_cache == 2} == old_m_vector[29+i*8:1+8*i];

end

wire [30*8-1:0] old_m_vector;
wire[27:0] addr_out;
qnm #(.N_WIDTH(0), .M_WIDTH(1+1+28), .Q_LENGTH(8)) q1(
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

onehot_2_bin o2b(
    .a(modify_vector),
    .b(mshr_fin_ptr)
);

endmodule

module onehot_2_bin (
    input a[7:0],
    output b[2:0]
);
    always @(*) begin
        case(a)
        1: b <=0;
        2:b <=1;
        4:b <=2;
        8:b <=3;
        16:b <=4;
        32:b <=5;
        64:b <=6;
        128:b <=7;
        endcase
    end
endmodule