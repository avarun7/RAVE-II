module tag_select #(parameter TAG_SIZE = 20) (
    input [TAG_SIZE*4-1:0] tag_cur_state,
    input [TAG_SIZE-1:0] tag_in,
    input [8*4-1:0] meta_in,

    output hit, 
    output miss,
    output [3:0] way_out,
    output reg [TAG_SIZE-1:0] tag_repl_out
);
wire [3:0] meta_loc[0:3];
wire [17:0] tag_loc[0:3];
genvar i;
for(i = 0; i < 4; i = i + 1) begin :plzplzplz
    assign way_out[i] = (tag_in == tag_cur_state[TAG_SIZE*(i+1)-1:TAG_SIZE*i]) && (meta_in[8*i + 3:8*i]!= 1);
    assign meta_loc[i] = meta_in[8*i + 3:8*i];
    assign tag_loc[i] = tag_cur_state[TAG_SIZE*(i+1)-1:TAG_SIZE*i];
    always @(*) begin
        if(way_out[i]) begin
            tag_repl_out <= tag_cur_state[TAG_SIZE*(i+1)-1:TAG_SIZE*i];
        end
    end
end
assign hit = |way_out;
assign miss = ~hit;
endmodule