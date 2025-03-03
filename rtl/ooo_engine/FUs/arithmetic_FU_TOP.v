module arithmetic_FU#(parameter XLEN=32, ROB_SIZE=256)(
    input clk, rst, valid_in,
    input                       additional_info,
    input[2:0]                  arithmetic_type,
    input[$clog2(ROB_SIZE)-1:0] rob_entry_in,
    input[XLEN-1:0]             rs1,
    input[XLEN-1:0]             rs2,

    output reg[XLEN-1:0] result,
    output reg           valid_out,
    output reg           rob_entry
);

always @(posedge clk) begin
    if(rst)
        result <= 1'b0;
    else begin
        rob_entry <= rob_entry_in;
        case (arithmetic_type)
            3'b000: // Add/Sub
                if(additional_info)
                    result <= $signed(rs1) - $signed(rs2);
                else 
                    result <= $signed(rs1) + $signed(rs2);
            3'b010: // Set Less than, needs to be intepreted as signed
                result <= ($signed(rs2) > $signed(rs1)) ? 1'b1 : 1'b0;
            3'b011: // Set Less than Unsigned
                result <= (rs2 > rs1) ? 1 : 0; 

            default: 
                result <= 2;
        endcase
    end
end
endmodule