module directory_top #(parameter CL_SIZE = 128, TAG_SIZE = 18, IDX_CNT = 512, DATA_SIZE = 4) (
    input clk,
    input rst, 

    //EVEN SIDE
    //MEM_DATA_Q_in
    input[31:0] addr_in_mem_data_q_even,
    input [CL_SIZE-1:0] data_in_mem_data_q_even,
    input [2:0] operation_in_mem_data_q_even,
    input is_flush_in_mem_data_q_even,
    input alloc_in_mem_data_q_even,
    input [1:0] src_in_mem_data_q_even,
    input [1:0] dest_in_mem_data_q_even,

    output full_out_mem_data_q_even,
    
    //MEM_INSTR_Q_in
    input[31:0] addr_in_mem_instr_q_even,
    input [2:0] operation_in_mem_instr_q_even,
    input is_flush_in_mem_instr_q_even,
    input alloc_in_mem_instr_q_even,
    input [1:0] src_in_mem_instr_q_even,
    input [1:0] dest_in_mem_instr_q_even,

    output full_out_mem_instr_q_even,
    
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
    
    //D$_DATA_Q_in
    input[31:0] addr_in_dc_data_q_even,
    input [CL_SIZE-1:0] data_in_dc_data_q_even,
    input [2:0] operation_in_dc_data_q_even,
    input is_flush_in_dc_data_q_even,
    input alloc_in_dc_data_q_even,
    input [1:0] src_in_dc_data_q_even,
    input [1:0] dest_in_dc_data_q_even,

    output full_out_dc_data_q_even,
    
    //D$_INSTR_Q_in
    input[31:0] addr_in_dc_instr_q_even,
    input [2:0] operation_in_dc_instr_q_even,
    input is_flush_in_dc_instr_q_even,
    input alloc_in_dc_instr_q_even,
    input [1:0] src_in_dc_instr_q_even,
    input [1:0] dest_in_dc_instr_q_even,

    output full_out_dc_instr_q_even,

    //Outputs towards Qs
    output mem_instr_q_alloc_even,
    output [2:0] mem_instr_q_operation_even,

    output mem_data_q_alloc_even,
    output [2:0]mem_data_q_operation_even,
    
    output  ic_inst_q_alloc_even,
    output  [2:0]ic_inst_q_operation_even,

    output  ic_data_q_alloc_even,
    output  [2:0]ic_data_q_operation_even,

    output  dc_inst_q_alloc_even,
    output  [2:0]dc_inst_q_operation_even,

    output  dc_data_q_alloc_even,
    output  [2:0]dc_data_q_operation_even,

    output [1:0] src_out_even,
    output [1:0] dest_out_even,
    output [31:0] addr_out_even,
    output [CL_SIZE-1:0] data_out_even,

    //MEM_DATA_Q_in
    input[31:0] addr_in_mem_data_q_odd,
    input [CL_SIZE-1:0] data_in_mem_data_q_odd,
    input [2:0] operation_in_mem_data_q_odd,
    input is_flush_in_mem_data_q_odd,
    input alloc_in_mem_data_q_odd,
    input [1:0] src_in_mem_data_q_odd,
    input [1:0] dest_in_mem_data_q_odd,

    output full_out_mem_data_q_odd,
    
    //MEM_INSTR_Q_in
    input[31:0] addr_in_mem_instr_q_odd,
    input [2:0] operation_in_mem_instr_q_odd,
    input is_flush_in_mem_instr_q_odd,
    input alloc_in_mem_instr_q_odd,
    input [1:0] src_in_mem_instr_q_odd,
    input [1:0] dest_in_mem_instr_q_odd,

    output full_out_mem_instr_q_odd,
    
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
    
    //D$_DATA_Q_in
    input[31:0] addr_in_dc_data_q_odd,
    input [CL_SIZE-1:0] data_in_dc_data_q_odd,
    input [2:0] operation_in_dc_data_q_odd,
    input is_flush_in_dc_data_q_odd,
    input alloc_in_dc_data_q_odd,
    input [1:0] src_in_dc_data_q_odd,
    input [1:0] dest_in_dc_data_q_odd,

    output full_out_dc_data_q_odd,
    
    //D$_INSTR_Q_in
    input[31:0] addr_in_dc_instr_q_odd,
    input [2:0] operation_in_dc_instr_q_odd,
    input is_flush_in_dc_instr_q_odd,
    input alloc_in_dc_instr_q_odd,
    input [1:0] src_in_dc_instr_q_odd,
    input [1:0] dest_in_dc_instr_q_odd,

    output full_out_dc_instr_q_odd,

    //Outputs towards Qs
    output mem_instr_q_alloc_odd,
    output [2:0] mem_instr_q_operation_odd,

    output mem_data_q_alloc_odd,
    output [2:0]mem_data_q_operation_odd,
    
    output  ic_inst_q_alloc_odd,
    output  [2:0]ic_inst_q_operation_odd,

    output  ic_data_q_alloc_odd,
    output  [2:0]ic_data_q_operation_odd,

    output  dc_inst_q_alloc_odd,
    output  [2:0]dc_inst_q_operation_odd,

    output  dc_data_q_alloc_odd,
    output  [2:0]dc_data_q_operation_odd,

    output [1:0] src_out_odd,
    output [1:0] dest_out_odd,
    output [31:0] addr_out_odd,
    output [CL_SIZE-1:0] data_out_odd
);

       //MEM_DATA_Q_in
