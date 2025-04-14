module f2_TOP #(parameter XLEN = 32,
                  parameter CL_SIZE = 128, // Cache line size (bits)
                  parameter CLC_WIDTH = 28)
(
    input  clk,
    input  rst,
    input  stall_in,
    
    // Icache outputs
    input  [CL_SIZE - 1:0] clc_data_in_even,
    input  [CL_SIZE - 1:0] clc_data_in_odd,
    input  clc_data_even_hit,
    input  clc_data_odd_hit,
    
    input  pcd,         // don't cache MMIO
    input  hit,
    input  [1:0] way,   // TODO: way selection if needed
    input  exceptions,
    
    // Branch resolution inputs
    input  update_btb,                    
    input  [XLEN-1:0] resolved_pc,        
    input  [XLEN-1:0] resolved_target,    
    input  resolved_taken,                
    
    // resteer signals
    input  resteer,
    
    input  [XLEN - 1:0] resteer_target_D1,
    input  resteer_taken_D1,
    
    input  [XLEN - 1:0] resteer_target_BR,
    input  resteer_taken_BR,
    input  [9:0] bp_update_bhr_BR,  
    
    input  [XLEN - 1:0] resteer_target_ROB,
    input  resteer_taken_ROB,
    input  [9:0] bp_update_bhr_ROB,
    
    input  [XLEN - 1:0] resteer_target_ras,
    input  resteer_taken_ras,
    
    // Outputs
    output reg exceptions_out,
    output reg [511:0] IBuff_out, // Instruction (or word) sent to decode  
    output reg [XLEN - 1:0] pc_out,
    output reg stall   // New stall signal generated if IBuff insertion cannot occur
);

    //--------------------------------------------------------------------------
    // File logging (unchanged)
    integer file;
    integer cycle_number = 0;
    initial begin
        file = $fopen("f2.log", "w");
        if (file == 0) begin
            $display("Error: Failed to open file f2.log");
            $finish;
        end
    end

    //--------------------------------------------------------------------------
    // Branch Predictor instantiation (unchanged except for pc connection)
    wire final_predict_taken;
    wire [XLEN-1:0] final_target_addr;
    
    predictor_btb_wrapper btb_inst (
        .clk(clk),
        .reset(rst),
        .branch_addr(pc),                // Instruction address from fetch stage
        .branch_outcome(resolved_taken),
        .update(update_btb),
        .update_addr(resolved_pc),
        .actual_target(resolved_target),
        .branch_taken(resolved_taken),
        .final_predict_taken(final_predict_taken),
        .final_target_addr(final_target_addr)
    );
    
    //--------------------------------------------------------------------------
    // PC and sequencing logic
    reg [XLEN - 1:0] pc;
    reg [XLEN - 1:0] pc_last;
    
    always @(posedge clk) begin
        if (rst) begin
            pc      <= 0;
            pc_last <= 0;
        end else if (stall_in || stall) begin  // also stall if IBuff insertion is blocked
            pc      <= pc;
            pc_last <= pc_last;
        end else if (resteer) begin
            if (resteer_taken_ROB) begin
                pc      <= resteer_target_ROB;
                pc_last <= resteer_target_ROB;
            end else if (resteer_taken_D1) begin
                pc      <= resteer_target_D1;
                pc_last <= resteer_target_D1;
            end else if (resteer_taken_BR) begin
                pc      <= resteer_target_BR;
                pc_last <= resteer_target_BR;
            end else if (resteer_taken_ras) begin
                pc      <= resteer_target_ras;
                pc_last <= resteer_target_ras;
            end
        end else begin
            pc_last <= pc;
            pc      <= pc + 32;
        end
        
        pc_out <= pc;
    end

    //--------------------------------------------------------------------------
    // IBuff connection signals
    wire [3:0]          ibuff_valid;
    wire [CL_SIZE-1:0]  ibuff_data_out [3:0];
    wire [3:0]          ibuff_load;
    // For simplicity, we tie the invalidate signal to zero.
    wire [3:0]          ibuff_invalidate = 4'b0000;
    
    //--------------------------------------------------------------------------
    // Combinational logic: Determine which IBuff slot to load
    // (Slots 0 and 2 are for even data; Slots 1 and 3 for odd data.)
    reg [3:0] load_signals;
    reg       stall_due_to_ibuff;
    
    always @(*) begin
        load_signals = 4'b0000;
        stall_due_to_ibuff = 1'b0;
        
        // Even data: if an even cache line is ready (hit), try slot 0 first, then slot 2.
        if (clc_data_even_hit) begin
            if (!ibuff_valid[0])
                load_signals[0] = 1'b1;
            else if (!ibuff_valid[2])
                load_signals[2] = 1'b1;
            else
                stall_due_to_ibuff = 1'b1;
        end
        
        // Odd data: if an odd cache line is ready (hit), try slot 1 first, then slot 3.
        if (clc_data_odd_hit) begin
            if (!ibuff_valid[1])
                load_signals[1] = 1'b1;
            else if (!ibuff_valid[3])
                load_signals[3] = 1'b1;
            else
                stall_due_to_ibuff = 1'b1;
        end
    end
    
    // Drive the IBuff load vector with the computed signals.
    assign ibuff_load = load_signals;
    
    // Generate the overall stall signal (ORing with other stalls if needed)
    always @(*) begin
        // Here, the stall signal reflects that the IBuff cannot accept the new line.
        stall = stall_due_to_ibuff;
    end
    
    //--------------------------------------------------------------------------
    // Instantiate the IBuff, connecting inputs from the icache and using our load signals.
    IBuff #(.CACHE_LINE_SIZE(CL_SIZE)) ibuff (
        .clk(clk),
        .rst(rst || resteer),
        .load(ibuff_load),
        .invalidate(ibuff_invalidate),
        .data_in_even(clc_data_in_even),
        .data_in_odd(clc_data_in_odd),
        .data_out(ibuff_data_out),
        .valid_out(ibuff_valid)
    );
    
    //--------------------------------------------------------------------------
    // Logging the cycle (unchanged)
    always @(posedge clk) begin
        cycle_number = cycle_number + 1;
        $fwrite(file, "Cycle number: %d\n", cycle_number);
        $fwrite(file, "IBuff_out: 0x%h\n", IBuff_out);
        $fwrite(file, "pc_out: 0x%h\n", pc_out);
        $fwrite(file, "\n");
    end
    
    final begin
        $fclose(file);
    end

    // Additional logic (e.g. determining which IBuff output packet to send to decode)
    // can be developed as needed.
    
endmodule
