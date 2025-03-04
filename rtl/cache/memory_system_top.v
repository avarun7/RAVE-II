module memory_system_top #(parameter CL_SIZE = 128, OOO_TAG_SIZE = 10, TAG_SIZE = 18, IDX_CNT = 512) (
    input clk,
    input rst,

    //I$
    //FRONTEND FACING STUF
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
    output exception
    
);

           //ic_2_dir_data
wire    [31:0] ic_2_dir_addr_data_q_even;
wire    [CL_SIZE-1:0] ic_2_dir_data_data_q_even;
wire    [2:0] ic_2_dir_operation_data_q_even;
wire    ic_2_dir_is_flush_data_q_even;
wire    ic_2_dir_valid_data_q_even;
wire    [1:0]ic_2_dir_src_data_q_even;
wire    [1:0]ic_2_dir_dest_data_q_even;

    //ic_2_dir_instr
wire    [31:0]ic_2_dir_addr_instr_q_even;
wire    [2:0]ic_2_dir_operation_instr_q_even;
wire   ic_2_dir_is_flush_instr_q_even;
wire   ic_2_dir_valid_instr_q_even;
wire    [1:0]ic_2_dir_src_instr_q_even;
wire    [1:0]ic_2_dir_dest_instr_q_even;

           //dir_2_ic_data
wire    [31:0] dir_2_ic_addr_data_q_even;
wire    [CL_SIZE-1:0] dir_2_ic_data_data_q_even;
wire    [2:0] dir_2_ic_operation_data_q_even;
wire    dir_2_ic_is_flush_data_q_even;
wire   dir_2_ic_valid_data_q_even;
wire    [1:0]dir_2_ic_src_data_q_even;
wire    [1:0]dir_2_ic_dest_data_q_even;

    //dir_2_ic_instr
wire    [31:0]dir_2_ic_addr_instr_q_even;
wire    [2:0]dir_2_ic_operation_instr_q_even;
wire   dir_2_ic_is_flush_instr_q_even;
wire   dir_2_ic_valid_instr_q_even;
wire    [1:0]dir_2_ic_src_instr_q_even;
wire    [1:0]dir_2_ic_dest_instr_q_even;

           //dc_2_dir_data
wire    [31:0] dc_2_dir_addr_data_q_even;
wire    [CL_SIZE-1:0] dc_2_dir_data_data_q_even;
wire    [2:0] dc_2_dir_operation_data_q_even;
wire    dc_2_dir_is_flush_data_q_even;
wire   dc_2_dir_valid_data_q_even;
wire    [1:0]dc_2_dir_src_data_q_even;
wire    [1:0]dc_2_dir_dest_data_q_even;

    //dc_2_dir_instr
wire    [31:0]dc_2_dir_addr_instr_q_even;
wire    [2:0]dc_2_dir_operation_instr_q_even;
wire   dc_2_dir_is_flush_instr_q_even;
wire   dc_2_dir_valid_instr_q_even;
wire    [1:0]dc_2_dir_src_instr_q_even;
wire    [1:0]dc_2_dir_dest_instr_q_even;

           //dir_2_dc_data
wire    [31:0] dir_2_dc_addr_data_q_even;
wire    [CL_SIZE-1:0] dir_2_dc_data_data_q_even;
wire    [2:0] dir_2_dc_operation_data_q_even;
wire    dir_2_dc_is_flush_data_q_even;
wire   dir_2_dc_valid_data_q_even;
wire    [1:0]dir_2_dc_src_data_q_even;
wire    [1:0]dir_2_dc_dest_data_q_even;

    //dir_2_dc_instr
wire    [31:0]dir_2_dc_addr_instr_q_even;
wire    [2:0]dir_2_dc_operation_instr_q_even;
wire   dir_2_dc_is_flush_instr_q_even;
wire   dir_2_dc_valid_instr_q_even;
wire    [1:0]dir_2_dc_src_instr_q_even;
wire    [1:0]dir_2_dc_dest_instr_q_even;

           //dir_2_mem_data
