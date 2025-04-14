module logical_FU#(parameter XLEN=32, ROB_SIZE=256, UOP_SIZE=16, PHYS_REG_SIZE=256)( 
    input clk, rst, valid_in,
    input[$clog2(ROB_SIZE)-1:0]             rob_entry_in,
    input[$clog2(PHYS_REG_SIZE)-1:0]        dest_reg_in,
    input[$clog2(UOP_SIZE)-1:0]             uop,
    input[XLEN - 1:0]                       rs1,
    input[XLEN - 1:0]                       rs2,
    input[XLEN - 1:0]                       pc,

    output reg[XLEN - 1:0]                  result,
    output reg                              valid_out,
    output reg[$clog2(ROB_SIZE)-1:0]        rob_entry,
    output reg[$clog2(PHYS_REG_SIZE)-1:0]   dest_reg

);
    always @(posedge clk) begin
        if(rst || !valid_in) valid_out <= 0;
        else begin
            rob_entry <= rob_entry_in;
            dest_reg <= dest_reg_in;
            valid_out <= valid_in;

            if(UOP_SIZE == 5'b01101) result <= rs1;
            else begin
                case (uop[3:0])
                    4'b0100: // XOR
                        result <= rs1 ^ rs2;
                    4'b0110: // OR
                        result <= rs1 | rs2;
                    4'b0111: // AND
                        result <= rs1 & rs2;
                    4'b0001: // Logical Left Shift
                        result <= rs1 << (rs2 & 5'b11111);
                    4'b0101: // Right shift
                        if(uop[0]) 
                            result <= ($signed(rs1) >>> (rs2 & 5'b11111));
                        else                
                            result <= (rs1 >> (rs2 & 5'b11111));
                    default: 
                        result <= 1'b0;
                endcase
            end
        end
    end
endmodule
