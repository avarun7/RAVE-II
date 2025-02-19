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
    check_result;
    test_phase = "Reset";
    rst = 1;
    #10 
    check_result;rst = 0;
    
    // Wait for reset to complete
    #20;
    test_phase = "Post-Reset";
    if(valid_out != valid_in)
      $display("YO THIS SHIT BROKEN");

    valid_in = 1;

/*#################################################################################*/

    test_phase = "Mul";
    md_type = 3'b000;
    errors = 0;

    rs1 = 32'd10;   rs2 = 32'd5;    expected = 64'd50;
    #10;
    check_result;
    
    // Test case 2: Large positive numbers
    rs1 = 32'd65535;    rs2 = 32'd256;  expected = 64'd16776960;
    #10;
    check_result;
    
    // Test case 3: Maximum positive value
    rs1 = 32'h7FFFFFFF; rs2 = 32'd2;    expected = 64'd4294967294;
    #10;
    check_result;
    
    // Test case 4: Negative numbers
    rs1 = -32'd15;      rs2 = 32'd4;        expected = -64'd60;
    #10;
    check_result;
    
    // Test case 5: Both negative numbers
    rs1 = -32'd12;      rs2 = -32'd5;       expected = 64'd60;
    #10;
    check_result;
    
    // Test case 6: Maximum unsigned value
    rs1 = 32'hFFFFFFFF; rs2 = 32'd2;        expected = 64'd8589934590;
    #10;
    check_result;

    // Test case 7: Powers of 2
    rs1 = 32'h00010000; rs2 = 32'h00000100; expected = 64'd16777216;
    #10;
    check_result;

    // Test case 8: Minimum signed value
    rs1 = 32'h80000000; rs2 = 32'd2;        expected = 64'h8000000000000000;  // -4294967296
    #10;
    check_result;

    // Test case 9: Large negative times large positive
    rs1 = 32'hFF000000;  rs2 = 32'h00FFFFFF; expected = -64'd16777216000000000;
    #10;
    check_result;

    // Test case 10: Almost maximum values
    rs1 = 32'h7FFFFFFE; rs2 = 32'h7FFFFFFD;  expected = 64'd4611686014132420594;
    #10;
    check_result;

    // Test case 11: Alternating bit pattern
    rs1 = 32'h55555555; rs2 = 32'hAAAAAAAA; expected = -64'd6148914691236517206;
    #10;
    check_result;

    // Test case 12: One small, one large
    rs1 = 32'd3;        rs2 = 32'h7FFFFFFF; expected = 64'd6442450941;
    #10;
    check_result;

/*#################################################################################*/

    test_phase = "MulH";
    md_type = 3'b001;
    errors = 0;
    rs1 = 32'd10;   rs2 = 32'd5;    expected = 64'd50;
    #10;
    check_result;
    
    // Test case 2: Large positive numbers
    rs1 = 32'd65535;    rs2 = 32'd256;  expected = 64'd16776960;
    #10;
    check_result;
    
    // Test case 3: Maximum positive value
    rs1 = 32'h7FFFFFFF; rs2 = 32'd2;    expected = 64'd4294967294;
    #10;
    check_result;
    
    // Test case 4: Negative numbers
    rs1 = -32'd15;      rs2 = 32'd4;        expected = -64'd60;
    #10;
    check_result;
    
    // Test case 5: Both negative numbers
    rs1 = -32'd12;      rs2 = -32'd5;       expected = 64'd60;
    #10;
    check_result;
    
    // Test case 6: Maximum unsigned value
    rs1 = 32'hFFFFFFFF; rs2 = 32'd2;        expected = 64'd8589934590;
    #10;
    check_result;

    // Test case 7: Powers of 2
    rs1 = 32'h00010000; rs2 = 32'h00000100; expected = 64'd16777216;
    #10;
    check_result;

    // Test case 8: Minimum signed value
    rs1 = 32'h80000000; rs2 = 32'd2;        expected = 64'h8000000000000000;  // -4294967296
    #10;
    check_result;

    // Test case 9: Large negative times large positive
    rs1 = 32'hFF000000;  rs2 = 32'h00FFFFFF; expected = -64'd16777216000000000;
    #10;
    check_result;

    // Test case 10: Almost maximum values
    rs1 = 32'h7FFFFFFE; rs2 = 32'h7FFFFFFD;  expected = 64'd4611686014132420594;
    #10;
    check_result;

    // Test case 11: Alternating bit pattern
    rs1 = 32'h55555555; rs2 = 32'hAAAAAAAA; expected = -64'd6148914691236517206;
    #10;
    check_result;

    // Test case 12: One small, one large
    rs1 = 32'd3;        rs2 = 32'h7FFFFFFF; expected = 64'd6442450941;
    #10;
    check_result;

