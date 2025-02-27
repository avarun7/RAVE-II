module ldst_FU#(parameter XLEN=32)(
    input clk, rst, valid,
    input[4:0] opcode,
    input[3:0] ld_st_type,
    input[XLEN-1:0] rs1,
    input[XLEN-1:0] rs2,

    output reg[XLEN-1:0] result,
    output reg[XLEN-1:0] address
);

reg equals, less_than;
    // Output to D$
    // if LD/ST, data, data size, sext bit, address, valid, OoO tag
    always @(posedge clk) begin
        if(!opcode[3])begin
            //loads
        end
        else begin
            //stores
        end
            
    end

endmodule