module frontend_TOP(    // TODO: Add right inputs here
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
        .clbp_bhr(),);

        c_TOP cache(
            .clk(clk), 
        );

        f1_TOP fetch_1(
            .clk(clk), 
        );

        f2_TOP fetch_2(
            .clk(clk), 
        );

        d1_TOP decode_1(
            .clk(clk), 
        );

        d2_TOP decode_2(
            .clk(clk), 
        );
        

endmodule