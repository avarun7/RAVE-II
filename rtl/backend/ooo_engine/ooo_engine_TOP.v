module ooo_engine_TOP#(parameter XLEN=32,PHYS_REG_SIZE=256, ROB_SIZE=256, UOP_SIZE=16 ,RSV_SIZE=16)(
    input clk, rst, valid_in,

    input[2:0]                               mapper_to_ring_functional_unit_num,
    input[$clog2(ROB_SIZE)-1:0]              mapper_to_ring_rob_entry,
    input[$clog2(PHYS_REG_SIZE)-1:0]         mapper_to_ring_uop_rs1_reg,
    input                                    mapper_to_ring_uop_rs1_received,
    input[XLEN-1:0]                          mapper_to_ring_uop_rs1_value,
    input[XLEN-1:0]                          mapper_to_ring_uop_pc_in,
    input[$clog2(UOP_SIZE)-1:0]               mapper_to_ring_uop_uop_encoding,
    input[XLEN-1:0]                          mapper_to_ring_uop_rs2_value,
    input                                    mapper_to_ring_uop_rs2_received,
    input[$clog2(PHYS_REG_SIZE)-1:0]         mapper_to_ring_uop_rs2_reg,
    input[$clog2(PHYS_REG_SIZE)-1:0]         mapper_to_ring_dest_reg,

    output                                   out_reg_file_valid,
    output[$clog2(PHYS_REG_SIZE)-1:0]         out_reg_file_update_reg,
    output[XLEN-1:0]                          out_reg_file_update_val,
    output[$clog2(ROB_SIZE)-1:0]             out_reg_file_rob_entry,

    output                                   out_rob_valid,
    output[$clog2(PHYS_REG_SIZE)-1:0]        out_rob_update_reg,
    output[XLEN-1:0]                         out_rob_update_val,
    output[$clog2(ROB_SIZE)-1:0]             out_rob_rob_entry

);

wire[$clog2(PHYS_REG_SIZE)-1:0]    ring_to_logical_rs1_reg;
wire[$clog2(ROB_SIZE)-1:0]         ring_to_logical_rob_entry;
wire                               ring_to_logical_rs1_received;
wire[XLEN-1:0]                     ring_to_logical_rs1_value;
wire[XLEN-1:0]                     ring_to_logical_pc;
wire[$clog2(UOP_SIZE)-1:0]         ring_to_logical_uop_encoding;
wire[XLEN-1:0]                     ring_to_logical_rs2_value;
wire                               ring_to_logical_rs2_received;
wire[$clog2(PHYS_REG_SIZE)-1:0]    ring_to_logical_rs2_reg;
wire                               ring_to_logical_valid;  
wire[$clog2(PHYS_REG_SIZE)-1:0]    ring_to_logical_dest_reg;

wire[$clog2(PHYS_REG_SIZE)-1:0]    ring_to_arithmetic_rs1_reg;
wire[$clog2(ROB_SIZE)-1:0]         ring_to_arithmetic_rob_entry;
wire                               ring_to_arithmetic_rs1_received;
wire[XLEN-1:0]                     ring_to_arithmetic_rs1_value;
wire[XLEN-1:0]                     ring_to_arithmetic_pc;
wire[$clog2(UOP_SIZE)-1:0]          ring_to_arithmetic_uop_encoding;
wire[XLEN-1:0]                     ring_to_arithmetic_rs2_value;
wire                               ring_to_arithmetic_rs2_received;
wire[$clog2(PHYS_REG_SIZE)-1:0]    ring_to_arithmetic_rs2_reg;
wire                               ring_to_arithmetic_valid;  
wire[$clog2(PHYS_REG_SIZE)-1:0]    ring_to_arithmetic_dest_reg;

wire[$clog2(PHYS_REG_SIZE)-1:0]    ring_to_branch_rs1_reg;
wire[$clog2(ROB_SIZE)-1:0]         ring_to_branch_rob_entry;
wire                               ring_to_branch_rs1_received;
wire[XLEN-1:0]                     ring_to_branch_rs1_value;
wire[XLEN-1:0]                     ring_to_branch_pc;
wire[$clog2(UOP_SIZE)-1:0]          ring_to_branch_uop_encoding;
wire[XLEN-1:0]                     ring_to_branch_rs2_value;
wire                               ring_to_branch_rs2_received;
wire[$clog2(PHYS_REG_SIZE)-1:0]    ring_to_branch_rs2_reg;
wire                               ring_to_branch_valid;  
wire[$clog2(PHYS_REG_SIZE)-1:0]    ring_to_branch_dest_reg;

