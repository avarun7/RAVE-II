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

 module cache_bank #(parameter CL_SIZE = 128, IDX_CNT = 512, TAG_SIZE = 18, OOO_TAG_SIZE = 10, BANK_NAME = 1) (
    //Systen Input
    input clk,
    input rst,

    //Pipeline Input - done
    input [31:0] addr_in,
    input [CL_SIZE-1:0] data_in,
    input [1:0] size_in,
    input [2:0] operation_in,
    input [OOO_TAG_SIZE-1:0] ooo_tag_in,

    //Cache Inputs
    input rwnd_full,
    input lsq_full,


    //Pipeline Output : 
    output [31:0] addr_out,
    output [CL_SIZE-1:0] data_out,
    output [1:0] size_out,
    output [2:0] operation_out,
    output [OOO_TAG_SIZE-1:0] ooo_tag_out,
    output hit,

    //Outputs to LSQ
    //MSHR
    output mshr_hit, //
    output [2:0] mshr_hit_ptr,
    output [2:0]  mshr_wr_ptr, 
    output [2:0] mshr_fin_ptr, 
    output mshr_fin,//
    output mshr_full, //
    //Cache
    output lsq_alloc,
    output lsq_data, 

    //Outputs to RWND Q
    output rwnd_alloc, 
    output [31:0] rwnd_data,


    //Requests to DRAM/Directory
    //Eviction Q
    output [2:0] operation_evic,
    output reg[31:0]  addr_evic, //TODO: implement
    output alloc_evic,
    output [CL_SIZE-1:0] data_evic,
    //Miss Q
    output [2:0] operation_miss,
    output reg[31:0]  addr_miss,
    output alloc_miss,

    output stall_cache

);
//TODO: REBUILD ADDR

localparam IDX_ROW = $clog2(IDX_CNT);

localparam  NO_OP= 0;
localparam LD = 1;
localparam ST = 2;
localparam RD = 3;
localparam  WR= 4;
localparam  INV = 5;
localparam  UPD= 6;
localparam WR_LD = 7;


localparam RWITM = 7;
localparam RINV = 7;
localparam REPLY = 2;
wire[TAG_SIZE-1:0] tag_in, tag_buf;
wire[IDX_ROW-1:0] idx_in, idx_buf;
wire[32-IDX_ROW-TAG_SIZE-2:0] offset_in, offset_buf;
wire parity_in, parity_buf;

reg [31:0] addr_buffer;
reg [CL_SIZE-1:0] data_buffer;
reg [1:0] size_buffer;
reg [2:0] operation_buffer;
reg [OOO_TAG_SIZE-1:0] OOO_TAG_buffer;

initial addr_buffer = 0;
initial operation_buffer = 0;
initial size_buffer = 0;
initial data_buffer = 0;
initial OOO_TAG_buffer = 0;


assign offset_in = addr_in[32-IDX_ROW-TAG_SIZE-1:0];
assign parity_in = addr_in[32-IDX_ROW-TAG_SIZE+1:32-IDX_ROW-TAG_SIZE];
assign idx_in = addr_in[32-1-TAG_SIZE:32-IDX_ROW-TAG_SIZE+2];
assign tag_in = addr_in[31:32-TAG_SIZE];

assign offset_buf = addr_buffer[32-IDX_ROW-TAG_SIZE-1:0];
assign parity_buf = addr_buffer[32-IDX_ROW-TAG_SIZE+1:32-IDX_ROW-TAG_SIZE];
assign idx_buf = addr_buffer[32-1-TAG_SIZE:32-IDX_ROW-TAG_SIZE+2];
assign tag_buf = addr_buffer[31:32-TAG_SIZE];


assign valid_operation_in = |operation_in;
assign valid_operation_buf = |operation_buffer;
assign lsq_alloc = (is_miss || is_pending) && valid_operation_buf;
wire [CL_SIZE-1:0] data_evict;
assign hit = is_hit && !is_pending;
assign addr_out = addr_buffer;
assign size_out = size_buffer;
assign operation_out = operation_buffer;
assign ooo_tag_out = OOO_TAG_buffer;
assign data_out = data_evict;
assign data_evic = data_evict;
assign st_fwd = !stall_cache && addr_in[31:5] == addr_buffer[31:5] && valid_operation_in; 
assign rwnd_alloc = operation_buffer == ST;
assign lsq_data = data_buffer;

//TODO: adjust mshr_alloc to be mshr_alloc_pre_stall
assign stall_cache = pending_stall  || mshr_alloc && mshr_full || rwnd_full && rwnd_alloc || lsq_full && lsq_alloc;

