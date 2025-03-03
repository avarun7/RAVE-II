module archfile #(parameter ARCHFILE_SIZE=32,
                  parameter PHYSFILE_SIZE=256)(
    input clk, rst,

    input update,
    input [$clog2(ARCHFILE_SIZE)-1:0] arch_rd1, arch_rd2,
    input [$clog2(ARCHFILE_SIZE)-1:0] arch_wr,
    input [$clog2(PHYSFILE_SIZE)-1:0] arch_wr_phys,

    input rollback,

    output reg [$clog2(PHYSFILE_SIZE)-1:0] arch_rd1_phys, arch_rd2_phys
);

    integer i;

    reg [$clog2(PHYSFILE_SIZE)-1:0] archvect [ARCHFILE_SIZE-1:0];

    always@(posedge clk) begin
        for(i = 0; i < ARCHFILE_SIZE; i = i + 1) begin
            if(arch_rd1 == i) begin
                arch_rd1_phys <= archvect[i];
            end
            if(arch_rd2 == i) begin
                arch_rd2_phys <= archvect[i];
            end
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