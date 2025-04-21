module queue_arbitrator_sync #(parameter CL_SIZE = 128, Q_WIDTH = 6) (
    input rst,    

    input[32*Q_WIDTH-1:0]   addr_in,
    input[Q_WIDTH * CL_SIZE-1:0] data_in,
    input[3*Q_WIDTH-1:0]    operation_in, 
    input [Q_WIDTH-1:0]     valid_in,
    input[2*Q_WIDTH-1:0]    src_in,
    input[2*Q_WIDTH-1:0]    dest_in,
    input [Q_WIDTH-1:0]     is_flush_in,

    input stall_in,

    input [Q_WIDTH-1:0] partner_dealloc,

    output reg[32-1:0]      addr_out,
    output wire[3-1:0]       operation_out, 
    output wire             valid_out,
    output reg[2-1:0]       src_out,
    output reg[2-1:0]       dest_out,
    output reg              is_flush_out,
    output reg[CL_SIZE-1:0] data_out,

    output wire[Q_WIDTH-1:0] dealloc,
    output wire[Q_WIDTH-1:0] dealloc_desired
);
reg[3-1:0]       operation_out_temp;
wire[Q_WIDTH-1:0] op_choice;
assign sync_stall = partner_dealloc > dealloc_desired;
pencoder_copy #(.WIDTH(Q_WIDTH)) pec1(.a(valid_in), .o(op_choice));
assign dealloc_desired =  valid_out? op_choice & {8{~stall_in}} : 0;
assign dealloc = rst ? 0 : !valid_out ? 0 : sync_stall ? 0 : op_choice & {8{~stall_in}};
assign valid_out = rst ? 0 :sync_stall ? 0 : |valid_in;
assign operation_out = sync_stall ? 0 :valid_out ? operation_out_temp : 0;

genvar i;
for(i = 0; i < Q_WIDTH; i = i + 1) begin
    always @(*) begin
    if(op_choice[i]) begin
        addr_out = !valid_out ? 0 : addr_in [i*32 + 31:i*32] ;  
        operation_out_temp = !valid_out ? 0 :operation_in [i*3 + 2:i*3] ;
        src_out = !valid_out ? 0 : src_in [i*2 + 1:i*2] ;
        dest_out = !valid_out ? 0 :dest_in [i*2 + 1:i*2]  ;
        is_flush_out = !valid_out ? 0 : is_flush_in [i]  ;
        data_out = !valid_out ? 0 :data_in[CL_SIZE*(i+1)-1:CL_SIZE*i];
        end
    end
end

endmodule

// module pencoder_copy #(parameter WIDTH=32)(
//     input [WIDTH-1:0] a,
//     input rst,
//     output reg [WIDTH-1:0] o
// );
    
//     integer unsigned i;
//     always@(*) begin
        
//         for(i = 0; i < WIDTH; i = i + 1) begin
//             if(rst) begin
//                 o[i] = 0;
//             end
//             else if(a[i]) begin
//                 o = 1 << i;
//             end
//         end
//     end

// endmodule