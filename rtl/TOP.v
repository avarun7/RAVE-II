module TOP();

    localparam CYCLE_TIME = 5.0;
    localparam XLEN = 32;

    reg clk;
    initial begin
        clk = 1'b1;
        forever #(CYCLE_TIME / 2.0) clk = ~clk;
    end
    
    //instantiation of the modules: frontend, mapper, OOOengine, regfile, ROB, and L2$

    frontend_TOP #(.XLEN(XLEN)) frontend (
        .clk(clk), .rst(),

        //inputs
        .resteer(), //onehot, 2b, ROB or WB/BR
        .resteer_target_BR(), //32b - mispredict
        .resteer_target_ROB(), //32b - exception

        .bp_update(), //1b
        .bp_update_taken(), //1b
        .bp_update_target(), //32b
        .pcbp_update_bhr(), // bhr to update in pc branch predictor
        .clbp_update_bhr(), // bhr to update in cache line branch predictor

        .prefetch_addr(), //32b
        .prefetch_valid(),

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
      
        .icache_l2_op(), .icache_l2_addr(), .icache_l2_data_out(), .icache_l2_state()
        //TODO: add more outputs
    );

    memory_system_top icache (
        .clk(clk), 
        .rst(rst),
        .addr_even(),
        .addr_odd(),

        //outputs
        .hit_even(),
        .hit_odd(),
        .cl_even(),
        .cl_odd(),

        .addr_out_even(),
        .addr_out_odd(),
        .is_write_even(),
        .is_write_odd(),
        .stall(),
        .exception()        
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
        .exception_in(), //TODO: need better name for this since it goes into and out of mapper (and rob)

        .rob_write_ptr(), //comes from ROB
        .rob_full(),

        .fu_full(), //one hot, one for each FU
        
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
/*
    regfile_TOP regfile(
        //2 read ports, 1 write ports

        //TODO: Debating between versions, read data and copy into RS at mapper or read data after RS going into FU
        .clk(clk), .rst(),
        
        //inputs
        //TODO: add more inputs
        // .regfile_is_read_valid_update_is_ready(),
        .sr1_reg_l(), //Indexed physically from RS
        .sr2_reg_l(), //Indexed physically from RS

        .sr1_reg_i(), //Indexed physically from RS
        .sr2_reg_i(), //Indexed physically from RS

        .sr1_reg_ls(), //Indexed physically from RS
        .sr2_reg_ls(), //Indexed physically from RS

        .sr1_reg_b(), //Indexed physically from RS
        .sr2_reg_b(), //Indexed physically from RS

        .sr1_reg_md(), //Indexed physically from RS
        .sr2_reg_md(), //Indexed physically from RS
        
        .wb_wr_l(),
        .wb_tag_l(), //index into physical reg file
        .wb_data_l(),

        .wb_wr_i(),
        .wb_tag_i(), //index into physical reg file
        .wb_data_i(),

        .wb_wr_ls(),
        .wb_tag_ls(), //index into physical reg file
        .wb_data_ls(),

        .wb_wr_b(),
        .wb_tag_b(), //index into physical reg file
        .wb_data_b(),

        .wb_wr_md(),
        .wb_tag_md(), //index into physical reg file
        .wb_data_md(),

        //outputs
        .sr1_data_l(),
        .sr2_data_l(),
        .valid_l(),

        .sr1_data_i(),
        .sr2_data_i(),
        .valid_i(),

        .sr1_data_ls(),
        .sr2_data_ls(),
        .valid_ls(),

        .sr1_data_b(),
        .sr2_data_b(),
        .valid_b(),

        .sr1_data_md(),
        .sr2_data_md(),
        .valid_md()
        //TODO: add more outputs
    );

    ooo_engine_TOP ooo_engine(
        .clk(clk), .rst(),
        .flush(),
        
        .l2_dcache_op(), .l2_dcache_addr(), .l2_dcache_data_out(), .l2_dcache_state(),

        //inputs
        .exception(),
        .fu_target(),
        .rob_entry(),
        .src1_ready(), .src1_tag(), .src1_val(),
        .src2_ready(), .src2_tag(), .src2_val(),

        //Get data from REGFILE
        .sr1_data_l(),
        .sr2_data_l(),
        .valid_l(),

        .sr1_data_i(),
        .sr2_data_i(),
        .valid_i(),

        .sr1_data_ls(),
        .sr2_data_ls(),
        .valid_ls(),

        .sr1_data_b(),
        .sr2_data_b(),
        .valid_b(),

        .sr1_data_md(),
        .sr2_data_md(),
        .valid_md(),
        //TODO: add more inputs
        

        // functional units:

        // integer
        // logical
        // load/store
        // branch
        // mul/div/mod?
        
        
        //outputs
        //Broadcast to the regfile 
        .dcache_l2_op(), .dcache_l2_addr(), .dcache_l2_data_in(), .dcache_l2_state(),


        .wb_wr_log(),
        .wb_tag_log(), //index into physical reg file
        .wb_data_log(),

        .wb_wr_int(),
        .wb_tag_int(), //index into physical reg file
        .wb_data_int(),

        .wb_wr_ls(),
        .wb_tag_ls(), //index into physical reg file
        .wb_data_ls(),

        .wb_wr_br(),
        .wb_tag_br(), //index into physical reg file
        .wb_data_br(),

        .wb_wr_md(),
        .wb_tag_md(), //index into physical reg file
        .wb_data_md(),

        .fu_full(),  // One-hot encoding

        .ooo_data(),
        .ooo_rob_entry(),
        .ooo_valid(),
        .ooo_exception()
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
        .rob_full() //1 bit signal to let mapper know when to stall
        
        //TODO: add more outputs
    );

    
    l2cache_TOP l2cache(
        .clk(clk), .rst(),
        
        //inputs
        //Ops = R, SW (also known as RWITM), Flush, Update State)
        .icache_l2_op(), .icache_l2_addr(), .icache_l2_data_in(), .icache_l2_state(),
        .dcache_l2_op(), .dcache_l2_addr(), .dcache_l2_data_in(), .dcache_l2_state(),

        .prefetch_addr(), //32b
        .prefetch_valid(),

        //BUS
        //Address - 32 bits
        //Bus_data - 64 bits
        //Sender - 4 bits
        //Reciever - 4 bits
        // RW - 1 bit
        .BUS(),
        .bus_req(),
        .bus_ack(),
        .bus_grant(),
        //TODO: add more inputs

        //outputs
        .l2_icache_op(), .l2_icache_addr(), .l2_icache_data_out(), .l2_icache_state(),
        .l2_dcache_op(), .l2_dcache_addr(), .l2_dcache_data_out(), .l2_dcache_state()
        //TODO: add more outputs
    );

    */

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