`timescale 1ns/1ps

module branch_FU_tb;
  // Parameters
  parameter XLEN = 32;
  
  // Test bench signals
    reg clk, rst, valid_in;
    reg[$clog2(UOP_SIZE)-1:0]         uop;
    reg[$clog2(ROB_SIZE)-1:0]         rob_entry_in;
    reg[$clog2(PHYS_REG_SIZE)-1:0]    dest_reg_in;
    reg[XLEN-1:0]                     rs1;
    reg[XLEN-1:0]                     rs2;
    reg[XLEN-1:0]                     pc;

    // DCache Inputs
    reg[31:0]                addr_dcache_out;
    reg[XLEN-1:0]            data_dcache_out;
    reg                      is_st_dcache_out;
    reg                      is_flush_dcache_out;
    reg[PHYS_REG_SIZE-1:0]   tag_dcache_out;
    reg[ROB_SIZE-1:0]        rob_line_dcache_out;
    reg                      valid_dcache_out;

    // Outputs to D$
    wire[31:0]               addr_dcache_in;
    wire[31:0]               data_dcache_in;
    wire[1:0]                size_dcache_in;
    wire                     is_st_dcache_in;
    wire[PHYS_REG_SIZE-1:0]  ooo_tag_dcache_in;
    wire[ROB_SIZE-1:0]       ooo_rob_dcache_in;
    wire                     sext_dcache_in;
    wire                     valid_dcache_in;

    wire[XLEN-1:0]                  result;
    wire                            valid_out;
    wire[$clog2(ROB_SIZE)-1:0]      rob_entry;
    wire[$clog2(PHYS_REG_SIZE)-1:0] dest_reg;
  
  
  // Instantiate the TLB
  ldst_FU #(
    .XLEN(XLEN)
  ) load_store_fu(
    .clk(clk), 
    .rst(rst), 
    .valid_in(valid_in),
    .uop(uop),
    .rob_entry_in(rob_entry_in),
    .dest_reg_in(dest_reg_in),
    .rs1(rs1),
    .rs2(rs2),
    .pc(pc),

    // DCache Inputs
    .addr_dcache_out(addr_dcache_out),
    .data_dcache_out(data_dcache_out),
    .is_st_dcache_out(is_st_dcache_out),
    .is_flush_dcache_out(is_flush_dcache_out),
    .tag_dcache_out(tag_dcache_out),
    .rob_line_dcache_out(rob_line_dcache_out),
    .valid_dcache_out(valid_dcache_out),

    // Outputs to D$
    .addr_dcache_in(addr_dcache_in),
    .data_dcache_in(data_dcache_in),
    .size_dcache_in(size_dcache_in),
    .is_st_dcache_in(is_st_dcache_in),
    .ooo_tag_dcache_in(ooo_tag_dcache_in), 
    .ooo_rob_dcache_in(ooo_rob_dcache_in),
    .sext_dcache_in(sext_dcache_in),
    .valid_dcache_in(valid_dcache_in),   

    .result(result),
    .valid_out(valid_out),
    .rob_entry(rob_entry),
    .dest_reg(dest_reg)
  );
  
  // Clock generation
  always begin
    #5 clk = ~clk;
  end
  
  // Initial block for waveform generation
  initial begin
    // Create VCD file
    $dumpfile("ldst_FU.vcd");
    // Dump all variables including those in sub-modules
    $dumpvars(0, load_store_fu);
    // Add specific signals to wave window with hierarchy
  end

  // Add string labels for test phases (for waveform viewer)
  reg [127:0] test_phase;

  initial begin
    test_phase = "Initialize";
  end

  integer expected_res;
  integer taken_expected;
  integer expected_link;
  integer link_expected;
  
  // Test scenarios
  initial begin
    // Initialize signals
    rst = 0;
    clk = 0;
    rst = 0;
    valid_in = 0;
    opcode = 0;
    branch_type = 0;
    rs1 = 0;
    rs2 = 0;
    pc = 0;
    link_expected = 0;
    
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
/*#################################################################################*/

    test_phase = "BEQ";
    pc = 32'h30000000;
    offset = 32'hF;
    opcode = 5'b11000;
    branch_type = 3'b000;
    
    rs1 = 32'h12345678; rs2 = 32'h12345678; taken_expected = 1; expected_res = 32'h3000000F;
    #10;

    rs1 = 32'h12345678; rs2 = 32'h12345768; taken_expected = 0; expected_res = 32'h30000000;
    #10;

/*#################################################################################*/

    test_phase = "BNE";
    pc = 32'h3000000F;
    offset = -32'hF;
    opcode = 5'b11000;
    branch_type = 3'b001;
    
    rs1 = 32'h12345678; rs2 = 32'h12345678; taken_expected = 0; expected_res = 32'h3000000F;
    #10;

    rs1 = 32'h12345678; rs2 = 32'h12345768; taken_expected = 1; expected_res = 32'h30000000;
    #10;

/*#################################################################################*/

    test_phase = "BLT";
    pc = 32'h3000000F;
    offset = 32'hF;
    opcode = 5'b11000;
    branch_type = 3'b100;

    rs1 = -32'd25; rs2 = -32'd23; taken_expected = 1; expected_res = 32'h3000001E;
    #10;
    
    rs1 = 32'd25; rs2 = 32'd23; taken_expected = 0; expected_res = 32'h3000000F;
    #10;

    rs1 = 32'd25; rs2 = 32'd26; taken_expected = 1; expected_res = 32'h3000001E;
    #10;

    rs1 = 32'd25; rs2 = 32'd25; taken_expected = 0; expected_res = 32'h3000000F;
    #10;

/*#################################################################################*/

    test_phase = "BGE";
    pc = 32'h3000000F;
    offset = 32'hF;
    opcode = 5'b11000;
    branch_type = 3'b101;
    
    rs1 = 32'd 25; rs2 = 32'd23; taken_expected = 1; expected_res = 32'h3000001E;
    #10;

    rs1 = 32'd25; rs2 = 32'd26; taken_expected = 0; expected_res = 32'h3000000F;
    #10;

    rs1 = -32'd23; rs2 = -32'd26; taken_expected = 1; expected_res = 32'h3000001E;
    #10;

    rs1 = 32'd25; rs2 = 32'd25; taken_expected = 0; expected_res = 32'h3000000F;
    #10;

/*#################################################################################*/

    test_phase = "BLTU";
    pc = 32'h3000000F;
    offset = 32'hF;
    opcode = 5'b11000;
    branch_type = 3'b110;

    rs1 = 32'd 25; rs2 = 32'd23; taken_expected = 0; expected_res = 32'h3000000F;
    #10;

    rs1 = 32'd25; rs2 = 32'd26; taken_expected = 1; expected_res = 32'h3000001E;
    #10;

    rs1 = 32'd25; rs2 = 32'd25; taken_expected = 0; expected_res = 32'h3000000F;
    #10;

    rs1 = 32'd25; rs2 = -32'd25; taken_expected = 1; expected_res = 32'h3000001E; // Negative nums larger than positive in unsigned
    #10;

/*#################################################################################*/

    test_phase = "BGEU";
    pc = 32'h3000000;
    offset = 32'hF;
    opcode = 5'b11000;
    branch_type = 3'b101;
    
    rs1 = 32'd 25; rs2 = 32'd23; taken_expected = 1; expected_res = 32'h3000000F;
    #10;

    rs1 = 32'd25; rs2 = 32'd26; taken_expected = 0; expected_res = 32'h30000000;
    #10;

    rs1 = 32'd25; rs2 = -32'd25; taken_expected = 1; expected_res = 32'h3000000F; // Negative nums larger than positive in unsigned
    #10;

    rs1 = 32'd25; rs2 = 32'd25; taken_expected = 0; expected_res = 32'h30000000;
    #10;

    

/*#################################################################################*/

    test_phase = "JALR";
    pc = 32'h3000000F;
    offset = 32'hF;
    opcode = 5'b11001;
    rs1 = 0;
    
    taken_expected = 1; link_expected = 1; expected_res = 32'hF; expected_link = 32'h30000013;
    #10;

/*#################################################################################*/

    test_phase = "JAL";
    pc = 32'h30000000;
    offset = 32'hFF;
    opcode = 5'b11011;
    
    taken_expected = 1; link_expected = 1; expected_res = 32'h3000001E; expected_link = 32'h300000FF;
    #10;

/*#################################################################################*/

    test_phase = "AUIPC";
    pc = 32'h30000000;
    offset = 32'h100;
    opcode = 5'b00101;
    
    taken_expected = 1; expected_res = 32'h30000100;
    #10;

    $finish;
  end

endmodule
