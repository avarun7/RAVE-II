module IBuff #(
    parameter CACHE_LINE_SIZE = 128 // Default cache line size (bits)
)(
    input  logic clk,                     // Clock signal
    input  logic rst,                     // Reset signal
    input  logic [3:0] load,              // Load signals for each entry
    input  logic [CACHE_LINE_SIZE-1:0] data_in [3:0], // Data inputs for each entry
    output logic [CACHE_LINE_SIZE-1:0] data_out [3:0], // Outputs for all 4 entries
    output logic [3:0] valid_out          // Valid bits for each entry
);

    // Internal storage for the 4 entries
    logic [CACHE_LINE_SIZE-1:0] buffer [3:0];
    logic [3:0] valid_bits;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            valid_bits <= 4'b0000; // Reset valid bits
        end else begin
            for (int i = 0; i < 4; i++) begin
                if (load[i]) begin
                    buffer[i] <= data_in[i]; // Load data into buffer
                    valid_bits[i] <= 1'b1;   // Set valid bit
                end
            end
        end
    end

    // Assign outputs
    assign data_out = buffer;
    assign valid_out = valid_bits;

endmodule
