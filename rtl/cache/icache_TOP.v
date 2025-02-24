module icache_TOP #(parameter CL_SIZE = 128) (
    input clk,
    input rst,

    //Pipeline facing I/O
    input [31:0] addr_e, //Address for even bank of I$
    input [31:0] addr_o, //Address for odd bank of I$

    output hit_e, //Return whether current cache line access was a hit
    output hit_o,

    output [CL_SIZE-1:0] cl_e, //Data of the even I$ bank
    output  [CL_SIZE-1:0] cl_o,

    output [31:0] addr_out_e, //Since I$ access is two cycles, tells you what address the current data corresponds to
    output [31:0] addr_out_o,

    output is_write_e, //Tells whether the data being processed is a write (probably want to ignore results if it is)
    output is_write_o,

    output stall //Signal to say stop feeding data to cache. I don't think its needed since this is blocking
    
    //TODO: All other I/O memory facing and I will handle
    //Shouldn't affect people working on integrating the pipeline


);

endmodule 