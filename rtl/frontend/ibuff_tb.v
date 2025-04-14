`timescale 1ns/1ps

// -------------------------------------------------------------------------
// Dummy predictor_btb_wrapper: minimal functionality just to allow
// f2_TOP to compile. Its outputs are tied to constants.
// -------------------------------------------------------------------------
module predictor_btb_wrapper(
    input         clk,
    input         reset,
    input  [31:0] branch_addr,
    input         branch_outcome,
    input         update,
    input  [31:0] update_addr,
    input  [31:0] actual_target,
    input         branch_taken,
    output        final_predict_taken,
    output [31:0] final_target_addr
);
    assign final_predict_taken = 1'b0;
    assign final_target_addr   = 32'h0;
endmodule


// -------------------------------------------------------------------------
// Testbench for the f2_TOP module focusing on the IBuff behavior.
// -------------------------------------------------------------------------
module tb_f2;

  // Clock and reset
  reg clk;
  reg rst;
  reg stall_in;
  
  // Icache signals (128-bit data width is assumed)
  reg [127:0] clc_data_in_even;
  reg [127:0] clc_data_in_odd;
  reg         clc_data_even_hit;
  reg         clc_data_odd_hit;
  
  // Unused signals for branch predictor and pc load logic.
  // These are tied to constant values.
  reg         pcd;
  reg         hit;
  reg [1:0]   way;
  reg         exceptions;
  
  reg         update_btb;
  reg [31:0]  resolved_pc;
  reg [31:0]  resolved_target;
  reg         resolved_taken;
  
  reg         resteer;
  reg [31:0]  resteer_target_D1;
  reg         resteer_taken_D1;
  reg [31:0]  resteer_target_BR;
  reg         resteer_taken_BR;
  reg [9:0]   bp_update_bhr_BR;
  reg [31:0]  resteer_target_ROB;
  reg         resteer_taken_ROB;
  reg [9:0]   bp_update_bhr_ROB;
  reg [31:0]  resteer_target_ras;
  reg         resteer_taken_ras;
  
  // Outputs from f2_TOP
  wire        exceptions_out;
  wire [511:0] IBuff_out;
  wire [31:0] pc_out;
  wire        stall;

  // -----------------------------------------------------------------------
  // Instantiate the f2_TOP module (this is your top-level module)
  // -----------------------------------------------------------------------
  f2_TOP uut (
    .clk(clk),
    .rst(rst),
    .stall_in(stall_in),
    
    .clc_data_in_even(clc_data_in_even),
    .clc_data_in_odd(clc_data_in_odd),
    .clc_data_even_hit(clc_data_even_hit),
    .clc_data_odd_hit(clc_data_odd_hit),
    
    .pcd(pcd),
    .hit(hit),
    .way(way),
    .exceptions(exceptions),
    
    .update_btb(update_btb),
    .resolved_pc(resolved_pc),
    .resolved_target(resolved_target),
    .resolved_taken(resolved_taken),
    
    .resteer(resteer),
    .resteer_target_D1(resteer_target_D1),
    .resteer_taken_D1(resteer_taken_D1),
    .resteer_target_BR(resteer_target_BR),
    .resteer_taken_BR(resteer_taken_BR),
    .bp_update_bhr_BR(bp_update_bhr_BR),
    
    .resteer_target_ROB(resteer_target_ROB),
    .resteer_taken_ROB(resteer_taken_ROB),
    .bp_update_bhr_ROB(bp_update_bhr_ROB),
    
    .resteer_target_ras(resteer_target_ras),
    .resteer_taken_ras(resteer_taken_ras),
    
    .exceptions_out(exceptions_out),
    .IBuff_out(IBuff_out),
    .pc_out(pc_out),
    .stall(stall)
  );
  
  // -----------------------------------------------------------------------
  // Clock generation: 10ns period
  // -----------------------------------------------------------------------
  initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
  end
  
  // -----------------------------------------------------------------------
  // Test stimulus to focus on IBuff behavior
  // -----------------------------------------------------------------------
  initial begin
    // Initialize inputs and assert reset
    rst              = 1;
    stall_in         = 0;
    
    clc_data_in_even = 128'b0;
    clc_data_in_odd  = 128'b0;
    clc_data_even_hit = 0;
    clc_data_odd_hit  = 0;
    
    pcd              = 0;
    hit              = 0;
    way              = 2'b00;
    exceptions       = 0;
    
    update_btb       = 0;
    resolved_pc      = 32'b0;
    resolved_target  = 32'b0;
    resolved_taken   = 0;
    
    resteer          = 0;
    resteer_target_D1 = 32'b0;
    resteer_taken_D1  = 0;
    resteer_target_BR = 32'b0;
    resteer_taken_BR  = 0;
    bp_update_bhr_BR  = 10'b0;
    resteer_target_ROB = 32'b0;
    resteer_taken_ROB = 0;
    bp_update_bhr_ROB  = 10'b0;
    resteer_target_ras = 32'b0;
    resteer_taken_ras  = 0;
    
    // Hold reset for a few clock cycles
    #12;
    rst = 0;
    
    // ---------------------------------------------------------------------
    // Test 1: Load even cache line into slot 0
    // ---------------------------------------------------------------------
    // Apply even cache-line hit with a known pattern.
    clc_data_in_even = 128'h11111111111111111111111111111111;
    clc_data_even_hit = 1;
    #10;  // allow one clock cycle for load
    clc_data_even_hit = 0;
    #10;
    $display("Test 1: After even IBuff load, IBuff_out = %h", IBuff_out);
    
    // ---------------------------------------------------------------------
    // Test 2: Load odd cache line into slot 1
    // ---------------------------------------------------------------------
    clc_data_in_odd = 128'hAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA;
    clc_data_odd_hit = 1;
    #10;
    clc_data_odd_hit = 0;
    #10;
    $display("Test 2: After odd IBuff load, IBuff_out = %h", IBuff_out);
    
    // ---------------------------------------------------------------------
    // Test 3: Second even IBuff load; slot 0 is already valid so data goes to slot 2
    // ---------------------------------------------------------------------
    clc_data_in_even = 128'h22222222222222222222222222222222;
    clc_data_even_hit = 1;
    #10;
    clc_data_even_hit = 0;
    #10;
    $display("Test 3: After second even IBuff load (slot2), IBuff_out = %h", IBuff_out);
    
    // ---------------------------------------------------------------------
    // Test 4: Second odd IBuff load; slot 1 is already valid so data goes to slot 3
    // ---------------------------------------------------------------------
    clc_data_in_odd = 128'hBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB;
    clc_data_odd_hit = 1;
    #10;
    clc_data_odd_hit = 0;
    #10;
    $display("Test 4: After second odd IBuff load (slot3), IBuff_out = %h", IBuff_out);
    
    // ---------------------------------------------------------------------
    // Test 5: Stall condition on even IBuff load
    // Both even slots (slot 0 and 2) are now occupied.
    // A new even hit should result in stall being asserted.
    // ---------------------------------------------------------------------
    clc_data_in_even = 128'h33333333333333333333333333333333;
    clc_data_even_hit = 1;
    #10;
    $display("Test 5: Checking stall condition for even IBuff load, stall = %b", stall);
    clc_data_even_hit = 0;
    
    #20;
    $finish;
  end

endmodule
