module rob_TOP #(parameter ROB_SIZE=128,
                 parameter ARCHFILE_SIZE=32,
                 parameter PHYSFILE_SIZE=256)(
    input clk, rst,

    input uop_update,
    input [$clog2(ARCHFILE_SIZE)-1:0] uop_dest_arch_in,
    input [$clog2(PHYSFILE_SIZE)-1:0] uop_dest_phys_in,
    input except_in, //TODO: implement exception logic

    input uop_finish,
    input [$clog2(ROB_SIZE)-1:0] uop_finish_rob_entry,

    output retire_uop,
    output reg [$clog2(ARCHFILE_SIZE)-1:0] uop_dest_arch_out,
    output reg [$clog2(PHYSFILE_SIZE)-1:0] uop_dest_phys_out,

    output [$clog2(ROB_SIZE)-1:0] next_rob_entry,

    output rob_full
);

    integer i;

    reg [$clog2(ROB_SIZE)-1:0] rd_ptr, wr_ptr;
    wire rob_empty;

    assign rob_full = rd_ptr-1 == wr_ptr;
    assign rob_empty = rd_ptr == wr_ptr;
    assign next_rob_entry = wr_ptr;

    assign retire_uop = ~rob_empty && rob_entries[rd_ptr][1+$clog2(ARCHFILE_SIZE)+$clog2(PHYSFILE_SIZE)-1];

    reg [1+$clog2(ARCHFILE_SIZE)+$clog2(PHYSFILE_SIZE)-1:0] rob_entries [ROB_SIZE-1:0];

    always@(posedge clk) begin
        if(uop_update) begin //TODO: should check if full first
            wr_ptr <= wr_ptr + 1;
            rob_entries[wr_ptr] <= {1'b0,uop_dest_arch_in,uop_dest_phys_in};
        end
        if(uop_finish) begin //TODO: should check if empty first
            rob_entries[uop_finish_rob_entry] <= {1'b1,rob_entries[uop_finish_rob_entry][$clog2(ARCHFILE_SIZE)+$clog2(PHYSFILE_SIZE)-1:0]};
        end
        if(retire_uop) begin
            uop_dest_arch_out <= rob_entries[rd_ptr][$clog2(ARCHFILE_SIZE)+$clog2(PHYSFILE_SIZE)-1:$clog2(PHYSFILE_SIZE)];
            uop_dest_phys_out <= rob_entries[rd_ptr][$clog2(PHYSFILE_SIZE)-1:0];
        end
    end

    always@(negedge rst) begin
        for(i = 0; i < ROB_SIZE; i = i + 1) begin
            rob_entries[i] <= {1+$clog2(ARCHFILE_SIZE)+$clog2(PHYSFILE_SIZE){1'b0}};
        end
    end

endmodule