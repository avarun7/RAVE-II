module dram_top #(parameter CL_SIZE = 128) (
    input clk,
    input rst,

    // I/O FROM INPUT QUEUES
    
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
    
    //ODD SIDE
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

    // I/O to OUTPUT QUEUES

    //EVEN SIDE
    //MEM_DATA_Q_out
    output [31:0] addr_out_mem_data_q_even,
    output [CL_SIZE-1:0] data_out_mem_data_q_even,
    output [2:0] operation_out_mem_data_q_even,
    output is_flush_out_mem_data_q_even,
    output alloc_out_mem_data_q_even,
    output [1:0] src_out_mem_data_q_even,
    output [1:0] dest_out_mem_data_q_even,

    input full_in_mem_data_q_even,

    //ODD SIDE
    //MEM_DATA_Q_out
    output [31:0] addr_out_mem_data_q_odd,
    output  [CL_SIZE-1:0] data_out_mem_data_q_odd,
    output  [2:0] operation_out_mem_data_q_odd,
    output  is_flush_out_mem_data_q_odd,
    output  alloc_out_mem_data_q_odd,
    output  [1:0] src_out_mem_data_q_odd,
    output  [1:0] dest_out_mem_data_q_odd,

    input full_in_mem_data_q_odd
);

       //MEM_DATA_Q_in
wire [31:0] bank_addr_in_mem_data_q_even;
wire  [CL_SIZE-1:0] bank_data_in_mem_data_q_even;
wire  [2:0] bank_operation_in_mem_data_q_even;
wire  bank_is_flush_in_mem_data_q_even;
wire  bank_valid_in_mem_data_q_even;
wire  [1:0] bank_src_in_mem_data_q_even;
wire  [1:0] bank_dest_in_mem_data_q_even;

wire [1:0] dealloc_even, dealloc_odd;
    //MEM_INSTR_Q_in
wire [31:0] bank_addr_in_mem_instr_q_even;
wire  [2:0] bank_operation_in_mem_instr_q_even;
wire  bank_is_flush_in_mem_instr_q_even;
wire  bank_valid_in_mem_instr_q_even;
wire  [1:0] bank_src_in_mem_instr_q_even;
wire  [1:0] bank_dest_in_mem_instr_q_even;
wire [CL_SIZE -1 : 0] bank_data_in_even, bank_data_in_odd;

data_q #(.Q_LENGTH(8), .CL_SIZE(CL_SIZE)) mem_data_q_even(
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
    .dealloc(dealloc_even[1]),

    //output sender
    .full(full_out_mem_data_q_even),

    //output reciever
    .addr_out(bank_addr_in_mem_data_q_even),
    .data_out(bank_data_in_mem_data_q_even),
    .operation_out(bank_operation_in_mem_data_q_even),
    .valid(bank_valid_in_mem_data_q_even),
    .src_out(bank_src_in_mem_data_q_even),
    .dest_out(bank_dest_in_mem_data_q_even),
    .is_flush_out(bank_is_flush_in_mem_data_q_even)
);

instr_q  #(.Q_LENGTH(8), .CL_SIZE(CL_SIZE)) mem_instr_q_even(
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
    .dealloc(dealloc_even[0]),

    //output sender
    .full(full_out_mem_instr_q_even),

    //output reciever
    .addr_out(bank_addr_in_mem_instr_q_even),
    .operation_out(bank_operation_in_mem_instr_q_even),
    .valid(bank_valid_in_mem_instr_q_even),
    .src_out(bank_src_in_mem_instr_q_even),
    .dest_out(bank_dest_in_mem_instr_q_even),
    .is_flush_out(bank_is_flush_in_mem_instr_q_even)
);
wire [31:0] bank_addr_in_even;
wire [2:0] bank_operation_in_even;
wire bank_valid_in_even;
// wire [CL_SIZE - 1:0] bank_data_in_even;
wire [1:0] bank_src_in_even;
wire [1:0] bank_dest_in_even;
wire bank_is_flush_in_even;

wire [31:0] bank_addr_in_odd;
wire [2:0] bank_operation_in_odd;
wire bank_valid_in_odd;
// wire [CL_SIZE - 1:0] bank_data_in_odd;
wire [1:0] bank_src_in_odd;
wire [1:0] bank_dest_in_odd;
wire bank_is_flush_in_odd;
queue_arbitrator #(.CL_SIZE(CL_SIZE), .Q_WIDTH(2)) queue_arb_even(
    .addr_in({
        bank_addr_in_mem_data_q_even,
        bank_addr_in_mem_instr_q_even
    }),
    .data_in({
        bank_data_in_mem_data_q_even,
        128'd0
    }),
    .operation_in({
        bank_operation_in_mem_data_q_even,
        bank_operation_in_mem_instr_q_even
    }), 
    .valid_in({
        bank_valid_in_mem_data_q_even,
        bank_valid_in_mem_instr_q_even
    }),
    .src_in({
        bank_src_in_mem_data_q_even,
        bank_src_in_mem_instr_q_even
    }),
    .dest_in({
        bank_dest_in_mem_data_q_even,
        bank_dest_in_mem_instr_q_even
    }),
    .is_flush_in({
        bank_is_flush_in_mem_data_q_even,
        bank_is_flush_in_mem_instr_q_even
    }),
    .stall_in(bank_stall_even),


    .addr_out(      bank_addr_in_even),
    .operation_out( bank_operation_in_even), 
    .valid_out(     bank_valid_in_even),
    .data_out(      bank_data_in_even),
    .src_out(       bank_src_in_even),
    .dest_out(      bank_dest_in_even),
    .is_flush_out(  bank_is_flush_in_even),

    .dealloc(dealloc_even)
);

