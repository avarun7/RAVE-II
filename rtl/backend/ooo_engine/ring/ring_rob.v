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

localparam NUM_IN = 5;
/*    ROB -> logical -> arithmetic -> branch -> ld_st -> mul_div      */

reg                                   ring_update         [0:5];
reg[$clog2(PHYS_REG_SIZE)-1:0]        ring_update_reg     [0:5];
reg[XLEN-1:0]                         ring_update_val     [0:5];
reg[$clog2(ROB_ENTRY)-1:0]            ring_rob_entry      [0:5];

// Queue values
wire[NUM_IN-1:0]                           inserts;
// Insertion interface
wire[NUM_IN-1:0]                           insert_valid;                            // Valid signal for each potential insert

wire[NUM_IN*XLEN-1:0]                      insert_vals;                 // Data for each potential insert
wire[NUM_IN*$clog2(PHYS_REG_SIZE)-1:0]     insert_regs;
wire[NUM_IN*$clog2(ROB_ENTRY)-1:0]          insert_rob_entry;

wire[NUM_IN-1:0] insert_ready;                           // Ready signal for each potential insert

// Removal interface
wire remove_valid;
assign remove_valid = 1;

wire [XLEN-1:0]                     remove_data;
wire [$clog2(PHYS_REG_SIZE)-1:0]    remove_reg;
wire [$clog2(ROB_ENTRY)-1:0]        remove_rob_entry;
wire remove_ready;                                                      // Queue has data to remove

// Status signals
wire full;            
wire empty;
wire [$clog2(RF_QUEUE)-1:0] occupancy;

multi_insertion_queue #(.DATA_WIDTH(XLEN), .QUEUE_DEPTH(RF_QUEUE), .MAX_INSERTS_PER_CYCLE(NUM_IN)) miq_val(.clk(clk), .rst(rst), .insert_valid(inserts), .insert_data(insert_vals), .insert_ready(insert_ready), .remove_valid(remove_valid), .remove_data(remove_data), .remove_ready(remove_ready));
multi_insertion_queue #(.DATA_WIDTH($clog2(PHYS_REG_SIZE)), .QUEUE_DEPTH(RF_QUEUE), .MAX_INSERTS_PER_CYCLE(NUM_IN)) miq_reg(.clk(clk), .rst(rst), .insert_valid(inserts), .insert_data(insert_regs), .insert_ready(insert_ready), .remove_valid(remove_valid), .remove_data(remove_reg), .remove_ready(remove_ready));
multi_insertion_queue #(.DATA_WIDTH($clog2(ROB_ENTRY)), .QUEUE_DEPTH(RF_QUEUE), .MAX_INSERTS_PER_CYCLE(NUM_IN)) miq_rob(.clk(clk), .rst(rst), .insert_valid(inserts), .insert_data(insert_rob_entry), .insert_ready(insert_ready), .remove_valid(remove_valid), .remove_data(remove_rob_entry), .remove_ready(remove_ready));

assign insert_valid[4] = logical_update;
assign insert_valid[3] = arithmetic_update;
assign insert_valid[2] = branch_update;
assign insert_valid[1] = ld_st_update;
assign insert_valid[0] = mul_div_update;

assign insert_vals[5*XLEN-1:4*XLEN] = logical_update_val;
assign insert_vals[4*XLEN-1:3*XLEN] = arithmetic_update_val;
assign insert_vals[3*XLEN-1:2*XLEN] = branch_update_val;
assign insert_vals[2*XLEN-1:XLEN]   = ld_st_update_val;
assign insert_vals[1*XLEN-1:0]      = mul_div_update_val;

assign insert_regs[5*$clog2(PHYS_REG_SIZE)-1:4*$clog2(PHYS_REG_SIZE)] = logical_update_reg;
assign insert_regs[4*$clog2(PHYS_REG_SIZE)-1:3*$clog2(PHYS_REG_SIZE)] = arithmetic_update_reg;
assign insert_regs[3*$clog2(PHYS_REG_SIZE)-1:2*$clog2(PHYS_REG_SIZE)] = branch_update_reg;
assign insert_regs[2*$clog2(PHYS_REG_SIZE)-1:1*$clog2(PHYS_REG_SIZE)]   = ld_st_update_reg;
assign insert_regs[$clog2(PHYS_REG_SIZE)-1:0]                         = mul_div_update_reg;

assign insert_regs[5*$clog2(ROB_ENTRY)-1:4*$clog2(ROB_ENTRY)] = logical_rob_entry;
assign insert_regs[4*$clog2(ROB_ENTRY)-1:3*$clog2(ROB_ENTRY)] = arithmetic_rob_entry;
assign insert_regs[3*$clog2(ROB_ENTRY)-1:2*$clog2(ROB_ENTRY)] = branch_rob_entry;
assign insert_regs[2*$clog2(ROB_ENTRY)-1:1*$clog2(ROB_ENTRY)] = ld_st_rob_entry;
assign insert_regs[$clog2(ROB_ENTRY)-1:0]                     = mul_div_rob_entry;

integer i;

always @(posedge clk ) begin
    // if(logical_ring[0] & logical_update);
        //stall the FU
    if(ring_update[0]) begin
        out_rob_valid         <= ring_update[0];
        out_rob_update_reg    <= ring_update_reg[0];
        out_rob_update_val    <= ring_update_val[0];
        out_rob_rob_entry     <= ring_rob_entry[0];
    end

    // if(logical_ring[0] & logical_update);
        //stall the FU
    if(ring_update[1]) begin
        out_logical_valid         <= ring_update[1];
        out_logical_update_reg    <= ring_update_reg[1];
        out_logical_update_val    <= ring_update_val[1];
    end

    // if(arithmetic_ring[0] & arithmetic_update);
        //stall the FU
    else if(ring_update[2]) begin
        out_arithmetic_valid         <= ring_update[2];
        out_arithmetic_update_reg    <= ring_update_reg[2];
        out_arithmetic_update_val    <= ring_update_val[2];
    end

    // if(branch_ring[0] & branch_update);
        //stall the FU
    else if(ring_update[3]) begin
        out_branch_valid         <= ring_update[3];
        out_branch_update_reg    <= ring_update_reg[3];
        out_branch_update_val    <= ring_update_val[3];
    end

    // if(ld_st_ring[0] & ld_st_update);
        //stall the FU
    else if(ring_update[4]) begin //TODO: make ld_st
        out_logical_valid         <= ring_update[4];
        out_logical_update_reg    <= ring_update_reg[4];
        out_logical_update_val    <= ring_update_val[4];
    end

    // if(m[0] & logical_update);
        //stall the FU
    else if(ring_update[5]) begin
        out_logical_valid         <= ring_update[5];
        out_logical_update_reg    <= ring_update_reg[5];
        out_logical_update_val    <= ring_update_val[5];
    end

    // Get from queue
    if(remove_ready)begin
        ring_update     [0] = 1'b1;
        ring_update_reg [0] = remove_reg;
        ring_update_val [0] = remove_data;
        ring_rob_entry  [0] = remove_rob_entry;
    end 
    else ring_update     [0] = 1'b0;
    //rob ->arithmetic->logical->branch->md->ld/st
    for(i = 0; i < NUM_IN-1; i = i + 1) begin
        ring_update[i+1]     = ring_update[i]; 
        ring_update_reg[i+1] = ring_update_reg[i];
        ring_update_val[i+1] = ring_update_val[i];
        ring_rob_entry[i+1]  = ring_rob_entry[i];
    end
 


end

endmodule