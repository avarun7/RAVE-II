//d1_TOP testbench
/*
compile and run tb with:
iverilog -o d1_tb.vvp d1_tb.v d1_TOP.v
vvp d1_tb.vvp

Clock Generation: A clock signal is generated with a period of 10 ns.
Reset and Input Initialization:
The reset signal is applied at the start of the testbench, then deasserted to allow normal operation.
Inputs are initialized to zero and updated for each test case.
Test Cases:
Different cases are simulated by modifying input values.
For example, IBuff_in and resteer_target signals are given different values to test typical decode behavior.
Output Monitoring:
The $monitor statement continuously displays signal values during the simulation.
*/

`timescale 1ns / 1ps

module d1_tb;
    parameter XLEN = 32;
    
    // Inputs
    reg clk;
    reg rst;
    reg exception_in;
    reg [XLEN - 1:0] IBuff_in;
    reg resteer;
    reg [XLEN - 1:0] resteer_target_BR;
    reg [XLEN - 1:0] resteer_target_ROB;
    reg bp_update;
    reg bp_update_taken;
    reg [XLEN - 1:0] bp_update_target;
    reg [9:0] pcbp_update_bhr;

    // Outputs
    wire [XLEN - 1:0] pc;
    wire exception_out;
    wire [4:0] opcode_format;
    wire [XLEN - 1:0] instruction_out;
    wire resteer_D1;
    wire [XLEN - 1:0] resteer_target_D1;
    wire resteer_taken;
    wire [9:0] clbp_update_bhr_D1;
    wire ras_push;
    wire ras_pop;
    wire [XLEN - 1:0] ras_ret_addr;

    // Instantiate the DUT (Device Under Test)
    d1_TOP #(XLEN) DUT (
        .clk(clk),
        .rst(rst),
        .exception_in(exception_in),
        .IBuff_in(IBuff_in),
        .resteer(resteer),
        .resteer_target_BR(resteer_target_BR),
        .resteer_target_ROB(resteer_target_ROB),
        .bp_update(bp_update),
        .bp_update_taken(bp_update_taken),
        .bp_update_target(bp_update_target),
        .pcbp_update_bhr(pcbp_update_bhr),
        .pc(pc),
        .exception_out(exception_out),
        .opcode_format(opcode_format),
        .instruction_out(instruction_out),
        .resteer_D1(resteer_D1),
        .resteer_target_D1(resteer_target_D1),
        .resteer_taken(resteer_taken),
        .clbp_update_bhr_D1(clbp_update_bhr_D1),
        .ras_push(ras_push),
        .ras_pop(ras_pop),
        .ras_ret_addr(ras_ret_addr)
    );

    // Generate a clock signal
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 10ns period clock
    end

    // Test stimulus
    initial begin
        // Initialize inputs
        rst = 1;
        exception_in = 0;
        IBuff_in = 32'h00000000;
        resteer = 0;
        resteer_target_BR = 32'h00000000;
        resteer_target_ROB = 32'h00000000;
        bp_update = 0;
        bp_update_taken = 0;
        bp_update_target = 32'h00000000;
        pcbp_update_bhr = 10'b0;

        // Apply reset
        #10 rst = 0;
        
        // Test Case 1: Normal operation
        #10 IBuff_in = 32'hA5A5A5A5;
        resteer = 1;
        resteer_target_BR = 32'h12345678;
        resteer_target_ROB = 32'h87654321;
        
        // Test Case 2: Exception
        #20 exception_in = 1;
        
        // Test Case 3: Branch prediction update
        #10 bp_update = 1;
        bp_update_taken = 1;
        bp_update_target = 32'hABCD1234;
        pcbp_update_bhr = 10'b1010101010;

        // Test Case 4: Resteer inactive
        #10 resteer = 0;
        
        // Test Case 5: RAS Push and Pop signals
        #10 rst = 1;  // Trigger reset to check if outputs reset correctly
        #10 rst = 0;
        
        // Finish simulation
        #50 $finish;
    end

    // Monitor the output signals
    initial begin
        $monitor("Time=%0d | pc=%h | exception_out=%b | opcode_format=%b | instruction_out=%h | resteer_D1=%b | resteer_target_D1=%h | resteer_taken=%b | clbp_update_bhr_D1=%b | ras_push=%b | ras_pop=%b | ras_ret_addr=%h", 
                 $time, pc, exception_out, opcode_format, instruction_out, resteer_D1, resteer_target_D1, resteer_taken, clbp_update_bhr_D1, ras_push, ras_pop, ras_ret_addr);
    end
endmodule
