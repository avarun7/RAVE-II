module md_FU#(parameter XLEN=32, ROB_SIZE=256, UOP_SIZE=16, PHYS_REG_SIZE=256)(
    input clk, rst, valid_in,
    input[$clog2(UOP_SIZE)-1:0]             uop,
    input[XLEN-1:0]                         rs1,
    input[XLEN-1:0]                         rs2,
    input[XLEN-1:0]                         pc,
    input[$clog2(ROB_SIZE)-1:0]             rob_entry_in,
    input[$clog2(PHYS_REG_SIZE)-1:0]        dest_reg_in,

    output reg[XLEN-1:0]                    result,
    output reg                              valid_out,
    output reg[$clog2(ROB_SIZE)-1:0]        rob_entry,
    output reg[$clog2(PHYS_REG_SIZE)-1:0]   dest_reg
);


reg [XLEN*2-1:0] whole_result;

    always @(posedge clk) begin
        rob_entry <= rob_entry_in;
        valid_out <= valid_in;
        dest_reg <= dest_reg_in;
        if(uop[2]) begin // Div
            if(rs2 == 0) valid_out <= 0;
            if(uop[0]) result <= rs1 / rs2;
            else           result <= $signed(rs1) / $signed(rs2);
        end
        else begin // Mul
            // Determine signed vs unsigned
            if(uop[1]) whole_result <= rs1 * rs2;
            else           whole_result <= $signed(rs1) * $signed(rs2);
                
            if(uop[0]) result <= whole_result[2*XLEN-1:XLEN];
            else           result <= whole_result[XLEN-1:0];
        end
    end

endmodule