module arithmetic_FU#(parameter XLEN=32)(
    input clk, rst, valid,
    input[2:0]  arithmetic_type,
    input       additional_info,
    input[XLEN - 1:0] rs1,
    input[XLEN - 1:0] rs2,

    output reg[31:0] result,
    output reg       valid_out
);

always @(posedge clk) begin
    if(rst)
        result <= 1'b0;
    else begin
        case (operation)
            3'b000: // Add/Sub
                result <= rs1 + ((additional_info) ? (!rs2 + 1) : rs2);
            3'b010: // Set Less than, needs to be intepreted as signed
                if(!rs1[31] && rs2[31])         result <= 1'b1;
                else if(rs1[31] && !rs2[31])    result <= 1'b0;
                else                            result <= (rs2 > rs1) ? 1'b1 : 1'b0;
            3'b011: // Set Less than Unsigned
                result <= (rs2 > rs1) ? 1'b1 : 1'b0; 

            default: 
                result <= 1'b0;
        endcase
    end
end
endmodule