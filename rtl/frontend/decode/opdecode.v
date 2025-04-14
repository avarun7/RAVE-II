module opdecode #(parameter XLEN=32) (
    input clk,
    input rst,    

    input [XLEN-1:0] pc_in,
    input valid_instr_in,
    input [XLEN-1:0] instr_in,    

    //Outputs to backend
    output uop_ready_out, 
    output [6:0] uop_out, 
    output eoi_out,
    output [XLEN-1:0] imm_out, 
    output use_imm_out,
    output [XLEN-1:0] pc_out,
    output except_out,
    output [4:0] src1_arch_out, 
    output [4:0] src2_arch_out,
    output [4:0] dest_arch_out
);
reg halt;

wire[6:0] first_sev;
assign first_sev = instr_in[6:0];
assign op_mul_add = instr_in[26:25];
wire [4:0] rs1;
assign rs1 = instr_in[19:15];
wire[4:0] rst2;
assign rs2 = instr_in[24:20];
wire [4:0] rd; 
assign rd = instr_in[11:7];

reg             uop_ready_in;
reg [6:0]       uop_in;
reg             eoi_in;
reg [XLEN-1:0]  imm_in;
reg             use_imm_in;
reg [XLEN-1:0]  pcin;
reg             except_in;
reg [4:0]       src1_arch_in;
reg [4:0]       src2_arch_in;
reg [4:0]       dest_arch_in;

always @(posedge clk) begin
    if(rst) begin
        halt=0;
        uop_ready_in=0;
        uop_in=0;
        eoi_in=0;
        imm_in=0;
        use_imm_in=0;
        pcin=0;
        except_in=0;
        src1_arch_in=0;
        src2_arch_in=0;
        dest_arch_in=0;
    end
    else if(valid_instr_in && !halt) begin
        eoi_in = 0;
        imm_in = 0;
        use_imm_in = 0;
        uop_ready_in = 0;
        uop_in = 0;
        src1_arch_in = 0;
        src2_arch_in = 0;
        dest_arch_in = 0;
        pcin = 0;
        except_in = 0;
        //halt
        if(instr_in == 32'hDEAD_BEEF) halt = 1;
        //LUI
        if(first_sev == 7'b01101_11) begin
            eoi_in = 1;
            imm_in = {instr_in[31:12],12'd0};
            use_imm_in = 1;
            uop_ready_in = 1;
            uop_in = 7'b010_0000;
            src1_arch_in = 0;
            src2_arch_in = 0;
            dest_arch_in = rd;
            pcin = pc_in;
            except_in = 0;
        end
        //ADDI
        if(first_sev == 7'b00100_11) begin
            eoi_in = 1;
            imm_in = {20'd0, instr_in[31:20]};
            use_imm_in = 1;
            uop_ready_in = 1;
            uop_in = 7'b010_0000;
            src1_arch_in = rs1;
            src2_arch_in = 0;
            dest_arch_in = rd;
            pcin = pc_in;
            except_in = 0;
        end
        //ADD
        if(first_sev == 7'b01100_11 && op_mul_add == 2'b00) begin
            eoi_in = 1;
            imm_in = 0;
            use_imm_in = 0;
            uop_ready_in = 1;
            uop_in = 7'b010_0000;
            src1_arch_in = rs1;
            src2_arch_in = rs2;
            dest_arch_in = rd;
            pcin = pc_in;
            except_in = 0;
        end
        //MUL
        if(first_sev == 7'b01100_11 && op_mul_add == 2'b01) begin
            eoi_in = 1;
            imm_in = 0;
            use_imm_in = 0;
            uop_ready_in = 1;
            uop_in = 7'b100_0000;
            src1_arch_in = rs1;
            src2_arch_in = rs2;
            dest_arch_in = rd;
            pcin = pc_in;
            except_in = 0;
        end
    end
end

assign uop_ready_out = !valid_n;
qn #(.N_WIDTH(32 + CL_SIZE + 8), .M_WIDTH(0), .Q_LENGTH(Q_LENGTH)) q1(
    .m_din(),
    .n_din({eoi_in,imm_in,use_imm_in,uop_ready_in,uop_in,src1_arch_in,src2_arch_in,dest_arch_in,pcin,except_in}),
    .new_m_vector(0),
    .wr(uop_ready_in), 
    .rd(uop_ready_out),
    .modify_vector(8'b0),
    .rst(rst),
    .clk(clk),
    .full(full), 
    .empty(valid_n),
    .old_m_vector(),
    .dout({eoi_out,imm_out,use_imm_out,uop_ready_out2,uop_out,src1_arch_out,src2_arch_out,dest_arch_out,pcin,except_out})
);
//ADDI = 7'b010_0000
//MUL = 7'b100_0000
//ADD = 7'b010_0000
//HALT = 7'111_1111
//LUI = 7'b010_0000
endmodule