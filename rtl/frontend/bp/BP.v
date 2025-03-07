module saturating_counter (
    input         clk,      // Clock signal
    input         reset,    // Synchronous reset
    input         enable,   // Enable update for this counter
    input         taken,    // Branch outcome for update: 1 for taken, 0 for not taken
    output reg [1:0] counter // 2-bit saturating counter value
);

  always @(posedge clk) begin
    if (reset)
      counter <= 2'b10;  // Initialize to "weakly taken"
    else if (enable) begin
      if (taken) begin
        // Increment unless at maximum (2'b11)
        if (counter < 2'b11)
          counter <= counter + 1;
      end
      else begin
        // Decrement unless at minimum (2'b00)
        if (counter > 2'b00)
          counter <= counter - 1;
      end
    end
  end

endmodule


module gshare_predictor (
    input         clk,           // Clock signal
    input         reset,         // Synchronous reset
    input  [31:0] branch_addr,   // Branch address (assumed 32-bit)
    input         branch_outcome,// Actual branch outcome: 1 = taken, 0 = not taken
    output        predict_taken  // Prediction: 1 = taken, 0 = not taken
);

  // Global History Register (8 bits)
  reg [7:0] GHR;

  // Compute index into the PHT: XOR lower 8 bits of branch_addr with GHR.
  wire [7:0] index;
  assign index = branch_addr[7:0] ^ GHR;

  // Pattern History Table: 256 entries of 2-bit saturating counters.
  // Each counter is updated only when its index matches the computed index.
  wire [1:0] pht [0:255];

  genvar i;
  generate
    for (i = 0; i < 256; i = i + 1) begin : pht_entries
      saturating_counter sc (
          .clk(clk),
          .reset(reset),
          // Only update the counter whose index matches the computed index.
          .enable((index == i) ? 1'b1 : 1'b0),
          .taken(branch_outcome),
          .counter(pht[i])
      );
    end
  endgenerate

  // The prediction is based on the MSB of the saturating counter at the indexed entry.
  // (Conventional design: states 2'b10 and 2'b11 predict taken.)
  assign predict_taken = pht[index][1];

  // Update the Global History Register:
  // Shift in the most recent branch outcome.
  always @(posedge clk) begin
    if (reset)
      GHR <= 8'b0;
    else
      GHR <= {GHR[6:0], branch_outcome};
  end

endmodule