/*#################################################################################*/

    test_phase = "Mul_U";
    md_type = 3'b010;
    errors = 0;

    rs1 = 32'd10;       rs2 = 32'd5;        expected = 64'd50;
    #10;
    check_result;
    
    // Test case 2: Large positive numbers
    rs1 = 32'd65535;    rs2 = 32'd256;      expected = 64'd16776960;
    #10;
    check_result;
    
    // Test case 3: Maximum positive value
    rs1 = 32'h7FFFFFFF; rs2 = 32'd2;    
    expected = 64'd4294967294;
    #10;
    check_result;
    
    // Test case 4: Negative numbers
    rs1 = -32'd15;      rs2 = 32'd4;      
    expected = 64'd17179869124;
    #10;
    check_result;
    
    // Test case 5: Both negative numbers
    rs1 = -32'd12;      rs2 = -32'd5;       
    expected = 64'd17179869124;
    #10;
    check_result;
    
    // Test case 6: Maximum unsigned value
    rs1 = 32'hFFFFFFFF; rs2 = 32'd2;      
    expected = 64'd8589934590;
    #10;
    check_result;

    // Test case 7: Powers of 2
    rs1 = 32'h00010000; rs2 = 32'h00000100;
    expected = 64'd16777216;
    #10;
    check_result;

    // Test case 8: Minimum signed value
    rs1 = 32'h80000000; rs2 = 32'd2;       
    expected = 64'd8589934592;
    #10;
    check_result;

    // Test case 9: Large negative times large positive
    rs1 = 32'hFF000000;  rs2 = 32'h00FFFFFF;
    expected = 64'd1095216660735;
    #10;
    check_result;

    // Test case 10: Almost maximum values
    rs1 = 32'h7FFFFFFE; rs2 = 32'h7FFFFFFD; 
    expected = 64'd4611686014132420594;
    #10;
    check_result;

    // Test case 11: Alternating bit pattern
    rs1 = 32'h55555555; rs2 = 32'hAAAAAAAA; 
    expected = 64'd12297829382473034410;
    #10;
    check_result;

    // Test case 12: One small, one large
    rs1 = 32'd3;        rs2 = 32'h7FFFFFFF; 
    expected = 64'd6442450941;
    #10;
    check_result;

/*#################################################################################*/

    test_phase = "Mul_UH";
    md_type = 3'b011;
    errors = 0;

    rs1 = 32'd10;       rs2 = 32'd5;        expected = 64'd50;
    #10;
    check_result;
    
    // Test case 2: Large positive numbers
    rs1 = 32'd65535;    rs2 = 32'd256;      expected = 64'd16776960;
    #10;
    check_result;
    
    // Test case 3: Maximum positive value
    rs1 = 32'h7FFFFFFF; rs2 = 32'd2;    
    expected = 64'd4294967294;
    #10;
    check_result;
    
    // Test case 4: Negative numbers
    rs1 = -32'd15;      rs2 = 32'd4;      
    expected = 64'd17179869124;
    #10;
    check_result;
    
    // Test case 5: Both negative numbers
    rs1 = -32'd12;      rs2 = -32'd5;       
    expected = 64'd17179869124;
    #10;
    check_result;
    
    // Test case 6: Maximum unsigned value
    rs1 = 32'hFFFFFFFF; rs2 = 32'd2;      
    expected = 64'd8589934590;
    #10;
    check_result;

    // Test case 7: Powers of 2
    rs1 = 32'h00010000; rs2 = 32'h00000100;
    expected = 64'd16777216;
    #10;
    check_result;

    // Test case 8: Minimum signed value
    rs1 = 32'h80000000; rs2 = 32'd2;       
    expected = 64'd8589934592;
    #10;
    check_result;

    // Test case 9: Large negative times large positive
    rs1 = 32'hFF000000;  rs2 = 32'h00FFFFFF;
    expected = 64'd1095216660735;
    #10;
    check_result;

    // Test case 10: Almost maximum values
    rs1 = 32'h7FFFFFFE; rs2 = 32'h7FFFFFFD; 
    expected = 64'd4611686014132420594;
    #10;
    check_result;

    // Test case 11: Alternating bit pattern
    rs1 = 32'h55555555; rs2 = 32'hAAAAAAAA; 
    expected = 64'd12297829382473034410;
    #10;
    check_result;

    // Test case 12: One small, one large
    rs1 = 32'd3;        rs2 = 32'h7FFFFFFF; 
    expected = 64'd6442450941;
    #10;
    check_result;

