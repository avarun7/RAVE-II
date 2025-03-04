module logical_FU#(parameter XLEN=32)( // TODO: Break integer and logical units into break
    input clk, rst, valid,
    input[2:0] logical_type,
    input[31:0] input_a,
    input[31:0] input_b,

    output reg[31:0] result
);

always @(posedge clk) begin

end
endmodule
