module predecode #(parameter XLEN=32) (
    input clk, rst,

    //inputs
    input exception_in,
    input [XLEN - 1:0] inst_in,

    //outputs
    output exception_out,
    output [2:0] opcode_format, //TODO
    output [XLEN - 1:0] inst_out,
    output compressed_inst,

    output ras_push,
    output ras_pop
); 

    always @ (posedge clk) begin

        if(IBuff_in[0] & IBuff_in[1]) begin
            compressed_inst <= 1'b1;
            inst_out <= 32'h0000_0000;
        end else begin
            compressed_inst <= 1'b0;
            inst_out <= IBuff_in;
        end

        case (IBuff_in[6:2])
            5'b00000: begin //I-type
                opcode_format <= 3'b000;
                exception_out <= 1'b0 | exception_in; 
            end
            5'b00011: begin
                opcode_format <= 3'b000;
                exception_out <= 1'b0 | exception_in; 
            end
            5'b00100: begin
                opcode_format <= 3'b000;
                exception_out <= 1'b0 | exception_in; 
            end
            5'b11001: begin
                opcode_format <= 3'b000;
                exception_out <= 1'b0 | exception_in; 
            end
            5'b11100: begin
                opcode_format <= 3'b000;
                exception_out <= 1'b0 | exception_in; 
            end

            5'b01000: begin //S-type
                opcode_format <= 3'b001;
                exception_out <= 1'b0 | exception_in; 
            end

            5'b01011: begin //R-type
                opcode_format <= 3'b010;
                exception_out <= 1'b0 | exception_in; 
            end
            5'b01100: begin
                opcode_format <= 3'b010;
                exception_out <= 1'b0 | exception_in; 
            end

            5'b11000: begin //B-type
                opcode_format <= 3'b011;
                exception_out <= 1'b0 | exception_in; 
            end

            5'b11011: begin //J-type
                opcode_format <= 3'b100;
                exception_out <= 1'b0 | exception_in; 
            end

            5'b00101: begin //U-type
                opcode_format <= 3'b101;
                exception_out <= 1'b0 | exception_in; 
            end
            5'b01101: begin
                opcode_format <= 3'b101;
                exception_out <= 1'b0 | exception_in; 
            end

            default: begin //Illegal
                opcode_format <= 3'b111;
                exception_out <= 1'b0 | exception_in; 
            end
        endcase

    end

endmodule