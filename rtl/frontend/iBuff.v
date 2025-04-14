module IBuff
#(
    parameter CACHE_LINE_SIZE = 128 // Default cache line size (bits)
)
(
    input                         clk,           // Clock signal
    input                         rst,           // Reset signal
    input       [3:0]             load,          // Load signals for each entry
    input       [3:0]             invalidate,    // Invalidate signals for each entry
    input       [CACHE_LINE_SIZE-1:0] data_in_even,  // Even cache line input 
    input       [CACHE_LINE_SIZE-1:0] data_in_odd,   // Odd cache line input
    output reg  [CACHE_LINE_SIZE-1:0] data_out0,    // Output for entry 0
    output reg  [CACHE_LINE_SIZE-1:0] data_out1,    // Output for entry 1
    output reg  [CACHE_LINE_SIZE-1:0] data_out2,    // Output for entry 2
    output reg  [CACHE_LINE_SIZE-1:0] data_out3,    // Output for entry 3
    output reg  [3:0]             valid_out      // Valid bits for each entry
);

    // Internal storage for the 4 entries
    reg [CACHE_LINE_SIZE-1:0] buffer [0:3];
    reg [3:0] valid_bits;
    integer i;

    // Sequential logic: load and invalidate operations.
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            valid_bits <= 4'b0000; // Clear all valid bits on reset.
        end else begin
            for (i = 0; i < 4; i = i + 1) begin
                // Only load if the load signal is asserted, the entry is not valid,
                // and there is no invalidate requested.
                if (load[i] && !valid_bits[i] && !invalidate[i]) begin
                    // Depending on slot parity, choose the appropriate data.
                    if (i % 2 == 0)
                        buffer[i] <= data_in_even;
                    else
                        buffer[i] <= data_in_odd;
                    valid_bits[i] <= 1'b1;
                end
                // Handle invalidate: if requested, clear the valid bit.
                if (invalidate[i])
                    valid_bits[i] <= 1'b0;
            end
        end
    end

    // Combinatorial logic for output assignment:
    always @(*) begin
        data_out0 = buffer[0];
        data_out1 = buffer[1];
        data_out2 = buffer[2];
        data_out3 = buffer[3];
        valid_out = valid_bits;
    end

endmodule