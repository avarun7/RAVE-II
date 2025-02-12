module replacement #(parameter META_SIZE = 8) (
    input [META_SIZE*4-1:0] meta_in,
    input [3:0] hits,
    input mshr_hit,
    input [2:0] operation,

    output [META_SIZE*4-1:0] meta_out,
    output wire tag_alloc,
    output [3:0] way_replace,
    output wire mshr_alloc
);

wire [META_SIZE*4:0] meta_way_split [3:0];

genvar i;
for(i = 0; i < 4; i = i + 1) begin
    assign meta_way_split[i] = meta_in[(i+1)*8-1:i*8];
end

assign mshr_alloc = ~(|operation) && ~(|hits) && ~(mshr_hit);
assign tag_alloc = mshr_alloc;

always @(*) begin
    if(!(|operation)) begin 
        if(!(|hits) && !mshr_alloc) begin
            
        end
    end
end

assign pending_stall = meta_way_split[0][0] && meta_way_split[0][1] && meta_way_split[0][2] && meta_way_split[0][3];



endmodule