always @(posedge clk) begin
    if(rst) begin
        addr_buffer = 32'hFFFF_FFFF;
        data_buffer = 0;
        size_buffer = 0;
        operation_buffer = 0;
        OOO_TAG_buffer  = 0;
        addr_miss = addr_buffer;
        addr_evic = addr_buffer;
    end
    else if (!stall_cache && valid_operation_in) begin
        addr_buffer = addr_in;
        data_buffer = data_in;
        size_buffer = size_in;
        operation_buffer = operation_in;
        OOO_TAG_buffer = ooo_tag_in;
        addr_miss = addr_buffer;
        addr_evic = addr_buffer;
    end
    else if(stall_cache && valid_operation_in) begin 
        addr_buffer = addr_buffer;
        data_buffer = data_buffer;
        size_buffer = size_buffer;
        operation_buffer = operation_buffer;
        OOO_TAG_buffer = OOO_TAG_buffer;
        addr_miss = addr_buffer;
        addr_evic = addr_buffer;
    end
    else begin operation_buffer = 0;
        addr_miss = addr_buffer;
        addr_evic = addr_buffer;
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
    .alloc(tag_store_alloc && !stall_cache),
    .st_fwd(st_fwd),


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
    .alloc(data_store_alloc  && !stall_cache),
    .st_fwd(st_fwd),


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
    .alloc(valid_operation_buf && !stall_cache),

    .st_fwd(st_fwd),

    //initial read out
    .meta_lines_out(meta_lines_old)  
);

 wire is_hit, is_miss;
 wire [3:0] hits;

 tag_select #(.TAG_SIZE(TAG_SIZE)) ts2 (
    .tag_cur_state(tag_lines_old),
    .tag_in(tag_buf),
    .meta_in(meta_lines_old),

    .hit(is_hit), 
    .miss(is_miss),
    .way_out(hits),
    .tag_repl_out() //TODO: Validate if this is worth including. i dont think it is
);

wire[3:0] selected_replacement_way;
wire [3:0] current_state_buf;
assign is_pending = current_state_buf[3];
 meta_next_state #(.META_SIZE(8)) mns1 (
    .meta_in(meta_lines_old),
    .hits(hits),
    .mshr_hit(mshr_hit),
    .operation(operation_buffer),

    .meta_out(meta_lines_new),
    .tag_alloc(tag_store_alloc), //done
    .way_out(selected_replacement_way), //done
    .mshr_alloc(mshr_alloc), //done
    .pending_stall(pending_stall),
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
    .data_evic(data_evict),
    .rewind_data(rwnd_data)
);


mshr #(.Q_LEGNTH(8)) mshr1(
    //Global
    .clk(clk),
    .rst(rst),    

    //alloc from cache
    .alloc(mshr_alloc  && !stall_cache),
    .operation_cache(operation_buffer),
    .addr_cache(addr_buffer),

    //from l2
    .l22q_valid(operation_buffer == WR_LD || operation_buffer == WR),
    .l2_ldst(operation_buffer == WR),
    .addr_l2(addr_buffer),

    //output to cache
    .mshr_hit(mshr_hit), //
    .mshr_hit_ptr(mshr_hit_ptr),
    .mshr_wr_ptr(mshr_wr_ptr), //
    .mshr_fin_ptr(mshr_fin_ptr), //
    .mshr_fin(mshr_fin),

    .mshr_full(mshr_full) 
);
assign alloc_evic = alloc_evic_pre_stall  && !stall_cache;
assign alloc_miss = alloc_miss_pre_stall  && !stall_cache;

gen_request_l1 gr1(
    .operation(operation_buffer),
    .current_state(current_state_buf),
    .tag_hit(is_hit),
    .mshr_hit(mshr_hit),
    .is_evict(is_evict),
    
    //output miss
    .alloc_miss(alloc_miss_pre_stall),
    .operation_out_miss(operation_miss),

    //output evic
    .alloc_evic(alloc_evic_pre_stall),
    .operation_out_evic(operation_evic)
);


reg [8*6:1] opcode_names [0:7]; // Each string is max 6 chars long
reg [8*6:1] dir_opcode_names [0:7]; // Each string is max 6 chars long
reg [8*6:1] state_names[0:3];
reg [8*6:1] src_names[0:3];
reg [8*6:1] size_names[0:3];
localparam I = 1; //Invalid
localparam  PL= 11; //Pending Load
localparam  PS= 9; //Pending Store
localparam  PM= 10; //Pending Modified 
localparam  M= 4; //Modified
localparam  S= 2; //Shared
localparam PLS = 15; //Pending Load Store (edge case where store comes after load but before write)


localparam NOOP = 0; //WHAT DO YOU THINK IT DOES EINSTEIN????


integer file;
  integer count = 0;
