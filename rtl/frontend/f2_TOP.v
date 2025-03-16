module f2_TOP #(parameter XLEN=32, CL_SIZE = 128, CLC_WIDTH=28) (
    input clk, rst,

    input stall_in,

    //inputs
   
    input [CL_SIZE - 1:0] clc_data_in_even,
    input [CL_SIZE - 1:0] clc_data_in_odd,
    input clc_data_even_hit,
    input clc_data_odd_hit,

    input pcd,         //don't cache MMIO
    input hit,
    input [1:0] way, //TODO
    input exceptions,

    // Branch resolution inputs
    input update_btb,                    // Signal to update BTB (from branch resolution)
    input [XLEN-1:0] resolved_pc,        // Address of resolved branch
    input [XLEN-1:0] resolved_target,    // Actual target of the branch
    input resolved_taken,                // Branch taken/not-taken decision

    //resteers
    input resteer,

    input [XLEN - 1:0] resteer_target_D1,
    input resteer_taken_D1,

    input [XLEN - 1:0] resteer_target_BR,
    input resteer_taken_BR,
    input [9:0] bp_update_bhr_BR,  

    input [XLEN - 1:0] resteer_target_ROB,
    input resteer_taken_ROB,
    input [9:0] bp_update_bhr_ROB,

    input [XLEN - 1:0] resteer_target_ras,
    input resteer_taken_ras,

    //outputs
    output reg exceptions_out,
    output reg [XLEN - 1:0] IBuff_out,

    //PC 
    output reg [XLEN - 1:0] pc_out

);

//BP instantiation
// Branch Prediction Wires
wire final_predict_taken;
wire [XLEN-1:0] final_target_addr;

// Instantiate Branch Predictor
predictor_btb_wrapper btb_inst (
    .clk(clk),
    .reset(rst),
    .branch_addr(pc),                // Instruction address from fetch stage
    .branch_outcome(resolved_taken), // Outcome from branch resolution
    .update(update_btb),             // Update BTB when a branch is resolved
    .update_addr(resolved_pc),       // Address of resolved branch
    .actual_target(resolved_target), // Actual branch target
    .branch_taken(resolved_taken),   // Branch taken/not-taken decision
    .final_predict_taken(final_predict_taken), // Prediction output
    .final_target_addr(final_target_addr)      // Predicted target address
);

//PC instantiation
reg [XLEN - 1:0] pc;
reg [XLEN - 1:0] pc_last;

always @(posedge clk) begin
    if (rst) begin
        pc <= 0;
        pc_last <= 0;
    end else if (stall_in) begin
        pc <= pc;
        pc_last <= pc_last;
    end else if (resteer) begin
        if (resteer_taken_ROB) begin
            pc <= resteer_target_ROB;
            pc_last <= resteer_target_ROB;
        end else if (resteer_taken_D1) begin
            pc <= resteer_target_D1;
            pc_last <= resteer_target_D1;
        end else if (resteer_taken_BR) begin
            pc <= resteer_target_BR;
            pc_last <= resteer_target_BR;
        end else if (resteer_taken_ras) begin
            pc <= resteer_target_ras;
            pc_last <= resteer_target_ras;
        end
    end else begin
        pc_last <= pc;
        pc <= pc + 32;
    end

    pc_out <= pc;
end

//IBUFF instantiation
IBuff #(.CACHE_LINE_SIZE(128)) ibuff(
    .clk(clk),
    .rst(rst || resteer),
    .load(),
    .invalidate(),
    .data_in(), // Data inputs for each entry
    .data_out(), // Outputs for all 4 entries
    .valid_out()          // Valid bits for each entry
);



//logic to determine which ibuff output packet to send to decode
// TODO

endmodule