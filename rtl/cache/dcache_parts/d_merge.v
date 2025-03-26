module d_merge #(parameter  CL_SIZE = 128, IDX_CNT = 512, OOO_TAG_SIZE = 10, TAG_SIZE = 18) (
input clk,
input rst,

input size_in,
input sext_in,

input [31:0] even_rwnd_data,
input [31:0] odd_rwnd_data,


input [31:0] addr_in_e,
input [CL_SIZE-1:0] data_in_e,
input [1:0] size_in_e,
input [2:0] operation_in_e,
input [OOO_TAG_SIZE-1:0] ooo_tag_in_e,

input [31:0] addr_in_o,
input [CL_SIZE-1:0] data_in_o,
input [1:0] size_in_o,
input [2:0] operation_in_o,
input [OOO_TAG_SIZE-1:0] ooo_tag_in_o,

input wake_e,
input wake_o,
input hit_e,
input hit_o,
input use_e_as_0,
input need_p1,

output addr_out, //done
output reg [31:0] data_out, //done
output [1:0] size_out, //done
output [2:0] operation_out, //done
output [OOO_TAG_SIZE-1:0] ooo_tag_out, //done
output valid_out, //done

output [31:0] rwnd_data
);
localparam  NOOP= 0;
localparam LD = 1;
localparam ST = 2;
localparam RD = 3;
localparam  WR= 4;
localparam  INV = 5;
localparam  UPD= 6;
localparam WR_LD = 7;


localparam RWITM = 7;
localparam RINV = 7;


//Handle just one cache line
wire [31:0] addr_0; //done
wire [CL_SIZE-1:0] data_0; //done
wire [1:0] size_0; //done
wire  [2:0] operation_0; //done
wire [OOO_TAG_SIZE-1:0] ooo_tag_0; //done
wire wake_0;

wire [31:0] addr_1; //done
wire [CL_SIZE-1:0] data_1; //done 
wire [1:0] size_1; //done
wire  [2:0] operation_1; //done
wire [OOO_TAG_SIZE-1:0] ooo_tag_1; //done
wire wake_1;
wire [31:0]rwnd_data_0, rwnd_data_1;
assign rwnd_data_0 = use_e_as_0 ? even_rwnd_data : odd_rwnd_data;
assign hit_0 = use_e_as_0 ? hit_e : hit_o;
assign addr_0 = use_e_as_0 ? addr_in_e : addr_in_o;
assign data_0 = use_e_as_0 ? data_in_e : data_in_o;
assign size_0 = use_e_as_0 ? size_in_e : size_in_o;
assign operation_0 = use_e_as_0 ? operation_in_e : operation_in_o;
assign ooo_tag_0 = use_e_as_0 ? ooo_tag_in_e : ooo_tag_in_o;

assign rwnd_data_1 = !use_e_as_0 ? even_rwnd_data : odd_rwnd_data;
assign hit_1 = !use_e_as_0 ? hit_e : hit_o;
assign addr_1 = !use_e_as_0 ? addr_in_e : addr_in_o;
assign data_1 = !use_e_as_0 ? data_in_e : data_in_o;
assign size_1 = !use_e_as_0 ? size_in_e : size_in_o;
assign operation_1 = !use_e_as_0 ? operation_in_e : operation_in_o;
assign ooo_tag_1 = !use_e_as_0 ? ooo_tag_in_e : ooo_tag_in_o;

assign addr_out = addr_0;
// assign data_out = need_p1 ? data_1 << (addr_0[3:0] <<8) | data_0 >> (addr_0[3:0] << 3): data_0 >> (addr_0[3:0] << 3);
assign size_out = size_in;
assign operation_out = operation_0;
assign ooo_tag_out = ooo_tag_0;
assign valid_out = (operation_0 == LD || operation_0 == ST) && (need_p1 ? hit_e && hit_o : hit_0 ) ;

reg[31:0] data_1_concat;
reg[31:0] data_0_concat;

wire [CL_SIZE * 2 -1 : 0] data_full, data_shift;
assign data_full = {data_1, data_0};
assign data_shift = data_full >>> (addr_0[3:0]* 8);

always @(*) begin
    if(sext_in) begin
    case(size_in) 
        0: data_out = {data_shift[7:0], 24'd0} >>> 24;
        1: data_out = {data_shift[15:0], 16'd0} >>> 16;
       
        3: data_out = data_shift[31:0];
        default: data_out = 0;
    endcase
    end
    else begin
        case(size_in) 
        0: data_out = {data_shift[7:0], 24'd0} >> 24;
        1: data_out = {data_shift[15:0], 16'd0} >> 16;
       
        3: data_out = data_shift[31:0];
        default: data_out = 0;
        endcase
    end
end
wire[63:0] rwnd_concat;
wire [31:0] shift_amt;
assign shift_amt = size_0 << 3;
assign rwnd_concat = {rwnd_data_1,rwnd_data_0};
assign rwnd_data = need_p1 ? (rwnd_concat >> shift_amt): rwnd_data_0;
// always @(*) begin
//     case(size_1) 
//         0: data_1_concat = {data_1[7:0], 24'd0};
//         1: data_1_concat = {data_1[15:0], 16'd0};
//         2: data_1_concat = {data_1[23:0], 8'd0};
//     endcase
// end
// wire [CL_SIZE-1:0] data_0_shift;
// assign data_0_shift = data_0 >> (8 * addr_0[3:0]);
// always @(*) begin
//     case(size_0) 
//         0: data_0_concat = {24'd0, data_0_shift[7:0]};
//         1: data_0_concat = {16'd0, data_0_shift[15:0]};
//         2: data_0_concat =  {8'd0, data_0_shift[23:0]};
//         3: data_0_concat =  {data_0_shift[31:0]};
//     endcase
// end
// wire [31:0] data_1_shift;
// assign data_1_concat = 
endmodule