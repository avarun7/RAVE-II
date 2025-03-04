module ooo_engine_TOP#(parameter XLEN=32)(
    // .clk(clk), .rst(),
    //     .flush(),
        
    //     .l2_dcache_op(), .l2_dcache_addr(), .l2_dcache_data_out(), .l2_dcache_state(),

    //     //inputs
    //     .exception(),
    //     .fu_target(),
    //     .rob_entry(),
    //     .src1_ready(), .src1_tag(), .src1_val(),
    //     .src2_ready(), .src2_tag(), .src2_val(),

    //     //Get data from REGFILE
    //     .sr1_data_l(),
    //     .sr2_data_l(),
    //     .valid_l(),

    //     .sr1_data_i(),
    //     .sr2_data_i(),
    //     .valid_i(),

    //     .sr1_data_ls(),
    //     .sr2_data_ls(),
    //     .valid_ls(),

    //     .sr1_data_b(),
    //     .sr2_data_b(),
    //     .valid_b(),

    //     .sr1_data_md(),
    //     .sr2_data_md(),
    //     .valid_md(),
);

register [31:0] rs1;
register [31:0] rs2;
register [2:0]  logical_type;       // For the bits [14-12] that determine operation
register        additional_info;    // For bit 30

// FUs
logical_FU_TOP #(.XLEN(XLEN)) logical_functional_unit( // Only for opcodes 00100 and 01100
    .clk(clk), .rst(rst), .valid(valid_l),
    .logical_type(logical_type), 
    .rs1(rs1),
    .rs2(rs2)
);

arithmetic_FU_TOP #(.XLEN(XLEN)) arithmetic_functional_unit(
    .clk(clk), .rst(rst), .valid(valid_a),
    .arithmetic_type(logical_type),
    .additional_info(additional_info),
    .rs1(rs1),
    .rs2(rs2)
);

br_FU_TOP #(.XLEN(XLEN)) branch_functional_unit( // RD for Branch is always PC if taken
    .clk(clk), .rst(rst), .valid(valid_b),
    .opcode(opcode),
    .branch_type(logical_type),
    .rs1(rs1),
    .rs2(rs2),
    .pc(pc),
    .offset(offset)
);

ld_st_FU_TOP #(.XLEN(XLEN)) load_store_functional_unit(
    .clk(clk), .rst(rst), .valid(valid_b),
    .opcode(opcode),
    .ld_st_type(logical_type),
    .rs1(rs1),
    .rs2(rs2)
);

md_FU_TOP #(.XLEN(XLEN)) multiply_divide_functional_unit(
    .clk(clk), .rst(rst), .valid(valid_b),
    .md_type(logical_type),
    .rs1(rs1),
    .rs2(rs2)
);


endmodule