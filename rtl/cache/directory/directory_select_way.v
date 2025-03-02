module directory_select_way #(parameter CL_SIZE = 4, TAG_SIZE = 18) (
    input clk,
    input rst,

    input [TAG_SIZE-1:0] tag_in,
    input [TAG_SIZE*8-1:0] tag_cur_state,
    input [CL_SIZE*8-1:0] data_cur_state,

    input [2:0] operation,
    input [1:0] src,
    input [1:0] dest,

    output [TAG_SIZE*8-1:0] tag_next_state,
    output [CL_SIZE*8-1:0] data_next_state
);

wire[7:0] hits;
wire[7:0] valid_list;
wire[7:0] selected_way;
reg[3:0] selected_data;
wire[3:0] data_next;
genvar i;
for(i = 0; i < 8; i = i + 1) begin : ands
    assign hits[i] = tag_in == tag_cur_state[i*8+7:i*8];
    assign valid_list[i] = |data_cur_state[i*4+3:i*4];
    assign selected_way[i] = hits[i] & valid_list[i]; 
end

always @(*) begin
    data_next_sate = data_cur_state;
    casex(hits)
        8'b1XXX_XXXX :  begin selected_data = data_cur_state[7*4+3:7*4]; data_next_state[7*4+3:7*4] = data_next; end
        8'b01XX_XXXX :  begin selected_data = data_cur_state[6*4+3:6*4]; data_next_state[6*4+3:6*4] = data_next; end
        8'b001X_XXXX :  begin selected_data = data_cur_state[5*4+3:5*4]; data_next_state[5*4+3:5*4] = data_next; end
        8'b0001_XXXX :  begin selected_data = data_cur_state[4*4+3:4*4]; data_next_state[4*4+3:4*4] = data_next; end
        8'b0000_1XXX :  begin selected_data = data_cur_state[3*4+3:3*4]; data_next_state[3*4+3:3*4] = data_next; end
        8'b0000_01XX :  begin selected_data = data_cur_state[2*4+3:2*4]; data_next_state[2*4+3:2*4] = data_next; end
        8'b0000_001X :  begin selected_data = data_cur_state[1*4+3:1*4]; data_next_state[1*4+3:1*4] = data_next; end
        8'b0000_0001 :  begin selected_data = data_cur_state[0*4+3:0*4]; data_next_state[0*4+3:0*4] = data_next; end
    endcase
end

directory_next_state dns(
   .rst(rst),
   .current_state(selected_data),
   .operation(operation),
   .src(src),
   .dest(dest),
//Ouptuts
   .next_state(data_next)
);
endmodule