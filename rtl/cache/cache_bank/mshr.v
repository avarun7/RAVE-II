module mshr #(parameter Q_LEGNTH = 8) (
    //Global
    input clk,
    input rst,    

    //alloc from cache
    input alloc,
    input [2:0] operation_cache,
    input [31:0] addr_cache,

    //from l2
    input l22q_valid,
    input l2_ldst,
    input [31:0] addr_l2,

    //output to cache
    output mshr_hit, //done
    output [$clog2(Q_LEGNTH)-1:0] mshr_hit_ptr,
    output reg [$clog2(Q_LEGNTH)-1:0] mshr_wr_ptr, //done
    output [$clog2(Q_LEGNTH)-1:0] mshr_fin_ptr, //done
    output mshr_fin,//done

    output mshr_full //done
);
wire[7:0] modify_vector, hit_vector;
wire [30*8-1:0] new_m_vector;
wire [29:0] hit_first; 
wire [29:0] hit_second[0:7];

assign mshr_hit = |hit_vector;
assign mshr_fin = |modify_vector && l22q_valid;
wire[31:0] old_v_0;
assign hit_first = {addr_cache[31:4], 1'b0};
assign old_v_0 = old_m_vector[29:1];
genvar i;
for(i = 0; i < 8; i = i + 1) begin
    assign modify_vector[i]  = {addr_l2[31:4], 1'b0} == old_m_vector[29+i*30:1+30*i];
    assign new_m_vector[i*30] = 1;
    assign new_m_vector[i*30 + 29 : i*30 +1 ] = old_m_vector[i*30 + 29 : i * 30 + 1];
    assign hit_vector[i] = {addr_cache[31:4], 1'b0} == old_m_vector[29+i*30:1+30*i];
    assign hit_second[i] = old_m_vector[29+i*30:1+30*i];

end

wire [30*8-1:0] old_m_vector;
wire[27:0] addr_out;
qm #(.N_WIDTH(0), .M_WIDTH(1+1+28), .Q_LENGTH(8)) q1(
    .m_din({addr_cache[31:4], 1'b0,1'b0}),
    .n_din(),
    .new_m_vector(new_m_vector),
    .wr(alloc), 
    .rd(valid_out && ~valid_n),
    .modify_vector(modify_vector),
    .rst(rst),
    .clk(clk),
    .full(mshr_full), 
    .empty(valid_n),
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
onehot_2_bin o2b2(
    .a(hit_vector),
    .b(mshr_hit_ptr)
);
endmodule

module onehot_2_bin (
    input [7:0]a,
    output reg[2:0]b
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
        default:b <=  0;
        endcase
    end
endmodule