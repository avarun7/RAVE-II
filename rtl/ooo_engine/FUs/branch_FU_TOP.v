module branch_FU#(parameter XLEN=32)(
    input clk, rst, valid_in,
    input       additional_info,
    input[4:0]  opcode,
    input[2:0]  branch_type,
    input[XLEN-1:0] rs1,
    input[XLEN-1:0] rs2,
    input[XLEN-1:0] pc,
    input[XLEN-1:0] offset,

    output reg       valid_out,
    output reg[XLEN-1:0] result,
    output reg       taken,
    output reg       link
);

reg equals, less_than, s_less_than;

    always @(posedge clk) begin
        valid_out <= valid_in;
        case (opcode)
            5'b11000: begin// Branch Instruction
                link <= 1'b0;
                equals = (rs1 == rs2);
                if(branch_type[2]) begin
                    less_than <= rs1 < rs2;
                    s_less_than <= $signed(rs1) < $signed(rs2);
                    if(branch_type[1])  // Unsigned types, no need for other comparisons
                        taken <= ((additional_info) ? less_than : !less_than) & !equals;
                    else 
                        taken <= ((additional_info) ? s_less_than : !s_less_than) & !equals;
                end
                else begin
                    result <= pc + offset;
                    taken <= (additional_info) ? (!equals) : equals;
                end
            end

            5'b11001: begin // TODO: This assumes that ROB entry has the register allocated to store the result of the 
                taken <= 1'b1;
                link <= 1'b1;
                result <= pc + 4;
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
                result <= 0;
            end
        endcase
    end

endmodule