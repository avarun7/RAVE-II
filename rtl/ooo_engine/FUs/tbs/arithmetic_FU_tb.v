`timescale 1ns/1ps

module tlb_tb;
  // Parameters
  parameter XLEN = 32;
  parameter CLC_WIDTH = 26;
  parameter TLB_ENTRIES = 16;
  parameter TAG_WIDTH = 20;
  parameter PAGE_OFFSET = 12;
  
  // Test bench signals
  reg clk;
  reg rst;
  reg [XLEN-1:0] pc;
  reg [CLC_WIDTH-1:0] clc_in;
  reg [CLC_WIDTH-1:0] clc_nl_in;
  reg RW_in;
  reg valid_in;
  
  wire pcd;
  wire hit;
  wire exception;
  wire [CLC_WIDTH-1:0] clc_paddr;
  wire clc_paddr_valid;
  wire [CLC_WIDTH-1:0] clc_nl_paddr;
  wire clc_nl_paddr_valid;

  // Signal groups for wave dumping
  wire [3:0] status_signals;
  assign status_signals = {pcd, hit, exception, valid_in};
  
  // Instantiate the TLB
  tlb_TOP #(
    .XLEN(XLEN),
    .CLC_WIDTH(CLC_WIDTH)
  ) dut (
    .clk(clk),
    .rst(rst),
    .pc(pc),
    .clc_in(clc_in),
    .clc_nl_in(clc_nl_in),
    .RW_in(RW_in),
    .valid_in(valid_in),
    .pcd(pcd),
    .hit(hit),
    .exception(exception),
    .clc_paddr(clc_paddr),
    .clc_paddr_valid(clc_paddr_valid),
    .clc_nl_paddr(clc_nl_paddr),
    .clc_nl_paddr_valid(clc_nl_paddr_valid)
  );
  
  // Clock generation
  always begin
    #5 clk = ~clk;
  end
  
  // Test vector storage
  reg [31:0] test_vectors [0:9];
  integer errors = 0;
  integer i;
  
  // Initial block for waveform generation
  initial begin
    // Create VCD file
    $dumpfile("tlb_test.vcd");
    // Dump all variables including those in sub-modules
    $dumpvars(0, tlb_tb);
    
    // Optional: Create FST format file (if simulator supports it)
    // $fsdbDumpfile("tlb_test.fsdb");
    // $fsdbDumpvars(0, tlb_tb);
    
    // Add specific signals to wave window with hierarchy
    $display("\nSimulation Wave Information:");
    $display("----------------------------------------");
    $display("Wave file: tlb_test.vcd");
    $display("Simulation resolution: 1ns/1ps");
    $display("----------------------------------------\n");
  end

  // Add string labels for test phases (for waveform viewer)
  reg [127:0] test_phase;
  initial begin
    test_phase = "Initialize";
  end
  
  // Test scenarios
  initial begin
    // Initialize signals
    clk = 0;
    rst = 0;
    pc = 0;
    clc_in = 0;
    clc_nl_in = 0;
    RW_in = 0;
    valid_in = 0;
    
    // Apply reset
    #10;
    test_phase = "Reset";
    rst = 1;
    #10 rst = 0;
    
    // Wait for reset to complete
    #20;
    test_phase = "Post-Reset";
    
    // Test Case 1: Basic TLB miss
    test_phase = "TLB Miss Test";
    $display("Test Case 1: TLB Miss Test at time %0t", $time);
    valid_in = 1;
    clc_in = 26'h1234567;
    #10;
    if (!exception || hit) begin
      $display("Error: TLB miss not properly detected");
      errors = errors + 1;
    end
    
    // Test Case 2: Invalid request
    test_phase = "Invalid Request";
    $display("Test Case 2: Invalid Request Test at time %0t", $time);
    valid_in = 0;
    #10;
    if (exception) begin
      $display("Error: Exception raised for invalid request");
      errors = errors + 1;
    end
    
    // Test Case 3: Read permission test
    test_phase = "Read Permission";
    $display("Test Case 3: Read Permission Test at time %0t", $time);
    // Setup TLB entry
    dut.tlb_valid[0] = 1'b1;
    dut.tlb_tags[0] = clc_in[CLC_WIDTH-1:PAGE_OFFSET];
    dut.tlb_physical_pages[0] = 32'hABCD0000;
    dut.permission_bits[0] = 4'b0001; // Read only
    valid_in = 1;
    RW_in = 0; // Read access
    #10;
    if (exception || !hit) begin
      $display("Error: Valid read access denied");
      errors = errors + 1;
    end
    
    // Test Case 4: Write permission violation
    test_phase = "Write Permission";
    $display("Test Case 4: Write Permission Test at time %0t", $time);
    RW_in = 1; // Write access
    #10;
    if (!exception) begin
      $display("Error: Write to read-only page not caught");
      errors = errors + 1;
    end
    
    // Test Case 5: Dual port operation
    test_phase = "Dual Port Test";
    $display("Test Case 5: Dual Port Operation Test at time %0t", $time);
    clc_in = 26'h1234567;
    clc_nl_in = 26'h7654321;
    dut.tlb_valid[1] = 1'b1;
    dut.tlb_tags[1] = clc_nl_in[CLC_WIDTH-1:PAGE_OFFSET];
    dut.tlb_physical_pages[1] = 32'hDCBA0000;
    #10;
    if (!clc_nl_paddr_valid) begin
      $display("Error: Second port translation failed");
      errors = errors + 1;
    end

    // Wait for waveforms to settle
    #20;
    test_phase = "Complete";
    
    // Report results
    if (errors == 0)
      $display("\nSimulation completed successfully at time %0t!", $time);
    else
      $display("\nSimulation completed with %d errors at time %0t", errors, $time);
    
    // Add some delay before ending simulation for waveform capture
    #100;
    $display("\nWaveform file tlb_test.vcd has been generated.");
    $finish;
  end
  
  // Monitor important signal changes for waveform verification
  always @(posedge clk) begin
    $display("Time=%0t Phase=%s hit=%b exception=%b pcd=%b valid_in=%b RW_in=%b",
             $time, test_phase, hit, exception, pcd, valid_in, RW_in);
  end
  
  // Monitor TLB internal state changes
  // This will help in waveform analysis
  always @(posedge clk) begin
    if (hit)
      $display("Time=%0t TLB Hit - Physical Address: %h", $time, clc_paddr);
  end
