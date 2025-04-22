module ldst_FU#(parameter XLEN=32, ROB_SIZE=256, PHYS_REG_SIZE=256, UOP_SIZE=16)(
    input clk, rst, valid_in,
    input[$clog2(UOP_SIZE)-1:0]         uop,
    input[$clog2(ROB_SIZE)-1:0]         rob_entry_in,
    input[$clog2(PHYS_REG_SIZE)-1:0]    dest_reg_in,
    input[XLEN-1:0]                     rs1,
    input[XLEN-1:0]                     rs2,
    input[XLEN-1:0]                     pc,

    // DCache Inputs
    input [31:0]                addr_dcache_out,
    input [XLEN-1:0]            data_dcache_out,
    input                       is_st_dcache_out,
    input                       is_flush_dcache_out,
    input [PHYS_REG_SIZE-1:0]   tag_dcache_out,
    input [ROB_SIZE-1:0]        rob_line_dcache_out,
    input                       valid_dcache_out,

    // Outputs to D$
    output [31:0]               addr_dcache_in,
    output [31:0]               data_dcache_in,
    output [1:0]                size_dcache_in,      // 0 - B, 1 - 2B, 3 - 4B
    output                      is_st_dcache_in,     //Say whether input is ST or LD
    output [PHYS_REG_SIZE-1:0]  ooo_tag_dcache_in,   //tag from register renaming
    output [ROB_SIZE-1:0]       ooo_rob_dcache_in,
    output                      sext_dcache_in,
    output                      valid_dcache_in,   

    output [XLEN-1:0]                    result,
    output                               valid_out,
    output [$clog2(ROB_SIZE)-1:0]        rob_entry,
    output [$clog2(PHYS_REG_SIZE)-1:0]   dest_reg
);


// Insert into d-cache
assign addr_dcache_in = (valid_in) ? rs1 : {XLEN{1'b0}};
assign data_dcache_in = (valid_in) ? rs1 : {XLEN{1'b0}};
assign size_dcache_in  = (valid_in) ? ((uop[1:0] == 2'b10) ? 2'b11 : uop[1:0]) : 2'b00;
assign is_st_dcache_in  = (valid_in) ? uop[$clog2(UOP_SIZE)-1] : 1'b0;
assign ooo_tag_dcache_in = (valid_in) ? dest_reg_in : {$clog2(ROB_SIZE){1'b0}};
assign ooo_rob_dcache_in = (valid_in) ? rob_entry : {$clog2(PHYS_REG_SIZE){1'b0}};
assign sext_dcache_in = (valid_in) ? uop[2] : {1'b0};
assign valid_dcache_in = valid_in;

//Get from dcache
assign result = data_dcache_in;
assign valid_out = valid_dcache_out;
assign rob_entry = rob_line_dcache_out;
assign dest_reg = tag_dcache_out;

endmodule