module sat_cnt (cnt,clk,rst);
input clk,rst;
output [2:0]cnt;

reg [2:0]cnt;
wire [2:0]next_cnt;

assign next_cnt = cnt + 1'b1;  //Just increment by 1

always @ (posedge clk or posedge rst)   
begin
    if(rst) begin
    cnt <= 3'b0;
    end
    else begin
        if(!(cnt == 3'b111))
            cnt <= next_cnt;
    end
end

endmodule

module ring_rob#(parameter XLEN=32, PHYS_REG_SIZE=256, RF_QUEUE=8) (
    input clk, rst,

    input                                   logical_update,
    // input                                   logical_rf_pass,
    input[$clog2(PHYS_REG_SIZE)-1:0]        logical_update_reg,
    input[XLEN-1:0]                         logical_update_val,

    input                                   arithmetic_update,
    // input                                   arithmetic_rf_pass,
    input[$clog2(PHYS_REG_SIZE)-1:0]        arithmetic_update_reg,
    input[XLEN-1:0]                         arithmetic_update_val, 

    input                                   branch_update,
    // input                                   branch_rf_pass,
    input[$clog2(PHYS_REG_SIZE)-1:0]        branch_update_reg,
    input[XLEN-1:0]                         branch_update_val, 

    input                                   ld_st_update,
    // input                                   ld_st_rf_pass,
    input[$clog2(PHYS_REG_SIZE)-1:0]        ld_st_update_reg,
    input[XLEN-1:0]                         ld_st_update_val, 

    input                                   md_div_update,
    // input                                   md_div_rf_pass,
    input[$clog2(PHYS_REG_SIZE)-1:0]        md_div_update_reg,
    input[XLEN-1:0]                         md_div_update_val,

    output reg                              out_logical_valid,
    output reg[$clog2(PHYS_REG_SIZE)-1:0]   out_logical_update_reg,
    output reg[XLEN-1:0]                    out_logical_update_val,

    output reg                              out_arithmetic_valid,
    output reg[$clog2(PHYS_REG_SIZE)-1:0]   out_arithmetic_update_reg,
    output reg[XLEN-1:0]                    out_arithmetic_update_val, 

    output reg                              out_branch_valid,
    output reg[$clog2(PHYS_REG_SIZE)-1:0]   out_branch_update_reg,
    output reg[XLEN-1:0]                    out_branch_update_val, 

    output reg                              out_ld_st_valid,
    output reg[$clog2(PHYS_REG_SIZE)-1:0]   out_ld_st_update_reg,
    output reg[XLEN-1:0]                    out_ld_st_update_val, 

    output reg                              out_md_div_valid,
    output reg[$clog2(PHYS_REG_SIZE)-1:0]   out_md_div_update_reg,
    output reg[XLEN-1:0]                    out_md_div_update_val

);

reg[($clog2(PHYS_REG_SIZE)+XLEN):0] logical_ring;
reg[($clog2(PHYS_REG_SIZE)+XLEN):0] arithmetic_ring;
reg[($clog2(PHYS_REG_SIZE)+XLEN):0] branch_ring;
reg[($clog2(PHYS_REG_SIZE)+XLEN):0] ld_st_ring;
reg[($clog2(PHYS_REG_SIZE)+XLEN):0] md_div_ring;
reg[($clog2(PHYS_REG_SIZE)+XLEN):0] rob_ring;

reg[($clog2(PHYS_REG_SIZE)+XLEN):0] rf_queue [0:RF_QUEUE];
reg[$clog2(RF_QUEUE)-1:0]           head;
reg[$clog2(RF_QUEUE)-1:0]           tail;

always @(posedge clk ) begin
    // Use 3-bit sat counter, clear your entry when 6, only zero at insertion
    if(logical_ring[0] & logical_update);
        //stall the FU
    else if(logical_update) begin
        logical_ring[($clog2(PHYS_REG_SIZE)+XLEN):XLEN] = logical_update_reg;
        logical_ring[XLEN:1] = logical_update_val;
        logical_ring[0] = 1;
    end

    if(arithmetic_ring[0] & arithmetic_update);
        //stall the FU
    else if(arithmetic_update) begin
        arithmetic_ring[($clog2(PHYS_REG_SIZE)+XLEN):XLEN] = logical_update_reg;
        arithmetic_ring[XLEN:1] = logical_update_val;
        arithmetic_ring[0] = 1;
    end

    if(branch_ring[0] & branch_update);
        //stall the FU
    else if(branch_update) begin
        branch_ring[($clog2(PHYS_REG_SIZE)+XLEN):XLEN] = logical_update_reg;
        branch_ring[XLEN:1] = logical_update_val;
        branch_ring[0] = 1;
    end

    if(ld_st_ring[0] & ld_st_update);
        //stall the FU
    else if(ld_st_update) begin
        ld_st_ring[($clog2(PHYS_REG_SIZE)+XLEN):XLEN] = logical_update_reg;
        ld_st_ring[XLEN:1] = logical_update_val;
        ld_st_ring[0] = 1;
    end

    if(logical_ring[0] & logical_update);
        //stall the FU
    else if(logical_update) begin
        logical_ring[($clog2(PHYS_REG_SIZE)+XLEN):XLEN] = logical_update_reg;
        logical_ring[XLEN:1] = logical_update_val;
        logical_ring[0] = 1;
    end

    if(logical_ring[0] & logical_update);
        //stall the FU
    else if(logical_update) begin
        logical_ring[($clog2(PHYS_REG_SIZE)+XLEN):XLEN] = logical_update_reg;
        logical_ring[XLEN:1] = logical_update_val;
        logical_ring[0] = 1;
    end


    // Finally progress ring
    //rob ->arithmetic->logical->branch->md->ld/st
    arithmetic_ring <= rob_ring;
    logical_ring    <= arithmetic_ring;
    branch_ring     <= logical_ring;
    md_div_ring     <= branch_ring;
    ld_st_ring      <= md_div_ring;
    //TODO: Assign rob_ring

    


end

endmodule