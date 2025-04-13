module physfile #(parameter PHYSFILE_SIZE=256,
                  parameter REG_SIZE=32)(
    input clk, rst,

    input uop_update,
    input [$clog2(PHYSFILE_SIZE)-1:0] phys_rd1, phys_rd2,
    input [$clog2(PHYSFILE_SIZE)-1:0] phys_wr,

    input ring_update,
    input [$clog2(PHYSFILE_SIZE)-1:0] phys_ring,
    input [REG_SIZE-1:0] phys_ring_val,

    input rollback, //TODO: implement rollback mech

    output reg phys_rd1_rdy, phys_rd2_rdy,
    output reg [REG_SIZE-1:0] phys_rd1_val, phys_rd2_val
);

    integer i;

    reg [REG_SIZE-1:0] physvect [PHYSFILE_SIZE-1:0];
    reg [PHYSFILE_SIZE-1:0] rdyvect;

    always@(posedge clk) begin
        for(i = 0; i < PHYSFILE_SIZE; i = i + 1) begin
            if(phys_rd1 == i) begin
                phys_rd1_rdy <= rdyvect[i];
                phys_rd1_val <= physvect[i];
            end
            if(phys_rd2 == i) begin
                phys_rd2_rdy <= rdyvect[i];
                phys_rd2_val <= physvect[i];
            end
            if(uop_update) begin
                if(phys_wr == i) begin
                    rdyvect[i] <= 1'b0;
                end
            end

            if(ring_update) begin
                if(phys_ring == i) begin
                    rdyvect[i] <= 1'b1;
                    physvect[i] <= phys_ring_val;
                end
            end
        end
    end

    always@(negedge rst) begin
        for(i = 0; i < PHYSFILE_SIZE; i = i + 1) begin
            physvect[i] <= {REG_SIZE{1'b0}};
        end
        rdyvect <= {PHYSFILE_SIZE{1'b1}};
    end

endmodule