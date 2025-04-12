module pulse_syncronizer(
    input clk_in, clk_out, rst_n,

    input pulse_in,
    output reg pulse_out
);

reg pulse_a;
reg pulse_b;

initial begin
    pulse_a = 0;
    pulse_b= 0;
end

always @(posedge clk_in or negedge rst_n) begin
    if(!rst_n) begin
        pulse_a <= 0;
        pulse_b <= 0;
    end
    else begin
        pulse_a <= pulse_in;
    end
end

always @(posedge clk_out or negedge rst_n) begin
    if(!rst_n) begin
        pulse_a <= 0;
        pulse_b <= 0;
    end
    else begin
        pulse_b <= pulse_a;
        pulse_out <= pulse_b;
    end
    
end 

endmodule


// wr || rd || Current || Next    
    0       0       0      0      
    0       0       1      1
    0       0       2      2
    0       1       0      0
    0       1       1      0
    0       1       2      1
    1       0       0      1
    1       0       1      2
    1       0       2      2   
    1       1       0      1
    1       1       1      1
    1       1       2      1

typedef enum{
    IDLE, 
    FILL0,
    FILL1
} State;

module ctrl(
    input clk, rst_n,
    input wr, rd,
    output reg empty,
    output reg full
);
State state, nextState;

always @(posedge clk or negedge rst_n)begin
    if(!rst_n) begin
        state <= IDLE;
    end
    else state <= nextState;
end

always @(*) begin
    case(state):

        IDLE: begin
            empty <= 1;
            nextState = (wr) ? FILL0 : IDLE;
        end
        
        FILL0: begin
            empty <= 0;
            full <= 0;
            nextState = (wr & !rd) ? FILL1 : ((rd & !wr) ? IDLE : FILL0);
        end

        FILL1: begin
            full <= 1;
            nextState = (rd) ? FILL0 : FILL1;
        end

        default: begin
            nextState = IDLE;

        end
        
    endcase
    
end


endmodule
         