// https://electronics.stackexchange.com/questions/266587/finding-an-empty-slot-in-an-array-of-registers
// Use of pencoders for access

module rsv #(parameter XLEN=32, SIZE=16, PHYS_REG_SIZE=256, ROB_SIZE=265)( // Assume mapper handles SEXT
    input clk, rst, valid_in,

    // Organized as such within the RSV
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
    input                               update_valid,
    input[$clog2(PHYS_REG_SIZE)-1:0]    update_reg,
    input[XLEN-1:0]                     update_val,
    
    output reg[$clog2(ROB_SIZE)-1:0]    rob_entry,
    output reg[XLEN-1:0]                rs1,
    output reg[XLEN-1:0]                rs2,
    output reg[XLEN-1:0]                pc,
    output reg[4:0]                     opcode,
    output reg[2:0]                     opcode_type,
    output reg                          additional_info,
    output reg                          valid_out

);

reg[SIZE-1:0]                           free_list;
reg[SIZE-1:0]                           available;
reg[SIZE-1:0]                           rs1_update;
reg[SIZE-1:0]                           rs2_update;
wire[$clog2(SIZE)-1:0]                  dispatch;
wire[$clog2(SIZE)-1:0]                  allocate;
wire                                    none_dispatch;
wire                                    none_allocate;

reg[$clog2(ROB_SIZE)-1:0]         rob_queue                [0:SIZE-1];
reg[$clog2(PHYS_REG_SIZE)-1:0]    rs1_reg_queue            [0:SIZE-1];
reg                               rs1_received_queue       [0:SIZE-1];
reg[XLEN-1:0]                     rs1_value_queue          [0:SIZE-1];
reg[XLEN-1:0]                     pc_queue                 [0:SIZE-1];
reg[4:0]                          opcode_queue             [0:SIZE-1];
reg[2:0]                          opcode_type_queue        [0:SIZE-1];
reg                               additional_info_queue    [0:SIZE-1];
reg[XLEN-1:0]                     rs2_value_queue          [0:SIZE-1];
reg                               rs2_received_queue       [0:SIZE-1];
reg[$clog2(PHYS_REG_SIZE)-1:0]    rs2_reg_queue            [0:SIZE-1];


pencoder #(.WIDTH(SIZE)) out(.a(available), .o(dispatch), .none(none_dispatch));
pencoder #(.WIDTH(SIZE)) in(.a(free_list), .o(allocate), .none(none_allocate));

initial begin
    free_list = {SIZE{1'b1}};
    available = {SIZE{1'b0}};
    for(i = 0; i < SIZE; i = i + 1) begin
        rs1_received_queue[i] <= 1'b0;
        rs2_received_queue[i] <= 1'b0;
    end
end

integer unsigned i;
always @(*) begin
    for(i = 0; i < SIZE; i = i + 1) begin
        available[i] <= rs2_received_queue[i] & rs1_received_queue[i];
    end
end

always @(*) begin
    for(i = 0; i < SIZE; i = i + 1) begin
        if((update_reg == rs1_reg_queue[i]) & !rs1_received_queue[i])
            rs1_update[i] <= 1;
        else rs1_update[i] <= 0;
    end
end

always @(*) begin
    for(i = 0; i < SIZE; i = i + 1) begin
        if((update_reg == rs2_reg_queue[i]) & !rs2_received_queue[i])
            rs2_update[i] <= 1;
        else rs2_update[i] <= 0;
    end
end

always @(posedge clk or posedge rst) begin
    
    if(!none_dispatch)begin
        // Dispatch to fu
        rob_entry                       <= rob_queue[dispatch];
        rs1                             <= rs1_value_queue[dispatch];
        pc                              <= pc_queue[dispatch];
        opcode                          <= opcode_queue[dispatch];
        opcode_type                     <= opcode_type_queue[dispatch];
        additional_info                 <= additional_info_queue[dispatch];
        rs2                             <= rs2_value_queue[dispatch];
        rs2_received_queue[dispatch]    <= 1'b0;
        free_list[dispatch]             <= 1'b1;
        valid_out                       <= 1'b1;
        
    end else valid_out                  <= 1'b0;
    // TODO: Needs double pointer method, no idea how imma do that
    if(!none_allocate & valid_in) begin
        // Write to FU
        rob_queue[allocate]               <= rob_entry;
        rs1_reg_queue[allocate]           <= rs1_reg;
        rs1_received_queue[allocate]      <= rs1_received;
        rs1_value_queue[allocate]         <= rs1_value;
        pc_queue[allocate]                <= pc_in;
        opcode_queue[allocate]            <= opcode_in;
        opcode_type_queue[allocate]       <= opcode_type_in;
        additional_info_queue[allocate]   <= additional_info_in;
        rs2_value_queue[allocate]         <= rs2_value;
        rs2_received_queue[allocate]      <= rs2_received;
        rs2_reg_queue[allocate]           <= rs2_reg;
        free_list[allocate]               <= 1'b0;                                                        
    end

    // Update
    if(update_valid)begin
        for(i=0; i < SIZE; i = i + 1)begin
            if(rs1_update[i])begin
                rs1_received_queue[i] <= 1'b1;
                rs1_value_queue[i]    <= update_val;
            end
            if(rs2_update[i])begin
                rs2_received_queue[i] <= 1'b1;
                rs2_value_queue[i]    <= update_val;
            end
        end
    end
    
end


endmodule