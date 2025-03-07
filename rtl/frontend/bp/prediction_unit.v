module predictor_btb_wrapper (
    input         clk,
    input         reset,
    input  [31:0] branch_addr,      // Branch address from the fetch stage
    input         branch_outcome,   // Actual outcome for branch predictor update
    // BTB update interface (from branch resolution stage)
    input         update,           
    input  [31:0] update_addr,      
    input  [31:0] actual_target,    
    input         branch_taken,     // Actual branch outcome for BTB update
    // Final outputs to the fetch stage
    output        final_predict_taken,  // Final branch prediction: 1=taken, 0=not taken
    output [31:0] final_target_addr     // Final predicted target address
);

  //-------------------------------------------------------------------------
  // Instantiate the two-level GShare Branch Predictor
  //-------------------------------------------------------------------------
  wire gp_taken;
  gshare_predictor gp (
      .clk(clk),
      .reset(reset),
      .branch_addr(branch_addr),
      .branch_outcome(branch_outcome),
      .predict_taken(gp_taken)
  );

  //-------------------------------------------------------------------------
  // Instantiate the Branch Target Buffer (BTB)
  //-------------------------------------------------------------------------
  wire btb_taken;
  wire [31:0] btb_target;
  branch_target_buffer btb (
      .clk(clk),
      .reset(reset),
      .branch_addr(branch_addr),
      .predict_taken(btb_taken),
      .target_addr(btb_target),
      .update(update),
      .update_addr(update_addr),
      .actual_target(actual_target),
      .branch_taken(branch_taken)
  );

  //-------------------------------------------------------------------------
  // Final Prediction Logic:
  // The branch is predicted taken only if both the predictor and the BTB agree.
  // If predicted taken, use the BTB target address; otherwise, default to the
  // sequential address (branch_addr + 4).
  //-------------------------------------------------------------------------
  assign final_predict_taken = gp_taken && btb_taken;
  assign final_target_addr = final_predict_taken ? btb_target : (branch_addr + 32'd4);

endmodule
