module logical_FU#(parameter XLEN=32)(
    input clk, rst, 
    input[3:0] logical_type,
    input[31:0] input_a,
    input[31:0] input_b,

    output reg[31:0] result
);

always @(posedge clk) begin
    case (logical_type)
        4'b0000: // Add/Sub
            result = input_a + ((logical_type[3]) ? (!input_b + 1) : input_b);
        4'b0001: // Logical Left Shift
            result = input_a << (input_b & 5'b11111);
        4'b0010: // Set Less than
            result = (input_b > input_a) ? 1 : 0;
        4'b0011: // Set Less than Unsigned
            result = (input_b > input_a) ? 1 : 0;
        4'b0100: // XOR
            result = input_a ^ input_b;
        4'b0101: // Right shift
            result = (logical_type[3]) ? (input_a >>> (input_b & 5'b11111)) : (input_a >> (input_b & 5'b11111));  // Logical
        4'b0110: // OR
            result = input_a | input_b;
        4'b0111: // AND
            result = input_a & input_b;

        default: 
            result = 0;
    endcase
end
endmodule
