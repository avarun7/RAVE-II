`timescale 1ns / 1ps

module icache_tb;

  // Testbench signals
  reg clk;
  reg reset;
  reg [31:0] addr;
  wire [31:0] data_out;
  wire hit;
  wire mem_request;
  wire [31:0] mem_addr;
  reg [31:0] mem_data_in;

  // Instantiate the icache module
  icache uut (
    .clk(clk),
    .reset(reset),
    .addr(addr),
    .data_out(data_out),
    .hit(hit),
    .mem_request(mem_request),
    .mem_addr(mem_addr),
    .mem_data_in(mem_data_in)
  );

  // Clock generation
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // Test sequence
  initial begin
    // Initialize inputs
    reset = 1;
    addr = 0;
    mem_data_in = 32'hDEADBEEF;

    // Apply reset
    #10 reset = 0;
    #10 reset = 1;
    #10 reset = 0;

    // Cache miss case (first access, assuming it's empty initially)
    addr = 32'h00000010;  // Address to test
    #10;
    
    if (mem_request) begin
      $display("Cache miss occurred at time %0t, mem_request generated.", $time);
    end else begin
      $display("Error: Expected a miss but no mem_request at time %0t", $time);
    end

    // Simulate memory response
    mem_data_in = 32'hAABBCCDD;  // Data for memory response
    #10;

    // Access the same address to verify cache hit
    addr = 32'h00000010;
    #10;

    if (hit) begin
      $display("Cache hit confirmed at time %0t for address %0h.", $time, addr);
    end else begin
      $display("Error: Expected a hit but got a miss at time %0t", $time);
    end

    // Access a new address to generate another cache miss
    addr = 32'h00000020;
    #10;

    if (mem_request) begin
      $display("Cache miss occurred for new address %0h at time %0t.", addr, $time);
    end else begin
      $display("Error: Expected a miss but got a hit at time %0t", $time);
    end

    // Further testing can include resetting, different addresses, checking data integrity, etc.
    
    // Finish simulation
    #100;
    $stop;
  end

endmodule
