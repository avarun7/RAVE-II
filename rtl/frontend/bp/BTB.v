module branch_target_buffer (
    input         clk,
    input         reset,
    // Lookup interface: branch address provided during fetch.
    input  [31:0] branch_addr,
    output reg    predict_taken,    // Output: 1 if BTB hit (predict taken), else 0.
    output reg [31:0] target_addr,  // Output: predicted branch target address.
    
    // Update interface: used on branch resolution.
    input         update,           // When high, update the BTB entry.
    input  [31:0] update_addr,      // Branch address corresponding to the update.
    input  [31:0] actual_target,    // Resolved target address.
    input         branch_taken      // Actual branch outcome (1 if taken, 0 if not).
);

  // Number of BTB entries: 256 (direct-mapped)
  localparam BTB_ENTRIES = 256;

  // Storage for BTB entries:
  // Each entry stores a valid bit, a tag, and the target address.
  // Using branch_addr[7:0] as the index:
  reg        valid   [0:BTB_ENTRIES-1];
  reg [23:0] tag_array [0:BTB_ENTRIES-1]; // Tag = update_addr[31:8]
  reg [31:0] target_array [0:BTB_ENTRIES-1];

  // Compute lookup index and tag from the branch address.
  wire [7:0] lookup_index = branch_addr[7:0];
  wire [23:0] lookup_tag  = branch_addr[31:8];

  // Lookup Process:
  // On each clock cycle, the BTB performs a synchronous lookup.
  // If the entry is valid and the tag matches, the branch is predicted taken,
  // and the target address is provided.
  always @(posedge clk) begin
    if (reset) begin
      predict_taken <= 1'b0;
      target_addr   <= 32'b0;
    end else begin
      if (valid[lookup_index] && (tag_array[lookup_index] == lookup_tag)) begin
         predict_taken <= 1'b1;
         target_addr   <= target_array[lookup_index];
      end else begin
         predict_taken <= 1'b0;
         target_addr   <= 32'b0;  // Optionally, could be set to branch_addr + 4 (fall-through)
      end
    end
  end

  // Update Process:
  // When a branch is resolved (update is high), the BTB is updated.
  // If the branch was taken, the BTB entry is updated with the target address;
  // if not taken, the entry is invalidated.
  integer i;
  always @(posedge clk) begin
    if (reset) begin
      // Invalidate all BTB entries on reset.
      for (i = 0; i < BTB_ENTRIES; i = i + 1) begin
         valid[i]       <= 1'b0;
         tag_array[i]   <= 24'b0;
         target_array[i] <= 32'b0;
      end
    end else if (update) begin
      // Use the same indexing as lookup.
      if (branch_taken) begin
         valid[update_addr[7:0]]       <= 1'b1;
         tag_array[update_addr[7:0]]     <= update_addr[31:8];
         target_array[update_addr[7:0]]  <= actual_target;
      end else begin
         // If the branch was not taken, we invalidate the BTB entry.
         valid[update_addr[7:0]] <= 1'b0;
      end
    end
  end

endmodule
