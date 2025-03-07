module regread #(parameter NUM_UOPS=32,
                 parameter XLEN=32,
                 parameter ARCHFILE_SIZE=32)(
    input clk, rst,

    input [$clog2(NUM_UOPS)-1:0] uop_in,
    input eoi_in,
    input [$clog2(ARCHFILE_SIZE)-1:0] dest_arch_in,
    input [XLEN-1:0] imm_in,
    input use_imm_in,
    input [31:0] pc_in,
    input except_in,

    output reg [$clog2(NUM_UOPS)-1:0] uop_out,
    output reg eoi_out,
    output reg [$clog2(ARCHFILE_SIZE)-1:0] dest_arch_out,
    output reg [XLEN-1:0] imm_out,
    output reg use_imm_out,
    output reg [31:0] pc_out,
    output reg except_out
);

    always@(posedge clk) begin
        uop_out <= uop_in;
        eoi_out <= eoi_in;
        dest_arch_out <= dest_arch_in;
        imm_out <= imm_in;
        use_imm_out <= use_imm_in;
        pc_out <= pc_in;
        except_out <= except_in;
    end

    always@(negedge rst) begin
        uop_out <= {$clog2(NUM_UOPS){1'b0}};
        eoi_out <= 1'b0;
        dest_arch_out <= {$clog2(ARCHFILE_SIZE){1'b0}};
        imm_out <= {XLEN{1'b0}};
        use_imm_out <= 1'b0;
        pc_out <= {32{1'b0}};
        except_out <= 1'b0;
    end

endmodule