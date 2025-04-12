module ring_rob#(parameter XLEN=32, PHYS_REG_SIZE=256, RF_QUEUE=8, UOP_SIZE=16, ROB_ENTRY=256) (
    input clk, rst,

    input                                   logical_update,
    input[$clog2(PHYS_REG_SIZE)-1:0]        logical_update_reg,
    input[XLEN-1:0]                         logical_update_val,
    input[$clog2(ROB_ENTRY)-1:0]            logical_rob_entry,

    input                                   arithmetic_update,
    input[$clog2(PHYS_REG_SIZE)-1:0]        arithmetic_update_reg,
    input[XLEN-1:0]                         arithmetic_update_val, 
    input[$clog2(ROB_ENTRY)-1:0]            arithmetic_rob_entry,

    input                                   branch_update,
    input[$clog2(PHYS_REG_SIZE)-1:0]        branch_update_reg,
    input[XLEN-1:0]                         branch_update_val, 
    input[$clog2(ROB_ENTRY)-1:0]            branch_rob_entry,

    input                                   ld_st_update,
    input[$clog2(PHYS_REG_SIZE)-1:0]        ld_st_update_reg,
    input[XLEN-1:0]                         ld_st_update_val, 
    input[$clog2(ROB_ENTRY)-1:0]            ld_st_rob_entry,

    input                                   mul_div_update,
    input[$clog2(PHYS_REG_SIZE)-1:0]        mul_div_update_reg,
    input[XLEN-1:0]                         mul_div_update_val,
    input[$clog2(ROB_ENTRY)-1:0]            mul_div_rob_entry,

    output reg                              out_reg_file_valid,
    output reg[$clog2(PHYS_REG_SIZE)-1:0]   out_reg_file_update_reg,
    output reg[XLEN-1:0]                    out_reg_file_update_val,
    output reg[$clog2(ROB_ENTRY)-1:0]       out_reg_file_rob_entry,

    output reg                              out_rob_valid,
    output reg[$clog2(PHYS_REG_SIZE)-1:0]   out_rob_update_reg,
    output reg[XLEN-1:0]                    out_rob_update_val,
    output reg[$clog2(ROB_ENTRY)-1:0]       out_rob_rob_entry,

    output reg                              out_logical_valid,
    output reg[$clog2(PHYS_REG_SIZE)-1:0]   out_logical_update_reg,
    output reg[XLEN-1:0]                    out_logical_update_val,

    output reg                              out_arithmetic_valid,
    output reg[$clog2(PHYS_REG_SIZE)-1:0]   out_arithmetic_update_reg,
    output reg[XLEN-1:0]                    out_arithmetic_update_val, 

    output reg                              out_branch_valid,
    output reg[$clog2(PHYS_REG_SIZE)-1:0]   out_branch_update_reg,
    output reg[XLEN-1:0]                    out_branch_update_val, 

    output reg                              out_ld_st_valid,
    output reg[$clog2(PHYS_REG_SIZE)-1:0]   out_ld_st_update_reg,
    output reg[XLEN-1:0]                    out_ld_st_update_val, 

    output reg                              out_mul_div_valid,
    output reg[$clog2(PHYS_REG_SIZE)-1:0]   out_mul_div_update_reg,
    output reg[XLEN-1:0]                    out_mul_div_update_val
);

localparam NUM_IN = 6;
localparam MAX_LOOPS = 2; // Entry will be cleared after 2 loops

// Ring structures
reg                                   ring_update         [0:6];
reg[$clog2(PHYS_REG_SIZE)-1:0]        ring_update_reg     [0:6];
reg[XLEN-1:0]                         ring_update_val     [0:6];
reg[$clog2(ROB_ENTRY)-1:0]            ring_rob_entry      [0:6];
reg                                   ring_valid          [0:6]; // Track valid data
reg[1:0]                              loop_count          [0:6]; // Track number of loops completed

// Circuit inputs
reg                                   input_valid       [1:5];
reg[$clog2(PHYS_REG_SIZE)-1:0]        input_update_reg  [1:5];
reg[XLEN-1:0]                         input_update_val  [1:5];
reg[$clog2(ROB_ENTRY)-1:0]            input_rob_entry   [1:5];

reg                                   temp_update       [0:6];
reg[$clog2(PHYS_REG_SIZE)-1:0]        temp_update_reg   [0:6];
reg[XLEN-1:0]                         temp_update_val   [0:6];
reg[$clog2(ROB_ENTRY)-1:0]            temp_rob_entry    [0:6];
reg                                   temp_valid        [0:6];
reg[1:0]                              temp_loop_count   [0:6];

