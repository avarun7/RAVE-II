module ring_rsvs#(parameter XLEN=32, PHYS_REG_SIZE=256, ROB_SIZE=256, UOP_SIZE=16) (
    input clk, rst, valid_in,

    input[2:0]                               functional_unit_num,
    input[$clog2(ROB_SIZE)-1:0]              rob_entry,
    input[$clog2(PHYS_REG_SIZE)-1:0]         uop_rs1_reg,
    input                                    uop_rs1_received,
    input[XLEN-1:0]                          uop_rs1_value,
    input[XLEN-1:0]                          uop_pc_in,
    input[$clog2(UOP_SIZE)-1:0]               uop_uop_encoding,
    input[XLEN-1:0]                          uop_rs2_value,
    input                                    uop_rs2_received,
    input[$clog2(PHYS_REG_SIZE)-1:0]         uop_rs2_reg,
    input[$clog2(PHYS_REG_SIZE)-1:0]    uop_dest_reg,

    output reg[$clog2(PHYS_REG_SIZE)-1:0]    logical_rs1_reg,
    output reg[$clog2(ROB_SIZE)-1:0]         logical_rob_entry,
    output reg                               logical_rs1_received,
    output reg[XLEN-1:0]                     logical_rs1_value,
    output reg[XLEN-1:0]                     logical_pc,
    output reg[$clog2(UOP_SIZE)-1:0]          logical_uop_encoding,
    output reg[XLEN-1:0]                     logical_rs2_value,
    output reg                               logical_rs2_received,
    output reg[$clog2(PHYS_REG_SIZE)-1:0]    logical_rs2_reg,
    output reg[$clog2(PHYS_REG_SIZE)-1:0]    logical_dest_reg,
    output reg                               logical_valid_out,

    output reg[$clog2(PHYS_REG_SIZE)-1:0]    arithmetic_rs1_reg,
    output reg[$clog2(ROB_SIZE)-1:0]         arithmetic_rob_entry,
    output reg                               arithmetic_rs1_received,
    output reg[XLEN-1:0]                     arithmetic_rs1_value,
    output reg[XLEN-1:0]                     arithmetic_pc,
    output reg[$clog2(UOP_SIZE)-1:0]          arithmetic_uop_encoding,
    output reg[XLEN-1:0]                     arithmetic_rs2_value,
    output reg                               arithmetic_rs2_received,
    output reg[$clog2(PHYS_REG_SIZE)-1:0]    arithmetic_rs2_reg,
    output reg[$clog2(PHYS_REG_SIZE)-1:0]    arithmetic_dest_reg,
    output reg                               arithmetic_valid_out,

    output reg[$clog2(PHYS_REG_SIZE)-1:0]    branch_rs1_reg,
    output reg[$clog2(ROB_SIZE)-1:0]         branch_rob_entry,
    output reg                               branch_rs1_received,
    output reg[XLEN-1:0]                     branch_rs1_value,
    output reg[XLEN-1:0]                     branch_pc,
    output reg[$clog2(UOP_SIZE)-1:0]          branch_uop_encoding,
    output reg[XLEN-1:0]                     branch_rs2_value,
    output reg                               branch_rs2_received,
    output reg[$clog2(PHYS_REG_SIZE)-1:0]    branch_rs2_reg,
    output reg[$clog2(PHYS_REG_SIZE)-1:0]    branch_dest_reg,
    output reg                               branch_valid_out,
    // TODO: Add branch offset 

    output reg[$clog2(PHYS_REG_SIZE)-1:0]    mul_div_rs1_reg,
    output reg[$clog2(ROB_SIZE)-1:0]         mul_div_rob_entry,
    output reg                               mul_div_rs1_received,
    output reg[XLEN-1:0]                     mul_div_rs1_value,
    output reg[XLEN-1:0]                     mul_div_pc,
    output reg[$clog2(UOP_SIZE)-1:0]          mul_div_uop_encoding,
    output reg[XLEN-1:0]                     mul_div_rs2_value,
    output reg                               mul_div_rs2_received,
    output reg[$clog2(PHYS_REG_SIZE)-1:0]    mul_div_rs2_reg,
    output reg[$clog2(PHYS_REG_SIZE)-1:0]    mul_div_dest_reg,
    output reg                               mul_div_valid_out,

    output reg[$clog2(PHYS_REG_SIZE)-1:0]    ld_st_rs1_reg,
    output reg[$clog2(ROB_SIZE)-1:0]         ld_st_rob_entry,
    output reg                               ld_st_rs1_received,
    output reg[XLEN-1:0]                     ld_st_rs1_value,
    output reg[XLEN-1:0]                     ld_st_pc,
    output reg[$clog2(UOP_SIZE)-1:0]          ld_st_uop_encoding,
    output reg[XLEN-1:0]                     ld_st_rs2_value,
    output reg                               ld_st_rs2_received,
    output reg[$clog2(PHYS_REG_SIZE)-1:0]    ld_st_rs2_reg,
    output reg[$clog2(PHYS_REG_SIZE)-1:0]    ld_st_dest_reg,
    output reg                               ld_st_valid_out
);
// TODO: Add in offset for the branch unit

