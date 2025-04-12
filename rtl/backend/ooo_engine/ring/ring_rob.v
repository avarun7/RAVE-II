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
/*    -> ROB -> logical -> arithmetic -> branch -> ld_st -> mul_div ->  RegFile ->   */

reg                                   ring_update         [0:6];
reg[$clog2(PHYS_REG_SIZE)-1:0]        ring_update_reg     [0:6];
reg[XLEN-1:0]                         ring_update_val     [0:6];
reg[$clog2(ROB_ENTRY)-1:0]            ring_rob_entry      [0:6];
reg[3:0]                              loop_run            [0:6];

// Queue values
// wire[NUM_IN-1:0]                           inserts;
// Insertion interface
// wire[NUM_IN-1:0]                           insert_valid;                            // Valid signal for each potential insert

// wire[NUM_IN*XLEN-1:0]                      insert_vals;                 // Data for each potential insert
// wire[NUM_IN*$clog2(PHYS_REG_SIZE)-1:0]     insert_regs;
// wire[NUM_IN*$clog2(ROB_ENTRY)-1:0]         insert_rob_entry;

// wire[NUM_IN-1:0] insert_ready;                           // Ready signal for each potential insert

// Removal interface
wire remove_valid;
assign remove_valid = 1;

// Status signals
// wire full;            
// wire empty;
// wire [$clog2(RF_QUEUE)-1:0] occupancy;

// assign insert_valid[4] = logical_update;
// assign insert_valid[3] = arithmetic_update;
// assign insert_valid[2] = branch_update;
// assign insert_valid[1] = ld_st_update;
// assign insert_valid[0] = mul_div_update;

// assign insert_vals[5*XLEN-1:4*XLEN] = logical_update_val;
// assign insert_vals[4*XLEN-1:3*XLEN] = arithmetic_update_val;
// assign insert_vals[3*XLEN-1:2*XLEN] = branch_update_val;
// assign insert_vals[2*XLEN-1:XLEN]   = ld_st_update_val;
// assign insert_vals[1*XLEN-1:0]      = mul_div_update_val;

// assign insert_regs[5*$clog2(PHYS_REG_SIZE)-1:4*$clog2(PHYS_REG_SIZE)] = logical_update_reg;
// assign insert_regs[4*$clog2(PHYS_REG_SIZE)-1:3*$clog2(PHYS_REG_SIZE)] = arithmetic_update_reg;
// assign insert_regs[3*$clog2(PHYS_REG_SIZE)-1:2*$clog2(PHYS_REG_SIZE)] = branch_update_reg;
// assign insert_regs[2*$clog2(PHYS_REG_SIZE)-1:1*$clog2(PHYS_REG_SIZE)] = ld_st_update_reg;
// assign insert_regs[$clog2(PHYS_REG_SIZE)-1:0]                         = mul_div_update_reg;

// assign insert_regs[5*$clog2(ROB_ENTRY)-1:4*$clog2(ROB_ENTRY)] = logical_rob_entry;
// assign insert_regs[4*$clog2(ROB_ENTRY)-1:3*$clog2(ROB_ENTRY)] = arithmetic_rob_entry;
// assign insert_regs[3*$clog2(ROB_ENTRY)-1:2*$clog2(ROB_ENTRY)] = branch_rob_entry;
// assign insert_regs[2*$clog2(ROB_ENTRY)-1:1*$clog2(ROB_ENTRY)] = ld_st_rob_entry;
// assign insert_regs[$clog2(ROB_ENTRY)-1:0]                     = mul_div_rob_entry;

integer i;

