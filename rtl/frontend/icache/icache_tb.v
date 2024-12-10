`timescale 1ns / 1ps

module icache_tb;

  // Parameters
  parameter SET_CNT = 1024;
  parameter CACHE_LINE = 512;
  parameter ADDR_SZ = 32;

  // Derived parameters
  localparam OFFSET_SZ = $clog2(CACHE_LINE);
  localparam INDEX_SZ = $clog2(SET_CNT);
  localparam TAG_SZ = ADDR_SZ - OFFSET_SZ - INDEX_SZ;

  // Clock and Reset
  reg clk;
  reg rst;

  // Inputs to icache (regs)
  reg [31:0] f1_address_in;
  reg [2:0] f1_op_in;

  reg f2_op_in;
  reg [31:0] f2_v_addr_in;
  reg [31:0] f2_p_addr_in;
  reg [3:0] f2_exception_in;
  reg [CACHE_LINE * 4 - 1: 0] f2_data_in;
  reg [TAG_SZ * 4 - 1:0] f2_tag_in;
  reg [4*4-1:0] f2_meta_in;
  reg [31:0] f2_lru_in;
  reg [3:0] f2_hit_in;
  reg f2_is_l2_req;

  reg [2:0] l2_icache_op;
  reg [31:0] l2_icache_addr;
  reg [CACHE_LINE-1:0] l2_icache_data;
  reg [3:0] l2_icache_state;

  // Outputs from icache (wires)
  wire [31:0] f1_v_addr_out;
  wire [31:0] f1_p_addr_out;
  wire [3:0] f1_exception_out;
  wire [CACHE_LINE * 4 - 1: 0] f1_data_out;
  wire [TAG_SZ * 4 -1 : 0 ] f1_tag_out;
  wire [4*4-1:0] f1_meta_out;
  wire [31:0] f1_lru_out;
  wire [3:0] f1_hit_out;
  wire f1_is_l2_req;

  wire [1:0] f2_hit_out;
  wire [CACHE_LINE-1:0] f2_cache_line_out;

  wire [2:0] icache_l2_op;
  wire [31:0] icache_l2_addr;
  wire [CACHE_LINE-1:0] icache_l2_data_out;
  wire [3:0] icache_l2_state;

  // Instantiate the icache module
  icache #(
    .SET_CNT(SET_CNT),
    .CACHE_LINE(CACHE_LINE),
    .ADDR_SZ(ADDR_SZ)
  ) uut (
    // Global
    .clk(clk),
    .rst(rst),

    // Inputs from F1
    .f1_address_in(f1_address_in),
    .f1_op_in(f1_op_in),

    // Outputs to F1
    .f1_v_addr_out(f1_v_addr_out),
    .f1_p_addr_out(f1_p_addr_out),
    .f1_exception_out(f1_exception_out),
    .f1_data_out(f1_data_out),
    .f1_tag_out(f1_tag_out),
    .f1_meta_out(f1_meta_out),
    .f1_lru_out(f1_lru_out),
    .f1_hit_out(f1_hit_out),
    .f1_is_l2_req(f1_is_l2_req),

    // Inputs from F2
    .f2_op_in(f2_op_in),
    .f2_v_addr_in(f2_v_addr_in),
    .f2_p_addr_in(f2_p_addr_in),
    .f2_exception_in(f2_exception_in),
    .f2_data_in(f2_data_in),
    .f2_tag_in(f2_tag_in),
    .f2_meta_in(f2_meta_in),
    .f2_lru_in(f2_lru_in),
    .f2_hit_in(f2_hit_in),
    .f2_is_l2_req(f2_is_l2_req),

    // Outputs from F2
    .f2_hit_out(f2_hit_out),
    .f2_cache_line_out(f2_cache_line_out),

    // Inputs from L2
    .l2_icache_op(l2_icache_op),
    .l2_icache_addr(l2_icache_addr),
    .l2_icache_data(l2_icache_data),
    .l2_icache_state(l2_icache_state),

    // Outputs to L2
    .icache_l2_op(icache_l2_op),
    .icache_l2_addr(icache_l2_addr),
    .icache_l2_data_out(icache_l2_data_out),
    .icache_l2_state(icache_l2_state)
  );

  // Clock generation
  initial begin
    clk = 0;
    forever #5 clk = ~clk; // 100MHz clock
  end

  // Reset generation
  initial begin
    rst = 1;
    #20 rst = 0; // Release reset after 20ns
  end

  // Test sequence
  initial begin
    // Wait for reset to deassert
    @(negedge rst);

    // Initialize inputs
    f1_address_in = 32'h0;
    f1_op_in = 3'b0;

    f2_op_in = 1'b0;
    f2_v_addr_in = 32'h0;
    f2_p_addr_in = 32'h0;
    f2_exception_in = 4'b0;
    f2_data_in = { (CACHE_LINE*4) {1'b0} };
    f2_tag_in = { (TAG_SZ*4) {1'b0} };
    f2_meta_in = { (4*4) {1'b0} };
    f2_lru_in = 32'h0;
    f2_hit_in = 4'b0;
    f2_is_l2_req = 1'b0;

    l2_icache_op = 3'b0;
    l2_icache_addr = 32'h0;
    l2_icache_data = { CACHE_LINE {1'b0} };
    l2_icache_state = 4'b0;

    // Wait for some clock cycles
    #20;

    // Test 1: Read operation from F1
    $display("Starting Test 1: Read operation from F1");
    f1_address_in = 32'h00001000; // Test address
    f1_op_in = 3'b001; // Assume 3'b001 represents a read operation
    @(posedge clk);
    f1_op_in = 3'b000; // De-assert operation after one cycle

    // Wait for cache response
    repeat (10) @(posedge clk);

    // Check outputs
    $display("Time %0t: f1_hit_out=%b, f1_data_out=%h", $time, f1_hit_out, f1_data_out);

    // Test 2: Write operation from F2
    $display("Starting Test 2: Write operation from F2");
    f2_op_in = 1'b1; // Indicate a write operation
    f2_v_addr_in = 32'h00002000;
    f2_p_addr_in = 32'h00002000;
    f2_data_in = { (CACHE_LINE*4) {1'b1} }; // Sample data
    f2_tag_in = { (TAG_SZ*4) {1'b1} };
    f2_meta_in = { (4*4) {1'b1} };
    f2_hit_in = 4'b0; // Indicate miss
    f2_is_l2_req = 1'b0;
    @(posedge clk);
    f2_op_in = 1'b0; // De-assert operation after one cycle

    // Wait for cache response
    repeat (10) @(posedge clk);

    // Check outputs
    $display("Time %0t: f2_hit_out=%b, f2_cache_line_out=%h", $time, f2_hit_out, f2_cache_line_out);

    // Test 3: Read after write to check if data is updated
    $display("Starting Test 3: Read after write to verify data update");
    f1_address_in = 32'h00002000; // Same address as write
    f1_op_in = 3'b001; // Read operation
    @(posedge clk);
    f1_op_in = 3'b000; // De-assert operation after one cycle

    // Wait for cache response
    repeat (10) @(posedge clk);

    // Check outputs
    $display("Time %0t: f1_hit_out=%b, f1_data_out=%h", $time, f1_hit_out, f1_data_out);

    // TODO: Add more tests

    // Finish simulation after some time
    #100 $finish;
  end

  // Monitor outputs
  initial begin
    $monitor("Time %0t | f1_hit_out=%b | f1_data_out=%h | f2_hit_out=%b | f2_cache_line_out=%h", 
             $time, f1_hit_out, f1_data_out, f2_hit_out, f2_cache_line_out);
  end

endmodule