wire    [31:0] dir_2_mem_addr_data_q_even;
wire    [CL_SIZE-1:0] dir_2_mem_data_data_q_even;
wire    [2:0] dir_2_mem_operation_data_q_even;
wire    dir_2_mem_is_flush_data_q_even;
wire   dir_2_mem_valid_data_q_even;
wire    [1:0]dir_2_mem_src_data_q_even;
wire    [1:0]dir_2_mem_dest_data_q_even;

    //dir_2_mem_instr
wire    [31:0]dir_2_mem_addr_instr_q_even;
wire    [2:0]dir_2_mem_operation_instr_q_even;
wire   dir_2_mem_is_flush_instr_q_even;
wire   dir_2_mem_valid_instr_q_even;
wire    [1:0]dir_2_mem_src_instr_q_even;
wire    [1:0]dir_2_mem_dest_instr_q_even;

           //mem_2_dir_data
wire    [31:0] mem_2_dir_addr_data_q_even;
wire    [CL_SIZE-1:0] mem_2_dir_data_data_q_even;
wire    [2:0] mem_2_dir_operation_data_q_even;
wire    mem_2_dir_is_flush_data_q_even;
wire   mem_2_dir_valid_data_q_even;
wire    [1:0]mem_2_dir_src_data_q_even;
wire    [1:0]mem_2_dir_dest_data_q_even;

    //mem_2_dir_instr
wire    [31:0]mem_2_dir_addr_instr_q_even;
wire    [2:0]mem_2_dir_operation_instr_q_even;
wire   mem_2_dir_is_flush_instr_q_even;
wire   mem_2_dir_valid_instr_q_even;
wire    [1:0]mem_2_dir_src_instr_q_even;
wire    [1:0]mem_2_dir_dest_instr_q_even;

           //ic_2_dir_data
wire    [31:0] ic_2_dir_addr_data_q_odd;
wire    [CL_SIZE-1:0] ic_2_dir_data_data_q_odd;
wire    [2:0] ic_2_dir_operation_data_q_odd;
wire    ic_2_dir_is_flush_data_q_odd;
wire    ic_2_dir_valid_data_q_odd;
wire    [1:0]ic_2_dir_src_data_q_odd;
wire    [1:0]ic_2_dir_dest_data_q_odd;

    //ic_2_dir_instr
wire    [31:0]ic_2_dir_addr_instr_q_odd;
wire    [2:0]ic_2_dir_operation_instr_q_odd;
wire   ic_2_dir_is_flush_instr_q_odd;
wire   ic_2_dir_valid_instr_q_odd;
wire    [1:0]ic_2_dir_src_instr_q_odd;
wire    [1:0]ic_2_dir_dest_instr_q_odd;

           //dir_2_ic_data
wire    [31:0] dir_2_ic_addr_data_q_odd;
wire    [CL_SIZE-1:0] dir_2_ic_data_data_q_odd;
wire    [2:0] dir_2_ic_operation_data_q_odd;
wire    dir_2_ic_is_flush_data_q_odd;
wire   dir_2_ic_valid_data_q_odd;
wire    [1:0]dir_2_ic_src_data_q_odd;
wire    [1:0]dir_2_ic_dest_data_q_odd;

    //dir_2_ic_instr
wire    [31:0]dir_2_ic_addr_instr_q_odd;
wire    [2:0]dir_2_ic_operation_instr_q_odd;
wire   dir_2_ic_is_flush_instr_q_odd;
wire   dir_2_ic_valid_instr_q_odd;
wire    [1:0]dir_2_ic_src_instr_q_odd;
wire    [1:0]dir_2_ic_dest_instr_q_odd;

           //dc_2_dir_data
wire    [31:0] dc_2_dir_addr_data_q_odd;
wire    [CL_SIZE-1:0] dc_2_dir_data_data_q_odd;
wire    [2:0] dc_2_dir_operation_data_q_odd;
wire    dc_2_dir_is_flush_data_q_odd;
wire   dc_2_dir_valid_data_q_odd;
wire    [1:0]dc_2_dir_src_data_q_odd;
wire    [1:0]dc_2_dir_dest_data_q_odd;

    //dc_2_dir_instr
