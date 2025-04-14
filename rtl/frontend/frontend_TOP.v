module frontend_TOP #(parameter XLEN=32, CL_SIZE = 128, CLC_WIDTH=28) (   
    input clk, rst,

    //inputs
    input resteer,
    input stall_in,

    input mispredict_BR,
    input [XLEN - 1:0] resteer_target_BR, //32b - mispredict
    input [9:0] bhr_update_BR,
    
    //from backend
    input exception_ROB, //exception
    input [XLEN - 1:0] resteer_target_ROB, //32b - exception
    input [9:0] bhr_update_ROB,

    input bp_update, //1b
    input bp_update_taken,                  // Branch taken/not-taken decision 
    input [XLEN - 1:0] br_resolved_pc,      // Address of resolved branch
    input [XLEN - 1:0] br_resolved_target,  // Branch taken/not-taken decision
    
    // I$ Outputs
    input wire mem_hit_even, mem_hit_odd,
    input wire [CL_SIZE-1:0] cl_even, cl_odd,
    input wire [XLEN-1:0] addr_out_even, addr_out_odd,
    input wire is_write_even, is_write_odd,
    input ic_stall,
    input ic_exception,

    // I$ Inputs
    output wire [XLEN - 1:0] cache_addr_even, cache_addr_odd,

    //outputs
    output uop_ready_out, 
    output [6:0] uop_out, 
    output eoi_out,
    output [XLEN-1:0] imm_out, 
    output use_imm_out,
    output [XLEN-1:0] pc_out,
    output except_out,
    output [4:0] src1_arch_out, 
    output [4:0] src2_arch_out,
    output [4:0] dest_arch_out,
    output exception, //vector with types, flagged as NOP for OOO engine
    output [9:0] bp_bhr  // bhr from pc branch predictor
);

    integer file;
    integer cycle_number = 0;
    initial begin
        file = $fopen("frontend.log", "w");
        if (file == 0) begin
            $display("Error: Failed to open file frontend.log");
            $finish;
        end
    end

    wire [CLC_WIDTH - 1:0] clc_even, clc_odd;
    wire [XLEN - 1:0] c1_ras_target; 
    wire c1_ras_valid;

    c_TOP #(.XLEN(XLEN), .CLC_WIDTH(CLC_WIDTH)) control(
        .clk(clk), .rst(rst),

        //inputs
        .stall_in(stall_in),
        .resteer(resteer),
        
        .resteer_target_D1(32'b0),
        .resteer_taken_D1(1'b0),

        .resteer_target_BR(resteer_target_BR),
        .resteer_taken_BR(mispredict_BR),

        .resteer_target_ROB(resteer_target_ROB),
        .resteer_taken_ROB(exception_ROB),

        .ras_push(1'b0),
        .ras_pop(1'b0),
        .ras_ret_addr(32'b0),
        .ras_valid_in(1'b0),

        //outputs
        .clc_even(clc_even),
        .clc_odd(clc_odd),
        .ras_data_out(c1_ras_target),
        .ras_valid_out(c1_ras_valid)
    );

        wire [XLEN - 1:0] f1_addr_even, f1_addr_odd;
        wire f1_clc_even_valid, f1_clc_odd_valid, f1_pcd, f1_hit, f1_exceptions;

        f1_TOP #(.XLEN(XLEN), .CLC_WIDTH(CLC_WIDTH)) fetch_1(
            .clk(clk), .rst(rst),
            //inputs
            .clc_even_in(clc_even),
            .clc_odd_in(clc_odd),
            
            .stall_in(stall_in || ic_stall),
            
            //outputs
            .pcd(),         //don't cache MMIO
            .hit(),
            .exceptions(),

            .addr_even_valid(f1_clc_even_valid),
            .addr_odd_valid(f1_clc_odd_valid),

            .addr_even(cache_addr_even),
            .addr_odd(cache_addr_odd)
        );

        wire [511:0] IBuff_out;
        wire [XLEN-1:0] f2_pc_out;

        f2_TOP #(.XLEN(XLEN)) fetch_2( 
            .clk(clk),  .rst(rst),
            //inputs
            .stall_in(stall_in),

            .clc_data_in_even(cl_even),
            .clc_data_in_odd(cl_odd),
            .clc_data_even_hit(mem_hit_even),
            .clc_data_odd_hit(mem_hit_odd),

            .pcd(),         //don't cache MMIO
            .hit(),
            .way(),
            .exceptions(),

            // Branch resolution inputs
            .update_btb(bp_update),
            .resolved_pc(br_resolved_pc),
            .resolved_target(br_resolved_target),
            .resolved_taken(bp_update_taken),

            .resteer(resteer),

            .resteer_target_D1(32'b0),
            .resteer_taken_D1(1'b0),

            .resteer_target_BR(resteer_target_BR),
            .resteer_taken_BR(mispredict_BR),
            .bp_update_bhr_BR(bhr_update_BR),

            .resteer_target_ROB(resteer_target_ROB),
            .resteer_taken_ROB(exception_ROB),
            .bp_update_bhr_ROB(bhr_update_ROB),

            .resteer_target_ras(c1_ras_target),
            .resteer_taken_ras(ras_valid_out),

            //outputs
            .exceptions_out(),
            .IBuff_out(IBuff_out),
            .pc_out(f2_pc_out)
        );

        wire [XLEN - 1:0] d1_pc_out, d1_instr_out;

        d1_TOP #(.XLEN(XLEN)) opcode_decode(
            .clk(clk), .rst(rst),
            // inputs
            .exception_in(1'b0),
            .IBuff_in(IBuff_out),
            .resteer(resteer),
            .pc_in(f2_pc_out),
            // .resteer_target_BR(), //32b - mispredict
            // .resteer_target_ROB(), //32b - exception
    
            // .bp_update(), //1b
            // .bp_update_taken(), //1b
            // .bp_update_target(), //32b
            // .pcbp_update_bhr(),
            
            // outputs
            .pc(d1_pc_out),
            .exception_out(),
            .opcode_format(), //format of the instruction - compressed or not
            .instruction_out(d1_instr_out), //expanded instruction
            .instruction_valid(d1_instr_val),   // New output: valid flag from the rotator
            .compressed_inst(),

            .resteer_D1(),
            .resteer_target_D1(),
            .resteer_taken(),

            .ras_push(),
            .ras_pop(),
            .ras_ret_addr()


        );

        opdecode #(parameter XLEN=32) opdec(
           .clk(clk),
           .rst(rst),
        
            .pc_in(d1_pc_out),
            .valid_instr_in(d1_instr_val),
            .instr_in(d1_instr_out),
        
            //Outputs to backend
            .uop_ready_out(uop_ready_out),
            .uop_out(uop_out),
            .eoi_out(eoi_out),
            .imm_out(imm_out),
            .use_imm_out(use_imm_out),
            .pc_out(pc_out),
            .except_out(except_out),
            .src1_arch_out(src1_arch_out),
            .src2_arch_out(src2_arch_out),
            .dest_arch_out(dest_arch_out)
        );

        always @(posedge clk) begin
            cycle_number = cycle_number + 1;
            $fwrite(file, "Cycle number: %d\n", cycle_number);
            $fwrite(file, "\n");

            $fwrite(file, "Control:\n");
            $fwrite(file, "- clc_even: 0x%h\n", clc_even);
            $fwrite(file, "- clc_odd: 0x%h\n", clc_odd);
            $fwrite(file, "- c1_ras_target: 0x%h\n", c1_ras_target);
            $fwrite(file, "- c1_ras_valid: %d\n", c1_ras_valid);
            $fwrite(file, "\n");

            $fwrite(file, "Fetch 1:\n");
            $fwrite(file, "- addr_even_valid: %b\n", f1_clc_even_valid);
            $fwrite(file, "- addr_odd_valid: %b\n", f1_clc_odd_valid);
            $fwrite(file, "- addr_even: 0x%h\n", f1_addr_even);
            $fwrite(file, "- addr_odd: 0x%h\n", f1_addr_odd);
            $fwrite(file, "\n");

            $fwrite(file, "Fetch 2:\n");
            $fwrite(file, "- IBuff_out: 0x%h\n", IBuff_out);
            $fwrite(file, "- pc_out: 0x%h\n", pc_out);

            $fwrite(file, "----------------------------------------------------\n\n");
        end
    
        final begin
            $fclose(file);
        end

endmodule