wire [31:0] dir_addr_in_mem_data_q_even;
wire  [CL_SIZE-1:0] dir_data_in_mem_data_q_even;
wire  [2:0] dir_operation_in_mem_data_q_even;
wire  dir_is_flush_in_mem_data_q_even;
wire  dir_valid_in_mem_data_q_even;
wire  [1:0] dir_src_in_mem_data_q_even;
wire  [1:0] dir_dest_in_mem_data_q_even;

    //MEM_INSTR_Q_in
wire [31:0] dir_addr_in_mem_instr_q_even;
wire  [2:0] dir_operation_in_mem_instr_q_even;
wire  dir_is_flush_in_mem_instr_q_even;
wire  dir_valid_in_mem_instr_q_even;
wire  [1:0] dir_src_in_mem_instr_q_even;
wire  [1:0] dir_dest_in_mem_instr_q_even;
 
     //I$_DATA_Q_in
wire [31:0] dir_addr_in_ic_data_q_even;
wire  [CL_SIZE-1:0] dir_data_in_ic_data_q_even;
wire  [2:0] dir_operation_in_ic_data_q_even;
wire  dir_is_flush_in_ic_data_q_even;
wire  dir_valid_in_ic_data_q_even;
wire  [1:0] dir_src_in_ic_data_q_even;
wire  [1:0] dir_dest_in_ic_data_q_even;
 
     //I$_INSTR_Q_in
wire [31:0] dir_addr_in_ic_instr_q_even;
wire  [2:0] dir_operation_in_ic_instr_q_even;
wire  dir_is_flush_in_ic_instr_q_even;
wire  dir_valid_in_ic_instr_q_even;
wire  [1:0] dir_src_in_ic_instr_q_even;
wire  [1:0] dir_dest_in_ic_instr_q_even;
 
    //D$_DATA_Q_in
wire [31:0] dir_addr_in_dc_data_q_even;
wire  [CL_SIZE-1:0] dir_data_in_dc_data_q_even;
wire  [2:0] dir_operation_in_dc_data_q_even;
wire  dir_is_flush_in_dc_data_q_even;
wire  dir_valid_in_dc_data_q_even;
wire  [1:0] dir_src_in_dc_data_q_even;
wire  [1:0] dir_dest_in_dc_data_q_even;
 
    //D$_INSTR_Q_in
wire [31:0] dir_addr_in_dc_instr_q_even;
wire  [2:0] dir_operation_in_dc_instr_q_even;
wire  dir_is_flush_in_dc_instr_q_even;
wire  dir_valid_in_dc_instr_q_even;
wire  [1:0] dir_src_in_dc_instr_q_even;
wire  [1:0] dir_dest_in_dc_instr_q_even;

      //MEM_DATA_Q_in
wire [31:0] dir_addr_in_mem_data_q_odd;
wire  [CL_SIZE-1:0] dir_data_in_mem_data_q_odd;
wire  [2:0] dir_operation_in_mem_data_q_odd;
wire  dir_is_flush_in_mem_data_q_odd;
wire  dir_valid_in_mem_data_q_odd;
wire  [1:0] dir_src_in_mem_data_q_odd;
wire  [1:0] dir_dest_in_mem_data_q_odd;

    //MEM_INSTR_Q_in
