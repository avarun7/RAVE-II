//Inside cache bank:
/*
Tag Store
Data Store
Meta Store
TLB
MSHR
Tag_select
data select
meta update
tag update

*/

 module cache_bank #(parameter CL_SIZE = 128, IDX_CNT = 512, TAG_SIZE = 18, OOO_TAG_SIZE = 10) (
    //Systen Input
    input clk,
    input rst,

    //Pipeline Input - done
    input [31:0] addr_in,
    input [CL_SIZE-1:0] data_in,
    input [1:0] size_in,
    input [2:0] operation_in,
    input [OOO_TAG_SIZE-1:0] ooo_tag_in,

    //TODO: allocate and select data
    //Pipeline Output : 
    output [31:0] addr_out,
    output [31:0] data_out,
    output [1:0] size_out,
    output [2:0] operation_out,
    output [OOO_TAG_SIZE-1:0] ooo_tag_out,
    output hit,

    //Outputs to LSQ
    //MSHR
    output mshr_hit, //
    output [2:0]  mshr_wr_ptr, 
    output [2:0] mshr_fin_ptr, 
    output mshr_fin,//
    output mshr_full, //
    //Cache
    output lsq_alloc,
    output lsq_data, //TODO: Implement replaced data


    //Requests to DRAM/Directory
    //Eviction Q
    output [2:0] operation_evic,
    output [31:0] addr_evic,
    output alloc_evic,
    output [CL_SIZE-1:0] data_evic,
    //Miss Q
    output [2:0] operation_miss,
    output [31:0] addr_miss,
    output alloc_miss

);
localparam  NO_OP= 0;
localparam LD = 1;
localparam ST = 2;
localparam RD = 3;
localparam  WR= 4;
localparam  INV = 5;
localparam  UPD= 6;
localparam WR_LD = 7;

wire[TAG_SIZE-1:0] tag_in, tag_buf;
wire[IDX_CNT-1:0] idx_in, idx_buf;
wire[32-IDX_CNT-TAG_SIZE-2:0] offset_in, offset_buf;
wire parity_in, parity_buf;
wire stall_cache;
reg [31:0] addr_buffer;
reg [CL_SIZE-1:0] data_buffer;
reg [1:0] size_buffer;
reg [2:0] operation_buffer;
reg [OOO_TAG_SIZE-1:0] OOO_TAG_buffer;

assign offset_in = addr_in[32-IDX_CNT-TAG_SIZE-1:0];
assign parity_in = addr_in[32-IDX_CNT-TAG_SIZE+1:32-IDX_CNT-TAG_SIZE];
assign idx_in = addr_in[32-1-TAG_SIZE:32-IDX_CNT-TAG_SIZE+2];
assign tag_in = addr_in[31:32-TAG_SIZE];

assign offset_buf = addr_buffer[32-IDX_CNT-TAG_SIZE-1:0];
assign parity_buf = addr_buffer[32-IDX_CNT-TAG_SIZE+1:32-IDX_CNT-TAG_SIZE];
assign idx_buf = addr_buffer[32-1-TAG_SIZE:32-IDX_CNT-TAG_SIZE+2];
assign tag_buf = addr_buffer[31:32-TAG_SIZE];


assign valid_operation_in = |operation_in;
assign valid_operation_buf = |operation_buffer;
assign lsq_alloc = is_miss && valid_operation_buf;


always @(posedge clk) begin
    if(rst) begin
        addr_buffer <= 32'hFFFF_FFFF;
        data_buffer <= 0;
        size_buffer <= 0;
        operation_buffer <= 0;
        OOO_TAG_buffer <= 0;
    end
    else if(!stall_cache && addr_in[31:5] == addr_buffer[31:5] && valid_operation_in ) begin
        //TODO: Finish once instantied rest of modules 
    end
    else if (!stall_cache) begin
        addr_buffer <= addr_in;
        data_buffer <= data_in;
        size_buffer <= size_in;
        operation_buffer <= operation_in;
        OOO_TAG_buffer <= ooo_tag_in;
    end
    else begin
        operation_buffer <= 0;
    end
end

