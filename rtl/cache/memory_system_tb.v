module memory_system_tb ();

reg clk, rst, tmp;
reg [31:0] addr_even, addr_odd;
wire[31:0]addr_out_even, addr_out_odd;
wire[127:0] cl_odd, cl_even;

reg[31:0] data_in, addr_in;
reg[1:0] size_in;
reg is_st_in;
reg [9:0] ooo_tag_in, ooo_rob_in, rob_ret_tag_in;
reg sext,ls_unit_alloc;

reg rob_valid, rob_resteer;

wire [31:0] addr_out;
wire [31:0] data_out;
wire is_st_out;
wire valid_out;
wire [9:0] tag_out, rob_line_out;

initial begin
    rob_ret_tag_in = 0;
    rob_valid =0; rob_resteer = 0;
    ls_unit_alloc = 0;
    addr_in = 32'b010_0000;
    data_in = 32'b011_0000;
    size_in = 1;
    is_st_in = 0;
    ooo_tag_in = 17;
    ooo_rob_in = 5;
    sext = 1;
    #120
    ls_unit_alloc = 1;
    #15
    ls_unit_alloc = 0;
    #299
    rob_ret_tag_in = 0;
    rob_valid =0; rob_resteer = 0;
    ls_unit_alloc = 0;
    addr_in = 32'b110_0010;
    data_in = 32'hDEAD_BEEF;
    size_in = 3;
    is_st_in = 1;
    ooo_tag_in = 20;
    ooo_rob_in = 7;
    sext = 1;
    ls_unit_alloc = 1;
    #8
    ls_unit_alloc = 0;
//    #10
//    rob_ret_tag_in = 0;
//    rob_valid =0; rob_resteer = 0;
//    ls_unit_alloc = 0;
//    addr_in = 32'b110_1000;
//    data_in = 32'hFFFF_FFFF;
//    size_in = 4;
//    is_st_in = 0;
//    ooo_tag_in = 22;
//    ooo_rob_in = 19;
//    sext = 1;
//    ls_unit_alloc = 1;
//    #8
//    ls_unit_alloc = 0;
end

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
    #20
    @(posedge hit_even);
    #20
           #1
    addr_even = 32'hFF00_0020;
    addr_odd = 32'hFF00_0030;
   #20
    @(posedge hit_even);
    #20
        #1
     addr_even = 32'b100_0000;
     addr_odd = 32'b101_0000;
     
    tmp = 1;
    #1000
    tmp = 0;
    $finish;
    end



memory_system_top #(.CL_SIZE(128), .OOO_TAG_SIZE(10), .TAG_SIZE(18), .IDX_CNT(512), .OOO_ROB_SIZE(10)) 
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

        .ic_stall(ic_stall),
        .exception(exception),

        //dc

        .ls_unit_alloc(ls_unit_alloc), //Data from RAS is valid or not
        .addr_in(addr_in),
        .data_in(data_in),
        .size_in(size_in), //
        .is_st_in(is_st_in), //Say whether input is ST or LD
        .ooo_tag_in(ooo_tag_in), //tag from register renaming
        .ooo_rob_in(ooo_rob_in),
        .sext(sext),

        //FROM ROB
        .rob_ret_tag_in(rob_ret_tag_in), //Show top of ROB tag
        .rob_valid(rob_valid), //bit to say whether or not the top of the rag is valid or not
        .rob_resteer(rob_resteer), //Signal if there is a flush from ROB
        
        //TO ROB
        .addr_out(addr_out),
        .data_out(data_out),
        .is_st_out(is_st_out),
        .valid_out(valid_out), //1 bit signal to tell whether or not there are cache results
        .tag_out(tag_out),
        .rob_line_out(rob_line_out),
        .is_flush_out(is_flush_out),

        //TO RSV
        .dc_stall(dc_stall)
    );


endmodule