wire [31:0] dir_addr_in_mem_instr_q_odd;
wire  [2:0] dir_operation_in_mem_instr_q_odd;
wire  dir_is_flush_in_mem_instr_q_odd;
wire  dir_valid_in_mem_instr_q_odd;
wire  [1:0] dir_src_in_mem_instr_q_odd;
wire  [1:0] dir_dest_in_mem_instr_q_odd;
 
     //I$_DATA_Q_in
wire [31:0] dir_addr_in_ic_data_q_odd;
wire  [CL_SIZE-1:0] dir_data_in_ic_data_q_odd;
wire  [2:0] dir_operation_in_ic_data_q_odd;
wire  dir_is_flush_in_ic_data_q_odd;
wire  dir_valid_in_ic_data_q_odd;
wire  [1:0] dir_src_in_ic_data_q_odd;
wire  [1:0] dir_dest_in_ic_data_q_odd;
 
     //I$_INSTR_Q_in
wire [31:0] dir_addr_in_ic_instr_q_odd;
wire  [2:0] dir_operation_in_ic_instr_q_odd;
wire  dir_is_flush_in_ic_instr_q_odd;
wire  dir_valid_in_ic_instr_q_odd;
wire  [1:0] dir_src_in_ic_instr_q_odd;
wire  [1:0] dir_dest_in_ic_instr_q_odd;
 
    //D$_DATA_Q_in
wire [31:0] dir_addr_in_dc_data_q_odd;
wire  [CL_SIZE-1:0] dir_data_in_dc_data_q_odd;
wire  [2:0] dir_operation_in_dc_data_q_odd;
wire  dir_is_flush_in_dc_data_q_odd;
wire  dir_valid_in_dc_data_q_odd;
wire  [1:0] dir_src_in_dc_data_q_odd;
wire  [1:0] dir_dest_in_dc_data_q_odd;
 
    //D$_INSTR_Q_in
wire [31:0] dir_addr_in_dc_instr_q_odd;
wire  [2:0] dir_operation_in_dc_instr_q_odd;
wire  dir_is_flush_in_dc_instr_q_odd;
wire  dir_valid_in_dc_instr_q_odd;
wire  [1:0] dir_src_in_dc_instr_q_odd;
wire  [1:0] dir_dest_in_dc_instr_q_odd;

data_q #(.Q_LEGNTH(8), .CL_SIZE(CL_SIZE)) mem_data_q_even(
    //System     
    .clk(clk),
    .rst(rst),

    //From Sender
    .addr_in(addr_in_mem_data_q_even),
    .data_in(data_in_mem_data_q_even),
    .operation_in(operation_in_mem_data_q_even),
    .is_flush(is_flush_in_mem_data_q_even),
    .alloc(alloc_in_mem_data_q_even),
    .src(src_in_mem_data_q_even),
    .dest(dest_in_mem_data_q_even),
    //From reciever
    .dealloc(dealloc_even[5]),

    //output sender
    .full(full_out_mem_data_q_even),

    //output reciever
    .addr_out(dir_addr_in_mem_data_q_even),
    .data_out(dir_data_in_mem_data_q_even),
    .operation_out(dir_operation_in_mem_data_q_even),
    .valid(dir_valid_in_mem_data_q_even),
    .src_out(dir_src_in_mem_data_q_even),
    .dest_out(dir_dest_in_mem_data_q_even),
    .is_flush_out(dir_is_flush_in_mem_data_q_even)
);

instr_q  #(.Q_LEGNTH(8), .CL_SIZE(CL_SIZE)) mem_instr_q_even(
    //System     
    .clk(clk),
    .rst(rst),

    //From Sender
    .addr_in(addr_in_mem_instr_q_even),
    .operation_in(operation_in_mem_instr_q_even),
    .is_flush(is_flush_in_mem_instr_q_even),
    .alloc(alloc_in_mem_instr_q_even),
    .src(src_in_mem_instr_q_even),
    .dest(dest_in_mem_instr_q_even),

    //From reciever
    .dealloc(dealloc_even[4]),

    //output sender
    .full(full_out_mem_instr_q_even),

    //output reciever
    .addr_out(dir_addr_in_mem_instr_q_even),
    .operation_out(dir_operation_in_mem_instr_q_even),
    .valid(dir_valid_in_mem_instr_q_even),
    .src_out(dir_src_in_mem_instr_q_even),
    .dest_out(dir_dest_in_mem_instr_q_even),
    .is_flush_out(dir_is_flush_in_mem_instr_q_even)
);

