module meta_store #(parameter META_SIZE = 8,  IDX_CNT = 8) (
    input clk,
    input rst,

    //initial read
    input [2:0] operation,
    input [IDX_CNT-1:0] idx,

    //writeback
    input [META_SIZE*4-1:0]meta_in_wb,
    input [IDX_CNT-1:0] idx_in_wb,
    input alloc,

    input st_fwd,

    //initial read out
    output reg[META_SIZE*4-1:0] meta_lines_out  
);

reg [META_SIZE*4-1:0] meta_store[IDX_CNT-1:0];
genvar i;
for(i = 0; i < IDX_CNT; i = i +1 ) begin : init_ts
    initial begin 
        meta_store[i] = 0;
    end
end

integer j;
always @(posedge clk) begin
    if(rst) begin
        for(j = 0; j < IDX_CNT; j = j + 1) begin 
            meta_store[j] = 0;
        end
    end
    else begin
        if(operation != 0) begin
            meta_lines_out <= st_fwd ? meta_in_wb :  meta_store[idx];
        end
        if(alloc) begin
            meta_store[idx_in_wb] <= meta_in_wb;
        end
    end
end

endmodule