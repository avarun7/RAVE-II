module dcache_core #(parameter CL_SIZE = 128, IDX_CNT = 512, OOO_TAG_SIZE = 10, TAG_SIZE = 18, OOO_ROB_SIZE = 10, BANK_NAME = 2) (
    input[31:0] addr_in_dc_data_q,
    input [CL_SIZE-1:0] data_in_dc_data_q,
    input [2:0] operation_in_dc_data_q,
    input is_flush_in_dc_data_q,
    input alloc_in_dc_data_q,
    input [1:0] src_in_dc_data_q,
    input [1:0] dest_in_dc_data_q,

    output full_out_dc_data_q,
    
    //I$_INSTR_Q_in
    input[31:0] addr_in_dc_instr_q,
    input [2:0] operation_in_dc_instr_q,
    input is_flush_in_dc_instr_q,
    input alloc_in_dc_instr_q,
    input [1:0] src_in_dc_instr_q,
    input [1:0] dest_in_dc_instr_q,

    output full_out_dc_instr_q,

    //RWND
    input[31:0] addr_in_dc_rwnd_q,
    input [CL_SIZE-1:0] data_in_dc_rwnd_q,
    input [2:0] operation_in_dc_rwnd_q,
    input is_flush_in_dc_rwnd_q,
    input valid_in_dc_rwnd_q,
    input [1:0] src_in_dc_rwnd_q,
    input [1:0] dest_in_dc_rwnd_q,
    input [1:0] size_in_dc_rwnd_q,
    input [OOO_TAG_SIZE-1:0] ooo_tag_rwnd_q,
    input [OOO_ROB_SIZE-1:0] ooo_rob_rwnd_q,


    input  rwnd_full,

    //LDST
    input[31:0] addr_in_dc_ldst_q,
    input [CL_SIZE-1:0] data_in_dc_ldst_q,
    input [2:0] operation_in_dc_ldst_q,
    input is_flush_in_dc_ldst_q,
    input valid_in_dc_ldst_q,
    input [1:0] src_in_dc_ldst_q,
    input [1:0] dest_in_dc_ldst_q,
    input [1:0] size_in_dc_ldst_q,
    input [OOO_TAG_SIZE-1:0] ooo_tag_ldst_q,
    input [OOO_ROB_SIZE-1:0] ooo_rob_ldst_q,

    input ldst_full,
  
    //Pipe
    input[31:0] addr_in_dc_pipe_q,
    input [CL_SIZE-1:0] data_in_dc_pipe_q,
    input [2:0] operation_in_dc_pipe_q,
    input is_flush_in_dc_pipe_q,
    input valid_in_dc_pipe_q,
    input [1:0] src_in_dc_pipe_q,
    input [1:0] dest_in_dc_pipe_q,
    input [1:0] size_in_dc_pipe_q,
    input [OOO_TAG_SIZE-1:0] ooo_tag_pipe_q,
    input [OOO_ROB_SIZE-1:0] ooo_rob_pipe_q,
   
    //OUTPUTS TO MEM
    //I$_DATA_Q_in
    output[31:0] addr_out_dc_data_q,
    output [CL_SIZE-1:0] data_out_dc_data_q,
    output [2:0] operation_out_dc_data_q,
    output is_flush_out_dc_data_q,
    output alloc_out_dc_data_q,
    output [1:0] src_out_dc_data_q,
    output [1:0] dest_out_dc_data_q,

    input full_in_dc_data_q,
    
    //I$_INSTR_Q_in
    output[31:0] addr_out_dc_instr_q,
    output [2:0] operation_out_dc_instr_q,
    output is_flush_out_dc_instr_q,
    output alloc_out_dc_instr_q,
    output [1:0] src_out_dc_instr_q,
    output [1:0] dest_out_dc_instr_q,

    input full_in_dc_instr_q,

    //Pipeline Output : 
    output [31:0] addr_out,
    output [CL_SIZE-1:0] data_out,
    output [1:0] size_out,
    output [2:0] operation_out,
    output [OOO_TAG_SIZE-1:0] ooo_tag_out,
    output hit,
    
    //LSQ output
    output mshr_hit, //
    output [2:0] mshr_hit_ptr,
    output [2:0]  mshr_wr_ptr, 
    output [2:0] mshr_fin_ptr, 
    output mshr_fin,//
    output mshr_full, //
    output lsq_alloc,
    output lsq_data, 

    //Outputs to RWND Q
    output rwnd_alloc, 
    output [31:0] rwnd_data,

    output stall_cache
);

