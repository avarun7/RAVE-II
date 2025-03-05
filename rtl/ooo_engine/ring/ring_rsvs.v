module ring_rsvs#(parameter XLEN=32, PHYS_REG_SIZE=256, RF_QUEUE=8, ROB_SIZE=256) (
    input clk, rst, valid_in,

    input[2:0]                               functional_unit_num,
    input[$clog2(ROB_SIZE)-1:0]              rob_entry,
    input[$clog2(PHYS_REG_SIZE)-1:0]         uop_rs1_reg,
    input                                    uop_rs1_received,
    input[XLEN-1:0]                          uop_rs1_value,
    input[XLEN-1:0]                          uop_pc_in,
    input[4:0]                               uop_opcode_in,
    input[2:0]                               uop_opcode_type_in,
    input                                    uop_additional_info_in,
    input[XLEN-1:0]                          uop_rs2_value,
    input                                    uop_rs2_received,
    input[$clog2(PHYS_REG_SIZE)-1:0]         uop_rs2_reg,

    output reg[$clog2(PHYS_REG_SIZE)-1:0]    logical_rs1_reg,
    output reg[$clog2(ROB_SIZE)-1:0]         logical_rob_entry,
    output reg                               logical_rs1_received,
    output reg[XLEN-1:0]                     logical_rs1_value,
    output reg[XLEN-1:0]                     logical_pc,
    output reg[4:0]                          logical_opcode,
    output reg[2:0]                          logical_opcode_type,
    output reg                               logical_additional_info,
    output reg[XLEN-1:0]                     logical_rs2_value,
    output reg                               logical_rs2_received,
    output reg[$clog2(PHYS_REG_SIZE)-1:0]    logical_rs2_reg,

    output reg[$clog2(PHYS_REG_SIZE)-1:0]    arithmetic_rs1_reg,
    output reg[$clog2(ROB_SIZE)-1:0]         arithmetic_rob_entry,
    output reg                               arithmetic_rs1_received,
    output reg[XLEN-1:0]                     arithmetic_rs1_value,
    output reg[XLEN-1:0]                     arithmetic_pc,
    output reg[4:0]                          arithmetic_opcode,
    output reg[2:0]                          arithmetic_opcode_type,
    output reg                               arithmetic_additional_info,
    output reg[XLEN-1:0]                     arithmetic_rs2_value,
    output reg                               arithmetic_rs2_received,
    output reg[$clog2(PHYS_REG_SIZE)-1:0]    arithmetic_rs2_reg,

    output reg[$clog2(PHYS_REG_SIZE)-1:0]    branch_rs1_reg,
    output reg[$clog2(ROB_SIZE)-1:0]         branch_rob_entry,
    output reg                               branch_rs1_received,
    output reg[XLEN-1:0]                     branch_rs1_value,
    output reg[XLEN-1:0]                     branch_pc,
    output reg[4:0]                          branch_opcode,
    output reg[2:0]                          branch_opcode_type,
    output reg                               branch_additional_info,
    output reg[XLEN-1:0]                     branch_rs2_value,
    output reg                               branch_rs2_received,
    output reg[$clog2(PHYS_REG_SIZE)-1:0]    branch_rs2_reg,

    output reg[$clog2(PHYS_REG_SIZE)-1:0]    mul_div_rs1_reg,
    output reg[$clog2(ROB_SIZE)-1:0]         mul_div_rob_entry,
    output reg                               mul_div_rs1_received,
    output reg[XLEN-1:0]                     mul_div_rs1_value,
    output reg[XLEN-1:0]                     mul_div_pc,
    output reg[4:0]                          mul_div_opcode,
    output reg[2:0]                          mul_div_opcode_type,
    output reg                               mul_div_additional_info,
    output reg[XLEN-1:0]                     mul_div_rs2_value,
    output reg                               mul_div_rs2_received,
    output reg[$clog2(PHYS_REG_SIZE)-1:0]    mul_div_rs2_reg,

    output reg[$clog2(PHYS_REG_SIZE)-1:0]    ld_st_rs1_reg,
    output reg[$clog2(ROB_SIZE)-1:0]         ld_st_rob_entry,
    output reg                               ld_st_rs1_received,
    output reg[XLEN-1:0]                     ld_st_rs1_value,
    output reg[XLEN-1:0]                     ld_st_pc,
    output reg[4:0]                          ld_st_opcode,
    output reg[2:0]                          ld_st_opcode_type,
    output reg                               ld_st_additional_info,
    output reg[XLEN-1:0]                     ld_st_rs2_value,
    output reg                               ld_st_rs2_received,
    output reg[$clog2(PHYS_REG_SIZE)-1:0]    ld_st_rs2_reg
);
// TODO: Add in offset for the branch unit

