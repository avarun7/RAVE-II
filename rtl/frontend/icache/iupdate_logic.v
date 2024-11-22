module iupdate_logic  #(parameter SET_CNT = 1024,parameter CACHE_LINE = 512, parameter ADDR_SZ = 32) (
    //Global Inputs
    input clk,
    input rst,

    //inputs from f2
    input [(ADDR_SZ - $clog2(SET_CNT) - $clog2(CACHE_LINE))-1:0] f2_tag_addr_in,
    input [2:0] f2_op_in,
    input [CACHE_LINE * 4 - 1: 0] f2_data_in,
    input [(ADDR_SZ - $clog2(SET_CNT) - $clog2(CACHE_LINE))*4 - 1:0] f2_tag_in,
    input [$clog2(SET_CNT)-1:0] f2_index_in,
    input [5*4-1:0] f2_meta_in,
    input [2:0] f2_plru_in,
    input [3:0] f2_hit_in,
    input [CACHE_LINE-1:0] l2_data_in,
    input f2_is_l2_req,

    //outputs for pipeline
    output reg cache_hit,
    output reg [CACHE_LINE-1:0] f2_data_out,

    //outputs for tag store
    output reg tag_write_out, //done
    output reg tag_plru_update, //done
    output reg [(ADDR_SZ - $clog2(SET_CNT) - $clog2(CACHE_LINE))*4 - 1:0] tag_out, //done
    output reg [5*4-1:0] tag_meta_out,//done
    output reg [2:0] tag_plru_out, //done
    output  [3:0] tag_way_out, //done

    //outputs for data_store
    output reg data_write_out,

    //global outputs
    output reg stall

);
reg evict;
assign valid_in = (f2_op_in != 0);
assign hit = (|f2_hit_in);
//Process pipeline requests
always @(posedge clk)begin
    case(f2_hit_in)
        4'h1: f2_data_out <= f2_data_in[CACHE_LINE-1:0];
        4'h2: f2_data_out <= f2_data_in[CACHE_LINE*2-1:CACHE_LINE];
        4'h4: f2_data_out <= f2_data_in[CACHE_LINE*3-1:CACHE_LINE*2];
        4'h8: f2_data_out <= f2_data_in[CACHE_LINE*4-1:CACHE_LINE*3];
        default: f2_data_out <= 0;
    endcase
    cache_hit <= valid_in && hit;
end

//process tag store
assign all_valid = f2_meta_in[4] & f2_meta_in[9] & f2_meta_in[14] & f2_meta_in[19];   
assign all_cl_ptc = f2_meta_in[2] & f2_meta_in[7] & f2_meta_in[12] & f2_meta_in[17] ; 

wire[3:0] valid_bits;
assign valid_bits = {f2_meta_in[19],f2_meta_in[14],f2_meta_in[9],f2_meta_in[4]};
assign ld_bits = {f2_meta_in[16], f2_meta_in[11], f2_meta_in[6], f2_meta_in[1]};

reg[3:0] replacement_way;
wire[15:0] replacement_order ;
assign replacement_order =  ~f2_plru_in[2] & f2_plru_in[1] ? 16'b0100_1000_0010_0001:
                            ~f2_plru_in[2] & ~f2_plru_in[1] ? 16'b1000_0100_0001_0010:
                            f2_plru_in[2] & f2_plru_in[0] ? 16'b0001_0010_1000_0100 :
                            16'b0010_0001_0100_1000;
// assign replacement_way = f2_plru_in[2] & f2_plru_in[1] & f2_meta_in[17] ? 4'b1000 :
//                         f2_plru_in[2] & ~f2_plru_in[1] & f2_meta_in[12] ? 4'b0100 :
//                         ~f2_plru_in[2] & f2_plru_in[0] & f2_meta_in[7] ? 4'b0010 :
//                         ~f2_plru_in[2] & ~f2_plru_in[0] & f2_meta_in[2] ? 4'b0001 :             

