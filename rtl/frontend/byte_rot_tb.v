module byte_rotator_tb;

    reg [511:0] data_in;     // 512-bit input (64 bytes)
    reg [5:0]   shift;       // Byte-wise shift amount (0 to 63)
    reg [3:0]   ibuff_valid; // Valid bits for each 128-bit region:
                             //   - Region 0: bits 511:384 → ibuff_valid[0]
                             //   - Region 1: bits 383:256 → ibuff_valid[1]
                             //   - Region 2: bits 255:128 → ibuff_valid[2]
                             //   - Region 3: bits 127:0   → ibuff_valid[3]
    wire [31:0] data_out;    // 32-bit output slice
    wire        valid_out;   // Valid output flag

    byte_rotator uut (
        .data_in(data_in),
        .shift(shift),
        .ibuff_valid(ibuff_valid),
        .data_out(data_out),
        .valid_out(valid_out)
    );

    initial begin
        // Define a full 512-bit constant using distinct 64-bit chunks.
        // Chunk mapping (from MSB to LSB):
        //   Chunk 7 (bits 511:448): 0x0123456789ABCDEF
        //   Chunk 6 (bits 447:384): 0xFEDCBA9876543210
        //   Chunk 5 (bits 383:320): 0x89ABCDEF01234567
        //   Chunk 4 (bits 319:256): 0x76543210FEDCBA98
        //   Chunk 3 (bits 255:192): 0xCAFEBABEDEADBEEF
        //   Chunk 2 (bits 191:128): 0xDEADBEEFCAFEBABE
        //   Chunk 1 (bits 127:64) : 0x1122334455667788
        //   Chunk 0 (bits 63:0)   : 0x8877665544332211
        data_in = 512'h0123456789ABCDEF_FEDCBA9876543210_89ABCDEF01234567_76543210FEDCBA98_CAFEBABEDEADBEEF_DEADBEEFCAFEBABE_1122334455667788_8877665544332211;

        //========================================================================
        // Test Case 1: No shift.
        //
        // shift = 0:
        //   start_index = 511 - (0*8) = 511, window = data_in[511:480].
        //   This selects the top 32 bits of Chunk 7, i.e. 32'h01234567.
        //   Region: index 511 falls in Region 0, so valid_out = ibuff_valid[0].
        //   Set ibuff_valid so that region 0 is valid.
        ibuff_valid = 4'b1011; // (Region0:1, Region1:1, Region2:0, Region3:1)
        shift = 6'd0;
        #10;
        $display("TC1: shift=0, Expected data_out = 01234567, valid=1, Got: data_out = %h, valid_out = %b", data_out, valid_out);

        //========================================================================
        // Test Case 2: Shift by 8 bytes.
        //
        // shift = 8:
        //   start_index = 511 - (8*8) = 511 - 64 = 447, window = data_in[447:416].
        //   This selects the top 32 bits of Chunk 6, i.e. 32'hFEDCBA98.
        //   Region: index 447 is within Region 0, so valid_out = ibuff_valid[0] (should be 1).
        ibuff_valid = 4'b1011; // Region0 remains valid.
        shift = 6'd8;
        #10;
        $display("TC2: shift=8, Expected data_out = FEDCBA98, valid=1, Got: data_out = %h, valid_out = %b", data_out, valid_out);

        //========================================================================
        // Test Case 3: Shift by 16 bytes.
        //
        // shift = 16:
        //   start_index = 511 - (16*8) = 511 - 128 = 383, window = data_in[383:352].
        //   This selects the top 32 bits of Chunk 5, i.e. 32'h89ABCDEF.
        //   Region: index 383 falls in Region 1, so valid_out = ibuff_valid[1].
        //   Set ibuff_valid so that region 1 is marked invalid.
        ibuff_valid = 4'b1001; // (Region0:1, Region1:0, Region2:0, Region3:1)
        shift = 6'd16;
        #10;
        $display("TC3: shift=16, Expected data_out = 89ABCDEF, valid=0, Got: data_out = %h, valid_out = %b", data_out, valid_out);

        //========================================================================
        // Test Case 4: Shift by 24 bytes.
        //
        // shift = 24:
        //   start_index = 511 - (24*8) = 511 - 192 = 319, window = data_in[319:288].
        //   This selects the top 32 bits of Chunk 4, i.e. 32'h76543210.
        //   Region: index 319 falls in Region 1, so valid_out = ibuff_valid[1].
        //   Set ibuff_valid so that region 1 is valid.
        ibuff_valid = 4'b1011; // (Region1 now valid because ibuff_valid[1]=1)
        shift = 6'd24;
        #10;
        $display("TC4: shift=24, Expected data_out = 76543210, valid=1, Got: data_out = %h, valid_out = %b", data_out, valid_out);

        //========================================================================
        // Test Case 5: Shift by 63 bytes (wrap-around condition).
        //
        // shift = 63:
        //   start_index = 511 - (63*8) = 511 - 504 = 7, which is less than 31,
        //   so the window wraps around.
        //   Regardless of ibuff_valid, valid_out should be forced to 0.
        //   The rotated 32-bit slice evaluates (via rotation) to 32'h11012345.
        shift = 6'd63;
        ibuff_valid = 4'b1011; // Valid mask does not matter because window wraps.
        #10;
        $display("TC5: shift=63, Expected data_out = 11012345, valid=0, Got: data_out = %h, valid_out = %b", data_out, valid_out);

        $finish;
    end

endmodule
