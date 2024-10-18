module TOP();

    localparam CYCLE_TIME = 15;
    reg clk;

    initial begin
        clk = 1'b1;
        forever #(CYCLE_TIME / 2.0) clk = ~clk;
    end
    
    //instantiation of the modules: front end, mapper, OOO engine, and ROB

    FRONT_END front_end(
        .clk(clk),
    );

endmodule
