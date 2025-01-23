module logical_FU#(parameter XLEN=32)( 
    input clk, rst, valid,
    input[2:0] logical_type,
    input[31:0] rs1,
    input[31:0] rs2,

    output reg[31:0] result
);

    always @(posedge clk) begin
        if(rst)
            result <= 0;
        else begin
            case (logical_type)
                4'b0100: // XOR
                    result <= rs1 ^ rs2;
                4'b0110: // OR
                    result <= rs1 | rs2;
                4'b0111: // AND
                    result <= rs1 & rs2;

                default: 
                    result <= 1'b0;
            endcase
        end
    end
endmodule
