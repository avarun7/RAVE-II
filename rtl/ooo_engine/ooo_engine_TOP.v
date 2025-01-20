module ooo_engine_TOP#(parameter XLEN=32)(

);

register [31:0] input_a;
register [31:0] input_b;

// FUs
logical_FU_TOP #(.XLEN(XLEN)) logical_functional_unit(
    .clk(clk), .rst(rst),
    .input_a(input_a),
    .input_b(input_b)
);

arithmetic_FU_TOP #(.XLEN(XLEN)) arithmetic_functional_unit(
    .clk(clk), .rst(rst),
    .input_a(input_a),
    .input_b(input_b)
);

br_FU_TOP #(.XLEN(XLEN)) branch_functional_unit(
    .clk(clk), .rst(rst),
    .input_a(input_a),
    .input_b(input_b)
);

endmodule