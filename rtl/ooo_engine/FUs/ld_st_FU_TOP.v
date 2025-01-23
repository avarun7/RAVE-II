module br_FU#(parameter XLEN=32)(
    input clk, rst, valid,
    input[4:0] opcode,
    input[3:0] ld_st_type,
    input[31:0] rs1,
    input[31:0] rs2,

    output reg[31:0] result
);

reg equals, less_than;

    always @(posedge clk) begin
        case (opcode)
            
        endcase
    end

endmodule