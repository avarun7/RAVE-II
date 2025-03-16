module c_TOP #(parameter XLEN=32, CLC_WIDTH = 28) (
    input clk, rst,

    //inputs
    input stall_in,
    input resteer,
    
    input [XLEN - 1:0] resteer_target_D1,
    input resteer_taken_D1,

    input [XLEN - 1:0] resteer_target_BR,
    input resteer_taken_BR,

    input [XLEN - 1:0] resteer_target_ROB,
    input resteer_taken_ROB,

    input ras_push,
    input ras_pop,
    input [XLEN - 1:0] ras_ret_addr,
    input ras_valid_in,
    
    //outputs
    output reg [CLC_WIDTH - 1 : 0] clc_even,
    output reg [CLC_WIDTH - 1 : 0] clc_odd,
    output reg [XLEN - 1:0] ras_data_out,
    output reg ras_valid_out
);


    reg [CLC_WIDTH - 1 : 0] clc;

    // instantiate RAS
    ras ras1 (
        .clk(clk),
        .rst(rst),
        .valid_in(ras_valid_in),
        .push(ras_push),
        .pop(ras_pop),
        .data_in(ras_ret_addr),

        .result(ras_data_out),
        .empty(),
        .full(),
        .valid_out(ras_valid_out)
    );

    // logic to update the cacheline counter
    always @(posedge clk) begin
        if (rst) begin
            clc <= 0;
        end else if (stall_in) begin
            clc <= clc;
        end else if (resteer) begin
            if (resteer_taken_ROB) begin
                clc <= resteer_target_ROB [31:4]; //since clc is 28 bits
            end else if (resteer_taken_D1) begin
                clc <= resteer_target_D1 [31:4];
            end else if (resteer_taken_BR) begin
                clc <= resteer_target_BR [31:4];
            end else if (ras_valid_out) begin
                clc <= ras_data_out [31:4];
            end
        end else begin
            clc <= clc + 1;
        end
    end

    // logic to check if the address is even or odd, and 
    // generate the even and odd addresses
    always @(*) begin
        if (clc[0] == 1'b0) begin
            clc_even <= clc;
            clc_odd <= clc + 1;
        end else begin
            clc_even <= clc + 1;
            clc_odd <= clc;
        end
    end

endmodule
