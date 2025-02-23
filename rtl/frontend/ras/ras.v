module ras #(parameter XLEN=32, parameter DEPTH=128)(
    input clk, rst, valid_in,
    input              push,
    input              pop,
    input [XLEN-1:0]  data_in,
    
    output reg [XLEN-1:0]  result,
    output reg             empty,
    output reg             full,
    output reg             valid_out
);
reg [XLEN-1:0]        stack [0:DEPTH-1];
reg [$clog2(DEPTH):0]  stack_ptr;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        stack_ptr <= 0;
        empty <= 1;
        full <= 0;

    end else begin
        if(valid_in | !(pop & push)) begin
            if (push && !full) begin
                stack[stack_ptr] <= data_in;
                stack_ptr        <= stack_ptr + 1;
                empty            <= 0;
                valid_out <= 0;         // Push shouldn't return a value
                result <= {XLEN{1'b0}};
    
                if (stack_ptr == DEPTH - 1) begin   //Needs to use old value to determine this
                    full <= 1;
                end
    
            end else if (pop && !empty) begin
                result <= stack[stack_ptr - 1];
                stack_ptr <= stack_ptr - 1;
                valid_out <= 1;
                full      <= 0;
    
                if (stack_ptr == 1) begin
                    empty <= 1;
                end
            end
            else begin
                valid_out <= 0;
                result <= {XLEN{1'b0}};
            end
        end
        else valid_out <= 0;
        
    end
end

endmodule