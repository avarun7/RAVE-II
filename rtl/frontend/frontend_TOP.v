module frontend_TOP(    
        input clk, rst,

    //inputs
        input resteer, //onehot, 2b, ROB or WB/BR
        input [31:0] resteer_target_BR, //32b - mispredict
        input [31:0] resteer_target_ROB, //32b - exception

        input bp_update, //1b
        input bp_update_taken, //1b
        input [31:0] bp_update_target, //32b
        input [9:0] pcbp_update_bhr,
        input [9:0] clbp_update_bhr,

        input [31:0] prefetch_addr, 
        input prefetch_valid,

        //TODO: potentially a interrupt/exception target vector signal
        
        input [2:0] l2_icache_op, // (R, W, RWITM, flush, update)
        input [31:0] l2_icache_addr, 
        input [511:0] l2_icache_data,  
        input [2:0] l2_icache_state, 
               
        //outputs
        output valid_out,
        output uop, //micro-op //TODO: decide uops
        output eoi, //Tells if uop is end of instruction
        output [4:0] dr, 
        output [4:0] sr1, 
        output [4:0] sr2, 
        output [31:0] imm,
        output use_imm,
        output [31:0] pc,
        output exception, //vector with types, flagged as NOP for OOO engine
        output [9:0] pcbp_bhr,  // bhr from pc branch predictor
        output [9:0] clbp_bhr,  // bhr from cache line branch predictor
        output [2:0] icache_l2_op, // (R, W, RWITM, flush, update)
        output [31:0] icache_l2_addr, 
        output [511:0] icache_l2_data_out, 
        output [2:0] icache_l2_state
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
            .bppf() //branch-predictor prefetch

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
            .tag_out()
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
            .l2_icache_op(), .l2_icache_addr(), .l2_icache_data_in(), .l2_icache_state(),
            


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
            .icache_l2_op(), .icache_l2_addr(), .icache_l2_data_out(), .icache_l2_state()

            
        );

        d1_TOP opcode_decode(
            .clk(clk), .rst(),
            // inputs
            .exception_in(),
            .IBuff_in(),
            .resteer(), //onehot, 2b, ROB or WB/BR
            .resteer_target_BR(), //32b - mispredict
            .resteer_target_ROB(), //32b - exception
    
            .bp_update(), //1b
            .bp_update_taken(), //1b
            .bp_update_target(), //32b
            .pcbp_update_bhr(),
            
            // outputs
            .pc(),

            .exception_out(),
            .opcode_format(), //format of the instruction - compressed or not
            .instruction_out(), //expanded instruction

            .resteer_D1(),
            .resteer_target_D1(),
            .resteer_taken(),
            .clbp_update_bhr_D1(), // bhr to update in cache line branch predictor

            .ras_push(),
            .ras_pop(),
            .ras_ret_addr()


        );

        d2_TOP decode(
            .clk(clk), .rst(),
            // Inputs
            .pc_in(),
            
            .exception_in(),
            .uop_count(),
            .opcode_format(),
            .instruction_in(),
            
            // Outputs
            .uop(),
            .eoi(),
            .dr(), .sr1(), .sr2(), .imm(),
            .use_imm(),
            .pc_out(),
            .exception_out()
        );
        

endmodule
