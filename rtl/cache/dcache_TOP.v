module dcache_TOP #(parameter CL_SIZE = 128, IDX_CNT = 512, OOO_TAG_SIZE = 10, TAG_SIZE = 18, OOO_ROB_SIZE = 10) (
    //FROM SYSTEM
    input clk,
    input rst,

    //FROM RSV
    input ls_unit_alloc, //Data from RAS is valid or not
    input [31:0] addr_in,
    input [31:0] data_in,
    input [1:0] size_in, //
    input is_st_in, //Say whether input is ST or LD
    input [OOO_TAG_SIZE-1:0] ooo_tag_in, //tag from register renaming
    input [OOO_ROB_SIZE-1:0] ooo_rob_in,
    input sext,

    //FROM ROB
    input [OOO_TAG_SIZE-1:0] rob_ret_tag_in, //Show top of ROB tag
    input rob_valid, //bit to say whether or not the top of the rag is valid or not
    input rob_resteer, //Signal if there is a flush from ROB
    
    //TO ROB
    output addr_out,
    output [31:0] data_out,
    output is_st_out,
    output valid_out, //1 bit signal to tell whether or not there are cache results
    output [OOO_TAG_SIZE-1:0] tag_out,
    output [OOO_ROB_SIZE-1:0] rob_line_out,
    output is_flush_out,

    //TO RSV
    output stall,

    //TODO: All other I/O memory facing and I will handle
    //Shouldn't affect people working on integrating the pipeline

    input[31:0] addr_in_dc_data_q_even,
    input [CL_SIZE-1:0] data_in_dc_data_q_even,
    input [2:0] operation_in_dc_data_q_even,
    input is_flush_in_dc_data_q_even,
    input alloc_in_dc_data_q_even,
    input [1:0] src_in_dc_data_q_even,
    input [1:0] dest_in_dc_data_q_even,

    output full_out_dc_data_q_even,
    
    //I$_INSTR_Q_in
    input[31:0] addr_in_dc_instr_q_even,
    input [2:0] operation_in_dc_instr_q_even,
    input is_flush_in_dc_instr_q_even,
    input alloc_in_dc_instr_q_even,
    input [1:0] src_in_dc_instr_q_even,
    input [1:0] dest_in_dc_instr_q_even,

    output full_out_dc_instr_q_even,

        //I$_DATA_Q_in
    input[31:0] addr_in_dc_data_q_odd,
    input [CL_SIZE-1:0] data_in_dc_data_q_odd,
    input [2:0] operation_in_dc_data_q_odd,
    input is_flush_in_dc_data_q_odd,
    input alloc_in_dc_data_q_odd,
    input [1:0] src_in_dc_data_q_odd,
    input [1:0] dest_in_dc_data_q_odd,

    output full_out_dc_data_q_odd,
    
    //I$_INSTR_Q_in
    input[31:0] addr_in_dc_instr_q_odd,
    input [2:0] operation_in_dc_instr_q_odd,
    input is_flush_in_dc_instr_q_odd,
    input alloc_in_dc_instr_q_odd,
    input [1:0] src_in_dc_instr_q_odd,
    input [1:0] dest_in_dc_instr_q_odd,

    output full_out_dc_instr_q_odd,

    //OUTPUTS TO MEM

    //I$_DATA_Q_in
    output[31:0] addr_out_dc_data_q_even,
    output [CL_SIZE-1:0] data_out_dc_data_q_even,
    output [2:0] operation_out_dc_data_q_even,
    output is_flush_out_dc_data_q_even,
    output alloc_out_dc_data_q_even,
    output [1:0] src_out_dc_data_q_even,
    output [1:0] dest_out_dc_data_q_even,

    input full_in_dc_data_q_even,
    
    //I$_INSTR_Q_in
    output[31:0] addr_out_dc_instr_q_even,
    output [2:0] operation_out_dc_instr_q_even,
    output is_flush_out_dc_instr_q_even,
    output alloc_out_dc_instr_q_even,
    output [1:0] src_out_dc_instr_q_even,
    output [1:0] dest_out_dc_instr_q_even,

    input full_in_dc_instr_q_even,

        //I$_DATA_Q_in
    output[31:0] addr_out_dc_data_q_odd,
    output [CL_SIZE-1:0] data_out_dc_data_q_odd,
    output [2:0] operation_out_dc_data_q_odd,
    output is_flush_out_dc_data_q_odd,
    output alloc_out_dc_data_q_odd,
    output [1:0] src_out_dc_data_q_odd,
    output [1:0] dest_out_dc_data_q_odd,

    input full_in_dc_data_q_odd,
    
    //I$_INSTR_Q_in
    output[31:0] addr_out_dc_instr_q_odd,
    output [2:0] operation_out_dc_instr_q_odd,
    output is_flush_out_dc_instr_q_odd,
    output alloc_out_dc_instr_q_odd,
    output [1:0] src_out_dc_instr_q_odd,
    output [1:0] dest_out_dc_instr_q_odd,

    input full_in_dc_instr_q_odd
);



localparam  NO_OP= 0;
localparam LD = 1;
localparam ST = 2;
localparam RD = 3;
localparam  WR= 4;
localparam  INV = 5;
localparam  UPD= 6;
localparam RWITM = 7;
localparam RINV = 7;
localparam REPLY = 2;

wire[4:0] dealloc_des_even, dealloc_des_odd;

//Pipeline Output : 
wire [31:0] addr_out_bank_even;
wire [CL_SIZE-1:0] data_out_bank_even;
wire [1:0] size_out_bank_even;
wire [2:0] operation_out_bank_even ;
wire [OOO_TAG_SIZE-1:0] ooo_tag_out_bank_even;
wire  hit_bank_even;

wire [OOO_TAG_SIZE-1:0] ooo_tag_in_orig;
wire [OOO_ROB_SIZE-1:0] ooo_rob_in_orig;
wire [31:0] addr_in_orig;
wire[31:0] data_in_orig;
wire [2:0] operation_in_orig;
wire [1:0] size_in_orig;
wire sext_in_orig;

