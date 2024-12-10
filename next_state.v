module inext_state  #(parameter SET_CNT = 1024,parameter CACHE_LINE = 512, parameter ADDR_SZ = 32) (
    input clk,
    input rst,

    input valid_in,
    input [5*4-1:0] f2_meta_in,
    input f2_ld,
    input f2_st,
    input l2_w,
    input l2_inv,
    input f2_evict,
    input [3:0] hit_way,
    input [3:0] evict_way,

    output reg [5*4-1:0] next_meta_out
);
reg[4:0] cur_state;
wire[4:0] meta_w3, meta_w2, meta_w1, meta_w0;
assign meta_w3 = f2_meta_in[19:15];
assign meta_w2 = f2_meta_in[14:10];
assign meta_w1 = f2_meta_in[9:5];
assign meta_w0 = f2_meta_in[4:0];
reg[4:0] next_state;
always @(*) begin
    case(cur_state) 
        5'd0: next_state <= f2_ld ? 5'b00010 : cur_state;
        5'd2: next_state <= l2_w ? 5'b10000 : cur_state;
        5'd16: next_state <= f2_evict ? 5'b00010 : cur_state;
        default: next_state <= cur_state;
    endcase
end

always @(*) begin
    cur_state = hit_way[3] ? meta_w3 : 
                hit_way[2] ? meta_w2 :
                hit_way[1] ? meta_w1 :
                meta_w0; 
    if(valid_in) begin
        if(f2_evict) begin
            case(evict_way) 
                4'h1:next_meta_out <={f2_meta_in[19:5],5'b00010};
                4'h2:next_meta_out <={f2_meta_in[19:10],5'b00010,f2_meta_in[4:0]};
                4'h4:next_meta_out <={f2_meta_in[19:15],5'b00010,f2_meta_in[9:0]};
                4'h8:next_meta_out <={5'b00010,f2_meta_in[14:0]};
                default: next_meta_out <= f2_meta_in;
            endcase
        end
        else if (l2_inv) begin
            case(hit_way) 
                4'h1:next_meta_out <={f2_meta_in[19:5],5'b00000};
                4'h2:next_meta_out <={f2_meta_in[19:10],5'b00000,f2_meta_in[4:0]};
                4'h4:next_meta_out <={f2_meta_in[19:15],5'b00000,f2_meta_in[9:0]};
                4'h8:next_meta_out <={5'b00000,f2_meta_in[14:0]};
                default: next_meta_out <= f2_meta_in;
            endcase
        end
        else begin
            case(hit_way)
                4'h1:next_meta_out <={f2_meta_in[19:5],next_state};
                4'h2:next_meta_out <={f2_meta_in[19:10],next_state,f2_meta_in[4:0]};
                4'h4:next_meta_out <={f2_meta_in[19:15],next_state,f2_meta_in[9:0]};
                4'h8:next_meta_out <={next_state,f2_meta_in[14:0]};
                default: next_meta_out <= f2_meta_in;
            endcase
        end
    end
end

endmodule