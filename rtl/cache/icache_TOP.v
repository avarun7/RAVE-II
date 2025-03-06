module icache_TOP #(parameter CL_SIZE = 128, IDX_CNT = 512, OOO_TAG_SIZE = 10, TAG_SIZE = 18) (
    input clk,
    input rst,

    //Pipeline facing I/O
    input [31:0] addr_even, //Address for even bank of I$
    input [31:0] addr_odd, //Address for odd bank of I$

    output hit_even, //Return whether current cache line access was a hit
    output hit_odd,

    output [CL_SIZE-1:0] cl_even, //Data of the even I$ bank
    output  [CL_SIZE-1:0] cl_odd,

    output [31:0] addr_out_even, //Since I$ access is two cycles, tells you what address the current data corresponds to
    output [31:0] addr_out_odd,

    output is_write_even, //Tells whether the data being processed is a write (probably want to ignore results if it is)
    output is_write_odd,

    output stall, //Signal to say stop feeding data to cache. I don't think its needed since this is blocking
    
    //TLB
    output exception,

    //TODO: All other I/O memory facing and I will handle
    //Shouldn't affect people working on integrating the pipeline
    
    // INPUTS FROM MEM
    //I$_DATA_Q_in
    input[31:0] addr_in_ic_data_q_even,
    input [CL_SIZE-1:0] data_in_ic_data_q_even,
    input [2:0] operation_in_ic_data_q_even,
    input is_flush_in_ic_data_q_even,
    input alloc_in_ic_data_q_even,
    input [1:0] src_in_ic_data_q_even,
    input [1:0] dest_in_ic_data_q_even,

    output full_out_ic_data_q_even,
    
    //I$_INSTR_Q_in
    input[31:0] addr_in_ic_instr_q_even,
    input [2:0] operation_in_ic_instr_q_even,
    input is_flush_in_ic_instr_q_even,
    input alloc_in_ic_instr_q_even,
    input [1:0] src_in_ic_instr_q_even,
    input [1:0] dest_in_ic_instr_q_even,

    output full_out_ic_instr_q_even,

        //I$_DATA_Q_in
    input[31:0] addr_in_ic_data_q_odd,
    input [CL_SIZE-1:0] data_in_ic_data_q_odd,
    input [2:0] operation_in_ic_data_q_odd,
    input is_flush_in_ic_data_q_odd,
    input alloc_in_ic_data_q_odd,
    input [1:0] src_in_ic_data_q_odd,
    input [1:0] dest_in_ic_data_q_odd,

    output full_out_ic_data_q_odd,
    
    //I$_INSTR_Q_in
    input[31:0] addr_in_ic_instr_q_odd,
    input [2:0] operation_in_ic_instr_q_odd,
    input is_flush_in_ic_instr_q_odd,
    input alloc_in_ic_instr_q_odd,
    input [1:0] src_in_ic_instr_q_odd,
    input [1:0] dest_in_ic_instr_q_odd,

    output full_out_ic_instr_q_odd,

    //OUTPUTS TO MEM

    //I$_DATA_Q_in
    output[31:0] addr_out_ic_data_q_even,
    output [CL_SIZE-1:0] data_out_ic_data_q_even,
    output [2:0] operation_out_ic_data_q_even,
    output is_flush_out_ic_data_q_even,
    output alloc_out_ic_data_q_even,
    output [1:0] src_out_ic_data_q_even,
    output [1:0] dest_out_ic_data_q_even,

    input full_in_ic_data_q_even,
    
    //I$_INSTR_Q_in
    output[31:0] addr_out_ic_instr_q_even,
    output [2:0] operation_out_ic_instr_q_even,
    output is_flush_out_ic_instr_q_even,
    output alloc_out_ic_instr_q_even,
    output [1:0] src_out_ic_instr_q_even,
    output [1:0] dest_out_ic_instr_q_even,

    input full_in_ic_instr_q_even,

        //I$_DATA_Q_in
    output[31:0] addr_out_ic_data_q_odd,
    output [CL_SIZE-1:0] data_out_ic_data_q_odd,
    output [2:0] operation_out_ic_data_q_odd,
    output is_flush_out_ic_data_q_odd,
    output alloc_out_ic_data_q_odd,
    output [1:0] src_out_ic_data_q_odd,
    output [1:0] dest_out_ic_data_q_odd,

    input full_in_ic_data_q_odd,
    
    //I$_INSTR_Q_in
    output[31:0] addr_out_ic_instr_q_odd,
    output [2:0] operation_out_ic_instr_q_odd,
    output is_flush_out_ic_instr_q_odd,
    output alloc_out_ic_instr_q_odd,
    output [1:0] src_out_ic_instr_q_odd,
    output [1:0] dest_out_ic_instr_q_odd,

    input full_in_ic_instr_q_odd
);
assign stall = stall_cache_even || stall_cache_odd;
//Opeartion Names
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
     //I$_DATA_Q_in