wire [OOO_TAG_SIZE-1:0] ooo_tag_out_orig;
wire [OOO_ROB_SIZE-1:0] ooo_rob_out_orig;
wire [31:0] addr_out_orig;
wire[31:0] data_out_orig;
wire [2:0] operation_out_orig;
wire [1:0] size_out_orig;
wire sext_out_orig;

wire [31:0] dcache_addr_in_dc_data_q_even;
wire  [CL_SIZE-1:0] dcache_data_in_dc_data_q_even;
wire  [2:0] dcache_operation_in_dc_data_q_even;
wire  dcache_is_flush_in_dc_data_q_even;
wire  dcache_valid_in_dc_data_q_even;
wire  [1:0] dcache_src_in_dc_data_q_even;
wire  [1:0] dcache_dest_in_dc_data_q_even;
 
     //I$_INSTR_Q_in
wire [31:0] dcache_addr_in_dc_instr_q_even;
wire  [2:0] dcache_operation_in_dc_instr_q_even;
wire  dcache_is_flush_in_dc_instr_q_even;
wire  dcache_valid_in_dc_instr_q_even;
wire  [1:0] dcache_src_in_dc_instr_q_even;
wire  [1:0] dcache_dest_in_dc_instr_q_even;

     //I$_DATA_Q_in
wire [31:0] dcache_addr_in_dc_data_q_odd;
wire  [CL_SIZE-1:0] dcache_data_in_dc_data_q_odd;
wire  [2:0] dcache_operation_in_dc_data_q_odd;
wire  dcache_is_flush_in_dc_data_q_odd;
wire  dcache_valid_in_dc_data_q_odd;
wire  [1:0] dcache_src_in_dc_data_q_odd;
wire  [1:0] dcache_dest_in_dc_data_q_odd;
 
     //I$_INSTR_Q_in
wire [31:0] dcache_addr_in_dc_instr_q_odd;
wire  [2:0] dcache_operation_in_dc_instr_q_odd;
wire  dcache_is_flush_in_dc_instr_q_odd;
wire  dcache_valid_in_dc_instr_q_odd;
wire  [1:0] dcache_src_in_dc_instr_q_odd;
wire  [1:0] dcache_dest_in_dc_instr_q_odd;

wire[4:0] dealloc_even;
wire[4:0] dealloc_odd;


wire [31:0] pipe_addr_in_dc_data_q;
wire  [CL_SIZE-1:0] pipe_data_in_dc_data_q;
wire  [2:0] pipe_operation_in_dc_data_q;
wire  pipe_is_flush_in_dc_data_q;
wire  pipe_valid_in_dc_data_q;
wire  [1:0] pipe_src_in_dc_data_q;
wire  [1:0] pipe_dest_in_dc_data_q;
wire [1:0] pipe_size_in_dc_data_q;
wire [OOO_TAG_SIZE-1:0] pipe_ooo_tag_in_dc_data_q;
wire [OOO_ROB_SIZE-1:0] pipe_ooo_rob_in_dc_data_q;
wire pipe_sext_in_dc_data_q;

wire [31:0] pipe_addr_in_dc_data_q_even;
wire  [CL_SIZE-1:0] pipe_data_in_dc_data_q_even;
wire  [2:0] pipe_operation_in_dc_data_q_even;
wire  pipe_is_flush_in_dc_data_q_even;
wire  pipe_valid_in_dc_data_q_even;
wire  [1:0] pipe_src_in_dc_data_q_even;
wire  [1:0] pipe_dest_in_dc_data_q_even;
wire [1:0] pipe_size_in_dc_data_q_even;
wire [OOO_TAG_SIZE-1:0] pipe_ooo_tag_in_dc_data_q_even;
wire [OOO_ROB_SIZE-1:0] pipe_ooo_rob_in_dc_data_q_even;
wire pipe_sext_in_dc_data_q_even;


dinpq #(.Q_LENGTH(8), .DATA_SIZE(32), .OOO_TAG_SIZE(OOO_TAG_SIZE), .OOO_ROB_SIZE(OOO_ROB_SIZE), .CL_SIZE(CL_SIZE)) data_input_q (

.clk(clk),
.rst(rst),
.resteer(rob_resteer),

//FROM RSV
.alloc(ls_unit_alloc), //Data from RAS is valid or not

.addr_in(addr_in),
.data_in(data_in),
.size_in(size_in), //
.is_st_in(is_st_in), //Say whether input is ST or LD
.ooo_tag_in(ooo_tag_in), //tag from register renaming
.ooo_rob_in(ooo_rob_in),
.sext_in(sext),

.dealloc(dealloc_even[0] || dealloc_odd[0]),

.valid(valid_pipe),

.addr_out(pipe_addr_in_dc_data_q),
.data_out(pipe_data_in_dc_data_q),
.size_out(pipe_size_in_dc_data_q), //
.operation_out(pipe_operation_in_dc_data_q), //Say whether input is ST or LD
.ooo_tag_out(pipe_ooo_tag_in_dc_data_q), //tag from register renaming
.ooo_rob_out(pipe_ooo_rob_in_dc_data_q),
.src_out(pipe_src_in_dc_data_q), 
.dest_out(pipe_dest_in_dc_data_q),
.sext_out(pipe_sext_in_dc_data_q),

.full(stall)

);
wire [31:0] lsq_addr_in_dc_data_q;
wire  [CL_SIZE-1:0] lsq_data_in_dc_data_q;
wire  [2:0] lsq_operation_in_dc_data_q;
wire  lsq_is_flush_in_dc_data_q;
wire  lsq_valid_in_dc_data_q;
wire  [1:0] lsq_src_in_dc_data_q;
wire  [1:0] lsq_dest_in_dc_data_q;
wire [1:0] lsq_size_in_dc_data_q;
wire [OOO_TAG_SIZE-1:0] lsq_ooo_tag_in_dc_data_q;
wire [OOO_ROB_SIZE-1:0] lsq_ooo_rob_in_dc_data_q;
wire lsq_sext_in_dc_data_q;

