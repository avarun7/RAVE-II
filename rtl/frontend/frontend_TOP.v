module frontend_TOP #(parameter XLEN=32, CL_SIZE = 128, CLC_WIDTH=26) (    
        input clk, rst,

    //inputs
        input resteer,
        input stall_in,
        input [XLEN - 1:0] resteer_target_BR, //32b - mispredict
        input [XLEN - 1:0] resteer_target_ROB, //32b - exception
        
        //from backend
        input mispredict_BR,
        input exception_ROB, //exception

        input bp_update, //1b
        input bp_update_taken, //1b
        input [XLEN - 1:0] bp_update_target, //32b
        input [9:0] pcbp_update_bhr,

        input [XLEN - 1:0] prefetch_addr,
        input prefetch_valid,

        //TODO: potentially a interrupt/exception target vector signal
        
        input [2:0] l2_icache_op, // (R, W, RWITM, flush, update)
        input [XLEN - 1:0] l2_icache_addr, 
        input [511:0] l2_icache_data, 
        input [2:0] l2_icache_state,

        //outputs
        output valid_out,
        output uop, //micro-op //TODO: decide uops
        output eoi, //Tells if uop is end of instruction
        output [4:0] dr, 
        output [4:0] sr1, 
        output [4:0] sr2, 
        output [XLEN - 1:0] imm,
        output use_imm,
        output [XLEN - 1:0] pc,
        output exception, //vector with types, flagged as NOP for OOO engine
        output [9:0] pcbp_bhr,  // bhr from pc branch predictor
        output [2:0] icache_l2_op, // (R, W, RWITM, flush, update)
        output [XLEN - 1:0] icache_l2_addr, 
        output [511:0] icache_l2_data_out, 
        output [2:0] icache_l2_state
    );

        wire [CLC_WIDTH - 1:0] clc_even, clc_odd;
    
        c_TOP #(.XLEN(XLEN), .CLC_WIDTH(CLC_WIDTH)) control(
            .clk(clk), .rst(rst),

            //inputs
            .stall_in(stall_in),
            .resteer(resteer),
            
            .bp_update_D1(1'b0), //1b
            .resteer_target_D1(32'b0),
            .resteer_taken_D1(1'b0),
            .clbp_update_bhr_D1(10'b0), 

            .bp_update_BR(1'b0), //1b
            .resteer_target_BR(resteer_target_BR),
            .resteer_taken_BR(mispredict_BR),
            .clbp_update_bhr_BR(10'b0),

            .bp_update_ROB(1'b0), //1b
            .resteer_target_ROB(resteer_target_ROB),
            .resteer_taken_ROB(exception_ROB),
            .clbp_update_bhr_ROB(10'b0),  

            .ras_push(1'b0),
            .ras_pop(1'b0),
            .ras_ret_addr(32'b0),
            .ras_valid_in(1'b0),
            
            //outputs
            .clc_even(clc_even),
            .clc_odd(clc_odd)
        );

        wire [XLEN - 1:0] f1_addr_even, f1_addr_odd;
        wire f1_clc_even_valid, f1_clc_odd_valid, f1_pcd, f1_hit, f1_exceptions;

        f1_TOP #(.XLEN(XLEN), .CLC_WIDTH(CLC_WIDTH)) fetch_1(
            .clk(clk), .rst(rst),
            //inputs
            .clc_even_in(clc_even),
            .clc_odd_in(clc_odd),
            
            //outputs
            .pcd(),         //don't cache MMIO
            .hit(),
            .exceptions(),

            .addr_even_valid(f1_clc_even_valid),
            .addr_odd_valid(f1_clc_odd_valid),

            .addr_even(f1_addr_even),
            .addr_odd(f1_addr_odd)
        );

        wire mem_hit_even, mem_hit_odd;
        wire [CL_SIZE-1:0] cl_even, cl_odd;
        wire [XLEN-1:0] addr_out_even, addr_out_odd;
        wire is_write_even, is_write_odd;
        wire mem_sys_stall;

        memory_system_top icache (
            .clk(clk), 
            .rst(rst),
            .addr_even(f1_addr_even),
            .addr_odd(f1_addr_odd),
    
            //outputs
            .hit_even(mem_hit_even),
            .hit_odd(mem_hit_odd),
            .cl_even(cl_even),
            .cl_odd(cl_odd),
    
            .addr_out_even(addr_out_even),
            .addr_out_odd(addr_out_odd),
            .is_write_even(is_write_even),
            .is_write_odd(is_write_odd),
            .stall(mem_sys_stall),
            .exception()        
        );

        // f2_TOP #(.XLEN(XLEN)) fetch_2( 
        //     .clk(clk),  .rst(rst),
        //     //inputs
        //     .stall_in(stall_in),
        //     .clc_paddr(f1_clc_paddr),
        //     .clc_vaddr(),
        //     .clc_valid(),

        //     .clc_data_in_even(cl_even),
        //     .clc_data_in_odd(cl_odd),

        //     .pcd(),         //don't cache MMIO
        //     .hit(),
        //     .way(),
        //     .exceptions(),

        //     .bppf_paddr(),
        //     .bppf_valid(),

        //     .nlpf_paddr(),
        //     .nlpf_valid(),

        //     //TAG_STORE
        //     .tag_evict(),

        //     //DATASTORE
        //     .l2_icache_op(), .l2_icache_addr(), .l2_icache_data_in(), .l2_icache_state(),
            


        //     //outputs
        //     .exceptions_out(),
        //     //Tag Store Overwrite
        //     .tag_ovrw(),
        //     .way_ovrw(),

        //     .IBuff_out(),


        //     //Prefetch
        //     .prefetch_valid(),
        //     .prefetch_addr(),

        //     //Datastore
        //     .icache_l2_op(), .icache_l2_addr(), .icache_l2_data_out(), .icache_l2_state()

            
        // );

        // d1_TOP #(.XLEN(XLEN)) opcode_decode(
        //     .clk(clk), .rst(),
        //     // inputs
        //     .exception_in(),
        //     .IBuff_in(),
        //     .resteer(), //onehot, 2b, ROB or WB/BR
        //     .resteer_target_BR(), //32b - mispredict
        //     .resteer_target_ROB(), //32b - exception
    
        //     .bp_update(), //1b
        //     .bp_update_taken(), //1b
        //     .bp_update_target(), //32b
        //     .pcbp_update_bhr(),
            
        //     // outputs
        //     .pc(),

        //     .exception_out(),
        //     .opcode_format(), //format of the instruction - compressed or not
        //     .instruction_out(), //expanded instruction

        //     .resteer_D1(),
        //     .resteer_target_D1(),
        //     .resteer_taken(),
        //     .clbp_update_bhr_D1(), // bhr to update in cache line branch predictor

        //     .ras_push(),
        //     .ras_pop(),
        //     .ras_ret_addr()


        // );

        // d2_TOP #(.XLEN(XLEN)) decode(
        //     .clk(clk), .rst(),
        //     // Inputs
        //     .pc_in(),
            
        //     .exception_in(),
        //     .uop_count(),
        //     .opcode_format(),
        //     .instruction_in(),
            
        //     // Outputs
        //     .uop(),
        //     .eoi(),
        //     .dr(), .sr1(), .sr2(), .imm(),
        //     .use_imm(),
        //     .pc_out(),
        //     .exception_out()
        // );
        

endmodule
