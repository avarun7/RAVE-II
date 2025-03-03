module regfile_TOP #(parameter ARCHFILE_SIZE=32,
                     parameter PHYSFILE_SIZE=256,
                     parameter REG_SIZE=32)(
    input clk, rst,

    input uop_update,
    input [$clog2(ARCHFILE_SIZE)-1:0] arch_rd1, arch_rd2,
    input [$clog2(ARCHFILE_SIZE)-1:0] arch_wr,

    input ring_update,
    input [$clog2(PHYSFILE_SIZE)-1:0] phys_ring,
    input [REG_SIZE-1:0] phys_ring_val,

    input rob_update,
    input [$clog2(ARCHFILE_SIZE)-1:0] arch_rob,
    input [$clog2(PHYSFILE_SIZE)-1:0] arch_rob_phys,
    input [$clog2(PHYSFILE_SIZE)-1:0] phys_rob,

    input rollback,

    output phys_rd1_rdy, phys_rd2_rdy,
    output reg [$clog2(PHYSFILE_SIZE)-1:0] phys_rd1, phys_rd2,
    output [REG_SIZE-1:0] phys_rd1_val, phys_rd2_val,

    output reg [$clog2(PHYSFILE_SIZE)-1:0] phys_wr,

    output none_free
);

    wire [$clog2(PHYSFILE_SIZE)-1:0] arch_wr_phys;

    reg archphys_uop_update;
    wire [$clog2(PHYSFILE_SIZE)-1:0] archphys_rd1, archphys_rd2;
    reg [$clog2(PHYSFILE_SIZE)-1:0] archphys_wr;
    
    always@(posedge clk) begin
        //1st cycle
        archphys_uop_update <= uop_update;
        archphys_wr <= arch_wr_phys;

        //2nd cycle
        phys_rd1 <= archphys_rd1;
        phys_rd2 <= archphys_rd2;
        phys_wr <= archphys_wr;
    end

    archregfile_TOP #(.ARCHFILE_SIZE(ARCHFILE_SIZE), .PHYSFILE_SIZE(PHYSFILE_SIZE))
            arf(.clk(clk), .rst(rst),
                    //1st cycle inputs
                .uop_update(uop_update),
                .arch_rd1(arch_rd1), .arch_rd2(arch_rd2),
                .arch_wr(arch_wr), .arch_wr_phys(arch_wr_phys),
                    //rob inputs
                .rob_update(rob_update),
                .arch_rob(arch_rob), .arch_rob_phys(arch_rob_phys),
                    //rollback
                .rollback(rollback),
                    //1st cycle outputs
                .arch_rd1_phys(archphys_rd1), .arch_rd2_phys(archphys_rd2));

    physregfile_TOP #(.PHYSFILE_SIZE(PHYSFILE_SIZE), .REG_SIZE(REG_SIZE))
            prf(.clk(clk), .rst(rst),
                    //2nd cycle inputs
                .uop_update(archphys_uop_update),
                .phys_rd1(archphys_rd1), .phys_rd2(archphys_rd2),
                .phys_wr(archphys_wr),
                    //ring inputs
                .ring_update(ring_update),
                .phys_ring(phys_ring), .phys_ring_val(phys_ring_val),
                    //rob inputs
                .rob_update(rob_update),
                .phys_rob(phys_rob),
                    //1st cycle inputs
                .arch_update(uop_update),
                    //rollback
                .rollback(rollback),
                    //2nd cycle outputs
                .phys_rd1_rdy(phys_rd1_rdy), .phys_rd2_rdy(phys_rd2_rdy),
                .phys_rd1_val(phys_rd1_val), .phys_rd2_val(phys_rd2_val),
                    //1st cycle outputs
                .none_free(none_free), .next_free(arch_wr_phys));

endmodule