wire [31:0] lsq_addr_in_dc_data_q_even;
wire  [CL_SIZE-1:0] lsq_data_in_dc_data_q_even;
wire  [2:0] lsq_operation_in_dc_data_q_even;
wire  lsq_is_flush_in_dc_data_q_even;
wire  lsq_valid_in_dc_data_q_even;
wire  [1:0] lsq_src_in_dc_data_q_even;
wire  [1:0] lsq_dest_in_dc_data_q_even;
wire [1:0] lsq_size_in_dc_data_q_even;
wire [OOO_TAG_SIZE-1:0] lsq_ooo_tag_in_dc_data_q_even;
wire [OOO_ROB_SIZE-1:0] lsq_ooo_rob_in_dc_data_q_even;
wire lsq_sext_in_dc_data_q_even;

wire [31:0] lsq_addr_in_dc_data_q_odd;
wire  [CL_SIZE-1:0] lsq_data_in_dc_data_q_odd;
wire  [2:0] lsq_operation_in_dc_data_q_odd;
wire  lsq_is_flush_in_dc_data_q_odd;
wire  lsq_valid_in_dc_data_q_odd;
wire  [1:0] lsq_src_in_dc_data_q_odd;
wire  [1:0] lsq_dest_in_dc_data_q_odd;
wire [1:0] lsq_size_in_dc_data_q_odd;
wire [OOO_TAG_SIZE-1:0] lsq_ooo_tag_in_dc_data_q_odd;
wire [OOO_ROB_SIZE-1:0] lsq_ooo_rob_in_dc_data_q_odd;
wire lsq_sext_in_dc_data_q_odd;


wire[2:0] mshr_hit_ptr_even;//Not needed for I$
wire[2:0] mshr_wr_ptr_even;//Not needed for I$
wire[2:0] mshr_fin_ptr_even;//Not needed for I$

wire[2:0] mshr_hit_ptr_odd;//Not needed for I$
wire[2:0]  mshr_wr_ptr_odd;//Not needed for I$
wire[2:0] mshr_fin_ptr_odd;//Not needed for I$

wire [31:0] pipe_addr_in_dc_data_q_odd;
wire  [CL_SIZE-1:0] pipe_data_in_dc_data_q_odd;
wire  [2:0] pipe_operation_in_dc_data_q_odd;
wire  pipe_is_flush_in_dc_data_q_odd;
wire  pipe_valid_in_dc_data_q_odd;
wire  [1:0] pipe_src_in_dc_data_q_odd;
wire  [1:0] pipe_dest_in_dc_data_q_odd;
wire [1:0] pipe_size_in_dc_data_q_odd;
wire [OOO_TAG_SIZE-1:0] pipe_ooo_tag_in_dc_data_q_odd;
wire [OOO_ROB_SIZE-1:0] pipe_ooo_rob_in_dc_data_q_odd;
wire pipe_sext_in_dc_data_q_odd;

//Pipeline Output : 
wire [31:0] addr_out_bank_odd;
wire [CL_SIZE-1:0] data_out_bank_odd;
wire [1:0] size_out_bank_odd;
wire [2:0] operation_out_bank_odd ;
wire [OOO_TAG_SIZE-1:0] ooo_tag_out_bank_odd;
wire  hit_bank_odd;

assign lsq_alloc = lsq_alloc_even || lsq_alloc_odd;
lsq #(.Q_LENGTH(8), .OOO_TAG_BITS(OOO_TAG_SIZE), .OOO_ROB_BITS(OOO_ROB_SIZE)) lsq_one (
    .clk(clk),
    .rst(rst),

    //From cache
    .dealloc(dealloc_even[1] || dealloc_odd[1]),
    .alloc(lsq_alloc),
    
    .operation_in_even(operation_out_bank_even),
    .operation_in_odd(operation_out_bank_odd), 
    .addr_in(addr_out_orig),
    .data_in(data_out_orig),
    .ooo_tag_in(ooo_tag_out_orig),
    .ooo_rob_in(ooo_rob_out_orig),
    .size_in(size_out_orig),
    .sext_in(sext_out_orig),

    .hit_even(hit_bank_even),
    .hit_odd(hit_bank_odd),

    //From MSHR  x
    .mshr_wr_idx_even(mshr_wr_ptr_even), //next location to be allocated into mshr
    .mshr_fin_even(mshr_fin_even),
    .mshr_fin_idx_even(mshr_fin_ptr_even),// location being deallocated from mshr

    .mshr_wr_idx_odd(mshr_wr_ptr_odd), //next location to be allocated into mshr
    .mshr_fin_odd(mshr_fin_odd),
    .mshr_fin_idx_odd(mshr_fin_ptr_odd),// location being deallocated from mshr

    //outputs 
    .ooo_tag_out(lsq_ooo_tag_in_dc_data_q),
    .ooo_rob_out(lsq_ooo_rob_in_dc_data_q),
    .data_out(lsq_data_in_dc_data_q),
    .addr_out(lsq_addr_in_dc_data_q),
    .operation_out(lsq_operation_in_dc_data_q),
    .size_out(lsq_size_in_dc_data_q),
    .sext_out(lsq_sext_in_dc_data_q),
    
    .valid_out(valid_lsq),
    .lsq_full(lsq_full)
);



d_split #(.CL_SIZE(CL_SIZE), .IDX_CNT(IDX_CNT), .OOO_TAG_SIZE(OOO_TAG_SIZE), .TAG_SIZE(TAG_SIZE)) split_lsq(
    .clk(clk),
    .rst(rst),

    .stall(1'b0), //TODO: Check this
   
    .addr_in(lsq_addr_in_dc_data_q),
    .data_in(lsq_data_in_dc_data_q),
    .size_in(lsq_size_in_dc_data_q),
    .operation_in(lsq_operation_in_dc_data_q),
    .ooo_tag_in(lsq_ooo_tag_in_dc_data_q),

    .addr_out_e(lsq_addr_in_dc_data_q_even),
    .data_out_e(lsq_data_in_dc_data_q_even),
    .size_out_e(lsq_size_in_dc_data_q_even),
    .operation_out_e(lsq_operation_in_dc_data_q_even),
    .ooo_tag_out_e(lsq_ooo_tag_in_dc_data_q_even),

    .addr_out_o(lsq_addr_in_dc_data_q_odd),
    .data_out_o(lsq_data_in_dc_data_q_odd),
    .size_out_o(lsq_size_in_dc_data_q_odd),
    .operation_out_o(lsq_operation_in_dc_data_q_odd),
    .ooo_tag_out_o(lsq_ooo_tag_in_dc_data_q_odd),

     .wake_e(         lsq_wake_even),
     .wake_o(         lsq_wake_odd),
     .out_q_alloc(    lsq_alloc_q),
     .use_e_as_0(     lsq_e_as_0),
     .need_p1(        lsq_need_p1)
);