wire[$clog2(PHYS_REG_SIZE)-1:0]    ring_to_mul_div_rs1_reg;
wire[$clog2(ROB_SIZE)-1:0]         ring_to_mul_div_rob_entry;
wire                               ring_to_mul_div_rs1_received;
wire[XLEN-1:0]                     ring_to_mul_div_rs1_value;
wire[XLEN-1:0]                     ring_to_mul_div_pc;
wire[$clog2(UOP_SIZE)-1:0]          ring_to_mul_div_uop_encoding;
wire[XLEN-1:0]                     ring_to_mul_div_rs2_value;
wire                               ring_to_mul_div_rs2_received;
wire[$clog2(PHYS_REG_SIZE)-1:0]    ring_to_mul_div_rs2_reg;
wire                               ring_to_mul_div_valid;  
wire[$clog2(PHYS_REG_SIZE)-1:0]    ring_to_mul_div_dest_reg;

wire[$clog2(PHYS_REG_SIZE)-1:0]    ring_to_ld_st_rs1_reg;
wire[$clog2(ROB_SIZE)-1:0]         ring_to_ld_st_rob_entry;
wire                               ring_to_ld_st_rs1_received;
wire[XLEN-1:0]                     ring_to_ld_st_rs1_value;
wire[XLEN-1:0]                     ring_to_ld_st_pc;
wire[$clog2(UOP_SIZE)-1:0]         ring_to_ld_st_uop_encoding;
wire[XLEN-1:0]                     ring_to_ld_st_rs2_value;
wire                               ring_to_ld_st_rs2_received;
wire[$clog2(PHYS_REG_SIZE)-1:0]    ring_to_ld_st_rs2_reg;
wire                               ring_to_ld_st_valid;  
wire[$clog2(PHYS_REG_SIZE)-1:0]    ring_to_ld_st_dest_reg;

wire                              update_logical_valid;
wire[$clog2(PHYS_REG_SIZE)-1:0]   update_logical_update_reg;
wire[XLEN-1:0]                    update_logical_update_val;

wire                              update_arithmetic_valid;
wire[$clog2(PHYS_REG_SIZE)-1:0]   update_arithmetic_update_reg;
wire[XLEN-1:0]                    update_arithmetic_update_val; 

wire                              update_branch_valid;
wire[$clog2(PHYS_REG_SIZE)-1:0]   update_branch_update_reg;
wire[XLEN-1:0]                    update_branch_update_val;

wire                              update_ld_st_valid;
wire[$clog2(PHYS_REG_SIZE)-1:0]   update_ld_st_update_reg;
wire[XLEN-1:0]                    update_ld_st_update_val;

wire                              update_mul_div_valid;
wire[$clog2(PHYS_REG_SIZE)-1:0]   update_mul_div_update_reg;
wire[XLEN-1:0]                    update_mul_div_update_val;

ring_rsvs #(.XLEN(XLEN), .PHYS_REG_SIZE(PHYS_REG_SIZE), .ROB_SIZE(ROB_SIZE), .UOP_SIZE(UOP_SIZE)) ring_mapper_to_rsvs(
    .clk(clk), .rst(rst), .valid_in(valid_in),

    .functional_unit_num(mapper_to_ring_functional_unit_num),
    .rob_entry(mapper_to_ring_rob_entry),
    .uop_rs1_reg(mapper_to_ring_uop_rs1_reg),
    .uop_rs1_received(mapper_to_ring_uop_rs1_received),
    .uop_rs1_value(mapper_to_ring_uop_rs1_value),
    .uop_pc_in(mapper_to_ring_uop_pc_in),
    .uop_uop_encoding(mapper_to_ring_uop_uop_encoding),
    .uop_rs2_value(mapper_to_ring_uop_rs2_value),
    .uop_rs2_received(mapper_to_ring_uop_rs2_received),
    .uop_rs2_reg(mapper_to_ring_uop_rs2_reg),
    .uop_dest_reg(mapper_to_ring_dest_reg),