reg[2:0]                          ring_uop_disperse_functional_unit_num;
reg[$clog2(PHYS_REG_SIZE)-1:0]    ring_uop_disperse_rs1_reg;
reg[$clog2(ROB_SIZE)-1:0]         ring_uop_disperse_rob_entry;
reg                               ring_uop_disperse_rs1_received;
reg[XLEN-1:0]                     ring_uop_disperse_rs1_value;
reg[XLEN-1:0]                     ring_uop_disperse_pc;
reg[$clog2(UOP_SIZE)-1:0]          ring_uop_uop_encoding;
reg[XLEN-1:0]                     ring_uop_disperse_rs2_value;
reg                               ring_uop_disperse_rs2_received;
reg[$clog2(PHYS_REG_SIZE)-1:0]    ring_uop_disperse_rs2_reg;
reg[$clog2(PHYS_REG_SIZE)-1:0]    ring_uop_disperse_dest_reg;

reg[2:0]                          ring_logical_functional_unit_num;
reg[$clog2(PHYS_REG_SIZE)-1:0]    ring_logical_rs1_reg;
reg[$clog2(ROB_SIZE)-1:0]         ring_logical_rob_entry;
reg                               ring_logical_rs1_received;
reg[XLEN-1:0]                     ring_logical_rs1_value;
reg[XLEN-1:0]                     ring_logical_pc;
reg[$clog2(UOP_SIZE)-1:0]          ring_logical_uop_encoding;
reg[XLEN-1:0]                     ring_logical_rs2_value;
reg                               ring_logical_rs2_received;
reg[$clog2(PHYS_REG_SIZE)-1:0]    ring_logical_rs2_reg;
reg[$clog2(PHYS_REG_SIZE)-1:0]    ring_logical_dest_reg;

reg[2:0]                          ring_arithmetic_functional_unit_num;
reg[$clog2(PHYS_REG_SIZE)-1:0]    ring_arithmetic_rs1_reg;
reg[$clog2(ROB_SIZE)-1:0]         ring_arithmetic_rob_entry;
reg                               ring_arithmetic_rs1_received;
reg[XLEN-1:0]                     ring_arithmetic_rs1_value;
reg[XLEN-1:0]                     ring_arithmetic_pc;
reg[$clog2(UOP_SIZE)-1:0]          ring_arithmetic_uop_encoding;
reg[XLEN-1:0]                     ring_arithmetic_rs2_value;
reg                               ring_arithmetic_rs2_received;
reg[$clog2(PHYS_REG_SIZE)-1:0]    ring_arithmetic_rs2_reg;
reg[$clog2(PHYS_REG_SIZE)-1:0]    ring_arithmetic_dest_reg;

reg[2:0]                          ring_branch_functional_unit_num;
reg[$clog2(PHYS_REG_SIZE)-1:0]    ring_branch_rs1_reg;
reg[$clog2(ROB_SIZE)-1:0]         ring_branch_rob_entry;
reg                               ring_branch_rs1_received;
reg[XLEN-1:0]                     ring_branch_rs1_value;
reg[XLEN-1:0]                     ring_branch_pc;
reg[$clog2(UOP_SIZE)-1:0]          ring_branch_uop_encoding;
reg[XLEN-1:0]                     ring_branch_rs2_value;
reg                               ring_branch_rs2_received;
reg[$clog2(PHYS_REG_SIZE)-1:0]    ring_branch_rs2_reg;
reg[$clog2(PHYS_REG_SIZE)-1:0]    ring_branch_dest_reg;