d_split #(.CL_SIZE(CL_SIZE), .IDX_CNT(IDX_CNT), .OOO_TAG_SIZE(OOO_TAG_SIZE), .TAG_SIZE(TAG_SIZE)) split_pipe(
    .clk(clk),
    .rst(rst),

    .stall(1'b0),
   
    .addr_in(pipe_addr_in_dc_data_q),
    .data_in(pipe_data_in_dc_data_q),
    .size_in(pipe_size_in_dc_data_q),
    .operation_in(pipe_operation_in_dc_data_q),
    .ooo_tag_in(pipe_ooo_tag_in_dc_data_q),

    .addr_out_e(pipe_addr_in_dc_data_q_even),
    .data_out_e(pipe_data_in_dc_data_q_even),
    .size_out_e(pipe_size_in_dc_data_q_even),
    .operation_out_e(pipe_operation_in_dc_data_q_even),
    .ooo_tag_out_e(pipe_ooo_tag_in_dc_data_q_even),

    .addr_out_o(pipe_addr_in_dc_data_q_odd),
    .data_out_o(pipe_data_in_dc_data_q_odd),
    .size_out_o(pipe_size_in_dc_data_q_odd),
    .operation_out_o(pipe_operation_in_dc_data_q_odd),
    .ooo_tag_out_o(pipe_ooo_tag_in_dc_data_q_odd),

     .wake_e(       pipe_wake_even),
     .wake_o(       pipe_wake_odd),
     .out_q_alloc(  pipe_alloc_q),
     .use_e_as_0(   pipe_e_as_0),
     .need_p1(      pipe_need_p1)
);

assign pipe_valid_even =  valid_pipe && pipe_operation_in_dc_data_q_even != 0;
assign pipe_valid_odd =   valid_pipe && pipe_operation_in_dc_data_q_odd != 0;

assign lsq_valid_even = valid_lsq && lsq_operation_in_dc_data_q_even != 0;
assign lsq_valid_odd = valid_lsq &&  lsq_operation_in_dc_data_q_odd != 0;

wire [31:0] rwnd_addr_in_dc_data_q_even;
wire  [CL_SIZE-1:0] rwnd_data_in_dc_data_q_even;
wire  [2:0] rwnd_operation_in_dc_data_q_even;
wire  rwnd_is_flush_in_dc_data_q_even;
wire  rwnd_valid_in_dc_data_q_even;
wire  [1:0] rwnd_src_in_dc_data_q_even;
wire  [1:0] rwnd_dest_in_dc_data_q_even;
wire [1:0] rwnd_size_in_dc_data_q_even;
wire [OOO_TAG_SIZE-1:0] rwnd_ooo_tag_in_dc_data_q_even;
wire [OOO_ROB_SIZE-1:0] rwnd_ooo_rob_in_dc_data_q_even;
wire rwnd_sext_in_dc_data_q_even;

wire [31:0] rwnd_addr_in_dc_data_q_odd;
wire  [CL_SIZE-1:0] rwnd_data_in_dc_data_q_odd;
wire  [2:0] rwnd_operation_in_dc_data_q_odd;
wire  rwnd_is_flush_in_dc_data_q_odd;
wire  rwnd_valid_in_dc_data_q_odd;
wire  [1:0] rwnd_src_in_dc_data_q_odd;
wire  [1:0] rwnd_dest_in_dc_data_q_odd;
wire [1:0] rwnd_size_in_dc_data_q_odd;
wire [OOO_TAG_SIZE-1:0] rwnd_ooo_tag_in_dc_data_q_odd;
wire [OOO_ROB_SIZE-1:0] rwnd_ooo_rob_in_dc_data_q_odd;
wire rwnd_sext_in_dc_data_q_odd;

wire [31:0] rwnd_addr_in_dc_data_q;
wire  [CL_SIZE-1:0] rwnd_data_in_dc_data_q;
wire  [2:0] rwnd_operation_in_dc_data_q;
wire  rwnd_is_flush_in_dc_data_q;
wire  rwnd_valid_in_dc_data_q;
wire  [1:0] rwnd_src_in_dc_data_q;
wire  [1:0] rwnd_dest_in_dc_data_q;
wire [1:0] rwnd_size_in_dc_data_q;
wire [OOO_TAG_SIZE-1:0] rwnd_ooo_tag_in_dc_data_q;
wire [OOO_ROB_SIZE-1:0] rwnd_ooo_rob_in_dc_data_q;
wire rwnd_sext_in_dc_data_q;
/////////////////////////////////////
//  Begin Even Side
/////////////////////////////////////


data_q #(.Q_LENGTH(8), .CL_SIZE(CL_SIZE)) dcache_data_q_even(
    //System     
    .clk(clk),
    .rst(rst),

    //From Sender
    .addr_in(addr_in_dc_data_q_even),
    .data_in(data_in_dc_data_q_even),
    .operation_in(operation_in_dc_data_q_even),
    .is_flush(is_flush_in_dc_data_q_even),
    .alloc(alloc_in_dc_data_q_even),
    .src(src_in_dc_data_q_even),
    .dest(dest_in_dc_data_q_even),
    //From reciever
    .dealloc(dealloc_even[4]),

    //output sender
    .full(full_out_dc_data_q_even),

    //output reciever
    .addr_out(dcache_addr_in_dc_data_q_even),
    .data_out(dcache_data_in_dc_data_q_even),
    .operation_out(dcache_operation_in_dc_data_q_even),
    .valid(dcache_valid_in_dc_data_q_even),
    .src_out(dcache_src_in_dc_data_q_even),
    .dest_out(dcache_dest_in_dc_data_q_even),
    .is_flush_out(dcache_is_flush_in_dc_data_q_even)
);

