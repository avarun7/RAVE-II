module tag_next_state #(parameter TAG_SIZE = 20) (
    input [TAG_SIZE*4-1:0] tag_cur_state,
    input [TAG_SIZE-1:0] tag_in,
    input is_alloc,
    input [3:0] selected_way, 

    output reg[TAG_SIZE*4-1:0] tag_next_state
);
    always @(*) begin
        if(is_alloc) begin
            case(selected_way)
            1:tag_next_state <= {tag_cur_state[TAG_SIZE*4-1:TAG_SIZE*3], tag_cur_state[TAG_SIZE*3-1:TAG_SIZE*2], tag_cur_state[TAG_SIZE*2-1:TAG_SIZE*1], tag_in};
            2:tag_next_state <= {tag_cur_state[TAG_SIZE*4-1:TAG_SIZE*3], tag_cur_state[TAG_SIZE*3-1:TAG_SIZE*2], tag_in, tag_cur_state[TAG_SIZE*1-1:TAG_SIZE*0]};
            4:tag_next_state <= {tag_cur_state[TAG_SIZE*4-1:TAG_SIZE*3], tag_in, tag_cur_state[TAG_SIZE*2-1:TAG_SIZE*1], tag_cur_state[TAG_SIZE*1-1:TAG_SIZE*0]};
            8:tag_next_state <= {tag_in, tag_cur_state[TAG_SIZE*3-1:TAG_SIZE*2], tag_cur_state[TAG_SIZE*2-1:TAG_SIZE*1], tag_cur_state[TAG_SIZE*1-1:TAG_SIZE*0]};
            default tag_next_state <= tag_cur_state;
            endcase
        end
        else tag_next_state <= tag_cur_state;
    end
endmodule

module data_next_state #(parameter CL_SIZE = 128) (
    input [CL_SIZE*4-1:0] data_cur_state,
    input [CL_SIZE-1:0] data_in,
    input [2:0] operation,
    input [3:0] selected_way, 
    input [31:0] addr_in,
    input [1:0] size,

    output reg [CL_SIZE*4-1:0] data_next_state,
    output reg data_wb,
    output wire [CL_SIZE -1 :0] data_evic,
    output wire [31:0] rewind_data
);
    //Opeartion Names
localparam  NO_OP= 0;
localparam LD = 1;
localparam ST = 2;
localparam RD = 3;
localparam  WR= 4;
localparam  INV = 5;
localparam  UPD= 6;
localparam WR_LD = 7;
//State Names
localparam I = 1; //Invalid
localparam  PL= 11; //Pending Load
localparam  PS= 9; //Pending Store
localparam  PM= 10; //Pending Modified 
localparam  M= 4; //Modified
localparam  S= 2; //Shared
localparam PLS = 15; //Pending Load Store (edge case where store comes after load but before write)

    assign data_evic = data_to_mod;
    reg [CL_SIZE-1:0] data_to_mod, mod_data;
    wire [CL_SIZE-1:0] data_st;
    always @(*) begin 
        case(selected_way)
            1: data_to_mod <= data_cur_state[CL_SIZE-1:0];
            2: data_to_mod <= data_cur_state[CL_SIZE*2-1:CL_SIZE];
            4: data_to_mod <= data_cur_state[CL_SIZE*3-1:CL_SIZE*2];
            8: data_to_mod <= data_cur_state[CL_SIZE*4-1:CL_SIZE*3];
            default : data_to_mod <= data_cur_state[CL_SIZE-1:0];
        endcase
    end

    always @(*) begin 
        case(selected_way)
            1: data_next_state <= {data_cur_state[CL_SIZE-1:0], mod_data};
            2: data_next_state <= {data_cur_state[CL_SIZE*4-1:CL_SIZE*2],mod_data, data_cur_state[CL_SIZE-1:0]};
            4: data_next_state <= {data_cur_state[CL_SIZE*4-1:CL_SIZE*3],mod_data, data_cur_state[CL_SIZE*2-1:0]};
            8: data_next_state <= {mod_data, data_cur_state[CL_SIZE*3-1:0]};
            default : data_to_mod <= data_cur_state;
        endcase
    end
    replace_32_bit r32b(.data_in(data_in[31:0]), .shift({2'b00,addr_in[3:0]}), .data_512_in(data_to_mod),.size(size), .data_512_out(data_st), .data_replaced(rewind_data));
    always @(*) begin
        case(operation)

        ST: begin
            data_wb <= 1;
            data_next_state <= data_st;
        end

        WR: begin
            data_wb <= 1;
            mod_data <= data_in;
        end
        
        default: begin 
            data_wb <= 0;
            data_next_state <= data_cur_state;
        end
        endcase
    end
endmodule

module replace_32_bit (
    input [31:0] data_in,        
    input [5:0] shift,           
    input [127:0] data_512_in,   
    input [1:0] size,
    output reg [127:0] data_512_out,
    output reg [31:0] data_replaced
);

    integer i;

    always @(*) begin
        data_512_out = data_512_in; 
        for (i = 0; i < 16; i = i + 1) begin
            case(size)
            0:    if (i == shift) begin
                    data_replaced = data_512_out[(i * 8) +: 32];
                    data_512_out[(i * 8) +: 8] = data_in; 
                end
            1: if (i == shift) begin
                data_replaced = data_512_out[(i * 8) +: 32];
                data_512_out[(i * 8) +: 16] = data_in; 
                
            end
            2: if (i == shift) begin
                data_replaced = data_512_out[(i * 8) +: 32];
                data_512_out[(i * 8) +: 32] = data_in; 
            end
            endcase 
        end
    end
endmodule

