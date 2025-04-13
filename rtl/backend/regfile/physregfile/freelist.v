module freelist #(parameter PHYSFILE_SIZE=256)(
    input clk, rst,

    input phys_rsv, phys_free, phys_nonspec,
    input [$clog2(PHYSFILE_SIZE)-1:0] phystag_rsv, phystag_free, phystag_nonspec,

    input rollback, //TODO: implement rollback mech

    output none_free,
    output [$clog2(PHYSFILE_SIZE)-1:0] next_free
);

    integer i;

    reg [PHYSFILE_SIZE-1:0] freevect, rb_freevect;

    always@(posedge clk) begin
        if(!rollback) begin
            for(i = 0; i < PHYSFILE_SIZE; i = i + 1) begin
                if(phystag_rsv == i && phys_rsv) begin
                    freevect[i] <= 1'b0;
                    rb_freevect[i] <= 1'b0;
                end else if (phystag_free == i && phys_free)begin
                    freevect[i] <= 1'b1;
                end else if (phystag_nonspec == i && phys_nonspec)begin
                    rb_freevect[i] <= 1'b1;
                end
            end
        end else begin
            freevect <= rb_freevect;
        end
    end

    pencoder #(.WIDTH(PHYSFILE_SIZE)) pe(.a(freevect), .o(next_free), .none(none_free));

    always@(negedge rst) begin
        freevect <= -1;
        rb_freevect <= -1;
    end

endmodule