instr_q  #(.Q_LENGTH(8), .CL_SIZE(CL_SIZE)) dcache_instr_q_even(
    //System     
    .clk(clk),
    .rst(rst),

    //From Sender
    .addr_in(addr_in_dc_instr_q_even),
    .operation_in(operation_in_dc_instr_q_even),
    .is_flush(is_flush_in_dc_instr_q_even),
    .alloc(alloc_in_dc_instr_q_even),
    .src(src_in_dc_instr_q_even),
    .dest(dest_in_dc_instr_q_even),

    //From reciever
    .dealloc(dealloc_even[3]),

    //output sender
    .full(full_out_dc_instr_q_even),

    //output reciever
    .addr_out(dcache_addr_in_dc_instr_q_even),
    .operation_out(dcache_operation_in_dc_instr_q_even),
    .valid(dcache_valid_in_dc_instr_q_even),
    .src_out(dcache_src_in_dc_instr_q_even),
    .dest_out(dcache_dest_in_dc_instr_q_even),
    .is_flush_out(dcache_is_flush_in_dc_instr_q_even)
);



rewind #(.OOO_TAG_SIZE(OOO_TAG_SIZE)) rwnd_even(
    //Global
.clk(clk),
.rst(rst),
.stall(1'b0),


//From ROB
.rob_ret_tag_in(rob_ret_tag_in),
.rob_valid(rob_valid),
.rob_resteer(rob_resteer),

//From Cache
.addr_in(addr_out_bank_even),
.data_repl(rwnd_data_even),
.operation(operation_out_bank_even),
.cache_ooo_tag_in(ooo_tag_out_bank_even),
.size(size_out_bank_even),
.alloc(rwnd_alloc_even),

.dealloc(dealloc_even[2]),

//To Cache
.valid_rewind(rwnd_valid_even),
.addr_out(rwnd_addr_in_dc_data_q_even),
.data_out(rwnd_data_in_dc_data_q_even),
.operation_out(rwnd_operation_in_dc_data_q_even),
.cache_ooo_tag_out(rwnd_ooo_tag_in_dc_data_q_even),
.size_out(rwnd_size_in_dc_data_q_even),

.rewind_full(rwnd_full_even)
);

wire [31:0] dcache_addr_in_even;
wire  [2:0] dcache_operation_in_even;
wire [CL_SIZE-1:0] dcache_data_in_even;
wire dcache_valid_in_even;
wire [1:0]dcache_src_in_even;
wire [1:0] dcache_dest_in_even;
wire dcache_is_flush_in_even;

wire [31:0] dcache_addr_in_odd;
wire  [2:0] dcache_operation_in_odd;
wire [CL_SIZE-1:0] dcache_data_in_odd;
wire dcache_valid_in_odd;
wire [1:0]dcache_src_in_odd;
wire [1:0] dcache_dest_in_odd;
wire dcache_is_flush_in_odd;
queue_arbitrator_sync #(.CL_SIZE(CL_SIZE), .Q_WIDTH(5)) queue_arb_even(
    .rst(rst),
    .addr_in({
        dcache_addr_in_dc_data_q_even,
        dcache_addr_in_dc_instr_q_even,
          rwnd_addr_in_dc_data_q_even,
           lsq_addr_in_dc_data_q_even,
          pipe_addr_in_dc_data_q_even

    }),
    .data_in({
        dcache_data_in_dc_data_q_even,
        128'd0,
          rwnd_data_in_dc_data_q_even,
           lsq_data_in_dc_data_q_even,
          pipe_data_in_dc_data_q_even
    }),
    .operation_in({
        dcache_operation_in_dc_data_q_even,
        dcache_operation_in_dc_instr_q_even,
          rwnd_operation_in_dc_data_q_even,
           lsq_operation_in_dc_data_q_even,
          pipe_operation_in_dc_data_q_even
    }), 
    .valid_in({
        dcache_valid_in_dc_data_q_even,
        dcache_valid_in_dc_instr_q_even,
        rwnd_valid_even,
        lsq_valid_even,
        pipe_valid_even
    }),
    .src_in({
        dcache_src_in_dc_data_q_even,
        dcache_src_in_dc_instr_q_even,
        2'b00,
        2'b00,
        2'b00
    }),
    .dest_in({
        dcache_dest_in_dc_data_q_even,
        dcache_dest_in_dc_instr_q_even,
        2'b00,
        2'b00,
        2'b00
    }),
    .is_flush_in({
        dcache_is_flush_in_dc_data_q_even,
        dcache_is_flush_in_dc_instr_q_even,
        1'b0,
        1'b0,
        1'b0
    }),

    .stall_in(stall_cache_even),

    .partner_dealloc(dealloc_des_odd),
    .dealloc_desired(dealloc_des_even),

    .addr_out(      dcache_addr_in_even),
    .operation_out( dcache_operation_in_even), 
    .data_out(      dcache_data_in_even),
    .valid_out(     dcache_valid_in_even),
    .src_out(       dcache_src_in_even),
    .dest_out(      dcache_dest_in_even),
    .is_flush_out(  dcache_is_flush_in_even),

    .dealloc(dealloc_even)
);
wire [1:0] size_in_even;
wire[OOO_TAG_SIZE -1 : 0] ooo_tag_in_even;
wire[OOO_ROB_SIZE-1:0]ooo_rob_in_even;
assign size_in_even = dealloc_even[2] ? rwnd_size_in_dc_data_q_even : dealloc_even[1] ? lsq_size_in_dc_data_q :  dealloc_even[0] ? pipe_size_in_dc_data_q_even : 0;
assign ooo_tag_in_even = dealloc_even[2] ? rwnd_ooo_tag_in_dc_data_q_even : dealloc_even[1] ? lsq_ooo_tag_in_dc_data_q : dealloc_even[0] ? pipe_ooo_tag_in_dc_data_q_even : 0;
assign ooo_rob_in_even = dealloc_even[2] ? rwnd_ooo_rob_in_dc_data_q_even : dealloc_even[1] ? lsq_ooo_rob_in_dc_data_q : dealloc_even[0] ? pipe_ooo_rob_in_dc_data_q : 0;







//Cache

wire [31:0] lsq_data_even; //Not needed for I$

wire[31:0] rwnd_data_even;



