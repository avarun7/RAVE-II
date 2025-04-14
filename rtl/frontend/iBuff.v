module IBuff #(
    parameter CACHE_LINE_SIZE = 128 // Default cache line size (bits)
)
(
    input  logic                      clk,           // Clock signal
    input  logic                      rst,           // Reset signal
    input  logic [3:0]                load,          // Load signals for each entry
    input  logic [3:0]                invalidate,    // Invalidate signals for each entry
    input  logic [CACHE_LINE_SIZE-1:0] data_in_even,  // Even cache line input 
    input  logic [CACHE_LINE_SIZE-1:0] data_in_odd,   // Odd cache line input
    output logic [CACHE_LINE_SIZE-1:0] data_out [3:0],  // Outputs for all 4 entries
    output logic [3:0]                valid_out      // Valid bits for each entry
);

    // Internal storage for the 4 entries
    logic [CACHE_LINE_SIZE-1:0] buffer [3:0];
    logic [3:0] valid_bits;

    integer i;
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            valid_bits <= 4'b0000; // Clear all valid bits on reset.
        end else begin
            for (i = 0; i < 4; i = i + 1) begin
                // Only load if the load signal is asserted, the entry is not valid,
                // and there is no invalidate requested.
                if (load[i] && !valid_bits[i] && !invalidate[i]) begin
                    // Depending on slot parity, choose the appropriate data.
                    buffer[i] <= (i % 2 == 0) ? data_in_even : data_in_odd;
                    valid_bits[i] <= 1'b1;
                end
                // Handle invalidate: if requested, clear the valid bit.
                if (invalidate[i]) begin
                    valid_bits[i] <= 1'b0;
                end
            end
        end
    end

    // Continuous assignment of outputs:
    always @(*) begin
        for (i = 0; i < 4; i = i + 1) begin
            data_out[i] = buffer[i];
        end
        valid_out = valid_bits;
    end

endmodule