data_q #(.Q_LEGNTH(8), .CL_SIZE(CL_SIZE)) icache_data_q_even(
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
    .dealloc(dealloc_even[3]),

    //output sender
    .full(full_out_ic_data_q_even),

    //output reciever
    .addr_out(dir_addr_in_ic_data_q_even),
    .data_out(dir_data_in_ic_data_q_even),
    .operation_out(dir_operation_in_ic_data_q_even),
    .valid(dir_valid_in_ic_data_q_even),
    .src_out(dir_src_in_ic_data_q_even),
    .dest_out(dir_dest_in_ic_data_q_even),
    .is_flush_out(dir_is_flush_in_ic_data_q_even)
);

instr_q  #(.Q_LEGNTH(8), .CL_SIZE(CL_SIZE)) icache_instr_q_even(
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
    .dealloc(dealloc_even[2]),

    //output sender
    .full(full_out_ic_instr_q_even),

    //output reciever
    .addr_out(dir_addr_in_ic_instr_q_even),
    .operation_out(dir_operation_in_ic_instr_q_even),
    .valid(dir_valid_in_ic_instr_q_even),
    .src_out(dir_src_in_ic_instr_q_even),
    .dest_out(dir_dest_in_ic_instr_q_even),
    .is_flush_out(dir_is_flush_in_ic_instr_q_even)
);

data_q #(.Q_LEGNTH(8), .CL_SIZE(CL_SIZE)) dcache_data_q_even(
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
    .dealloc(dealloc_even[1]),

    //output sender
    .full(full_out_dc_data_q_even),

    //output reciever
    .addr_out(dir_addr_in_dc_data_q_even),
    .data_out(dir_data_in_dc_data_q_even),
    .operation_out(dir_operation_in_dc_data_q_even),
    .valid(dir_valid_in_dc_data_q_even),
    .src_out(dir_src_in_dc_data_q_even),
    .dest_out(dir_dest_in_dc_data_q_even),
    .is_flush_out(dir_is_flush_in_dc_data_q_even)
);
instr_q  #(.Q_LEGNTH(8), .CL_SIZE(CL_SIZE)) dcache_instr_q_even(
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
    .dealloc(dealloc_even[0]),

    //output sender
    .full(full_out_dc_instr_q_even),

    //output reciever
    .addr_out(dir_addr_in_dc_instr_q_even),
    .operation_out(dir_operation_in_dc_instr_q_even),
    .valid(dir_valid_in_dc_instr_q_even),
    .src_out(dir_src_in_dc_instr_q_even),
    .dest_out(dir_dest_in_dc_instr_q_even),
    .is_flush_out(dir_is_flush_in_dc_instr_q_even)
);