assign ooo_tag_in_orig = ooo_tag_in_even;
assign ooo_rob_in_orig = ooo_rob_in_even;
assign addr_in_orig = 
    dealloc_even[4] ? dcache_addr_in_dc_data_q_even :
    dealloc_even[3] ? dcache_addr_in_dc_instr_q_even :
    dealloc_even[2] ? rwnd_addr_in_dc_data_q_even :
    dealloc_even[1] ? lsq_addr_in_dc_data_q :
    dealloc_even[0] ? pipe_addr_in_dc_data_q :
    0;
assign data_in_orig = 
    dealloc_even[4] ? dcache_data_in_dc_data_q_even :
    dealloc_even[3] ? 128'd0 :
    dealloc_even[2] ? rwnd_data_in_dc_data_q_even :
    dealloc_even[1] ? lsq_data_in_dc_data_q :
    dealloc_even[0] ? pipe_data_in_dc_data_q :
    0;
assign operation_in_orig = 
    dealloc_even[4] ? dcache_operation_in_dc_data_q_even :
    dealloc_even[3] ? dcache_operation_in_dc_instr_q_even :
    dealloc_even[2] ? rwnd_operation_in_dc_data_q_even :
    dealloc_even[1] ? lsq_operation_in_dc_data_q :
    dealloc_even[0] ? pipe_operation_in_dc_data_q :
    0;
assign size_in_orig = 
    dealloc_even[4] ? 0 :  
    dealloc_even[3] ? 0 :
    dealloc_even[2] ? rwnd_size_in_dc_data_q_even :
    dealloc_even[1] ? lsq_size_in_dc_data_q :
    dealloc_even[0] ? pipe_size_in_dc_data_q :
    0;
assign sext_in_orig =   dealloc_even[1] ? lsq_sext_in_dc_data_q : pipe_sext_in_dc_data_q;
    
   
cache_bank #(.CL_SIZE(CL_SIZE), .IDX_CNT(IDX_CNT), .TAG_SIZE(TAG_SIZE), .OOO_TAG_SIZE(OOO_TAG_SIZE), .BANK_NAME(3)) cache_bank_even (
    //Systen Input
    .clk(clk),
    .rst(rst),

    //Pipeline Input - done
    .addr_in(dcache_addr_in_even),
    .data_in(dcache_data_in_even),
    .size_in(size_in_even),
    .operation_in(dcache_operation_in_even),
    .ooo_tag_in(ooo_tag_in_even),

    //Cache Inputs
    .rwnd_full(rwnd_full_even),
    .lsq_full(lsq_full),


    //Pipeline Output : 
    .addr_out(addr_out_bank_even),
    .data_out(data_out_bank_even),
    .size_out(size_out_bank_even), //Not needed for I$
    .operation_out(operation_out_bank_even), 
    .ooo_tag_out(ooo_tag_out_bank_even), //Not needed for I$
    .hit(hit_bank_even),

    //Outputs to LSQ
    //MSHR
    .mshr_hit(mshr_hit_bank_even), 
    .mshr_hit_ptr(mshr_hit_ptr_even),
    .mshr_wr_ptr(mshr_wr_ptr_even),
    .mshr_fin_ptr(mshr_fin_ptr_even),
    .mshr_fin(mshr_fin_even),
    .mshr_full(mshr_full_bank_even), 

    //Cache
    .lsq_alloc(lsq_alloc_even), //Not needed for I$
    .lsq_data(lsq_data_even), //Not needed for I$

    //Outputs to RWND Q
    .rwnd_alloc(rwnd_alloc_even),  //Not needed for I$
    .rwnd_data(rwnd_data_even),//Not needed for I$


    //Requests to DRAM/Directory
    //Evdction Q
    .operation_evic(operation_out_dc_data_q_even),
    .addr_evic(addr_out_dc_data_q_even), 
    .alloc_evic(alloc_out_dc_data_q_even),
    .data_evic(data_out_dc_data_q_even),
    //Miss Q
    .operation_miss(operation_out_dc_instr_q_even),
    .addr_miss(addr_out_dc_instr_q_even),
    .alloc_miss(alloc_out_dc_instr_q_even),

    .stall_cache(stall_cache_even), 

    .operation_in_orig(operation_in_orig),
    .addr_in_orig(addr_in_orig),
    .data_in_orig(data_in_orig),
    .ooo_tag_in_orig(ooo_tag_in_orig),
    .ooo_rob_in_orig(ooo_rob_in_orig),
    .size_in_orig(size_in_orig),
    .sext_in_orig(sext_in_orig),

    .operation_out_orig(operation_out_orig),
    .addr_out_orig(addr_out_orig),
    .data_out_orig(data_out_orig),
    .ooo_tag_out_orig(ooo_tag_out_orig),
    .ooo_rob_out_orig(ooo_rob_out_orig),
    .size_out_orig(size_out_orig),
    .sext_out_orig(sext_out_orig)
);

assign is_flush_out_dc_data_q_even = 0;
assign  src_out_dc_data_q_even = 2;
assign dest_out_dc_data_q_evend = operation_out_dc_data_q_even == WR ? 3 : 2;

assign is_flush_out_dc_instr_q_even = 0;
assign src_out_dc_instr_q_even = 2;
assign dest_out_dc_instr_q_even = operation_out_dc_instr_q_even == WR || operation_out_dc_instr_q_even == RD ? 3 : 2;

/////////////////////////////////////
//  Begin Even Side
/////////////////////////////////////


data_q #(.Q_LENGTH(8), .CL_SIZE(CL_SIZE)) dcache_data_q_odd(
    //System     
    .clk(clk),
    .rst(rst),

    //From Sender
    .addr_in(addr_in_dc_data_q_odd),
    .data_in(data_in_dc_data_q_odd),
    .operation_in(operation_in_dc_data_q_odd),
    .is_flush(is_flush_in_dc_data_q_odd),
    .alloc(alloc_in_dc_data_q_odd),
    .src(src_in_dc_data_q_odd),
    .dest(dest_in_dc_data_q_odd),
    //From reciever
    .dealloc(dealloc_odd[4]),

    //output sender
    .full(full_out_dc_data_q_odd),

    //output reciever
    .addr_out(dcache_addr_in_dc_data_q_odd),
    .data_out(dcache_data_in_dc_data_q_odd),
    .operation_out(dcache_operation_in_dc_data_q_odd),
    .valid(dcache_valid_in_dc_data_q_odd),
    .src_out(dcache_src_in_dc_data_q_odd),
    .dest_out(dcache_dest_in_dc_data_q_odd),
    .is_flush_out(dcache_is_flush_in_dc_data_q_odd)
);

