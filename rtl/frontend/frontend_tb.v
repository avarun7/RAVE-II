module frontend_tb();

reg clk, rst, stall_in;
reg [31:0] addr_even, addr_odd;
wire[31:0]addr_out_even, addr_out_odd;
wire[127:0] cl_odd, cl_even;

always begin
    #5
    clk = !clk;
end

initial begin
    clk = 0;
    rst = 1;

    addr_even = 32'b0;
    addr_odd = 32'b0;
    stall_in = 0;

    #20
    rst = 0;

    #20
    addr_even = 32'b010_0000;
    addr_odd = 32'b011_0000;

    #60
    stall_in = 1;

    #400
    stall_in = 0;

    #500

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
    .resteer(1'b0),
    .stall_in(stall_in),
    .resteer_target_BR(32'b0), //32b - mispredict
    .resteer_target_ROB(32'b0), //32b - exception

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