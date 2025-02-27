module rsv_entry #(parameter XLEN = 32)(

);

endmodule


module rsv #(parameter XLEN=32, SIZE=16)( // Assume mapper handles SEXT
    input clk, rst, valid_in,

    // Organized as such within the RSV
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

    /*   Update Vars, from ring from ROB   */
    input                   update,
    input[4:0]              update_reg,
    input[XLEN-1:0]         update_val,
    
    output reg[XLEN-1:0]    rs1,
    output reg[XLEN-1:0]    rs2,
    output reg[XLEN-1:0]    pc,
    input[4:0]              opcode,
    input[2:0]              opcode_type,
    input                   additional_info

        
);

reg [(3*XLEN + 19)-1:0]     reservation_station [0:SIZE-1]; // 32-bit PC, 2 32-bit values, 2 5-bit reg ids, 7 bits of opcode data, 
reg [SIZE-1:0]              free_list;

always @(posedge clk or posedge rst) begin
    
end

endmodule