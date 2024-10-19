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
        .resteer(), //onehot, 2b
        .resteer_target_BR(), //32b
        .resteer_target_ROB(), //32b

        .bp_update(), //1b
        .bp_update_taken(), //1b
        .bp_update_target(), //32b
        .pcbp_update_bhr(),
        .clbp_update_bhr(),

        .prefetch_batch(), //64b (32b for each of the two prefetches)

        //TODO: potentially a interrupt/exception target signal
        
        .l2_icache_op(), // (R, W, RWITM, flush, update)
        .l2_icache_addr(), .l2_icache_data(), 
        .l2_icache_state(), 
        
        
        //TODO: add more inputs

        //outputs
        .uop(),
        .dr(), .sr1(), .sr2(), .imm(),
        .pc(),
        .exception(), //vector with types, flagged as NOP for OOO engine


        //TODO: add more outputs
    );

    mapper_TOP mapper(
        .clk(clk), .rst(),
        
        //inputs
        .uop(),
        .dr(), .sr1(), .sr2(), .imm(),
        .pc(),
        .exception() //TODO: need better name for this since it goes into and out of mapper (and rob)

        .next_rob_entry()
        //TODO: add more inputs

        //outputs
        .fu(),
        .rob_entry(),
        .src1_ready(), .src1_tag(), .src1_val(),
        .src2_ready(), .src2_tag(), .src2_val(),

        .exception()

        //TODO: add more outputs
    );

    regfile_TOP regfile( //TODO: how many read ports are we gonna need since the OOOengine is gonna need to check for readiness
        .clk(clk), .rst(),
        
        //inputs
        //TODO: add more inputs

        //outputs
        //TODO: add more outputs
    );

    ooo_engine_TOP ooo_engine(
        .clk(clk), .rst(),
        
        //inputs
        .fu(),
        .rob_entry(),
        .src1_ready(), .src1_tag(), .src1_val(),
        .src2_ready(), .src2_tag(), .src2_val(),
        //TODO: add more inputs

        //outputs
        //TODO: add more outputs
    );

    rob_TOP rob(
        .clk(clk), .rst(),
       
        //inputs
        //TODO: add more inputs

        //outputs
        .bp_update(), //1b
        .bp_update_taken(), //1b
        .bp_update_target(), //32b
        .pcbp_update_bhr(),
        .clbp_update_bhr(),

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
