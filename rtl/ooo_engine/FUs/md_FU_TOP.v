module br_FU#(parameter XLEN=32)(
    input clk, rst, valid,
    input[3:0] md_type,
    input[31:0] rs1,
    input[31:0] rs2,
    input[31:0] pc,
    input[31:0] offset,

    output reg[31:0] result
);



    always @(posedge clk) begin
        if(md_type[2]) begin // Div
            
        end
        else begin // Mul
            
        end
    end

endmodule