module f2_TOP #(parameter XLEN=32, CL_SIZE = 128) (
    input clk, rst,

    input stall_in,

    //inputs
    input [XLEN - 1:0] clc_paddr, //TODO
    input [XLEN - 1:0] clc_vaddr, //TODO
    input clc_valid,
    
    input [CL_SIZE - 1:0] clc_data_in_even,
    input [CL_SIZE - 1:0] clc_data_in_odd,

    input pcd,         //don't cache MMIO
    input hit,
    input [1:0] way, //TODO
    input exceptions,

    input [XLEN - 1:0] bppf_paddr, //TODO
    input bppf_valid,

    input [XLEN - 1:0] nlpf_paddr, //TODO
    input nlpf_valid,

    //TAG_STORE
    input [XLEN - 1:0] tag_evict, //TODO

    //DATASTORE
    input [2:0] l2_icache_op, 
    input [2:0] l2_icache_state,
    input [XLEN - 1:0] l2_icache_addr,
    input [511:0] l2_icache_data_in,

    // Branch resolution inputs
    input update_btb,                    // Signal to update BTB (from branch resolution)
    input [XLEN-1:0] resolved_pc,        // Address of resolved branch
    input [XLEN-1:0] resolved_target,    // Actual target of the branch
    input resolved_taken,                // Branch taken/not-taken decision

    //resteers
    input resteer,
    input [XLEN - 1:0] resteer_target_D1,
    input resteer_taken_D1,
    output [XLEN - 1:0] resteer_target_BR,
    output resteer_taken_BR,
    input [XLEN - 1:0] resteer_target_ROB,
    input resteer_taken_ROB,
    input [XLEN - 1:0] resteer_target_ras,
    input resteer_taken_ras,

    //outputs
    output exceptions_out,

    //Tag Store Overwrite
    output [XLEN - 1:0] tag_ovrw, //TODO
    output [1:0] way_ovrw,  //TODO

    output [XLEN - 1:0] IBuff_out,

    output prefetch_valid,
    output [XLEN - 1:0] prefetch_addr,

    //Datastore
    output [2:0] icache_l2_op,
    output [2:0] icache_l2_state,
    output [XLEN - 1:0] icache_l2_addr,
    output [511:0] icache_l2_data_out,

    //PC 
    output [XLEN - 1:0] pc_out

);

//BP instantiation
// Branch Prediction Wires
wire final_predict_taken;
wire [XLEN-1:0] final_target_addr;

// Instantiate Branch Predictor
predictor_btb_wrapper btb_inst (
    .clk(clk),
    .reset(rst),
    .branch_addr(clc_paddr),         // Instruction address from fetch stage
    .branch_outcome(resolved_taken), // Outcome from branch resolution
    .update(update_btb),             // Update BTB when a branch is resolved
    .update_addr(resolved_pc),       // Address of resolved branch
    .actual_target(resolved_target), // Actual branch target
    .branch_taken(resolved_taken),   // Branch taken/not-taken decision
    .final_predict_taken(final_predict_taken), // Prediction output
    .final_target_addr(final_target_addr)      // Predicted target address
);

// Use the prediction results
assign prefetch_valid = final_predict_taken;
assign prefetch_addr  = final_target_addr;

//IBUFF instantiation

IBuff #(.CACHE_LINE_SIZE(128)) ibuff(
    .clk(clk),
    .rst(rst || resteer),
    .load(),
    .data_in(), // Data inputs for each entry
    .data_out(), // Outputs for all 4 entries
    .valid_out()          // Valid bits for each entry
);

byte_rotator rotator (
    .data_in(),
    .shift(),
    .data_out()
);

//PC instantiation
reg [XLEN - 1:0] pc;

always @(posedge clk) begin
    if (rst) begin
        pc <= 0;
    end else if (stall_in) begin
        pc <= pc;
    end else if (resteer) begin
        if (resteer_taken_ROB) begin
            pc <= resteer_target_ROB;
        end else if (resteer_taken_D1) begin
            pc <= resteer_target_D1;
        // end else if () begin
        //     pc <= ;
        // end else if (ras_valid_out) begin
        //     pc <= ras_data_out;
        end
    end else begin
        pc <= pc + 64;
    end
end

endmodule
