`timescale 1ns / 1ps

module frontend_tb;

    // Clock/reset, control, and branch signals.
    reg         clk, rst, stall_in, resteer;
    reg         mispredict_BR, exception_ROB;
    reg  [31:0] addr_BR, addr_ROB;
    
    // Dummy I-cache signals (dummy responses to frontend)
    // I$ outputs (inputs to frontend_TOP)
    wire        ic_mem_hit_even, ic_mem_hit_odd;
    wire [127:0] ic_cl_even, ic_cl_odd;
    wire [31:0] ic_addr_out_even, ic_addr_out_odd;
    wire        ic_is_write_even, ic_is_write_odd;
    wire        ic_stall, ic_exception;
    
    // I$ inputs (outputs from frontend_TOP)
    wire [31:0] cache_addr_even, cache_addr_odd;
    
    // Frontend outputs
    wire        valid_out, uop, eoi;
    wire [4:0]  dr, sr1, sr2;
    wire [31:0] imm, pc;
    wire        use_imm;
    wire        exception;
    wire [9:0]  bp_bhr;
    
    // Dummy I-cache: tie the responses to constant (or simple) values.
    // In this example, the I-cache always returns a "hit" and fixed cache lines.
    assign ic_mem_hit_even  = 1'b1;
    assign ic_mem_hit_odd   = 1'b1;
    assign ic_cl_even       = 128'hDEADBEEF_DEADBEEF_DEADBEEF_DEADBEEF; // dummy even cache line
    assign ic_cl_odd        = 128'hCAFEBABE_CAFEBABE_CAFEBABE_CAFEBABE; // dummy odd cache line
    // For address outputs from I-cache, simply echo back the addresses requested.
    assign ic_addr_out_even = cache_addr_even;
    assign ic_addr_out_odd  = cache_addr_odd;
    assign ic_is_write_even = 1'b0;
    assign ic_is_write_odd  = 1'b0;
    assign ic_stall         = 1'b0;
    assign ic_exception     = 1'b0;

    // Generate a clock with period 10 ns.
    always #5 clk = ~clk;

    initial begin
        // Initialize signals
        clk = 0;
        rst = 1;
        resteer = 0;
        mispredict_BR = 0;
        exception_ROB = 0;
        stall_in = 0;
        addr_BR = 32'b0;
        addr_ROB = 32'b0;

        #20;
        rst = 0;

        // Let the frontend run normally for a short period.
        #60;

        // Stimulate a branch-based resteer:
        // For example, assume that when BR resteer is triggered,
        // the frontend uses addr_BR as a mispredicted branch target.
        #20;
        resteer = 1;
        mispredict_BR = 1;
        addr_BR = 32'h20;  // example branch target address for mispredict
        addr_ROB = 32'h30; // example branch target for exception (if used)
        
        #300;
        resteer = 0;
        mispredict_BR = 0;
        addr_BR = 32'b0;
        addr_ROB = 32'b0;
        
        #20;
        // Stimulate an exception-based resteer:
        resteer = 1;
        exception_ROB = 1;
        addr_BR = 32'h20;
        addr_ROB = 32'h30;
        
        #20;
        resteer = 0;
        exception_ROB = 0;
        addr_BR = 32'b0;
        addr_ROB = 32'b0;
        
        #20;
        $finish;
    end

    initial begin
        // Dump waveforms for inspection in a viewer.
        $dumpfile("frontend.vcd");
        $dumpvars(0, frontend_tb);
    end

    // Instantiate the full frontend.
    // Note: Many of the internal modules (c_TOP, f1_TOP, f2_TOP, d1_TOP)
    // are connected within frontend_TOP.
    frontend_TOP #(.XLEN(32), .CL_SIZE(128), .CLC_WIDTH(28))
    frontend (
        .clk(clk), 
        .rst(rst),

        // Control inputs
        .resteer(resteer),
        .stall_in(stall_in),

        // Branch misprediction inputs
        .mispredict_BR(mispredict_BR),
        .resteer_target_BR(addr_BR),
        .bhr_update_BR(10'b0),

        // Exception inputs
        .exception_ROB(exception_ROB),
        .resteer_target_ROB(addr_ROB),
        .bhr_update_ROB(10'b0),

        // Branch prediction resolution inputs
        .bp_update(1'b0),
        .bp_update_taken(1'b0),
        .br_resolved_pc(32'b0),
        .br_resolved_target(32'b0),

        // I-cache responses (simulate instruction cache)
        .mem_hit_even(ic_mem_hit_even),
        .mem_hit_odd(ic_mem_hit_odd),
        .cl_even(ic_cl_even),
        .cl_odd(ic_cl_odd),
        .addr_out_even(ic_addr_out_even),
        .addr_out_odd(ic_addr_out_odd),
        .is_write_even(ic_is_write_even),
        .is_write_odd(ic_is_write_odd),
        .ic_stall(ic_stall),
        .ic_exception(ic_exception),

        // I-cache requests (from frontend)
        .cache_addr_even(cache_addr_even),
        .cache_addr_odd(cache_addr_odd),

        // Frontend outputs
        .valid_out(valid_out),
        .uop(uop),
        .eoi(eoi),
        .dr(dr),
        .sr1(sr1),
        .sr2(sr2),
        .imm(imm),
        .use_imm(use_imm),
        .pc(pc),
        .exception(exception),
        .bp_bhr(bp_bhr)
    );
    
endmodule
