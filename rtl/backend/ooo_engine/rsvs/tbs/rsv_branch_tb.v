`timescale 1ns/1ps

module rsv_tb;
  // Parameters
  parameter XLEN = 32;
  parameter SIZE = 16;
  parameter PHYS_REG_SIZE = 256;
  parameter ROB_SIZE = 265;
  
  // Test bench signals
  reg clk;
  reg rst;
  reg valid_in;
  reg[$clog2(ROB_SIZE)-1:0]         rob_entry_in;
  reg[$clog2(PHYS_REG_SIZE)-1:0]    rs1_reg;
  reg                               rs1_received;
  reg[XLEN-1:0]                     rs1_value;
  reg[XLEN-1:0]                     pc_in;
  reg[4:0]                          opcode_in;
  reg[2:0]                          opcode_type_in;
  reg                               additional_info_in;
  reg[XLEN-1:0]                     rs2_value;
  reg                               rs2_received;
  reg[$clog2(PHYS_REG_SIZE)-1:0]    rs2_reg;

  /*   Update Vars, from ring from ROB   */
  reg                               update_valid;
  reg[$clog2(PHYS_REG_SIZE)-1:0]    update_reg;
  reg[XLEN-1:0]                     update_val;
  
  wire[$clog2(ROB_SIZE)-1:0]    rob_entry;
  wire[XLEN-1:0]                rs1;
  wire[XLEN-1:0]                rs2;
  wire[XLEN-1:0]                pc;
  wire[4:0]                     opcode;
  wire[2:0]                     opcode_type;
  wire                          additional_info;
  wire                          valid_out;
  
  // Instantiate the TLB
  rsv #(
    .XLEN(XLEN)
  ) rsv(
    .clk(clk),
    .rst(rst),
    .valid_in(valid_in),
    .rob_entry_in(rob_entry_in),
    .rs1_reg(rs1_reg),
    .rs1_received(rs1_received),
    .rs1_value(rs1_value),
    .pc_in(pc_in),
    .opcode_in(opcode_in),
    .opcode_type_in(opcode_type_in),
    .additional_info_in(additional_info_in),
    .rs2_value(rs2_value),
    .rs2_received(rs2_received),
    .rs2_reg(rs2_reg),
    .update_valid(update_valid),
    .update_reg(update_reg),
    .update_val(update_val), 
    .rob_entry(rob_entry),
    .rs1(rs1),
    .rs2(rs2),
    .pc(pc),
    .opcode(opcode),
    .opcode_type(opcode_type),
    .additional_info(additional_info),
    .valid_out(valid_out)
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
    $dumpvars(2, rsv_tb);
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
    clk = 0;
    rst = 0;
    valid_in = 0;
    rob_entry_in = 0;
    rs1_reg = 0;
    rs1_received = 0;
    rs1_value = 0;
    pc_in = 0;
    opcode_in = 0;
    opcode_type_in = 0;
    additional_info_in = 0;
    rs2_value = 0;
    rs2_received = 0;
    rs2_reg = 0;
    update_reg = 0;
    update_val = 0;
    update_valid = 0;
    
    // Apply reset
    #10;
    test_phase = "Reset";
    rst = 1;
    #10 rst = 0;
    
    // Wait for reset to complete
    #20;
    test_phase = "Post-Reset";
    // if(valid_out != valid_in)
    //   $display("YO THIS SHIT BROKEN");

    //Test basic insertion and replication
    test_phase = "Insert";

    valid_in = 1;
    rob_entry_in = 20;
    rs1_reg = 1;
    rs1_received = 0;
    rs1_value = 0;
    pc_in = 32'h30000000;
    opcode_in = 5'b10010;
    opcode_type_in = 0;
    additional_info_in = 0;
    rs2_value = 25;
    rs2_received = 1;
    rs2_reg = 2;

    #10
    test_phase = "Valid Update";
    valid_in = 0;
    update_valid = 1;
    update_reg = 1;
    update_val = 26;
    #10
    update_valid = 0;
    #10

    test_phase = "Insert_2";

    valid_in = 1;
    rob_entry_in = 20;
    rs1_reg = 1;
    rs1_received = 0;
    rs1_value = 0;
    pc_in = 32'h30000000;
    opcode_in = 5'b10010;
    opcode_type_in = 0;
    additional_info_in = 0;
    rs2_value = 25;
    rs2_received = 1;
    rs2_reg = 2;
    #10

    valid_in = 1;
    rob_entry_in = 20;
    rs1_reg = 1;
    rs1_received = 0;
    rs1_value = 0;
    pc_in = 32'h30000000;
    opcode_in = 5'b10010;
    opcode_type_in = 0;
    additional_info_in = 0;
    rs2_value = 27;
    rs2_received = 1;
    rs2_reg = 2;
    #10

    test_phase = "Valid Update_2";
    valid_in = 0;
    update_valid = 1;
    update_reg = 1;
    update_val = 26;
    #10
    update_valid = 0;
    #10
    #10
    #10
    
    $finish;
  end


endmodule
