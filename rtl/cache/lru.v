module lru_next_state (
    input [3:0] selected_way,
    input [15:0] lru_state_in,

    output reg [15:0] lru_state_out
);
    wire[3:0] w1, w2, w3, w4;
    reg[3:0] w1_out, w2_out, w3_out, w4_out, updated_way;
    assign w1 = lru_state_in[3:0];
    assign w2 = lru_state_in[7:4];
    assign w3 = lru_state_in[11:8];
    assign w4 = lru_state_in[15:12];

    //Figure out baseline
    always @(*) begin
        case(selected_way)
            1: updated_way <= w1;
            2: updated_way <= w2;
            4: updated_way <= w3;
            8: updated_way <= w4;
            default: updated_way <= w1;
        endcase
    end
    genvar i;
    generate 
        for(i = 0; i < 4; i = i + 1) begin: looper
            always @(*) begin
                if(lru_state_in[i*4+3:i*4] < updated_way) lru_state_out[i*4+3:i*4] <= lru_state_in[i*4+3:i*4];
                else if (lru_state_in[i*4+3:i*4] > updated_way) lru_state_out[i*4+3:i*4] <= lru_state_in[i*4+3:i*4] >> 1;
                else lru_state_out[i*4+3:i*4] <= 4'b1000;
            end
        end
    endgenerate 
    
endmodule