wire [31:0] icache_addr_in_ic_data_q_even;
wire  [CL_SIZE-1:0] icache_data_in_ic_data_q_even;
wire  [2:0] icache_operation_in_ic_data_q_even;
wire  icache_is_flush_in_ic_data_q_even;
wire  icache_valid_in_ic_data_q_even;
wire  [1:0] icache_src_in_ic_data_q_even;
wire  [1:0] icache_dest_in_ic_data_q_even;
 
     //I$_INSTR_Q_in
wire [31:0] icache_addr_in_ic_instr_q_even;
wire  [2:0] icache_operation_in_ic_instr_q_even;
wire  icache_is_flush_in_ic_instr_q_even;
wire  icache_valid_in_ic_instr_q_even;
wire  [1:0] icache_src_in_ic_instr_q_even;
wire  [1:0] icache_dest_in_ic_instr_q_even;

     //I$_DATA_Q_in
wire [31:0] icache_addr_in_ic_data_q_odd;
wire  [CL_SIZE-1:0] icache_data_in_ic_data_q_odd;
wire  [2:0] icache_operation_in_ic_data_q_odd;
wire  icache_is_flush_in_ic_data_q_odd;
wire  icache_valid_in_ic_data_q_odd;
wire  [1:0] icache_src_in_ic_data_q_odd;
wire  [1:0] icache_dest_in_ic_data_q_odd;
 
     //I$_INSTR_Q_in
wire [31:0] icache_addr_in_ic_instr_q_odd;
wire  [2:0] icache_operation_in_ic_instr_q_odd;
wire  icache_is_flush_in_ic_instr_q_odd;
wire  icache_valid_in_ic_instr_q_odd;
wire  [1:0] icache_src_in_ic_instr_q_odd;
wire  [1:0] icache_dest_in_ic_instr_q_odd;

wire [2:0]dealloc_even;
data_q #(.Q_LENGTH(8), .CL_SIZE(CL_SIZE)) icache_data_q_even(
    //System     
    .clk(clk),
    .rst(rst),

    //From Sender
    .addr_in(addr_in_ic_data_q_even),
    .data_in(data_in_ic_data_q_even),
    .operation_in(operation_in_ic_data_q_even),
    .is_flush(is_flush_in_ic_data_q_even),
    .alloc(alloc_in_ic_data_q_even),
    .src(src_in_ic_data_q_even),
    .dest(dest_in_ic_data_q_even),
    //From reciever
    .dealloc(dealloc_even[2]),

    //output sender
    .full(full_out_ic_data_q_even),

    //output reciever
    .addr_out(icache_addr_in_ic_data_q_even),
    .data_out(icache_data_in_ic_data_q_even),
    .operation_out(icache_operation_in_ic_data_q_even),
    .valid(icache_valid_in_ic_data_q_even),
    .src_out(icache_src_in_ic_data_q_even),
    .dest_out(icache_dest_in_ic_data_q_even),
    .is_flush_out(icache_is_flush_in_ic_data_q_even)
);

instr_q  #(.Q_LENGTH(8), .CL_SIZE(CL_SIZE)) icache_instr_q_even(
    //System     
    .clk(clk),
    .rst(rst),

    //From Sender
    .addr_in(addr_in_ic_instr_q_even),
    .operation_in(operation_in_ic_instr_q_even),
    .is_flush(is_flush_in_ic_instr_q_even),
    .alloc(alloc_in_ic_instr_q_even),
    .src(src_in_ic_instr_q_even),
    .dest(dest_in_ic_instr_q_even),

    //From reciever
    .dealloc(dealloc_even[1]),

    //output sender
    .full(full_out_ic_instr_q_even),

    //output reciever
    .addr_out(icache_addr_in_ic_instr_q_even),
    .operation_out(icache_operation_in_ic_instr_q_even),
    .valid(icache_valid_in_ic_instr_q_even),
    .src_out(icache_src_in_ic_instr_q_even),
    .dest_out(icache_dest_in_ic_instr_q_even),
    .is_flush_out(icache_is_flush_in_ic_instr_q_even)
);
wire [31:0] icache_addr_in_even;
wire  [2:0] icache_operation_in_even;
wire [CL_SIZE-1:0] icache_data_in_even;
wire icache_valid_in_even;
wire [1:0]icache_src_in_even;
wire [1:0] icache_dest_in_even;
wire icache_is_flush_in_even;

