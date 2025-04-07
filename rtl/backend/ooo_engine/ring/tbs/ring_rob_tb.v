`timescale 1ns/1ps

module ring_rob_tb;

    parameter XLEN=32;
    parameter PHYS_REG_SIZE=256;
    parameter RF_QUEUE=8;
    parameter UOP_SIZE=16;
    parameter ROB_ENTRY=256;
    reg clk; 
    reg rst;

    reg logical_update;
    reg[$clog2(PHYS_REG_SIZE)-1:0] logical_update_reg;
    reg[XLEN-1:0]                  logical_update_val;
    reg[$clog2(ROB_ENTRY)-1:0]     logical_rob_entry;

    reg arithmetic_update;
    reg[$clog2(PHYS_REG_SIZE)-1:0] arithmetic_update_reg;
    reg[XLEN-1:0]                  arithmetic_update_val; 
    reg[$clog2(ROB_ENTRY)-1:0]     arithmetic_rob_entry;

    reg branch_update;
    reg[$clog2(PHYS_REG_SIZE)-1:0] branch_update_reg;
    reg[XLEN-1:0]                  branch_update_val; 
    reg[$clog2(ROB_ENTRY)-1:0]     branch_rob_entry;

    reg ld_st_update;
    reg[$clog2(PHYS_REG_SIZE)-1:0] ld_st_update_reg;
    reg[XLEN-1:0]                  ld_st_update_val;
    reg[$clog2(ROB_ENTRY)-1:0]     ld_st_rob_entry;

    reg mul_div_update;
    reg[$clog2(PHYS_REG_SIZE)-1:0] mul_div_update_reg;
    reg[XLEN-1:0]                  mul_div_update_val;
    reg[$clog2(ROB_ENTRY)-1:0]     mul_div_rob_entry;

    output wire                              out_rob_valid;
    output wire[$clog2(PHYS_REG_SIZE)-1:0]   out_rob_update_reg;
    output wire[XLEN-1:0]                    out_rob_update_val;
    output wire[$clog2(ROB_ENTRY)-1:0]       out_rob_rob_entry;

    output wire                              out_logical_valid;
    output wire[$clog2(PHYS_REG_SIZE)-1:0]   out_logical_update_reg;
    output wire[XLEN-1:0]                    out_logical_update_val;

    output wire                              out_arithmetic_valid;
    output wire[$clog2(PHYS_REG_SIZE)-1:0]   out_arithmetic_update_reg;
    output wire[XLEN-1:0]                    out_arithmetic_update_val; 

    output wire                              out_branch_valid;
    output wire[$clog2(PHYS_REG_SIZE)-1:0]   out_branch_update_reg;
    output wire[XLEN-1:0]                    out_branch_update_val; 

    output wire                              out_ld_st_valid;
    output wire[$clog2(PHYS_REG_SIZE)-1:0]   out_ld_st_update_reg;
    output wire[XLEN-1:0]                    out_ld_st_update_val; 

    output wire                              out_mul_div_valid;
    output wire[$clog2(PHYS_REG_SIZE)-1:0]   out_mul_div_update_reg;
    output wire[XLEN-1:0]                    out_mul_div_update_val;

ring_rob #(
    .XLEN(XLEN),
    .PHYS_REG_SIZE(PHYS_REG_SIZE),
    .RF_QUEUE(RF_QUEUE),
    .UOP_SIZE(UOP_SIZE),
    .ROB_ENTRY(ROB_ENTRY)
) ring_rob(
    .clk(clk), 
    .rst(rst),

    .logical_update(logical_update),
    .logical_update_reg(logical_update_reg),
    .logical_update_val(logical_update_val),
    .logical_rob_entry(logical_rob_entry),
                                                                                                                                          
    .arithmetic_update(arithmetic_update),
    .arithmetic_update_reg(arithmetic_update_reg),
    .arithmetic_update_val(arithmetic_update_val),
    .arithmetic_rob_entry(arithmetic_rob_entry),  

    .branch_update(branch_update),
    .branch_update_reg(branch_update_reg),
    .branch_update_val(branch_update_val),
    .branch_rob_entry(branch_rob_entry),
                                                                                                                                                         
    .ld_st_update(ld_st_update),
    .ld_st_update_reg(ld_st_update_reg),
    .ld_st_update_val(ld_st_update_val),
    .ld_st_rob_entry(ld_st_rob_entry),
                                                                                                                                                 
    .mul_div_update(mul_div_update),
    .mul_div_update_reg(mul_div_update_reg),
    .mul_div_update_val(mul_div_update_val),
    .mul_div_rob_entry(mul_div_rob_entry),
                                                                                                                                                    
    .out_rob_valid(out_rob_valid),
    .out_rob_update_reg(out_rob_update_reg),
    .out_rob_update_val(out_rob_update_val),
    .out_rob_rob_entry(out_rob_rob_entry),
                                                                                                                                                  
    .out_logical_valid(out_logical_valid),
    .out_logical_update_reg(out_logical_update_reg),
    .out_logical_update_val(out_logical_update_val),
                                                                                                                                                   
    .out_arithmetic_valid(out_arithmetic_valid),
    .out_arithmetic_update_reg(out_arithmetic_update_reg),
    .out_arithmetic_update_val(out_arithmetic_update_val),
                                                                                                                                                                                  
    .out_branch_valid(out_branch_valid),
    .out_branch_update_reg(out_branch_update_reg),
    .out_branch_update_val(out_branch_update_val),
                                                                                                                                                                            
    .out_ld_st_valid(out_ld_st_valid),
    .out_ld_st_update_reg(out_ld_st_update_reg),
    .out_ld_st_update_val(out_ld_st_update_val),  

    .out_mul_div_valid(out_mul_div_valid),
    .out_mul_div_update_reg(out_mul_div_update_reg),
    .out_mul_div_update_val(out_mul_div_update_val)
);

// Clock generation
always begin
    #5 clk = ~clk;
end
    
// Initial block for waveform generation
initial begin
    // Create VCD file
    $dumpfile("ring_rob.vcd");
    // Dump all variables including those in sub-modules
    $dumpvars(2, ring_rob_tb);
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
    
    // Apply reset
    #10;
    test_phase = "Reset";
    rst = 1;
    #10 rst = 0;

    // Wait for reset to complete
    #20;
    test_phase = "Post-Reset";
    mul_div_update = 1;
    mul_div_update_reg = 55;
    mul_div_update_val = 32'h12345678;
    mul_div_rob_entry = 19;

    logical_update = 1;
    logical_update_reg = 12;
    logical_update_val = 32'h87654321;
    logical_rob_entry = 91;
    #10;

    mul_div_update = 0;
    logical_update = 0;
    #100;

    $finish;
end


endmodule
    