module predecode #(parameter XLEN=32) (
    input clk, rst,

    //inputs
    input [XLEN - 1:0] IBuff_in,

    //outputs
    output [2:0] opcode_format,
    output [XLEN - 1:0] inst_out,
    output compressed_inst//,

    //output ras_push, TODO:
    //output ras_pop
); 

    assign compressed_inst = (IBuff_in[0] && IBuff_in[1])? 1'b0 : 1'b1;
    assign inst_out = (IBuff_in[0] && IBuff_in[1])? IBuff_in : 32'h0000_0000;

    assign opcode_format = (IBuff_in[6:2] == 5'b00000) ? 3'b000 : //I-type
                           (IBuff_in[6:2] == 5'b00011) ? 3'b000 : 
                           (IBuff_in[6:2] == 5'b00100) ? 3'b000 :
                           (IBuff_in[6:2] == 5'b11001) ? 3'b000 :
                           (IBuff_in[6:2] == 5'b11100) ? 3'b000 :
                           (IBuff_in[6:2] == 5'b00011) ? 3'b000 :

                           (IBuff_in[6:2] == 5'b01000) ? 3'b001 : //S-type

                           (IBuff_in[6:2] == 5'b01011) ? 3'b010 : //R-type
                           (IBuff_in[6:2] == 5'b01100) ? 3'b010 :

                           (IBuff_in[6:2] == 5'b11000) ? 3'b011 : //B-type

                           (IBuff_in[6:2] == 5'b11011) ? 3'b100 : //J-type

                           (IBuff_in[6:2] == 5'b00101) ? 3'b101 : //U-type
                           (IBuff_in[6:2] == 5'b01101) ? 3'b101 :
                           
                                                        3'b111; //null type

endmodule