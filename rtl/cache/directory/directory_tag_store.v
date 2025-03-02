module tag_store #(parameter TAG_SIZE = 18,  IDX_CNT = 512) (
    input clk,
    input rst,

    //initial read
    input [2:0] operation,
    input [$clog2(IDX_CNT)-1:0] idx,
    input [TAG_SIZE-1:0] tag_in_rd,

    //writeback
    input [TAG_SIZE*8-1:0]tag_in_wb,
    input [$clog2(IDX_CNT)-1:0] idx_in_wb,
    input alloc,
    input st_fwd,

    //initial read out
    output reg[TAG_SIZE*8-1:0] tag_lines_out  
);

reg [TAG_SIZE*8-1:0] tag_store[IDX_CNT-1:0];
genvar i;
for(i = 0; i < IDX_CNT; i = i +1 ) begin : init_ts
    initial begin 
        tag_store[i] = 0;
    end
end


always @(posedge clk) begin
    if(rst) begin
    
    end
    else begin
        if(operation != 0) begin
            tag_lines_out <= st_fwd ? tag_in_wb : tag_store[idx];
        end
        if(alloc) begin
            tag_store[idx_in_wb] <= tag_in_wb;
        end
    end
end

endmodule