assign tag_way_out = replacement_way;
always @(posedge clk) begin
    stall = all_cl_ptc && valid_in && !hit;
    tag_write_out <= !stall & !hit && valid_in;
    tag_plru_update <= valid_in;
    
    if(&valid_bits) begin
        casez(valid_bits)
            4'b0???:replacement_way = 8;
            4'b10??:replacement_way = 4;
            4'b110?:replacement_way = 2;
            4'b1110:replacement_way = 1;
        endcase
    end else begin
        case(~ld_bits) 
            4'h0: replacement_way = 0;
            4'h1: replacement_way = 4'b0001;  
            4'h2: replacement_way = 4'b0010;
            4'h3: replacement_way = f2_plru_in[2] ? replacement_order[15:12] : replacement_order[7:4];
            4'h4: replacement_way = 4'b0100;
            4'h5: replacement_way = f2_plru_in[2] ? 4'b0001 : 4'b0100;
            4'h6: replacement_way = f2_plru_in[2] ? 4'b0010 : 4'b0100;
            4'h7: replacement_way = f2_plru_in[2] ? replacement_order[15:12] : 4'b0100;
            4'h8: replacement_way = 4'b1000;
            4'h9: replacement_way = f2_plru_in[2] ? 4'b0001 : 4'b1000;
            4'ha: replacement_way = f2_plru_in[2] ? 4'b0010 : 4'b1000;
            4'hb: replacement_way = f2_plru_in[2] ? replacement_order[15:12] : 4'b1000;
            4'hc: replacement_way = f2_plru_in[2] ? replacement_order[7:4] : replacement_order[15:12];
            4'hd: replacement_way = f2_plru_in[2] ?  4'b0001 : replacement_order[15:12];
            4'he: replacement_way = f2_plru_in[2] ?  4'b0010 : replacement_order[15:12];
            4'hf: replacement_way = replacement_order[15:12];
        endcase
    end

    case(f2_hit_in)
        4'h1: tag_out <=  {f2_tag_in[CACHE_LINE*4-1:CACHE_LINE],f2_tag_addr_in} ;
        4'h2: tag_out <=  {f2_tag_in[CACHE_LINE*4-1:CACHE_LINE*2], f2_tag_addr_in,f2_tag_in[CACHE_LINE-1:0] };
        4'h4: tag_out <=  {f2_tag_in[CACHE_LINE*4-1:CACHE_LINE*3], f2_tag_addr_in,f2_tag_in[CACHE_LINE*2-1:0] };
        4'h8: tag_out <=  {f2_tag_addr_in,f2_tag_in[CACHE_LINE*3-1:0]};
        default: tag_out <= f2_tag_in;
    endcase

    //Updated PLRU
    //MS bit == 1 = Way 3/4 accessed last
    //2nd bit == 1 =  Way 4 newer than Way 3
    //LS bit == 1 = Way 2 newer than Way 1
    tag_plru_out[2] <= f2_hit_in[3] || f2_hit_in[2];// a b c d
    tag_plru_out[1] <= f2_hit_in[3] || f2_hit_in[2] ? f2_hit_in[3] : f2_plru_in[1];
    tag_plru_out[0] <= f2_hit_in[3] || f2_hit_in[2] ? f2_plru_in[0] : f2_hit_in[1]; 

    //Update Meta Store
end

always @(posedge clk) begin
    case(f2_hit_in) 
        4'h1:data_write_out <={l2_data_in[19:5],next_state};
        4'h2:data_write_out <={l2_data_in[19:10],next_state,l2_data_in[4:0]};
        4'h4:data_write_out <={l2_data_in[19:15],next_state,l2_data_in[9:0]};
        4'h8:data_write_out <={next_state,l2_data_in[14:0]};
        default: data_write_out <= f2_data_in;
    endcase 
end

inext_state i1( clk, 
                rst, 
                valid_in, 
                f2_meta_in, 
                ~f2_is_l2_req && f2_op_in == 3'b001, 
                ~f2_is_l2_req && f2_op_in == 3'b010, 
                f2_is_l2_req && f2_op_in == 3'b010, 
                f2_is_l2_req && f2_op_in == 3'b100, 
                tag_write_out, 
                f2_way_in,
                tag_way_out,
                tag_meta_out
                );

endmodule 