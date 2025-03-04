`timescale 1ns/1ps

module muldiv_FU_tb;
  // Parameters
  parameter XLEN = 32;
  
  // Test bench signals
  reg clk;
  reg rst;
  reg valid_in;
  reg [2:0] md_type;
  reg [XLEN-1:0] rs1;
  reg [XLEN-1:0] rs2;
  
  wire            valid_out;
  wire[XLEN - 1:0]  result;
  
  // Instantiate the TLB
  md_FU #(
    .XLEN(XLEN)
  ) muldiv_FU(
    .clk(clk),
    .rst(rst),
    .valid_in(valid_in),
    .md_type(md_type),
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
    $dumpfile("muldiv_FU.vcd");
    // Dump all variables including those in sub-modules
    $dumpvars(0, muldiv_FU_tb);
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
    rst = 0;
    valid_in = 0;
    md_type = 0;
    rs1 = 0;
    rs2 = 0;
    errors = 0;
    
    // Apply reset
    #10;
    test_phase = "Reset";
    rst = 1;
    #10 
    rst = 0;
    
    // Wait for reset to complete
    #20;
    test_phase = "Post-Reset";
    if(valid_out != valid_in)
      $display("YO THIS SHIT BROKEN");

    valid_in = 1;

/*#################################################################################*/
    test_phase = "MUL";
    md_type = 3'b000;
    errors = 0;

  // Test case 1: Simple positive numbers
    rs1 = 32'd10;   rs2 = 32'd5;
    expected = 32'd50;          // (10 * 5) & 0xFFFFFFFF = 50
    #10;
    check_result;
    
    // Test case 2: Large positive numbers
    rs1 = 32'h0000FFFF;  // 65535
    rs2 = 32'h0000FFFF;  // 65535
    expected = 32'hFFFE_0001;           // (65535 * 65535) & 0xFFFFFFFF
    #10;
    check_result;
    
    // Test case 3: Maximum positive value
    rs1 = 32'h7FFF_FFFF;  // 2147483647
    rs2 = 32'h7FFF_FFFF;  // 2147483647
    expected = 32'h0000_0001;           // (2147483647 * 2147483647) & 0xFFFFFFFF
    #10;
    check_result;
    
    // Test case 4: One negative, one positive
    rs1 = 32'hFFFF_FFF1;  // -15
    rs2 = 32'h0000_0004;  // 4
    expected = 32'hFFFF_FFC4;           // (-15 * 4) & 0xFFFFFFFF
    #10;
    check_result;
    
    // Test case 5: Both negative numbers
    rs1 = 32'hFFFF_FFF4;  // -12
    rs2 = 32'hFFFF_FFFB;  // -5
    expected = 32'h0000_003C;           // (60) & 0xFFFFFFFF
    #10;
    check_result;
    
    // Test case 6: Maximum unsigned value
    rs1 = 32'hFFFF_FFFF;  // 4294967295
    rs2 = 32'hFFFF_FFFF;  // 4294967295
    expected = 32'h0000_0001;           // (4294967295 * 4294967295) & 0xFFFFFFFF
    #10;
    check_result;

    // Test case 7: One just below max positive, one small positive
    rs1 = 32'h7FFF_FFFE;  // 2147483646
    rs2 = 32'h0000_0002;  // 2
    expected = 32'hFFFF_FFFC;           // (2147483646 * 2) & 0xFFFFFFFF
    #10;
    check_result;

    // Test case 8: Minimum signed value times -1
    rs1 = 32'h8000_0000;  // -2147483648
    rs2 = 32'hFFFF_FFFF;  // -1
    expected = 32'h8000_0000;           // (-2147483648 * -1) & 0xFFFFFFFF
    #10;
    check_result;

// Test case 9: Alternating bit pattern multiplication
    rs1 = 32'h5555_5555;  // 0101... pattern
    rs2 = 32'hAAAA_AAAA;  // 1010... pattern
    expected = 32'h0000_0000;           // Lower 32 bits
    #10;
    check_result;

    // Test case 10: Power of 2 boundary
    rs1 = 32'h0001_0000;  // 65536
    rs2 = 32'h0001_0000;  // 65536
    expected = 32'h0000_0000;           // Lower 32 bits
    #10;
    check_result;

    // Test case 11: Single bit in highest position
    rs1 = 32'h4000_0000;  // Second highest bit set
    rs2 = 32'h4000_0000;  // Second highest bit set
    expected = 32'h0000_0000;           // Lower 32 bits
    #10;
    check_result;

    // Test case 12: Mixed bits with 0xF pattern
    rs1 = 32'hF0F0_F0F0;
    rs2 = 32'h0F0F_0F0F;
    expected = 32'h1E1E_1E10;           // Lower 32 bits
    #10;
    check_result;

    // Test case 13: Almost maximum times small negative
    rs1 = 32'h7FFF_FFFE;  // 2147483646
    rs2 = 32'hFFFF_FFFD;  // -3
    expected = 32'hFFFF_FFF2;           // Lower 32 bits
    #10;
    check_result;

    // Test case 14: Sparse bit pattern
    rs1 = 32'h8421_8421;  // Sparse 1s
    rs2 = 32'h1248_1248;  // Different sparse 1s
    expected = 32'h8421_8408;           // Lower 32 bits
    #10;
    check_result;

    // Test case 15: Walking ones pattern
    rs1 = 32'h0123_4567;
    rs2 = 32'h89AB_CDEF;
    expected = 32'h2236_D115;           // Lower 32 bits
    #10;
    check_result;

    // Test case 16: Edge around minimum negative
    rs1 = 32'h8000_0001;  // MIN_INT + 1
    rs2 = 32'h8000_0001;  // MIN_INT + 1
    expected = 32'h0000_0001;           // Lower 32 bits
    #10;
    check_result;

/*#################################################################################*/
    test_phase = "MUL_H";
    md_type = 3'b001;
    errors = 0;

  // Test case 1: Simple positive numbers
    rs1 = 32'd10;   
    rs2 = 32'd5;  
    expected = 32'd0;    // (10 * 5) >> 32 = 0
    #10;
    check_result;
    
    // Test case 2: Large positive numbers
    rs1 = 32'h0000FFFF;  // 65535
    rs2 = 32'h0000FFFF;  // 65535
    expected = 32'h0000_0000;    // (65535 * 65535) >> 32
    #10;
    check_result;
    
    // Test case 3: Maximum positive value
    rs1 = 32'h7FFF_FFFF;  // 2147483647
    rs2 = 32'h7FFF_FFFF;  // 2147483647
    expected = 32'h3FFF_FFFF;    // (2147483647 * 2147483647) >> 32
    #10;
    check_result;
    
    // Test case 4: One negative, one positive
    rs1 = 32'hFFFF_FFF1;  // -15
    rs2 = 32'h0000_0004;  // 4
    expected = 32'hFFFF_FFFF;    // (-15 * 4) >> 32
    #10;
    check_result;
    
    // Test case 5: Both negative numbers
    rs1 = 32'hFFFF_FFF4;  // -12
    rs2 = 32'hFFFF_FFFB;  // -5
    expected = 32'h0000_0000;    // (-12 * -5) >> 32
    #10;
    check_result;
    
    // Test case 6: Maximum unsigned value
    rs1 = 32'hFFFF_FFFF;  // 4294967295
    rs2 = 32'hFFFF_FFFF;  // 4294967295
    expected = 32'h0000_0000;    // (-1 * -1) >> 32
    #10;
    check_result;

    // Test case 7: One just below max positive, one small positive
    rs1 = 32'h7FFF_FFFE;  // 2147483646
    rs2 = 32'h0000_0002;  // 2
    expected = 32'h0000_0000;    // (2147483646 * 2) >> 32
    #10;
    check_result;

    // Test case 8: Minimum signed value times -1
    rs1 = 32'h8000_0000;  // -2147483648
    rs2 = 32'hFFFF_FFFF;  // -1
    expected = 32'h0000_0000;    // (-2147483648 * -1) >> 32
    #10;
    check_result;

// Test case 9: Alternating bit pattern multiplication
    rs1 = 32'h5555_5555;  // 0101... pattern
    rs2 = 32'hAAAA_AAAA;  // 1010... pattern
    expected = 32'hD555_5555;    // Sign extended result
    #10;
    check_result;

    // Test case 10: Power of 2 boundary
    rs1 = 32'h0001_0000;  // 65536
    rs2 = 32'h0001_0000;  // 65536
    expected = 32'h0000_0001;    // High bits of 4,294,967,296
    #10;
    check_result;

    // Test case 11: Single bit in highest position
    rs1 = 32'h4000_0000;  // Second highest bit set
    rs2 = 32'h4000_0000;  // Second highest bit set
    expected = 32'h1000_0000;    // High bits of positive result
    #10;
    check_result;

    // Test case 12: Mixed bits with 0xF pattern
    rs1 = 32'hF0F0_F0F0;
    rs2 = 32'h0F0F_0F0F;
    expected = 32'hE1E1_E1E1;    // Signed result
    #10;
    check_result;

    // Test case 13: Almost maximum times small negative
    rs1 = 32'h7FFF_FFFE;  // 2147483646
    rs2 = 32'hFFFF_FFFD;  // -3
    expected = 32'hFFFF_FFFF;    // Sign extended negative result
    #10;
    check_result;

    // Test case 14: Sparse bit pattern
    rs1 = 32'h8421_8421;  // Sparse 1s
    rs2 = 32'h1248_1248;  // Different sparse 1s
    expected = 32'hE1E1_E1E1;    // Signed result
    #10;
    check_result;

    // Test case 15: Walking ones pattern
    rs1 = 32'h0123_4567;
    rs2 = 32'h89AB_CDEF;
    expected = 32'hFFFF_FFAE;    // Signed result
    #10;
    check_result;

    // Test case 16: Edge around minimum negative
    rs1 = 32'h8000_0001;  // MIN_INT + 1
    rs2 = 32'h8000_0001;  // MIN_INT + 1
    expected = 32'h4000_0000;    // Signed result
    #10;
    check_result;

/*#################################################################################*/
    test_phase = "MULU";
    md_type = 3'b010;
    errors = 0;

  // Test case 1: Simple positive numbers
    rs1 = 32'd10;   rs2 = 32'd5;
    expected = 32'd50;          // (10 * 5) & 0xFFFFFFFF = 50
    #10;
    check_result;
    
    // Test case 2: Large positive numbers
    rs1 = 32'h0000FFFF;  // 65535
    rs2 = 32'h0000FFFF;  // 65535
    expected = 32'hFFFE_0001;           // (65535 * 65535) & 0xFFFFFFFF
    #10;
    check_result;
    
    // Test case 3: Maximum positive value
    rs1 = 32'h7FFF_FFFF;  // 2147483647
    rs2 = 32'h7FFF_FFFF;  // 2147483647
    expected = 32'h0000_0001;           // (2147483647 * 2147483647) & 0xFFFFFFFF
    #10;
    check_result;
    
    // Test case 4: One negative, one positive
    rs1 = 32'hFFFF_FFF1;  // -15
    rs2 = 32'h0000_0004;  // 4
    expected = 32'hFFFF_FFC4;           // (-15 * 4) & 0xFFFFFFFF
    #10;
    check_result;
    
    // Test case 5: Both negative numbers
    rs1 = 32'hFFFF_FFF4;  // -12
    rs2 = 32'hFFFF_FFFB;  // -5
    expected = 32'h0000_003C;           // (60) & 0xFFFFFFFF
    #10;
    check_result;
    
    // Test case 6: Maximum unsigned value
    rs1 = 32'hFFFF_FFFF;  // 4294967295
    rs2 = 32'hFFFF_FFFF;  // 4294967295
    expected = 32'h0000_0001;           // (4294967295 * 4294967295) & 0xFFFFFFFF
    #10;
    check_result;

    // Test case 7: One just below max positive, one small positive
    rs1 = 32'h7FFF_FFFE;  // 2147483646
    rs2 = 32'h0000_0002;  // 2
    expected = 32'hFFFF_FFFC;           // (2147483646 * 2) & 0xFFFFFFFF
    #10;
    check_result;

    // Test case 8: Minimum signed value times -1
    rs1 = 32'h8000_0000;  // -2147483648
    rs2 = 32'hFFFF_FFFF;  // -1
    expected = 32'h8000_0000;           // (-2147483648 * -1) & 0xFFFFFFFF
    #10;
    check_result;

// Test case 9: Alternating bit pattern multiplication
    rs1 = 32'h5555_5555;  // 0101... pattern
    rs2 = 32'hAAAA_AAAA;  // 1010... pattern
    expected = 32'h0000_0000;           // Lower 32 bits
    #10;
    check_result;

    // Test case 10: Power of 2 boundary
    rs1 = 32'h0001_0000;  // 65536
    rs2 = 32'h0001_0000;  // 65536
    expected = 32'h0000_0000;           // Lower 32 bits
    #10;
    check_result;

    // Test case 11: Single bit in highest position
    rs1 = 32'h4000_0000;  // Second highest bit set
    rs2 = 32'h4000_0000;  // Second highest bit set
    expected = 32'h0000_0000;           // Lower 32 bits
    #10;
    check_result;

    // Test case 12: Mixed bits with 0xF pattern
    rs1 = 32'hF0F0_F0F0;
    rs2 = 32'h0F0F_0F0F;
    expected = 32'h1E1E_1E10;           // Lower 32 bits
    #10;
    check_result;

    // Test case 13: Almost maximum times small negative
    rs1 = 32'h7FFF_FFFE;  // 2147483646
    rs2 = 32'hFFFF_FFFD;  // -3
    expected = 32'hFFFF_FFF2;           // Lower 32 bits
    #10;
    check_result;

    // Test case 14: Sparse bit pattern
    rs1 = 32'h8421_8421;  // Sparse 1s
    rs2 = 32'h1248_1248;  // Different sparse 1s
    expected = 32'h8421_8408;           // Lower 32 bits
    #10;
    check_result;

    // Test case 15: Walking ones pattern
    rs1 = 32'h0123_4567;
    rs2 = 32'h89AB_CDEF;
    expected = 32'h2236_D115;           // Lower 32 bits
    #10;
    check_result;

    // Test case 16: Edge around minimum negative
    rs1 = 32'h8000_0001;  // MIN_INT + 1
    rs2 = 32'h8000_0001;  // MIN_INT + 1
    expected = 32'h0000_0001;           // Lower 32 bits
    #10;
    check_result;

/*#################################################################################*/
    test_phase = "MULU_H";
    md_type = 3'b011;
    errors = 0;

  // Test case 1: Simple positive numbers
    rs1 = 32'd10;   rs2 = 32'd5; 
    expected = 32'd0; 
    #10;
    check_result;
    
    // Test case 2: Large positive numbers
    rs1 = 32'h0000FFFF;  // 65535
    rs2 = 32'h0000FFFF;  // 65535
    expected = 32'h0000_0000;  // (65535 * 65535) >> 32
    #10;
    check_result;
    
    // Test case 3: Maximum positive value
    rs1 = 32'h7FFF_FFFF;  // 2147483647
    rs2 = 32'h7FFF_FFFF;  // 2147483647
    expected = 32'h3FFF_FFFF;  // (2147483647 * 2147483647) >> 32
    #10;
    check_result;
    
    // Test case 4: One negative, one positive
    rs1 = 32'hFFFF_FFF1;  // -15
    rs2 = 32'h0000_0004;  // 4
    expected = 32'h0000_0003;  // (4294967281 * 4) >> 32
    #10;
    check_result;
    
    // Test case 5: Both negative numbers
    rs1 = 32'hFFFF_FFF4;  // -12
    rs2 = 32'hFFFF_FFFB;  // -5
    expected = 32'hFFFF_FFFF;  // (4294967284 * 4294967291) >> 32
    #10;
    check_result;
    
    // Test case 6: Maximum unsigned value
    rs1 = 32'hFFFF_FFFF;  // 4294967295
    rs2 = 32'hFFFF_FFFF;  // 4294967295
    expected = 32'hFFFF_FFFE;  // (4294967295 * 4294967295) >> 32
    #10;
    check_result;

    // Test case 7: One just below max positive, one small positive
    rs1 = 32'h7FFF_FFFE;  // 2147483646
    rs2 = 32'h0000_0002;  // 2
    expected = 32'h0000_0000;  // (2147483646 * 2) >> 32
    #10;
    check_result;

    // Test case 8: Minimum signed value times -1
    rs1 = 32'h8000_0000;  // -2147483648
    rs2 = 32'hFFFF_FFFF;  // -1
    expected = 32'h7FFF_FFFF;  // (2147483648 * 4294967295) >> 32
    #10;
    check_result;

// Test case 9: Alternating bit pattern multiplication
    rs1 = 32'h5555_5555;  // 0101... pattern
    rs2 = 32'hAAAA_AAAA;  // 1010... pattern
    expected = 32'h2AAA_AAAA;  // Unsigned result
    #10;
    check_result;

    // Test case 10: Power of 2 boundary
    rs1 = 32'h0001_0000;  // 65536
    rs2 = 32'h0001_0000;  // 65536
    expected = 32'h0000_0001;  // Same for unsigned
    #10;
    check_result;

    // Test case 11: Single bit in highest position
    rs1 = 32'h4000_0000;  // Second highest bit set
    rs2 = 32'h4000_0000;  // Second highest bit set
    expected = 32'h1000_0000;  // Same for unsigned
    #10;
    check_result;

    // Test case 12: Mixed bits with 0xF pattern
    rs1 = 32'hF0F0_F0F0;
    rs2 = 32'h0F0F_0F0F;
    expected = 32'h0E1E_1E1E;  // Unsigned result
    #10;
    check_result;

    // Test case 13: Almost maximum times small negative
    rs1 = 32'h7FFF_FFFE;  // 2147483646
    rs2 = 32'hFFFF_FFFD;  // -3
    expected = 32'h7FFF_FFFD;  // Unsigned result
    #10;
    check_result;

    // Test case 14: Sparse bit pattern
    rs1 = 32'h8421_8421;  // Sparse 1s
    rs2 = 32'h1248_1248;  // Different sparse 1s
    expected = 32'h0948_9489;  // Unsigned result
    #10;
    check_result;

    // Test case 15: Walking ones pattern
    rs1 = 32'h0123_4567;
    rs2 = 32'h89AB_CDEF;
    expected = 32'h000B_5B5B;  // Unsigned result
    #10;
    check_result;

    // Test case 16: Edge around minimum negative
    rs1 = 32'h8000_0001;  // MIN_INT + 1
    rs2 = 32'h8000_0001;  // MIN_INT + 1
    expected = 32'h4000_0000;  // Unsigned result
    #10;
    check_result;

/*#################################################################################*/
    test_phase = "DIV";
    md_type = 3'b100;
    errors = 0;

     // Test case 1: Simple positive numbers
    rs1 = 32'd10;    rs2 = 32'd5;    expected = 32'd2;
    #10;
    check_result;
    
    // Test case 2: Large positive numbers
    rs1 = 32'd65535;    rs2 = 32'd256;    expected = 32'd256;
    #10;
    check_result;
    
    // Test case 3: Maximum positive value
    rs1 = 32'h7FFFFFFF;    rs2 = 32'd2;    expected = 32'd1073741823;
    #10;
    check_result;
    
    // Test case 4: Negative numbers
    rs1 = -32'd15;    rs2 = 32'd4;    expected = -32'd3;
    #10;
    check_result;
    
    // Test case 5: Both negative numbers
    rs1 = -32'd12;    rs2 = -32'd5;    expected = 32'd2;
    #10;
    check_result;
    
    // Test case 6: Maximum unsigned value
    rs1 = 32'hFFFFFFFF;    rs2 = 32'd2;    expected = -32'd1;
    #10;
    check_result;

    // Test case 7: Powers of 2
    rs1 = 32'h00010000;   rs2 = 32'h00000100;    expected = 32'd256;
    #10;
    check_result;

    // Test case 8: Minimum signed value
    rs1 = 32'h80000000;  rs2 = 32'd2; expected = -32'd1073741824;
    #10;
    check_result;

    // Test case 9: Large negative times large positive
    rs1 = 32'hFF000000;    rs2 = 32'h00FFFFFF;    expected = -32'd256;
    #10;
    check_result;

    // Test case 10: Almost maximum values
    rs1 = 32'h7FFFFFFE;   rs2 = 32'h7FFFFFFD;  expected = 32'd1;
    #10;
    check_result;

    // Test case 11: Alternating bit pattern
    rs1 = 32'h55555555; rs2 = 32'hAAAAAAAA;  expected = 32'd0;
    #10;
    check_result;

    // Test case 12: One small, one large
    rs1 = 32'd3;      rs2 = 32'h7FFFFFFF;    expected = 32'd0;
    #10;
    check_result;

/*#################################################################################*/
    test_phase = "DIV_U";
    md_type = 3'b100;
    errors = 0;

     // Test case 1: Simple positive numbers
    rs1 = 32'd10;     rs2 = 32'd5;      expected = 32'd2;
    #10;
    check_result;
    // Test case 2: Large positive numbers
    rs1 = 32'd65535;  rs2 = 32'd256;    expected = 32'd256;
    #10;
    check_result;

    // Test case 3: Maximum positive value
    rs1 = 32'h7FFFFFFF; rs2 = 32'd2;   expected = 32'd1073741823;
    #10;
    check_result;

    // Test case 4: Negative numbers
    rs1 = -32'd15;      rs2 = 32'd4;   expected = 32'd1073741821;
    #10;
    check_result;
    
    // Test case 5: Both negative numbers
    rs1 = -32'd12;    rs2 = -32'd5;    expected = 32'd0;
    #10;
    check_result;
    
    // Test case 6: Maximum unsigned value
    rs1 = 32'hFFFFFFFF;  rs2 = 32'd2;    expected = 32'd2147483647;
    #10;
    check_result;
    // Test case 7: Powers of 2
    rs1 = 32'h00010000;  rs2 = 32'h00000100; expected = 32'd256;
    #10;
    check_result;

    // Test case 8: Minimum signed value
    rs1 = 32'h80000000;  rs2 = 32'd2; expected = 32'd1073741824;
    #10;
    check_result;

    // Test case 9: Large negative times large positive
    rs1 = 32'hFF000000; rs2 = 32'h00FFFFFF;  expected = 32'd255;
    #10;
    check_result;

    // Test case 10: Almost maximum values
    rs1 = 32'h7FFFFFFE; rs2 = 32'h7FFFFFFD;  expected = 32'd1;
    #10;
    check_result;

    // Test case 11: Alternating bit pattern
    rs1 = 32'h55555555; rs2 = 32'hAAAAAAAA;  expected = 32'd0;
    #10;
    check_result;

    // Test case 12: One small, one large
    rs1 = 32'd3;      rs2 = 32'h7FFFFFFF;    expected = 32'd0;
    #10;
    check_result;

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