wire    [31:0]dc_2_dir_addr_instr_q_odd;
wire    [2:0]dc_2_dir_operation_instr_q_odd;
wire   dc_2_dir_is_flush_instr_q_odd;
wire   dc_2_dir_valid_instr_q_odd;
wire    [1:0]dc_2_dir_src_instr_q_odd;
wire    [1:0]dc_2_dir_dest_instr_q_odd;

           //dir_2_dc_data
wire    [31:0] dir_2_dc_addr_data_q_odd;
wire    [CL_SIZE-1:0] dir_2_dc_data_data_q_odd;
wire    [2:0] dir_2_dc_operation_data_q_odd;
wire    dir_2_dc_is_flush_data_q_odd;
wire   dir_2_dc_valid_data_q_odd;
wire    [1:0]dir_2_dc_src_data_q_odd;
wire    [1:0]dir_2_dc_dest_data_q_odd;

    //dir_2_dc_instr
wire    [31:0]dir_2_dc_addr_instr_q_odd;
wire    [2:0]dir_2_dc_operation_instr_q_odd;
wire   dir_2_dc_is_flush_instr_q_odd;
wire   dir_2_dc_valid_instr_q_odd;
wire    [1:0]dir_2_dc_src_instr_q_odd;
wire    [1:0]dir_2_dc_dest_instr_q_odd;

           //dir_2_mem_data
wire    [31:0] dir_2_mem_addr_data_q_odd;
wire    [CL_SIZE-1:0] dir_2_mem_data_data_q_odd;
wire    [2:0] dir_2_mem_operation_data_q_odd;
wire    dir_2_mem_is_flush_data_q_odd;
wire   dir_2_mem_valid_data_q_odd;
wire    [1:0]dir_2_mem_src_data_q_odd;
wire    [1:0]dir_2_mem_dest_data_q_odd;

    //dir_2_mem_instr
wire    [31:0]dir_2_mem_addr_instr_q_odd;
wire    [2:0]dir_2_mem_operation_instr_q_odd;
wire   dir_2_mem_is_flush_instr_q_odd;
wire   dir_2_mem_valid_instr_q_odd;
wire    [1:0]dir_2_mem_src_instr_q_odd;
wire    [1:0]dir_2_mem_dest_instr_q_odd;

           //mem_2_dir_data
wire    [31:0] mem_2_dir_addr_data_q_odd;
wire    [CL_SIZE-1:0] mem_2_dir_data_data_q_odd;
wire    [2:0] mem_2_dir_operation_data_q_odd;
wire    mem_2_dir_is_flush_data_q_odd;
wire   mem_2_dir_valid_data_q_odd;
wire    [1:0]mem_2_dir_src_data_q_odd;
wire    [1:0]mem_2_dir_dest_data_q_odd;

    //mem_2_dir_instr
wire    [31:0]mem_2_dir_addr_instr_q_odd;
wire    [2:0]mem_2_dir_operation_instr_q_odd;
wire   mem_2_dir_is_flush_instr_q_odd;
wire   mem_2_dir_valid_instr_q_odd;
wire    [1:0]mem_2_dir_src_instr_q_odd;
wire    [1:0]mem_2_dir_dest_instr_q_odd;

wire [1:0] src_dir_2_all_even;
wire [1:0] dest_dir_2_all_even;
wire [31:0] addr_dir_2_all_even;
wire [CL_SIZE-1:0] data_dir_2_all_even;

wire [1:0] src_dir_2_all_odd;
wire [1:0] dest_dir_2_all_odd;
wire [31:0] addr_dir_2_all_odd;
wire [CL_SIZE-1:0] data_dir_2_all_odd;