reg[2:0]                          ring_mul_div_functional_unit_num;
reg[$clog2(PHYS_REG_SIZE)-1:0]    ring_mul_div_rs1_reg;
reg[$clog2(ROB_SIZE)-1:0]         ring_mul_div_rob_entry;
reg                               ring_mul_div_rs1_received;
reg[XLEN-1:0]                     ring_mul_div_rs1_value;
reg[XLEN-1:0]                     ring_mul_div_pc;
reg[$clog2(UOP_SIZE)-1:0]          ring_mul_div_uop_encoding;
reg[XLEN-1:0]                     ring_mul_div_rs2_value;
reg                               ring_mul_div_rs2_received;
reg[$clog2(PHYS_REG_SIZE)-1:0]    ring_mul_div_rs2_reg;
reg[$clog2(PHYS_REG_SIZE)-1:0]    ring_mul_div_dest_reg;

reg[2:0]                          ring_ld_st_functional_unit_num;
reg[$clog2(PHYS_REG_SIZE)-1:0]    ring_ld_st_rs1_reg;
reg[$clog2(ROB_SIZE)-1:0]         ring_ld_st_rob_entry;
reg                               ring_ld_st_rs1_received;
reg[XLEN-1:0]                     ring_ld_st_rs1_value;
reg[XLEN-1:0]                     ring_ld_st_pc;
reg[$clog2(UOP_SIZE)-1:0]          ring_ld_st_uop_encoding;
reg[XLEN-1:0]                     ring_ld_st_rs2_value;
reg                               ring_ld_st_rs2_received;
reg[$clog2(PHYS_REG_SIZE)-1:0]    ring_ld_st_rs2_reg;
reg[$clog2(PHYS_REG_SIZE)-1:0]    ring_ld_st_dest_reg;


