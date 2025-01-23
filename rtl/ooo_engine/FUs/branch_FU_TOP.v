module br_FU#(parameter XLEN=32)(
    input clk, rst, valid,
    input[4:0] opcode,
    input[3:0] branch_type,
    input[31:0] rs1,
    input[31:0] rs2,
    input[31:0] pc,
    input[31:0] offset,

    output reg[31:0] result,
    output reg       taken
);

reg equals, less_than;

    always @(posedge clk) begin
        case (opcode)
            5'b11000: begin// Branch Instruction
                equals = (rs1 == rs2);
                if(branch_type[2]) begin
                    less_than <= rs1 < rs2;
                    if(branch_type[1])  // Unsigned types, no need for other comparisons
                        taken <= ((branch_type[0]) ? less_than : !less_than) & !equals;
                    else begin
                        if(rs1[31] && rs2[31])          taken <= ((branch_type[0]) ? less_than : !less_than) & !equals;
                        else if(!rs1[31] && rs2[31])    taken <= 1'b1;
                        else if(rs1[31] && !rs2[31])    taken <= 1'b0;
                        else                            taken <= ((branch_type[0]) ? less_than : !less_than) & !equals;
                    end
                end
                else begin
                    result <= pc + offset;
                    taken <= (branch_type[0]) ? (!equals) : equals;
                end
            end

            5'b11001: begin
                taken <= 1'b1;
            end  // TODO: JALR needs to put PC+4 in RD
                
                
            5'b11011: begin
                taken <= 1'b1;
            end  //JAL does same thing
                
                
            5'b00101: begin
                taken <= 1'b1;
                result <= pc + offset;
            end

            default: begin
                taken <= 1'b0;
                result <= 32'b0;
            end
        endcase
    end

endmodule