instr_q  #(.Q_LENGTH(8), .CL_SIZE(CL_SIZE)) dcache_instr_q_odd(
    //System     
    .clk(clk),
    .rst(rst),

    //From Sender
    .addr_in(addr_in_dc_instr_q_odd),
    .operation_in(operation_in_dc_instr_q_odd),
    .is_flush(is_flush_in_dc_instr_q_odd),
    .alloc(alloc_in_dc_instr_q_odd),
    .src(src_in_dc_instr_q_odd),
    .dest(dest_in_dc_instr_q_odd),

    //From reciever
    .dealloc(dealloc_odd[3]),

    //output sender
    .full(full_out_dc_instr_q_odd),

    //output reciever
    .addr_out(dcache_addr_in_dc_instr_q_odd),
    .operation_out(dcache_operation_in_dc_instr_q_odd),
    .valid(dcache_valid_in_dc_instr_q_odd),
    .src_out(dcache_src_in_dc_instr_q_odd),
    .dest_out(dcache_dest_in_dc_instr_q_odd),
    .is_flush_out(dcache_is_flush_in_dc_instr_q_odd)
);



rewind #(.OOO_TAG_SIZE(OOO_TAG_SIZE)) rwnd_odd(
    //Global
.clk(clk),
.rst(rst),
.stall(1'b0),


//From ROB
.rob_ret_tag_in(rob_ret_tag_in),
.rob_valid(rob_valid),
.rob_resteer(rob_resteer),

//From Cache
.addr_in(addr_out_bank_odd),
.data_repl(rwnd_data_odd),
.operation(operation_out_bank_odd),
.cache_ooo_tag_in(ooo_tag_out_bank_odd),
.size(size_out_bank_odd),
.alloc(rwnd_alloc_odd),

.dealloc(dealloc_odd[2]),

//To Cache
.valid_rewind(rwnd_valid_odd),
.addr_out(rwnd_addr_in_dc_data_q_odd),
.data_out(rwnd_data_in_dc_data_q_odd),
.operation_out(rwnd_operation_in_dc_data_q_odd),
.cache_ooo_tag_out(rwnd_ooo_tag_in_dc_data_q_odd),
.size_out(rwnd_size_in_dc_data_q_odd),

.rewind_full(rwnd_full_odd)
);




queue_arbitrator_sync #(.CL_SIZE(CL_SIZE), .Q_WIDTH(5)) queue_arb_odd(
    .rst(rst),
    .addr_in({
        dcache_addr_in_dc_data_q_odd,
        dcache_addr_in_dc_instr_q_odd,
          rwnd_addr_in_dc_data_q_odd,
           lsq_addr_in_dc_data_q_odd,
          pipe_addr_in_dc_data_q_odd

    }),
    .data_in({
        dcache_data_in_dc_data_q_odd,
        128'd0,
          rwnd_data_in_dc_data_q_odd,
           lsq_data_in_dc_data_q_odd,
          pipe_data_in_dc_data_q_odd
    }),
    .operation_in({
        dcache_operation_in_dc_data_q_odd,
        dcache_operation_in_dc_instr_q_odd,
          rwnd_operation_in_dc_data_q_odd,
           lsq_operation_in_dc_data_q_odd,
          pipe_operation_in_dc_data_q_odd
    }), 
    .valid_in({
        dcache_valid_in_dc_data_q_odd,
        dcache_valid_in_dc_instr_q_odd,
        rwnd_valid_odd,
        lsq_valid_odd,
        pipe_valid_odd
    }),
    .src_in({
        dcache_src_in_dc_data_q_odd,
        dcache_src_in_dc_instr_q_odd,
        2'b00,
        2'b00,
        2'b00
    }),
    .dest_in({
        dcache_dest_in_dc_data_q_odd,
        dcache_dest_in_dc_instr_q_odd,
        2'b00,
        2'b00,
        2'b00
    }),
    .is_flush_in({
        dcache_is_flush_in_dc_data_q_odd,
        dcache_is_flush_in_dc_instr_q_odd,
        1'b0,
        1'b0,
        1'b0
    }),
    
    .stall_in(stall_cache_odd),

    .partner_dealloc(dealloc_des_even),
    .dealloc_desired(dealloc_des_odd),

    .addr_out(      dcache_addr_in_odd),
    .operation_out( dcache_operation_in_odd), 
    .data_out(      dcache_data_in_odd),
    .valid_out(     dcache_valid_in_odd),
    .src_out(       dcache_src_in_odd),
    .dest_out(      dcache_dest_in_odd),
    .is_flush_out(  dcache_is_flush_in_odd),

    .dealloc(dealloc_odd)
);
wire [1:0] size_in_odd;
wire[OOO_TAG_SIZE -1 : 0] ooo_tag_in_odd;
wire[OOO_ROB_SIZE-1:0]ooo_rob_in_odd;
assign size_in_odd = dealloc_odd[2] ? rwnd_size_in_dc_data_q_odd : dealloc_odd[1] ? lsq_size_in_dc_data_q : dealloc_odd[0] ? pipe_size_in_dc_data_q_odd : 0;
assign ooo_tag_in_odd = dealloc_odd[2] ? rwnd_ooo_tag_in_dc_data_q_odd : dealloc_odd[1] ? lsq_ooo_tag_in_dc_data_q : dealloc_odd[0] ? pipe_ooo_tag_in_dc_data_q_odd :0;
assign ooo_rob_in_odd = dealloc_odd[2] ? rwnd_ooo_rob_in_dc_data_q_odd : dealloc_odd[1] ? lsq_ooo_rob_in_dc_data_q : dealloc_odd[0] ? pipe_ooo_rob_in_dc_data_q :0;








//Cache

wire [31:0] lsq_data_odd; //Not needed for I$

