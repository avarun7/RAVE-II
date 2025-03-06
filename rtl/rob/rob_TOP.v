module rob_TOP #(parameter ARCHFILE_SIZE=32,
                 parameter PHYSFILE_SIZE=256,
                 parameter ROB_SIZE=128)(
    input clk, rst,

    input uop_update,
    input [$clog2(ARCHFILE_SIZE)-1:0] uop_dest_arch_in,
    input [$clog2(PHYSFILE_SIZE)-1:0] uop_dest_phys_in, uop_dest_oldphys_in,
    input except, //TODO: implement exception logic

    input uop_finish,
    input [$clog2(ROB_SIZE)-1:0] uop_finish_rob_entry,

    output retire_uop,
    output [$clog2(ARCHFILE_SIZE)-1:0] uop_dest_arch_out,
    output [$clog2(PHYSFILE_SIZE)-1:0] uop_dest_phys_out, uop_dest_oldphys_out,

    output [$clog2(ROB_SIZE)-1:0] next_rob_entry,

    output rob_full
);

    integer i;

    reg [$clog2(ROB_SIZE)-1:0] rd_ptr, wr_ptr;
    wire rob_empty;

    assign rob_full = rd_ptr-1 == wr_ptr;
    assign rob_empty = rd_ptr == wr_ptr;
    assign next_rob_entry = wr_ptr;

    reg [ROB_SIZE-1:0] rdyvect;
    reg [$clog2(ARCHFILE_SIZE)+(2*$clog2(PHYSFILE_SIZE))-1:0] rob_entries [ROB_SIZE-1:0];

    assign retire_uop = ~rob_empty && rdyvect[rd_ptr];
    assign {uop_dest_arch_out, uop_dest_phys_out, uop_dest_oldphys_out} = rob_entries[rd_ptr];

    always@(posedge clk) begin
        if(uop_update) begin //TODO: should check if full first
            wr_ptr <= wr_ptr + 1;
            rdyvect[wr_ptr] <= 1'b0;
            rob_entries[wr_ptr] <= {uop_dest_arch_in, uop_dest_phys_in, uop_dest_oldphys_in};
        end
        if(uop_finish) begin //TODO: should check if empty first
            rdyvect[uop_finish_rob_entry] <= 1'b1;
        end
        if(retire_uop) begin
            rd_ptr <= rd_ptr + 1;
        end
    end

    always@(negedge rst) begin
        rdyvect <= {ROB_SIZE{1'b0}};
        for(i = 0; i < ROB_SIZE; i = i + 1) begin
            rob_entries[i] <= {$clog2(ARCHFILE_SIZE)+(2*$clog2(PHYSFILE_SIZE)){1'b0}};
        end
    end

endmodule