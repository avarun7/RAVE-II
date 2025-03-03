module tlb_TOP #(parameter XLEN = 32, CLC_WIDTH = 26)(
    input clk, rst,
    input [XLEN - 1 : 0] pc,
    input [CLC_WIDTH - 1 : 0] clc0_in,
    input [CLC_WIDTH - 1 : 0] clc1_in,
    input RW_in,            //check permissions
    input valid_in,         //if 1, then we are doing a memory request, else no exception should be thrown
    
    //outputs
    output pcd,             //don't cache MMIO
    output hit,
    output exception,
    output [2:0] exception_type,
    output [CLC_WIDTH - 1 : 0] clc0_paddr,
    output [CLC_WIDTH - 1 : 0] clc1_paddr,
    output clc0_paddr_valid,
    output clc1_paddr_valid
);

    // TLB entry structure
    parameter TLB_ENTRIES = 16;
    parameter TAG_WIDTH = 20;
    parameter PAGE_OFFSET = 12;
    
    // TLB entry fields
    reg [TAG_WIDTH-1:0] tlb_tags [TLB_ENTRIES-1:0];
    reg [XLEN-1:0] tlb_physical_pages [TLB_ENTRIES-1:0];
    reg tlb_valid [TLB_ENTRIES-1:0];
    reg tlb_cacheable [TLB_ENTRIES-1:0];
    reg [3:0] permission_bits [TLB_ENTRIES-1:0];
        // from lowest to highest priv: user, supervisor, reserved, machine
    
    // TLB lookup signals for both ports
    wire [TAG_WIDTH-1:0] lookup_tag_clc0, lookup_tag_clc1;
    wire [PAGE_OFFSET-1:0] page_offset_clc0, page_offset_clc1;
    reg [$clog2(TLB_ENTRIES)-1:0] match_index_clc0, match_index_clc1;
    reg tlb_hit_clc0, tlb_hit_clc1;
    
    // Extract tag and offset from both virtual addresses
    assign lookup_tag_clc0 = clc0_in[CLC_WIDTH-1:PAGE_OFFSET];
    assign page_offset_clc0 = clc0_in[PAGE_OFFSET-1:0];
    
    assign lookup_tag_clc1 = clc1_in[CLC_WIDTH-1:PAGE_OFFSET];
    assign page_offset_clc1 = clc1_in[PAGE_OFFSET-1:0];
    
    // TLB lookup logic for both ports
    integer i;
    always @(*) begin
        tlb_hit_clc0 = 1'b0;
        tlb_hit_clc1 = 1'b0;
        match_index_clc0 = 0;
        match_index_clc1 = 0;
        
        for(i = 0; i < TLB_ENTRIES; i = i + 1) begin
            // Port 1 (clc0_in) lookup
            if(tlb_valid[i] && (tlb_tags[i] == lookup_tag_clc0)) begin
                tlb_hit_clc0 = 1'b1;
                match_index_clc0 = i;
            end
            
            // Port 2 (clc1_in) lookup
            if(tlb_valid[i] && (tlb_tags[i] == lookup_tag_clc1)) begin
                tlb_hit_clc1 = 1'b1;
                match_index_clc1 = i;
            end
        end
    end
    
    // Output assignments for both ports
    assign hit = tlb_hit_clc0;  // Primary port hit
    assign exception = valid_in ? 
                      (tlb_hit_clc0 ? !(RW_in ? permission_bits[match_index_clc0][1] : permission_bits[match_index_clc0][0]) : 1'b1) :
                      1'b0;
    assign pcd = tlb_hit_clc0 ? !tlb_cacheable[match_index_clc0] : 1'b1;
    
    // Physical address calculation for both ports
    wire [CLC_WIDTH-1:0] translated_addr_clc0, translated_addr_clc1;
    
    assign translated_addr_clc0 = tlb_hit_clc0 ? 
        {tlb_physical_pages[match_index_clc0][XLEN-1:PAGE_OFFSET], page_offset_clc0} :
        {clc0_in[CLC_WIDTH-1:PAGE_OFFSET], page_offset_clc0};
        
    assign translated_addr_clc1 = tlb_hit_clc1 ? 
        {tlb_physical_pages[match_index_clc1][XLEN-1:PAGE_OFFSET], page_offset_clc1} :
        {clc1_in[CLC_WIDTH-1:PAGE_OFFSET], page_offset_clc1};
    
    // Output address assignments
    assign clc0_paddr = translated_addr_clc0;
    assign clc0_paddr_valid = tlb_hit_clc0;
    assign clc1_paddr = translated_addr_clc1;
    assign clc1_paddr_valid = tlb_hit_clc1;
    
    // TLB initialization and updates
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            // Reset all TLB entries
            for(i = 0; i < TLB_ENTRIES; i = i + 1) begin
                tlb_valid[i] <= 1'b0;
                tlb_tags[i] <= 0;
                tlb_physical_pages[i] <= 0;
                tlb_cacheable[i] <= 1'b0;
                permission_bits[i] <= 4'b0000;
            end
        end
        else begin
            //TODO: Page table walk and other logic
        end
    end

endmodule