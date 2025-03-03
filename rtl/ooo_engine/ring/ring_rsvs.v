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
    output reg[XLEN-1:0]                     logical_pc_in,
    output reg[4:0]                          logical_opcode_in,
    output reg[2:0]                          logical_opcode_type_in,
    output reg                               logical_additional_info_in,
    output reg[XLEN-1:0]                     logical_rs2_value,
    output reg                               logical_rs2_received,
    output reg[$clog2(PHYS_REG_SIZE)-1:0]    logical_rs2_reg,

    output reg[$clog2(PHYS_REG_SIZE)-1:0]    arithmetic_rs1_reg,
    output reg[$clog2(ROB_SIZE)-1:0]         arithmetic_rob_entry,
    output reg                               arithmetic_rs1_received,
    output reg[XLEN-1:0]                     arithmetic_rs1_value,
    output reg[XLEN-1:0]                     arithmetic_pc_in,
    output reg[4:0]                          arithmetic_opcode_in,
    output reg[2:0]                          arithmetic_opcode_type_in,
    output reg                               arithmetic_additional_info_in,
    output reg[XLEN-1:0]                     arithmetic_rs2_value,
    output reg                               arithmetic_rs2_received,
    output reg[$clog2(PHYS_REG_SIZE)-1:0]    arithmetic_rs2_reg,

    output reg[$clog2(PHYS_REG_SIZE)-1:0]    branch_rs1_reg,
    output reg[$clog2(ROB_SIZE)-1:0]         branch_rob_entry,
    output reg                               branch_rs1_received,
    output reg[XLEN-1:0]                     branch_rs1_value,
    output reg[XLEN-1:0]                     branch_pc_in,
    output reg[4:0]                          branch_opcode_in,
    output reg[2:0]                          branch_opcode_type_in,
    output reg                               branch_additional_info_in,
    output reg[XLEN-1:0]                     branch_rs2_value,
    output reg                               branch_rs2_received,
    output reg[$clog2(PHYS_REG_SIZE)-1:0]    branch_rs2_reg,

    output reg[$clog2(PHYS_REG_SIZE)-1:0]    mul_div_rs1_reg,
    output reg[$clog2(ROB_SIZE)-1:0]         mul_div_rob_entry,
    output reg                               mul_div_rs1_received,
    output reg[XLEN-1:0]                     mul_div_rs1_value,
    output reg[XLEN-1:0]                     mul_div_pc_in,
    output reg[4:0]                          mul_div_opcode_in,
    output reg[2:0]                          mul_div_opcode_type_in,
    output reg                               mul_div_additional_info_in,
    output reg[XLEN-1:0]                     mul_div_rs2_value,
    output reg                               mul_div_rs2_received,
    output reg[$clog2(PHYS_REG_SIZE)-1:0]    mul_div_rs2_reg,

    output reg[$clog2(PHYS_REG_SIZE)-1:0]    ld_st_rs1_reg,
    output reg[$clog2(ROB_SIZE)-1:0]         ld_st_rob_entry,
    output reg                               ld_st_rs1_received,
    output reg[XLEN-1:0]                     ld_st_rs1_value,
    output reg[XLEN-1:0]                     ld_st_pc_in,
    output reg[4:0]                          ld_st_opcode_in,
    output reg[2:0]                          ld_st_opcode_type_in,
    output reg                               ld_st_additional_info_in,
    output reg[XLEN-1:0]                     ld_st_rs2_value,
    output reg                               ld_st_rs2_received,
    output reg[$clog2(PHYS_REG_SIZE)-1:0]    ld_st_rs2_reg
);
// TODO: Add in offset for the branch unit

reg[($clog2(ROB_SIZE)+2*$clog2(PHYS_REG_SIZE)+3*XLEN+13):0] logical_ring; 
reg[($clog2(ROB_SIZE)+2*$clog2(PHYS_REG_SIZE)+3*XLEN+13):0] arithmetic_ring;
reg[($clog2(ROB_SIZE)+2*$clog2(PHYS_REG_SIZE)+3*XLEN+13):0] branch_ring;
reg[($clog2(ROB_SIZE)+2*$clog2(PHYS_REG_SIZE)+3*XLEN+13):0] ld_st_ring;
reg[($clog2(ROB_SIZE)+2*$clog2(PHYS_REG_SIZE)+3*XLEN+13):0] mul_div_ring;
reg[($clog2(ROB_SIZE)+2*$clog2(PHYS_REG_SIZE)+3*XLEN+13):0] uop_disperse;


