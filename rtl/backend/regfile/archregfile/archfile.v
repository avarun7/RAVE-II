module specfile #(parameter ARCHFILE_SIZE=32,
                  parameter PHYSFILE_SIZE=256)(
    input clk, rst,

    input update,
    input [$clog2(ARCHFILE_SIZE)-1:0] arch_rd1, arch_rd2,
    input [$clog2(ARCHFILE_SIZE)-1:0] arch_wr,
    input [$clog2(PHYSFILE_SIZE)-1:0] arch_wr_phys,

    input rollback,
    input [ARCHFILE_SIZE*$clog2(PHYSFILE_SIZE)-1:0] rb_dump,

    output reg [$clog2(PHYSFILE_SIZE)-1:0] arch_rd1_phys, arch_rd2_phys, arch_wr_oldphys
);

    integer i;
    genvar j;

    reg [$clog2(PHYSFILE_SIZE)-1:0] archvect [ARCHFILE_SIZE-1:0];
    wire [$clog2(PHYSFILE_SIZE)-1:0] rb_dump_w [ARCHFILE_SIZE-1:0];

    generate
        for (j = 0; j < ARCHFILE_SIZE; j = j + 1) begin : archvect_flatten
            assign rb_dump_w[j] = rb_dump[(j+1)*$clog2(PHYSFILE_SIZE)-1:j*$clog2(PHYSFILE_SIZE)];
        end
    endgenerate

    always@(posedge clk) begin
        if(!rollback) begin
            for(i = 0; i < ARCHFILE_SIZE; i = i + 1) begin
                if(arch_rd1 == i) begin
                    arch_rd1_phys <= archvect[i];
                end
                if(arch_rd2 == i) begin
                    arch_rd2_phys <= archvect[i];
                end
                if(update) begin
                    if(arch_wr == i) begin
                        arch_wr_oldphys <= archvect[i];
                        archvect[i] <= arch_wr_phys;
                    end
                end
            end
        end else begin
            for(i = 0; i < ARCHFILE_SIZE; i = i + 1) begin
                archvect[i] <= rb_dump_w[i];
            end
        end
    end

    always@(negedge rst) begin
        for(i = 0; i < ARCHFILE_SIZE; i = i + 1) begin
            archvect[i] <= {$clog2(PHYSFILE_SIZE){1'b0}};
        end
    end

endmodule



module nonspecfile #(parameter ARCHFILE_SIZE=32,
                     parameter PHYSFILE_SIZE=256)(
    input clk, rst,

    input update,
    input [$clog2(ARCHFILE_SIZE)-1:0] arch_wr,
    input [$clog2(PHYSFILE_SIZE)-1:0] arch_wr_phys,

    output [ARCHFILE_SIZE*$clog2(PHYSFILE_SIZE)-1:0] arch_dump
);

    integer i;
    genvar j;

    reg [$clog2(PHYSFILE_SIZE)-1:0] archvect [ARCHFILE_SIZE-1:0];

    generate
        for (j = 0; j < ARCHFILE_SIZE; j = j + 1) begin : archvect_flatten
            assign arch_dump[(j+1)*$clog2(PHYSFILE_SIZE)-1:j*$clog2(PHYSFILE_SIZE)] = archvect[j];
        end
    endgenerate

    always@(posedge clk) begin
        for(i = 0; i < ARCHFILE_SIZE; i = i + 1) begin
            if(update) begin
                if(arch_wr == i) begin
                    archvect[i] <= arch_wr_phys;
                end
            end
        end
    end

    always@(negedge rst) begin
        for(i = 0; i < ARCHFILE_SIZE; i = i + 1) begin
            archvect[i] <= {$clog2(PHYSFILE_SIZE){1'b0}};
        end
    end

endmodule