wire[TAG_SIZE*4-1:0] tag_lines_old, tag_lines_new;

 tag_store  #(.TAG_SIZE(TAG_SIZE),  .IDX_CNT(IDX_CNT)) ts1 (
    .clk(clk),
    .rst(rst),

    //initial rea()d
    .operation(operation_in),
    .idx(idx_in),
    .tag_in_rd(tag_in),

    //writebac()k
    .tag_in_wb(tag_lines_new),
    .idx_in_wb(idx_buf),
    .alloc(tag_store_alloc),

    //initial read ou()t
    .tag_lines_out (tag_lines_old) 
);

wire[CL_SIZE *4 -1:0] data_lines_old, data_lines_new;
data_store #(.CL_SIZE(CL_SIZE),  .IDX_CNT(IDX_CNT)) ds1(
    .clk(clk), 
    .rst(rst),

    //initial read
    .operation(operation_in),
    .idx(idx_in),

    //writeback
    .cl_in_wb(data_lines_new),
    .idx_in_wb(idx_buf),
    .alloc(data_store_alloc),

    //initial read out
    .cl_lines_out(data_lines_old)  
);

wire[8*4-1:0] meta_lines_new, meta_lines_old;
meta_store #(.META_SIZE(8),  .IDX_CNT(IDX_CNT)) ms1(
    .clk(clk),
    .rst(rst),

    //initial read
    .operation(operation_in),
    .idx(idx_in),

    //writeback
    .meta_in_wb(meta_lines_new),
    .idx_in_wb(idx_buf),
    .alloc(valid_operation_buffer),

    //initial read out
    .meta_lines_out(meta_lines_old)  
);

 wire is_hit, is_miss;
 wire [3:0] hits;

 tag_select #(.TAG_SIZE(TAG_SIZE)) ts2 (
    .tag_cur_state(tag_lines_old),
    .tag_in(tag_buf),

    .hit(is_hit), 
    .miss(is_miss),
    .way_out(hits),
    .tag_repl_out() //TODO: Validate if this is worth including. i dont think it is
);

wire[3:0] selected_replacement_way;
wire [3:0] current_state_buf;
 meta_next_state #(.META_SIZE(8)) mns1 (
    .meta_in(meta_lines_old),
    .hits(hits),
    .mshr_hit(mshr_hit),
    .operation(operation_buffer),

    .meta_out(meta_lines_new),
    .tag_alloc(tag_store_alloc), //done
    .way_out(selected_replacement_way), //done
    .mshr_alloc(mshr_alloc), //done
    .pending_stall(), //TODO: implement stall logic
    .wb_to_l2(alloc_wb_l2), //done
    .cur_state(current_state_buf),
    .is_evict(is_evict)
);

 tag_next_state #(.TAG_SIZE(TAG_SIZE)) tns1(
    .tag_cur_state(tag_lines_old),
    .tag_in(tag_buf),
    .is_alloc(tag_store_alloc),
    .selected_way(selected_replacement_way), 

    .tag_next_state(tag_lines_new)
);

 data_next_state #(.CL_SIZE(CL_SIZE)) dns1(
    .data_cur_state(data_lines_old),
    .data_in(data_buffer),
    .operation(operation_buffer),
    .selected_way(selected_replacement_way), 
    .addr_in(addr_buffer),
    .size(size_buffer),

    .data_next_state(data_lines_new),
    .data_wb(data_store_alloc),
    .data_evic(data_evict)
);


mshr #(.Q_LEGNTH(8)) mshr1(
    //Global
    .clk(clk),
    .rst(rst),    

    //alloc from cache
    .alloc(mshr_alloc),
    .operation_cache(operation_buffer),
    .addr_cache(addr_buffer),

    //from l2
    .l22q_valid(operation_buffer == WR_LD || operation_buffer == WR),
    .l2_ldst(operation_buffer == WR),
    .addr_l2(addr_buffer),

    //output to cache
    .mshr_hit(mshr_hit), //
    .mshr_wr_ptr(mshr_wr_ptr), //
    .mshr_fin_ptr(mshr_fin_ptr), //
    .mshr_fin(mshr_fin),

    .mshr_full(mshr_full) //TODO: STALL LOGIC
);
gen_request_l1 gr1(
    .operation(operation_buffer),
    .current_state(current_state_buf),
    .tag_hit(is_hit),
    .mshr_hit(mshr_hit),
    .is_evict(is_evict),
    
    //output miss
    .alloc_miss(alloc_miss),
    .operation_out_miss(operation_miss),

    //output evic
    .alloc_evic(alloc_evic),
    .operation_out_evic(operation_evic)
);



 endmodule