/*#################################################################################*/

    test_phase = "Div";
    md_type = 3'b100;
    errors = 0;

    rs1 = 32'd10;   rs2 = 32'd5;    
    expected = 32'd2;
    #10;
    check_result;
    
    // Test case 2: Large positive numbers
    rs1 = 32'd65535;    rs2 = 32'd256;  
    expected = 32'd256;
    #10;
    check_result;
    
    // Test case 3: Maximum positive value
    rs1 = 32'h7FFFFFFF; rs2 = 32'd2;   
    expected = 32'd1073741823;
    #10;
    check_result;
    
    // Test case 4: Negative numbers
    rs1 = -32'd15;      rs2 = 32'd4;       
    expected = -32'd3;
    #10;
    check_result;
    
    // Test case 5: Both negative numbers
    rs1 = -32'd12;      rs2 = -32'd5;
    expected = 32'd2;
    #10;
    check_result;
    
    // Test case 6: Maximum unsigned value
    rs1 = 32'hFFFFFFFF; rs2 = 32'd2;
    expected = -32'd1;
    #10;
    check_result;

    // Test case 7: Powers of 2
    rs1 = 32'h00010000; rs2 = 32'h00000100;
    expected = 32'd256;
    #10;
    check_result;

    // Test case 8: Minimum signed value
    rs1 = 32'h80000000; rs2 = 32'd2;
    expected = -32'd1073741824;
    #10;
    check_result;

    // Test case 9: Large negative times large positive
    rs1 = 32'hFF000000;  rs2 = 32'h00FFFFFF; 
    expected = -32'd256;
    #10;
    check_result;

    // Test case 10: Almost maximum values
    rs1 = 32'h7FFFFFFE; rs2 = 32'h7FFFFFFD; 
    expected = 32'd1;
    #10;
    check_result;

    // Test case 11: Alternating bit pattern
    rs1 = 32'h55555555; rs2 = 32'hAAAAAAAA;
    expected = 32'd0;
    #10;
    check_result;

    // Test case 12: One small, one large
    rs1 = 32'd3;        rs2 = 32'h7FFFFFFF;
    expected = 32'd0;
    #10;
    check_result;

/*#################################################################################*/

    test_phase = "Div_U";
    md_type = 3'b101;
    errors = 0;

    rs1 = 32'd10;   rs2 = 32'd5;
    expected = 32'd2;
    #10;
    check_result;
    
    // Test case 2: Large positive numbers
    rs1 = 32'd65535;    rs2 = 32'd256;
    expected = 32'd256;
    #10;
    check_result;
    
    // Test case 3: Maximum positive value
    rs1 = 32'h7FFFFFFF; rs2 = 32'd2;
    expected = 32'd1073741823;
    #10;
    check_result;
    
    // Test case 4: Negative numbers
    rs1 = -32'd15;      rs2 = 32'd4;
    expected = 32'd1073741821;
    #10;
    check_result;
    
    // Test case 5: Both negative numbers
    rs1 = -32'd12;      rs2 = -32'd5;
    expected = 32'd0;
    #10;
    check_result;
    
    // Test case 6: Maximum unsigned value
    rs1 = 32'hFFFFFFFF; rs2 = 32'd2;
    expected = 32'd2147483647;
    #10;
    check_result;

    // Test case 7: Powers of 2
    rs1 = 32'h00010000; rs2 = 32'h00000100; 
    expected = 32'd256; // 256256;
    #10;
    check_result;

    // Test case 8: Minimum signed value
    rs1 = 32'h80000000; rs2 = 32'd2;
    expected = 32'd1073741824;
    #10;
    check_result;

    // Test case 9: Large negative times large positive
    rs1 = 32'hFF000000;  rs2 = 32'h00FFFFFF; 
    expected = 32'd255;
    #10;
    check_result;

    // Test case 10: Almost maximum values
    rs1 = 32'h7FFFFFFE; rs2 = 32'h7FFFFFFD;
    expected = 32'd1;
    #10;
    check_result;

    // Test case 11: Alternating bit pattern
    rs1 = 32'h55555555; rs2 = 32'hAAAAAAAA;
    expected = 32'd0;
    #10;
    check_result;

    // Test case 12: One small, one large
    rs1 = 32'd3;        rs2 = 32'h7FFFFFFF;
    expected = 32'd0;
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