reg[2:0]                          ring_uop_disperse_functional_unit_num;
reg[$clog2(PHYS_REG_SIZE)-1:0]    ring_uop_disperse_rs1_reg;
reg[$clog2(ROB_SIZE)-1:0]         ring_uop_disperse_rob_entry;
reg                               ring_uop_disperse_rs1_received;
reg[XLEN-1:0]                     ring_uop_disperse_rs1_value;
reg[XLEN-1:0]                     ring_uop_disperse_pc;
reg[4:0]                          ring_uop_disperse_opcode;
reg[2:0]                          ring_uop_disperse_opcode_type;
reg                               ring_uop_disperse_additional_info;
reg[XLEN-1:0]                     ring_uop_disperse_rs2_value;
reg                               ring_uop_disperse_rs2_received;
reg[$clog2(PHYS_REG_SIZE)-1:0]    ring_uop_disperse_rs2_reg;

reg[2:0]                          ring_logical_functional_unit_num;
reg[$clog2(PHYS_REG_SIZE)-1:0]    ring_logical_rs1_reg;
reg[$clog2(ROB_SIZE)-1:0]         ring_logical_rob_entry;
reg                               ring_logical_rs1_received;
reg[XLEN-1:0]                     ring_logical_rs1_value;
reg[XLEN-1:0]                     ring_logical_pc;
reg[4:0]                          ring_logical_opcode;
reg[2:0]                          ring_logical_opcode_type;
reg                               ring_logical_additional_info;
reg[XLEN-1:0]                     ring_logical_rs2_value;
reg                               ring_logical_rs2_received;
reg[$clog2(PHYS_REG_SIZE)-1:0]    ring_logical_rs2_reg;

reg[2:0]                          ring_arithmetic_functional_unit_num;
reg[$clog2(PHYS_REG_SIZE)-1:0]    ring_arithmeric_rs1_reg;
reg[$clog2(ROB_SIZE)-1:0]         ring_arithmeric_rob_entry;
reg                               ring_arithmeric_rs1_received;
reg[XLEN-1:0]                     ring_arithmeric_rs1_value;
reg[XLEN-1:0]                     ring_arithmeric_pc;
reg[4:0]                          ring_arithmeric_opcode;
reg[2:0]                          ring_arithmeric_opcode_type;
reg                               ring_arithmeric_additional_info;
reg[XLEN-1:0]                     ring_arithmeric_rs2_value;
reg                               ring_arithmeric_rs2_received;
reg[$clog2(PHYS_REG_SIZE)-1:0]    ring_arithmeric_rs2_reg;

reg[2:0]                          ring_branch_functional_unit_num;
reg[$clog2(PHYS_REG_SIZE)-1:0]    ring_branch_rs1_reg;
reg[$clog2(ROB_SIZE)-1:0]         ring_branch_rob_entry;
reg                               ring_branch_rs1_received;
reg[XLEN-1:0]                     ring_branch_rs1_value;
reg[XLEN-1:0]                     ring_branch_pc;
reg[4:0]                          ring_branch_opcode;
reg[2:0]                          ring_branch_opcode_type;
reg                               ring_branch_additional_info;
reg[XLEN-1:0]                     ring_branch_rs2_value;
reg                               ring_branch_rs2_received;
reg[$clog2(PHYS_REG_SIZE)-1:0]    ring_branch_rs2_reg;

