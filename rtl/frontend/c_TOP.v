module c_TOP #(parameter XLEN=32) (
    input clk, rst,

    //inputs
    input stall_in,
    input resteer,
    
    input bp_update_D1, //1b
    input [XLEN - 1:0] resteer_target_D1,
    input resteer_taken_D1,
    input [9:0] clbp_update_bhr_D1,  

    input bp_update_BR, //1b
    input [XLEN - 1:0] resteer_target_BR,
    input resteer_taken_BR,
    input [9:0] clbp_update_bhr_BR,  

    input bp_update_ROB, //1b
    input [XLEN - 1:0] resteer_target_ROB,
    input resteer_taken_ROB,
    input [9:0] clbp_update_bhr_ROB,

    input ras_push,
    input ras_pop,
    input [XLEN - 1:0] ras_ret_addr,
    input ras_valid_in,
    
    //outputs
    output reg [25:0] clc, //cacheline counter 
    output reg  [25:0] nlpf //next-line prefetch

    output reg [XLEN - 1:0] ras_data_out;
    output reg ras_valid_out; //TODO: should these be regs or wires?
    // output reg [25:0] bppf  //branch-predictor prefetch
);

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
        .valid_out(ras_valid_out),
    );

    // logic to update the cacheline counter
    always @(posedge clk) begin
        if (rst) begin
            clc <= 0;
        end else if (stall_in) begin
            clc <= clc;
        end else if (resteer) begin
            if (resteer_taken_ROB) begin
                clc <= resteer_target_ROB [31:6];
            end else if (resteer_taken_D1) begin
                clc <= resteer_target_D1 [31:6];
            end else if (resteer_taken_BR) begin
                clc <= resteer_target_BR [31:6];
            end else if (ras_valid_out) begin
                clc <= ras_data_out [31:6];
            end
        end else begin
            clc <= clc + 64;
        end
    end


endmodule