/***********************************************************************/
    .logical_rs1_reg(ring_to_logical_rs1_reg),
    .logical_rob_entry(ring_to_logical_rob_entry),
    .logical_rs1_received(ring_to_logical_rs1_received),
    .logical_rs1_value(ring_to_logical_rs1_value),
    .logical_pc(ring_to_logical_pc),
    .logical_uop_encoding(ring_to_logical_uop_encoding),
    .logical_rs2_value(ring_to_logical_rs2_value),
    .logical_rs2_received(ring_to_logical_rs2_received),
    .logical_rs2_reg(ring_to_logical_rs2_reg),
    .logical_dest_reg(ring_to_logical_dest_reg),
    .logical_valid_out(ring_to_logical_valid),
    
    .arithmetic_rs1_reg(ring_to_arithmetic_rs1_reg),
    .arithmetic_rob_entry(ring_to_arithmetic_rob_entry),
    .arithmetic_rs1_received(ring_to_arithmetic_rs1_received),
    .arithmetic_rs1_value(ring_to_arithmetic_rs1_value),
    .arithmetic_pc(ring_to_arithmetic_pc),
    .arithmetic_uop_encoding(ring_to_arithmetic_uop_encoding),
    .arithmetic_rs2_value(ring_to_arithmetic_rs2_value),
    .arithmetic_rs2_received(ring_to_arithmetic_rs2_received),
    .arithmetic_rs2_reg(ring_to_arithmetic_rs2_reg),
    .arithmetic_dest_reg(ring_to_arithmetic_dest_reg),
    .arithmetic_valid_out(ring_to_arithmetic_valid),

    .branch_rs1_reg(ring_to_branch_rs1_reg),
    .branch_rob_entry(ring_to_branch_rob_entry),
    .branch_rs1_received(ring_to_branch_rs1_received),
    .branch_rs1_value(ring_to_branch_rs1_value),
    .branch_pc(ring_to_branch_pc),
    .branch_uop_encoding(ring_to_branch_uop_encoding),
    .branch_rs2_value(ring_to_branch_rs2_value),
    .branch_rs2_received(ring_to_branch_rs2_received),
    .branch_rs2_reg(ring_to_branch_rs2_reg),
    .branch_dest_reg(ring_to_branch_dest_reg),
    .branch_valid_out(ring_to_branch_valid),


    .mul_div_rs1_reg(ring_to_mul_div_rs1_reg),
    .mul_div_rob_entry(ring_to_mul_div_rob_entry),
    .mul_div_rs1_received(ring_to_mul_div_rs1_received),
    .mul_div_rs1_value(ring_to_mul_div_rs1_value),
    .mul_div_pc(ring_to_mul_div_pc),
    .mul_div_uop_encoding(ring_to_mul_div_uop_encoding),
    .mul_div_rs2_value(ring_to_mul_div_rs2_value),
    .mul_div_rs2_received(ring_to_mul_div_rs2_received),
    .mul_div_rs2_reg(ring_to_mul_div_rs2_reg),
    .mul_div_dest_reg(ring_to_mul_div_dest_reg),
    .mul_div_valid_out(ring_to_mul_div_valid),

    .ld_st_rs1_reg(ring_to_ld_st_rs1_reg),
    .ld_st_rob_entry(ring_to_ld_st_rob_entry),
    .ld_st_rs1_received(ring_to_ld_st_rs1_received),
    .ld_st_rs1_value(ring_to_ld_st_rs1_value),
    .ld_st_pc(ring_to_ld_st_pc),
    .ld_st_uop_encoding(ring_to_ld_st_uop_encoding),
    .ld_st_rs2_value(ring_to_ld_st_rs2_value),
    .ld_st_rs2_received(ring_to_ld_st_rs2_received),
    .ld_st_rs2_reg(ring_to_ld_st_rs2_reg),
    .ld_st_dest_reg(ring_to_ld_st_dest_reg),
    .ld_st_valid_out(ring_to_ld_st_valid)
);

wire[$clog2(ROB_SIZE)-1:0]      logical_rsv_to_fu_rob_entry;
wire[XLEN-1:0]                  logical_rsv_to_fu_rs1;
wire[XLEN-1:0]                  logical_rsv_to_fu_rs2;
wire[XLEN-1:0]                  logical_rsv_to_fu_pc;
wire[$clog2(UOP_SIZE)-1:0]       logical_rsv_to_fu_uop_encoding;
wire[$clog2(PHYS_REG_SIZE)-1:0] logical_rsv_to_fu_dest_reg;
wire                            logical_rsv_to_fu_valid_out;

