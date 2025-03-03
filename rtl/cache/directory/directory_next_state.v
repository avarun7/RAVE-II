module directory_next_state(
    input rst,
    input [3:0] current_state,
    input [2:0] operation,
    input [1:0] src,
    input [1:0] dest,

    output [3:0] next_state
);
localparam RD = 3; //Get cache line on miss from LD
localparam WR = 4; //Send data to memory
localparam INV = 5; //Evict line from directory
localparam NOOP = 0; //WHAT DO YOU THINK IT DOES EINSTEIN????
localparam REPLY = 2; //Response from A RD request
localparam RWITM = 7; //Request from an cache miss on st
localparam UPD = 6; //request on st from a hit

localparam S = 1;
localparam M = 2;
localparam I = 0;

wire[1:0] src_state, other_state;
reg[1:0] osn, ssn;
assign src_state = src == 2 ? current_state[3:2] : src == 1 ? current_state[1:0] : 0;
assign other_state = src == 1 ? current_state[3:2] : src ==  2? current_state[1:0] : 0;
assign oim = other_state[1]; //other is modifed
assign ois = other_state[0]; //other is shared
assign oii = !oim && ! ois; //other is invalid

assign sim = src_state[1]; //source is modified
assign sis = src_state[0];
assign sii = !oim && ! ois;
initial osn = 0;
initial ssn = 0;

assign next_state = src == 2 ? {ssn, osn} : src == 1 ? {osn, ssn } : current_state;
reg [1:0] osn, ssn; //osn == other state next, ssn = source state next
always @(*) begin
    if(rst) begin
        osn = 0;
        ssn = 0;
    end
    osn = other_state;
    ssn = src_state;
    case(operation)
    RD:begin
        if(sii) begin
            ssn = S;
        end
        if(oim) begin
            osn = S;
        end
    end

    WR:begin
        if(sii) begin
            ssn = M;
        end
        if(ois) begin
            osn = I;
        end
    end

    RWITM:begin
        if(sii) begin
            ssn = M;
        end
        if(sis) begin
            ssn = M;
        end
        if(ois) begin
            osn = I;
        end
    end

    UPD:begin
        if(sii) begin
            ssn = M;
        end
        if(sis) begin
            ssn = M;
        end
        if(ois) begin
            osn = I;
        end
    end

    INV:begin
        if(sis || sim) begin
            ssn = I;
        end
    end

    NOOP:begin
        ssn = src_state;
        osn = other_state;
    end

    REPLY:begin
        ssn = src_state;
        osn = other_state;
    end
    default: begin
        ssn = src_state;
        osn = other_state;
    end
    endcase
end
endmodule