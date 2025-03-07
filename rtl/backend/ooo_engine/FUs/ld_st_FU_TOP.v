module ldst_FU#(parameter XLEN=32, ROB_SIZE=256, PHYS_REG_SIZE=256, UOP_SIZE=16)(
    input clk, rst, valid_in,
    input[$clog2(UOP_SIZE)-1:0]             uop,
    input[$clog2(ROB_SIZE)-1:0]             rob_entry_in,
    input[$clog2(PHYS_REG_SIZE)-1:0]        dest_reg_in,
    input[XLEN-1:0]                         rs1,
    input[XLEN-1:0]                         rs2,
    input[XLEN-1:0]                         pc,

    output reg[XLEN-1:0]                    result,
    output reg                              valid_out,
    output wire[$clog2(ROB_SIZE)-1:0]       rob_entry,
    output wire[$clog2(PHYS_REG_SIZE)-1:0]  dest_reg
);

reg equals, less_than;
    // Output to D$
    // if LD/ST, data, data size, sext bit, address, valid, OoO tag
    always @(posedge clk) begin
        if(!uop[3])begin
            //loads
        end
        else begin
            //stores
        end
            
    end

endmodule