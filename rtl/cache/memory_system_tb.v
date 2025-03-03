module memory_system_tb ();

reg clk, rst;
reg [31:0] addr_even, addr_odd;
wire[31:0]addr_out_even, addr_out_odd;
wire[127:0] cl_odd, cl_even;
always begin
    #5
    clk = !clk;
end

initial begin
    clk = 0;
    rst = 1;
    addr_even = 32'b010_0000;
    addr_odd = 32'b011_0000;

    #20
    rst = 0;


end

memory_system_top #(.CL_SIZE(128), .OOO_TAG_SIZE(10), .TAG_SIZE(18), .IDX_CNT(512)) 
     mem_sys_inst (
        .clk(clk),
        .rst(rst),

        // I$ Inputs
        .addr_even(addr_even),
        .addr_odd(addr_odd),

        // I$ Outputs
        .hit_even(hit_even),
        .hit_odd(hit_odd),

        .cl_even(cl_even),
        .cl_odd(cl_odd),

        .addr_out_even(addr_out_even),
        .addr_out_odd(addr_out_odd),

        .is_write_even(is_write_even),
        .is_write_odd(is_write_odd),

        .stall(stall),
        .exception(exception)
    );


endmodule