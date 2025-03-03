module branch_FU#(parameter XLEN=32, ROB_SIZE=256)(
    input clk, rst, valid_in,
    input[4:0]  opcode,
    input[2:0]  branch_type,
    input[XLEN-1:0]      rs1,
    input[XLEN-1:0]      rs2,
    input[XLEN-1:0]      pc,
    input[XLEN-1:0]      offset,
    input[$clog2(ROB_SIZE)-1:0] rob_entry_in,

    output reg           valid_out,
    output reg[XLEN-1:0] result,
    output reg[XLEN-1:0] link_reg,
    output reg           taken,
    output reg           link,
    output reg          rob_entry
);

reg equals, less_than, s_less_than;

    always @(posedge clk) begin
        valid_out <= valid_in;
        rob_entry <= rob_entry_in;
        case (opcode)

            //Branch
            5'b11000: begin
                link <= 1'b0;
                equals = (rs1 == rs2);
                less_than = rs1 < rs2;
                s_less_than = $signed(rs1) < $signed(rs2);
                if(branch_type[2]) begin
                    if(branch_type[1])  // Unsigned types, no need for other comparisons
                        taken <= (((branch_type[0]) ? (!less_than) : less_than) && (!equals));
                    else 
                        taken <= (((branch_type[0]) ? (!s_less_than) : s_less_than) && (!equals));
                end
                else begin
                    taken <= (branch_type[0]) ? (!equals) : equals;
                end
                result <= pc + $signed(offset);
                link_reg <= pc;
            end

            //JALR
            5'b11001: begin // TODO: This assumes that ROB entry has the register allocated to store the result of the PC+OFF
                taken <= 1'b1;
                link <= 1'b1;
                link_reg <= pc + 4;
                result <= rs1 + $signed(offset);
            end 
                
            //JAL
            5'b11011: begin // TODO: This may need to depend on if compressed or not
                taken <= 1'b1;
                link <= 1'b1;
                link_reg <= pc + 4; 
                result <= pc + $signed(offset);
            end  //JAL does same thing
                
            // AUIPC
            5'b00101: begin
                taken <= 1'b1;
                result <= pc + $signed(offset);
                link <= 0;
            end

            default: begin
                taken <= 1'b0;
                result <= 0;
                link <= 0;
            end
        endcase
    end

endmodule