always @(posedge clk ) begin
    // Use 3-bit sat counter, clear your entry when 6, only zero at insertion
    if(valid_in) begin
        uop_disperse[($clog2(ROB_SIZE)+2*$clog2(PHYS_REG_SIZE)+3*XLEN+13):($clog2(ROB_SIZE)+2*$clog2(PHYS_REG_SIZE)+3*XLEN+11)]   <= functional_unit_num;
        uop_disperse[($clog2(ROB_SIZE)+2*$clog2(PHYS_REG_SIZE)+3*XLEN+10):($clog2(PHYS_REG_SIZE)+3*XLEN+11)]                      <= rob_entry;
        uop_disperse[(2*$clog2(PHYS_REG_SIZE)+3*XLEN+10):($clog2(PHYS_REG_SIZE)+3*XLEN+11)]                                       <= uop_rs1_reg;
        uop_disperse[($clog2(PHYS_REG_SIZE)+3*XLEN+10)]                                                                           <= uop_rs1_received;
        uop_disperse[($clog2(PHYS_REG_SIZE)+3*XLEN+9):($clog2(PHYS_REG_SIZE)+2*XLEN+10)]                                          <= uop_rs1_value;
        uop_disperse[($clog2(PHYS_REG_SIZE)+2*XLEN+9):($clog2(PHYS_REG_SIZE)+XLEN+10)]                                            <= uop_pc_in;
        uop_disperse[($clog2(PHYS_REG_SIZE)+XLEN+9):($clog2(PHYS_REG_SIZE)+XLEN+5)]                                               <= uop_opcode_in;
        uop_disperse[($clog2(PHYS_REG_SIZE)+XLEN+4):($clog2(PHYS_REG_SIZE)+XLEN+2)]                                               <= uop_opcode_type_in;
        uop_disperse[($clog2(PHYS_REG_SIZE)+XLEN+1)]                                                                              <= uop_additional_info_in;
        uop_disperse[($clog2(PHYS_REG_SIZE)+XLEN):($clog2(PHYS_REG_SIZE)+1)]                                                      <= uop_rs2_value;
        uop_disperse[$clog2(PHYS_REG_SIZE)]                                                                                       <= uop_rs2_received;
        uop_disperse[($clog2(PHYS_REG_SIZE)-1):0]                                                                                 <= uop_rs2_reg;
        
    end
    else uop_disperse <= {(2*$clog2(PHYS_REG_SIZE)+3*XLEN + 10){1'b0}};
    
    if( logical_ring[($clog2(ROB_SIZE)+2*$clog2(PHYS_REG_SIZE)+3*XLEN+13):($clog2(ROB_SIZE)+2*$clog2(PHYS_REG_SIZE)+3*XLEN+11)] == 3'b001) begin
        logical_rob_entry           <= logical_ring[($clog2(ROB_SIZE)+2*$clog2(PHYS_REG_SIZE)+3*XLEN+10):(2*$clog2(PHYS_REG_SIZE)+3*XLEN+11)];
        logical_rs1_reg             <= logical_ring[(2*$clog2(PHYS_REG_SIZE)+3*XLEN+10):($clog2(PHYS_REG_SIZE)+3*XLEN+11)];
        logical_rs1_received        <= logical_ring[($clog2(PHYS_REG_SIZE)+3*XLEN+10)];
        logical_rs1_value           <= logical_ring[($clog2(PHYS_REG_SIZE)+3*XLEN+9):($clog2(PHYS_REG_SIZE)+2*XLEN+10)];
        logical_pc_in               <= logical_ring[($clog2(PHYS_REG_SIZE)+2*XLEN+9):($clog2(PHYS_REG_SIZE)+XLEN+10)];
        logical_opcode_in           <= logical_ring[($clog2(PHYS_REG_SIZE)+XLEN+9):($clog2(PHYS_REG_SIZE)+XLEN+5)];
        logical_opcode_type_in      <= logical_ring[($clog2(PHYS_REG_SIZE)+XLEN+4):($clog2(PHYS_REG_SIZE)+XLEN+2)];
        logical_additional_info_in  <= logical_ring[($clog2(PHYS_REG_SIZE)+XLEN+1)];
        logical_rs2_value           <= logical_ring[($clog2(PHYS_REG_SIZE)+XLEN):($clog2(PHYS_REG_SIZE)+1)];
        logical_rs2_received        <= logical_ring[$clog2(PHYS_REG_SIZE)];
        logical_rs2_reg             <= logical_ring[($clog2(PHYS_REG_SIZE)-1):0];
    end

    if( arithmetic_ring[($clog2(ROB_SIZE)+2*$clog2(PHYS_REG_SIZE)+3*XLEN+13):($clog2(ROB_SIZE)+2*$clog2(PHYS_REG_SIZE)+3*XLEN+11)] == 3'b010) begin
        arithmetic_rob_entry           <= arithmetic_ring[($clog2(ROB_SIZE)+2*$clog2(PHYS_REG_SIZE)+3*XLEN+10):(2*$clog2(PHYS_REG_SIZE)+3*XLEN+11)];
        arithmetic_rs1_reg             <= arithmetic_ring[(2*$clog2(PHYS_REG_SIZE)+3*XLEN+10):($clog2(PHYS_REG_SIZE)+3*XLEN+11)];
        arithmetic_rs1_received        <= arithmetic_ring[($clog2(PHYS_REG_SIZE)+3*XLEN+10)];
        arithmetic_rs1_value           <= arithmetic_ring[($clog2(PHYS_REG_SIZE)+3*XLEN+9):($clog2(PHYS_REG_SIZE)+2*XLEN+10)];
        arithmetic_pc_in               <= arithmetic_ring[($clog2(PHYS_REG_SIZE)+2*XLEN+9):($clog2(PHYS_REG_SIZE)+XLEN+10)];
        arithmetic_opcode_in           <= arithmetic_ring[($clog2(PHYS_REG_SIZE)+XLEN+9):($clog2(PHYS_REG_SIZE)+XLEN+5)];
        arithmetic_opcode_type_in      <= arithmetic_ring[($clog2(PHYS_REG_SIZE)+XLEN+4):($clog2(PHYS_REG_SIZE)+XLEN+2)];
        arithmetic_additional_info_in  <= arithmetic_ring[($clog2(PHYS_REG_SIZE)+XLEN+1)];
        arithmetic_rs2_value           <= arithmetic_ring[($clog2(PHYS_REG_SIZE)+XLEN):($clog2(PHYS_REG_SIZE)+1)];
        arithmetic_rs2_received        <= arithmetic_ring[$clog2(PHYS_REG_SIZE)];
        arithmetic_rs2_reg             <= arithmetic_ring[($clog2(PHYS_REG_SIZE)-1):0];
    end

    if( branch_ring[($clog2(ROB_SIZE)+2*$clog2(PHYS_REG_SIZE)+3*XLEN+13):($clog2(ROB_SIZE)+2*$clog2(PHYS_REG_SIZE)+3*XLEN+11)] == 3'b011) begin
        branch_rob_entry           <= branch_ring[($clog2(ROB_SIZE)+2*$clog2(PHYS_REG_SIZE)+3*XLEN+10):(2*$clog2(PHYS_REG_SIZE)+3*XLEN+11)];
        branch_rs1_reg             <= branch_ring[(2*$clog2(PHYS_REG_SIZE)+3*XLEN+10):($clog2(PHYS_REG_SIZE)+3*XLEN+11)];
        branch_rs1_received        <= branch_ring[($clog2(PHYS_REG_SIZE)+3*XLEN+10)];
        branch_rs1_value           <= branch_ring[($clog2(PHYS_REG_SIZE)+3*XLEN+9):($clog2(PHYS_REG_SIZE)+2*XLEN+10)];
        branch_pc_in               <= branch_ring[($clog2(PHYS_REG_SIZE)+2*XLEN+9):($clog2(PHYS_REG_SIZE)+XLEN+10)];
        branch_opcode_in           <= branch_ring[($clog2(PHYS_REG_SIZE)+XLEN+9):($clog2(PHYS_REG_SIZE)+XLEN+5)];
        branch_opcode_type_in      <= branch_ring[($clog2(PHYS_REG_SIZE)+XLEN+4):($clog2(PHYS_REG_SIZE)+XLEN+2)];
        branch_additional_info_in  <= branch_ring[($clog2(PHYS_REG_SIZE)+XLEN+1)];
        branch_rs2_value           <= branch_ring[($clog2(PHYS_REG_SIZE)+XLEN):($clog2(PHYS_REG_SIZE)+1)];
        branch_rs2_received        <= branch_ring[$clog2(PHYS_REG_SIZE)];
        branch_rs2_reg             <= branch_ring[($clog2(PHYS_REG_SIZE)-1):0];
    end

    if( ld_st_ring[($clog2(ROB_SIZE)+2*$clog2(PHYS_REG_SIZE)+3*XLEN+13):($clog2(ROB_SIZE)+2*$clog2(PHYS_REG_SIZE)+3*XLEN+11)] == 3'b100) begin
        ld_st_rob_entry           <= ld_st_ring[($clog2(ROB_SIZE)+2*$clog2(PHYS_REG_SIZE)+3*XLEN+10):(2*$clog2(PHYS_REG_SIZE)+3*XLEN+11)];
        ld_st_rs1_reg             <= ld_st_ring[(2*$clog2(PHYS_REG_SIZE)+3*XLEN+10):($clog2(PHYS_REG_SIZE)+3*XLEN+11)];
        ld_st_rs1_received        <= ld_st_ring[($clog2(PHYS_REG_SIZE)+3*XLEN+10)];
        ld_st_rs1_value           <= ld_st_ring[($clog2(PHYS_REG_SIZE)+3*XLEN+9):($clog2(PHYS_REG_SIZE)+2*XLEN+10)];
        ld_st_pc_in               <= ld_st_ring[($clog2(PHYS_REG_SIZE)+2*XLEN+9):($clog2(PHYS_REG_SIZE)+XLEN+10)];
        ld_st_opcode_in           <= ld_st_ring[($clog2(PHYS_REG_SIZE)+XLEN+9):($clog2(PHYS_REG_SIZE)+XLEN+5)];
        ld_st_opcode_type_in      <= ld_st_ring[($clog2(PHYS_REG_SIZE)+XLEN+4):($clog2(PHYS_REG_SIZE)+XLEN+2)];
        ld_st_additional_info_in  <= ld_st_ring[($clog2(PHYS_REG_SIZE)+XLEN+1)];
        ld_st_rs2_value           <= ld_st_ring[($clog2(PHYS_REG_SIZE)+XLEN):($clog2(PHYS_REG_SIZE)+1)];
        ld_st_rs2_received        <= ld_st_ring[$clog2(PHYS_REG_SIZE)];
        ld_st_rs2_reg             <= ld_st_ring[($clog2(PHYS_REG_SIZE)-1):0];
    end
        
    if( mul_div_ring[($clog2(ROB_SIZE)+2*$clog2(PHYS_REG_SIZE)+3*XLEN+13):($clog2(ROB_SIZE)+2*$clog2(PHYS_REG_SIZE)+3*XLEN+11)] == 3'b101) begin
        mul_div_rob_entry           <= mul_div_ring[($clog2(ROB_SIZE)+2*$clog2(PHYS_REG_SIZE)+3*XLEN+10):(2*$clog2(PHYS_REG_SIZE)+3*XLEN+11)];
        mul_div_rs1_reg             <= mul_div_ring[(2*$clog2(PHYS_REG_SIZE)+3*XLEN+10):($clog2(PHYS_REG_SIZE)+3*XLEN+11)];
        mul_div_rs1_received        <= mul_div_ring[($clog2(PHYS_REG_SIZE)+3*XLEN+10)];
        mul_div_rs1_value           <= mul_div_ring[($clog2(PHYS_REG_SIZE)+3*XLEN+9):($clog2(PHYS_REG_SIZE)+2*XLEN+10)];
        mul_div_pc_in               <= mul_div_ring[($clog2(PHYS_REG_SIZE)+2*XLEN+9):($clog2(PHYS_REG_SIZE)+XLEN+10)];
        mul_div_opcode_in           <= mul_div_ring[($clog2(PHYS_REG_SIZE)+XLEN+9):($clog2(PHYS_REG_SIZE)+XLEN+5)];
        mul_div_opcode_type_in      <= mul_div_ring[($clog2(PHYS_REG_SIZE)+XLEN+4):($clog2(PHYS_REG_SIZE)+XLEN+2)];
        mul_div_additional_info_in  <= mul_div_ring[($clog2(PHYS_REG_SIZE)+XLEN+1)];
        mul_div_rs2_value           <= mul_div_ring[($clog2(PHYS_REG_SIZE)+XLEN):($clog2(PHYS_REG_SIZE)+1)];
        mul_div_rs2_received        <= mul_div_ring[$clog2(PHYS_REG_SIZE)];
        mul_div_rs2_reg             <= mul_div_ring[($clog2(PHYS_REG_SIZE)-1):0];
    end

    // Finally progress ring
    //uop ->arithmetic->logical->branch->md->ld/st
    arithmetic_ring <= uop_disperse;
    logical_ring    <= arithmetic_ring;
    branch_ring     <= logical_ring;
    ld_st_ring      <= branch_ring;
    mul_div_ring    <= ld_st_ring;

end

endmodule