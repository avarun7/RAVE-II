// https://electronics.stackexchange.com/questions/266587/finding-an-empty-slot-in-an-array-of-registers
// Use of pencoders for access

module rsv #(parameter XLEN=32, SIZE=16, PHYS_REG_SIZE=256, ROB_SIZE=265, UOP_SIZE=16, RSV_NUM=0)( // Assume mapper handles SEXT
    input clk, rst, valid_in,

    // Organized as such within the RSV
    input[$clog2(ROB_SIZE)-1:0]         rob_entry_in,
    input[$clog2(PHYS_REG_SIZE)-1:0]    rs1_reg,
    input                               rs1_received,
    input[XLEN-1:0]                     rs1_value,
    input[XLEN-1:0]                     pc_in,
    input[$clog2(UOP_SIZE)-1:0]          uop_encoding_in,
    input[XLEN-1:0]                     rs2_value,
    input                               rs2_received,
    input[$clog2(PHYS_REG_SIZE)-1:0]    rs2_reg,
    input[$clog2(PHYS_REG_SIZE)-1:0]    dest_reg_in,

    /*   Update Vars, from ring from ROB   */
    input                                   update_valid,
    input[$clog2(PHYS_REG_SIZE)-1:0]        update_reg,
    input[XLEN-1:0]                         update_val,
    
    output reg[$clog2(ROB_SIZE)-1:0]        rob_entry,
    output reg[XLEN-1:0]                    rs1,
    output reg[XLEN-1:0]                    rs2,
    output reg[XLEN-1:0]                    pc,
    output reg[$clog2(UOP_SIZE)-1:0]         uop_encoding,
    output reg                              valid_out,
    output reg[$clog2(PHYS_REG_SIZE)-1:0]   dest_reg

);

reg[SIZE-1:0]                     free_list;
wire[SIZE-1:0]                    available;
wire[SIZE-1:0]                    rs1_update;
wire[SIZE-1:0]                    rs2_update;
wire[$clog2(SIZE)-1:0]            dispatch;
wire[$clog2(SIZE)-1:0]            allocate;
wire                              none_dispatch;
wire                              none_allocate;

reg[$clog2(ROB_SIZE)-1:0]         rob_queue                [0:SIZE-1];
reg[$clog2(PHYS_REG_SIZE)-1:0]    rs1_reg_queue            [0:SIZE-1];
reg                               rs1_received_queue       [0:SIZE-1];
reg[XLEN-1:0]                     rs1_value_queue          [0:SIZE-1];
reg[XLEN-1:0]                     pc_queue                 [0:SIZE-1];
reg[$clog2(UOP_SIZE)-1:0]         uop_encoding_queue       [0:SIZE-1];
reg[XLEN-1:0]                     rs2_value_queue          [0:SIZE-1];
reg                               rs2_received_queue       [0:SIZE-1];
reg[$clog2(PHYS_REG_SIZE)-1:0]    rs2_reg_queue            [0:SIZE-1];
reg[$clog2(PHYS_REG_SIZE)-1:0]    dest_reg_queue           [0:SIZE-1];


pencoder #(.WIDTH(SIZE)) out(.a(available), .o(dispatch), .none(none_dispatch));
pencoder #(.WIDTH(SIZE)) in(.a(free_list), .o(allocate), .none(none_allocate));