wire [31:0] icache_addr_in_odd;
wire  [2:0] icache_operation_in_odd;
wire [CL_SIZE-1:0] icache_data_in_odd;
wire icache_valid_in_odd;
wire [1:0]icache_src_in_odd;
wire [1:0] icache_dest_in_odd;
wire icache_is_flush_in_odd;
queue_arbitrator #(.CL_SIZE(CL_SIZE), .Q_WIDTH(3)) queue_arb_even(
    .addr_in({
        icache_addr_in_ic_data_q_even,
        icache_addr_in_ic_instr_q_even,
        addr_even
    }),
    .data_in({
        icache_data_in_ic_data_q_even,
        256'd0
    }),
    .operation_in({
        icache_operation_in_ic_data_q_even,
        icache_operation_in_ic_instr_q_even,
        3'b001
    }), 
    .valid_in({
        icache_valid_in_ic_data_q_even,
        icache_valid_in_ic_instr_q_even,
        1'b1
    }),
    .src_in({
        icache_src_in_ic_data_q_even,
        icache_src_in_ic_instr_q_even,
        2'b01
    }),
    .dest_in({
        icache_dest_in_ic_data_q_even,
        icache_dest_in_ic_instr_q_even,
        2'b01
    }),
    .is_flush_in({
        icache_is_flush_in_ic_data_q_even,
        icache_is_flush_in_ic_instr_q_even,
        1'b0
    }),
    
    .stall_in(stall_cache_even),

    .addr_out(      icache_addr_in_even),
    .operation_out( icache_operation_in_even), 
    .data_out(      icache_data_in_even),
    .valid_out(     icache_valid_in_even),
    .src_out(       icache_src_in_even),
    .dest_out(      icache_dest_in_even),
    .is_flush_out(  icache_is_flush_in_even),

    .dealloc(dealloc_even)
);
wire[2:0] operation_out_even;
assign is_write_even = !(operation_out_even == LD);
cache_bank #(.CL_SIZE(CL_SIZE), .IDX_CNT(IDX_CNT), .TAG_SIZE(TAG_SIZE), .OOO_TAG_SIZE(OOO_TAG_SIZE), .BANK_NAME(1)) cache_bank_even (
    //Systen Input
    .clk(clk),
    .rst(rst),

    //Pipeline Input - done
    .addr_in(icache_addr_in_even),
    .data_in(icache_data_in_even),
    .size_in(2'b0),
    .operation_in(icache_operation_in_even),
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
    //Eviction Q
    .operation_evic(operation_out_ic_data_q_even),
    .addr_evic(addr_out_ic_data_q_even), 
    .alloc_evic(alloc_out_ic_data_q_even),
    .data_evic(data_out_ic_data_q_even),
    //Miss Q
    .operation_miss(operation_out_ic_instr_q_even),
    .addr_miss(addr_out_ic_instr_q_even),
    .alloc_miss(alloc_out_ic_instr_q_even),

    .stall_cache(stall_cache_even)
);
assign is_flush_out_ic_data_q_even = 0;
assign  src_out_ic_data_q_even = 1;
assign dest_out_ic_data_q_even = operation_out_ic_data_q_even == WR ? 3 : 2;

assign is_flush_out_ic_instr_q_even = 0;
assign src_out_ic_instr_q_even = 1;
assign dest_out_ic_instr_q_even = operation_out_ic_instr_q_even == WR || operation_out_ic_instr_q_even == RD ? 3 : 2;
wire[2:0] dealloc_odd;
data_q #(.Q_LENGTH(8), .CL_SIZE(CL_SIZE)) icache_data_q_odd(
    //System     
    .clk(clk),
    .rst(rst),

    //From Sender
    .addr_in(addr_in_ic_data_q_odd),
    .data_in(data_in_ic_data_q_odd),
    .operation_in(operation_in_ic_data_q_odd),
    .is_flush(is_flush_in_ic_data_q_odd),
    .alloc(alloc_in_ic_data_q_odd),
    .src(src_in_ic_data_q_odd),
    .dest(dest_in_ic_data_q_odd),
    //From reciever
    .dealloc(dealloc_odd[2]),

    //output sender
    .full(full_out_ic_data_q_odd),

    //output reciever
    .addr_out(icache_addr_in_ic_data_q_odd),
    .data_out(icache_data_in_ic_data_q_odd),
    .operation_out(icache_operation_in_ic_data_q_odd),
    .valid(icache_valid_in_ic_data_q_odd),
    .src_out(icache_src_in_ic_data_q_odd),
    .dest_out(icache_dest_in_ic_data_q_odd),
    .is_flush_out(icache_is_flush_in_ic_data_q_odd)
);

