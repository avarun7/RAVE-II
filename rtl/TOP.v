module TOP();

    localparam CYCLE_TIME = 5.0;
    reg clk;

    initial begin
        clk = 1'b1;
        forever #(CYCLE_TIME / 2.0) clk = ~clk;
    end
    
    //instantiation of the modules: frontend, mapper, OOOengine, regfile, ROB, and L2$

    frontend_TOP frontend(
        .clk(clk),
        //TODO: add more inputs/outputs
    );

    mapper_TOP mapper(
        .clk(clk),
        //TODO: add more inputs/outputs
    );

    regfile_TOP regfile(
        .clk(clk),
        //TODO: add more inputs/outputs
    );

    ooo_engine_TOP ooo_engine(
        .clk(clk),
        //TODO: add more inputs/outputs
    );

    rob_TOP rob(
        .clk(clk),
        //TODO: add more inputs/outputs
    );

    l2cache_TOP l2cache(
        .clk(clk),
        //TODO: add more inputs/outputs
    );

endmodule
