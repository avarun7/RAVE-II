module tlb_TOP #(parameter XLEN = 32, CLC_WIDTH = 26)(
    input clk, rst,
    input [XLEN - 1 : 0] pc,
    input [CLC_WIDTH - 1 : 0] clc_in,
    input [CLC_WIDTH - 1 : 0] clc_nl_in,
    input RW_in,            //check permissions
    input valid_in,         //if 1, then we are doing a memory request, else no exception should be thrown

    output pcd,             //don't cache MMIO
    output hit,
    output exception,
    output [CLC_WIDTH - 1 : 0] clc_paddr,
    output clc_paddr_valid,
    output [CLC_WIDTH - 1 : 0] clc_nl_paddr,
    output clc_nl_paddr_valid
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
    reg [3:0] permission_bits [TLB_ENTRIES-1:0]; // Read, Write, Execute, User
    
    // TLB lookup signals for both ports
    wire [TAG_WIDTH-1:0] lookup_tag_clc, lookup_tag_clc_nl;
    wire [PAGE_OFFSET-1:0] page_offset_clc, page_offset_clc_nl;
    reg [$clog2(TLB_ENTRIES)-1:0] match_index_clc, match_index_clc_nl;
    reg tlb_hit_clc, tlb_hit_clc_nl;
    
    // Extract tag and offset from both virtual addresses
    assign lookup_tag_clc = clc_in[CLC_WIDTH-1:PAGE_OFFSET];
    assign page_offset_clc = clc_in[PAGE_OFFSET-1:0];
    
    assign lookup_tag_clc_nl = clc_nl_in[CLC_WIDTH-1:PAGE_OFFSET];
    assign page_offset_clc_nl = clc_nl_in[PAGE_OFFSET-1:0];
    
    // TLB lookup logic for both ports
    integer i;
    always @(*) begin
        tlb_hit_clc = 1'b0;
        tlb_hit_clc_nl = 1'b0;
        match_index_clc = 0;
        match_index_clc_nl = 0;
        
        for(i = 0; i < TLB_ENTRIES; i = i + 1) begin
            // Port 1 (clc_in) lookup
            if(tlb_valid[i] && (tlb_tags[i] == lookup_tag_clc)) begin
                tlb_hit_clc = 1'b1;
                match_index_clc = i;
            end
            
            // Port 2 (clc_nl_in) lookup
            if(tlb_valid[i] && (tlb_tags[i] == lookup_tag_clc_nl)) begin
                tlb_hit_clc_nl = 1'b1;
                match_index_clc_nl = i;
            end
        end
    end
    
    // Output assignments for both ports
    assign hit = tlb_hit_clc;  // Primary port hit
    assign exception = valid_in ? 
                      (tlb_hit_clc ? !(RW_in ? permission_bits[match_index_clc][1] : permission_bits[match_index_clc][0]) : 1'b1) :
                      1'b0;
    assign pcd = tlb_hit_clc ? !tlb_cacheable[match_index_clc] : 1'b1;
    
    // Physical address calculation for both ports
    wire [CLC_WIDTH-1:0] translated_addr_clc, translated_addr_clc_nl;
    
    assign translated_addr_clc = tlb_hit_clc ? 
        {tlb_physical_pages[match_index_clc][XLEN-1:PAGE_OFFSET], page_offset_clc} :
        {clc_in[CLC_WIDTH-1:PAGE_OFFSET], page_offset_clc};
        
    assign translated_addr_clc_nl = tlb_hit_clc_nl ? 
        {tlb_physical_pages[match_index_clc_nl][XLEN-1:PAGE_OFFSET], page_offset_clc_nl} :
        {clc_nl_in[CLC_WIDTH-1:PAGE_OFFSET], page_offset_clc_nl};
    
    // Output address assignments
    assign clc_paddr = translated_addr_clc;
    assign clc_paddr_valid = tlb_hit_clc;
    assign clc_nl_paddr = translated_addr_clc_nl;
    assign clc_nl_paddr_valid = tlb_hit_clc_nl;
    
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