wire[31:0] dir_addr_in_even;
wire[2:0] dir_operation_in_even;
wire[1:0] dir_src_in_even;
wire[1:0] dir_dest_in_even;
wire dir_is_flush_in_even;
wire[CL_SIZE-1:0] dir_data_in_even;
wire[5:0] dealloc_even;
queue_arbitrator #(.CL_SIZE(CL_SIZE), .Q_WIDTH(6)) queue_arb_even(
    .addr_in({
        dir_addr_in_mem_data_q_even,
        dir_addr_in_mem_instr_q_even,
        dir_addr_in_ic_data_q_even,
        dir_addr_in_ic_instr_q_even,
        dir_addr_in_dc_data_q_even,
        dir_addr_in_dc_instr_q_even
    }),
    .data_in({
        dir_data_in_mem_data_q_even,
        dir_data_in_ic_data_q_even,
        dir_data_in_dc_data_q_even
    }),
    .operation_in({
        dir_operation_in_mem_data_q_even,
        dir_operation_in_mem_instr_q_even,
        dir_operation_in_ic_data_q_even,
        dir_operation_in_ic_instr_q_even,
        dir_operation_in_dc_data_q_even,
        dir_operation_in_dc_instr_q_even
    }), 
    .valid_in({
        dir_valid_in_mem_data_q_even,
        dir_valid_in_mem_instr_q_even,
        dir_valid_in_ic_data_q_even,
        dir_valid_in_ic_instr_q_even,
        dir_valid_in_dc_data_q_even,
        dir_valid_in_dc_instr_q_even
    }),
    .src_in({
        dir_src_in_mem_data_q_even,
        dir_src_in_mem_instr_q_even,
        dir_src_in_ic_data_q_even,
        dir_src_in_ic_instr_q_even,
        dir_src_in_dc_data_q_even,
        dir_src_in_dc_instr_q_even
    }),
    .dest_in({
        dir_dest_in_mem_data_q_even,
        dir_dest_in_mem_instr_q_even,
        dir_dest_in_ic_data_q_even,
        dir_dest_in_ic_instr_q_even,
        dir_dest_in_dc_data_q_even,
        dir_dest_in_dc_instr_q_even
    }),
    .is_flush_in({
        dir_is_flush_in_mem_data_q_even,
        dir_is_flush_in_mem_instr_q_even,
        dir_is_flush_in_ic_data_q_even,
        dir_is_flush_in_ic_instr_q_even,
        dir_is_flush_in_dc_data_q_even,
        dir_is_flush_in_dc_instr_q_even
    }),
    
    .stall_in(0),

    .addr_out(dir_addr_in_even),
    .operation_out(dir_operation_in_even), 
    .data_out(dir_data_in_even),
    .valid_out(dir_valid_in_even),
    .src_out(dir_src_in_even),
    .dest_out(dir_dest_in_even),
    .is_flush_out(dir_is_flush_in_even),

    .dealloc(dealloc_even)
);

directory_bank #(.DATA_SIZE(DATA_SIZE), .CL_SIZE(CL_SIZE), .IDX_CNT(IDX_CNT), .TAG_SIZE(18)) directory_bank_even(
    .clk(clk),
    .rst(rst),

    .addr_in(dir_addr_in_even),
    .data_in(dir_data_in_even),
    .operation_in(dir_operation_in_even & {3{dir_valid_in_even}}),
    .src_in(dir_src_in_even),
    .dest_in(dir_is_flush_in_even),

    .mem_instr_q_alloc(mem_instr_q_alloc_even),
    .mem_instr_q_operation(mem_instr_q_operation_even),

    .mem_data_q_alloc(mem_data_q_alloc_even),
    .mem_data_q_operation(mem_data_q_operation_even),
    
    .ic_inst_q_alloc(ic_inst_q_alloc_even),
    .ic_inst_q_operation(ic_inst_q_operation_even),

    .ic_data_q_alloc(ic_data_q_alloc_even),
    .ic_data_q_operation(ic_data_q_operation_even),

    .dc_inst_q_alloc(dc_inst_q_alloc_even),
    .dc_inst_q_operation(dc_inst_q_operation_even),

    .dc_data_q_alloc(dc_data_q_alloc_even),
    .dc_data_q_operation(dc_data_q_operation_even),

    .src_out(src_out_even),
    .dest_out(dest_out_even),
    .addr_out(addr_out_even),
    .data_out(data_out_even)
);
data_q #(.Q_LEGNTH(8), .CL_SIZE(CL_SIZE)) mem_data_q_odd(
    //System     
    .clk(clk),
    .rst(rst),

    //From Sender
    .addr_in(addr_in_mem_data_q_odd),
    .data_in(data_in_mem_data_q_odd),
    .operation_in(operation_in_mem_data_q_odd),
    .is_flush(is_flush_in_mem_data_q_odd),
    .alloc(alloc_in_mem_data_q_odd),
    .src(src_in_mem_data_q_odd),
    .dest(dest_in_mem_data_q_odd),
    //From reciever
    .dealloc(dealloc_odd[5]),

    //output sender
    .full(full_out_mem_data_q_odd),

    //output reciever
    .addr_out(dir_addr_in_mem_data_q_odd),
    .data_out(dir_data_in_mem_data_q_odd),
    .operation_out(dir_operation_in_mem_data_q_odd),
    .valid(dir_valid_in_mem_data_q_odd),
    .src_out(dir_src_in_mem_data_q_odd),
    .dest_out(dir_dest_in_mem_data_q_odd),
    .is_flush_out(dir_is_flush_in_mem_data_q_odd)
);