rsv #(.XLEN(XLEN), .PHYS_REG_SIZE(PHYS_REG_SIZE), .ROB_SIZE(ROB_SIZE), .UOP_SIZE(UOP_SIZE)) logical_rsv(
    .clk(clk), .rst(rst), .valid_in(ring_to_logical_valid),

    .rob_entry_in(ring_to_logical_rob_entry),
    .rs1_reg(ring_to_logical_rs1_reg),
    .rs1_received(ring_to_logical_rs1_received),
    .rs1_value(ring_to_logical_rs1_value),
    .pc_in(ring_to_logical_pc),
    .uop_encoding_in(ring_to_logical_uop_encoding),
    .rs2_value(ring_to_logical_rs2_value),
    .rs2_received(ring_to_logical_rs2_received),
    .rs2_reg(ring_to_logical_rs2_reg),
    .dest_reg_in(ring_to_logical_dest_reg),

    .update_valid(update_logical_valid),
    .update_reg(update_logical_update_reg),
    .update_val(update_logical_update_val),

    .rob_entry(logical_rsv_to_fu_rob_entry),
    .rs1(logical_rsv_to_fu_rs1),
    .rs2(logical_rsv_to_fu_rs2),
    .pc(logical_rsv_to_fu_pc),
    .uop_encoding(logical_rsv_to_fu_uop_encoding),
    .valid_out(logical_rsv_to_fu_valid_out),
    .dest_reg(logical_rsv_to_fu_dest_reg)
);

wire[XLEN - 1:0]                logical_fu_to_ring_result;
wire                            logical_fu_to_ring_valid_out;
wire[$clog2(ROB_SIZE)-1:0]      logical_fu_to_ring_rob_entry;
wire[$clog2(PHYS_REG_SIZE)-1:0] logical_fu_to_ring_dest_reg;


logical_FU#(.XLEN(XLEN), .ROB_SIZE(ROB_SIZE), .UOP_SIZE(UOP_SIZE), .PHYS_REG_SIZE(PHYS_REG_SIZE)) log_fu(
    .clk(clk), .rst(rst), .valid_in(logical_rsv_to_fu_valid_out),
    
    .rob_entry_in(logical_rsv_to_fu_rob_entry),
    .uop(logical_rsv_to_fu_uop_encoding),
    .rs1(logical_rsv_to_fu_rs1),
    .rs2(logical_rsv_to_fu_rs2),
    .dest_reg_in(logical_rsv_to_fu_dest_reg),
    .pc(logical_rsv_to_fu_pc),

    .result(logical_fu_to_ring_result),
    .valid_out(logical_fu_to_ring_valid_out),
    .rob_entry(logical_fu_to_ring_rob_entry)

);


wire[$clog2(ROB_SIZE)-1:0]      arithmetic_rsv_to_fu_rob_entry;
wire[XLEN-1:0]                  arithmetic_rsv_to_fu_rs1;
wire[XLEN-1:0]                  arithmetic_rsv_to_fu_rs2;
wire[XLEN-1:0]                  arithmetic_rsv_to_fu_pc;
wire[$clog2(UOP_SIZE)-1:0]       arithmetic_rsv_to_fu_uop_encoding;
wire[$clog2(PHYS_REG_SIZE)-1:0] arithmetic_rsv_to_fu_dest_reg;
wire                            arithmetic_rsv_to_fu_valid_out;

rsv #(.XLEN(XLEN), .PHYS_REG_SIZE(PHYS_REG_SIZE), .ROB_SIZE(ROB_SIZE), .UOP_SIZE(UOP_SIZE)) arithmetic_rsv(
    .clk(clk), .rst(rst), .valid_in(ring_to_arithmetic_valid),

    .rob_entry_in(ring_to_arithmetic_rob_entry),
    .rs1_reg(ring_to_arithmetic_rs1_reg),
    .rs1_received(ring_to_arithmetic_rs1_received),
    .rs1_value(ring_to_arithmetic_rs1_value),
    .pc_in(ring_to_arithmetic_pc),
    .uop_encoding_in(ring_to_arithmetic_uop_encoding),
    .rs2_value(ring_to_arithmetic_rs2_value),
    .rs2_received(ring_to_arithmetic_rs2_received),
    .rs2_reg(ring_to_arithmetic_rs2_reg),
    .dest_reg_in(ring_to_arithmetic_dest_reg),

    .update_valid(update_arithmetic_valid),
    .update_reg(update_arithmetic_update_reg),
    .update_val(update_arithmetic_update_val),

    .rob_entry(arithmetic_rsv_to_fu_rob_entry),
    .rs1(arithmetic_rsv_to_fu_rs1),
    .rs2(arithmetic_rsv_to_fu_rs2),
    .pc(arithmetic_rsv_to_fu_pc),
    .uop_encoding(arithmetic_rsv_to_fu_uop_encoding),
    .valid_out(arithmetic_rsv_to_fu_valid_out),
    .dest_reg(arithmetic_rsv_to_fu_dest_reg)
);

