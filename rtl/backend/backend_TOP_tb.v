module TOP;

    localparam CYCLE_TIME = 2.0;

    localparam NUM_UOPS=128;
    localparam XLEN=32;
    localparam ARCHFILE_SIZE=16;
    localparam PHYSFILE_SIZE=128;
    localparam REG_SIZE=32;
    localparam RSV_SIZE=8;
    localparam ROB_SIZE=64;

    integer k;

    reg clk, rst;

    reg uop_ready;
    reg [$clog2(NUM_UOPS)-1:0] uop;
    reg eoi;
    reg [XLEN-1:0] imm;
    reg use_imm;
    reg [31:0] pc;
    reg except;
    reg [$clog2(ARCHFILE_SIZE)-1:0] src1_arch, src2_arch;
    reg [$clog2(ARCHFILE_SIZE)-1:0] dest_arch;

    backend_TOP #(.NUM_UOPS(NUM_UOPS), .XLEN(XLEN), .ARCHFILE_SIZE(ARCHFILE_SIZE),
                  .PHYSFILE_SIZE(PHYSFILE_SIZE), .REG_SIZE(REG_SIZE), .RSV_SIZE(RSV_SIZE),
                  .ROB_SIZE(ROB_SIZE))
            be(.clk(clk), .rst(rst),
               .uop_ready(uop_ready), .uop(uop), .eoi(eoi),
               .imm(imm), .use_imm(use_imm),
               .pc(pc),
               .except(except),
               .src1_arch(src1_arch), .src2_arch(src2_arch),
               .dest_arch(dest_arch));

    initial begin
        clk = 1'b1;
        pc = 32'b0;
        forever #(CYCLE_TIME / 2.0) clk = ~clk;
    end

    initial begin
        rst = 1'b0;
        uop_ready = 1'b0; uop = {$clog2(NUM_UOPS){1'b0}}; eoi = 1'b0;
        imm = {XLEN{1'b0}}; use_imm = 1'b0;
        except = 1'b0;
        src1_arch = {$clog2(ARCHFILE_SIZE){1'b0}}; src2_arch = {$clog2(ARCHFILE_SIZE){1'b0}};
        dest_arch = {$clog2(ARCHFILE_SIZE){1'b0}};
        #CYCLE_TIME;

        rst = 1'b1;

        uop_ready = 1'b1;

        uop = 7'b0100000;
        src1_arch = {$clog2(ARCHFILE_SIZE){1'b0}}; src2_arch = {$clog2(ARCHFILE_SIZE){1'b0}};
        dest_arch = {$clog2(ARCHFILE_SIZE){1'b0}};
        imm = {{XLEN-1{1'b0}},1'b1}; use_imm = 1'b1;

        #CYCLE_TIME;
        #CYCLE_TIME;
        #CYCLE_TIME;
        #CYCLE_TIME;
        #CYCLE_TIME;
        #CYCLE_TIME;
        #CYCLE_TIME;
        #CYCLE_TIME;
        #CYCLE_TIME;

        uop_ready = 1'b0;

        #CYCLE_TIME;
        #CYCLE_TIME;
        #CYCLE_TIME;
        #CYCLE_TIME;
        #CYCLE_TIME;
        #CYCLE_TIME;
        #CYCLE_TIME;
        #CYCLE_TIME;
        #CYCLE_TIME;

        uop_ready = 1'b1;

        
        #CYCLE_TIME;
        #CYCLE_TIME;
        #CYCLE_TIME;
        #CYCLE_TIME;
        #CYCLE_TIME;
        #CYCLE_TIME;
        #CYCLE_TIME;
        #CYCLE_TIME;
        #CYCLE_TIME;

        uop_ready = 1'b0;

        #CYCLE_TIME;
        #CYCLE_TIME;
        #CYCLE_TIME;
        #CYCLE_TIME;
        #CYCLE_TIME;
        #CYCLE_TIME;
        #CYCLE_TIME;
        #CYCLE_TIME;
        #CYCLE_TIME;

                uop_ready = 1'b1;

        
        #CYCLE_TIME;
        #CYCLE_TIME;
        #CYCLE_TIME;
        #CYCLE_TIME;
        #CYCLE_TIME;
        #CYCLE_TIME;
        #CYCLE_TIME;
        #CYCLE_TIME;
        #CYCLE_TIME;

        uop_ready = 1'b0;

        #CYCLE_TIME;
        #CYCLE_TIME;
        #CYCLE_TIME;
        #CYCLE_TIME;
        #CYCLE_TIME;
        #CYCLE_TIME;
        #CYCLE_TIME;
        #CYCLE_TIME;
        #CYCLE_TIME;

        #CYCLE_TIME;
        $finish;
    end

    always@(posedge clk) begin
        pc = pc + 1;
    end

    initial begin
        $dumpfile("test.vcd");
        $dumpvars(0, TOP);
    end

endmodule
