module dram_bank #(parameter CL_SIZE = 128, file_name = 1) (
input rst,
input clk,

input [31:0] addr_in,
input [2:0] operation_in,
input valid_in,
input [1:0]src_in,
input [1:0]dest_in,
input is_flush_in,
input [CL_SIZE-1:0] data_in,

output reg[31:0] addr_out,
output reg [2:0] operation_out,
output reg valid_out,
output reg [1:0]src_out,
output reg [1:0]dest_out,
output reg is_flush_out,
output reg [CL_SIZE-1:0] data_out,

output reg stall_out
);
localparam RD = 3; //Get cache line on miss from LD
localparam WR = 4; //Send data to memory
localparam INV = 5; //Evict line from directory
localparam NOOP = 0; //WHAT DO YOU THINK IT DOES EINSTEIN????
localparam REPLY = 2; //Response from A RD request
localparam RWITM = 7; //Request from an cache miss on st
localparam UPD = 6; //request on st from a hit
localparam RINV = 7; //READ AND INVALIDATE
reg [CL_SIZE-1:0] mem_bank[0:4095];

reg[6:0] state_bank;

reg [31:0] addr_buf;
reg [2:0] operation_buf;
reg valid_buf;
reg [1:0]src_buf;
reg [1:0]dest_buf;
reg is_flush_buf;
reg [CL_SIZE-1:0] data_buf;

always @(posedge clk) begin
    if(rst) begin
        state_bank = 0;
        valid_buf = 0;
        operation_buf = 0;
        valid_out = 0;
        operation_out = 0;
    end
    valid_out = 0;
    operation_out = 0;
    case(state_bank) 
        0: begin 
            stall_out = 0;
            if(valid_in && operation_in != 0) begin
                state_bank = 1;
                addr_buf = addr_in;
                operation_buf = operation_in;
                valid_buf = valid_in;
                src_buf = src_in;
                dest_buf = dest_in;
                is_flush_buf = is_flush_in;
                data_buf = data_in;
            end
        end
        1: begin
            stall_out = 1;
            state_bank = 2;
        end
        2: begin
            stall_out = 1;
            state_bank = 3;
        end
        3: begin
            stall_out = 1;
            state_bank = 4;
        end
        4: begin
            stall_out = 1;
            state_bank = 5;
        end
        5: begin 
            state_bank = 0;
            stall_out = 1;
            data_out = mem_bank[addr_buf[16:5]];
            if(operation_buf == WR) begin
                mem_bank[addr_buf[16:5]] = data_buf;
            end
            valid_out = operation_buf == WR ? 0 : 1;
            operation_out = operation_buf == RD ? WR : NOOP ;
            src_out = 3;
            dest_out = src_buf;
            addr_out = addr_buf;
            is_flush_out = 0;
        end
    endcase
end

initial begin
    if(file_name == 1) begin 
        $readmemh("banke_data.hex", mem_bank); // Load bank0 from hex file
    end
    else begin
        $readmemh("banko_data.hex", mem_bank); // Load bank1 from hex file
    end
end

endmodule