integer i;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        // Reset all ring entries and output signals
        for(i = 0; i <= 6; i = i + 1) begin
            ring_update[i]     <= 1'b0;
            ring_update_reg[i] <= {$clog2(PHYS_REG_SIZE){1'b0}};
            ring_update_val[i] <= {XLEN{1'b0}};
            ring_rob_entry[i]  <= {$clog2(ROB_ENTRY){1'b0}};
            ring_valid[i]      <= 1'b0;
            loop_count[i]      <= 2'b00;
        end
        
        // Reset all output signals
        out_rob_valid         <= 1'b0;
        out_rob_update_reg    <= {$clog2(PHYS_REG_SIZE){1'b0}};
        out_rob_update_val    <= {XLEN{1'b0}};
        out_rob_rob_entry     <= {$clog2(ROB_ENTRY){1'b0}};
        
        out_logical_valid     <= 1'b0;
        out_logical_update_reg <= {$clog2(PHYS_REG_SIZE){1'b0}};
        out_logical_update_val <= {XLEN{1'b0}};
        
        out_arithmetic_valid   <= 1'b0;
        out_arithmetic_update_reg <= {$clog2(PHYS_REG_SIZE){1'b0}};
        out_arithmetic_update_val <= {XLEN{1'b0}};
        
        out_branch_valid      <= 1'b0;
        out_branch_update_reg <= {$clog2(PHYS_REG_SIZE){1'b0}};
        out_branch_update_val <= {XLEN{1'b0}};
        
        out_ld_st_valid       <= 1'b0;
        out_ld_st_update_reg  <= {$clog2(PHYS_REG_SIZE){1'b0}};
        out_ld_st_update_val  <= {XLEN{1'b0}};
        
        out_mul_div_valid     <= 1'b0;
        out_mul_div_update_reg <= {$clog2(PHYS_REG_SIZE){1'b0}};
        out_mul_div_update_val <= {XLEN{1'b0}};
        
        out_reg_file_valid    <= 1'b0;
        out_reg_file_update_reg <= {$clog2(PHYS_REG_SIZE){1'b0}};
        out_reg_file_update_val <= {XLEN{1'b0}};
        out_reg_file_rob_entry <= {$clog2(ROB_ENTRY){1'b0}};
    end else begin
        // Prepare input data for potential insertion
        input_valid[1]       <= logical_update;
        input_update_reg[1]  <= logical_update_reg;
        input_update_val[1]  <= logical_update_val;
        input_rob_entry[1]   <= logical_rob_entry;
        
        input_valid[2]       <= arithmetic_update;
        input_update_reg[2]  <= arithmetic_update_reg;
        input_update_val[2]  <= arithmetic_update_val;
        input_rob_entry[2]   <= arithmetic_rob_entry;
        
        input_valid[3]       <= branch_update;
        input_update_reg[3]  <= branch_update_reg;
        input_update_val[3]  <= branch_update_val;
        input_rob_entry[3]   <= branch_rob_entry;
        
        input_valid[4]       <= ld_st_update;
        input_update_reg[4]  <= ld_st_update_reg;
        input_update_val[4]  <= ld_st_update_val;
        input_rob_entry[4]   <= ld_st_rob_entry;
        
        input_valid[5]       <= mul_div_update;
        input_update_reg[5]  <= mul_div_update_reg;
        input_update_val[5]  <= mul_div_update_val;
        input_rob_entry[5]   <= mul_div_rob_entry;
        
        // Process output for each position (sink nodes)
        // Position 0 - Output to ROB
        if (ring_valid[0]) begin
            out_rob_valid      <= 1'b1;
            out_rob_update_reg <= ring_update_reg[0];
            out_rob_update_val <= ring_update_val[0];
            out_rob_rob_entry  <= ring_rob_entry[0];
        end else begin
            out_rob_valid      <= 1'b0;
        end
        
        // Position 1 - Output to logical
        if (ring_valid[1]) begin
            out_logical_valid      <= 1'b1;
            out_logical_update_reg <= ring_update_reg[1];
            out_logical_update_val <= ring_update_val[1];
        end else begin
            out_logical_valid      <= 1'b0;
        end
        
        // Position 2 - Output to arithmetic
        if (ring_valid[2]) begin
            out_arithmetic_valid      <= 1'b1;
            out_arithmetic_update_reg <= ring_update_reg[2];
            out_arithmetic_update_val <= ring_update_val[2];
        end else begin
            out_arithmetic_valid      <= 1'b0;
        end
        
        // Position 3 - Output to branch
        if (ring_valid[3]) begin
            out_branch_valid      <= 1'b1;
            out_branch_update_reg <= ring_update_reg[3];
            out_branch_update_val <= ring_update_val[3];
        end else begin
            out_branch_valid      <= 1'b0;
        end
        
        // Position 4 - Output to ld_st
        if (ring_valid[4]) begin
            out_ld_st_valid      <= 1'b1;
            out_ld_st_update_reg <= ring_update_reg[4];
            out_ld_st_update_val <= ring_update_val[4];
        end else begin
            out_ld_st_valid      <= 1'b0;
        end
        
        // Position 5 - Output to mul_div
        if (ring_valid[5]) begin
            out_mul_div_valid      <= 1'b1;
            out_mul_div_update_reg <= ring_update_reg[5];
            out_mul_div_update_val <= ring_update_val[5];
        end else begin
            out_mul_div_valid      <= 1'b0;
        end
        
        // Position 6 - Output to reg_file
        if (ring_valid[6]) begin
            out_reg_file_valid      <= 1'b1;
            out_reg_file_update_reg <= ring_update_reg[6];
            out_reg_file_update_val <= ring_update_val[6];
            out_reg_file_rob_entry  <= ring_rob_entry[6];
        end else begin
            out_reg_file_valid      <= 1'b0;
        end

        // Update the ring - first save current values temporarily
        
        for(i = 0; i <= 6; i = i + 1) begin
            temp_update[i]     = ring_update[i];
            temp_update_reg[i] = ring_update_reg[i];
            temp_update_val[i] = ring_update_val[i];
            temp_rob_entry[i]  = ring_rob_entry[i];
            temp_valid[i]      = ring_valid[i];
            temp_loop_count[i] = loop_count[i];
        end
        
        // Circular shift - move data around the ring
        for(i = 0; i < 6; i = i + 1) begin
            // Shift from position i to i+1
            ring_update[i+1]     <= temp_update[i];
            ring_update_reg[i+1] <= temp_update_reg[i];
            ring_update_val[i+1] <= temp_update_val[i];
            ring_rob_entry[i+1]  <= temp_rob_entry[i];
            ring_valid[i+1]      <= temp_valid[i];
            loop_count[i+1]      <= temp_loop_count[i];
        end
        
        // Special handling for completing the loop
        // When data moves from position 6 back to position 0, increment the loop counter
        if (temp_valid[6]) begin
            ring_update[0]     <= temp_update[6];
            ring_update_reg[0] <= temp_update_reg[6];
            ring_update_val[0] <= temp_update_val[6];
            ring_rob_entry[0]  <= temp_rob_entry[6];
            
            // Increment loop counter when wrapping around
            // If completed MAX_LOOPS (2) loops, clear the entry
            if (temp_loop_count[6] == MAX_LOOPS - 1) begin
                ring_valid[0]  <= 1'b0; // Clear the entry after MAX_LOOPS
                loop_count[0]  <= 2'b00;
            end else begin
                ring_valid[0]  <= temp_valid[6];
                loop_count[0]  <= temp_loop_count[6] + 1'b1;
            end
        end else begin
            ring_update[0]     <= 1'b0;
            ring_update_reg[0] <= {$clog2(PHYS_REG_SIZE){1'b0}};
            ring_update_val[0] <= {XLEN{1'b0}};
            ring_rob_entry[0]  <= {$clog2(ROB_ENTRY){1'b0}};
            ring_valid[0]      <= 1'b0;
            loop_count[0]      <= 2'b00;
        end
        
        // Process input insertions - each position can take input if data is valid
        for(i = 1; i <= 5; i = i + 1) begin
            if (input_valid[i] && !ring_valid[i]) begin
                // We have input data and the ring position is free
                ring_update[i]     <= 1'b1;
                ring_update_reg[i] <= input_update_reg[i];
                ring_update_val[i] <= input_update_val[i];
                ring_rob_entry[i]  <= input_rob_entry[i];
                ring_valid[i]      <= 1'b1;
                loop_count[i]      <= 2'b00; // Reset loop counter for new data
            end
        end
    end
end

endmodule