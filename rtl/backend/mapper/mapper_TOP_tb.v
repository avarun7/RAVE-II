module TOP;

    localparam CYCLE_TIME = 2.0;

    localparam NUM_UOPS = 32;
    localparam XLEN = 32;
    localparam ARCHFILE_SIZE = 32;
    localparam PHYSFILE_SIZE = 128;
    localparam ROB_SIZE = 32;

    integer k;

    reg clk, rst;

    reg uop_ready;
    reg [$clog2(NUM_UOPS)-1:0] uop_in;
    reg eoi_in;
    reg [$clog2(ARCHFILE_SIZE)-1:0] dest_arch_in;
    reg [XLEN-1:0] imm_in;
    reg use_imm_in;
    reg [31:0] pc_in;
    reg except_in;
    reg rf_src1_rdy, rf_src2_rdy;
    reg [$clog2(PHYSFILE_SIZE)-1:0] rf_src1_tag, rf_src2_tag;
    reg [XLEN-1:0] rf_src1_val, rf_src2_val;
    reg [$clog2(PHYSFILE_SIZE)-1:0] rf_dest_tag, rf_dest_oldtag;
    reg rob_full;
    reg [$clog2(ROB_SIZE)-1:0] rob_entry_in;

    wire [$clog2(NUM_UOPS)-1:0] uop_out;
    wire eoi_out;
    wire op1_rdy_out, op2_rdy_out;
    wire [$clog2(PHYSFILE_SIZE)-1:0] op1_tag_out, op2_tag_out;
    wire [XLEN-1:0] op1_val_out, op2_val_out;
    wire [$clog2(PHYSFILE_SIZE)-1:0] dest_tag_out;
    wire pc_out;
    wire [$clog2(ROB_SIZE)-1:0] rob_entry_out;
    wire alloc_rob;
    wire [$clog2(ARCHFILE_SIZE)-1:0] dest_arch_out;
    wire [$clog2(PHYSFILE_SIZE)-1:0] dest_phys_out, dest_oldphys_out;
    wire except_out;

    mapper_TOP #(.NUM_UOPS(NUM_UOPS), .XLEN(XLEN), .ARCHFILE_SIZE(ARCHFILE_SIZE),
                 .PHYSFILE_SIZE(PHYSFILE_SIZE), .ROB_SIZE(ROB_SIZE))
            map(.clk(clk), .rst(rst),
                    //uopQ inputs
                .uop_ready(uop_ready), .uop_in(uop_in), .eoi_in(eoi_in),
                .dest_arch_in(dest_arch_in),
                .imm_in(imm_in), .use_imm_in(use_imm_in),
                .pc_in(pc_in),
                .except_in(except_in),
                    //RF inputs
                .rf_src1_rdy(rf_src1_rdy), .rf_src2_rdy(rf_src2_rdy),
                .rf_src1_tag(rf_src1_tag), .rf_src2_tag(rf_src2_tag),
                .rf_src1_val(rf_src1_val), .rf_src2_val(rf_src2_val),
                .rf_dest_tag(rf_dest_tag), .rf_dest_oldtag(rf_dest_oldtag),
                    //ROB inputs
                .rob_full(rob_full),
                .rob_entry_in(rob_entry_in),
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
                .dest_arch_out(dest_arch_out),
                .dest_phys_out(dest_phys_out), .dest_oldphys_out(dest_oldphys_out),                 
                .except_out(except_out));

    initial begin
        clk = 1'b1;
        forever #(CYCLE_TIME / 2.0) clk = ~clk;
    end

    initial begin
        rst = 1'b0;
        uop_ready = 1'b0; uop_in = {NUM_UOPS{1'b0}}; eoi_in = 1'b0;
        dest_arch_in = {$clog2(ARCHFILE_SIZE){1'b0}};
        imm_in = {XLEN{1'b0}}; use_imm_in = 1'b0;
        pc_in = 32'b0;
        except_in = 1'b0;
        rf_src1_rdy = 1'b0; rf_src2_rdy = 1'b0;
        rf_src1_tag = {$clog2(PHYSFILE_SIZE){1'b0}}; rf_src2_tag = {$clog2(PHYSFILE_SIZE){1'b0}};
        rf_src1_val = {XLEN{1'b0}}; rf_src2_val = {XLEN{1'b0}};
        rf_dest_tag = {$clog2(PHYSFILE_SIZE){1'b0}}; rf_dest_oldtag = {$clog2(PHYSFILE_SIZE){1'b0}};
        rob_full  = 1'b0; rob_entry_in = {$clog2(ROB_SIZE){1'b0}};
        #CYCLE_TIME;

        rst = 1'b1;

        uop_ready = 1'b1;
        dest_arch_in = {$clog2(ARCHFILE_SIZE){1'b1}};
        rf_src1_rdy = 1'b0; rf_src2_rdy = 1'b1;
        rf_src1_tag = {$clog2(PHYSFILE_SIZE){1'b0}}; rf_src2_tag = {$clog2(PHYSFILE_SIZE){1'b1}};
        rf_src1_val = {XLEN{1'b0}}; rf_src2_val = {XLEN{1'b1}};
        rf_dest_tag = {$clog2(PHYSFILE_SIZE){1'b0}}; rf_dest_oldtag = {$clog2(PHYSFILE_SIZE){1'b1}};

        uop_in = {NUM_UOPS/2{2'b00}}; eoi_in = 1'b0;
        imm_in = {XLEN/2{2'b00}}; use_imm_in = 1'b0;
        pc_in = 32'b0;
        rob_entry_in = {$clog2(ROB_SIZE)/2{2'b00}};
        #CYCLE_TIME;
        uop_in = {NUM_UOPS/2{2'b01}}; eoi_in = 1'b1;
        imm_in = {XLEN/2{2'b01}}; use_imm_in = 1'b1;
        pc_in = 32'h1;
        rob_entry_in = {$clog2(ROB_SIZE)/2{2'b01}};
        #CYCLE_TIME;
        uop_in = {NUM_UOPS/2{2'b10}}; eoi_in = 1'b0;
        imm_in = {XLEN/2{2'b10}}; use_imm_in = 1'b0;
        pc_in = 32'h2;
        rob_entry_in = {$clog2(ROB_SIZE)/2{2'b10}};
        #CYCLE_TIME;
        uop_in = {NUM_UOPS/2{2'b11}}; eoi_in = 1'b1;
        imm_in = {XLEN/2{2'b11}}; use_imm_in = 1'b1;
        pc_in = 32'h3;
        rob_entry_in = {$clog2(ROB_SIZE)/2{2'b11}};
        #CYCLE_TIME;

        #CYCLE_TIME;
        $finish;
    end

    initial begin
        $dumpfile("test.fst");
        $dumpvars(0, TOP);
    end

endmodule