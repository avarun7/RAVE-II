`timescale 1ns/1ps

module predecode_tb;

    localparam x = 32;
    localparam cycletime = 6;

    reg clk, rst;

    reg [x - 1: 0] IBuff_in;

    wire exception_out;
    wire [2:0] opcode_format;
    wire [x - 1:0] inst_out;
    wire compressed_inst;

    //wire ras_push,
    //wire ras_pop

    initial begin
        clk = 0;
        forever
            #(cycletime / 2) clk = ~clk;
    end

    initial begin
        IBuff_in = 32'h00000000;
        #(3*cycletime);

        $display("inst: addi R1, 0x0, 0x2");
        IBuff_in = 32'h00200093;
        #cycletime;

        $display("inst: add R3, R1, R2");
        IBuff_in = 32'h00300113;
        #cycletime;

        $display("inst: sw R3, 0(R6)");
        IBuff_in = 32'h00332023;
        #cycletime;

        $display("inst: lw R8, 0(R6)");
        IBuff_in = 32'h00032403;
        #cycletime;

        $display("inst: jalr 0x0, 0x0, R0");
        IBuff_in = 32'h00000067;
        #cycletime;

        $finish;

    end

    // Dump all waveforms
    initial begin
     $dumpfile("pdecode.fst");
     $dumpvars(0,pdecode_test); 
    end

    predecode #(.XLEN(x)) pdecode_test(.clk(clk), .rst(rst),
                                        .IBuff_in(IBuff_in),
                                        .opcode_format(opcode_format), .inst_out(inst_out),
                                        .compressed_inst(compressed_inst)
                                        /*.push_ras(push_ras), .pop_ras(pop_ras)*/);

endmodule