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

dinpq #(.Q_LENGTH(8), .DATA_SIZE(32), .OOO_TAG_SIZE(OOO_TAG_SIZE), .OOO_ROB_SIZE(OOO_ROB_SIZE), .CL_SIZE(CL_SIZE)) (

clk,
rst,
resteer,

//FROM RSV
alloc, //Data from RAS is valid or not

addr_in,
data_in,
size_in, //
is_st_in, //Say whether input is ST or LD
ooo_tag_in, //tag from register renaming
ooo_rob_in,
sext_in,

dealloc,

valid,

addr_out,
data_out,
size_out, //
operation_out, //Say whether input is ST or LD
ooo_tag_out, //tag from register renaming
ooo_rob_out,
src_out, 
dest_out,
sext_out,

full()

);

lsq #(.Q_LENGTH(8), .OOO_TAG_BITS(OOO_TAG_SIZE), .OOO_ROB_BITS(OOO_ROB_SIZE)) (
    clk,
    rst,

    //From cache
    rd,
    wr,
    operation_in, 
    addr_in,
    data_in,
    ooo_tag_in,
    ooo_rob_in,
    size_in,
    
    //From MSHR  x
    mshr_wr_idx, //next location to be allocated into mshr
    mshr_fin,
    mshr_fin_idx ,// location being deallocated from mshr

    //outputs 
    ooo_tag_out,
    data_out,
    addr_out,
    operation_out,
    size_out,
    valid_out,
    lsq_full
);

rewind #(.OOO_TAG_SIZE(OOO_TAG_SIZE)) (
    //Global
    clk, 
    rst,

    //From ROB
    rob_ret_tag_in,
    rob_valid,
    rob_resteer,

    //From Cache
    addr_in,
    data_repl,
    operation,
    cache_ooo_tag_in,
    size,

    //To Cache
    valid_rewind,
    addr_out,
    data_out,
    operation_out,
    cache_ooo_tag_out,
    size_out,
    rewind_full
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
queue_arbitrator #(.CL_SIZE(CL_SIZE), .Q_WIDTH(3)) queue_arb_even(
    .addr_in({
        dcache_addr_in_dc_data_q_even,
        dcache_addr_in_dc_instr_q_even,
        addr_even
    }),
    .data_in({
        dcache_data_in_dc_data_q_even,
        256'd0
    }),
    .operation_in({
        dcache_operation_in_dc_data_q_even,
        dcache_operation_in_dc_instr_q_even,
        3'b001
    }), 
    .valid_in({
        dcache_valid_in_dc_data_q_even,
        dcache_valid_in_dc_instr_q_even,
        1'b1
    }),
    .src_in({
        dcache_src_in_dc_data_q_even,
        dcache_src_in_dc_instr_q_even,
        2'b01
    }),
    .dest_in({
        dcache_dest_in_dc_data_q_even,
        dcache_dest_in_dc_instr_q_even,
        2'b01
    }),
    .is_flush_in({
        dcache_is_flush_in_dc_data_q_even,
        dcache_is_flush_in_dc_instr_q_even,
        1'b0
    }),
    
    .stall_in(stall_cache_even),

    .addr_out(      dcache_addr_in_even),
    .operation_out( dcache_operation_in_even), 
    .data_out(      dcache_data_in_even),
    .valid_out(     dcache_valid_in_even),
    .src_out(       dcache_src_in_even),
    .dest_out(      dcache_dest_in_even),
    .is_flush_out(  dcache_is_flush_in_even),

    .dealloc(dealloc_even)
);

cache_bank #(.CL_SIZE(CL_SIZE), .IDX_CNT(IDX_CNT), .TAG_SIZE(TAG_SIZE), .OOO_TAG_SIZE(OOO_TAG_SIZE), .BANK_NAME(1)) cache_bank_even (
    //Systen Input
    .clk(clk),
    .rst(rst),

    //Pipeline Input - done
    .addr_in(dcache_addr_in_even),
    .data_in(dcache_data_in_even),
    .size_in(2'b0),
    .operation_in(dcache_operation_in_even),
    .ooo_tag_in({OOO_TAG_SIZE{1'b0}}),

    //Cache Inputs
    .rwnd_full(1'b0),
    .lsq_full(1'b0),


    //Pipeline Output : 
    .addr_out(addr_out_even),
    .data_out(cl_even),
    .size_out(), //Not needed for I$
    .operation_out(operation_out_even), 
    .ooo_tag_out(), //Not needed for I$
    .hit(hit_even),

    //Outputs to LSQ
    //MSHR
    .mshr_hit(), //Not needed for I$
    .mshr_hit_ptr(),//Not needed for I$
    .mshr_wr_ptr(),//Not needed for I$
    .mshr_fin_ptr(),//Not needed for I$
    .mshr_fin(),//Not needed for I$
    .mshr_full(), //Not needed for I$

    //Cache
    .lsq_alloc(), //Not needed for I$
    .lsq_data(), //Not needed for I$

    //Outputs to RWND Q
    .rwnd_alloc(),  //Not needed for I$
    .rwnd_data(),//Not needed for I$


    //Requests to DRAM/Directory
    //Evdction Q
    .operation_evdc(operation_out_dc_data_q_even),
    .addr_evdc(addr_out_dc_data_q_even), 
    .alloc_evdc(alloc_out_dc_data_q_even),
    .data_evdc(data_out_dc_data_q_even),
    //Miss Q
    .operation_miss(operation_out_dc_instr_q_even),
    .addr_miss(addr_out_dc_instr_q_even),
    .alloc_miss(alloc_out_dc_instr_q_even),

    .stall_cache(stall_cache_even)
);


doutq #(parameter Q_LENGTH = 8, DATA_SIZE = 32, OOO_TAG_SIZE = 10, OOO_ROB_SIZE = 10) (
    input clk, rst,

    input[31:0] addr_in,
    input [DATA_SIZE-1:0] data_in,
    input [2:0] operation_in,
    input is_flush_in,
    input [OOO_TAG_SIZE-1:0] tag_in,
    input [OOO_ROB_SIZE-1:0] rob_line_in,
    input alloc,

    //From ROB
    input dealloc,
    input resteer,

    //TO CACHE
    output full,

    //TO ROB
    output[31:0] addr_out,
    output [DATA_SIZE-1:0] data_out,
    output is_st_out,
    output is_flush_out,
    output [OOO_TAG_SIZE-1:0] tag_out,
    output [OOO_ROB_SIZE-1:0] rob_line_out,
    output valid_out
);
endmodule