wire[XLEN - 1:0]                arithmetic_fu_to_ring_result;
wire                            arithmetic_fu_to_ring_valid_out;
wire[$clog2(ROB_SIZE)-1:0]      arithmetic_fu_to_ring_rob_entry;
wire[$clog2(PHYS_REG_SIZE)-1:0] arithmetic_fu_to_ring_dest_reg;

arithmetic_FU #(.XLEN(XLEN), .ROB_SIZE(ROB_SIZE), .UOP_SIZE(UOP_SIZE), .PHYS_REG_SIZE(PHYS_REG_SIZE)) arithmetic_fu(
    .clk(clk), .rst(rst), .valid_in(arithmetic_rsv_to_fu_valid_out),
    
    .rob_entry_in(arithmetic_rsv_to_fu_rob_entry),
    .uop(arithmetic_rsv_to_fu_uop_encoding),
    .rs1(arithmetic_rsv_to_fu_rs1),
    .rs2(arithmetic_rsv_to_fu_rs2),
    .dest_reg_in(arithmetic_rsv_to_fu_dest_reg),
    .pc(arithmetic_rsv_to_fu_pc),

    .result(arithmetic_fu_to_ring_result),
    .valid_out(arithmetic_fu_to_ring_valid_out),
    .rob_entry(arithmetic_fu_to_ring_rob_entry),
    .dest_reg(arithmetic_fu_to_ring_dest_reg)

);

wire[$clog2(ROB_SIZE)-1:0]      mul_div_rsv_to_fu_rob_entry;
wire[XLEN-1:0]                  mul_div_rsv_to_fu_rs1;
wire[XLEN-1:0]                  mul_div_rsv_to_fu_rs2;
wire[XLEN-1:0]                  mul_div_rsv_to_fu_pc;
wire[$clog2(UOP_SIZE)-1:0]      mul_div_rsv_to_fu_uop_encoding;
wire[$clog2(PHYS_REG_SIZE)-1:0] mul_div_rsv_to_fu_dest_reg;
wire                            mul_div_rsv_to_fu_valid_out;

rsv #(.XLEN(XLEN), .PHYS_REG_SIZE(PHYS_REG_SIZE), .ROB_SIZE(ROB_SIZE), .UOP_SIZE(UOP_SIZE)) mul_div_rsv(
    .clk(clk), .rst(rst), .valid_in(ring_to_mul_div_valid),

    .rob_entry_in(ring_to_mul_div_rob_entry),
    .rs1_reg(ring_to_mul_div_rs1_reg),
    .rs1_received(ring_to_mul_div_rs1_received),
    .rs1_value(ring_to_mul_div_rs1_value),
    .pc_in(ring_to_mul_div_pc),
    .uop_encoding_in(ring_to_mul_div_uop_encoding),
    .rs2_value(ring_to_mul_div_rs2_value),
    .rs2_received(ring_to_mul_div_rs2_received),
    .rs2_reg(ring_to_mul_div_rs2_reg),
    .dest_reg_in(ring_to_mul_div_dest_reg),

    .update_valid(update_mul_div_valid),
    .update_reg(update_mul_div_update_reg),
    .update_val(update_mul_div_update_val),

    .rob_entry(mul_div_rsv_to_fu_rob_entry),
    .rs1(mul_div_rsv_to_fu_rs1),
    .rs2(mul_div_rsv_to_fu_rs2),
    .pc(mul_div_rsv_to_fu_pc),
    .uop_encoding(mul_div_rsv_to_fu_uop_encoding),
    .valid_out(mul_div_rsv_to_fu_valid_out),
    .dest_reg(mul_div_rsv_to_fu_dest_reg)
);