wire [31:0] dcache_addr_in;
wire  [2:0] dcache_operation_in;
wire [CL_SIZE-1:0] dcache_data_in;
wire dcache_valid_in;
wire [1:0]dcache_src_in;
wire [1:0] dcache_dest_in;
wire dcache_is_flush_in;

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
wire [31:0] dcache_addr_in_dc_data_q;
wire  [CL_SIZE-1:0] dcache_data_in_dc_data_q;
wire  [2:0] dcache_operation_in_dc_data_q;
wire  dcache_is_flush_in_dc_data_q;
wire  dcache_valid_in_dc_data_q;
wire  [1:0] dcache_src_in_dc_data_q;
wire  [1:0] dcache_dest_in_dc_data_q;
 
     //I$_INSTR_Q_in
wire [31:0] dcache_addr_in_dc_instr_q;
wire  [2:0] dcache_operation_in_dc_instr_q;
wire  dcache_is_flush_in_dc_instr_q;
wire  dcache_valid_in_dc_instr_q;
wire  [1:0] dcache_src_in_dc_instr_q;
wire  [1:0] dcache_dest_in_dc_instr_q;
wire [4:0] dealloc;
data_q #(.Q_LENGTH(8), .CL_SIZE(CL_SIZE)) dcache_data_q(
    //System     
    .clk(clk),
    .rst(rst),

    //From Sender
    .addr_in(addr_in_dc_data_q),
    .data_in(data_in_dc_data_q),
    .operation_in(operation_in_dc_data_q),
    .is_flush(is_flush_in_dc_data_q),
    .alloc(alloc_in_dc_data_q),
    .src(src_in_dc_data_q),
    .dest(dest_in_dc_data_q),
    //From reciever
    .dealloc(dealloc[4]),

    //output sender
    .full(full_out_dc_data_q),

    //output reciever
    .addr_out(dcache_addr_in_dc_data_q),
    .data_out(dcache_data_in_dc_data_q),
    .operation_out(dcache_operation_in_dc_data_q),
    .valid(dcache_valid_in_dc_data_q),
    .src_out(dcache_src_in_dc_data_q),
    .dest_out(dcache_dest_in_dc_data_q),
    .is_flush_out(dcache_is_flush_in_dc_data_q)
);

instr_q  #(.Q_LENGTH(8), .CL_SIZE(CL_SIZE)) dcache_instr_q(
    //System     
    .clk(clk),
    .rst(rst),

    //From Sender
    .addr_in(addr_in_dc_instr_q),
    .operation_in(operation_in_dc_instr_q),
    .is_flush(is_flush_in_dc_instr_q),
    .alloc(alloc_in_dc_instr_q),
    .src(src_in_dc_instr_q),
    .dest(dest_in_dc_instr_q),

    //From reciever
    .dealloc(dealloc[3]),

    //output sender
    .full(full_out_dc_instr_q),

    //output reciever
    .addr_out(dcache_addr_in_dc_instr_q),
    .operation_out(dcache_operation_in_dc_instr_q),
    .valid(dcache_valid_in_dc_instr_q),
    .src_out(dcache_src_in_dc_instr_q),
    .dest_out(dcache_dest_in_dc_instr_q),
    .is_flush_out(dcache_is_flush_in_dc_instr_q)
);

