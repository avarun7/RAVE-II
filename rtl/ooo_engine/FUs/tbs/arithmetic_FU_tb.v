`timescale 1ns/1ps

module arithmetic_FU_tb;
  // Parameters
  parameter XLEN = 32;
  
  // Test bench signals
  reg clk;
  reg rst;
  reg valid_in;
  reg additional_info;
  reg [2:0] arithmetic_type;
  reg [XLEN-1:0] rs1;
  reg [XLEN-1:0] rs2;
  
  wire            valid_out;
  wire[XLEN - 1:0]  result;
  
  // Instantiate the TLB
  arithmetic_FU #(
    .XLEN(XLEN)
  ) arithmetic_fu(
    .clk(clk),
    .rst(rst),
    .valid_in(valid_in),
    .additional_info(additional_info),
    .arithmetic_type(arithmetic_type),
    .rs1(rs1),
    .rs2(rs2),

    .valid_out(valid_out),
    .result(result)
  );
  
  // Clock generation
  always begin
    #5 clk = ~clk;
  end
  
  // Initial block for waveform generation
  initial begin
    // Create VCD file
    $dumpfile("arithmetic_FU.vcd");
    // Dump all variables including those in sub-modules
    $dumpvars(0, arithmetic_FU_tb);
    // Add specific signals to wave window with hierarchy
  end

  // Add string labels for test phases (for waveform viewer)
  reg [127:0] test_phase;

  initial begin
    test_phase = "Initialize";
  end

  integer errors;
  integer expected;
  
  // Test scenarios
  initial begin
    // Initialize signals
    rst = 0;
    clk = 0;
    additional_info = 0;
    rst = 0;
    valid_in = 0;
    arithmetic_type = 0;
    rs1 = 0;
    rs2 = 0;
    errors = 0;
    
    // Apply reset
    #10;
    test_phase = "Reset";
    rst = 1;
    #10 rst = 0;
    
    // Wait for reset to complete
    #20;
    test_phase = "Post-Reset";
    if(valid_out != valid_in)
      $display("YO THIS SHIT BROKEN");

    valid_in = 1;
    

/*#################################################################################*/
    test_phase = "Adder";
    additional_info = 0;
    arithmetic_type = 0;
    errors = 0;
    // Test Case 1: Basic addition
    rs1 = 32'h00000001; rs2 = 32'h00000001; expected = 32'h00000002;
    #10;
    check_result;
    
    // Test Case 2: Zero addition
    rs1 = 32'h00000000; rs2 = 32'h00000000; expected = 32'h00000000;
    #10;
    check_result;
    
    // Test Case 3: Large numbers
    rs1 = 32'h7FFFFFFF; rs2 = 32'h00000001; expected = 32'h80000000;
    #10;
    check_result;
    
    // Test Case 4: Overflow
    rs1 = 32'h80000000; rs2 = 32'h80000000; expected = 32'h00000000;
    #10;
    check_result;

    // Test Case 9: Carry chain
    rs1 = 32'hFFFFFFFF; rs2 = 32'h00000001; expected = 32'h00000000;
    #10;
    check_result;
    
    // Test Case 10: Multiple carries
    rs1 = 32'hFFFFFFFF; rs2 = 32'hFFFFFFFF; expected = 32'hFFFFFFFE;
    #10;
    check_result;
    
     // Test Case 13: Max positive + 1
    rs1 = 32'h7FFFFFFF; rs2 = 32'h00000001; expected = 32'h80000000;
    #10;
    check_result;
    
    // Test Case 14: Max negative + max negative
    rs1 = 32'h80000000; rs2 = 32'h80000000; expected = 32'h00000000;
    #10;
    check_result;

    // Test Case 17: Alternating bits
    rs1 = 32'hAAAAAAAA; rs2 = 32'h55555555; expected = 32'hFFFFFFFF;
    #10;
    check_result;
    
    // Test Case 18: Mixed patterns
    rs1 = 32'hDEADBEEF; rs2 = 32'h12345678; expected = 32'hF0E21567;
    #10;
    check_result;

    if (errors == 0)
        $display("All ADD test cases passed!");
    else
        $display("Failed %d test cases.", errors);

    test_phase = "Subtractor";
    additional_info = 1;
    errors = 0;
    // Test Case 6: Basic subtraction
    rs1 = 32'h00000002; rs2 = 32'h00000001; expected = 32'h00000001;
    #10;
    check_result;
    
    // Test Case 7: Zero result
    rs1 = 32'h00000001; rs2 = 32'h00000001; expected = 32'h00000000;
    #10;
    check_result;
    
    // Test Case 8: Negative result
    rs1 = 32'h00000001; rs2 = 32'h00000002; expected = 32'hFFFFFFFF;
    #10;
    check_result;

    // Test Case 11: Large number subtraction
    rs1 = 32'h80000000; rs2 = 32'h00000001; expected = 32'h7FFFFFFF;
    #10;
    check_result;
    
    // Test Case 12: Borrow chain
    rs1 = 32'h00000000; rs2 = 32'h00000001; expected = 32'hFFFFFFFF;
    #10;
    check_result;

    // Test Case 15: Max positive - (-1)
    rs1 = 32'h7FFFFFFF; rs2 = 32'hFFFFFFFF; expected = 32'h80000000;
    #10;
    check_result;
    
    // Test Case 16: Zero - max positive
    rs1 = 32'h00000000; rs2 = 32'h7FFFFFFF; expected = 32'h80000001;
    #10;
    check_result;

    // Test Case 19: Power of 2 differences
    rs1 = 32'h00010000; rs2 = 32'h00001000; expected = 32'h0000F000;
    #10;
    check_result;
    
    // Test Case 20: Sparse bit patterns
    rs1 = 32'h10101010; rs2 = 32'h01010101; expected = 32'h0F0F0F0F;
    #10;
    check_result;

    if (errors == 0)
        $display("All sub test cases passed!");
    else
        $display("Failed %d test cases.", errors);

/*#################################################################################*/
    
    test_phase = "SLT";
    additional_info = 0;
    arithmetic_type = 2;
    errors = 0;
    
    rs1 = 32'h00000001; rs2 = 32'h00000002; expected = 32'h00000001;  // 1 < 2 (true for both)
    #10;
    check_result;
    rs1 = 32'h00000002; rs2 = 32'h00000001; expected = 32'h00000000;
    #10;
    check_result;
    rs1 = 32'h00000005; rs2 = 32'h00000005; expected = 32'h00000000;
    #10;
    check_result;

    // Comparing with zero
    rs1 = 32'h00000000; rs2 = 32'h00000001; expected = 32'h00000001; 
    #10;
    check_result;
    rs1 = 32'h00000001; rs2 = 32'h00000000; expected = 32'h00000000; 
    #10;
    check_result;
    rs1 = 32'h00000000; rs2 = 32'h00000000; expected = 32'h00000000;
    #10;
    check_result;
    // Signed vs Unsigned differences with negative numbers
    rs1 = 32'hFFFFFFFF; rs2 = 32'h00000001; expected = 32'h00000001; 
    #10;
    check_result;
    rs1 = 32'h00000001; rs2 = 32'hFFFFFFFF; expected = 32'h00000000; 
    #10;
    check_result;
    rs1 = 32'hFFFFFFFF; rs2 = 32'hFFFFFFFE; expected = 32'h00000000; 
    #10;
    check_result;
    // Edge cases
    rs1 = 32'h80000000; rs2 = 32'h7FFFFFFF; expected = 32'h00000001; 
    #10;
    check_result;
    rs1 = 32'h7FFFFFFF; rs2 = 32'h80000000; expected = 32'h00000000; 
    #10;
    check_result;
    rs1 = 32'h80000000; rs2 = 32'h80000000; expected = 32'h00000000; 
    #10;
    check_result;
    rs1 = 32'h7FFFFFFF; rs2 = 32'h7FFFFFFF; expected = 32'h00000000; 
    #10;
    check_result;
    // Large number comparisons
    rs1 = 32'h12345678; rs2 = 32'h87654321; expected = 32'h00000000; 
    #10;
    check_result;
    rs1 = 32'h87654321; rs2 = 32'h12345678; expected = 32'h00000001; 
    #10;
    check_result;
    // Pattern tests
    rs1 = 32'hAAAAAAAA; rs2 = 32'h55555555; expected = 32'h00000001; 
    #10;
    check_result;
    rs1 = 32'h55555555; rs2 = 32'hAAAAAAAA; expected = 32'h00000000; 
    #10;
    check_result;

    if (errors == 0)
        $display("All Set Less Than test cases passed!");
    else
        $display("Failed %d test cases.", errors);

/*#################################################################################*/
    
    test_phase = "SLTU";
    additional_info = 0;
    arithmetic_type = 3;
    errors = 0;

    rs1 = 32'h00000001; rs2 = 32'h00000002; expected = 32'h00000001;  // 1 < 2 (true for both)
    #10;
    check_result;
    rs1 = 32'h00000002; rs2 = 32'h00000001; expected = 32'h00000000;  // 2 < 1 (false for both)
    #10;
    check_result;
    rs1 = 32'h00000005; rs2 = 32'h00000005; expected = 32'h00000000;  // 5 < 5 (false for both)
    #10;
    check_result;

    // Comparing with zero
    rs1 = 32'h00000000; rs2 = 32'h00000001; expected = 32'h00000001;  // 0 < 1 (true for both)
    #10;
    check_result;
    rs1 = 32'h00000001; rs2 = 32'h00000000; expected = 32'h00000000;  // 1 < 0 (false for both)
    #10;
    check_result;
    rs1 = 32'h00000000; rs2 = 32'h00000000; expected = 32'h00000000;  // 0 < 0 (false for both)
    #10;
    check_result;
    // Signed vs Unsigned differences with negative numbers
    rs1 = 32'hFFFFFFFF; rs2 = 32'h00000001; expected = 32'h00000000;  // -1 < 1 (true signed, false unsigned)
    #10;
    check_result;
    rs1 = 32'h00000001; rs2 = 32'hFFFFFFFF; expected = 32'h00000001;  // 1 < -1 (false signed, true unsigned)
    #10;
    check_result;
    rs1 = 32'hFFFFFFFF; rs2 = 32'hFFFFFFFE; expected = 32'h00000000;  // -1 < -2 (false for both)
    #10;
    check_result;
    // Edge cases
    rs1 = 32'h80000000; rs2 = 32'h7FFFFFFF; expected = 32'h00000000;  // MIN_INT < MAX_INT (true signed, false unsigned)
    #10;
    check_result;
    rs1 = 32'h7FFFFFFF; rs2 = 32'h80000000; expected = 32'h00000001;  // MAX_INT < MIN_INT (false signed, true unsigned)
    #10;
    check_result;
    rs1 = 32'h80000000; rs2 = 32'h80000000; expected = 32'h00000000;  // MIN_INT < MIN_INT (false for both)
    #10;
    check_result;
    rs1 = 32'h7FFFFFFF; rs2 = 32'h7FFFFFFF; expected = 32'h00000000;  // MAX_INT < MAX_INT (false for both)
    #10;
    check_result;
    // Large number comparisons
    rs1 = 32'h12345678; rs2 = 32'h87654321; expected = 32'h00000001;  // Different results signed vs unsigned
    #10;
    check_result;
    rs1 = 32'h87654321; rs2 = 32'h12345678; expected = 32'h00000000;  // Different results signed vs unsigned
    #10;
    check_result;
    // Pattern tests
    rs1 = 32'hAAAAAAAA; rs2 = 32'h55555555; expected = 32'h00000000;  // Alternating patterns
    #10;
    check_result;
    rs1 = 32'h55555555; rs2 = 32'hAAAAAAAA; expected = 32'h00000001;  // Alternating patterns reversed
    #10;
    check_result;

    if (errors == 0)
        $display("All Set Less Than Unsigned test cases passed!");
    else
        $display("Failed %d test cases.", errors);
        
    $finish;
  end

  task check_result;
        begin
            if (result !== expected) begin
                errors = errors + 1;
                $display("%0t\t%h\t%h\t%h\t%h\tFAIL", $time, rs1, rs2, expected, result);
            end 
        end
    endtask

endmodule
