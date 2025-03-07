module directory_bank #(parameter DATA_SIZE = 4, CL_SIZE = 128, IDX_CNT = 512, TAG_SIZE = 18, NAME = 1) (
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
assign parity_in = addr_in[32-IDX_ROW-TAG_SIZE+1:32-IDX_ROW-TAG_SIZE-1];
assign idx_in = addr_in[32-1-TAG_SIZE:32-IDX_ROW-TAG_SIZE];
assign tag_in = addr_in[31:32-TAG_SIZE];

assign offset_buf = addr_buffer[32-IDX_ROW-TAG_SIZE-1:0];
assign parity_buf = addr_buffer[32-IDX_ROW-TAG_SIZE+1:32-IDX_ROW-TAG_SIZE - 1];
assign idx_buf = addr_buffer[32-1-TAG_SIZE:32-IDX_ROW-TAG_SIZE];
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
wire[3:0] current_state;
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
    .data_next_state(data_lines_new),
    .current_state(current_state)
);

directory_gen_request #( .CL_SIZE(CL_SIZE), .NAME(NAME)) dgr(
    .clk(clk),
    .rst(rst),

    .current_state(current_state),
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

reg [8*6:1] opcode_names [0:7]; // Each string is max 6 chars long
reg [8*6:1] dir_opcode_names [0:7]; // Each string is max 6 chars long
reg [8*6:1] state_names[0:3];
reg [8*6:1] src_names[0:3];
reg [8*6:1] size_names[0:3];
integer file;
  integer count = 0;
initial begin
    if(NAME == 1) begin
        file = $fopen("DIR_BANK_EVEN.csv", "w");
    end
    if(NAME == 2) begin
        file = $fopen("DIR_BANK_ODD.csv", "w");
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
    
    $fdisplay(file, "Time,Cycle,Address_Buffer, Operation_Buffer,Data_Buffer, Index_buffer, Tag_Buffer, Offset_buffer, Tag_Old, Tag_New, Data_Old, Data_New, mem_inst_q_alloc, mem_inst_q_op, mem_data_q_alloc, mem_data_q_op, ic_inst_q_alloc, ic_inst_q_op, ic_data_q_alloc, ic_data_q_op,dc_inst_q_alloc, dc_inst_q_op, dc_data_q_alloc, dc_data_q_op,"); // Write header
  end
  localparam META_SIZE = 8;
//  MSHR_Alloc
  always @(posedge clk) begin
    if (rst) begin
      count <= 0;  // Reset count on reset
    end else begin
      count <= count + 1; // Increment count
      #1
      if(operation_buffer != 0 ) begin 
        $fdisplay(file, "%t,%d,32'h%h ,%s,128'h%h ,9'h%h ,18'h%h ,4'h%h ,18'h%h_18'h%h_18'h%h_18'h%h_18'h%h_18'h%h_18'h%h_18'h%h ,18'h%h_18'h%h_18'h%h_18'h%h_18'h%h_18'h%h_18'h%h_18'h%h,4'h%h_4'h%h_4'h%h_4'h%h_4'h%h_4'h%h_4'h%h_4'h%h,4'h%h_4'h%h_4'h%h_4'h%h_4'h%h_4'h%h_4'h%h_4'h%h,1'h%h, %s,1'h%h, %s,1'h%h, %s,1'h%h, %s,1'h%h, %s,1'h%h, %s, %s, %s, 32'h%h, 128'h%h", 
        $time, count, addr_buffer, dir_opcode_names[operation_buffer], data_buffer, 
        idx_buf, tag_buf, offset_buf, 
        tag_lines_old[TAG_SIZE*8-1:TAG_SIZE*7],tag_lines_old[TAG_SIZE*7-1:TAG_SIZE*6],tag_lines_old[TAG_SIZE*6-1:TAG_SIZE*5],tag_lines_old[TAG_SIZE*5-1:TAG_SIZE*4],tag_lines_old[TAG_SIZE*4-1:TAG_SIZE*3],tag_lines_old[TAG_SIZE*3-1:TAG_SIZE*2],tag_lines_old[TAG_SIZE*2-1:TAG_SIZE*1],tag_lines_old[TAG_SIZE*1-1:TAG_SIZE*0], 
        tag_lines_new[TAG_SIZE*8-1:TAG_SIZE*7],tag_lines_new[TAG_SIZE*7-1:TAG_SIZE*6],tag_lines_new[TAG_SIZE*6-1:TAG_SIZE*5],tag_lines_new[TAG_SIZE*5-1:TAG_SIZE*4],tag_lines_new[TAG_SIZE*4-1:TAG_SIZE*3],tag_lines_new[TAG_SIZE*3-1:TAG_SIZE*2],tag_lines_new[TAG_SIZE*2-1:TAG_SIZE*1],tag_lines_new[TAG_SIZE*1-1:TAG_SIZE*0], 
        data_lines_old[4*8-1:4*7],data_lines_old[4*7-1:4*6],data_lines_old[4*6-1:4*5],data_lines_old[4*5-1:4*4],data_lines_old[4*4-1:4*3],data_lines_old[4*3-1:4*2],data_lines_old[4*2-1:4*1],data_lines_old[4*1-1:4*0], 
        data_lines_new[4*8-1:4*7],data_lines_new[4*7-1:4*6],data_lines_new[4*6-1:4*5],data_lines_new[4*5-1:4*4],data_lines_new[4*4-1:4*3],data_lines_new[4*3-1:4*2],data_lines_new[4*2-1:4*1],data_lines_new[4*1-1:4*0], 
        mem_instr_q_operation, opcode_names[mem_instr_q_operation], mem_data_q_alloc, opcode_names[mem_data_q_operation], ic_inst_q_alloc, opcode_names[ic_inst_q_operation],ic_data_q_alloc, opcode_names[ic_data_q_operation],  dc_inst_q_alloc, opcode_names[dc_inst_q_operation],dc_data_q_alloc, opcode_names[dc_data_q_operation], src_names[src_out], src_names[dest_out], addr_out, data_out
        );
    end 
    end
  end

endmodule