initial begin
    free_list = {SIZE{1'b1}};
    for(i = 0; i < SIZE; i = i + 1) begin
        rs1_received_queue[i] <= 1'b0;
        rs2_received_queue[i] <= 1'b0;
    end
end

integer unsigned i;

genvar k;
generate
    for(k = 0; k < SIZE; k = k + 1) begin
        assign available[k] = rs2_received_queue[k] & rs1_received_queue[k];

        assign rs1_update[k] = (update_reg == rs1_reg_queue[k]) & !rs1_received_queue[k];

        assign rs2_update[k] = (update_reg == rs2_reg_queue[k]) & !rs2_received_queue[k];
    end
endgenerate
always@(negedge rst) begin
    for(i = 0; i < SIZE; i = i + 1) begin
        rob_queue[i]            <= {$clog2(ROB_SIZE){1'b0}};
        rs1_reg_queue[i]        <= {$clog2(PHYS_REG_SIZE){1'b0}};
        rs1_received_queue[i]   <= 1'b0;                       
        rs1_value_queue[i]      <= {XLEN{1'b0}};
        pc_queue[i]             <= {XLEN{1'b0}};
        uop_encoding_queue[i]   <= {$clog2(UOP_SIZE){1'b0}};
        rs2_value_queue[i]      <= {XLEN{1'b0}};
        rs2_received_queue[i]   <= 1'b0;                          
        rs2_reg_queue[i]        <= {$clog2(PHYS_REG_SIZE){1'b0}};
        dest_reg_queue[i]       <= {$clog2(PHYS_REG_SIZE){1'b0}};
    end
end

always @(posedge clk) begin
    
    if(!none_dispatch)begin
        // Dispatch to fu
        rob_entry                       <= rob_queue[dispatch];
        rs1                             <= rs1_value_queue[dispatch];
        pc                              <= pc_queue[dispatch];
        uop_encoding                    <= uop_encoding_queue[dispatch];
        rs2                             <= rs2_value_queue[dispatch];
        rs2_received_queue[dispatch]    <= 1'b0;
        free_list[dispatch]             <= 1'b1;
        valid_out                       <= 1'b1;
        dest_reg                        <= dest_reg_queue[dispatch];
    end else valid_out                  <= 1'b0;
    // TODO: Needs double pointer method, no idea how imma do that
    if(!none_allocate & valid_in) begin
        // Write to FU
        rob_queue[allocate]             <= rob_entry_in;
        rs1_reg_queue[allocate]         <= rs1_reg;
        rs1_received_queue[allocate]    <= rs1_received;
        rs1_value_queue[allocate]       <= rs1_value;
        pc_queue[allocate]              <= pc_in;
        uop_encoding_queue[allocate]    <= uop_encoding_in;
        rs2_value_queue[allocate]       <= rs2_value;
        rs2_received_queue[allocate]    <= rs2_received;
        rs2_reg_queue[allocate]         <= rs2_reg;
        dest_reg_queue[allocate]        <= dest_reg_in;
        free_list[allocate]             <= 1'b0;                                                        
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

`ifdef DEBUG
integer cycle_cnt;
integer fullfile, sparsefile, retirefile;


initial begin
    cycle_cnt = 0;
    if(RSV_NUM == 0) begin
        fullfile = $fopen("./out/arithmetic_rsv.dump");
        sparsefile = $fopen("./out/arithmetic_rsv_sparse.dump");
    end
    else if(RSV_NUM == 1) begin
        fullfile = $fopen("./out/logical_rsv.dump");
        sparsefile = $fopen("./out/logical_rsv_sparse.dump");
    end 
    else if(RSV_NUM == 2) begin
        fullfile = $fopen("./out/branch_rsv.dump");
        sparsefile = $fopen("./out/branch_rsv_sparse.dump");
    end 
    else if(RSV_NUM == 3) begin
        fullfile = $fopen("./out/mul_div_rsv.dump");
        sparsefile = $fopen("./out/mul_div_rsv_sparse.dump");
    end
    else if(RSV_NUM == 4) begin
        fullfile = $fopen("./out/ld_st_rsv.dump");
        sparsefile = $fopen("./out/ld_st_rsv_sparse.dump");
    end
    
end

always@(posedge clk) begin
    $fdisplay(fullfile, "cycle number: %d", cycle_cnt);
    $fdisplay(fullfile, "[====RSV UPDATES====]");
    $fdisplay(fullfile, "UPDATE: %b\t--\t Reg: %0d \t--\t Value: %0d",update_valid, update_reg, update_val);
    $fdisplay(fullfile, "FREE_LIST: %b", free_list);
    $fdisplay(fullfile, "AVAILABLE: %b", available);
    $fdisplay(fullfile, "[====RSV ENTRIES====]");
    for(i=0; i<SIZE; i = i+1) begin
        $fdisplay(fullfile, "RSV%0d\t= \t ROB: %0d ,\tRSV_1[REG:%0d\tRDY:\t%0d,VAL:\t%0d],\tPC: %0d\t ,\UOP:%0d\t= RSV_2[VAL:%0d\tRDY:\t%0d,REG:\t%0d] \t DEST: %0d",
        i,rob_queue[i], rs1_reg_queue[i], rs1_received_queue[i], rs1_value_queue[i], pc_queue[i], uop_encoding_queue[i], rs2_value_queue[i], rs2_received_queue[i], rs2_reg_queue[i], dest_reg_queue[i]);
    end

    $fdisplay(fullfile, "\n\n");

    if(update_valid || (!none_allocate & valid_in) || !none_dispatch) begin
        $fdisplay(sparsefile, "cycle number: %d", cycle_cnt);
        if(!none_allocate & valid_in) begin
            $fdisplay(sparsefile, "[====RSV UPDATES====]");
            $fdisplay(sparsefile, "UPDATE: %b\t--\t Reg: %0d \t--\t Value: %0d",update_valid, update_reg, update_val);
        end
        $fdisplay(sparsefile, "FREE_LIST: %b", free_list);
        $fdisplay(sparsefile, "AVAILABLE: %b", available);
        $fdisplay(sparsefile, "[====RSV ENTRIES====]");
        for(i=0; i<SIZE; i = i+1) begin
            $fdisplay(sparsefile, "RSV%0d\t= \t ROB: %0d ,\tRSV_1[REG:%0d\tRDY:\t%0d,VAL:\t%0d],\tPC: %0d\t ,\UOP:%0d\t= RSV_2[VAL:%0d\tRDY:\t%0d,REG:\t%0d] \t DEST: %0d",
            i,rob_queue[i], rs1_reg_queue[i], rs1_received_queue[i], rs1_value_queue[i], pc_queue[i], uop_encoding_queue[i], rs2_value_queue[i], rs2_received_queue[i], rs2_reg_queue[i], dest_reg_queue[i]);
        end
        $fdisplay(sparsefile, "\n\n");
    end

    cycle_cnt = cycle_cnt + 1;
end
`endif



endmodule