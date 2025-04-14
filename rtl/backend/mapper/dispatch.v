module dispatch #(parameter NUM_UOPS=32,
                  parameter XLEN=32,
                  parameter ARCHFILE_SIZE=32,
                  parameter PHYSFILE_SIZE=256,
                  parameter ROB_SIZE=128)(
    input valid_in,

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
    input [$clog2(PHYSFILE_SIZE)-1:0] dest_tag_in, dest_oldtag_in,

    input rob_full,
    input [$clog2(ROB_SIZE)-1:0] rob_entry_in,

    output [$clog2(NUM_UOPS)-1:0] uop_out,
    output eoi_out,
    output op1_rdy_out, op2_rdy_out,
    output [$clog2(PHYSFILE_SIZE)-1:0] op1_tag_out, op2_tag_out,
    output [XLEN-1:0] op1_val_out, op2_val_out,
    output [$clog2(PHYSFILE_SIZE)-1:0] dest_tag_out,
    output [31:0] pc_out,
    output [$clog2(ROB_SIZE)-1:0] rob_entry_out,

    output alloc_rob,
    output [$clog2(ARCHFILE_SIZE)-1:0] dest_arch_out,
    output [$clog2(PHYSFILE_SIZE)-1:0] dest_phys_out, dest_oldphys_out, //TODO: is redundant with dest_tag_out
    output except_out
);

    assign uop_out = uop_in;
    assign eoi_out = eoi_in;
    assign op1_rdy_out = src1_rdy_in;
    assign op2_rdy_out = (use_imm_in)? 1'b1 : src2_rdy_in;
    assign op1_tag_out = src1_tag_in;
    assign op2_tag_out = (use_imm_in)? {$clog2(PHYSFILE_SIZE){1'b0}} : src2_tag_in;
    assign op1_val_out = src1_val_in;
    assign op2_val_out = (use_imm_in)? imm_in : src2_val_in;
    assign dest_tag_out = dest_tag_in;
    assign pc_out = pc_in;
    assign rob_entry_out = rob_entry_in;

    assign alloc_rob = ~rob_full & valid_in;
    assign dest_arch_out = dest_arch_in;
    assign dest_phys_out = dest_tag_in;
    assign dest_oldphys_out = dest_oldtag_in;
    assign except_out = except_in;

endmodule