always @(posedge clk ) begin
    // if(logical_ring[0] & logical_update);
        //stall the FU
    if(ring_update[0]) begin
        out_rob_valid         <= ring_update[0];
        out_rob_update_reg    <= ring_update_reg[0];
        out_rob_update_val    <= ring_update_val[0];
        out_rob_rob_entry     <= ring_rob_entry[0];
        loop_run[0]           <= loop_run[0] - 1;
    end else begin
        out_rob_valid         <= 0;
        out_rob_update_reg    <= 0;
        out_rob_update_val    <= 0;
        out_rob_rob_entry     <= 0;
    end

    // if(logical_ring[0] & logical_update);
        //stall the FU
    if(ring_update[1]) begin
        out_logical_valid         <= ring_update[1];
        out_logical_update_reg    <= ring_update_reg[1];
        out_logical_update_val    <= ring_update_val[1];
        loop_run[1]           <=    loop_run[1] - 1;
    end else if(loop_run[1] == 0) begin
        if(logical_update) begin
            ring_update[1]      <= logical_update;
            ring_update_reg[1]  <= logical_update_reg;
            ring_update_val[1]  <= logical_update_val;
            ring_rob_entry[1]   <= logical_rob_entry;
        end else begin
            ring_update[1]       <= 1'b0;
            ring_update_reg[1]   <= {$clog2(PHYS_REG_SIZE){1'b0}};
            ring_update_val[1]   <= {XLEN{1'b0}};
            ring_rob_entry[1]    <= {$clog2(ROB_ENTRY){1'b0}};
        end
    end else begin
        out_logical_valid         <= 0;
        out_logical_update_reg    <= 0;
        out_logical_update_val    <= 0;
    end

    // if(arithmetic_ring[0] & arithmetic_update);
        //stall the FU
    if(ring_update[2]) begin
        out_arithmetic_valid         <= ring_update[2];
        out_arithmetic_update_reg    <= ring_update_reg[2];
        out_arithmetic_update_val    <= ring_update_val[2];
        loop_run[2]           <= loop_run[2] - 1;
    end else if(loop_run[2] == 0) begin
        if(arithmetic_update) begin
            ring_update[2]      <= arithmetic_update;
            ring_update_reg[2]  <= arithmetic_update_reg;
            ring_update_val[2]  <= arithmetic_update_val;
            ring_rob_entry[2]   <= arithmetic_rob_entry;
            loop_run[2]         <= 14;
        end else begin
            ring_update[2]       <= 1'b0;
            ring_update_reg[2]   <= {$clog2(PHYS_REG_SIZE){1'b0}};
            ring_update_val[2]   <= {XLEN{1'b0}};
            ring_rob_entry[2]    <= {$clog2(ROB_ENTRY){1'b0}};
        end
    end else begin
        out_arithmetic_valid         <= 0;
        out_arithmetic_update_reg    <= 0;
        out_arithmetic_update_val    <= 0;
    end

    // if(branch_ring[0] & branch_update);
        //stall the FU
    if(ring_update[3]) begin
        out_branch_valid         <= ring_update[3];
        out_branch_update_reg    <= ring_update_reg[3];
        out_branch_update_val    <= ring_update_val[3];
        loop_run[3]           <= loop_run[3] - 1;
    end else if(loop_run[3] == 0) begin
        if(branch_update) begin
            ring_update[3]       <= branch_update;
            ring_update_reg[3]   <= branch_update_reg;
            ring_update_val[3]   <= branch_update_val;
            ring_rob_entry[3]    <= branch_rob_entry;
            loop_run[3]          <= 14;
        end else begin
            ring_update[3]       <= 1'b0;
            ring_update_reg[3]   <= {$clog2(PHYS_REG_SIZE){1'b0}};
            ring_update_val[3]   <= {XLEN{1'b0}};
            ring_rob_entry[3]    <= {$clog2(ROB_ENTRY){1'b0}};
        end
    end else begin
        out_branch_valid         <= 0;
        out_branch_update_reg    <= 0;
        out_branch_update_val    <= 0;
    end

    // if(ld_st_ring[0] & ld_st_update);
        //stall the FU
    if(ring_update[4]) begin //TODO: make ld_st
        out_ld_st_valid         <= ring_update[4];
        out_ld_st_update_reg    <= ring_update_reg[4];
        out_ld_st_update_val    <= ring_update_val[4];
        loop_run[4]           <= loop_run[4] - 1;
    end else if(loop_run[4] == 0) begin
        if(ld_st_update) begin
            ring_update[4]       <= ld_st_update;
            ring_update_reg[4]   <= ld_st_update_reg;
            ring_update_val[4]   <= ld_st_update_val;
            ring_rob_entry[4]    <= ld_st_rob_entry;
            loop_run[4]          <= 14;
        end else begin
            ring_update[4]       <= 1'b0;
            ring_update_reg[4]   <= {$clog2(PHYS_REG_SIZE){1'b0}};
            ring_update_val[4]   <= {XLEN{1'b0}};
            ring_rob_entry[4]    <= {$clog2(ROB_ENTRY){1'b0}};
        end
    end else begin
        out_ld_st_valid         <= 0;
        out_ld_st_update_reg    <= 0;
        out_ld_st_update_val    <= 0;
    end

    // if(m[0] & logical_update);
        //stall the FU
    if(ring_update[5]) begin
        out_mul_div_valid         <= ring_update[5];
        out_mul_div_update_reg    <= ring_update_reg[5];
        out_mul_div_update_val    <= ring_update_val[5];
        loop_run[5]           <= loop_run[5] - 1;
    end else if(loop_run[5] == 0) begin
        if(mul_div_update) begin
            ring_update[5]       <= mul_div_update;
            ring_update_reg[5]   <= mul_div_update_reg;
            ring_update_val[5]   <= mul_div_update_val;
            ring_rob_entry[5]    <= mul_div_rob_entry;
            loop_run[5]          <= 14;
        end else begin
            ring_update[5]       <= 1'b0;
            ring_update_reg[5]   <= {$clog2(PHYS_REG_SIZE){1'b0}};
            ring_update_val[5]   <= {XLEN{1'b0}};
            ring_rob_entry[5]    <= {$clog2(ROB_ENTRY){1'b0}};
        end
    end else begin
        out_mul_div_valid         <= 0;
        out_mul_div_update_reg    <= 0;
        out_mul_div_update_val    <= 0;
    end

    if(ring_update[6]) begin
        out_reg_file_valid         <= ring_update[6];
        out_reg_file_update_reg    <= ring_update_reg[6];
        out_reg_file_update_val    <= ring_update_val[6];
        loop_run[6]                <= loop_run[6] - 1;
    end else begin
        out_reg_file_valid         <= 0;
        out_reg_file_update_reg    <= 0;
        out_reg_file_update_val    <= 0;
        out_reg_file_rob_entry     <= 0;
    end

    // Get from queue
    
    //rob ->arithmetic->logical->branch->md->ld/st
    for(i = 0; i < NUM_IN-1; i = i + 1) begin
        ring_update[i+1]     = ring_update[i]; 
        ring_update_reg[i+1] = ring_update_reg[i];
        ring_update_val[i+1] = ring_update_val[i];
        ring_rob_entry[i+1]  = ring_rob_entry[i];
    end
    ring_update[0]     = ring_update[6]; 
    ring_update_reg[0] = ring_update_reg[6];
    ring_update_val[0] = ring_update_val[6];
    ring_rob_entry[0]  = ring_rob_entry[6];

end

endmodule