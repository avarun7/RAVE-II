//4 Way Set Accociativity 
module itag_store #(parameter SET_CNT = 256,parameter CACHE_LINE = 512, parameter ADDR_SZ = 32) (
    //Global
    input clk,
    input rst,
    input resteer,

    //f1 Inputs
    input [(ADDR_SZ - $clog2(SET_CNT) - $clog2(CACHE_LINE)) * 4 - 1:0] f1_tag_in,
    input [$clog2(SET_CNT)-1:0] f1_index_in,
    input f1_valid,

    //f1 outputs
    output reg [(ADDR_SZ - $clog2(SET_CNT) - $clog2(CACHE_LINE)) * 4 - 1:0]   f1_tag_out,
    output reg [5*4-1:0]        f1_meta_out,
    output reg [2:0]           f1_plru_out,
    output reg [3:0]            f1_hit_out,

    //f2 inputs
    input [(ADDR_SZ - $clog2(SET_CNT) - $clog2(CACHE_LINE)) * 4 - 1:0]  f2_tag_in,
    input [5*4-1:0]   f2_meta_in,
    input [2:0]      f2_plru_in,
    input [$clog2(SET_CNT)-1:0] f2_index_in,
    input f2_write_in,
    input f2_plru_update

);
localparam TAG_SZ = ADDR_SZ - $clog2(SET_CNT) - $clog2(CACHE_LINE);
localparam INDEX_SZ = $clog2(SET_CNT);
localparam OFFSET_SZ = $clog2(CACHE_LINE);
localparam WAY_CNT = 4;

wire[TAG_SZ-1:0] f2_tag_w0;
assign f2_tag_w0 = f2_tag_in[TAG_SZ-1:0];
wire[TAG_SZ-1:0] f2_tag_w1;
assign f2_tag_w1 = f2_tag_in[TAG_SZ*2-1:TAG_SZ];
wire[TAG_SZ-1:0] f2_tag_w2;
assign f2_tag_w2 = f2_tag_in[TAG_SZ*3-1:TAG_SZ*2];
wire[TAG_SZ-1:0] f2_tag_w3;
assign f2_tag_w1 = f2_tag_in[TAG_SZ*4-1:TAG_SZ*3];

wire[TAG_SZ-1:0] f1_tag_w0;
assign f1_tag_w0 = f1_tag_out[TAG_SZ-1:0];
wire[TAG_SZ-1:0] f1_tag_w1;
assign f1_tag_w = f1_tag_out[TAG_SZ*2-1:TAG_SZ];
wire[TAG_SZ-1:0] f1_tag_w2;
assign f1_tag_w2 = f1_tag_out[TAG_SZ*3-1:TAG_SZ*2];
wire[TAG_SZ-1:0] f1_tag_w3;
assign f1_tag_w3 = f1_tag_out[TAG_SZ*4-1:TAG_SZ*3];

//Valid, modified, PTC, LD, S  
reg [5*WAY_CNT-1:0] meta_store[0:SET_CNT-1];
reg [2:0] plru_store[0:SET_CNT-1];
reg [TAG_SZ*WAY_CNT-1:0] tag_store[0:SET_CNT-1]; // Array for tag storage
integer i;
always @(posedge clk) begin
    if(rst) begin 
        for (i = 0; i < SET_CNT; i = i + 1) begin
            meta_store[i] <= {5*WAY_CNT{1'b0}};
        end
    end else begin
        //Handle read and write to cache line in same cycle
        if(f1_valid && f2_write_in && (f1_index_in == f2_index_in)) begin
            f1_tag_out <= f2_tag_in;
            f1_meta_out <= f2_meta_in;
            f1_plru_out <= f2_plru_in;
            f1_hit_out <= {f2_tag_w3==f1_tag_in,f2_tag_w2==f1_tag_in,f2_tag_w1==f1_tag_in,f2_tag_w0==f1_tag_in };
            meta_store[f2_index_in] = f2_meta_in;
            tag_store[f2_index_in] = f2_tag_in;
            plru_store[f2_index_in] = f2_plru_in;
        end
       
        else begin  
             //Handle eviction writes to tag store
            if(f2_write_in) begin
                meta_store[f2_index_in] = f2_meta_in;
                tag_store[f2_index_in] = f2_tag_in;
                plru_store[f2_index_in] = f2_plru_in;
            end
            else if(f2_plru_update) begin
                plru_store[f2_index_in] = f2_plru_in;
            end
            //Handle normal read requests from pipeline
            if(f1_valid) begin
                f1_tag_out = tag_store[f1_index_in];
                f1_meta_out = meta_store[f1_index_in];
                f1_plru_out = plru_store[f1_index_in];
                f1_hit_out = {f1_tag_w3==f1_tag_in,f1_tag_w2==f1_tag_in,f1_tag_w1==f1_tag_in,f1_tag_w0==f1_tag_in};
            end
        end
        
    end

end



endmodule