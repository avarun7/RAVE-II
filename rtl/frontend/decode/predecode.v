module predecode #(parameter XLEN=32) (
    input clk, rst,

    //inputs
    input [XLEN - 1:0] IBuff_in,

    //outputs
    output reg [2:0] opcode_format,
    output reg [XLEN - 1:0] inst_out,
    output reg compressed_inst//,

    //output ras_push, TODO:
    //output ras_pop
); 

    always@(posedge clk) begin
        if(IBuff_in[0] && IBuff_in[1]) begin
            compressed_inst <= 1'b1;

            case(IBuff_in[1:0])
                2'b00: begin
                    case(IBuff_in[15:13])
                        3'b000: begin //C.ADDI4SPN
                            inst_out <= {2'b00,IBuff_in[10:7],IBuff_in[12:11],IBuff_in[5],IBuff_in[6],2'b00,
                                         5'b00010,
                                         3'b000,
                                         2'b01,IBuff_in[4:2],
                                         5'b00100,
                                         2'b11};
                            opcode_format <= 3'b000;
                        end
                        3'b010: begin //C.LW
                            inst_out <= {5'b00000,IBuff_in[5],IBuff_in[12:10],IBuff_in[6],2'b00,
                                         2'b01,IBuff_in[9:7],                                       
                                         3'b010,                                                    
                                         2'b01,IBuff_in[4:2],                                       
                                         5'b00000,
                                         2'b11};
                            opcode_format <= 3'b000;
                        end
                        3'b110: begin //C.SW
                            inst_out <= {5'b00000,IBuff_in[5],IBuff_in[12], 
                                         2'b01,IBuff_in[9:7],                                        
                                         2'b01,IBuff_in[4:2],                                        
                                         3'b010,                                                     
                                         IBuff_in[11:10],IBuff_in[6],2'b00, 
                                         5'b01000,
                                         2'b11};
                            opcode_format <= 3'b001;
                        end
                    endcase

                end
                2'b01: begin
                    case (IBuff_in[15:13])
                        3'b000: begin // C.NOP and C.ADDI
                            inst_out <= {{6{IBuff_in[12]}},IBuff_in[12],IBuff_in[6:2],
                                         IBuff_in[11:7],
                                         3'b000,
                                         IBuff_in[11:7],
                                         5'b00100,
                                         2'b11};
                            opcode_format <= 3'b000;
                        end
                        3'b001: begin // C.JAL //TODO: docs for this kinda confusing
                            inst_out <= 32'h0000_0000;
                            opcode_format <= 3'b111;
                        end
                        3'b010: begin // C.LI
                            inst_out <= {{6{IBuff_in[12]}},IBuff_in[12],IBuff_in[6:2],
                                         5'b00000,
                                         3'b000,
                                         IBuff_in[11:7],
                                         5'b00100,
                                         2'b11};
                            opcode_format <= 3'b000;
                        end
                        3'b011: begin // C.ADDI16SP and C.LUI
                            if(IBuff_in[11:7] == 5'b00010) begin // C.ADDI16SP
                                inst_out <= {{2{IBuff_in[12]}},IBuff_in[12],IBuff_in[6:2],4'b0000,
                                             5'b00010,
                                             3'b000,
                                             5'b00010,
                                             5'b00100,
                                             2'b11};
                                opcode_format <= 3'b000;
                            end else begin // C.LUI
                                inst_out <= {{14{IBuff_in[12]}},IBuff_in[12],IBuff_in[6:2],
                                             IBuff_in[11:7],
                                             5'b01101,
                                             2'b11};
                                opcode_format <= 3'b101;
                            end
                        end
                        3'b100: begin // C.SRLI, C.SRAI, C.ANDI, C.SUB, C.XOR, C.OR, and C.AND
                            case(IBuff_in[11:10])
                                2'b00: begin // C.SRLI
                                    inst_out <= {5'b00000,
                                                 2'b00,
                                                 IBuff_in[6:2],
                                                 2'b01,IBuff_in[9:7],
                                                 3'b101,
                                                 2'b01,IBuff_in[9:7],
                                                 5'b00100,
                                                 2'b11};
                                    opcode_format <= 3'b000;
                                end
                                2'b01: begin // C.SRAI
                                    inst_out <= {5'b01000,
                                                 2'b00,
                                                 IBuff_in[6:2],
                                                 2'b01,IBuff_in[9:7],
                                                 3'b101,
                                                 2'b01,IBuff_in[9:7],
                                                 5'b00100,
                                                 2'b11};
                                    opcode_format <= 3'b000;
                                end
                                2'b10: begin // C.ANDI
                                    inst_out <= {{6{IBuff_in[12]}},IBuff_in[12],IBuff_in[6:2],
                                                 2'b01,IBuff_in[9:7],
                                                 3'b111,
                                                 2'b01,IBuff_in[9:7],
                                                 5'b00100,
                                                 2'b11};
                                    opcode_format <= 3'b000;
                                end
                                2'b11: begin // C.SUB, C.XOR, C.OR, and C.AND
                                    case(IBuff_in[6:5])
                                        2'b00: begin // C.SUB
                                            inst_out <= {5'b01000,
                                                         2'b00,
                                                         2'b01,IBuff_in[4:2],
                                                         2'b01,IBuff_in[9:7],
                                                         3'b000,
                                                         2'b01,IBuff_in[9:7],
                                                         5'b01100,
                                                         2'b11};
                                        end
                                        2'b01: begin // C.XOR
                                            inst_out <= {5'b00000,
                                                         2'b00,
                                                         2'b01,IBuff_in[4:2],
                                                         2'b01,IBuff_in[9:7],
                                                         3'b100,
                                                         2'b01,IBuff_in[9:7],
                                                         5'b01100,
                                                         2'b11};
                                        end
                                        2'b10: begin // C.OR
                                            inst_out <= {5'b00000,
                                                         2'b00,
                                                         2'b01,IBuff_in[4:2],
                                                         2'b01,IBuff_in[9:7],
                                                         3'b110,
                                                         2'b01,IBuff_in[9:7],
                                                         5'b01100,
                                                         2'b11};
                                        end
                                        2'b11: begin // C.AND
                                            inst_out <= {5'b00000,
                                                         2'b00,
                                                         2'b01,IBuff_in[4:2],
                                                         2'b01,IBuff_in[9:7],
                                                         3'b111,
                                                         2'b01,IBuff_in[9:7],
                                                         5'b01100,
                                                         2'b11};
                                        end
                                    endcase
                                    opcode_format <= 3'b010;
                                end
                            endcase
                        end
                        3'b101: begin // C.J //TODO: docs for this kinda confusing
                            inst_out <= 32'h0000_0000;
                            opcode_format <= 3'b111;
                        end
                        3'b110: begin // C.BEQZ //TODO: docs for this kinda confusing
                            inst_out <= 32'h0000_0000;
                            opcode_format <= 3'b111;
                        end
                        3'b111: begin // C.BNEZ //TODO: docs for this kinda confusing
                            inst_out <= 32'h0000_0000;
                            opcode_format <= 3'b111;
                        end
                    endcase
                end

                2'b10: begin
                    case (IBuff_in[15:13])
                        3'b000: begin // C.SLLI
                            inst_out <= {5'b00000,
                                         2'b00,
                                         IBuff_in[6:2],
                                         2'b01,IBuff_in[9:7],
                                         3'b001,
                                         2'b01,IBuff_in[9:7],
                                         5'b00100,
                                         2'b11};
                            opcode_format <= 3'b000;
                        end
                        3'b010: begin // C.LWSP
                            inst_out <= {5'b00000,IBuff_in[3:2],IBuff_in[12],IBuff_in[6:4],2'b00,
                                         5'b00010,                                       
                                         3'b010,                                                    
                                         IBuff_in[11:7],                                       
                                         5'b00000,
                                         2'b11};
                            opcode_format <= 3'b000;
                        end
                        3'b100: begin // C.JR, C.MV, C.EBREAK, C.JALR, and C.ADD
                            if(IBuff_in[12] == 1'b0) begin // C.JR and C.MV
                                if(IBuff_in[6:2] == 5'b00000) begin // C.JR
                                    inst_out <= {12'b000000000000,
                                                 IBuff_in[11:7],
                                                 3'b000,
                                                 5'b00001,
                                                 5'b11001,
                                                 2'b11};
                                end else begin // C.MV
                                    inst_out <= {5'b00000,
                                                 2'b00,
                                                 IBuff_in[6:2],
                                                 5'b00000,
                                                 3'b000,
                                                 IBuff_in[11:7],
                                                 5'b01100,
                                                 2'b11};
                                end
                            end else begin // C.EBREAK, C.JALR, and C.ADD
                                if(IBuff_in[11:7] == 5'b00000) begin // C.EBREAK
                                    inst_out <= {5'b00000,
                                                 2'b00,
                                                 5'b00001,
                                                 5'b00000,
                                                 3'b000,
                                                 5'b00000,
                                                 5'b11100,
                                                 2'b11};
                                end else if(IBuff_in[6:2] == 5'b00000) begin // C.JALR
                                    inst_out <= {12'b000000000000,
                                                 IBuff_in[11:7],
                                                 3'b000,
                                                 5'b00000,
                                                 5'b11001,
                                                 2'b11};
                                end else begin // C.ADD
                                    inst_out <= {5'b00000,
                                                 2'b00,
                                                 IBuff_in[6:2],
                                                 IBuff_in[11:7],
                                                 3'b000,
                                                 IBuff_in[11:7],
                                                 5'b01100,
                                                 2'b11};
                                end
                            end
                            opcode_format <= 3'b000;
                        end
                        3'b110: begin // C.SWSP
                            inst_out <= {4'b0000,IBuff_in[8:7],IBuff_in[12], 
                                         IBuff_in[6:2],                                        
                                         5'b00001,                                        
                                         3'b010,                                                     
                                         IBuff_in[11:9],2'b00, 
                                         5'b01000,
                                         2'b11};
                            opcode_format <= 3'b001;
                        end
                    endcase
                end
            endcase

        end else begin
            compressed_inst <= 1'b0;
            inst_out <= IBuff_in;

            opcode_format <= (IBuff_in[6:2] == 5'b00000) ? 3'b000 : //I-type
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
        end
    end

endmodule