module queue_arbitrator #(parameter CL_SIZE = 128, Q_WIDTH = 6) (
    input[32*Q_WIDTH-1:0]   addr_in,
    input[Q_WIDTH/2 * CL_SIZE-1:0] data_in,
    input[3*Q_WIDTH-1:0]    operation_in, 
    input [Q_WIDTH-1:0]     valid_in,
    input[2*Q_WIDTH-1:0]    src_in,
    input[2*Q_WIDTH-1:0]    dest_in,
    input [Q_WIDTH-1:0]     is_flush_in,

    output reg[32-1:0]      addr_out,
    output wire[3-1:0]       operation_out, 
    output wire             valid_out,
    output reg[2-1:0]       src_out,
    output reg[2-1:0]       dest_out,
    output reg              is_flush_out,
    output reg[CL_SIZE-1:0] data_out,

    output wire[Q_WIDTH-1:0] dealloc
);
reg[3-1:0]       operation_out_temp;
wire[Q_WIDTH-1:0] op_choice;
pencoder_copy #(.WIDTH(Q_WIDTH)) pec1(.a(valid_in), .o(op_choice));
assign dealloc = op_choice;
assign valid_out = |op_choice;
assign operation_out = valid_out ? operation_out_temp : 0;

genvar i;
for(i = 0; i < Q_WIDTH; i = i + 1) begin
    always @(*) begin
    if(i == op_choice) begin
        addr_out = addr_in [i*32 + 31:i*32] ;  
        operation_out_temp = operation_in [i*3 + 2:i*3] ;
        src_out = src_in [i*2 + 1:i*2] ;
        dest_out = dest_in [i*2 + 1:i*2]  ;
        is_flush_out = is_flush_in [i]  ;
        data_out = data_in[CL_SIZE*(i+1)-1:CL_SIZE*i];
        end
    end
end

endmodule

module pencoder_copy #(parameter WIDTH=32)(
    input [WIDTH-1:0] a,
    output reg [WIDTH-1:0] o
);

    integer unsigned i;
    always@(*) begin
        for(i = 0; i < WIDTH; i = i + 1) begin
            if(a[i]) begin
                o = 1 << i;
            end
        end
    end

endmodule