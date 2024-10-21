module TOP();

    localparam CYCLE_TIME = 5.0;
    reg clk;

    initial begin
        clk = 1'b1;
        forever #(CYCLE_TIME / 2.0) clk = ~clk;
    end
    
    //instantiation of the modules: frontend, mapper, OOOengine, regfile, ROB, and L2$

    frontend_TOP frontend(
        .clk(clk), .rst(),

        //inputs
        .resteer(), //onehot, 2b, ROB or WB/BR
        .resteer_target_BR(), //32b - mispredict
        .resteer_target_ROB(), //32b - exception

        .bp_update(), //1b
        .bp_update_taken(), //1b
        .bp_update_target(), //32b
        .pcbp_update_bhr(),
        .clbp_update_bhr(),

        .prefetch_batch(), //64b (32b for each of the two prefetches)

        //TODO: potentially a interrupt/exception target vector signal
        
        .l2_icache_op(), // (R, W, RWITM, flush, update)
        .l2_icache_addr(), .l2_icache_data(), 
        .l2_icache_state(), 
                
        //TODO: add more inputs

        //outputs
        .valid_out(), //TODO: need to check if this is needed according to eddie's weird convention
        .uop(),
        .eoi(), //Tells if uop is end of instruction
        .dr(), .sr1(), .sr2(), .imm(),
        .use_imm(),
        .pc(),
        .exception(), //vector with types, flagged as NOP for OOO engine
        .pcbp_bhr(), 
        .clbp_bhr(),
      
        //TODO: add more outputs
    );

    mapper_TOP mapper(
        .clk(clk), .rst(),
        .flush(),

        //inputs
        .uop(),
        .eoi(),
        .dr(), .sr1(), .sr2(), .imm(),
        .use_imm(),
        .pc(),
        .exception_in() //TODO: need better name for this since it goes into and out of mapper (and rob)

        .rob_write_ptr() //comes from ROB
        .rob_full(),
        
        //TODO: add more inputs

        //outputs
        .fu_target(), //tells which func unit this instruction is using
        .rob_entry(), //index into ROB to be used for this uop
        .src1_valid(), .src1_tag(),
        .src2_valid(), .src2_tag(),
        
        .eoi_out(),
        .exception_out()

        //TODO: add more outputs
    );

    regfile_TOP regfile(
        //4 read ports, 2 write ports
        .clk(clk), .rst(),
        
        //inputs
        //TODO: add more inputs
        .regfile_read_valid_update_ready(),
        .sr1_reg(), //Indexed physically from RAT in mapper
        .sr2_reg(), //Indexed physically from RAT in mapper
        
        .wb_in_valid(),
        .wb_tag(), //index into physical reg file
        .wb_data(),

        //outputs
        .sr1_data(),
        .sr2_data(),
        //TODO: add more outputs
    );

    ooo_engine_TOP ooo_engine(
        .clk(clk), .rst(),
        .flush(),
        
        //inputs
        .exception(),
        .fu_target(),
        .rob_entry(),
        .src1_ready(), .src1_tag(), .src1_val(),
        .src2_ready(), .src2_tag(), .src2_val(),
        //TODO: add more inputs
        /*
        functional units:

        integer
        logical
        load/store
        branch
        mul/div/
        */
        
        //outputs
        //TODO: add more outputs
        .fu_full(),

        .ooo_data(),
        .ooo_rob_entry(),
        .ooo_valid(),
        .ooo_exception(),
    );

    rob_TOP rob(
        .clk(clk), .rst(),
       
        //inputs
        //TODO: add more inputs
        //Inputs from Mapper
        .rob_alloc(), //Tell whether input is valid
        .eoi_in(), //Let rob know end of instruction for atomics
        .dest_arch_in(), //Archictectural regist that this will write to
        .dest_tag_in(), //Physcial register that this will write to
        .pc_in(), //hold instruction counter for each entrance
        .uop(), 

        //outputs from OOO Engine
        .ooo_data(),
        .ooo_rob_entry(),
        .ooo_valid(),
        .ooo_exception(),

        //outputs
        .bp_update(), //1b
        .bp_update_taken(), //1b
        .bp_update_target(), //32b
        .pcbp_update_bhr(),
        .clbp_update_bhr(),

        .dest_valid(), //Tells whether the dta is the valid wb
        .dest_arch_out(), //Tells mapper which arch rat entry to update
        .dest_tag_out(), //Tells mapper which phys rat and register to update
        .dest_eoi_out(), //tell whether an instruction is finished for updating proper PC

        .rob_write_ptr(), //to mapper, tell where to write to next
        .rob_full(), //1 bit signal to let mapper know when to stall
        
        //TODO: add more outputs
    );

    l2cache_TOP l2cache(
        .clk(clk), .rst(),
        
        //inputs
        .icache_l2_op(), .icache_l2_addr(), .icache_l2_data_in(), .icache_l2_state(),
        .dcache_l2_op(), .dcache_l2_addr(), .dcache_l2_data_in(), .dcache_l2_state(),
        //TODO: add more inputs

        //outputs
        .idata_out(),
        .ddata_out(),
        //TODO: add more outputs
    );

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