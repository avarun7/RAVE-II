module dcache_TOP #(parameter CL_SIZE = 128, OOO_TAG_SIZE = 10) (
    //FROM SYSTEM
    input clk,
    input rst,

    //FROM RAS
    input ls_unit_alloc, //Data from RAS is valid or not
    input [31:0] addr_in,
    input [31:0] data_in,
    input [1:0] size_in, //
    input is_st_in, //Say whether input is ST or LD
    input [OOO_TAG_SIZE-1:0] ooo_tag_in, //tag from register renaming

    //FROM ROB
    input [OOO_TAG_SIZE-1:0] rob_ret_tag_in, //Show top of ROB tag
    input rob_valid, //bit to say whether or not the top of the rag is valid or not
    input rob_resteer, //Signal if there is a flush from ROB
    
    //TO ROB
    output addr_out,
    output [31:0] data_out,
    output [1:0]size_out,
    output is_st_out,
    output ls_unit_empty //1 bit signal to tell whether or not there are cache results


    //TODO: All other I/O memory facing and I will handle
    //Shouldn't affect people working on integrating the pipeline
);

endmodule