instr_q  #(.Q_LEGNTH(8), .CL_SIZE(CL_SIZE)) mem_instr_q_odd(
    //System     
    .clk(clk),
    .rst(rst),

    //From Sender
    .addr_in(addr_in_mem_instr_q_odd),
    .operation_in(operation_in_mem_instr_q_odd),
    .is_flush(is_flush_in_mem_instr_q_odd),
    .alloc(alloc_in_mem_instr_q_odd),
    .src(src_in_mem_instr_q_odd),
    .dest(dest_in_mem_instr_q_odd),

    //From reciever
    .dealloc(dealloc_odd[4]),

    //output sender
    .full(full_out_mem_instr_q_odd),

    //output reciever
    .addr_out(dir_addr_in_mem_instr_q_odd),
    .operation_out(dir_operation_in_mem_instr_q_odd),
    .valid(dir_valid_in_mem_instr_q_odd),
    .src_out(dir_src_in_mem_instr_q_odd),
    .dest_out(dir_dest_in_mem_instr_q_odd),
    .is_flush_out(dir_is_flush_in_mem_instr_q_odd)
);

data_q #(.Q_LEGNTH(8), .CL_SIZE(CL_SIZE)) icache_data_q_odd(
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
    .dealloc(dealloc_odd[3]),

    //output sender
    .full(full_out_ic_data_q_odd),

    //output reciever
    .addr_out(dir_addr_in_ic_data_q_odd),
    .data_out(dir_data_in_ic_data_q_odd),
    .operation_out(dir_operation_in_ic_data_q_odd),
    .valid(dir_valid_in_ic_data_q_odd),
    .src_out(dir_src_in_ic_data_q_odd),
    .dest_out(dir_dest_in_ic_data_q_odd),
    .is_flush_out(dir_is_flush_in_ic_data_q_odd)
);

instr_q  #(.Q_LEGNTH(8), .CL_SIZE(CL_SIZE)) icache_instr_q_odd(
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
    .dealloc(dealloc_odd[2]),

    //output sender
    .full(full_out_ic_instr_q_odd),

    //output reciever
    .addr_out(dir_addr_in_ic_instr_q_odd),
    .operation_out(dir_operation_in_ic_instr_q_odd),
    .valid(dir_valid_in_ic_instr_q_odd),
    .src_out(dir_src_in_ic_instr_q_odd),
    .dest_out(dir_dest_in_ic_instr_q_odd),
    .is_flush_out(dir_is_flush_in_ic_instr_q_odd)
);

data_q #(.Q_LEGNTH(8), .CL_SIZE(CL_SIZE)) dcache_data_q_odd(
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
    .dealloc(dealloc_odd[1]),

    //output sender
    .full(full_out_dc_data_q_odd),

    //output reciever
    .addr_out(dir_addr_in_dc_data_q_odd),
    .data_out(dir_data_in_dc_data_q_odd),
    .operation_out(dir_operation_in_dc_data_q_odd),
    .valid(dir_valid_in_dc_data_q_odd),
    .src_out(dir_src_in_dc_data_q_odd),
    .dest_out(dir_dest_in_dc_data_q_odd),
    .is_flush_out(dir_is_flush_in_dc_data_q_odd)
);
instr_q  #(.Q_LEGNTH(8), .CL_SIZE(CL_SIZE)) dcache_instr_q_odd(
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
    .dealloc(dealloc_odd[0]),

    //output sender
    .full(full_out_dc_instr_q_odd),

    //output reciever
    .addr_out(dir_addr_in_dc_instr_q_odd),
    .operation_out(dir_operation_in_dc_instr_q_odd),
    .valid(dir_valid_in_dc_instr_q_odd),
    .src_out(dir_src_in_dc_instr_q_odd),
    .dest_out(dir_dest_in_dc_instr_q_odd),
    .is_flush_out(dir_is_flush_in_dc_instr_q_odd)
);

