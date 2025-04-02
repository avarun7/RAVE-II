module TOP;

    localparam CYCLE_TIME = 2.0;

    localparam ARCHFILE_SIZE = 32;
    localparam PHYSFILE_SIZE = 256;
    localparam ROB_SIZE = 128;

    integer k;

    reg clk, rst;

    reg uop_update;
    reg [$clog2(ARCHFILE_SIZE)-1:0] uop_dest_arch_in;
    reg [$clog2(PHYSFILE_SIZE)-1:0] uop_dest_phys_in, uop_dest_oldphys_in;
    reg except;
    reg uop_finish;
    reg [$clog2(ROB_SIZE)-1:0] uop_finish_rob_entry;

    wire retire_uop;
    wire [$clog2(ARCHFILE_SIZE)-1:0] uop_dest_arch_out;
    wire [$clog2(PHYSFILE_SIZE)-1:0] uop_dest_phys_out, uop_dest_oldphys_out;
    wire [$clog2(ROB_SIZE)-1:0] next_rob_entry;
    wire rob_ful;

    rob_TOP #(.ARCHFILE_SIZE(ARCHFILE_SIZE), .PHYSFILE_SIZE(PHYSFILE_SIZE), .ROB_SIZE(ROB_SIZE))
            rob(.clk(clk), .rst(rst),
                .uop_update(uop_update),
                .uop_dest_arch_in(uop_dest_arch_in),
                .uop_dest_phys_in(uop_dest_phys_in), .uop_dest_oldphys_in(uop_dest_oldphys_in),
                .except(except),
                .uop_finish(uop_finish),
                .uop_finish_rob_entry(uop_finish_rob_entry),
                .retire_uop(retire_uop),
                .uop_dest_arch_out(uop_dest_arch_out),
                .uop_dest_phys_out(uop_dest_phys_out), .uop_dest_oldphys_out(uop_dest_oldphys_out),
                .next_rob_entry(next_rob_entry),
                .rob_full(rob_full));

    initial begin
        clk = 1'b1;
        forever #(CYCLE_TIME / 2.0) clk = ~clk;
    end

    initial begin
        rst = 1'b0;
        uop_update = 1'b0;
        uop_dest_arch_in = {$clog2(ARCHFILE_SIZE){1'b0}};
        uop_dest_phys_in = {$clog2(PHYSFILE_SIZE){1'b0}};
        uop_dest_oldphys_in = {$clog2(PHYSFILE_SIZE){1'b0}};
        except = 1'b0;
        uop_finish = 1'b0;
        uop_finish_rob_entry = {$clog2(ROB_SIZE){1'b0}};
        #CYCLE_TIME;

        rst = 1'b1;
        uop_update = 1'b1;

        uop_dest_arch_in = {$clog2(ARCHFILE_SIZE)/2{2'b01}};
        uop_dest_phys_in = {$clog2(PHYSFILE_SIZE)/2{2'b10}};
        uop_dest_oldphys_in = {$clog2(PHYSFILE_SIZE)/2{2'b11}};
        #CYCLE_TIME;

        uop_dest_arch_in = {$clog2(ARCHFILE_SIZE)/2{2'b10}};
        uop_dest_phys_in = {$clog2(PHYSFILE_SIZE)/2{2'b11}};
        uop_dest_oldphys_in = {$clog2(PHYSFILE_SIZE)/2{2'b01}};
        #CYCLE_TIME;

        uop_dest_arch_in = {$clog2(ARCHFILE_SIZE)/2{2'b11}};
        uop_dest_phys_in = {$clog2(PHYSFILE_SIZE)/2{2'b01}};
        uop_dest_oldphys_in = {$clog2(PHYSFILE_SIZE)/2{2'b00}};
        #CYCLE_TIME;

        uop_dest_arch_in = {$clog2(ARCHFILE_SIZE)/2{2'b00}};
        uop_dest_phys_in = {$clog2(PHYSFILE_SIZE)/2{2'b00}};
        uop_dest_oldphys_in = {$clog2(PHYSFILE_SIZE)/2{2'b01}};
        #CYCLE_TIME;

        uop_dest_arch_in = {$clog2(ARCHFILE_SIZE)/2{2'b11}};
        uop_dest_phys_in = {$clog2(PHYSFILE_SIZE)/2{2'b10}};
        uop_dest_oldphys_in = {$clog2(PHYSFILE_SIZE)/2{2'b11}};
        #CYCLE_TIME;

        #CYCLE_TIME;
        $finish;
    end

    initial begin
        $dumpfile("test.vcd");
        $dumpvars(0, TOP);
    end

endmodule
