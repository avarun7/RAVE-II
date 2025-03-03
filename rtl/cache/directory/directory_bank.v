module directory_bank #(parameter DATA_SIZE = 4, CL_SIZE = 128, IDX_CNT = 512, TAG_SIZE = 18) (
    input clk,
    input rst,

    input [31:0] addr_in,
    input [CL_SIZE-1:0] data_in,
    input [2:0] operation_in,
    input [1:0] src_in,
    input [1:0] dest_in,

    output  mem_instr_q_alloc,
    output  [2:0] mem_instr_q_operation,

    output  mem_data_q_alloc,
    output [2:0] mem_data_q_operation,
    
    output  ic_inst_q_alloc,
    output  [2:0] ic_inst_q_operation,

    output  ic_data_q_alloc,
    output  [2:0] ic_data_q_operation,

    output  dc_inst_q_alloc,
    output  [2:0] dc_inst_q_operation,

    output  dc_data_q_alloc,
    output  [2:0] dc_data_q_operation,

    output [1:0] src_out,
    output [1:0] dest_out,
    output [31:0] addr_out,
    output [CL_SIZE-1:0] data_out
);
localparam IDX_ROW = $clog2(IDX_CNT);

wire st_fwd, valid_operation_in;
reg [31:0] addr_buffer;
reg[CL_SIZE-1:0] data_buffer;
reg [2:0] operation_buffer;
reg [1:0] src_buffer, dest_buffer;

wire[TAG_SIZE-1:0] tag_in, tag_buf;
wire[IDX_ROW-1:0] idx_in, idx_buf;
wire[32-IDX_ROW-TAG_SIZE-2:0] offset_in, offset_buf;
wire parity_in, parity_buf;

assign src_out = src_buffer;
assign dest_out = dest_buffer;
assign addr_out = addr_buffer;
assign data_out = data_buffer;

assign offset_in = addr_in[32-IDX_ROW-TAG_SIZE-1:0];
assign parity_in = addr_in[32-IDX_ROW-TAG_SIZE+1:32-IDX_ROW-TAG_SIZE];
assign idx_in = addr_in[32-1-TAG_SIZE:32-IDX_ROW-TAG_SIZE+2];
assign tag_in = addr_in[31:32-TAG_SIZE];

assign offset_buf = addr_buffer[32-IDX_ROW-TAG_SIZE-1:0];
assign parity_buf = addr_buffer[32-IDX_ROW-TAG_SIZE+1:32-IDX_ROW-TAG_SIZE];
assign idx_buf = addr_buffer[32-1-TAG_SIZE:32-IDX_ROW-TAG_SIZE+2];
assign tag_buf = addr_buffer[31:32-TAG_SIZE];

assign valid_operation_buffer = |operation_buffer;
assign valid_operation_in = |operation_in;
assign st_fwd = (addr_in[31:4] == addr_buffer[31:4]) && valid_operation_in;


always @(posedge clk) begin
    if(rst) begin
        addr_buffer <= 32'hFFFF_FFFF;
        data_buffer <= 0;
        operation_buffer <= 0;
        dest_buffer <= 0;
        src_buffer <= 0;
    end
    else if (valid_operation_in) begin
        addr_buffer <= addr_in;
        data_buffer <= data_in;
        operation_buffer <= operation_in;
        src_buffer <= src_in;
        dest_buffer <= dest_in;
    end
    else begin
        operation_buffer <= 0;
    end
end
wire[DATA_SIZE*8-1:0] data_lines_old, data_lines_new;

directory_data_store #(.CL_SIZE(DATA_SIZE),  .IDX_CNT(IDX_CNT)) dds(
    .clk(clk),
    .rst(rst),

    //initial read
    .operation(operation_in),
    .idx(idx_in),

    //writeback
    .cl_in_wb(data_lines_new),
    .idx_in_wb(idx_buf),
    .alloc(valid_operation_buffer),
    .st_fwd(st_fwd),

    //initial read out
    .cl_lines_out(data_lines_old)  
);
wire[TAG_SIZE*8-1:0] tag_lines_old, tag_lines_new;

directory_tag_store #( .TAG_SIZE(TAG_SIZE),  .IDX_CNT(IDX_CNT)) dts(
    .clk(clk),
    .rst(rst),

    //initial read
    .operation(operation_in),
    .idx(idx_in),
    .tag_in_rd(tag_in),

    //writeback
    .tag_in_wb(tag_lines_new),
    .idx_in_wb(idx_buf),
    .alloc(valid_operation_buffer),
    .st_fwd(st_fwd),

    //initial read out
    .tag_lines_out(tag_lines_old) 
);

directory_select_way #(.CL_SIZE(DATA_SIZE), .TAG_SIZE(TAG_SIZE)) dsw(
    .clk(clk),
    .rst(rst),

    .tag_in(tag_buf),
    .tag_cur_state(tag_lines_old),
    .data_cur_state(data_lines_old),

    .operation(operation_buffer),
    .src(src_buffer),
    .dest(dest_buffer),

    .tag_next_state(tag_lines_new),
    .data_next_state(data_lines_new)
);

directory_gen_request #( .CL_SIZE(CL_SIZE)) dgr(
    .clk(clk),
    .rst(rst),

    .current_state(data_lines_new),
    .operation(operation_buffer),
    .source(src_buffer),
    .dest(dest_buffer),

    .mem_instr_q_alloc(mem_instr_q_alloc),
    .mem_instr_q_operation(mem_instr_q_operation),

    .mem_data_q_alloc(mem_data_q_alloc),
    .mem_data_q_operation(mem_data_q_operation),
    
    .ic_inst_q_alloc(ic_inst_q_alloc),
    .ic_inst_q_operation(ic_inst_q_operation),

    .ic_data_q_alloc(ic_data_q_alloc),
    .ic_data_q_operation(ic_data_q_operation),

    .dc_inst_q_alloc(dc_inst_q_alloc),
    .dc_inst_q_operation(dc_inst_q_operation),

    .dc_data_q_alloc(dc_data_q_alloc),
    .dc_data_q_operation(dc_data_q_operation)
);

endmodule