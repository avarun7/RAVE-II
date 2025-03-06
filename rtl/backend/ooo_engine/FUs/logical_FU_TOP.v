module logical_FU#(parameter XLEN=32, ROB_SIZE=256)( 
    input clk, rst, valid_in,
    input additional_info,
    input[$clog2(ROB_SIZE)-1:0] rob_entry_in,
    input[2:0] logical_type,
    input[4:0] opcode,
    input[XLEN - 1:0] rs1,
    input[XLEN - 1:0] rs2,

    output reg[XLEN - 1:0] result,
    output reg             valid_out,
    output reg             rob_entry
);
    always @(posedge clk) begin
        if(rst || !valid_in) valid_out <= 0;
        else begin
            rob_entry <= rob_entry_in;
            valid_out <= 1;
            if(opcode == 5'b01101) result <= rs1;
            else begin
                case (logical_type)
                    3'b100: // XOR
                        result <= rs1 ^ rs2;
                    3'b110: // OR
                        result <= rs1 | rs2;
                    3'b111: // AND
                        result <= rs1 & rs2;
                    3'b001: // Logical Left Shift
                        result <= rs1 << (rs2 & 5'b11111);
                    3'b101: // Right shift
                        if(additional_info) 
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
