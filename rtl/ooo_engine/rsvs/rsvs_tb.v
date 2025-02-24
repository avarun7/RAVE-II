`timescale 1ns/1ps

module rsv_tb;
  // Parameters
  parameter XLEN = 32;
  
  // Test bench signals
  reg clk;
  reg rst;
  reg valid_in;
  reg [4:0] opcode;
  reg [2:0] opcode_type;
  reg [XLEN-1:0] rs1;
  reg [XLEN-1:0] rs2;
  
  wire            valid_out;
  wire[XLEN - 1:0]  result;
  
  // Instantiate the TLB
  rsv #(
    .XLEN(XLEN)
  ) rsv(
    .clk(clk),
    .rst(rst),
    .valid_in(valid_in),
    .rsv_type(rsv_type),
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
    $dumpfile("rsv.vcd");
    // Dump all variables including those in sub-modules
    $dumpvars(0, rsv_tb);
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
    rsv_type = 0;
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
