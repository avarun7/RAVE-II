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

        .pcbp_bhr_update(),
        .clbp_bhr_update(),

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
        //TODO: add more inputs

        //outputs
        //TODO: add more outputs
    );

    regfile_TOP regfile(
        .clk(clk), .rst(),
        
        //inputs
        //TODO: add more inputs

        //outputs
        //TODO: add more outputs
    );

    ooo_engine_TOP ooo_engine(
        .clk(clk), .rst(),
        
        //inputs
        //TODO: add more inputs

        //outputs
        //TODO: add more outputs
    );

    rob_TOP rob(
        .clk(clk), .rst(),
       
        //inputs
        //TODO: add more inputs

        //outputs
        //TODO: add more outputs
    );

    l2cache_TOP l2cache(
        .clk(clk), .rst(),
        
        //inputs
        .iop(), .iaddr(), .idata_in()
        .dop(), .daddr(), .ddata_in()
        //TODO: add more inputs

        //outputs
        .idata_out(),
        .ddata_out(),
        //TODO: add more outputs
    );

endmodule
