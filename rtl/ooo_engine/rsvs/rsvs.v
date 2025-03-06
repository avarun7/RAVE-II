// https://electronics.stackexchange.com/questions/266587/finding-an-empty-slot-in-an-array-of-registers
// Use of pencoders for access

module rsv_entry #(parameter XLEN = 32)(
    input[4:0]              rs1_reg,
    input                   rs1_received,
    input[XLEN-1:0]         rs1_value,
    input[XLEN-1:0]         pc_in,
    input[4:0]              opcode_in,
    input[2:0]              opcode_type_in,
    input                   additional_info_in,
    input[XLEN-1:0]         rs2_value,
    input                   rs2_received,
    input[4:0]              rs2_reg,

    output reg[XLEN-1:0]    rs1,
    output reg[XLEN-1:0]    rs2,
    output reg[XLEN-1:0]    pc,
    input[4:0]              opcode,
    input[2:0]              opcode_type,
    input                   additional_info

);

endmodule


module rsv #(parameter XLEN=32, SIZE=16, PHYS_REG_SIZE=256)( // Assume mapper handles SEXT
    input clk, rst, valid_in,

    // Organized as such within the RSV
    input[$clog2(PHYS_REG_SIZE)-1:0]    rs1_reg,
    input                               rs1_received,
    input[XLEN-1:0]                     rs1_value,
    input[XLEN-1:0]                     pc_in,
    input[4:0]                          opcode_in,
    input[2:0]                          opcode_type_in,
    input                               additional_info_in,
    input[XLEN-1:0]                     rs2_value,
    input                               rs2_received,
    input[$clog2(PHYS_REG_SIZE)-1:0]    rs2_reg,

    /*   Update Vars, from ring from ROB   */
    input                               update,
    input[$clog2(PHYS_REG_SIZE)-1:0]    update_reg,
    input[XLEN-1:0]                     update_val,
    
    output reg[XLEN-1:0]                rs1,
    output reg[XLEN-1:0]                rs2,
    output reg[XLEN-1:0]                pc,
    input[4:0]                          opcode,
    input[2:0]                          opcode_type,
    input                               additional_info

);


always @(posedge clk or posedge rst) begin

    // 2 pointers with read and write
    
end

endmodule