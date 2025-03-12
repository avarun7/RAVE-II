`timescale 1ns / 1ps

module frontend_tb();

reg clk, rst, stall_in, resteer;
reg mispredict_BR, exception_ROB;
reg [31:0] addr_BR, addr_ROB;
wire[31:0]addr_out_even, addr_out_odd;
wire[127:0] cl_odd, cl_even;

always begin
    #5
    clk = !clk;
end

initial begin

    //init
    clk = 0;
    rst = 1;
    resteer = 0;
    mispredict_BR = 0;
    exception_ROB = 0;

    addr_BR = 32'b0;
    addr_ROB = 32'b0;
    stall_in = 0;

    #20
    rst = 0;

    #60

    // from memory system tb, addresses are:
    //even: 32'h20
    //odd: 32'h30

    #20
    //resteer from BR, clc should be 0x8
    resteer = 1;
    mispredict_BR = 1;
    addr_BR = 32'h20; //26'h20
    addr_ROB = 32'h30; 

    #300
    resteer = 0;
    mispredict_BR = 0;
    addr_BR = 32'b0;
    addr_ROB = 32'b0;

    #20
    resteer = 1;
    exception_ROB = 1;

    addr_BR = 32'h20;
    addr_ROB = 32'h30; //26'h30

    #20

    resteer = 0;
    exception_ROB = 0;
    addr_BR = 32'b0;
    addr_ROB = 32'b0;

    #20

    

    $finish;
end

initial begin
    // Create VCD file
    $dumpfile("frontend.vcd");
    // Dump all variables including those in sub-modules
    $dumpvars(0, frontend_tb);
    // Add specific signals to wave window with hierarchy
  end

frontend_TOP frontend (
    .clk(clk), .rst(rst),

    //inputs
    .resteer(resteer),
    .stall_in(stall_in),
    .resteer_target_BR(addr_BR), //32b - mispredict
    .resteer_target_ROB(addr_ROB), //32b - exception

    .mispredict_BR(mispredict_BR),
    .exception_ROB(exception_ROB),

    .bp_update(1'b0), //1b
    .bp_update_taken(1'b0), //1b
    .bp_update_target(32'b0), //32b
    .pcbp_update_bhr(10'b0), // bhr to update in pc branch predictor

    .prefetch_addr(32'b0), //32b
    .prefetch_valid(1'b0),

    .l2_icache_op(3'b0), // (R, W, RWITM, flush, update)
    .l2_icache_addr(32'b0), .l2_icache_data(512'b0),
    .l2_icache_state(3'b0),

    .valid_out(),
    .uop(),
    .eoi(),
    .dr(),
    .sr1(),
    .sr2(),
    .imm(),
    .use_imm(),
    .pc(),
    .exception(),
    .pcbp_bhr(),

    .icache_l2_op(),
    .icache_l2_addr(),
    .icache_l2_data_out(),
    .icache_l2_state()
);

endmodule