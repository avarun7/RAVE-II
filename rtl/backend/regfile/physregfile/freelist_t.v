module TOP;

    localparam CYCLE_TIME = 2.0;
    localparam PHYSFILE_SIZE = 32;
    integer k;

    reg clk, rst;

    reg phys_rsv, phys_free;
    reg [$clog2(PHYSFILE_SIZE)-1:0] phystag_rsv, phystag_free;
    reg rollback;

    wire none_free;
    wire [$clog2(PHYSFILE_SIZE)-1:0] next_free;

    freelist #(.PHYSFILE_SIZE(PHYSFILE_SIZE)) fl(.clk(clk), .rst(rst),
                                                 .phys_rsv(phys_rsv), .phys_free(phys_free),
                                                 .phystag_rsv(phystag_rsv), .phystag_free(phystag_free),
                                                 .rollback(rollback),
                                                 .none_free(none_free), .next_free(next_free));

    initial begin
        clk = 1'b1;
        forever #(CYCLE_TIME / 2.0) clk = ~clk;
    end

    initial begin
        rst = 1'b0;
        #CYCLE_TIME;
        rst = 1'b1;
        phys_rsv = 1'b0; phys_free = 1'b0;
        phystag_rsv = 7'h0; phystag_free = 7'h00;
        rollback = 1'b0;
        #CYCLE_TIME;

        phys_rsv = 1'b1;
        for (k = PHYSFILE_SIZE-1; k >= PHYSFILE_SIZE/2; k = k - 4) begin
            phystag_rsv = k;
            #CYCLE_TIME; 
        end

        phys_rsv = 1'b0;
        phys_free = 1'b1;
        for (k = PHYSFILE_SIZE/2; k < PHYSFILE_SIZE; k = k + 3) begin
            phystag_free = k;
            #CYCLE_TIME; 
        end

        phys_free = 1'b0;
        phys_rsv = 1'b1;
        for (k = PHYSFILE_SIZE-1; k >= PHYSFILE_SIZE/2; k = k - 4) begin
            phystag_rsv = k;
            #CYCLE_TIME; 
        end

        #CYCLE_TIME;
        rst = 1'b0;
        #CYCLE_TIME;
        #CYCLE_TIME;
        #CYCLE_TIME;
        $finish;
    end

    initial begin
        $dumpfile("test.fst");
        $dumpvars(0, TOP);
    end

endmodule