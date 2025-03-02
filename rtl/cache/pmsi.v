//Note: RD/WR/UPD/INV/WR_LD from L2 to Cache
//      LD/ST from pipeline to Cache

module pmsi_next_state(
    input [2:0] operation,
    input [3:0] current_state,
    input is_evict,
    output reg [3:0] next_state,
    output reg wb_to_l2
);
//Opeartion Names
localparam  NO_OP= 0;
localparam LD = 1;
localparam ST = 2;
localparam RD = 3;
localparam  WR= 4;
localparam  INV = 5;
localparam  UPD= 6;
localparam WR_LD = 7;
localparam RINV = 2;

//State Names
localparam I = 1; //Invalid
localparam  PL= 11; //Pending Load
localparam  PS= 9; //Pending Store
localparam  PM= 10; //Pending Modified 
localparam  M= 4; //Modified
localparam  S= 2; //Shared
localparam PLS = 15; //Pending Load Store (edge case where store comes after load but before write)

always @(*) begin 
    wb_to_l2 <= (is_evict && !current_state[3]) || (current_state == M && operation == RD);
end

//TODO: if pending, do you allow invalidates to occur? I dont think so
always @(*) begin
    if (is_evict && (operation == LD || operation == ST)) begin
        if(operation == LD) next_state <= PL;
        else next_state <= PS;
    end
    else begin
        case(current_state)
        I:  begin
            if(operation == LD) next_state <= PL;
            else next_state <= current_state;
            end
        PL: begin
            if(operation == WR) next_state <= S;
            else if(operation == ST) next_state <= PLS;
            else if(operation == INV || RINV == operation) next_state <= I;
            else next_state <= current_state;
            end
        S:  begin
            if(operation == ST) next_state <= PM;
            else if(operation == INV || RINV == operation) next_state <= I;
            else next_state <= current_state;
            end
        PLS: begin
            if ( operation == WR) next_state <= PM;
            else if(operation == INV || RINV == operation) next_state <= I;
            else next_state <= current_state;
            end
        PM: begin
            if(operation == UPD) next_state <= M;
            else if(operation == INV  || RINV == operation) next_state <= I;
            else next_state <= current_state;
            end
        PS: begin
            if(operation == WR) next_state <= M;
            else if(operation == INV  || RINV == operation) next_state <= I;
            else next_state <= current_state;
            end
        M: begin
            if(operation == RD) next_state <= S;
            else if(operation == INV  || RINV == operation) next_state <= I;
            else next_state <= current_state; 
        end
        default: next_state = current_state;
        endcase
    end
end

endmodule