reg[2:0]                          ring_mul_div_functional_unit_num;
reg[$clog2(PHYS_REG_SIZE)-1:0]    ring_mul_div_rs1_reg;
reg[$clog2(ROB_SIZE)-1:0]         ring_mul_div_rob_entry;
reg                               ring_mul_div_rs1_received;
reg[XLEN-1:0]                     ring_mul_div_rs1_value;
reg[XLEN-1:0]                     ring_mul_div_pc;
reg[4:0]                          ring_mul_div_opcode;
reg[2:0]                          ring_mul_div_opcode_type;
reg                               ring_mul_div_additional_info;
reg[XLEN-1:0]                     ring_mul_div_rs2_value;
reg                               ring_mul_div_rs2_received;
reg[$clog2(PHYS_REG_SIZE)-1:0]    ring_mul_div_rs2_reg;

reg[2:0]                          ring_ld_st_functional_unit_num;
reg[$clog2(PHYS_REG_SIZE)-1:0]    ring_ld_st_rs1_reg;
reg[$clog2(ROB_SIZE)-1:0]         ring_ld_st_rob_entry;
reg                               ring_ld_st_rs1_received;
reg[XLEN-1:0]                     ring_ld_st_rs1_value;
reg[XLEN-1:0]                     ring_ld_st_pc;
reg[4:0]                          ring_ld_st_opcode;
reg[2:0]                          ring_ld_st_opcode_type;
reg                               ring_ld_st_additional_info;
reg[XLEN-1:0]                     ring_ld_st_rs2_value;
reg                               ring_ld_st_rs2_received;
reg[$clog2(PHYS_REG_SIZE)-1:0]    ring_ld_st_rs2_reg;


