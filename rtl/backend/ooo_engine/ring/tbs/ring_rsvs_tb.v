`timescale 1ns/1ps

module ring_rsvs_tb;
  // Parameters
  parameter XLEN = 32;
  parameter PHYS_REG_SIZE = 256;
  parameter ROB_SIZE = 265;
  
  // Test bench signals
    reg clk;
    reg rst;
    reg valid_in;
    reg[2:0]                               functional_unit_num;
    reg[$clog2(ROB_SIZE)-1:0]              rob_entry;
    reg[$clog2(PHYS_REG_SIZE)-1:0]         uop_rs1_reg;
    reg                                    uop_rs1_received;
    reg[XLEN-1:0]                          uop_rs1_value;
    reg[XLEN-1:0]                          uop_pc_in;
    reg[4:0]                               uop_opcode_in;
    reg[2:0]                               uop_opcode_type_in;
    reg                                    uop_additional_info_in;
    reg[XLEN-1:0]                          uop_rs2_value;
    reg                                    uop_rs2_received;
    reg[$clog2(PHYS_REG_SIZE)-1:0]         uop_rs2_reg;

    wire[$clog2(PHYS_REG_SIZE)-1:0]    logical_rs1_reg;
    wire[$clog2(ROB_SIZE)-1:0]         logical_rob_entry;
    wire                               logical_rs1_received;
    wire[XLEN-1:0]                     logical_rs1_value;
    wire[XLEN-1:0]                     logical_pc;
    wire[4:0]                          logical_opcode;
    wire[2:0]                          logical_opcode_type;
    wire                               logical_additional_info;
    wire[XLEN-1:0]                     logical_rs2_value;
    wire                               logical_rs2_received;
    wire[$clog2(PHYS_REG_SIZE)-1:0]    logical_rs2_reg;

    wire[$clog2(PHYS_REG_SIZE)-1:0]    arithmetic_rs1_reg;
    wire[$clog2(ROB_SIZE)-1:0]         arithmetic_rob_entry;
    wire                               arithmetic_rs1_received;
    wire[XLEN-1:0]                     arithmetic_rs1_value;
    wire[XLEN-1:0]                     arithmetic_pc;
    wire[4:0]                          arithmetic_opcode;
    wire[2:0]                          arithmetic_opcode_type;
    wire                               arithmetic_additional_info;
    wire[XLEN-1:0]                     arithmetic_rs2_value;
    wire                               arithmetic_rs2_received;
    wire[$clog2(PHYS_REG_SIZE)-1:0]    arithmetic_rs2_reg;

    wire[$clog2(PHYS_REG_SIZE)-1:0]    branch_rs1_reg;
    wire[$clog2(ROB_SIZE)-1:0]         branch_rob_entry;
    wire                               branch_rs1_received;
    wire[XLEN-1:0]                     branch_rs1_value;
    wire[XLEN-1:0]                     branch_pc;
    wire[4:0]                          branch_opcode;
    wire[2:0]                          branch_opcode_type;
    wire                               branch_additional_info;
    wire[XLEN-1:0]                     branch_rs2_value;
    wire                               branch_rs2_received;
    wire[$clog2(PHYS_REG_SIZE)-1:0]    branch_rs2_reg;

    wire[$clog2(PHYS_REG_SIZE)-1:0]    mul_div_rs1_reg;
    wire[$clog2(ROB_SIZE)-1:0]         mul_div_rob_entry;
    wire                               mul_div_rs1_received;
    wire[XLEN-1:0]                     mul_div_rs1_value;
    wire[XLEN-1:0]                     mul_div_pc;
    wire[4:0]                          mul_div_opcode;
    wire[2:0]                          mul_div_opcode_type;
    wire                               mul_div_additional_info;
    wire[XLEN-1:0]                     mul_div_rs2_value;
    wire                               mul_div_rs2_received;
    wire[$clog2(PHYS_REG_SIZE)-1:0]    mul_div_rs2_reg;

    wire[$clog2(PHYS_REG_SIZE)-1:0]    ld_st_rs1_reg;
    wire[$clog2(ROB_SIZE)-1:0]         ld_st_rob_entry;
    wire                               ld_st_rs1_received;
    wire[XLEN-1:0]                     ld_st_rs1_value;
    wire[XLEN-1:0]                     ld_st_pc;
    wire[4:0]                          ld_st_opcode;
    wire[2:0]                          ld_st_opcode_type;
    wire                               ld_st_additional_info;
    wire[XLEN-1:0]                     ld_st_rs2_value;
    wire                               ld_st_rs2_received;
    wire[$clog2(PHYS_REG_SIZE)-1:0]    ld_st_rs2_reg;
  
  // Instantiate the TLB
  ring_rsvs #(
    .XLEN(XLEN),
    .PHYS_REG_SIZE(PHYS_REG_SIZE),
    .ROB_SIZE(ROB_SIZE)
  ) ring_rsv(
    .clk(clk),
    .rst(rst),
    .valid_in(valid_in),
    .functional_unit_num(functional_unit_num),
    .rob_entry(rob_entry),
    .uop_rs1_reg(uop_rs1_reg),
    .uop_rs1_received(uop_rs1_received),
    .uop_rs1_value(uop_rs1_value),
    .uop_pc_in(uop_pc_in),
    .uop_opcode_in(uop_opcode_in),
    .uop_opcode_type_in(uop_opcode_type_in),
    .uop_additional_info_in(uop_additional_info_in),
    .uop_rs2_value(uop_rs2_value),
    .uop_rs2_received(uop_rs2_received),
    .uop_rs2_reg(uop_rs2_reg),

    .logical_rs1_reg(logical_rs1_reg),
    .logical_rob_entry(logical_rob_entry),
    .logical_rs1_received(logical_rs1_received),
    .logical_rs1_value(logical_rs1_value),
    .logical_pc(logical_pc),
    .logical_opcode(logical_opcode),
    .logical_opcode_type(logical_opcode_type),
    .logical_additional_info(logical_additional_info),
    .logical_rs2_value(logical_rs2_value),
    .logical_rs2_received(logical_rs2_received),
    .logical_rs2_reg(logical_rs2_reg),

    .arithmetic_rs1_reg(arithmetic_rs1_reg),
    .arithmetic_rob_entry(arithmetic_rob_entry),
    .arithmetic_rs1_received(arithmetic_rs1_received),
    .arithmetic_rs1_value(arithmetic_rs1_value),
    .arithmetic_pc(arithmetic_pc),
    .arithmetic_opcode(arithmetic_opcode),
    .arithmetic_opcode_type(arithmetic_opcode_type),
    .arithmetic_additional_info(arithmetic_additional_info),
    .arithmetic_rs2_value(arithmetic_rs2_value),
    .arithmetic_rs2_received(arithmetic_rs2_received),
    .arithmetic_rs2_reg(arithmetic_rs2_reg),

    .branch_rs1_reg(branch_rs1_reg),
    .branch_rob_entry(branch_rob_entry),
    .branch_rs1_received(branch_rs1_received),
    .branch_rs1_value(branch_rs1_value),
    .branch_pc(branch_pc),
    .branch_opcode(branch_opcode),
    .branch_opcode_type(branch_opcode_type),
    .branch_additional_info(branch_additional_info),
    .branch_rs2_value(branch_rs2_value),
    .branch_rs2_received(branch_rs2_received),
    .branch_rs2_reg(branch_rs2_reg),

    .mul_div_rs1_reg(mul_div_rs1_reg),
    .mul_div_rob_entry(mul_div_rob_entry),
    .mul_div_rs1_received(mul_div_rs1_received),
    .mul_div_rs1_value(mul_div_rs1_value),
    .mul_div_pc(mul_div_pc),
    .mul_div_opcode(mul_div_opcode),
    .mul_div_opcode_type(mul_div_opcode_type),
    .mul_div_additional_info(mul_div_additional_info),
    .mul_div_rs2_value(mul_div_rs2_value),
    .mul_div_rs2_received(mul_div_rs2_received),
    .mul_div_rs2_reg(mul_div_rs2_reg),
                                                                                                 
    .ld_st_rs1_reg(ld_st_rs1_reg),
    .ld_st_rob_entry(ld_st_rob_entry),
    .ld_st_rs1_received(ld_st_rs1_received),
    .ld_st_rs1_value(ld_st_rs1_value),
    .ld_st_pc(ld_st_pc),
    .ld_st_opcode(ld_st_opcode),
    .ld_st_opcode_type(ld_st_opcode_type),
    .ld_st_additional_info(ld_st_additional_info),
    .ld_st_rs2_value(ld_st_rs2_value),
    .ld_st_rs2_received(ld_st_rs2_received),
    .ld_st_rs2_reg(ld_st_rs2_reg)
  );
  
  // Clock generation
  always begin
    #5 clk = ~clk;
  end
  
  // Initial block for waveform generation
  initial begin
    // Create VCD file
    $dumpfile("ring_rsvs.vcd");
    // Dump all variables including those in sub-modules
    $dumpvars(2, ring_rsvs_tb);
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
    functional_unit_num = 0;
    rob_entry = 0;
    uop_rs1_reg = 0;
    uop_rs1_received = 0;
    uop_rs1_value = 0;
    uop_pc_in = 0;
    uop_opcode_in = 0;
    uop_opcode_type_in = 0;
    uop_additional_info_in = 0;
    uop_rs2_value = 0;
    uop_rs2_received = 0;
    uop_rs2_reg = 0;
    
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
    test_phase = "ld_st";
    valid_in = 1;
    functional_unit_num = 5;
    rob_entry = 1;
    uop_rs1_reg = 1;
    uop_rs1_received = 1;
    uop_rs1_value = 1;
    uop_pc_in = 1;
    uop_opcode_in = 1;
    uop_opcode_type_in = 1;
    uop_additional_info_in = 1;
    uop_rs2_value = 1;
    uop_rs2_received = 1;
    uop_rs2_reg = 1;
    #10
    valid_in = 0;
    #60


    $finish;
  end


endmodule
