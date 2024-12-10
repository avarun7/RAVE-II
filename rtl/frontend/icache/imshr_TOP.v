module imshr #(parameter DEPTH = 32) (
    //input from f1
    input f1_p_addr_in,
    input f1_valid,

    //output for f1
    output f1_mshr_hit,

    //input from f2
    input f2_p_addr_in,
    input f2_alloc,
    input f2_dealloc,

    //output for f2
    output f2_full
);

endmodule