wire[XLEN - 1:0]                mul_div_fu_to_ring_result;
wire                            mul_div_fu_to_ring_valid_out;
wire[$clog2(ROB_SIZE)-1:0]      mul_div_fu_to_ring_rob_entry;
wire[$clog2(PHYS_REG_SIZE)-1:0] mul_div_fu_to_ring_dest_reg;

md_FU#(.XLEN(XLEN), .ROB_SIZE(ROB_SIZE), .UOP_SIZE(UOP_SIZE), .PHYS_REG_SIZE(PHYS_REG_SIZE)) mul_div_fu(
    .clk(clk), .rst(rst), .valid_in(mul_div_rsv_to_fu_valid_out),
    
    .rob_entry_in(mul_div_rsv_to_fu_rob_entry),
    .uop(mul_div_rsv_to_fu_uop_encoding),
    .rs1(mul_div_rsv_to_fu_rs1),
    .rs2(mul_div_rsv_to_fu_rs2),
    .pc(mul_div_rsv_to_fu_pc),
    .dest_reg_in(mul_div_rsv_to_fu_dest_reg),

    .result(mul_div_fu_to_ring_result),
    .valid_out(mul_div_fu_to_ring_valid_out),
    .rob_entry(mul_div_fu_to_ring_rob_entry),
    .dest_reg(mul_div_fu_to_ring_dest_reg)

);

wire[$clog2(ROB_SIZE)-1:0]      ld_st_rsv_to_fu_rob_entry;
wire[XLEN-1:0]                  ld_st_rsv_to_fu_rs1;
wire[XLEN-1:0]                  ld_st_rsv_to_fu_rs2;
wire[XLEN-1:0]                  ld_st_rsv_to_fu_pc;
wire[$clog2(UOP_SIZE)-1:0]       ld_st_rsv_to_fu_uop_encoding;
wire[$clog2(PHYS_REG_SIZE)-1:0] ld_st_rsv_to_fu_dest_reg;
wire                            ld_st_rsv_to_fu_valid_out;

rsv #(.XLEN(XLEN), .PHYS_REG_SIZE(PHYS_REG_SIZE), .ROB_SIZE(ROB_SIZE), .UOP_SIZE(UOP_SIZE)) ld_st_rsv(
    .clk(clk), .rst(rst), .valid_in(ring_to_logical_valid),

    .rob_entry_in(ring_to_ld_st_rob_entry),
    .rs1_reg(ring_to_ld_st_rs1_reg),
    .rs1_received(ring_to_ld_st_rs1_received),
    .rs1_value(ring_to_ld_st_rs1_value),
    .pc_in(ring_to_ld_st_pc),
    .uop_encoding_in(ring_to_ld_st_uop_encoding),
    .rs2_value(ring_to_ld_st_rs2_value),
    .rs2_received(ring_to_ld_st_rs2_received),
    .rs2_reg(ring_to_ld_st_rs2_reg),
    .dest_reg_in(ring_to_ld_st_dest_reg),

    .update_valid(update_ld_st_valid),
    .update_reg(update_ld_st_update_reg),
    .update_val(update_ld_st_update_val),

    .rob_entry(ld_st_rsv_to_fu_rob_entry),
    .rs1(ld_st_rsv_to_fu_rs1),
    .rs2(ld_st_rsv_to_fu_rs2),
    .pc(ld_st_rsv_to_fu_pc),
    .uop_encoding(ld_st_rsv_to_fu_uop_encoding),
    .valid_out(ld_st_rsv_to_fu_valid_out),
    .dest_reg(ld_st_rsv_to_fu_dest_reg)
);

wire[XLEN - 1:0]                ld_st_fu_to_ring_result;
wire                            ld_st_fu_to_ring_valid_out;
wire[$clog2(ROB_SIZE)-1:0]      ld_st_fu_to_ring_rob_entry;
wire[$clog2(PHYS_REG_SIZE)-1:0] ld_st_fu_to_ring_dest_reg;

