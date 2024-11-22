module idata_store #(parameter SET_CNT = 256,parameter CACHE_LINE = 512, parameter ADDR_SZ = 32) (
    input clk,
    input rst,

    //f1 inputs
    input [$clog2(SET_CNT)-1:0] f1_index_in,

    //f1 outputs
    output reg [CACHE_LINE * 4 - 1: 0] f1_data_out,

    //f2 inputs
    input [$clog2(SET_CNT)-1:0] f2_index_in,
    input f2_write,
    input [CACHE_LINE*4-1:0] f2_data_in

);
wire[CACHE_LINE-1:0] f2_data_w0;
assign f2_data_w0 = f2_data_in[CACHE_LINE-1:0];
wire[CACHE_LINE-1:0] f2_data_w1;
assign f2_data_w1 = f2_data_in[CACHE_LINE*2-1:CACHE_LINE];
wire[CACHE_LINE-1:0] f2_data_w2;
assign f2_data_w2 = f2_data_in[CACHE_LINE*3-1:CACHE_LINE*2];
wire[CACHE_LINE-1:0] f2_data_w3;
assign f2_data_w1 = f2_data_in[CACHE_LINE*4-1:CACHE_LINE*3];


reg [CACHE_LINE-1:0] data_store[0:SET_CNT-1]; // Array for tag storage

always @(posedge clk)begin 
    if(f2_write && (f2_index_in == f1_index_in)) begin
        f1_data_out <= {f2_data_w3, f2_data_w2, f2_data_w1, f2_data_w0};
    end else begin
        f1_data_out <= data_store[f1_index_in];
    end

end

always @(posedge clk) begin
    if(f2_write) begin
        data_store[f2_index_in] = {f2_data_w3, f2_data_w2, f2_data_w1, f2_data_w0};
    end
end
endmodule