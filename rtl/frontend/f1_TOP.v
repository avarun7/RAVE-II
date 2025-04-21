module f1_TOP #(parameter XLEN=32, CLC_WIDTH=28) (
    input clk, rst,
    //inputs
    input [CLC_WIDTH - 1:0] clc_even_in,
    input [CLC_WIDTH - 1:0] clc_odd_in,
    input stall_in,
    
    //outputs
    output pcd,         //don't cache MMIO
    output hit,
    output exceptions,
    
    output addr_even_valid,
    output addr_odd_valid,
    output wire [XLEN - 1:0] addr_even,
    output wire [XLEN - 1:0] addr_odd
);

integer file;
integer cycle_number = 0;
initial begin
    file = $fopen("out/f1.log", "w");
    if (file == 0) begin
        $display("Error: Failed to open file f1.log");
        $finish;
    end
end

    simple_tlb #(.XLEN(XLEN), .CLC_WIDTH(CLC_WIDTH)) tlb (
        .clk(clk), .rst(rst),
        .pc(),
        .clc0_in(clc_even_in),
        .clc1_in(clc_odd_in),
        .RW_in(1'b0),
        .valid_in(1'b1),
        
        //outputs
        .pcd(pcd),
        .hit(hit),
        .exception(),
        .exception_type(),
        .clc0_paddr(addr_even),
        .clc1_paddr(addr_odd),
        .clc0_paddr_valid(addr_even_valid),
        .clc1_paddr_valid(addr_odd_valid)
    );

    always @(posedge clk) begin
        cycle_number = cycle_number + 1;
        $fwrite(file, "Cycle number: %d\n", cycle_number);
        $fwrite(file, "addr_even_valid: %b\n", addr_even_valid);
        $fwrite(file, "addr_odd_valid: %b\n", addr_odd_valid);
        $fwrite(file, "addr_even: %h\n", addr_even);
        $fwrite(file, "addr_odd: %h\n", addr_odd);

        $fwrite(file, "\n");
    end

//    final begin
//        $fclose(file);
//    end


endmodule