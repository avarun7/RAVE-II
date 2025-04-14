module d1_TOP #(parameter XLEN = 32) (
    input clk, rst,

    // inputs
    input exception_in,
    input [511:0] IBuff_in,
    input [3:0] IBuff_valid_in,   // New input: valid bits from IBuff (one per 128-bit region)
    input [31:0] pc_in,
    input resteer,
    // input [XLEN - 1:0] resteer_target_BR,
    // input [XLEN - 1:0] resteer_target_ROB,

    // input bp_update,        // 1b
    // input bp_update_taken,  // 1b
    // input [XLEN - 1:0] bp_update_target,  // 32b
    // input [9:0] bp_update_bhr,

    // outputs
    output [XLEN - 1:0] pc,
    output exception_out,
    output [2:0] opcode_format, // TODO: further decoding logic
    output [XLEN - 1:0] instruction_out,
    output instruction_valid,   // New output: valid flag from the rotator
    output compressed_inst,
    
    output resteer_D1,
    output [XLEN - 1:0] resteer_target_D1,
    output resteer_taken,
    
    output ras_push,
    output ras_pop,
    output [XLEN - 1:0] ras_ret_addr
);

    // Updated byte_rotator instantiation using the new valid port.
    byte_rotator #(.XLEN(XLEN)) rotator (
        .data_in(IBuff_in),
        .shift(pc_in[5:0]),
        .ibuff_valid(IBuff_valid_in),   // Connect the IBuff valid bits
        .data_out(instruction_out),
        .valid_out(instruction_valid)     // Drive the valid flag for the output slice
    );

endmodule

module byte_rotator #(parameter XLEN = 32) (
    input  wire [511:0] data_in,         // 512-bit input (64 bytes)
    input  wire [5:0]   shift,           // Byte-wise shift (0 to 63)
    input  wire [3:0]   ibuff_valid,     // IBuff valid bits for each 128-bit region
    output wire [XLEN-1:0] data_out,       // Output slice of rotated data
    output wire         valid_out         // Valid output: high if selected slice is fully within one valid region.
);

    // Rotate the 512-bit input by shift*8 bits.
    wire [511:0] rotated_data;
    assign rotated_data = (data_in >> (shift * 8)) | (data_in << ((64 - shift) * 8));
    assign data_out = rotated_data[XLEN-1:0];

    //--------------------------------------------------------------------------
    // Compute the equivalent slice in the original (unrotated) data.
    // The slice taken from the rotated_data corresponds to a contiguous 32-bit window
    // in the original data_in. Its starting index (in the 512-bit word) is given by:
    //
    //    start_index = (511 - (shift * 8)) mod 512
    //
    // Since shift*8 is at most 504 for shift up to 63, the subtraction never goes negative.
    // (For shift = 0, start_index = 511; for shift = 63, start_index = 511-504 = 7.)
    //
    // The selected window is 32 bits wide. If start_index >= 31 then the window is
    // contiguous and covers bits from (start_index - 31) to start_index.
    // Otherwise, it “wraps around” the word, and we choose to mark it as invalid.
    //--------------------------------------------------------------------------
    
    // Compute start index (0 to 511)
    wire [8:0] start_index;
    assign start_index = 511 - (shift << 3);  // shift*8, using a shift-left by 3
    
    // Compute end index of the 32-bit window.
    // If start_index is less than 31, the window would wrap around.
    wire [8:0] end_index;
    assign end_index = (start_index >= 31) ? (start_index - 31) : (start_index + (512 - 31));

    //--------------------------------------------------------------------------
    // Determine the IBuff region boundaries.
    //
    // We assume the 512-bit input is partitioned as:
    //   Region 0: bits 511:384  -> valid bit: ibuff_valid[0]
    //   Region 1: bits 383:256  -> valid bit: ibuff_valid[1]
    //   Region 2: bits 255:128  -> valid bit: ibuff_valid[2]
    //   Region 3: bits 127:0    -> valid bit: ibuff_valid[3]
    //
    // We create combinational logic to determine in which region a given bit index falls.
    //--------------------------------------------------------------------------
    
    function automatic [1:0] region_of;
        input [8:0] index;
        begin
            if (index >= 384)
                region_of = 2'd0;
            else if (index >= 256)
                region_of = 2'd1;
            else if (index >= 128)
                region_of = 2'd2;
            else
                region_of = 2'd3;
        end
    endfunction

    wire [1:0] region_start;
    wire [1:0] region_end;
    assign region_start = region_of(start_index);
    assign region_end   = region_of(end_index);

    //--------------------------------------------------------------------------
    // Generate the valid_out signal.
    //
    // The output is considered valid only if:
    // 1. The 32-bit window does NOT wrap around (i.e., start_index >= 31)
    // 2. Both the start and end indices lie in the same region (region_start == region_end)
    // In that case, valid_out is the valid bit for that region, taken from ibuff_valid.
    // Otherwise, valid_out is 0.
    //--------------------------------------------------------------------------
    assign valid_out = (start_index >= 31 && (region_start == region_end)) ?
                       ibuff_valid[region_start] : 1'b0;

endmodule
