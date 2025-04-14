`timescale 1ns/1ps

module tb_predictor_btb_wrapper;

  // Input signals for the predictor wrapper
  reg         clk;
  reg         reset;
  reg  [31:0] branch_addr;      // Branch address from fetch
  reg         branch_outcome;   // Outcome used for branch predictor update
  reg         update;           // Signal to update BTB entry
  reg  [31:0] update_addr;      // Branch address corresponding to update
  reg  [31:0] actual_target;    // Resolved target address for BTB update
  reg         branch_taken;     // Actual branch outcome used in BTB update

  // Output signals from the predictor wrapper
  wire        final_predict_taken;  // Final branch prediction: 1 = taken
  wire [31:0] final_target_addr;     // Final predicted target address

  // Instantiate the branch predictor wrapper (DUT)
  predictor_btb_wrapper dut (
    .clk(clk),
    .reset(reset),
    .branch_addr(branch_addr),
    .branch_outcome(branch_outcome),
    .update(update),
    .update_addr(update_addr),
    .actual_target(actual_target),
    .branch_taken(branch_taken),
    .final_predict_taken(final_predict_taken),
    .final_target_addr(final_target_addr)
  );

  // Clock generation: toggle clock every 5 time units
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // Test sequence: apply reset then a series of test vectors
  initial begin
    // Initializing all inputs
    reset         = 1;
    branch_addr   = 32'h0000;
    branch_outcome= 1'b0;
    update        = 0;
    update_addr   = 32'h0000;
    actual_target = 32'h0000;
    branch_taken  = 0;
    
    // Keep reset asserted for a few cycles
    #20;
    reset = 0;
    
    //-------------------------------------------------------------------------
    // Test Case 1: Taken Branch
    //-------------------------------------------------------------------------
    // 1a. Simulate the fetch stage for a branch at address 0x0040.
    branch_addr   = 32'h0040;
    branch_outcome= 1'b1;  // Predictor sees a taken branch outcome (for update)
    $display("Time %t: Fetching branch at address %h (assumed taken)", $time, branch_addr);
    #10;  // Let the design process the input
    
    // 1b. Update the BTB entry (as would occur during branch resolution).
    update        = 1;
    update_addr   = branch_addr;
    // For a taken branch, a valid target address is provided.
    actual_target = branch_addr + 32'h10;  
    branch_taken  = 1;
    #10;
    update        = 0;
    
    // 1c. Re-fetch the same branch to see the prediction and target address.
    #10;
    branch_addr   = 32'h0040;  // same branch address as before
    branch_outcome= 1'b1;       // predictor will update its counter further as needed
    #10;  // wait for the design to compute the prediction
    $display("Time %t: For branch %h -> final_predict_taken = %b, final_target_addr = %h", 
             $time, branch_addr, final_predict_taken, final_target_addr);
             
    //-------------------------------------------------------------------------
    // Test Case 2: Not Taken Branch
    //-------------------------------------------------------------------------
    // 2a. Simulate a different branch fetch (address 0x0080) where the branch is not taken.
    #10;
    branch_addr   = 32'h0080;
    branch_outcome= 1'b0;
    $display("Time %t: Fetching branch at address %h (assumed not taken)", $time, branch_addr);
    #10;
    
    // 2b. Update the BTB entry for this branch resolution:
    // For a not-taken branch, the BTB entry is invalidated.
    update        = 1;
    update_addr   = branch_addr;
    actual_target = branch_addr + 32'h8;   // target is arbitrary here
    branch_taken  = 0;  // indicate branch was not taken, so disable the BTB entry
    #10;
    update        = 0;
    
    // 2c. Re-fetch the branch; the BTB should not predict it taken now.
    #10;
    branch_addr   = 32'h0080;
    branch_outcome= 1'b0;
    #10;
    $display("Time %t: For branch %h -> final_predict_taken = %b, final_target_addr = %h", 
             $time, branch_addr, final_predict_taken, final_target_addr);

    // End the simulation after a short delay
    #30;
    $finish;
  end

endmodule
