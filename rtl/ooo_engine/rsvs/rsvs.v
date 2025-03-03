// https://electronics.stackexchange.com/questions/266587/finding-an-empty-slot-in-an-array-of-registers
// Use of pencoders for access

module rsv #(parameter XLEN=32, SIZE=16, PHYS_REG_SIZE=256, ROB_SIZE=265)( // Assume mapper handles SEXT
    input clk, rst, valid_in,

    // Organized as such within the RSV, TODO: need rob entry
    input[$clog2(ROB_SIZE)-1:0]         rob_entry_in,
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
    
    output reg[$clog2(ROB_SIZE)-1:0]    rob_entry,
    output reg[XLEN-1:0]                rs1,
    output reg[XLEN-1:0]                rs2,
    output reg[XLEN-1:0]                pc,
    output reg[4:0]                     opcode,
    output reg[2:0]                     opcode_type,
    output reg                          additional_info

);
reg [SIZE-1:0]                          free_list;
reg [SIZE-1:0]                          available;
wire [$clog2(SIZE)-1:0]                 dispatch;
wire [$clog2(SIZE)-1:0]                 allocate;
wire                                    none_dispatch;
wire                                    none_allocate;


reg [($clog2(ROB_SIZE)+2*$clog2(PHYS_REG_SIZE)+3*XLEN+10):0] rsv_entries[0:SIZE-1];
pencoder(.SIZE(SIZE)) read(.a(available), .o(dispatch), .none(none_dispatch));
pencoder(.SIZE(SIZE)) write(.a(free_list), .o(allocate), .none(none_allocate));

initial begin
    free_list = {SIZE{1'b1}};
end

integer unsigned i;
always @(*) begin
    for(i = 0; i < SIZE; i = i + 1) begin
        available[i] <= rsv_entries[i][1] & rsv_entries[i][$clog2(PHYS_REG_SIZE)+3*XLEN+10];
    end
end




always @(posedge clk or posedge rst) begin
    
    if(!none_dispatch)begin
        // Dispatch to fu
        rob_entry                <= rsv_entries[dispatch][($clog2(ROB_SIZE)+2*$clog2(PHYS_REG_SIZE)+3*XLEN+10):(2*$clog2(PHYS_REG_SIZE)+3*XLEN+11)];
        rs1                      <= rsv_entries[dispatch][($clog2(PHYS_REG_SIZE)+3*XLEN+9):($clog2(PHYS_REG_SIZE)+2*XLEN+10)];
        pc                       <= rsv_entries[dispatch][($clog2(PHYS_REG_SIZE)+2*XLEN+9):($clog2(PHYS_REG_SIZE)+XLEN+10)];
        opcode                   <= rsv_entries[dispatch][($clog2(PHYS_REG_SIZE)+XLEN+9):($clog2(PHYS_REG_SIZE)+XLEN+5)];
        opcode_type              <= rsv_entries[dispatch][($clog2(PHYS_REG_SIZE)+XLEN+4):($clog2(PHYS_REG_SIZE)+XLEN+2)];
        additional_info          <= rsv_entries[dispatch][($clog2(PHYS_REG_SIZE)+XLEN+1)];
        rs2                      <= rsv_entries[dispatch][($clog2(PHYS_REG_SIZE)+XLEN):($clog2(PHYS_REG_SIZE)+1)];
        free_list[dispatch] <= 1'b1;
        rsv_entries[i][1]        <= 1'b0;

    end
    // TODO: Needs double pointer method, no idea how imma do that
    if(~|free_list & valid_in) begin
        // Write to FU
        rsv_entries[allocate][($clog2(ROB_SIZE)+2*$clog2(PHYS_REG_SIZE)+3*XLEN+10):($clog2(PHYS_REG_SIZE)+3*XLEN+11)]  <= rob_entry;
        rsv_entries[allocate][(2*$clog2(PHYS_REG_SIZE)+3*XLEN+10):($clog2(PHYS_REG_SIZE)+3*XLEN+11)]                   <= rs1_reg;
        rsv_entries[allocate][($clog2(PHYS_REG_SIZE)+3*XLEN+10)]                                                       <= rs1_received;
        rsv_entries[allocate][($clog2(PHYS_REG_SIZE)+3*XLEN+9):($clog2(PHYS_REG_SIZE)+2*XLEN+10)]                      <= rs1_value;
        rsv_entries[allocate][($clog2(PHYS_REG_SIZE)+2*XLEN+9):($clog2(PHYS_REG_SIZE)+XLEN+10)]                        <= pc_in;
        rsv_entries[allocate][($clog2(PHYS_REG_SIZE)+XLEN+9):($clog2(PHYS_REG_SIZE)+XLEN+5)]                           <= opcode_in;
        rsv_entries[allocate][($clog2(PHYS_REG_SIZE)+XLEN+4):($clog2(PHYS_REG_SIZE)+XLEN+2)]                           <= opcode_type_in;
        rsv_entries[allocate][($clog2(PHYS_REG_SIZE)+XLEN+1)]                                                          <= additional_info_in;
        rsv_entries[allocate][($clog2(PHYS_REG_SIZE)+XLEN):($clog2(PHYS_REG_SIZE)+1)]                                  <= rs2_value;
        rsv_entries[allocate][$clog2(PHYS_REG_SIZE)]                                                                   <= rs2_received;
        rsv_entries[allocate][($clog2(PHYS_REG_SIZE)-1):0]                                                             <= rs2_reg;
    end
       
    
end


endmodule