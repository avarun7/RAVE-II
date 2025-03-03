module meta_next_state #(parameter META_SIZE = 8) (
    input [META_SIZE*4-1:0] meta_in,
    input [3:0] hits,
    input mshr_hit,
    input [2:0] operation,

    output [META_SIZE*4-1:0] meta_out,
    output wire tag_alloc, //done
    output [3:0] way_out, //done
    output wire mshr_alloc, //done
    output wire pending_stall, //done
    output wb_to_l2, //done
    output[3:0] cur_state,
    output is_evict

);
localparam  NO_OP= 0;
localparam LD = 1;
localparam ST = 2;
localparam RD = 3;
localparam  WR= 4;
localparam  INV = 5;
localparam  UPD= 6;
localparam RWITM = 7;
localparam RINV = 2;
wire [META_SIZE*4:0] meta_way_split [3:0];
wire[3:0] lru_concat[3:0];
wire[3:0] selected_way_miss;
wire[3:0] selected_way_hit;
wire[3:0] pending;
wire[3:0] pmsi_concat[3:0];
assign miss = ~(|hits);
assign valid = |operation;
assign way_out = |hits ? hits : selected_way_miss;

genvar i;
for(i = 0; i < 4; i = i + 1) begin
    assign meta_way_split[i] = meta_in[(i+1)*8-1:i*8];
    assign lru_concat[i] = meta_way_split[i][7:4];
    assign pmsi_concat[i] = meta_way_split[i][3:0];

    assign pending[i] = meta_way_split[i][3];
end

assign mshr_alloc = (operation == LD || operation == ST) && ~(|hits) && ~(mshr_hit); //TODO:Check if |opeariton should be op=LD/ST
assign tag_alloc = mshr_alloc;
assign cur_state = hits[3] ? pmsi_concat[3] : hits[2] ? pmsi_concat[2] : hits[1] ? pmsi_concat[1] : hits[0] ? pmsi_concat[0] : 0;
assign is_evict = pmsi_concat[3] != 0 && pmsi_concat[2] != 0 && pmsi_concat[1] != 0 && pmsi_concat[0] != 0 && miss;
//Choose which way to evict if there is a miss
max4 way_select(
.a(lru_concat[0]),
.b(lru_concat[1]),
.c(lru_concat[2]),
.d(lru_concat[3]),
.p({meta_way_split[0][3], meta_way_split[1][3], meta_way_split[2][3], meta_way_split[3][3]}),
.max_out(selected_way_miss),
.max_valid(pending_stall_temp)
);
assign pending_stall = pending_stall_temp && miss && valid;
assign is_evict = pmsi_concat[0] != 1 && pmsi_concat[1] != 1  && pmsi_concat[2] != 1 && pmsi_concat[3] != 1;

pmsi_next_state pns(
    .operation(operation),
    .current_state({pmsi_concat[3], pmsi_concat[2], pmsi_concat[1], pmsi_concat[0]}),
    .is_evict(is_evict),
    .next_state({meta_out[27:24],meta_out[19:16],meta_out[11:8] ,meta_out[3:0]}),
    .wb_to_l2(wb_to_l2)
);

lru_next_state lns(
    .selected_way(way_out),
    .lru_state_in({lru_concat[3], lru_concat[2], lru_concat[1], lru_concat[0]}),

    .lru_state_out({meta_out[31:28],meta_out[23:20],meta_out[15:12] ,meta_out[7:4]})
);

endmodule



module max4 (
    input   [3:0] a, b, c, d,  
    input    [3:0] p,        
    output  reg[3:0] max_out,  
    output    reg     max_valid  
);
    reg [3:0] temp_max;
    reg        found_valid;
    reg[3:0] way_sel;
    
    always @(*) begin
        temp_max = 32'b0;
        found_valid = 0;

        if (p[0]) begin
            temp_max = a;
            found_valid = 1;
            way_sel = 1;
        end
        if (p[1] && (!found_valid || b >= temp_max)) begin
            temp_max = b;
            found_valid = 1;
            way_sel = 2;

        end
        if (p[2] && (!found_valid || c >= temp_max)) begin
            temp_max = c;
            found_valid = 1;
            way_sel = 4;

        end
        if (p[3] && (!found_valid || d >= temp_max)) begin
            temp_max = d;
            found_valid = 1;
            way_sel = 4;

        end

        max_out = way_sel;
        max_valid = ~found_valid;
    end
endmodule