wire[31:0] rwnd_data_odd;



   
cache_bank #(.CL_SIZE(CL_SIZE), .IDX_CNT(IDX_CNT), .TAG_SIZE(TAG_SIZE), .OOO_TAG_SIZE(OOO_TAG_SIZE), .BANK_NAME(4)) cache_bank_odd (
    //Systen Input
    .clk(clk),
    .rst(rst),

    //Pipeline Input - done
    .addr_in(dcache_addr_in_odd),
    .data_in(dcache_data_in_odd),
    .size_in(size_in_odd),
    .operation_in(dcache_operation_in_odd),
    .ooo_tag_in(ooo_tag_in_odd),

    //Cache Inputs
    .rwnd_full(rwnd_full_odd),
    .lsq_full(lsq_full),


    //Pipeline Output : 
    .addr_out(addr_out_bank_odd),
    .data_out(data_out_bank_odd),
    .size_out(size_out_bank_odd), //Not needed for I$
    .operation_out(operation_out_bank_odd), 
    .ooo_tag_out(ooo_tag_out_bank_odd), //Not needed for I$
    .hit(hit_bank_odd),

    //Outputs to LSQ
    //MSHR
    .mshr_hit(mshr_hit_bank_odd), 
    .mshr_hit_ptr(mshr_hit_ptr_odd),
    .mshr_wr_ptr(mshr_wr_ptr_odd),
    .mshr_fin_ptr(mshr_fin_ptr_odd),
    .mshr_fin(mshr_fin_odd),
    .mshr_full(mshr_full_bank_odd), 

    //Cache
    .lsq_alloc(lsq_alloc_odd), //Not needed for I$
    .lsq_data(lsq_data_odd), //Not needed for I$

    //Outputs to RWND Q
    .rwnd_alloc(rwnd_alloc_odd),  //Not needed for I$
    .rwnd_data(rwnd_data_odd),//Not needed for I$


    //Requests to DRAM/Directory
    //Evdction Q
    .operation_evic(operation_out_dc_data_q_odd),
    .addr_evic(addr_out_dc_data_q_odd), 
    .alloc_evic(alloc_out_dc_data_q_odd),
    .data_evic(data_out_dc_data_q_odd),
    //Miss Q
    .operation_miss(operation_out_dc_instr_q_odd),
    .addr_miss(addr_out_dc_instr_q_odd),
    .alloc_miss(alloc_out_dc_instr_q_odd),

    .stall_cache(stall_cache_odd), 

    .operation_in_orig(operation_in_orig),
    .addr_in_orig(addr_in_orig),
    .data_in_orig(data_in_orig),
    .ooo_tag_in_orig(ooo_tag_in_orig),
    .ooo_rob_in_orig(ooo_rob_in_orig),
    .size_in_orig(size_in_orig),
    .sext_in_orig(sext_in_orig),

    .operation_out_orig(),
    .addr_out_orig(),
    .data_out_orig(),
    .ooo_tag_out_orig(),
    .ooo_rob_out_orig(),
    .size_out_orig(),
    .sext_out_orig()
);

assign is_flush_out_dc_data_q_odd = 0;
assign  src_out_dc_data_q_odd = 2;
assign dest_out_dc_data_q_odd = operation_out_dc_data_q_odd == WR ? 3 : 2;

assign is_flush_out_dc_instr_q_odd = 0;
assign src_out_dc_instr_q_odd = 2;
assign dest_out_dc_instr_q_odd = operation_out_dc_instr_q_odd == WR || operation_out_dc_instr_q_odd == RD ? 3 : 2;


wire [31:0] doutq_addr_in;
wire  [32-1:0] doutq_data_in;
wire  [2:0] doutq_operation_in;
wire  doutq_is_flush_in;
wire  doutq_valid_in;
wire  [1:0] doutq_src_in;
wire  [1:0] doutq_dest_in;
wire [1:0] doutq_size_in;
wire [OOO_TAG_SIZE-1:0] doutq_ooo_tag_in;
wire [OOO_ROB_SIZE-1:0] doutq_ooo_rob_in;
wire doutq_sext_in;


d_merge #(.CL_SIZE(CL_SIZE), .IDX_CNT(IDX_CNT), .OOO_TAG_SIZE(OOO_TAG_SIZE), .TAG_SIZE(TAG_SIZE)) d_merge (
.clk(clk),
.rst(rst),

.size_in(size_out_orig),
.sext_in(sext_out_orig),

.even_rwnd_data(rwnd_data_even),
.odd_rwnd_data(rwnd_data_odd),

.addr_in_e(addr_out_bank_even),
.data_in_e(data_out_bank_even),
.size_in_e(size_out_bank_even),
.operation_in_e(operation_out_bank_even),
.ooo_tag_in_e(ooo_tag_out_bank_even),

.addr_in_o(addr_out_bank_odd),
.data_in_o(data_out_bank_odd),
.size_in_o(size_out_bank_odd),
.operation_in_o(operation_out_bank_odd),
.ooo_tag_in_o(ooo_tag_out_bank_odd),

.wake_e(),
.wake_o(),
.hit_e(hit_bank_even),
.hit_o(hit_bank_odd),


.addr_out(doutq_addr_in),
.data_out(doutq_data_in),
.size_out(doutq_size_in),
.operation_out(doutq_operation_in),
.ooo_tag_out(doutq_ooo_tag_in),
.valid_out(alloc_doutq),

.rwnd_data() //dont need 
);
doutq #(.Q_LENGTH(8), .DATA_SIZE(32), .OOO_TAG_SIZE(OOO_TAG_SIZE), .OOO_ROB_SIZE(OOO_ROB_SIZE)) dout_q (
    .clk(clk), 
    .rst(rst),

    .addr_in(addr_out_orig),
    .data_in(doutq_data_in),
    .operation_in(doutq_operation_in),
    .is_flush_in(1'b0),
    .tag_in(ooo_tag_out_orig),
    .rob_line_in(ooo_rob_out_orig),
    .alloc(alloc_doutq),

    //From ROB
    .dealloc(rob_valid && (rob_ret_tag_in == tag_out)),
    .resteer(rob_resteer),

    //TO CACHE
    .full(),

    //TO ROB
    .addr_out(addr_out),
    .data_out(data_out),
    .is_st_out(is_st_out),
    .is_flush_out(is_flush_out),
    .tag_out(tag_out),
    .rob_line_out(rob_line_out),
    .valid_out(valid_out)
);
endmodule