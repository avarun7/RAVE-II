module backend_TOP #(parameter NUM_UOPS=32,
                     parameter XLEN=32,
                     parameter ARCHFILE_SIZE=32,
                     parameter PHYSFILE_SIZE=256,
                     parameter REG_SIZE=32,
                     parameter RSV_SIZE=16,
                     parameter ROB_SIZE=128)(
    input clk, rst,


    input uop_ready,
    input [$clog2(NUM_UOPS)-1:0] uop,
    input eoi,
    input [XLEN-1:0] imm,
    input use_imm,
    input [31:0] pc,
    input except,

    input [$clog2(ARCHFILE_SIZE)-1:0] src1_arch, src2_arch, 
    input [$clog2(ARCHFILE_SIZE)-1:0] dest_arch
);

        //RF --> map
    wire src1_rdy_rf_map, src2_rdy_rf_map;
    wire [$clog2(PHYSFILE_SIZE)-1:0] src1_tag_rf_map, src2_tag_rf_map;
    wire [XLEN-1:0] src1_val_rf_map, src2_val_rf_map;
    wire [$clog2(PHYSFILE_SIZE)-1:0] dest_tag_rf_map, dest_oldtag_rf_map;
        //ROB --> map
    wire rob_full_rob_map;
    wire [$clog2(ROB_SIZE)-1:0] next_rob_entry_rob_map;
        //map --> OOO
    wire [$clog2(NUM_UOPS)-1:0] uop_map_ooo;
    wire op1_rdy_map_ooo, op2_rdy_map_ooo;
    wire [$clog2(PHYSFILE_SIZE)-1:0] op1_tag_map_ooo, op2_tag_map_ooo;
    wire [XLEN-1:0] op1_val_map_ooo, op2_val_map_ooo;
    wire [$clog2(PHYSFILE_SIZE)-1:0] dest_tag_map_ooo;
    wire [31:0] pc_map_ooo;
    wire [$clog2(ROB_SIZE)-1:0] rob_entry_map_ooo;
        //map --> ROB
    wire alloc_rob;
    wire [$clog2(ARCHFILE_SIZE)-1:0] dest_arch_map_rob;
    wire [$clog2(PHYSFILE_SIZE)-1:0] dest_phys_map_rob, dest_oldphys_map_rob;
    wire except_map_rob;
        //OOO --> RF
    wire ring_update_ooo_rf;
    wire [$clog2(PHYSFILE_SIZE)-1:0] phys_ring_ooo_rf;
    wire [REG_SIZE-1:0] phys_ring_val_ooo_rf;
        //ROB --> RF
    wire rob_update_rob_rf;
    wire [$clog2(ARCHFILE_SIZE)-1:0] arch_rob_update_rob_rf;
    wire [$clog2(PHYSFILE_SIZE)-1:0] arch_rob_nonspec_phys_rob_rf;
    wire [$clog2(PHYSFILE_SIZE)-1:0] phys_rob_free_rob_rf;
    wire rollback_rob_rf;
        //OOO --> ROB
    wire uop_finish_ooo_rob;
    wire [$clog2(ROB_SIZE)-1:0] uop_finish_rob_entry_ooo_rob;



    mapper_TOP #(.NUM_UOPS(NUM_UOPS), .XLEN(XLEN), .ARCHFILE_SIZE(ARCHFILE_SIZE),
                 .PHYSFILE_SIZE(PHYSFILE_SIZE), .ROB_SIZE(ROB_SIZE))
            map(.clk(clk), .rst(rst),
                    //uopQ inputs
                .uop_ready(uop_ready), .uop_in(uop), .eoi_in(eoi),
                .imm_in(imm), .use_imm_in(use_imm),
                .pc_in(pc),
                .except_in(except),
                    //RF inputs
                .rf_src1_rdy(src1_rdy_rf_map), .rf_src2_rdy(src2_rdy_rf_map),
                .rf_src1_tag(src1_tag_rf_map), .rf_src2_tag(src2_tag_rf_map),
                .rf_src1_val(src1_val_rf_map), .rf_src2_val(src2_val_rf_map),
                .rf_dest_tag(dest_tag_rf_map), .rf_dest_oldtag(dest_oldtag_rf_map),
                    //ROB inputs
                .rob_full(rob_full_rob_map),
                .rob_entry_in(next_rob_entry_rob_map),
                    //RSV outputs
                .uop_out(uop_map_ooo), .eoi_out(),
                .op1_rdy_out(op1_rdy_map_ooo), .op2_rdy_out(op2_rdy_map_ooo),
                .op1_tag_out(op1_tag_map_ooo), .op2_tag_out(op2_tag_map_ooo),
                .op1_val_out(op1_val_map_ooo), .op2_val_out(op2_val_map_ooo),
                .dest_tag_out(dest_tag_map_ooo),
                .pc_out(pc_map_ooo),
                .rob_entry_out(rob_entry_map_ooo),
                    //ROB outputs
                .alloc_rob(alloc_rob),
                .dest_arch_out(dest_arch_map_rob), .dest_phys_out(dest_phys_map_rob), .dest_oldphys_out(dest_oldphys_map_rob),                 
                .except_out(except_map_rob));

    regfile_TOP #(.ARCHFILE_SIZE(ARCHFILE_SIZE), .PHYSFILE_SIZE(PHYSFILE_SIZE),
                  .REG_SIZE(REG_SIZE))
            rf(.clk(clk), .rst(rst),
                    //uopQ inputs
               .uop_update(uop_ready),
               .arch_rd1(src1_arch), .arch_rd2(src2_arch),
               .arch_wr(dest_arch),
                    //ring inputs
               .ring_update(uop_finish_ooo_rob/*ring_update_ooo_rf*/),
               .phys_ring(phys_ring_ooo_rf), .phys_ring_val(phys_ring_val_ooo_rf),
                    //ROB inputs
               .rob_update(rob_update_rob_rf),
               .arch_rob_update(arch_rob_update_rob_rf), .arch_rob_nonspec_phys(arch_rob_nonspec_phys_rob_rf),
               .phys_rob_free(phys_rob_free_rob_rf),
               .rollback(),
                    //mapper outputs
               .phys_rd1_rdy(src1_rdy_rf_map), .phys_rd2_rdy(src2_rdy_rf_map),
               .phys_rd1(src1_tag_rf_map), .phys_rd2(src2_tag_rf_map),
               .phys_rd1_val(src1_val_rf_map), .phys_rd2_val(src2_val_rf_map),
               .phys_wr(dest_tag_rf_map), .oldphys_wr(dest_oldtag_rf_map),
               .none_free());

    ooo_engine_TOP #(.XLEN(XLEN), .PHYS_REG_SIZE(PHYSFILE_SIZE), .ROB_SIZE(ROB_SIZE),
                     .UOP_SIZE(NUM_UOPS/8), .RSV_SIZE(RSV_SIZE))
            ooo(.clk(clk), .rst(~rst), //TODO: get consistent rst schemes
                .valid_in(alloc_rob),
                .mapper_to_ring_functional_unit_num(uop_map_ooo[$clog2(NUM_UOPS)-1:$clog2(NUM_UOPS)-3]),
                .mapper_to_ring_rob_entry(rob_entry_map_ooo),
                .mapper_to_ring_uop_rs1_reg(op1_tag_map_ooo),
                .mapper_to_ring_uop_rs1_received(op1_rdy_map_ooo),
                .mapper_to_ring_uop_rs1_value(op1_val_map_ooo),
                .mapper_to_ring_uop_pc_in(pc_map_ooo),
                .mapper_to_ring_uop_uop_encoding(uop_map_ooo[$clog2(NUM_UOPS)-4:0]),
                .mapper_to_ring_uop_rs2_value(op2_val_map_ooo),
                .mapper_to_ring_uop_rs2_received(op2_rdy_map_ooo),
                .mapper_to_ring_uop_rs2_reg(op2_tag_map_ooo),
                .mapper_to_ring_dest_reg(dest_tag_map_ooo),
                .out_rob_valid(uop_finish_ooo_rob),
                .out_rob_update_reg(phys_ring_ooo_rf),
                .out_rob_update_val(phys_ring_val_ooo_rf),
                .out_rob_rob_entry(uop_finish_rob_entry_ooo_rob));

    rob_TOP #(.ARCHFILE_SIZE(ARCHFILE_SIZE), .PHYSFILE_SIZE(PHYSFILE_SIZE), .ROB_SIZE(ROB_SIZE))
            rob(.clk(clk), .rst(rst),
                    //mapper inputs
                .uop_update(alloc_rob),
                .uop_dest_arch_in(dest_arch_map_rob), .uop_dest_phys_in(dest_phys_map_rob),
                .uop_dest_oldphys_in(dest_oldphys_map_rob),
                .except(except_map_rob),
                    //ring inputs
                .uop_finish(uop_finish_ooo_rob), .uop_finish_rob_entry(uop_finish_rob_entry_ooo_rob),
                    //RF outputs
                .retire_uop(rob_update_rob_rf),
                .uop_dest_arch_out(arch_rob_update_rob_rf), .uop_dest_phys_out(arch_rob_nonspec_phys_rob_rf),
                .uop_dest_oldphys_out(phys_rob_free_rob_rf),
                    //mapper outputs
                .next_rob_entry(next_rob_entry_rob_map),
                .rob_full(rob_full_rob_map));
    


    /*`ifdef DEBUG
        integer cycle_cnt;
        integer file;

        initial begin
            cycle_cnt = 0;
            fullfile = $fopen("./out/backend.dump");
        end

        always@(posedge clk) begin
            if(rob_update_rob_rf) begin

            end
        end
    `endif*/

endmodule