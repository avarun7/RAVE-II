module frontend_TOP(    // TODO: Add right inputs here
        clk, rst,

        //inputs
        resteer(), //onehot, 2b, ROB or WB/BR
        resteer_target_BR(), //32b - mispredict
        resteer_target_ROB(), //32b - exception

        bp_update(), //1b
        bp_update_taken(), //1b
        bp_update_target(), //32b
        pcbp_update_bhr(),
        clbp_update_bhr(),

        prefetch_batch(), //64b (32b for each of the two prefetches)

        //TODO: potentially a interrupt/exception target vector signal
    
        l2_icache_op(), // (R, W, RWITM, flush, update)
        l2_icache_addr(), .l2_icache_data(), 
        l2_icache_state(), 
               
        //TODO: add more inputs

        //outputs
        valid_out(), //TODO: need to check if this is needed according to eddie's weird convention
        uop(), //micro-op
        eoi(), //Tells if uop is end of instruction
        dr(), .sr1(), .sr2(), .imm(),
        use_imm(),
        pc(),
        exception(), //vector with types, flagged as NOP for OOO engine
        pcbp_bhr(),  // bhr from pc branch predictor
        clbp_bhr(),  // bhr from cache line branch predictor
        l2_icache_op(), // (R, W, RWITM, flush, update)
        l2_icache_addr(), 
        l2_icache_data_out(), 
        l2_icache_state()
        );

        c_TOP control(
            .clk(clk), .rst(),

            //inputs
            .stall_in(),
            .resteer(),
            
            .bp_update_D1(), //1b
            .resteer_target_D1(),
            .resteer_taken_D1(),
            .clbp_update_bhr_D1(),  


            .bp_update_BR(), //1b
            .resteer_target_BR(),
            .resteer_taken_BR(),
            .clbp_update_bhr_BR(),  

            .bp_update_ROB(), //1b
            .resteer_target_ROB(),
            .resteer_taken_ROB(),
            .clbp_update_bhr_ROB(),  

            .ras_push(),
            .ras_pop(),
            .ras_ret_addr(),
            
            //outputs
            .clc(), //cache line counter
            .nlpf(), //next-line prefetch
            .bppf(), //branch-predictor prefetch

        );

        f1_TOP fetch_1( //TLB + TAGSTORE
            .clk(clk), .rst(),
            //inputs
            .clc_in(),
            .bppf(),
            .nlpf(),
            
            //TAG_STORE
            .tag_in(),
            .way_in(),
            .evict_in(),

            //outputs
            .clc_paddr(),
            .clc_vaddr(),
            .pcd(),         //don't cache MMIO
            .hit(),
            .way(),
            .exceptions(),

            .bppf_paddr(),
            .bppf_valid(),

            .nlpf_paddr(),
            .nlpf_valid(),

            //TAG_STORE
            .tag_out(),
        );

        f2_TOP fetch_2( 
            .clk(clk),  .rst(),
            //inputs
            .clc_paddr(),
            .clc_vaddr(),
            .pcd(),         //don't cache MMIO
            .hit(),
            .way(),
            .exceptions(),

            .bppf_paddr(),
            .bppf_valid(),

            .nlpf_paddr(),
            .nlpf_valid(),

            //TAG_STORE
            .tag_evict(),

            //DATASTORE
            .icache_l2_op(), .icache_l2_addr(), .icache_l2_data_in(), .icache_l2_state(),
            


            //outputs
            .exceptions_out(),
            //Tag Store Overwrite
            .tag_ovrw(),
            .way_ovrw(),

            .IBuff_out(),


            //Prefetch
            .prefetch_valid(),
            .prefetch_addr(),

            //Datastore
            .l2_icache_op(), .l2_icache_addr(), .l2_icache_data_out(), .l2_icache_state(),

            
        );

        d1_TOP opcode_decode(
            .clk(clk), .rst(),
            // inputs
            .exceptions_in(),
            .IBUFF_in(),
            .resteer(), //onehot, 2b, ROB or WB/BR
            .resteer_target_BR(), //32b - mispredict
            .resteer_target_ROB(), //32b - exception
    
            .bp_update(), //1b
            .bp_update_taken(), //1b
            .bp_update_target(), //32b
            .pcbp_update_bhr(),
            
            // outputs
            .pc(),

            .exceptions_out(),
            .opcode_format(), //format of the instruction - compressed or not
            .instruction_out(), //expanded instruction

            .resteer_D1(),
            .resteer_target_D1(),
            .resteer_taken(),
            .clbp_update_bhr_D1(), // bhr to update in cache line branch predictor

            .ras_push(),
            .ras_pop(),
            .ras_ret_addr(), 


        );

        d2_TOP decode(
            .clk(clk), .rst(),
            // Inputs
            .pc(),
            
            .exceptions_in(),
            .uop_count(),
            .opcode_format(),
            .instruction_in(),
            
            // Outputs
            .uop(),
            .eoi(),
            .dr(), .sr1(), .sr2(), .imm(),
            .use_imm(),
            .pc(),
            .exception_out()
        );
        

endmodule