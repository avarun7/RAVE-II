module md_FU#(parameter XLEN=32)(
    input clk, rst, valid_in,
    input[2:0] md_type,
    input[XLEN-1:0] rs1,
    input[XLEN-1:0] rs2,
    input[XLEN-1:0] pc,
    input[XLEN-1:0] offset,

    output reg[XLEN-1:0] result,
    output reg       valid_out
);


reg [XLEN*2-1:0] whole_result;

    always @(posedge clk) begin
        if(md_type[2]) begin // Div
            if(rs2 == 0) valid_out <= 0;
            if(md_type[0]) result <= rs1 / rs2;
            else           result <= $signed(rs1) / $signed(rs2);
        end
        else begin // Mul
            // Determine signed vs unsigned
            if(md_type[1]) whole_result <= rs1 * rs2;
            else           whole_result <= $signed(rs1) * $signed(rs2);
                
            if(md_type[0]) result <= whole_result[2*XLEN-1:XLEN];
            else           result <= whole_result[XLEN-1:0];
        end
    end

endmodule