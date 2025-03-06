module dispatch #(parameter NUM_UOPS=32,
                  parameter XLEN=32,
                  parameter ARCHFILE_SIZE=32,
                  parameter PHYSFILE_SIZE=256,
                  parameter ROB_SIZE=128)(
    input clk, rst,

    input [$clog2(NUM_UOPS)-1:0] uop_in,
    input eoi_in,
    input [$clog2(ARCHFILE_SIZE)-1:0] dest_arch_in,
    input [XLEN-1:0] imm_in,
    input use_imm_in,
    input [31:0] pc_in,
    input except_in,

    input src1_rdy_in, src2_rdy_in,
    input [$clog2(PHYSFILE_SIZE)-1:0] src1_tag_in, src2_tag_in,
    input [XLEN-1:0] src1_val_in, src2_val_in,
    input [$clog2(PHYSFILE_SIZE)-1:0] dest_tag_in,

    input rob_full,
    input [$clog2(ROB_SIZE)-1:0] rob_entry_in,

    output reg [$clog2(NUM_UOPS)-1:0] uop_out,
    output reg op1_rdy_out, op2_rdy_out,
    output reg [$clog2(PHYSFILE_SIZE)-1:0] op1_tag_out, op2_tag_out,
    output reg [XLEN-1:0] op1_val_out, op2_val_out,
    output reg [$clog2(PHYSFILE_SIZE)-1:0] dest_tag_out,
    output reg pc_out,
    output reg [$clog2(ROB_SIZE)-1:0] rob_entry_out,

    output reg alloc_rob,
    output reg [$clog2(ARCHFILE_SIZE)-1:0] dest_arch_out,
    output reg [$clog2(PHYSFILE_SIZE)-1:0] dest_phys_out, //TODO: is redundant with dest_tag_out
    output reg except_out
);

always@(posedge clk) begin
    uop_out <= uop_in;
    op1_rdy_out <= src1_rdy_in;
    op2_rdy_out <= (use_imm_in)? 1'b1 : src2_rdy_in;
    op1_tag_out <= src1_tag_in;
    op2_tag_out <= (use_imm_in)? {$clog2(PHYSFILE_SIZE){1'b0}} : src2_tag_in;
    op1_val_out <= src1_val_in;
    op2_val_out <= (use_imm_in)? imm_in : src2_val_in;
    dest_tag_out <= dest_tag_in;
    pc_out <= pc_in;
    rob_entry_out <= rob_entry_in;

    alloc_rob <= alloc_rob;
    dest_arch_out <= dest_arch_in;
    dest_phys_out <= dest_tag_in;
    except_out <= except_in;
end

endmodule