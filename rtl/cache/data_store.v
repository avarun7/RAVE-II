module data_store #(parameter CL_SIZE = 512,  IDX_CNT = 8) (
    input clk,
    input rst,

    //initial read
    input [2:0] operation,
    input [IDX_CNT-1:0] idx,

    //writeback
    input [CL_SIZE*4-1:0]cl_in_wb,
    input [IDX_CNT-1:0] idx_in_wb,
    input alloc,
    input st_fwd,

    //initial read out
    output reg[CL_SIZE*4-1:0] cl_lines_out  
);

reg [CL_SIZE*4-1:0] data_store[IDX_CNT-1:0];
genvar i;
for(i = 0; i < IDX_CNT; i = i +1 ) begin : init_ts
    initial begin 
        data_store[i] = 0;
    end
end


always @(posedge clk) begin
    if(rst) begin
    
    end
    else begin
        if(operation != 0) begin
            cl_lines_out <= st_fwd ? cl_in_wb : data_store[idx];
        end
        if(alloc) begin
            data_store[idx_in_wb] <= cl_in_wb;
        end
    end
end

endmodule