module TOP();

    localparam CYCLE_TIME = 5.0;
    localparam XLEN = 32;

    localparam NUM_UOPS=128;
    localparam ARCHFILE_SIZE=16;
    localparam PHYSFILE_SIZE=128;
    localparam REG_SIZE=32;
    localparam RSV_SIZE=8;
    localparam ROB_SIZE=64;

    reg clk;
    initial begin
        clk = 1'b1;
        forever #(CYCLE_TIME / 2.0) clk = ~clk;
    end
    
    frontend_TOP frontend (
    .clk(clk), .rst(rst),

    //inputs
    .resteer(resteer),
    .stall_in(stall_in),

    .mispredict_BR(0),
    .resteer_target_BR(0), //32b - mispredict
    .bhr_update_BR(10'b0),

    .exception_ROB(exception_ROB),
    .resteer_target_ROB(addr_ROB), //32b - exception
    .bhr_update_ROB(10'b0),


    .bp_update(1'b0), //1b
    .bp_update_taken(1'b0), //1b
    .br_resolved_pc(32'b0), //32b
    .br_resolved_target(32'b0),

    .addr_even(addr_even),
       .addr_odd(addr_odd),

    // I$ Inputs
    .addr_even(addr_even),
    .addr_odd(addr_odd),
       // I$ Outputs
    .hit_even(hit_even),
    .hit_odd(hit_odd),
    .cl_even(cl_even),
    .cl_odd(cl_odd),
    .addr_out_even(addr_out_even),
    .addr_out_odd(addr_out_odd),
    .is_write_even(is_write_even),
    .is_write_odd(is_write_odd),
    .ic_stall(ic_stall),
    .exception(exception),

    .valid_out(),
    .uop(),
    .eoi(),
    .dr(),
    .sr1(),
    .sr2(),
    .imm(),
    .use_imm(),
    .pc(),
    .exception(),
    .bp_bhr()

);

    memory_system_top #(.CL_SIZE(128), .OOO_TAG_SIZE(10), .TAG_SIZE(18), .IDX_CNT(512), .OOO_ROB_SIZE(10)) 
    mem_sys_inst (
       .clk(clk),
       .rst(rst),

       // I$ Inputs
       .addr_even(addr_even),
       .addr_odd(addr_odd),

       // I$ Outputs
       .hit_even(hit_even),
       .hit_odd(hit_odd),

       .cl_even(cl_even),
       .cl_odd(cl_odd),

       .addr_out_even(addr_out_even),
       .addr_out_odd(addr_out_odd),

       .is_write_even(is_write_even),
       .is_write_odd(is_write_odd),

       .ic_stall(ic_stall),
       .exception(exception),

       //dc

       .ls_unit_alloc(ls_unit_alloc), //Data from RAS is valid or not
       .addr_in(addr_in),
       .data_in(data_in),
       .size_in(size_in), //
       .is_st_in(is_st_in), //Say whether input is ST or LD
       .ooo_tag_in(ooo_tag_in), //tag from register renaming
       .ooo_rob_in(ooo_rob_in),
       .sext(sext),

       //FROM ROB
       .rob_ret_tag_in(rob_ret_tag_in), //Show top of ROB tag
       .rob_valid(rob_valid), //bit to say whether or not the top of the rob is valid or not
       .rob_resteer(rob_resteer), //Signal if there is a flush from ROB
       
       //TO ROB
       .addr_out(addr_out),
       .data_out(data_out),
       .is_st_out(is_st_out),
       .valid_out(valid_out), //1 bit signal to tell whether or not there are cache results
       .tag_out(tag_out),
       .rob_line_out(rob_line_out),
       .is_flush_out(is_flush_out),

       //TO RSV
       .dc_stall(dc_stall)
   );


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

endmodule

// The RISC-V privileged specs define the following exceptions, in decreasing priority order:

// Instruction address misaligned
// Instruction access fault
// Illegal instruction
// Breakpoint
// Load address misaligned
// Load access fault
// Store/AMO address misaligned
// Store/AMO access fault
// Environment call from U-mode
// Environment call from M-mode
// Instruction page fault
// Load page fault
// Store/AMO page fault