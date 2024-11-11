//d2_TOP testbench
/*
compile and simulate with icarus:
iverilog -o d2_tb.vvp d2_tb.v d2_TOP.v
vvp d2_tb.vvp

Clock Signal:
A clock with a 10 ns period is generated for synchronous operations.
Input Initialization:
All inputs are initialized, and a reset is applied to bring the module to a known starting state.
Test Cases:
Test Case 1: Sets a sample pc_in, instruction_in, and opcode_format to test typical decoding behavior.
Test Case 2: Enables exception_in to test how exceptions propagate through the decode process.
Test Case 3: Varies uop_count to check if multiple micro-operations are handled correctly.
Test Case 4: Sets an instruction that likely involves an immediate value, checking the use_imm and imm output behavior.
Test Case 5: Resets the module to verify that outputs reset correctly.
Output Monitoring:
The $monitor statement logs the outputs, so you can observe how d2_TOP responds to each test case.
*/

`timescale 1ns / 1ps

module d2_tb;
    parameter XLEN = 32;
    
    // Inputs
    reg clk;
    reg rst;
    reg [XLEN - 1:0] pc_in;
    reg exception_in;
    reg [1:0] uop_count;
    reg [4:0] opcode_format;
    reg [XLEN - 1:0] instruction_in;

    // Outputs
    wire [XLEN - 1:0] uop;
    wire eoi;
    wire [4:0] dr, sr1, sr2;
    wire [XLEN - 1:0] imm;
    wire use_imm;
    wire [XLEN - 1:0] pc_out;
    wire exception_out;

    // Instantiate the Device Under Test (DUT)
    d2_TOP #(XLEN) DUT (
        .clk(clk),
        .rst(rst),
        .pc_in(pc_in),
        .exception_in(exception_in),
        .uop_count(uop_count),
        .opcode_format(opcode_format),
        .instruction_in(instruction_in),
        .uop(uop),
        .eoi(eoi),
        .dr(dr),
        .sr1(sr1),
        .sr2(sr2),
        .imm(imm),
        .use_imm(use_imm),
        .pc_out(pc_out),
        .exception_out(exception_out)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // Clock period of 10 ns
    end

    // Test stimulus
    initial begin
        // Initialize inputs
        rst = 1;
        pc_in = 0;
        exception_in = 0;
        uop_count = 2'b00;
        opcode_format = 5'b00000;
        instruction_in = 32'h00000000;

        // Apply reset
        #10 rst = 0;
        
        // Test Case 1: Basic instruction decoding
        #10 pc_in = 32'h1000_0000;
            instruction_in = 32'h1234_ABCD;
            opcode_format = 5'b10101;
            uop_count = 2'b01;

        // Test Case 2: Exception handling
        #10 exception_in = 1;
        
        // Test Case 3: Different uop_count
        #10 uop_count = 2'b10;

        // Test Case 4: Check immediate usage
        #10 instruction_in = 32'hABCD_EF12;
            opcode_format = 5'b01010;  // Assuming it maps to an instruction with immediate usage
        
        // Test Case 5: Reset to verify proper output reset
        #10 rst = 1; 
        #10 rst = 0;

        // Finish the simulation
        #50 $finish;
    end

    // Monitor outputs
    initial begin
        $monitor("Time=%0t | uop=%h | eoi=%b | dr=%b | sr1=%b | sr2=%b | imm=%h | use_imm=%b | pc_out=%h | exception_out=%b", 
                 $time, uop, eoi, dr, sr1, sr2, imm, use_imm, pc_out, exception_out);
    end
endmodule