directory_top #(
    .CL_SIZE(CL_SIZE),
    .TAG_SIZE(TAG_SIZE),
    .IDX_CNT(IDX_CNT),
    .DATA_SIZE(4)
) directory_inst (
    .clk(clk),
    .rst(rst),

    // EVEN SIDE
    .addr_in_mem_data_q_even(mem_2_dir_addr_data_q_even),
    .data_in_mem_data_q_even(mem_2_dir_data_data_q_even),
    .operation_in_mem_data_q_even(mem_2_dir_operation_data_q_even),
    .is_flush_in_mem_data_q_even(mem_2_dir_is_flush_data_q_even),
    .alloc_in_mem_data_q_even(mem_2_dir_valid_data_q_even),
    .src_in_mem_data_q_even(mem_2_dir_src_data_q_even),
    .dest_in_mem_data_q_even(mem_2_dir_dest_data_q_even),
    
    .full_out_mem_data_q_even(),

    .addr_in_mem_instr_q_even(mem_2_dir_addr_instr_q_even),
    .operation_in_mem_instr_q_even(mem_2_dir_operation_instr_q_even),
    .is_flush_in_mem_instr_q_even(mem_2_dir_is_flush_instr_q_even),
    .alloc_in_mem_instr_q_even(mem_2_dir_valid_instr_q_even),
    .src_in_mem_instr_q_even(mem_2_dir_src_instr_q_even),
    .dest_in_mem_instr_q_even(mem_2_dir_dest_instr_q_even),
    
    .full_out_mem_instr_q_even(),

    .addr_in_ic_data_q_even(ic_2_dir_addr_data_q_even),
    .data_in_ic_data_q_even(ic_2_dir_data_data_q_even),
    .operation_in_ic_data_q_even(ic_2_dir_operation_data_q_even),
    .is_flush_in_ic_data_q_even(ic_2_dir_is_flush_data_q_even),
    .alloc_in_ic_data_q_even(ic_2_dir_valid_data_q_even),
    .src_in_ic_data_q_even(ic_2_dir_src_data_q_even),
    .dest_in_ic_data_q_even(ic_2_dir_dest_data_q_even),
    
    .full_out_ic_data_q_even(),

    .addr_in_ic_instr_q_even(ic_2_dir_addr_instr_q_even),
    .operation_in_ic_instr_q_even(ic_2_dir_operation_instr_q_even),
    .is_flush_in_ic_instr_q_even(ic_2_dir_is_flush_instr_q_even),
    .alloc_in_ic_instr_q_even(ic_2_dir_valid_instr_q_even),
    .src_in_ic_instr_q_even(ic_2_dir_src_instr_q_even),
    .dest_in_ic_instr_q_even(ic_2_dir_dest_instr_q_even),
    
    .full_out_ic_instr_q_even(),

    //TODO: UNZERO OUT
    .addr_in_dc_data_q_even(dc_2_dir_addr_data_q_even),
    .data_in_dc_data_q_even(dc_2_dir_data_data_q_even),
    .operation_in_dc_data_q_even(dc_2_dir_operation_data_q_even & 3'd0),
    .is_flush_in_dc_data_q_even(dc_2_dir_is_flush_data_q_even),
    .alloc_in_dc_data_q_even(dc_2_dir_valid_data_q_even & 1'd0),
    .src_in_dc_data_q_even(dc_2_dir_src_data_q_even),
    .dest_in_dc_data_q_even(dc_2_dir_dest_data_q_even),
    
    .full_out_dc_data_q_even(),

    //TODO: UNZERO OUT
    .addr_in_dc_instr_q_even(dc_2_dir_addr_instr_q_even),
    .operation_in_dc_instr_q_even(dc_2_dir_operation_instr_q_even &  & 3'd0),
    .is_flush_in_dc_instr_q_even(dc_2_dir_is_flush_instr_q_even),
    .alloc_in_dc_instr_q_even(dc_2_dir_valid_instr_q_even &  & 1'd0),
    .src_in_dc_instr_q_even(dc_2_dir_src_instr_q_even),
    .dest_in_dc_instr_q_even(dc_2_dir_dest_instr_q_even),
    
    .full_out_dc_instr_q_even(),

    .mem_instr_q_alloc_even(dir_2_mem_valid_instr_q_even),
    .mem_instr_q_operation_even(dir_2_mem_operation_instr_q_even),
    .mem_data_q_alloc_even(dir_2_mem_valid_data_q_even),
    .mem_data_q_operation_even(dir_2_mem_operation_data_q_even),
    .ic_inst_q_alloc_even(dir_2_ic_valid_instr_q_even),
    .ic_inst_q_operation_even(dir_2_ic_operation_instr_q_even),
    .ic_data_q_alloc_even(dir_2_ic_valid_data_q_even),
    .ic_data_q_operation_even(dir_2_ic_operation_data_q_even),
    .dc_inst_q_alloc_even(dir_2_dc_valid_instr_q_even),
    .dc_inst_q_operation_even(dir_2_dc_operation_instr_q_even),
    .dc_data_q_alloc_even(dir_2_dc_valid_data_q_even),
    .dc_data_q_operation_even(dir_2_dc_operation_data_q_even),

    .src_out_even( src_dir_2_all_even ),
    .dest_out_even(dest_dir_2_all_even),
    .addr_out_even(addr_dir_2_all_even),
    .data_out_even(data_dir_2_all_even),

    // ODD SIDE
    .addr_in_mem_data_q_odd(mem_2_dir_addr_data_q_odd),
    .data_in_mem_data_q_odd(mem_2_dir_data_data_q_odd),
    .operation_in_mem_data_q_odd(mem_2_dir_operation_data_q_odd),
    .is_flush_in_mem_data_q_odd(mem_2_dir_is_flush_data_q_odd),
    .alloc_in_mem_data_q_odd(mem_2_dir_valid_data_q_odd),
    .src_in_mem_data_q_odd(mem_2_dir_src_data_q_odd),
    .dest_in_mem_data_q_odd(mem_2_dir_dest_data_q_odd),
    
    .full_out_mem_data_q_odd(),

    .addr_in_mem_instr_q_odd(mem_2_dir_addr_instr_q_odd),
    .operation_in_mem_instr_q_odd(mem_2_dir_operation_instr_q_odd &  & 3'd0),
    .is_flush_in_mem_instr_q_odd(mem_2_dir_is_flush_instr_q_odd),
    .alloc_in_mem_instr_q_odd(mem_2_dir_valid_instr_q_odd &  & 1'd0),
    .src_in_mem_instr_q_odd(mem_2_dir_src_instr_q_odd),
    .dest_in_mem_instr_q_odd(mem_2_dir_dest_instr_q_odd),
    
    .full_out_mem_instr_q_odd(),

    .addr_in_ic_data_q_odd(ic_2_dir_addr_data_q_odd),
    .data_in_ic_data_q_odd(ic_2_dir_data_data_q_odd),
    .operation_in_ic_data_q_odd(ic_2_dir_operation_data_q_odd),
    .is_flush_in_ic_data_q_odd(ic_2_dir_is_flush_data_q_odd),
    .alloc_in_ic_data_q_odd(ic_2_dir_valid_data_q_odd),
    .src_in_ic_data_q_odd(ic_2_dir_src_data_q_odd),
    .dest_in_ic_data_q_odd(ic_2_dir_dest_data_q_odd),
    
    .full_out_ic_data_q_odd(),

    .addr_in_ic_instr_q_odd(ic_2_dir_addr_instr_q_odd),
    .operation_in_ic_instr_q_odd(ic_2_dir_operation_instr_q_odd),
    .is_flush_in_ic_instr_q_odd(ic_2_dir_is_flush_instr_q_odd),
    .alloc_in_ic_instr_q_odd(ic_2_dir_valid_instr_q_odd),
    .src_in_ic_instr_q_odd(ic_2_dir_src_instr_q_odd),
    .dest_in_ic_instr_q_odd(ic_2_dir_dest_instr_q_odd),
    
    .full_out_ic_instr_q_odd(),

    //TODO: UNZERO OUT
    .addr_in_dc_data_q_odd(dc_2_dir_addr_data_q_odd),
    .data_in_dc_data_q_odd(dc_2_dir_data_data_q_odd),
    .operation_in_dc_data_q_odd(dc_2_dir_operation_data_q_odd &  & 3'd0),
    .is_flush_in_dc_data_q_odd(dc_2_dir_is_flush_data_q_odd),
    .alloc_in_dc_data_q_odd(dc_2_dir_valid_data_q_odd & 1'd0),
    .src_in_dc_data_q_odd(dc_2_dir_src_data_q_odd),
    .dest_in_dc_data_q_odd(dc_2_dir_dest_data_q_odd),
    
    .full_out_dc_data_q_odd(),

    //TODO: UNZERO OUT
    .addr_in_dc_instr_q_odd(dc_2_dir_addr_instr_q_odd),
    .operation_in_dc_instr_q_odd(dc_2_dir_operation_instr_q_odd &  & 3'd0),
    .is_flush_in_dc_instr_q_odd(dc_2_dir_is_flush_instr_q_odd),
    .alloc_in_dc_instr_q_odd(dc_2_dir_valid_instr_q_odd &  & 1'd0),
    .src_in_dc_instr_q_odd(dc_2_dir_src_instr_q_odd),
    .dest_in_dc_instr_q_odd(dc_2_dir_dest_instr_q_odd),
    
    .full_out_dc_instr_q_odd(),

    .mem_instr_q_alloc_odd(dir_2_mem_valid_instr_q_odd),
    .mem_instr_q_operation_odd(dir_2_mem_operation_instr_q_odd),
    .mem_data_q_alloc_odd(dir_2_mem_valid_data_q_odd),
    .mem_data_q_operation_odd(dir_2_mem_operation_data_q_odd),
    .ic_inst_q_alloc_odd(dir_2_ic_valid_instr_q_odd),
    .ic_inst_q_operation_odd(dir_2_ic_operation_instr_q_odd),
    .ic_data_q_alloc_odd(dir_2_ic_valid_data_q_odd),
    .ic_data_q_operation_odd(dir_2_ic_operation_data_q_odd),
    .dc_inst_q_alloc_odd(dir_2_dc_valid_instr_q_odd),
    .dc_inst_q_operation_odd(dir_2_dc_operation_instr_q_odd),
    .dc_data_q_alloc_odd(dir_2_dc_valid_data_q_odd),
    .dc_data_q_operation_odd(dir_2_dc_operation_data_q_odd),

    .src_out_odd(src_dir_2_all_odd),
    .dest_out_odd(dest_dir_2_all_odd),
    .addr_out_odd(addr_dir_2_all_odd),
    .data_out_odd(data_dir_2_all_odd)
);

dram_top #(
    .CL_SIZE(CL_SIZE)
) dram_inst (
    .clk(clk),
    .rst(rst),
    // src_dir_2_all_even 
    // dest_dir_2_all_even
    // addr_dir_2_all_even
    // data_dir_2_all_even
    // EVEN SIDE INPUTS
    .addr_in_mem_data_q_even(addr_dir_2_all_even),
    .data_in_mem_data_q_even(dir_2_mem_data_data_q_even),
    .operation_in_mem_data_q_even(dir_2_mem_operation_data_q_even),
    .is_flush_in_mem_data_q_even(dir_2_mem_is_flush_data_q_even),
    .alloc_in_mem_data_q_even(dir_2_mem_valid_data_q_even),
    .src_in_mem_data_q_even(src_dir_2_all_even),
    .dest_in_mem_data_q_even(dest_dir_2_all_even),
    
    .full_out_mem_data_q_even(),

    .addr_in_mem_instr_q_even(addr_dir_2_all_even),
    .operation_in_mem_instr_q_even(dir_2_mem_operation_instr_q_even),
    .is_flush_in_mem_instr_q_even(dir_2_mem_is_flush_instr_q_even),
    .alloc_in_mem_instr_q_even(dir_2_mem_valid_instr_q_even),
    .src_in_mem_instr_q_even(src_dir_2_all_even),
    .dest_in_mem_instr_q_even(dest_dir_2_all_even),
    
    .full_out_mem_instr_q_even(),

    //  src_dir_2_all_odd
    // dest_dir_2_all_odd
    // addr_dir_2_all_odd
    // data_dir_2_all_odd
    // ODD SIDE INPUTS
    .addr_in_mem_data_q_odd(addr_dir_2_all_odd),
    .data_in_mem_data_q_odd(dir_2_mem_data_data_q_odd),
    .operation_in_mem_data_q_odd(dir_2_mem_operation_data_q_odd),
    .is_flush_in_mem_data_q_odd(dir_2_mem_is_flush_data_q_odd),
    .alloc_in_mem_data_q_odd(dir_2_mem_valid_data_q_odd),
    .src_in_mem_data_q_odd(src_dir_2_all_odd),
    .dest_in_mem_data_q_odd(dest_dir_2_all_odd),
    
    .full_out_mem_data_q_odd(),

    .addr_in_mem_instr_q_odd(addr_dir_2_all_odd),
    .operation_in_mem_instr_q_odd(dir_2_mem_operation_instr_q_odd),
    .is_flush_in_mem_instr_q_odd(dir_2_mem_is_flush_instr_q_odd),
    .alloc_in_mem_instr_q_odd(dir_2_mem_valid_instr_q_odd),
    .src_in_mem_instr_q_odd(src_dir_2_all_odd),
    .dest_in_mem_instr_q_odd(dest_dir_2_all_odd),
    
    .full_out_mem_instr_q_odd(),

    // EVEN SIDE OUTPUTS
    .addr_out_mem_data_q_even(mem_2_dir_addr_data_q_even),
    .data_out_mem_data_q_even(mem_2_dir_data_data_q_even),
    .operation_out_mem_data_q_even(mem_2_dir_operation_data_q_even),
    .is_flush_out_mem_data_q_even(mem_2_dir_is_flush_data_q_even),
    .alloc_out_mem_data_q_even(mem_2_dir_valid_data_q_even),
    .src_out_mem_data_q_even(mem_2_dir_src_data_q_even),
    .dest_out_mem_data_q_even(mem_2_dir_dest_data_q_even),
    
    .full_in_mem_data_q_even(1'b0),

    // ODD SIDE OUTPUTS
    .addr_out_mem_data_q_odd(mem_2_dir_addr_data_q_odd),
    .data_out_mem_data_q_odd(mem_2_dir_data_data_q_odd),
    .operation_out_mem_data_q_odd(mem_2_dir_operation_data_q_odd),
    .is_flush_out_mem_data_q_odd(mem_2_dir_is_flush_data_q_odd),
    .alloc_out_mem_data_q_odd(mem_2_dir_valid_data_q_odd),
    .src_out_mem_data_q_odd(mem_2_dir_src_data_q_odd),
    .dest_out_mem_data_q_odd(mem_2_dir_dest_data_q_odd),
    
    .full_in_mem_data_q_odd(1'b0)
);

icache_TOP #(
    .CL_SIZE(CL_SIZE),
    .IDX_CNT(IDX_CNT),
    .OOO_TAG_SIZE(OOO_TAG_SIZE),
    .TAG_SIZE(TAG_SIZE)
) icache_inst (
    .clk(clk),
    .rst(rst),

    // Pipeline facing I/O
    .addr_even(addr_even),
    .addr_odd(addr_odd),

    .hit_even(hit_even),
    .hit_odd(hit_odd),

    .cl_even(cl_even),
    .cl_odd(cl_odd),

    .addr_out_even(addr_out_even),
    .addr_out_odd(addr_out_odd),

    .is_write_even(is_write_even),
    .is_write_odd(is_write_odd),

    .stall(stall),
    .exception(exception),
    //TODO: VERIFY THAT CHANGING VAR NAMES DOESN"T MESS stuff up
    //  src_dir_2_all_even
    // dest_dir_2_all_even
    // addr_dir_2_all_even
    // data_dir_2_all_even
    // ODD SIDE INPUTS
    // EVEN SIDE INPUTS FROM MEM
    .addr_in_ic_data_q_even(addr_dir_2_all_even),
    .data_in_ic_data_q_even(data_dir_2_all_even),
    .operation_in_ic_data_q_even(dir_2_ic_operation_data_q_even),
    .is_flush_in_ic_data_q_even(dir_2_ic_is_flush_data_q_even),
    .alloc_in_ic_data_q_even(dir_2_ic_valid_data_q_even),
    .src_in_ic_data_q_even(src_dir_2_all_even),
    .dest_in_ic_data_q_even(dest_dir_2_all_even),
    
    .full_out_ic_data_q_even(),

    .addr_in_ic_instr_q_even(addr_dir_2_all_even),
    .operation_in_ic_instr_q_even(dir_2_ic_operation_instr_q_even),
    .is_flush_in_ic_instr_q_even(dir_2_ic_is_flush_instr_q_even),
    .alloc_in_ic_instr_q_even(dir_2_ic_valid_instr_q_even),
    .src_in_ic_instr_q_even(src_dir_2_all_even),
    .dest_in_ic_instr_q_even(dest_dir_2_all_even),
    .full_out_ic_instr_q_even(),

    //  src_dir_2_all_odd
    // dest_dir_2_all_odd
    // addr_dir_2_all_odd
    // data_dir_2_all_odd
    // ODD SIDE INPUTS FROM MEM
    .addr_in_ic_data_q_odd(dir_2_ic_addr_data_q_odd),
    .data_in_ic_data_q_odd(data_dir_2_all_odd),
    .operation_in_ic_data_q_odd(dir_2_ic_operation_data_q_odd),
    .is_flush_in_ic_data_q_odd(dir_2_ic_is_flush_data_q_odd),
    .alloc_in_ic_data_q_odd(dir_2_ic_valid_data_q_odd),
    .src_in_ic_data_q_odd(src_dir_2_all_odd),
    .dest_in_ic_data_q_odd(dest_dir_2_all_odd),
    .full_out_ic_data_q_odd(),

    .addr_in_ic_instr_q_odd(addr_dir_2_all_odd),
    .operation_in_ic_instr_q_odd(dir_2_ic_operation_instr_q_odd),
    .is_flush_in_ic_instr_q_odd(dir_2_ic_is_flush_instr_q_odd),
    .alloc_in_ic_instr_q_odd(dir_2_ic_valid_instr_q_odd),
    .src_in_ic_instr_q_odd(src_dir_2_all_odd),
    .dest_in_ic_instr_q_odd(dest_dir_2_all_odd),

    .full_out_ic_instr_q_odd(),

    // EVEN SIDE OUTPUTS TO MEM
    .addr_out_ic_data_q_even(ic_2_dir_addr_data_q_even),
    .data_out_ic_data_q_even(ic_2_dir_data_data_q_even),
    .operation_out_ic_data_q_even(ic_2_dir_operation_data_q_even),
    .is_flush_out_ic_data_q_even(ic_2_dir_is_flush_data_q_even),
    .alloc_out_ic_data_q_even(ic_2_dir_valid_data_q_even),
    .src_out_ic_data_q_even(ic_2_dir_src_data_q_even),
    .dest_out_ic_data_q_even(ic_2_dir_dest_data_q_even),

    .full_in_ic_data_q_even(1'b0),

    .addr_out_ic_instr_q_even(ic_2_dir_addr_instr_q_even),
    .operation_out_ic_instr_q_even(ic_2_dir_operation_instr_q_even),
    .is_flush_out_ic_instr_q_even(ic_2_dir_is_flush_instr_q_even),
    .alloc_out_ic_instr_q_even(ic_2_dir_valid_instr_q_even),
    .src_out_ic_instr_q_even(ic_2_dir_src_instr_q_even),
    .dest_out_ic_instr_q_even(ic_2_dir_dest_instr_q_even),
    
    .full_in_ic_instr_q_even(1'b0),

    // ODD SIDE OUTPUTS TO MEM
    .addr_out_ic_data_q_odd(ic_2_dir_addr_data_q_odd),
    .data_out_ic_data_q_odd(ic_2_dir_data_data_q_odd),
    .operation_out_ic_data_q_odd(ic_2_dir_operation_data_q_odd),
    .is_flush_out_ic_data_q_odd(ic_2_dir_is_flush_data_q_odd),
    .alloc_out_ic_data_q_odd(ic_2_dir_valid_data_q_odd),
    .src_out_ic_data_q_odd(ic_2_dir_src_data_q_odd),
    .dest_out_ic_data_q_odd(ic_2_dir_dest_data_q_odd),

    .full_in_ic_data_q_odd(1'b0),

    .addr_out_ic_instr_q_odd(ic_2_dir_addr_instr_q_odd),
    .operation_out_ic_instr_q_odd(ic_2_dir_operation_instr_q_odd),
    .is_flush_out_ic_instr_q_odd(ic_2_dir_is_flush_instr_q_odd),
    .alloc_out_ic_instr_q_odd(ic_2_dir_valid_instr_q_odd),
    .src_out_ic_instr_q_odd(ic_2_dir_src_instr_q_odd),
    .dest_out_ic_instr_q_odd(ic_2_dir_dest_instr_q_odd),

    .full_in_ic_instr_q_odd(1'b0)
);


endmodule