wire[31:0] dir_addr_in_odd;
wire[2:0] dir_operation_in_odd;
wire[1:0] dir_src_in_odd;
wire[1:0] dir_dest_in_odd;
wire dir_is_flush_in_odd;
wire[CL_SIZE-1:0] dir_data_in_odd;
wire[5:0] dealloc_odd;
queue_arbitrator #(.CL_SIZE(CL_SIZE), .Q_WIDTH(6)) queue_arb_odd(
    .addr_in({
        dir_addr_in_mem_data_q_odd,
        dir_addr_in_mem_instr_q_odd,
        dir_addr_in_ic_data_q_odd,
        dir_addr_in_ic_instr_q_odd,
        dir_addr_in_dc_data_q_odd,
        dir_addr_in_dc_instr_q_odd
    }),
    .data_in({
        dir_data_in_mem_data_q_odd,
        dir_data_in_ic_data_q_odd,
        dir_data_in_dc_data_q_odd
    }),
    .operation_in({
        dir_operation_in_mem_data_q_odd,
        dir_operation_in_mem_instr_q_odd,
        dir_operation_in_ic_data_q_odd,
        dir_operation_in_ic_instr_q_odd,
        dir_operation_in_dc_data_q_odd,
        dir_operation_in_dc_instr_q_odd
    }), 
    .valid_in({
        dir_valid_in_mem_data_q_odd,
        dir_valid_in_mem_instr_q_odd,
        dir_valid_in_ic_data_q_odd,
        dir_valid_in_ic_instr_q_odd,
        dir_valid_in_dc_data_q_odd,
        dir_valid_in_dc_instr_q_odd
    }),
    .src_in({
        dir_src_in_mem_data_q_odd,
        dir_src_in_mem_instr_q_odd,
        dir_src_in_ic_data_q_odd,
        dir_src_in_ic_instr_q_odd,
        dir_src_in_dc_data_q_odd,
        dir_src_in_dc_instr_q_odd
    }),
    .dest_in({
        dir_dest_in_mem_data_q_odd,
        dir_dest_in_mem_instr_q_odd,
        dir_dest_in_ic_data_q_odd,
        dir_dest_in_ic_instr_q_odd,
        dir_dest_in_dc_data_q_odd,
        dir_dest_in_dc_instr_q_odd
    }),
    .is_flush_in({
        dir_is_flush_in_mem_data_q_odd,
        dir_is_flush_in_mem_instr_q_odd,
        dir_is_flush_in_ic_data_q_odd,
        dir_is_flush_in_ic_instr_q_odd,
        dir_is_flush_in_dc_data_q_odd,
        dir_is_flush_in_dc_instr_q_odd
    }),
    
    .stall_in(0),

    .addr_out(dir_addr_in_odd),
    .operation_out(dir_operation_in_odd), 
    .data_out(dir_data_in_odd),
    .valid_out(dir_valid_in_odd),
    .src_out(dir_src_in_odd),
    .dest_out(dir_dest_in_odd),
    .is_flush_out(dir_is_flush_in_odd),

    .dealloc(dealloc_odd)
);

directory_bank #(.DATA_SIZE(DATA_SIZE), .CL_SIZE(CL_SIZE), .IDX_CNT(IDX_CNT), .TAG_SIZE(18)) directory_bank_odd(
    .clk(clk),
    .rst(rst),

    .addr_in(dir_addr_in_odd),
    .data_in(dir_data_in_odd),
    .operation_in(dir_operation_in_odd & {3{dir_valid_in_odd}}),
    .src_in(dir_src_in_odd),
    .dest_in(dir_is_flush_in_odd),

    .mem_instr_q_alloc(mem_instr_q_alloc_odd),
    .mem_instr_q_operation(mem_instr_q_operation_odd),

    .mem_data_q_alloc(mem_data_q_alloc_odd),
    .mem_data_q_operation(mem_data_q_operation_odd),
    
    .ic_inst_q_alloc(ic_inst_q_alloc_odd),
    .ic_inst_q_operation(ic_inst_q_operation_odd),

    .ic_data_q_alloc(ic_data_q_alloc_odd),
    .ic_data_q_operation(ic_data_q_operation_odd),

    .dc_inst_q_alloc(dc_inst_q_alloc_odd),
    .dc_inst_q_operation(dc_inst_q_operation_odd),

    .dc_data_q_alloc(dc_data_q_alloc_odd),
    .dc_data_q_operation(dc_data_q_operation_odd),

    .src_out(src_out_odd),
    .dest_out(dest_out_odd),
    .addr_out(addr_out_odd),
    .data_out(data_out_odd)
);
endmodule