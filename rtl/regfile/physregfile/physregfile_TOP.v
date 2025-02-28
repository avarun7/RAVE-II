module physregfile_TOP #(parameter PHYSFILE_SIZE=256,
                         parameter REG_SIZE=32)(
    input clk, rst,

    input uop_update,
    input [$clog2(PHYSFILE_SIZE)-1:0] phys_rd1, phys_rd2,
    input [$clog2(PHYSFILE_SIZE)-1:0] phys_wr,

    input ring_update,
    input [$clog2(PHYSFILE_SIZE)-1:0] phys_ring,
    input [REG_SIZE-1:0] phys_ring_val,

    input rob_update,
    input [$clog2(PHYSFILE_SIZE)-1:0] phys_rob,

    input arch_update,

    input rollback, //TODO: implement rollback mech

    output phys_rd1_rdy, phys_rd2_rdy,
    output [REG_SIZE-1:0] phys_rd1_val, phys_rd2_val,

    output none_free,
    output [$clog2(PHYSFILE_SIZE)-1:0] next_free
);
    wire [$clog2(PHYSFILE_SIZE)-1:0] next_free;

    physfile #(.PHYSFILE_SIZE(PHYSFILE_SIZE), .REG_SIZE(REG_SIZE))
            pf(.clk(clk), .rst(rst),
               .uop_update(uop_update),
               .phys_rd1(phys_rd1), .phys_rd2(phys_rd2), .phys_wr(phys_wr),
               .ring_update(ring_update),
               .phys_ring(phys_ring), .phys_ring_val(phys_ring_val),
               .rollback(rollback),
               .phys_rd1_rdy(phys_rd1_rdy), .phys_rd2_rdy(phys_rd2_rdy),
               .phys_rd1_val(phys_rd1_val), .phys_rd2_val(phys_rd2_val));

    freelist #(.PHYSFILE_SIZE(PHYSFILE_SIZE))
            fl(.clk(clk), .rst(rst),
               .phys_rsv(arch_update & ~none_free), .phys_free(arch_update & ~none_free),
               .phystag_rsv(next_free), .phystag_free(phys_rob),
               .rollback(rollback),
               .none_free(none_free), .next_free(next_free));

endmodule