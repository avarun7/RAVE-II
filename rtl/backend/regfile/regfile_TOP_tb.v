module TOP;

    localparam CYCLE_TIME = 2.0;

    localparam ARCHFILE_SIZE = 32;
    localparam PHYSFILE_SIZE = 128;
    localparam REG_SIZE = 32;

    integer k;

    reg clk, rst;

    reg uop_update;
    reg [$clog2(ARCHFILE_SIZE)-1:0] arch_rd1, arch_rd2;
    reg [$clog2(ARCHFILE_SIZE)-1:0] arch_wr;

    reg ring_update;
    reg [$clog2(PHYSFILE_SIZE)-1:0] phys_ring;
    reg [REG_SIZE-1:0] phys_ring_val;

    reg rob_update;
    reg [$clog2(ARCHFILE_SIZE)-1:0] arch_rob_update;
    reg [$clog2(PHYSFILE_SIZE)-1:0] arch_rob_nonspec_phys;
    reg [$clog2(PHYSFILE_SIZE)-1:0] phys_rob_free;

    reg rollback;

    wire phys_rd1_rdy, phys_rd2_rdy;
    wire [$clog2(PHYSFILE_SIZE)-1:0] phys_rd1, phys_rd2;
    wire [REG_SIZE-1:0] phys_rd1_val, phys_rd2_val;

    wire [$clog2(PHYSFILE_SIZE)-1:0] phys_wr;

    wire none_free;

    regfile_TOP #(.ARCHFILE_SIZE(ARCHFILE_SIZE), .PHYSFILE_SIZE(PHYSFILE_SIZE), .REG_SIZE(REG_SIZE))
            rf(.clk(clk), .rst(rst),
               .uop_update(uop_update),
               .arch_rd1(arch_rd1), .arch_rd2(arch_rd2),
               .arch_wr(arch_wr),
               .ring_update(ring_update),
               .phys_ring(phys_ring), .phys_ring_val(phys_ring_val),
               .rob_update(rob_update),
               .arch_rob_update(arch_rob_update), .arch_rob_nonspec_phys(arch_rob_nonspec_phys), .phys_rob_free(phys_rob_free),
               .rollback(rollback),
               .phys_rd1_rdy(phys_rd1_rdy), .phys_rd2_rdy(phys_rd2_rdy),
               .phys_rd1(phys_rd1), .phys_rd2(phys_rd2),
               .phys_rd1_val(phys_rd1_val), .phys_rd2_val(phys_rd2_val),
               .phys_wr(phys_wr),
               .none_free(none_free));

    initial begin
        clk = 1'b1;
        forever #(CYCLE_TIME / 2.0) clk = ~clk;
    end

    initial begin
        rst = 1'b0;
        rollback = 1'b0;
        uop_update = 1'b0; ring_update = 1'b0; rob_update = 1'b0;
        arch_rd1 = 5'b0; arch_rd2 = 5'b0; arch_wr = 5'b0;
        phys_ring = 8'b0; phys_ring_val = 32'b0;
        arch_rob_update = 5'b0; arch_rob_nonspec_phys = 8'b0; phys_rob_free = 8'b0;
        #CYCLE_TIME;

        rst = 1'b1;

        uop_update = 1'b1;

        arch_rd1 = 5'h1f; arch_rd2 = 5'h0d; arch_wr = 5'h0d;
        #CYCLE_TIME;
        arch_rd1 = 5'h1f; arch_rd2 = 5'h0d; arch_wr = 5'h0d;
        #CYCLE_TIME;
        arch_rd1 = 5'h1f; arch_rd2 = 5'h0d; arch_wr = 5'h0d;
        #CYCLE_TIME;

        #CYCLE_TIME;
        $finish;
    end

    initial begin
        $dumpfile("test.vcd");
        $dumpvars(0, TOP);
    end

endmodule
