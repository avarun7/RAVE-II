`timescale 1ns/1ps

module ras_tb;
  // Parameters
  parameter XLEN = 32;
  parameter DEPTH = 8;
  
  // Test bench signals
  reg clk;
  reg rst;
  reg valid_in;
  reg pop;
  reg push;
  reg [XLEN-1:0] data_in;
  
  wire              valid_out;
  wire[XLEN - 1:0]  result;
  wire              empty;
  wire              full;
  
  // Instantiate the TLB
  ras #(
    .XLEN(XLEN),
    .DEPTH(DEPTH)
  ) ras(
    .clk(clk),
    .rst(rst),
    .valid_in(valid_in),
    .pop(pop),
    .push(push),
    .data_in(data_in),
    .valid_out(valid_out),
    .result(result),
    .empty(empty),
    .full(full)
  );
  
  // Clock generation
  always begin
    #5 clk = ~clk;
  end
  
  // Initial block for waveform generation
  initial begin
    // Create VCD file
    $dumpfile("ras.vcd");
    // Dump all variables including those in sub-modules
    $dumpvars(0, ras_tb);
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
    valid_in = 0;
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

    // Test Case 1: Push operations until full
    test_phase= "Push";
    repeat(8) begin
        @(posedge clk);
        push = 1;
        pop = 0;
        data_in = $random;
        #10;
    end

    // Test Case 2: Try to push when full
    test_phase="Push Full";
    @(posedge clk);
    push = 1;
    pop = 0;
    data_in = 32'hDEADBEEF;
    #10;

    // Test Case 3: Pop operations until empty
    test_phase="Pop";
    push = 0;
    repeat(8) begin
        @(posedge clk);
        pop = 1;
        #10;
    end

    // Test Case 4: Try to pop when empty
    test_phase="Pop Empty";
    @(posedge clk);
    pop = 1;
    #10;

    // Test Case 5: Alternating push and pop
    test_phase="Push/Pop";
    repeat(4) begin
        @(posedge clk);
        push = 1;
        pop = 0;
        data_in = $random;
        #10;
        @(posedge clk);
        push = 0;
        pop = 1;
        #10;
    end

    // Test Case 6: Reset while operations in progress
    @(posedge clk);
    push = 1;
    data_in = 32'hAAAAAAAA;
    #5;
    rst = 1;
    #10;
    rst = 0;

    // End simulation
    #100;

    
    $finish;
  end

endmodule