always @(posedge clk ) begin
    // Use 3-bit sat counter, clear your entry when 6, only zero at insertion
    if(valid_in) begin
        ring_uop_disperse_functional_unit_num               <= functional_unit_num;
        ring_uop_disperse_rs1_reg                           <= uop_rs1_reg;
        ring_uop_disperse_rob_entry                         <= rob_entry;
        ring_uop_disperse_rs1_received                      <= uop_rs1_received;
        ring_uop_disperse_rs1_value                         <= uop_rs1_value;
        ring_uop_disperse_pc                                <= uop_pc_in;
        ring_uop_uop_encoding                               <= uop_uop_encoding;
        ring_uop_disperse_rs2_value                         <= uop_rs2_value;
        ring_uop_disperse_rs2_received                      <= uop_rs2_received;
        ring_uop_disperse_rs2_reg                           <= uop_rs2_reg;
        ring_uop_disperse_dest_reg                          <= uop_dest_reg;
        
    end
    else begin
        ring_uop_disperse_functional_unit_num               <= 32'b0;                     
        ring_uop_disperse_rs1_reg                           <= {$clog2(PHYS_REG_SIZE){1'b0}};
        ring_uop_disperse_rob_entry                         <= {$clog2(PHYS_REG_SIZE){1'b0}};    
        ring_uop_disperse_rs1_received                      <= 1'b0;                      
        ring_uop_disperse_rs1_value                         <= {XLEN{1'b0}};                  
        ring_uop_disperse_pc                                <= {XLEN{1'b0}};                  
        ring_uop_uop_encoding                               <= {$clog2(UOP_SIZE){1'b0}};  
        ring_uop_disperse_rs2_value                         <= {XLEN{1'b0}};                
        ring_uop_disperse_rs2_received                      <= 1'b0;
        ring_uop_disperse_rs2_reg                           <= {$clog2(PHYS_REG_SIZE){1'b0}};
        ring_uop_disperse_dest_reg                          <= {$clog2(PHYS_REG_SIZE){1'b0}};
    end 
    
    if( ring_logical_functional_unit_num == 3'b001) begin
        logical_rob_entry           <= ring_logical_rob_entry;
        logical_rs1_reg             <= ring_logical_rs1_reg;
        logical_rs1_received        <= ring_logical_rs1_received;
        logical_rs1_value           <= ring_logical_rs1_value;
        logical_pc                  <= ring_logical_pc;
        logical_uop_encoding        <= ring_logical_uop_encoding;
        logical_rs2_value           <= ring_logical_rs2_value;
        logical_rs2_received        <= ring_logical_rs2_received;
        logical_rs2_reg             <= ring_logical_rs2_reg;
        logical_dest_reg            <= ring_logical_dest_reg;
        logical_valid_out           <= 1'b1;
    end else logical_valid_out      <= 1'b0;

    if( ring_arithmetic_functional_unit_num == 3'b010) begin
        arithmetic_rob_entry           <= ring_arithmetic_rob_entry;
        arithmetic_rs1_reg             <= ring_arithmetic_rs1_reg;
        arithmetic_rs1_received        <= ring_arithmetic_rs1_received;
        arithmetic_rs1_value           <= ring_arithmetic_rs1_value;
        arithmetic_pc                  <= ring_arithmetic_pc;
        arithmetic_uop_encoding        <= ring_arithmetic_uop_encoding;
        arithmetic_rs2_value           <= ring_arithmetic_rs2_value;
        arithmetic_rs2_received        <= ring_arithmetic_rs2_received;
        arithmetic_rs2_reg             <= ring_arithmetic_rs2_reg;
        arithmetic_dest_reg            <= ring_arithmetic_dest_reg;
        arithmetic_valid_out           <= 1'b1;
    end else arithmetic_valid_out      <= 1'b0;

    if( ring_branch_functional_unit_num == 3'b011) begin
        branch_rob_entry           <= ring_branch_rob_entry;
        branch_rs1_reg             <= ring_branch_rs1_reg;
        branch_rs1_received        <= ring_branch_rs1_received;
        branch_rs1_value           <= ring_branch_rs1_value;
        branch_pc                  <= ring_branch_pc;
        branch_uop_encoding        <= ring_branch_uop_encoding;
        branch_rs2_value           <= ring_branch_rs2_value;
        branch_rs2_received        <= ring_branch_rs2_received;
        branch_rs2_reg             <= ring_branch_rs2_reg;
        branch_dest_reg            <= ring_branch_dest_reg;
        branch_valid_out           <= 1'b1;
    end else branch_valid_out      <= 1'b0;

    if( ring_mul_div_functional_unit_num == 3'b100) begin
        mul_div_rob_entry           <= ring_mul_div_rob_entry;
        mul_div_rs1_reg             <= ring_mul_div_rs1_reg;
        mul_div_rs1_received        <= ring_mul_div_rs1_received;
        mul_div_rs1_value           <= ring_mul_div_rs1_value;
        mul_div_pc                  <= ring_mul_div_pc;
        mul_div_uop_encoding        <= ring_mul_div_uop_encoding;
        mul_div_rs2_value           <= ring_mul_div_rs2_value;
        mul_div_rs2_received        <= ring_mul_div_rs2_received;
        mul_div_rs2_reg             <= ring_mul_div_rs2_reg;
        mul_div_dest_reg            <= ring_mul_div_dest_reg;
        mul_div_valid_out           <= 1'b1;
    end else mul_div_valid_out      <= 1'b0;

    if( ring_ld_st_functional_unit_num == 3'b101) begin
        ld_st_rob_entry           <= ring_ld_st_rob_entry;
        ld_st_rs1_reg             <= ring_ld_st_rs1_reg;
        ld_st_rs1_received        <= ring_ld_st_rs1_received;
        ld_st_rs1_value           <= ring_ld_st_rs1_value;
        ld_st_pc                  <= ring_ld_st_pc;
        ld_st_uop_encoding        <= ring_ld_st_uop_encoding;
        ld_st_rs2_value           <= ring_ld_st_rs2_value;
        ld_st_rs2_received        <= ring_ld_st_rs2_received;
        ld_st_rs2_reg             <= ring_ld_st_rs2_reg;
        ld_st_dest_reg            <= ring_ld_st_dest_reg;
        ld_st_valid_out           <= 1'b1;
    end else ld_st_valid_out      <= 1'b0;
        

    // Finally progress ring
    //uop ->arithmetic->logical->branch->md->ld/st
    ring_arithmetic_functional_unit_num     <= ring_uop_disperse_functional_unit_num;
    ring_arithmetic_rs1_reg                 <= ring_uop_disperse_rs1_reg;
    ring_arithmetic_rob_entry               <= ring_uop_disperse_rob_entry;
    ring_arithmetic_rs1_received            <= ring_uop_disperse_rs1_received;
    ring_arithmetic_rs1_value               <= ring_uop_disperse_rs1_value;
    ring_arithmetic_pc                      <= ring_uop_disperse_pc;
    ring_arithmetic_uop_encoding            <= ring_uop_uop_encoding;
    ring_arithmetic_rs2_value               <= ring_uop_disperse_rs2_value;
    ring_arithmetic_rs2_received            <= ring_uop_disperse_rs2_received;
    ring_arithmetic_rs2_reg                 <= ring_uop_disperse_rs2_reg;
    ring_arithmetic_dest_reg                <= ring_uop_disperse_dest_reg;

    ring_logical_functional_unit_num    <= ring_arithmetic_functional_unit_num;
    ring_logical_rs1_reg                <= ring_arithmetic_rs1_reg;
    ring_logical_rob_entry              <= ring_arithmetic_rob_entry;
    ring_logical_rs1_received           <= ring_arithmetic_rs1_received;
    ring_logical_rs1_value              <= ring_arithmetic_rs1_value;
    ring_logical_pc                     <= ring_arithmetic_pc;
    ring_logical_uop_encoding           <= ring_arithmetic_uop_encoding;
    ring_logical_rs2_value              <= ring_arithmetic_rs2_value;
    ring_logical_rs2_received           <= ring_arithmetic_rs2_received;
    ring_logical_rs2_reg                <= ring_arithmetic_rs2_reg;
    ring_logical_dest_reg               <= ring_arithmetic_dest_reg;

    ring_branch_functional_unit_num    <= ring_logical_functional_unit_num;
    ring_branch_rs1_reg                <= ring_logical_rs1_reg;
    ring_branch_rob_entry              <= ring_logical_rob_entry;
    ring_branch_rs1_received           <= ring_logical_rs1_received;
    ring_branch_rs1_value              <= ring_logical_rs1_value;
    ring_branch_pc                     <= ring_logical_pc;
    ring_branch_uop_encoding           <= ring_logical_uop_encoding;
    ring_branch_rs2_value              <= ring_logical_rs2_value;
    ring_branch_rs2_received           <= ring_logical_rs2_received;
    ring_branch_rs2_reg                <= ring_logical_rs2_reg;
    ring_branch_dest_reg               <= ring_logical_dest_reg;

    ring_mul_div_functional_unit_num    <= ring_branch_functional_unit_num;
    ring_mul_div_rs1_reg                <= ring_branch_rs1_reg;
    ring_mul_div_rob_entry              <= ring_branch_rob_entry;
    ring_mul_div_rs1_received           <= ring_branch_rs1_received;
    ring_mul_div_rs1_value              <= ring_branch_rs1_value;
    ring_mul_div_pc                     <= ring_branch_pc;
    ring_mul_div_uop_encoding           <= ring_branch_uop_encoding;
    ring_mul_div_rs2_value              <= ring_branch_rs2_value;
    ring_mul_div_rs2_received           <= ring_branch_rs2_received;
    ring_mul_div_rs2_reg                <= ring_branch_rs2_reg;
    ring_mul_div_dest_reg               <= ring_branch_dest_reg;

    ring_ld_st_functional_unit_num    <= ring_mul_div_functional_unit_num;
    ring_ld_st_rs1_reg                <= ring_mul_div_rs1_reg;
    ring_ld_st_rob_entry              <= ring_mul_div_rob_entry;
    ring_ld_st_rs1_received           <= ring_mul_div_rs1_received;
    ring_ld_st_rs1_value              <= ring_mul_div_rs1_value;
    ring_ld_st_pc                     <= ring_mul_div_pc;
    ring_ld_st_uop_encoding           <= ring_mul_div_uop_encoding;
    ring_ld_st_rs2_value              <= ring_mul_div_rs2_value;
    ring_ld_st_rs2_received           <= ring_mul_div_rs2_received;
    ring_ld_st_rs2_reg                <= ring_mul_div_rs2_reg;
    ring_ld_st_dest_reg               <= ring_mul_div_dest_reg;

end

endmodule