instr_q  #(.Q_LENGTH(8), .CL_SIZE(CL_SIZE)) icache_instr_q_odd(
    //System     
    .clk(clk),
    .rst(rst),

    //From Sender
    .addr_in(addr_in_ic_instr_q_odd),
    .operation_in(operation_in_ic_instr_q_odd),
    .is_flush(is_flush_in_ic_instr_q_odd),
    .alloc(alloc_in_ic_instr_q_odd),
    .src(src_in_ic_instr_q_odd),
    .dest(dest_in_ic_instr_q_odd),

    //From reciever
    .dealloc(dealloc_odd[1]),

    //output sender
    .full(full_out_ic_instr_q_odd),

    //output reciever
    .addr_out(icache_addr_in_ic_instr_q_odd),
    .operation_out(icache_operation_in_ic_instr_q_odd),
    .valid(icache_valid_in_ic_instr_q_odd),
    .src_out(icache_src_in_ic_instr_q_odd),
    .dest_out(icache_dest_in_ic_instr_q_odd),
    .is_flush_out(icache_is_flush_in_ic_instr_q_odd)
);

queue_arbitrator #(.CL_SIZE(CL_SIZE), .Q_WIDTH(3)) queue_arb_odd(
    .addr_in({
        icache_addr_in_ic_data_q_odd,
        icache_addr_in_ic_instr_q_odd,
        addr_odd
    }),
    .data_in({
        icache_data_in_ic_data_q_odd,
        128'd0,
        128'd0
    }),
    .operation_in({
        icache_operation_in_ic_data_q_odd,
        icache_operation_in_ic_instr_q_odd,
        3'b001
    }), 
    .valid_in({
        icache_valid_in_ic_data_q_odd,
        icache_valid_in_ic_instr_q_odd,
        1'b1
    }),
    .src_in({
        icache_src_in_ic_data_q_odd,
        icache_src_in_ic_instr_q_odd,
        2'b01
    }),
    .dest_in({
        icache_dest_in_ic_data_q_odd,
        icache_dest_in_ic_instr_q_odd,
        2'b01
    }),
    .is_flush_in({
        icache_is_flush_in_ic_data_q_odd,
        icache_is_flush_in_ic_instr_q_odd,
        1'b0
    }),
    
    .stall_in(stall_cache_odd),

    .addr_out(icache_addr_in_odd),
    .operation_out(icache_operation_in_odd), 
    .data_out(icache_data_in_odd),
    .valid_out(icache_valid_in_odd),
    .src_out(icache_src_in_odd),
    .dest_out(icache_dest_in_odd),
    .is_flush_out(icache_is_flush_in_odd),

    .dealloc(dealloc_odd)
);
wire[2:0] operation_out_odd;
assign is_write_odd = !(operation_out_odd == LD);
cache_bank #(.CL_SIZE(CL_SIZE), .IDX_CNT(IDX_CNT), .TAG_SIZE(TAG_SIZE), .OOO_TAG_SIZE(OOO_TAG_SIZE), .BANK_NAME(2)) cache_bank_odd (
    //Systen Input
    .clk(clk),
    .rst(rst),

    //Pipeline Input - done
    .addr_in(icache_addr_in_odd),
    .data_in(icache_data_in_odd),
    .size_in(2'b0),
    .operation_in(icache_operation_in_odd),
    .ooo_tag_in({OOO_TAG_SIZE{1'b0}}),

    //Cache Inputs
    .rwnd_full(1'b0),
    .lsq_full(1'b0),


    //Pipeline Output : 
    .addr_out(addr_out_odd),
    .data_out(cl_odd),
    .size_out(), //Not needed for I$
    .operation_out(operation_out_odd), 
    .ooo_tag_out(), //Not needed for I$
    .hit(hit_odd),

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
    //Eviction Q
    .operation_evic(operation_out_ic_data_q_odd),
    .addr_evic(addr_out_ic_data_q_odd), 
    .alloc_evic(alloc_out_ic_data_q_odd),
    .data_evic(data_out_ic_data_q_odd),
    //Miss Q
    .operation_miss(operation_out_ic_instr_q_odd),
    .addr_miss(addr_out_ic_instr_q_odd),
    .alloc_miss(alloc_out_ic_instr_q_odd),

    .stall_cache(stall_cache_odd)
);
assign is_flush_out_ic_data_q_odd = 0;
assign  src_out_ic_data_q_odd = 1;
assign dest_out_ic_data_q_odd = operation_out_ic_data_q_odd == WR ? 3 : 2;

assign is_flush_out_ic_instr_q_odd = 0;
assign src_out_ic_instr_q_odd = 1;
assign dest_out_ic_instr_q_odd = operation_out_ic_instr_q_odd == WR || operation_out_ic_instr_q_odd == RD ? 3 : 2;





endmodule 