queue_arbitrator #(.CL_SIZE(CL_SIZE), .Q_WIDTH(5)) queue_arb(
    .addr_in({
        dcache_addr_in_dc_data_q,
        dcache_addr_in_dc_instr_q,
        addr_in_dc_rwnd_q,
        addr_in_dc_ldst_q,
        addr_in_dc_pipe_q
    }),
    .data_in({
        dcache_data_in_dc_data_q,
        128'd0,
        data_in_dc_rwnd_q,
        data_in_dc_ldst_q,
        data_in_dc_pipe_q
    }),
    .operation_in({
        dcache_operation_in_dc_data_q,
        dcache_operation_in_dc_instr_q,
        operation_in_dc_rwnd_q,
        operation_in_dc_ldst_q,
        operation_in_dc_pipe_q
    }), 
    .valid_in({
        dcache_valid_in_dc_data_q,
        dcache_valid_in_dc_instr_q,
        valid_in_dc_rwnd_q,
        valid_in_dc_ldst_q,
        valid_in_dc_pipe_q
    }),
    .src_in({
        dcache_src_in_dc_data_q,
        dcache_src_in_dc_instr_q,
        2'b00,
        2'b00,
        2'b00
    }),
    .dest_in({
        dcache_dest_in_dc_data_q,
        dcache_dest_in_dc_instr_q,
        2'b00,
        2'b00,
        2'b00

    }),
    .is_flush_in({
        dcache_is_flush_in_dc_data_q,
        dcache_is_flush_in_dc_instr_q,
        1'b0,
        1'b0,
        1'b0
    }),
    
    .stall_in(stall_cache),

    .addr_out(      dcache_addr_in),
    .operation_out( dcache_operation_in), 
    .data_out(      dcache_data_in),
    .valid_out(     dcache_valid_in),
    .src_out(       dcache_src_in),
    .dest_out(      dcache_dest_in),
    .is_flush_out(  dcache_is_flush_in),

    .dealloc(dealloc)
);
wire[1:0] size_in; 
wire [OOO_TAG_SIZE-1:0] ooo_tag_in;
wire  [OOO_ROB_SIZE-1:0] ooo_rob_in;
assign size_in = dealloc[2] ? size_in_dc_rwnd_q : dealloc [1] ? size_in_dc_ldst_q : size_in_dc_pipe_q;
assign ooo_rob_in = dealloc[2] ? ooo_rob_rwnd_q: dealloc [1] ? ooo_rob_ldst_q : ooo_rob_pipe_q;
assign ooo_tag_in = dealloc[2] ? ooo_tag_rwnd_q: dealloc [1] ? ooo_tag_ldst_q : ooo_tag_pipe_q;

cache_bank #(.CL_SIZE(CL_SIZE), .IDX_CNT(IDX_CNT), .TAG_SIZE(TAG_SIZE), .OOO_TAG_SIZE(OOO_TAG_SIZE), .BANK_NAME(2)) cache_bank (
    //Systen Input
    .clk(clk),
    .rst(rst),

    //Pipeline Input - done
    .addr_in(dcache_addr_in),
    .data_in(dcache_data_in),
    .size_in(size_in),
    .operation_in(dcache_operation_in),
    .ooo_tag_in(ooo_tag_in),
    //TODO: ADD OOO_ROB_IN/OUT
    //Cache Inputs
    .rwnd_full(rwnd_full),
    .lsq_full(ldst_full),


    //Pipeline Output : 
    .addr_out(addr_out),
    .data_out(cl),
    .size_out(size_out), //Not needed for I$
    .operation_out(operation_out), 
    .ooo_tag_out(ooo_tag_out), //Not needed for I$
    .hit(hit),

    //Outputs to LSQ
    //MSHR
    .mshr_hit(mshr_hit), //Not needed for I$
    .mshr_hit_ptr(mshr_hit_ptr),//Not needed for I$
    .mshr_wr_ptr(mshr_wr_ptr),//Not needed for I$
    .mshr_fin_ptr(mshr_fin_ptr),//Not needed for I$
    .mshr_fin(mshr_fin),//Not needed for I$
    .mshr_full(mshr_full), //Not needed for I$

    //Cache
    .lsq_alloc(lsq_alloc), //Not needed for I$
    .lsq_data(lsq_data), //Not needed for I$

    //Outputs to RWND Q
    .rwnd_alloc(rwnd_alloc),  //Not needed for I$
    .rwnd_data(rwnd_data),//Not needed for I$


    //Requests to DRAM/Directory
    //Evdction Q
    .operation_evdc(operation_out_dc_data_q),
    .addr_evdc(addr_out_dc_data_q), 
    .alloc_evdc(alloc_out_dc_data_q),
    .data_evdc(data_out_dc_data_q),
    //Miss Q
    .operation_miss(operation_out_dc_instr_q),
    .addr_miss(addr_out_dc_instr_q),
    .alloc_miss(alloc_out_dc_instr_q),

    .stall_cache(stall_cache)
);
assign is_flush_out_dc_data_q = 0;
assign  src_out_dc_data_q = 0;
assign dest_out_dc_data_q = operation_out_dc_data_q == WR ? 3 : 2;

assign is_flush_out_dc_instr_q = 0;
assign src_out_dc_instr_q = 0;
assign dest_out_dc_instr_q = operation_out_dc_instr_q == WR || operation_out_dc_instr_q == RD ? 3 : 2;
wire[2:0] dealloc_odd;



endmodule