always @(posedge clk ) begin
    // Use 3-bit sat counter, clear your entry when 6, only zero at insertion
    if(valid_in) begin
        ring_uop_disperse_functional_unit_num               <= functional_unit_num;
        ring_uop_disperse_rs1_reg                           <= rob_entry;
        ring_uop_disperse_rob_entry                         <= uop_rs1_reg;
        ring_uop_disperse_rs1_received                      <= uop_rs1_received;
        ring_uop_disperse_rs1_value                         <= uop_rs1_value;
        ring_uop_disperse_pc                                <= uop_pc_in;
        ring_uop_disperse_opcode                            <= uop_opcode_in;
        ring_uop_disperse_opcode_type                       <= uop_opcode_type_in;
        ring_uop_disperse_additional_info                   <= uop_additional_info_in;
        ring_uop_disperse_rs2_value                         <= uop_rs2_value;
        ring_uop_disperse_rs2_received                      <= uop_rs2_received;
        ring_uop_disperse_rs2_reg                           <= uop_rs2_reg;
        
    end
    else begin
        ring_uop_disperse_functional_unit_num               <= 32'b0;                     
        ring_uop_disperse_rs1_reg                           <= {$clog2(PHYS_REG_SIZE){1'b0}};
        ring_uop_disperse_rob_entry                         <= {$clog2(PHYS_REG_SIZE){1'b0}};    
        ring_uop_disperse_rs1_received                      <= 1'b0;                      
        ring_uop_disperse_rs1_value                         <= {XLEN{1'b0}};                  
        ring_uop_disperse_pc                                <= {XLEN{1'b0}};                  
        ring_uop_disperse_opcode                            <= 5'b0;                      
        ring_uop_disperse_opcode_type                       <= 3'b0;                    
        ring_uop_disperse_additional_info                   <= 1'b0;                          
        ring_uop_disperse_rs2_value                         <= {XLEN{1'b0}};                
        ring_uop_disperse_rs2_received                      <= 1'b0;
        ring_uop_disperse_rs2_reg                           <= {$clog2(PHYS_REG_SIZE){1'b0}};
    end 
    
    if( ring_logical_functional_unit_num == 3'b001) begin
        logical_rob_entry           <= ring_logical_rs1_reg;
        logical_rs1_reg             <= ring_logical_rob_entry;
        logical_rs1_received        <= ring_logical_rs1_received;
        logical_rs1_value           <= ring_logical_rs1_value;
        logical_pc                  <= ring_logical_pc;
        logical_opcode              <= ring_logical_opcode;
        logical_opcode_type         <= ring_logical_opcode_type;
        logical_additional_info     <= ring_logical_additional_info;
        logical_rs2_value           <= ring_logical_rs2_value;
        logical_rs2_received        <= ring_logical_rs2_received;
        logical_rs2_reg             <= ring_logical_rs2_reg;
    end

    if( ring_arithmetic_functional_unit_num == 3'b010) begin
        arithmetic_rob_entry           <= ring_arithmeric_rs1_reg;
        arithmetic_rs1_reg             <= ring_arithmeric_rob_entry;
        arithmetic_rs1_received        <= ring_arithmeric_rs1_received;
        arithmetic_rs1_value           <= ring_arithmeric_rs1_value;
        arithmetic_pc                  <= ring_arithmeric_pc;
        arithmetic_opcode              <= ring_arithmeric_opcode;
        arithmetic_opcode_type         <= ring_arithmeric_opcode_type;
        arithmetic_additional_info     <= ring_arithmeric_additional_info;
        arithmetic_rs2_value           <= ring_arithmeric_rs2_value;
        arithmetic_rs2_received        <= ring_arithmeric_rs2_received;
        arithmetic_rs2_reg             <= ring_arithmeric_rs2_reg;
    end

    if( ring_branch_functional_unit_num == 3'b011) begin
        branch_rob_entry           <= ring_branch_rs1_reg;
        branch_rs1_reg             <= ring_branch_rob_entry;
        branch_rs1_received        <= ring_branch_rs1_received;
        branch_rs1_value           <= ring_branch_rs1_value;
        branch_pc                  <= ring_branch_pc;
        branch_opcode              <= ring_branch_opcode;
        branch_opcode_type         <= ring_branch_opcode_type;
        branch_additional_info     <= ring_branch_additional_info;
        branch_rs2_value           <= ring_branch_rs2_value;
        branch_rs2_received        <= ring_branch_rs2_received;
        branch_rs2_reg             <= ring_branch_rs2_reg;
    end

    if( ring_mul_div_functional_unit_num == 3'b101) begin
        mul_div_rob_entry           <= ring_mul_div_rs1_reg;
        mul_div_rs1_reg             <= ring_mul_div_rob_entry;
        mul_div_rs1_received        <= ring_mul_div_rs1_received;
        mul_div_rs1_value           <= ring_mul_div_rs1_value;
        mul_div_pc                  <= ring_mul_div_pc;
        mul_div_opcode              <= ring_mul_div_opcode;
        mul_div_opcode_type         <= ring_mul_div_opcode_type;
        mul_div_additional_info     <= ring_mul_div_additional_info;
        mul_div_rs2_value           <= ring_mul_div_rs2_value;
        mul_div_rs2_received        <= ring_mul_div_rs2_received;
        mul_div_rs2_reg             <= ring_mul_div_rs2_reg;
    end

    if( ring_ld_st_functional_unit_num == 3'b100) begin
        ld_st_rob_entry           <= ring_ld_st_rs1_reg;
        ld_st_rs1_reg             <= ring_ld_st_rob_entry;
        ld_st_rs1_received        <= ring_ld_st_rs1_received;
        ld_st_rs1_value           <= ring_ld_st_rs1_value;
        ld_st_pc                  <= ring_ld_st_pc;
        ld_st_opcode              <= ring_ld_st_opcode;
        ld_st_opcode_type         <= ring_ld_st_opcode_type;
        ld_st_additional_info     <= ring_ld_st_additional_info;
        ld_st_rs2_value           <= ring_ld_st_rs2_value;
        ld_st_rs2_received        <= ring_ld_st_rs2_received;
        ld_st_rs2_reg             <= ring_ld_st_rs2_reg;
    end
        

    // Finally progress ring
    //uop ->arithmetic->logical->branch->md->ld/st
    ring_arithmetic_functional_unit_num    <= ring_uop_disperse_functional_unit_num;
    ring_arithmetic_rs1_reg                <= ring_uop_disperse_rs1_reg;
    ring_arithmetic_rob_ent                <= ring_uop_disperse_rob_entry;
    ring_arithmetic_rs1_receive            <= ring_uop_disperse_rs1_received;
    ring_arithmetic_rs1_val                <= ring_uop_disperse_rs1_value;
    ring_arithmetic_pc                     <= ring_uop_disperse_pc_in;
    ring_arithmetic_opcode                 <= ring_uop_disperse_opcode_in;
    ring_arithmetic_opcode_type            <= ring_uop_disperse_opcode_type_in;
    ring_arithmetic_additional_info        <= ring_uop_disperse_additional_info_in;
    ring_arithmetic_rs2_val                <= ring_uop_disperse_rs2_value;
    ring_arithmetic_rs2_receive            <= ring_uop_disperse_rs2_received;
    ring_arithmetic_rs2_reg                <= ring_uop_disperse_rs2_reg;

    ring_logical_functional_unit_num    <= ring_arithmetic_functional_unit_num;
    ring_logical_rs1_reg                <= ring_arithmetic_rs1_reg;
    ring_logical_rob_ent                <= ring_arithmetic_rob_entry;
    ring_logical_rs1_receive            <= ring_arithmetic_rs1_received;
    ring_logical_rs1_val                <= ring_arithmetic_rs1_value;
    ring_logical_pc                     <= ring_arithmetic_pc_in;
    ring_logical_opcode                 <= ring_arithmetic_opcode_in;
    ring_logical_opcode_type            <= ring_arithmetic_opcode_type_in;
    ring_logical_additional_info        <= ring_arithmetic_additional_info_in;
    ring_logical_rs2_val                <= ring_arithmetic_rs2_value;
    ring_logical_rs2_receive            <= ring_arithmetic_rs2_received;
    ring_logical_rs2_reg                <= ring_arithmetic_rs2_reg;

    ring_branch_functional_unit_num    <= ring_logical_functional_unit_num;
    ring_branch_rs1_reg                <= ring_logical_rs1_reg;
    ring_branch_rob_ent                <= ring_logical_rob_entry;
    ring_branch_rs1_receive            <= ring_logical_rs1_received;
    ring_branch_rs1_val                <= ring_logical_rs1_value;
    ring_branch_pc                     <= ring_logical_pc_in;
    ring_branch_opcode                 <= ring_logical_opcode_in;
    ring_branch_opcode_type            <= ring_logical_opcode_type_in;
    ring_branch_additional_info        <= ring_logical_additional_info_in;
    ring_branch_rs2_val                <= ring_logical_rs2_value;
    ring_branch_rs2_receive            <= ring_logical_rs2_received;
    ring_branch_rs2_reg                <= ring_logical_rs2_reg;

    ring_mul_div_functional_unit_num    <= ring_branch_functional_unit_num;
    ring_mul_div_rs1_reg                <= ring_branch_rs1_reg;
    ring_mul_div_rob_ent                <= ring_branch_rob_entry;
    ring_mul_div_rs1_receive            <= ring_branch_rs1_received;
    ring_mul_div_rs1_val                <= ring_branch_rs1_value;
    ring_mul_div_pc                     <= ring_branch_pc_in;
    ring_mul_div_opcode                 <= ring_branch_opcode_in;
    ring_mul_div_opcode_type            <= ring_branch_opcode_type_in;
    ring_mul_div_additional_info        <= ring_branch_additional_info_in;
    ring_mul_div_rs2_val                <= ring_branch_rs2_value;
    ring_mul_div_rs2_receive            <= ring_branch_rs2_received;
    ring_mul_div_rs2_reg                <= ring_branch_rs2_reg;

    ring_ld_st_functional_unit_num    <= ring_mul_div_functional_unit_num;
    ring_ld_st_rs1_reg                <= ring_mul_div_rs1_reg;
    ring_ld_st_rob_ent                <= ring_mul_div_rob_entry;
    ring_ld_st_rs1_receive            <= ring_mul_div_rs1_received;
    ring_ld_st_rs1_val                <= ring_mul_div_rs1_value;
    ring_ld_st_pc                     <= ring_mul_div_pc_in;
    ring_ld_st_opcode                 <= ring_mul_div_opcode_in;
    ring_ld_st_opcode_type            <= ring_mul_div_opcode_type_in;
    ring_ld_st_additional_info        <= ring_mul_div_additional_info_in;
    ring_ld_st_rs2_val                <= ring_mul_div_rs2_value;
    ring_ld_st_rs2_receive            <= ring_mul_div_rs2_received;
    ring_ld_st_rs2_reg                <= ring_mul_div_rs2_reg;
    

end

endmodule