dram_bank #(.CL_SIZE(CL_SIZE), .file_name(1)) db_even(
.rst(rst),
.clk(clk),

.addr_in(bank_addr_in_even),
.operation_in(bank_operation_in_even),
.valid_in(bank_valid_in_even),
.src_in(bank_src_in_even),
.dest_in(bank_dest_in_even),
.is_flush_in(bank_is_flush_in_even),
.data_in(bank_data_in_even),

.addr_out(addr_out_mem_data_q_even),
.operation_out(operation_out_mem_data_q_even),
.valid_out(alloc_out_mem_data_q_even),
.src_out(src_out_mem_data_q_even),
.dest_out(dest_out_mem_data_q_even),
.is_flush_out(is_flush_out_mem_data_q_even),
.data_out(data_out_mem_data_q_even),

.stall_out(bank_stall_even)
);
      //MEM_DATA_Q_in
wire [31:0] bank_addr_in_mem_data_q_odd;
wire  [CL_SIZE-1:0] bank_data_in_mem_data_q_odd;
wire  [2:0] bank_operation_in_mem_data_q_odd;
wire  bank_is_flush_in_mem_data_q_odd;
wire  bank_valid_in_mem_data_q_odd;
wire  [1:0] bank_src_in_mem_data_q_odd;
wire  [1:0] bank_dest_in_mem_data_q_odd;

    //MEM_INSTR_Q_in
wire [31:0] bank_addr_in_mem_instr_q_odd;
wire  [2:0] bank_operation_in_mem_instr_q_odd;
wire  bank_is_flush_in_mem_instr_q_odd;
wire  bank_valid_in_mem_instr_q_odd;
wire  [1:0] bank_src_in_mem_instr_q_odd;
wire  [1:0] bank_dest_in_mem_instr_q_odd;

data_q #(.Q_LENGTH(8), .CL_SIZE(CL_SIZE)) mem_data_q_odd(
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
    .dealloc(dealloc_odd[1]),

    //output sender
    .full(full_out_mem_data_q_odd),

    //output reciever
    .addr_out(bank_addr_in_mem_data_q_odd),
    .data_out(bank_data_in_mem_data_q_odd),
    .operation_out(bank_operation_in_mem_data_q_odd),
    .valid(bank_valid_in_mem_data_q_odd),
    .src_out(bank_src_in_mem_data_q_odd),
    .dest_out(bank_dest_in_mem_data_q_odd),
    .is_flush_out(bank_is_flush_in_mem_data_q_odd)
);

instr_q  #(.Q_LENGTH(8), .CL_SIZE(CL_SIZE)) mem_instr_q_odd(
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
    .dealloc(dealloc_odd[0]),

    //output sender
    .full(full_out_mem_instr_q_odd),

    //output reciever
    .addr_out(bank_addr_in_mem_instr_q_odd),
    .operation_out(bank_operation_in_mem_instr_q_odd),
    .valid(bank_valid_in_mem_instr_q_odd),
    .src_out(bank_src_in_mem_instr_q_odd),
    .dest_out(bank_dest_in_mem_instr_q_odd),
    .is_flush_out(bank_is_flush_in_mem_instr_q_odd)
);
queue_arbitrator #(.CL_SIZE(CL_SIZE), .Q_WIDTH(2)) queue_arb_odd(
    .addr_in({
        bank_addr_in_mem_data_q_odd,
        bank_addr_in_mem_instr_q_odd
    }),
    .data_in({
        bank_data_in_mem_data_q_odd,
        128'd0
    }),
    .operation_in({
        bank_operation_in_mem_data_q_odd,
        bank_operation_in_mem_instr_q_odd
    }), 
    .valid_in({
        bank_valid_in_mem_data_q_odd,
        bank_valid_in_mem_instr_q_odd
    }),
    .src_in({
        bank_src_in_mem_data_q_odd,
        bank_src_in_mem_instr_q_odd
    }),
    .dest_in({
        bank_dest_in_mem_data_q_odd,
        bank_dest_in_mem_instr_q_odd
    }),
    .is_flush_in({
        bank_is_flush_in_mem_data_q_odd,
        bank_is_flush_in_mem_instr_q_odd
    }),

    .stall_in(bank_stall_odd),

    .addr_out(bank_addr_in_odd),
    .operation_out(bank_operation_in_odd), 
    .valid_out(bank_valid_in_odd),
    .data_out(bank_data_in_odd),
    .src_out(bank_src_in_odd),
    .dest_out(bank_dest_in_odd),
    .is_flush_out(bank_is_flush_in_odd),

    .dealloc(dealloc_odd)
);

dram_bank #(.CL_SIZE(128), .file_name(2)) db_odd(
.rst(rst),
.clk(clk),

.addr_in(bank_addr_in_odd),
.operation_in(bank_operation_in_odd),
.valid_in(bank_valid_in_odd),
.src_in(bank_src_in_odd),
.dest_in(bank_dest_in_odd),
.is_flush_in(bank_is_flush_in_odd),
.data_in(bank_data_in_odd),

.addr_out(addr_out_mem_data_q_odd),
.operation_out(operation_out_mem_data_q_odd),
.valid_out(alloc_out_mem_data_q_odd),
.src_out(src_out_mem_data_q_odd),
.dest_out(dest_out_mem_data_q_odd),
.is_flush_out(is_flush_out_mem_data_q_odd),
.data_out(data_out_mem_data_q_odd),

.stall_out(bank_stall_odd)
);


integer file;
  integer count = 0;
initial begin
    file = $fopen("MEM_FINAL.csv", "w");
    if (file == 0) begin
      $display("Error: Unable to open file.");
      $stop;
    end
    $fdisplay(file, "Little Endian - Smallest address on the right, largest address left\n");

    // #400
    
  end


endmodule