initial begin
    if(BANK_NAME == 1) begin
        file = $fopen("I$_BANK_EVEN.csv", "w");
    end
    if(BANK_NAME == 2) begin
        file = $fopen("I$_BANK_ODD.csv", "w");
    end
    if(BANK_NAME == 3) begin
        file = $fopen("D$_BANK_EVEN.csv", "w");
    end
    if(BANK_NAME == 4) begin
        file = $fopen("D$_BANK_ODD.csv", "w");
    end
    opcode_names[0] = "NOOP";
    opcode_names[1] = "LD"; // Unused index
    opcode_names[2] = "ST";
    opcode_names[3] = "RD";
    opcode_names[4] = "WR";
    opcode_names[5] = "INV";
    opcode_names[6] = "UPD";
    opcode_names[7] = "RINV";
    state_names[1] = "S";
    state_names[2] = "M";
    state_names[0] = "???";
    state_names[3] = "???";
    src_names[0] = "???";
    src_names[1] = "I$";
    src_names[2] = "D$";
    src_names[3] = "MEM";
    size_names[0] = "1B";
    size_names[1] = "2B";
    size_names[2] = "4B";
    size_names[3] = "???";

    dir_opcode_names[0] = "NOOP";
    dir_opcode_names[1] = "???"; // Unused index
    dir_opcode_names[2] = "REPLY";
    dir_opcode_names[3] = "RD";
    dir_opcode_names[4] = "WR";
    dir_opcode_names[5] = "INV";
    dir_opcode_names[6] = "UPD";
    dir_opcode_names[7] = "RWITM";

    if (file == 0) begin
      $display("Error: Unable to open file.");
      $stop;
    end
    
    $fdisplay(file, "Time,Cycle,Address_Buffer, Operation_Buffer, Size_Buffer,Data_Buffer,OOO_Tag_Buffer, Index_buffer, Tag_Buffer, Offset_buffer,Stall,Hit,MSHR_Alloc, Selected_Way, Tag_Old, Tag_New, Meta_Old, Meta_New, Data_Old, Data_New, Instr_Q_Alloc, Instr_Q_Operation, Data_Q_Alloc, Data_Q_Operation, Data_Q_Data"); // Write header
  end
  localparam META_SIZE = 8;
//  MSHR_Alloc
  always @(posedge clk) begin
    if (rst) begin
      count <= 0;  // Reset count on reset
    end else begin
      count <= count + 1; // Increment count
      if(operation != 0) begin 
        $fdisplay(file, "%t,%d,0x%h,%s, %s,0x%h,0x%h,0x%h,0x%h,0x%h,0x%h,0x%h,0x%h,0x%h,0x%h_0x%h_0x%h_0x%h,0x%h_0x%h_0x%h_0x%h, 0x%h_0x%h_0x%h_0x%h,0x%h,%s,0x%h,%s, 0x%h", 
        $time, count, addr_buffer, opcode_names[operation_buffer], size_names[size_buffer], data_buffer, OOO_TAG_buffer, 
        idx_buf, tag_buf, offset_buf,stall_cache,hit,mshr_alloc && !stall_cache,selected_replacement_way, 
        tag_lines_old[TAG_SIZE*4-1:TAG_SIZE*3],tag_lines_old[TAG_SIZE*3-1:TAG_SIZE*2],tag_lines_old[TAG_SIZE*2-1:TAG_SIZE*1],tag_lines_old[TAG_SIZE*1-1:TAG_SIZE*0], 
        tag_lines_new[TAG_SIZE*4-1:TAG_SIZE*3],tag_lines_new[TAG_SIZE*3-1:TAG_SIZE*2],tag_lines_new[TAG_SIZE*2-1:TAG_SIZE*1],tag_lines_new[TAG_SIZE*1-1:TAG_SIZE*0], 
        meta_lines_old[META_SIZE*4-1:META_SIZE*3],meta_lines_old[META_SIZE*3-1:META_SIZE*2],meta_lines_old[META_SIZE*2-1:META_SIZE*1],meta_lines_old[META_SIZE*1-1:META_SIZE*0], 
        meta_lines_new[META_SIZE*4-1:META_SIZE*3],meta_lines_new[META_SIZE*3-1:META_SIZE*2],meta_lines_new[META_SIZE*2-1:META_SIZE*1],meta_lines_new[META_SIZE*1-1:META_SIZE*0], 
        data_lines_old[CL_SIZE*4-1:CL_SIZE*3],data_lines_old[CL_SIZE*3-1:CL_SIZE*2],data_lines_old[CL_SIZE*2-1:CL_SIZE*1],data_lines_old[CL_SIZE*1-1:CL_SIZE*0], 
        data_lines_new[CL_SIZE*4-1:CL_SIZE*3],data_lines_new[CL_SIZE*3-1:CL_SIZE*2],data_lines_new[CL_SIZE*2-1:CL_SIZE*1],data_lines_new[CL_SIZE*1-1:CL_SIZE*0], 
        alloc_miss, dir_opcode_names[operation_miss], alloc_evic, dir_opcode_names[operation_evic], data_evic
        );
    end 
    end
  end


 endmodule

