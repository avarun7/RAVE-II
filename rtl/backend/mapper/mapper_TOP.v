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
    input [$clog2(ARCHFILE_SIZE)-1:0] dest_arch_in,
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

    wire valid_arr_prr, valid_prr_disp;
    wire [$clog2(NUM_UOPS)-1:0] uop_arr_prr, uop_prr_disp;
    wire eoi_arr_prr, eoi_prr_disp;
    wire [$clog2(ARCHFILE_SIZE)-1:0] dest_arch_arr_prr, dest_arch_prr_disp;
    wire [XLEN-1:0] imm_arr_prr, imm_prr_disp;
    wire use_imm_arr_prr, use_imm_prr_disp;
    wire [31:0] pc_arr_prr, pc_prr_disp;
    wire except_arr_prr, except_prr_disp;

    regread #(.NUM_UOPS(NUM_UOPS), .XLEN(XLEN), .ARCHFILE_SIZE(ARCHFILE_SIZE))
            archrr(.clk(clk), .rst(rst),
                   .valid_in(uop_ready),
                   .uop_in(uop_in), .eoi_in(eoi_in),
                   .dest_arch_in(dest_arch_in),
                   .imm_in(imm_in), .use_imm_in(use_imm_in),
                   .pc_in(pc_in),
                   .except_in(except_in),
                   .valid_out(valid_arr_prr),
                   .uop_out(uop_arr_prr), .eoi_out(eoi_arr_prr),
                   .dest_arch_out(dest_arch_arr_prr),
                   .imm_out(imm_arr_prr), .use_imm_out(use_imm_arr_prr),
                   .pc_out(pc_arr_prr),
                   .except_out(except_arr_prr));

    
    regread #(.NUM_UOPS(NUM_UOPS), .XLEN(XLEN), .ARCHFILE_SIZE(ARCHFILE_SIZE))
            physrr(.clk(clk), .rst(rst),
                   .valid_in(valid_arr_prr),
                   .uop_in(uop_arr_prr), .eoi_in(eoi_arr_prr),
                   .dest_arch_in(dest_arch_arr_prr),
                   .imm_in(imm_arr_prr), .use_imm_in(use_imm_arr_prr),
                   .pc_in(pc_arr_prr),
                   .except_in(except_arr_prr),
                   .valid_out(valid_prr_disp),
                   .uop_out(uop_prr_disp), .eoi_out(eoi_prr_disp),
                   .dest_arch_out(dest_arch_prr_disp),
                   .imm_out(imm_prr_disp), .use_imm_out(use_imm_prr_disp),
                   .pc_out(pc_prr_disp),
                   .except_out(except_prr_disp));
    
    dispatch #(.NUM_UOPS(NUM_UOPS), .XLEN(XLEN), .ARCHFILE_SIZE(ARCHFILE_SIZE),
               .PHYSFILE_SIZE(PHYSFILE_SIZE), .ROB_SIZE(ROB_SIZE))
            disp(//RR inputs
                 .valid_in(valid_prr_disp),
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
                 .uop_out(uop_out), .eoi_out(eoi_out),
                 .op1_rdy_out(op1_rdy_out), .op2_rdy_out(op2_rdy_out),
                 .op1_tag_out(op1_tag_out), .op2_tag_out(op2_tag_out),
                 .op1_val_out(op1_val_out), .op2_val_out(op2_val_out),
                 .dest_tag_out(dest_tag_out),
                 .pc_out(pc_out),
                 .rob_entry_out(rob_entry_out),
                 //ROB outputs
                 .alloc_rob(alloc_rob),
                 .dest_arch_out(dest_arch_out), .dest_phys_out(dest_phys_out), 
                 .dest_oldphys_out(dest_oldphys_out),                
                 .except_out(except_out));



    // `ifdef DEBUG
        integer cycle_cnt;
        integer fullfile, sparsefile;

        initial begin
            cycle_cnt = 0;
            fullfile = $fopen("./out/mapper_full.dump");
            sparsefile = $fopen("./out/mapper_sparse.dump");
            //#800
            //$fclose(fullfile);
            //$fclose(sparsefile);
        end

        always@(posedge clk) begin
            $fdisplay(fullfile, "cycle number: %d", cycle_cnt);
            $fdisplay(fullfile, "[====ARCHREGREAD====]");
            $fdisplay(fullfile, "uop: 0x%h, eoi: %b", uop_arr_prr, eoi_arr_prr);
            $fdisplay(fullfile, "dest_arch: archR%0d", dest_arch_arr_prr);
            $fdisplay(fullfile, "use_imm: %b, imm: 0x%h", use_imm_arr_prr, imm_arr_prr);
            $fdisplay(fullfile, "PC: 0x%h", pc_arr_prr);
            $fdisplay(fullfile, "exception: %b", except_arr_prr);
            $fdisplay(fullfile, "[====PHYSREGREAD====]");
            $fdisplay(fullfile, "uop: 0x%h, eoi: %b", uop_prr_disp, eoi_prr_disp);
            $fdisplay(fullfile, "dest_arch: archR%0d", dest_arch_prr_disp);
            $fdisplay(fullfile, "use_imm: %b, imm: 0x%h", use_imm_prr_disp, imm_prr_disp);
            $fdisplay(fullfile, "PC: 0x%h", pc_prr_disp);
            $fdisplay(fullfile, "exception: %b", except_prr_disp);
            $fdisplay(fullfile, "[====DISPATCH-TO-RSV====]");
            $fdisplay(fullfile, "dispatch: %b", alloc_rob);
            $fdisplay(fullfile, "uop: 0x%h, eoi: %b", uop_out, eoi_out);
            $fdisplay(fullfile, "op1: rdy=%b, tag=physR%0d, val=0x%h", op1_rdy_out, op1_tag_out, op1_val_out);
            $fdisplay(fullfile, "op2: rdy=%b, tag=physR%0d, val=0x%h", op2_rdy_out, op2_tag_out, op2_val_out);
            $fdisplay(fullfile, "dest: tag=physR%0d", dest_tag_out);
            $fdisplay(fullfile, "PC: 0x%h", pc_out);
            $fdisplay(fullfile, "rob_entry: ROB%0d", rob_entry_out);
            $fdisplay(fullfile, "[====DISPATCH-TO-ROB====]");
            $fdisplay(fullfile, "dispatch: %b", alloc_rob);
            $fdisplay(fullfile, "alloc([(spec(archR%0d)<-physR%0d), free(physR%0d)])", dest_arch_out, dest_phys_out, dest_oldphys_out);
            $fdisplay(fullfile, "exception: %b", except_out);
            $fdisplay(fullfile, "\n\n");

            if(alloc_rob) begin
                $fdisplay(sparsefile, "cycle number: %d", cycle_cnt);
                $fdisplay(sparsefile, "[====DISPATCH-TO-RSV====]");
                $fdisplay(sparsefile, "uop: 0x%h, eoi: %b", uop_out, eoi_out);
                $fdisplay(sparsefile, "op1: rdy=%b, tag=physR%0d, val=0x%h", op1_rdy_out, op1_tag_out, op1_val_out);
                $fdisplay(sparsefile, "op2: rdy=%b, tag=physR%0d, val=0x%h", op2_rdy_out, op2_tag_out, op2_val_out);
                $fdisplay(sparsefile, "dest: tag=physR%0d", dest_tag_out);
                $fdisplay(sparsefile, "PC: 0x%h", pc_out);
                $fdisplay(sparsefile, "rob_entry: ROB%0d", rob_entry_out);
                $fdisplay(sparsefile, "[====DISPATCH-TO-ROB====]");
                $fdisplay(sparsefile, "alloc([(spec(archR%0d)<-physR%0d), free(physR%0d)])", dest_arch_out, dest_phys_out, dest_oldphys_out);
                $fdisplay(sparsefile, "exception: %b", except_out);
                $fdisplay(sparsefile, "\n\n");
            end

            cycle_cnt = cycle_cnt + 1;
        end
    // `endif

endmodule