ldst_FU #(.XLEN(XLEN), .ROB_SIZE(ROB_SIZE), .UOP_SIZE(UOP_SIZE), .PHYS_REG_SIZE(PHYS_REG_SIZE)) ld_st_fu(
    .clk(clk), .rst(rst), .valid_in(mul_div_rsv_to_fu_valid_out),
    
    .rob_entry_in(ld_st_rsv_to_fu_rob_entry),
    .uop(ld_st_rsv_to_fu_uop_encoding),
    .rs1(ld_st_rsv_to_fu_rs1),
    .rs2(ld_st_rsv_to_fu_rs2),
    .pc(ld_st_rsv_to_fu_pc),
    .dest_reg_in(ld_st_rsv_to_fu_dest_reg),

    .result(ld_st_fu_to_ring_result),
    .valid_out(ld_st_fu_to_ring_valid_out),
    .rob_entry(ld_st_fu_to_ring_rob_entry),
    .dest_reg(ld_st_fu_to_ring_dest_reg)

);

parameter RF_QUEUE = 8;

//TODO: Need actual branches

wire[XLEN - 1:0]                branch_fu_to_ring_result;
wire                            branch_fu_to_ring_valid_out;
wire[$clog2(ROB_SIZE)-1:0]      branch_fu_to_ring_rob_entry;
wire[$clog2(PHYS_REG_SIZE)-1:0] branch_fu_to_ring_dest_reg;


ring_rob #(.XLEN(XLEN), .PHYS_REG_SIZE(PHYS_REG_SIZE), .RF_QUEUE(RF_QUEUE), .UOP_SIZE(UOP_SIZE), .ROB_ENTRY(ROB_SIZE)) ring_for_rob(
    .clk(clk), .rst(rst),

    .logical_update(logical_fu_to_ring_valid_out),
    .logical_update_reg(logical_fu_to_ring_dest_reg),
    .logical_update_val(logical_fu_to_ring_result),
    .logical_rob_entry(logical_fu_to_ring_rob_entry),

    .arithmetic_update(arithmetic_fu_to_ring_valid_out),
    .arithmetic_update_reg(arithmetic_rsv_to_fu_dest_reg),
    .arithmetic_update_val(arithmetic_fu_to_ring_result), 
    .arithmetic_rob_entry(arithmetic_fu_to_ring_rob_entry),

    .branch_update(branch_fu_to_ring_valid_out),
    .branch_update_reg(branch_fu_to_ring_dest_reg),
    .branch_update_val(branch_fu_to_ring_result), 
    .branch_rob_entry(branch_fu_to_ring_rob_entry),

    .ld_st_update(ld_st_fu_to_ring_valid_out),
    .ld_st_update_reg(ld_st_fu_to_ring_dest_reg),
    .ld_st_update_val(ld_st_fu_to_ring_result), 
    .ld_st_rob_entry(ld_st_fu_to_ring_rob_entry),

    .mul_div_update(mul_div_fu_to_ring_valid_out),
    .mul_div_update_reg(mul_div_fu_to_ring_dest_reg),
    .mul_div_update_val(mul_div_fu_to_ring_result),
    .mul_div_rob_entry(mul_div_fu_to_ring_rob_entry),

    .out_reg_file_valid(out_reg_file_valid),
    .out_reg_file_update_reg(out_reg_file_update_reg),
    .out_reg_file_update_val(out_reg_file_update_val),
    .out_reg_file_rob_entry(out_reg_file_rob_entry),

    .out_rob_valid(out_rob_valid),
    .out_rob_update_reg(out_rob_update_reg),
    .out_rob_update_val(out_rob_update_val),
    .out_rob_rob_entry(out_rob_rob_entry),

    .out_logical_valid(update_logical_valid),
    .out_logical_update_reg(update_logical_update_reg),
    .out_logical_update_val(update_logical_update_val),

    .out_arithmetic_valid(update_arithmetic_valid),
    .out_arithmetic_update_reg(update_arithmetic_update_reg),
    .out_arithmetic_update_val(update_arithmetic_update_val), 

    .out_branch_valid(update_branch_valid),
    .out_branch_update_reg(update_branch_update_reg),
    .out_branch_update_val(update_branch_update_val),

    .out_ld_st_valid(update_ld_st_valid),
    .out_ld_st_update_reg(update_ld_st_update_reg),
    .out_ld_st_update_val(update_ld_st_update_val),

    .out_mul_div_valid(update_mul_div_valid),
    .out_mul_div_update_reg(update_mul_div_update_reg),
    .out_mul_div_update_val(update_mul_div_update_val)
);




endmodule