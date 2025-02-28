module gen_request_l1(
    input [2:0] operation,
    input [3:0] current_state,
    input tag_hit,
    input mshr_hit,
    input is_evict,
    
    //output miss
    output alloc_miss,
    output reg [2:0] operation_out_miss,

    //output evic
    output alloc_evic,
    output reg [2:0] operation_out_evic
);



//Opeartion Names
localparam  NO_OP= 0;
localparam LD = 1;
localparam ST = 2;
localparam RD = 3;
localparam  WR= 4;
localparam  INV = 5;
localparam  UPD= 6;
localparam RWITM = 7;
//State Names
localparam I = 1; //Invalid
localparam  PL= 11; //Pending Load
localparam  PS= 9; //Pending Store
localparam  PM= 10; //Pending Modified 
localparam  M= 4; //Modified
localparam  S= 2; //Shared
localparam PLS = 15; //Pending Load Store (edge case where store comes after load but before write)

assign alloc_miss = ~tag_hit && ~mshr_hit && (operation == LD || operation == ST);
assign alloc_evic = (alloc_miss && is_evict) || (tag_hit && operation == INV);
always @(*) begin
    if(is_evict) begin
        operation_out_miss <= operation == ST ? RWITM : RD;
    end
    else begin
        case(current_state) 
        I: operation_out_miss <= operation == ST ? RWITM : operation == LD ? RD: 0;
        PL: operation_out_miss <= operation == ST ? RWITM : 0;
        PLS: operation_out_miss <= 0;
        PS: operation_out_miss <= 0;
        S: operation_out_miss <= operation == ST ? RWITM : 0;
        PM: operation_out_miss <= 0;
        M: operation_out_miss <=  INV == operation ? WR : 0;
        endcase
    end
end

always @(*) begin
    case(current_state) 
    I: operation_out_evic <= INV;
    PL: operation_out_evic <= INV;
    PLS: operation_out_evic <= INV;
    PS:operation_out_evic <= INV;
    S:  operation_out_evic <= INV;
    PM:operation_out_evic <= INV;
    M: operation_out_evic <= WR;
    endcase
end

endmodule