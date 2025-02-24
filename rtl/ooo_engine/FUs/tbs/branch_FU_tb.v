`timescale 1ns/1ps

module branch_FU_tb;
  // Parameters
  parameter XLEN = 32;
  
  // Test bench signals
  reg clk;
  reg rst;
  reg valid_in;
  reg[4:0] opcode;
  reg[2:0] branch_type;
  reg[XLEN-1:0] rs1;
  reg[XLEN-1:0] rs2;
  reg[XLEN-1:0] pc;
  reg[XLEN-1:0] offset;
  
  wire              valid_out;
  wire[XLEN - 1:0]  result;
  wire[XLEN - 1:0]  link_reg;
  wire              taken;
  wire              link;
  
  
  // Instantiate the TLB
  branch_FU #(
    .XLEN(XLEN)
  ) branch_fu(
    .clk(clk),
    .rst(rst),
    .valid_in(valid_in),
    .opcode(opcode),
    .branch_type(branch_type),
    .rs1(rs1),
    .rs2(rs2),
    .pc(pc),
    .offset(offset),

    .valid_out(valid_out),
    .result(result),
    .link_reg(link_reg),
    .taken(taken),
    .link(link)
  );
  
  // Clock generation
  always begin
    #5 clk = ~clk;
  end
  
  // Initial block for waveform generation
  initial begin
    // Create VCD file
    $dumpfile("branch_FU.vcd");
    // Dump all variables including those in sub-modules
    $dumpvars(0, branch_FU_tb);
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
    errors = 0;
    pc = 0;
    
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
    errors = 0;
    opcode = 5'b11000;
    branch_type = 3'b000;
    
    rs1 = 32'h12345678; rs1 = 32'h12345678; taken_expected = 1; expected_res = 32'h3000000F;
    #10;

    rs1 = 32'h12345678; rs1 = 32'h12345768; taken_expected = 0; expected_res = 32'h30000000;
    #10;

/*#################################################################################*/

    test_phase = "BNE";
    pc = 32'h3000000F;
    offset = -32'hF;
    errors = 0;
    opcode = 5'b11000;
    branch_type = 3'b001;
    
    rs1 = 32'h12345678; rs1 = 32'h12345678; taken_expected = 0; expected_res = 32'h3000000F;
    #10;

    rs1 = 32'h12345678; rs1 = 32'h12345768; taken_expected = 1; expected_res = 32'h30000000;
    #10;

/*#################################################################################*/

    test_phase = "BLT";
    pc = 32'h3000000F;
    offset = 32'hF;
    errors = 0;
    opcode = 5'b11000;
    branch_type = 3'b100;

    rs1 = -32'd 25; -rs1 = -32'd23; taken_expected = 1; expected_res = 32'h3000001E;
    #10;
    
    rs1 = 32'd 25; rs1 = 32'd23; taken_expected = 0; expected_res = 32'h3000000F;
    #10;

    rs1 = 32'd25; rs1 = 32'd26; taken_expected = 1; expected_res = 32'h3000001E;
    #10;

    rs1 = 32'd25; rs1 = 32'd25; taken_expected = 0; expected_res = 32'h3000000F;
    #10;

/*#################################################################################*/

    test_phase = "BGE";
    pc = 32'h3000000F;
    offset = 32'hF;
    errors = 0;
    opcode = 5'b11000;
    branch_type = 3'b101;
    
    rs1 = 32'd 25; rs1 = 32'd23; taken_expected = 1; expected_res = 32'h3000001E;
    #10;

    rs1 = 32'd25; rs1 = 32'd26; taken_expected = 0; expected_res = 32'h3000000F;
    #10;

    rs1 = -32'd23; rs1 = -32'd26; taken_expected = 1; expected_res = 32'h3000001E;
    #10;

    rs1 = 32'd25; rs1 = 32'd25; taken_expected = 0; expected_res = 32'h3000000F;
    #10;

/*#################################################################################*/

    test_phase = "BLTU";
    pc = 32'h3000000F;
    offset = 32'hF;
    errors = 0;
    opcode = 5'b11000;
    branch_type = 3'b110;

    rs1 = 32'd 25; rs1 = 32'd23; taken_expected = 0; expected_res = 32'h3000000F;
    #10;

    rs1 = 32'd25; rs1 = 32'd26; taken_expected = 1; expected_res = 32'h3000001E;
    #10;

    rs1 = 32'd25; rs1 = 32'd25; taken_expected = 0; expected_res = 32'h3000000F;
    #10;

    rs1 = -32'd25; rs1 = 32'd25; taken_expected = 1; expected_res = 32'h3000001E; // Negative nums larger than positive in unsigned
    #10;

/*#################################################################################*/

    test_phase = "BGEU";
    pc = 32'h3000000;
    offset = 32'hF;
    errors = 0;
    opcode = 5'b11000;
    branch_type = 3'b101;
    
    rs1 = 32'd 25; rs1 = 32'd23; taken_expected = 1; expected_res = 32'h3000000F;
    #10;

    rs1 = 32'd25; rs1 = 32'd26; taken_expected = 0; expected_res = 32'h30000000;
    #10;

    rs1 = -32'd25; rs1 = 32'd25; taken_expected = 1; expected_res = 32'h3000000F; // Negative nums larger than positive in unsigned
    #10;

    rs1 = 32'd25; rs1 = 32'd25; taken_expected = 0; expected_res = 32'h30000000;
    #10;

    

/*#################################################################################*/

    test_phase = "JALR";
    pc = 32'h3000000F;
    offset = 32'hF;
    errors = 0;
    opcode = 5'b11001;
    rs1 = 0;
    
    taken_expected = 1; link_expected = 1; expected_res = 32'hF; expected_link = 32'h30000013;
    #10;

/*#################################################################################*/

    test_phase = "JAL";
    pc = 32'h30000000;
    offset = 32'hFF;
    errors = 0;
    opcode = 5'b11011;
    
    taken_expected = 1; link_expected = 1; expected_res = 32'h3000001E; expected_link = 32'h300000FF;
    #10;

/*#################################################################################*/

    test_phase = "AUIPC";
    pc = 32'h30000000;
    offset = 32'h100;
    errors = 0;
    opcode = 5'b00101;
    
    taken_expected = 1; expected_res = 32'h3000001E;
    #10;

    $finish;
  end

  task check_result;
        begin
            if (result !== expected_res) begin
                errors = errors + 1;
                $display("%0t\t%h\t%h\t%h\t%h\tFAIL", $time, rs1, rs2, expected, result);
            end 
        end
    endtask

endmodule
