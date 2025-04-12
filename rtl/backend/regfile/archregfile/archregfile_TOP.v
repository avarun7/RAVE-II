module archregfile_TOP #(parameter ARCHFILE_SIZE=32,
                         parameter PHYSFILE_SIZE=256)(
    input clk, rst,

    input uop_update,
    input [$clog2(ARCHFILE_SIZE)-1:0] arch_rd1, arch_rd2,
    input [$clog2(ARCHFILE_SIZE)-1:0] arch_wr,
    input [$clog2(PHYSFILE_SIZE)-1:0] arch_wr_phys,

    input rob_update,
    input [$clog2(ARCHFILE_SIZE)-1:0] arch_rob_update,
    input [$clog2(PHYSFILE_SIZE)-1:0] arch_rob_nonspec_phys,

    input rollback,

    output [$clog2(PHYSFILE_SIZE)-1:0] arch_rd1_phys, arch_rd2_phys, arch_wr_oldphys
);

    wire [ARCHFILE_SIZE*$clog2(PHYSFILE_SIZE)-1:0] rb_dump;

    specfile #(.ARCHFILE_SIZE(ARCHFILE_SIZE), .PHYSFILE_SIZE(PHYSFILE_SIZE))
            spec_af(.clk(clk), .rst(rst),
                    .update(uop_update),
                    .arch_rd1(arch_rd1), .arch_rd2(arch_rd2),
                    .arch_wr(arch_wr), .arch_wr_phys(arch_wr_phys),
                    .rollback(rollback), .rb_dump(rb_dump),
                    .arch_rd1_phys(arch_rd1_phys), .arch_rd2_phys(arch_rd2_phys),
                    .arch_wr_oldphys(arch_wr_oldphys));

    nonspecfile #(.ARCHFILE_SIZE(ARCHFILE_SIZE), .PHYSFILE_SIZE(PHYSFILE_SIZE))
            nonspec_af(.clk(clk), .rst(rst),
                       .update(rob_update),
                       .arch_wr(arch_rob_update), .arch_wr_phys(arch_rob_nonspec_phys),
                       .rollback(1'b0),
                       .arch_dump(rb_dump));

endmodule