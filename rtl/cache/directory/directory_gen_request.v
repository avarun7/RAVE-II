module directory_gen_request #(parameter CL_SIZE = 128) (
    input clk,
    input rst,

    input [3:0] current_state,
    input [2:0] operation,
    input [1:0] source,
    input [1:0] dest,

    output reg mem_instr_q_alloc,
    output reg [2:0] mem_instr_q_operation,

    output reg mem_data_q_alloc,
    output reg[2:0] mem_data_q_operation,
    
    output  ic_inst_q_alloc,
    output  [2:0] ic_inst_q_operation,

    output  ic_data_q_alloc,
    output  [2:0] ic_data_q_operation,

    output  dc_inst_q_alloc,
    output  [2:0] dc_inst_q_operation,

    output  dc_data_q_alloc,
    output  [2:0] dc_data_q_operation
);
localparam RD = 3; //Get cache line on miss from LD
localparam WR = 4; //Send data to memory
localparam INV = 5; //Evict line from directory
localparam NOOP = 0; //WHAT DO YOU THINK IT DOES EINSTEIN????
localparam REPLY = 2; //Response from A RD request
localparam RWITM = 7; //Request from an cache miss on st
localparam UPD = 6; //request on st from a hit


assign d_is_src = source == 2;
reg [2:0] other_data_operation, src_data_operation, other_instr_operation, src_instr_operation;
reg other_data_alloc, src_data_alloc, other_instr_alloc, src_instr_alloc;
wire[1:0] src_state, other_state;
assign src_state = source == 2 ? current_state [3:2] : source == 1 ? current_state[1:0] : 0;
assign other_state = source == 2 ? current_state [1:0] : source == 1 ? current_state[3:2] : 0;
assign oim = other_state[1]; //other is modifed
assign ois = other_state[0]; //other is shared
assign oii = !oim && ! ois; //other is invalid

assign sim = src_state[1]; //source is modified
assign sis = src_state[0];
assign sii = !oim && ! ois;

assign ic_inst_q_alloc = d_is_src ? other_instr_alloc : src_instr_alloc;
assign ic_inst_q_operation = d_is_src ? other_instr_operation : src_instr_operation;

assign ic_data_q_alloc = d_is_src ? other_data_alloc : src_data_alloc;
assign ic_data_q_operation = d_is_src ? other_data_operation : src_data_operation ;

assign dc_inst_q_alloc = !d_is_src ? other_instr_alloc : src_instr_alloc;
assign dc_inst_q_operation = !d_is_src ? other_instr_operation : src_instr_operation;

assign dc_data_q_alloc = !d_is_src ? other_data_alloc : src_data_alloc;
assign dc_data_q_operation = !d_is_src ? other_instr_operation : src_instr_operation;



always @(*) begin
    other_instr_alloc = 0;
    other_data_alloc = 0;
    src_instr_alloc = 0;
    src_data_alloc = 0;
    mem_instr_q_alloc = 0;
    mem_data_q_alloc = 0;
    case(operation) 
        RD: begin
            if(oim) begin
                other_instr_alloc = 1;
                other_instr_operation = RD;
            end
            if(ois) begin
                other_instr_alloc = 1;
                other_instr_operation = RD;
            end
            if(sii) begin
                mem_instr_q_operation = RD;
                mem_instr_q_alloc = 1;
            end
        end
        //TODO: mem v wb
        WR: begin
            
        end
        INV : begin 
            if(sim) begin
                mem_data_q_alloc = 1;
                mem_data_q_operation = WR;
            end
        end
        //TODO: evaluate if this causes an issue on returms from memory where source is MEM (maybe default source to be where it was from)
        REPLY : begin
            src_data_alloc = 1;
            src_data_operation = WR;
        end

        RWITM : begin
            
        end

        UPD : begin
            if(ois) begin
                other_instr_operation = INV;
                other_instr_alloc = 1;
            end
            if(sis) begin
                src_instr_alloc = 1;
                src_instr_operation = UPD;
            end
        end
        WR: begin
            if(sim) begin
                mem_data_q_alloc = 1;
                mem_data_q_operation = WR;
            end
        end
        default: begin
            other_instr_alloc = 0;
            other_data_alloc = 0;
            src_instr_alloc = 0;
            src_data_alloc = 0;
            mem_instr_q_alloc = 0;
            mem_data_q_alloc = 0;
        end
    endcase
end

reg [8*6:1] opcode_names [0:7]; // Each string is max 6 chars long
reg [8*6:1] state_names[0:3];
reg [8*6:1] src_names[0:3];
integer file;
  integer count = 0;
initial begin
    file = $fopen("dir_req_log.csv", "w");
    opcode_names[0] = "NOOP";
    opcode_names[1] = "?????"; // Unused index
    opcode_names[2] = "REPLY";
    opcode_names[3] = "RD";
    opcode_names[4] = "WR";
    opcode_names[5] = "INV";
    opcode_names[6] = "UPD";
    opcode_names[7] = "RWITM";
    state_names[1] = "S";
    state_names[2] = "M";
    state_names[0] = "???";
    state_names[3] = "???";
    src_names[0] = "???";
    src_names[1] = "I$";
    src_names[2] = "D$";
    src_names[3] = "MEM";

    if (file == 0) begin
      $display("Error: Unable to open file.");
      $stop;
    end
    
    $fdisplay(file, "Time,Cycle,I$State, D$State,Source,Destination,Operation,"); // Write header
  end

  always @(posedge clk) begin
    if (rst) begin
      count <= 0;  // Reset count on reset
    end else begin
      count <= count + 1; // Increment count
      if(operation != 0) begin 
      // Write data to file at every posedge clk
         $fdisplay(file, "%t,%d,%s,%s, %s,%s,%s", $time, count, state_names[current_state[1:0]], state_names[current_state[3:2]], src_names[source], src_names[dest], operation_names[operation]);
      end 
    end
  end

//   final begin
//     // Close the file at the end of simulation
//     $fclose(file);
//     $display("File write complete.");
//   end
endmodule