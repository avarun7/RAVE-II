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
    output reg  [CACHE_LINE_SIZE-1:0] data_out [0:3], // 2D array output: 4 entries
    output reg  [3:0]             valid_out      // Valid bits for each entry
);

    // Internal buffer holds the 4 cache lines.
    reg [CACHE_LINE_SIZE-1:0] buffer [0:3];
    reg [3:0] valid_bits;
    integer i;

    // Sequential logic for handling load and invalidate operations.
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            valid_bits <= 4'b0000; // Clear valid bits on reset.
        end else begin
            for (i = 0; i < 4; i = i + 1) begin
                // Load the data if the load signal is asserted,
                // the entry is not already valid, and no invalidate is asserted.
                if (load[i] && !valid_bits[i] && !invalidate[i]) begin
                    // Use data_in_even for even-indexed slots and data_in_odd for odd-indexed slots.
                    if (i % 2 == 0)
                        buffer[i] <= data_in_even;
                    else
                        buffer[i] <= data_in_odd;
                    valid_bits[i] <= 1'b1;
                end
                // Invalidate the entry if requested.
                if (invalidate[i])
                    valid_bits[i] <= 1'b0;
            end
        end
    end

    // Combinatorial logic assigns the internal buffer to the multi-dimensional output.
    always @(*) begin
        data_out[0] = buffer[0];
        data_out[1] = buffer[1];
        data_out[2] = buffer[2];
        data_out[3] = buffer[3];
        valid_out = valid_bits;
    end

endmodule
