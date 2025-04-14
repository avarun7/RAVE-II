module byte_rotator_tb();

    reg [511:0] data_in; // 512-bit input (64 bytes)
    reg [5:0] shift;     // 6-bit shift amount (0-63)
    wire [31:0] data_out; // 32-bit output

    byte_rotator uut (
        .data_in(data_in),
        .shift(shift),
        .data_out(data_out)
    );

    initial begin
        // Define a 512-bit constant with distinct 64-bit chunks.
        data_in = 512'h0123456789ABCDEF_FEDCBA9876543210_89ABCDEF01234567_76543210FEDCBA98_CAFEBABEDEADBEEF_DEADBEEFCAFEBABE_1122334455667788_8877665544332211;

        // Test case 1: Shift by 8 bytes -> Expect top 32 bits of chunk 6.
        shift = 6'd8;
        #10;
        $display("Test case 1 (shift 8): data_out = %h", data_out);
        // Expected output: 0xFEDCBA98

        // Test case 2: Shift by 16 bytes -> Expect top 32 bits of chunk 5.
        shift = 6'd16;
        #10;
        $display("Test case 2 (shift 16): data_out = %h", data_out);
        // Expected output: 0x89ABCDEF

        // Test case 3: No shift -> Expect top 32 bits of chunk 7.
        shift = 6'd0;
        #10;
        $display("Test case 3 (shift 0): data_out = %h", data_out);
        // Expected output: 0x01234567

        // Test case 4: Shift by 63 bytes -> Equivalent to right rotate by 1 byte.
        shift = 6'd63;
        #10;
        $display("Test case 4 (shift 63): data_out = %h", data_out);
        // Expected output: 0x11012345

        $finish;
    end

endmodule
