module d_merge #(parameter  CL_SIZE = 128, IDX_CNT = 512, OOO_TAG_SIZE = 10, TAG_SIZE = 18) (
input clk,
input rst,

input size_in,

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

output addr_out,
output [31:0] data_out,
output [1:0] size_out,
output [2:0] operation_out,
output [OOO_TAG_SIZE-1:0] ooo_tag_out,
output valid_out
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

assign addr_0 = use_e_as_0 ? addr_in_e : addr_in_o;
assign data_0 = use_e_as_0 ? data_in_e : data_in_o;
assign size_0 = use_e_as_0 ? size_in_e : size_in_o;
assign operation_0 = use_e_as_0 ? operation_in_e : operation_in_o;
assign ooo_tag_0 = use_e_as_0 ? ooo_tag_in_e : ooo_tag_in_o;

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
assign valid_out = operation_0 == LD || operation_0 == ST;

always @(*) begin
    case(size_0)

    endcase
end
endmodule