module mapper_TOP #(parameter NUM_UOPS=32,
                    parameter XLEN=32,
                    parameter ARCHFILE_SIZE=32,
                    parameter PHYSFILE_SIZE=256,
                    parameter ROB_SIZE=128)(
    /*input clk, rst, flush,

    //inputs
    input [31:0] uop, //TODO
    input eoi,
    input [4:0] dr, sr1, sr2,
    input [31:0] imm,
    input use_imm,
    input [31:0] pc,
    input exception_in, //TODO

    input [31:0] rob_write_ptr, //comes from ROB
    input rob_full,

    input [4:0] fu_full, //one hot, one for each FU

    //outputs
    output [4:0] fu_target, //tells which func unit this instruction is using
    output [31:0] rob_entry, //index into ROB to be used for this uop
    output src1_valid,
    output [7:0] src1_tag,
    output src2_valid,
    output [7:0] src2_tag,

    output eoi_out,
    output exception_out*/
    input clk, rst,

    input uop_ready,
    input [$clog2(NUM_UOPS)-1:0] uop_in,
    input eoi_in,
    //input [$clog2(ARCHFILE_SIZE)-1:0] src1_arch_in, src2_arch_in, //TODO: maybe should go through here before RF
    //input [$clog2(ARCHFILE_SIZE)-1:0] dest_arch_in, //TODO: maybe should go through here before RF
    input [XLEN-1:0] imm_in,
    input use_imm_in,
    input [31:0] pc_in,
    input except_in,

    input rf_src1_rdy, rf_src2_rdy,
    input [$clog2(PHYSFILE_SIZE)-1:0] rf_src1_tag, rf_src2_tag,
    input [XLEN-1:0] rf_src1_val, rf_src2_val,
    input [$clog2(PHYSFILE_SIZE)-1:0] rf_dest_tag, rf_dest_oldtag,

    input rob_full,
    input [$clog2(ROB_SIZE)-1:0] rob_entry_in,

    //output reg [$clog2(ARCHFILE_SIZE)-1:0] src1_arch_out, src2_arch_out, //TODO: maybe should go through here before RF
    //output reg [$clog2(ARCHFILE_SIZE)-1:0] dest_arch_out, //TODO: maybe should go through here before RF

    output reg [$clog2(NUM_UOPS)-1:0] uop_out,
    output reg op1_rdy_out, op2_rdy_out,
    output reg [$clog2(PHYSFILE_SIZE)-1:0] op1_tag_out, op2_tag_out,
    output reg [XLEN-1:0] op1_val_out, op2_val_out,
    output reg [$clog2(PHYSFILE_SIZE)-1:0] dest_tag_out,
    output reg pc_out,
    output reg [$clog2(ROB_SIZE)-1:0] rob_entry_out,

    output reg alloc_rob,
    output reg [$clog2(ARCHFILE_SIZE)-1:0] dest_arch_out,
    output reg [$clog2(PHYSFILE_SIZE)-1:0] dest_phys_out, dest_oldphys_out, //TODO: is redundant with dest_tag_out
    output reg except_out
);

    wire [$clog2(NUM_UOPS)-1:0] uop_arr_prr, uop_prr_disp;
    wire eoi_arr_prr, eoi_prr_disp;
    wire [$clog2(ARCHFILE_SIZE)-1:0] dest_arch_arr_prr, dest_arch_prr_disp;
    wire [XLEN-1:0] imm_arr_prr, imm_prr_disp;
    wire use_imm_arr_prr, use_imm_prr_disp;
    wire [31:0] pc_arr_prr, pc_prr_disp;
    wire except_arr_prr, except_prr_disp;

    regread #(.NUM_UOPS(NUM_UOPS), .XLEN(XLEN), .ARCHFILE_SIZE(ARCHFILE_SIZE))
            archrr(.clk(clk), .rst(rst),
                   .uop_in(uop_in), .eoi_in(eoi_in),
                   .dest_arch_in(dest_arch_in),
                   .imm_in(imm_in), .use_imm_in(use_imm_in),
                   .pc_in(pc_in),
                   .except_in(except_in),
                   .uop_out(uop_arr_prr), .eoi_out(eoi_arr_prr),
                   .dest_arch_out(dest_arch_arr_prr),
                   .imm_out(imm_arr_prr), .use_imm_out(use_imm_arr_prr),
                   .pc_out(pc_arr_prr),
                   .except_out(except_arr_prr));

    
    regread #(.NUM_UOPS(NUM_UOPS), .XLEN(XLEN), .ARCHFILE_SIZE(ARCHFILE_SIZE))
            physrr(.clk(clk), .rst(rst),
                   .uop_in(uop_arr_prr), .eoi_in(eoi_arr_prr),
                   .dest_arch_in(dest_arch_arr_prr),
                   .imm_in(imm_arr_prr), .use_imm_in(use_imm_arr_prr),
                   .pc_in(pc_arr_prr),
                   .except_in(except_arr_prr),
                   .uop_out(uop_prr_disp), .eoi_out(eoi_prr_disp),
                   .dest_arch_out(dest_arch_prr_disp),
                   .imm_out(imm_prr_disp), .use_imm_out(use_imm_prr_disp),
                   .pc_out(pc_prr_disp),
                   .except_out(except_prr_disp));
    
    dispatch #(.NUM_UOPS(NUM_UOPS), .XLEN(XLEN), .ARCHFILE_SIZE(ARCHFILE_SIZE),
               .PHYSFILE_SIZE(PHYSFILE_SIZE), .ROB_SIZE(ROB_SIZE))
            disp(.clk(clk), .rst(rst),
                 //RR inputs
                 .uop_in(uop_prr_disp), .eoi_in(eoi_prr_disp),
                 .dest_arch_in(dest_arch_prr_disp),
                 .imm_in(imm_prr_disp), .use_imm_in(use_imm_prr_disp),
                 .pc_in(pc_prr_disp),
                 .except_in(except_prr_disp),
                 //RF inputs
                 .src1_rdy_in(rf_src1_rdy), .src2_rdy_in(rf_src2_rdy),
                 .src1_tag_in(rf_src1_tag), .src2_tag_in(rf_src2_tag),
                 .src1_val_in(rf_src1_val), .src2_val_in(rf_src2_val),
                 .dest_tag_in(rf_dest_tag), .dest_oldtag_in(rf_dest_oldtag),
                 //ROB inputs
                 .rob_full(rob_full), .rob_entry_in(rob_entry_in),
                 //RSV outputs
                 .uop_out(uop_out),
                 .op1_rdy_out(op1_rdy_out), .op2_rdy_out(op2_rdy_out),
                 .op1_tag_out(op1_tag_out), .op2_tag_out(op2_tag_out),
                 .op1_val_out(op1_val_out), .op2_val_out(op1_val_out),
                 .dest_tag_out(dest_tag_out),
                 .pc_out(pc_out),
                 .rob_entry_out(rob_entry_out),
                 //ROB outputs
                 .alloc_rob(alloc_rob),
                 .dest_arch_out(dest_arch_out), .dest_phys_out(dest_phys_out), 
                 .dest_oldphys_out(dest_oldphys_out),                
                 .except_out(except_out));

endmodule