`timescale 1ns/1ps

module logical_FU_tb;
  // Parameters
  parameter XLEN = 32;
  
  // Test bench signals
  reg clk;
  reg rst;
  reg valid_in;
  reg additional_info;
  reg [2:0] logical_type;
  reg [XLEN-1:0] rs1;
  reg [XLEN-1:0] rs2;
  
  wire            valid_out;
  wire[XLEN - 1:0]  result;
  
  // Instantiate the TLB
  logical_FU #(
    .XLEN(XLEN)
  ) logical_fu(
    .clk(clk),
    .rst(rst),
    .valid_in(valid_in),
    .additional_info(additional_info),
    .logical_type(logical_type),
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
    $dumpfile("logical_fu.vcd");
    // Dump all variables including those in sub-modules
    $dumpvars(0, logical_FU_tb);
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
    logical_type = 0;
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
    
    
    valid_in = 1;

/*#################################################################################*/

    test_phase = "XOR Tests";
    logical_type = 3'b100;
    // Test Case 1: All zeros
    rs1 = 32'h00000000; rs2 = 32'h00000000; expected = 32'h00000000;
    #10;
    check_result;
    
    // Test Case 2: All ones
    rs1 = 32'hFFFFFFFF; rs2 = 32'hFFFFFFFF; expected = 32'h00000000;
    #10;
    check_result;
    
    // Test Case 3: Alternating patterns
    rs1 = 32'hAAAAAAAA; rs2 = 32'h55555555; expected = 32'hFFFFFFFF;
    #10;
    check_result;
    
    // Test Case 4: Walking 1 in first operand
    rs1 = 32'h00000001; rs2 = 32'hFFFFFFFF; expected = 32'hFFFFFFFE;
    #10;
    check_result;
    
    rs1 = 32'h00000002; rs2 = 32'hFFFFFFFF; expected = 32'hFFFFFFFD;
    #10;
    check_result;
    
    rs1 = 32'h00000004; rs2 = 32'hFFFFFFFF; expected = 32'hFFFFFFFB;
    #10;
    check_result;
    
    // Boundary Tests
    // Test Case 5: MSrs2 only
    rs1 = 32'h80000000; rs2 = 32'h80000000; expected = 32'h00000000;
    #10;
    check_result;
    
    // Test Case 6: LSrs2 only
    rs1 = 32'h00000001; rs2 = 32'h00000001; expected = 32'h00000000;
    #10;
    check_result;
    
    // Pattern Tests
    // Test Case 7: Checkerboard patterns
    rs1 = 32'hAAAAAAAA; rs2 = 32'hAAAAAAAA; expected = 32'h00000000;
    #10;
    check_result;
    
    // Test Case 8: Sliding windows
    rs1 = 32'h0000FFFF; rs2 = 32'hFFFF0000; expected = 32'hFFFFFFFF;
    #10;
    check_result;
    
    // Test Case 9: Byte-wise patterns
    rs1 = 32'h0F0F0F0F; rs2 = 32'hF0F0F0F0; expected = 32'hFFFFFFFF;
    #10;
    check_result;
    
    // Random Value Tests
    // Test Case 10: Random combinations
    rs1 = 32'h12345678; rs2 = 32'h87654321; expected = 32'h95511559;
    #10;
    check_result;
    
    rs1 = 32'hDEADBEEF; rs2 = 32'h12345678; expected = 32'hCC99E897;
    #10;
    check_result;
    
    rs1 = 32'hCAFEBABE; rs2 = 32'hBABECAFE; expected = 32'h70407040;
    #10;
    check_result;

    // Report final results
    if (errors == 0)
        $display("\nAll XOR test cases passed!");
    else
        $display("\nFailed %d test cases.", errors);

/*#################################################################################*/

    logical_type = 3'b110;
    test_phase = "OR";
    errors = 0;

    // Test Case 1: All zeros
    rs1 = 32'h00000000; rs2 = 32'h00000000; expected = 32'h00000000;
    #10;
    check_result;
    
    // Test Case 2: All ones
    rs1 = 32'hFFFFFFFF; rs2 = 32'hFFFFFFFF; expected = 32'hFFFFFFFF;
    #10;
    check_result;
    
    // Test Case 3: One register all ones
    rs1 = 32'hFFFFFFFF; rs2 = 32'h00000000; expected = 32'hFFFFFFFF;
    #10;
    check_result;
    
    // Test Case 4: Alternating bits
    rs1 = 32'hAAAAAAAA; rs2 = 32'h55555555; expected = 32'hFFFFFFFF;
    #10;
    check_result;
    
    // Test Case 5: Same alternating bits
    rs1 = 32'hAAAAAAAA; rs2 = 32'hAAAAAAAA; expected = 32'hAAAAAAAA;
    #10;
    check_result;
    
    // Test Case 6: Single bits
    rs1 = 32'h00000001; rs2 = 32'h00000002; expected = 32'h00000003;
    #10;
    check_result;
    
    // Test Case 7: Byte patterns
    rs1 = 32'hFF00FF00; rs2 = 32'h00FF00FF; expected = 32'hFFFFFFFF;
    #10;
    check_result;
    
    // Test Case 8: Common value
    rs1 = 32'hDEADBEEF; rs2 = 32'h12345678; expected = 32'hDEBDFEFF;
    #10;
    check_result;
    
    // Test Case 9: Walking ones
    rs1 = 32'h00000007; rs2 = 32'h00000038; expected = 32'h0000003F;
    #10;
    check_result;
    
    // Test Case 10: Sparse bits
    rs1 = 32'h10101010; rs2 = 32'h01010101; expected = 32'h11111111;
    #10;
    check_result;
    
    // Test Case 11: Half-word patterns
    rs1 = 32'hFFFF0000; rs2 = 32'h0000FFFF; expected = 32'hFFFFFFFF;
    #10;
    check_result;
    
    // Test Case 12: Random pattern
    rs1 = 32'hA5A5A5A5; rs2 = 32'h5A5A5A5A; expected = 32'hFFFFFFFF;
    #10;
    check_result;
    
    // Test Case 13: MSB tests
    rs1 = 32'h80000000; rs2 = 32'h00000001; expected = 32'h80000001;
    #10;
    check_result;
    
    // Test Case 14: LSB tests
    rs1 = 32'h00000001; rs2 = 32'h00000002; expected = 32'h00000003;
    #10;
    check_result;
    
    // Test Case 15: Complex pattern
    rs1 = 32'hF0F0F0F0; rs2 = 32'h0F0F0F0F; expected = 32'hFFFFFFFF;
    #10;
    check_result;

    if (errors == 0)
        $display("\nAll OR test cases passed!");
    else
        $display("\nFailed %d test cases.", errors);

/*#################################################################################*/

    logical_type = 3'b111;
    test_phase = "AND";
    errors = 0;

    // Test Case 1: All zeros
    rs1 = 32'h00000000; rs2 = 32'h00000000; expected = 32'h00000000;
    #10;
    check_result;
    
    // Test Case 2: All ones
    rs1 = 32'hFFFFFFFF; rs2 = 32'hFFFFFFFF; expected = 32'hFFFFFFFF;
    #10;
    check_result;
    
    // Test Case 3: One register all ones
    rs1 = 32'hFFFFFFFF; rs2 = 32'h00000000; expected = 32'h00000000;
    #10;
    check_result;
    
    // Test Case 4: Alternating bits
    rs1 = 32'hAAAAAAAA; rs2 = 32'h55555555; expected = 32'h00000000;
    #10;
    check_result;
    
    // Test Case 5: Same alternating bits
    rs1 = 32'hAAAAAAAA; rs2 = 32'hAAAAAAAA; expected = 32'hAAAAAAAA;
    #10;
    check_result;
    
    // Test Case 6: Single bits
    rs1 = 32'h00000001; rs2 = 32'h00000001; expected = 32'h00000001;
    #10;
    check_result;
    
    // Test Case 7: Byte patterns
    rs1 = 32'hFF00FF00; rs2 = 32'hFFFF0000; expected = 32'hFF000000;
    #10;
    check_result;
    
    // Test Case 8: Common value
    rs1 = 32'hDEADBEEF; rs2 = 32'h12345678; expected = 32'h12241668;
    #10;
    check_result;
    
    // Test Case 9: Walking ones
    rs1 = 32'h00000007; rs2 = 32'h00000003; expected = 32'h00000003;
    #10;
    check_result;
    
    // Test Case 10: Sparse bits
    rs1 = 32'h10101010; rs2 = 32'h10101010; expected = 32'h10101010;
    #10;
    check_result;
    
    // Test Case 11: Half-word patterns
    rs1 = 32'hFFFF0000; rs2 = 32'hFFFFFFFF; expected = 32'hFFFF0000;
    #10;
    check_result;
    
    // Test Case 12: Random pattern
    rs1 = 32'hA5A5A5A5; rs2 = 32'h5A5A5A5A; expected = 32'h00000000;
    #10;
    check_result;
    
    // Test Case 13: MSB tests
    rs1 = 32'h80000000; rs2 = 32'h80000000; expected = 32'h80000000;
    #10;
    check_result;
    
    // Test Case 14: LSB tests
    rs1 = 32'h00000001; rs2 = 32'h00000003; expected = 32'h00000001;
    #10;
    check_result;
    
    // Test Case 15: Complex pattern
    rs1 = 32'hF0F0F0F0; rs2 = 32'hFF00FF00; expected = 32'hF000F000;
    #10;
    check_result;

    if (errors == 0)
        $display("\nAll AND test cases passed!");
    else
        $display("\nFailed %d test cases.", errors);
    
/*#################################################################################*/
    
    test_phase = "Left Shift";
    logical_type = 3'b001;
    errors = 0;
    
    // Test Case 1: No shift
    rs1 = 32'h00000001; rs2 = 5'd0; expected = 32'h00000001;
    #10;
    check_result;
    
    // Test Case 2: Shift by 1
    rs1 = 32'h00000001; rs2 = 5'd1; expected = 32'h00000002;
    #10;
    check_result;
    
    // Test Case 3: Multiple bit shifts
    rs1 = 32'h00000001; rs2 = 5'd4; expected = 32'h00000010;
    #10;
    check_result;
    
    // Edge Cases
    // Test Case 4: Shift 31 positions (maximum)
    rs1 = 32'h00000001; rs2 = 5'd31; expected = 32'h80000000;
    #10;
    check_result;
    
    // Test Case 5: Overflow, should not
    rs1 = 32'h00000001; rs2 = 6'd32; expected = 32'h00000001;
    #10;
    check_result;
    
    // Pattern Tests
    // Test Case 6: Two full size numbers, should shift h'18
    rs1 = 32'h55555555; rs2 = 32'hFEDCBA98; expected = 32'h55000000;
    #10;
    check_result;
    
    // Test Case 7: All ones
    rs1 = 32'hFFFFFFFF; rs2 = 5'd4; expected = 32'hFFFFFFF0;
    #10;
    check_result;
    
    // Test Case 8: Multiple 1's shifting
    rs1 = 32'h00000003; rs2 = 5'd1; expected = 32'h00000006;
    #10;
    check_result;
    
    // Boundary Value Tests
    // Test Case 9: MSB set
    rs1 = 32'h80000000; rs2 = 5'd1; expected = 32'h00000000;
    #10;
    check_result;
    
    // Test Case 10: LSB set with large shift
    rs1 = 32'h00000001; rs2 = 5'd30; expected = 32'h40000000;
    #10;
    check_result;
    
    // Pattern Shifts
    // Test Case 11: Byte pattern
    rs1 = 32'h12345678; rs2 = 5'd8; expected = 32'h34567800;
    #10;
    check_result;
    
    // Test Case 12: Half-word shift
    rs1 = 32'h12345678; rs2 = 5'd16; expected = 32'h56780000;
    #10;
    check_result;
    
    // Multiple Bit Pattern Tests
    // Test Case 13: Walking ones
    rs1 = 32'h00000007; rs2 = 5'd2; expected = 32'h0000001C;
    #10;
    check_result;
    
    // Test Case 14: Sparse bit pattern
    rs1 = 32'h10101010; rs2 = 5'd3; expected = 32'h80808080;
    #10;
    check_result;
    
    // Common Values
    // Test Case 15: Shift 0xDEADBEEF
    rs1 = 32'hDEADBEEF; rs2 = 5'd4; expected = 32'hEADBEEF0;
    #10;
    check_result;
    
    // Test Case 16: Shift 0xAAAAAAAA
    rs1 = 32'hAAAAAAAA; rs2 = 5'd2; expected = 32'hAAAAAAA8;
    #10;
    check_result;
    
    // Random shifts with different values
    // Test Case 17: Random value 1
    rs1 = 32'h76543210; rs2 = 5'd7; expected = 32'h2a190800;
    #10;
    check_result;
    
    // Test Case 18: Random value 2
    rs1 = 32'hFEDCBA98; rs2 = 5'd12; expected = 32'hCBA98000;
    #10;
    check_result;

    if (errors == 0)
        $display("\nAll Left Shift test cases passed!");
    else
        $display("\nFailed %d test cases.", errors);

/*#################################################################################*/

    test_phase = "Right Shift";
    logical_type = 3'b101;
    errors = 0;
    additional_info = 0;
        
    // Test Case 1: No shift
    rs1 = 32'h80000000; rs2 = 5'd0; expected = 32'h80000000;
    #10;
    check_result;
    
    // Test Case 2: Shift by 1
    rs1 = 32'h80000000; rs2 = 5'd1; expected = 32'h40000000;
    #10;
    check_result;
    
    // Test Case 3: Multiple bit shifts
    rs1 = 32'h80000000; rs2 = 5'd4; expected = 32'h08000000;
    #10;
    check_result;
    
    // Test Case 4: Shift all bits
    rs1 = 32'hFFFFFFFF; rs2 = 5'd31; expected = 32'h00000001;
    #10;
    check_result;
    
    // Test Case 5: Pattern shifts
    rs1 = 32'hAAAAAAAA; rs2 = 5'd1; expected = 32'h55555555;
    #10;
    check_result;
    
    // Arithmetic Right Shift Tests (additional_info = 1)
    additional_info = 1;
    
    // Test Case 6: Positive number shifts
    rs1 = 32'h7FFFFFFF; rs2 = 5'd4; expected = 32'h07FFFFFF;
    #10;
    check_result;
    
    // Test Case 7: Negative number shifts
    rs1 = 32'h80000000; rs2 = 5'd4; expected = 32'hF8000000;
    #10;
    check_result;
    
    // Test Case 8: All ones (negative 1) shifting
    rs1 = 32'hFFFFFFFF; rs2 = 5'd16; expected = 32'hFFFFFFFF;
    #10;
    check_result;
    
    // More Complex Pattern Tests - Logical
    additional_info = 0;
    
    // Test Case 9: byte boundaries
    rs1 = 32'h12345678; rs2 = 5'd8; expected = 32'h00123456;
    #10;
    check_result;
    
    // Test Case 10: half word
    rs1 = 32'h12345678; rs2 = 5'd16; expected = 32'h00001234;
    #10;
    check_result;
    
    // Test Case 11: sparse patterns
    rs1 = 32'h10101010; rs2 = 5'd1; expected = 32'h08080808;
    #10;
    check_result;
    
    // More Complex Pattern Tests - Arithmetic
    additional_info = 1;
    
    // Test Case 12: Negative number partial shift
    rs1 = 32'h80000000; rs2 = 5'd16; expected = 32'hFFFF8000;
    #10;
    check_result;
    
    // Test Case 13: Negative number with ones
    rs1 = 32'hF0000000; rs2 = 5'd4; expected = 32'hFF000000;
    #10;
    check_result;
    
    // Edge Cases - Logical
    additional_info = 0;
    
    // Test Case 14: Maximum shift
    rs1 = 32'hFFFFFFFF; rs2 = 5'd31; expected = 32'h00000001;
    #10;
    check_result;
    
    // Test Case 15: Shift out all bits
    rs1 = 32'hFFFFFFFF; rs2 = 6'd32; expected = 32'hFFFFFFFF;
    #10;
    check_result;
    
    // Edge Cases - Arithmetic
    additional_info = 1;
    
    // Test Case 16: Maximum shift with negative
    rs1 = 32'h80000000; rs2 = 5'd31; expected = 32'hFFFFFFFF;
    #10;
    check_result;
    
    // Test Case 17: Shift with alternating pattern
    rs1 = 32'hAAAAAAAA; rs2 = 5'd2; expected = 32'hEAAAAAAA;
    #10;
    check_result;
    
    // Common Values
    additional_info = 0; // Logical
    
    // Test Case 18: Shift 0xDEADBEEF
    rs1 = 32'hDEADBEEF; rs2 = 5'd4; expected = 32'h0DEADBEE;
    #10;
    check_result;
    
    additional_info = 1; // Arithmetic
    
    // Test Case 19: Shift 0xDEADBEEF
    rs1 = 32'hDEADBEEF; rs2 = 5'd4; expected = 32'hFDEADBEE;
    #10;
    check_result;

    if (errors == 0)
        $display("\nAll Right Shift test cases passed!");
    else
        $display("\nFailed %d test cases.", errors);

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
