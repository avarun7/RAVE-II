module br_FU#(parameter XLEN=32)(
    input clk, rst,

    input[31:0] input_a,
    input[31:0] input_b,

    output[31:0] result
);