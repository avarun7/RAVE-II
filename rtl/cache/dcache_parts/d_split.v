module d_split #(parameter  CL_SIZE = 128, IDX_CNT = 512, OOO_TAG_SIZE = 10, TAG_SIZE = 18) (
    input clk,
    input rst,

    input stall,
    
    input [31:0] addr_in,
    input [CL_SIZE-1:0] data_in,
    input [1:0] size_in,
    input [2:0] operation_in,
    input [OOO_TAG_SIZE-1:0] ooo_tag_in,

    output [31:0] addr_out_e,
    output [CL_SIZE-1:0] data_out_e,
    output [1:0] size_out_e,
    output [2:0] operation_out_e,
    output [OOO_TAG_SIZE-1:0] ooo_tag_out_e,

    output [31:0] addr_out_o,
    output [CL_SIZE-1:0] data_out_o,
    output [1:0] size_out_o,
    output [2:0] operation_out_o,
    output [OOO_TAG_SIZE-1:0] ooo_tag_out_o,

    output wake_e,
    output wake_o,
    output out_q_alloc,
    output use_e_as_0,
    output need_p1

);
//TODO: Update so siz0 = 1B, size1 = 2B, size2 = 3B, and size3 = 4B
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

reg[31:0] addr_p1;
wire[4:0] ovr_flw_chk;
assign ovr_flw_chk = {1'b0,addr_in[3:0]} + (size_in);

assign need_p1 = ovr_flw_chk[4] && (operation_in == ST || operation_in == LD);
assign size_1 = ovr_flw_chk[1:0] ;
assign size_0 = need_p1 ? size_in - (size_1 + 1) : size_in;
assign addr_0 = addr_in;
assign addr_1 = {addr_in[31:4] + 28'd1, 4'd0}; 

assign operation_0 = operation_in;
assign operation_1 = need_p1 ? operation_in : operation_in == LD ? LD : NOOP;

assign ooo_tag_1 = ooo_tag_in;
assign ooo_tag_0 = ooo_tag_in;

assign data_0 = data_in;
assign data_1 = size_0 == 2 ? data_in >> 24 :  size_0 == 1 ? data_in >> 16 : data_in >> 8;

assign wake_0 = operation_0 == NOOP;
assign wake_1 = !need_p1;

assign out_q_alloc = (operation_0 == ST || operation_0 == LD) && !stall;

assign addr_out_e = addr_in[4] == 0 ? addr_0 : addr_1;
assign data_out_e = addr_in[4] == 0 ? data_0 : data_1;
assign size_out_e = addr_in[4] == 0 ? size_0 : size_1;
assign operation_out_e = addr_in[4] == 0 ? operation_0 : operation_1;
assign ooo_tag_out_e = addr_in[4] == 0 ? ooo_tag_0 : ooo_tag_1;
   
assign addr_out_o = addr_in[4] == 1 ? addr_0 : addr_1;
assign data_out_o = addr_in[4] == 1 ? data_0 : data_1;
assign size_out_o = addr_in[4] == 1 ? size_0 : size_1;
assign operation_out_o = addr_in[4] == 1 ? operation_0 : operation_1;
assign ooo_tag_out_o = addr_in[4] == 1 ? ooo_tag_0 : ooo_tag_1;

assign use_e_as_0 = addr_in[4]==0;
endmodule
