module qnm #(parameter N_WIDTH = 8, M_WIDTH = 8, Q_LENGTH = 8) (
    input [M_WIDTH-1:0] m_din,
    input [N_WIDTH-1:0] n_din,
    input [M_WIDTH*Q_LENGTH-1:0] new_m_vector,
    input wr, rd,
    input [Q_LENGTH-1:0] modify_vector,
    input rst,
    input clk,
    output full, empty,
    output [M_WIDTH*Q_LENGTH-1:0] old_m_vector,
    output [M_WIDTH+N_WIDTH-1:0] dout
);

reg [Q_LENGTH-1:0] wr_ptr, rd_ptr;
reg [N_WIDTH+M_WIDTH-1:0] queue[Q_LENGTH-1:0];
wire [(M_WIDTH+N_WIDTH) * Q_LENGTH -1:0] flat_queue;
genvar k;
generate
    for (k = 0; k < Q_LENGTH; k = k + 1) begin : flatten
        assign flat_queue[(k * (M_WIDTH+N_WIDTH)) +: (M_WIDTH+N_WIDTH)] = queue[k];
        assign old_m_vector[(k * (M_WIDTH)) +: (M_WIDTH)] = flat_queue[(k * (M_WIDTH+N_WIDTH)) +: (M_WIDTH)];
    end
endgenerate


mux_nm #(M_WIDTH+N_WIDTH, Q_LENGTH) mnm1 (
    .data_in(flat_queue),   
    .one_hot_sel(rd_ptr),
    .data_out(dout) 
); 

genvar i;
for(i = 0; i < Q_LENGTH; i= i + 1) begin :plz
    initial begin
        queue[i] = 0;

    end
end
initial begin 
    wr_ptr = 1;
    rd_ptr = 1;
end
wire[2:0] index;
onehot_2_bin oh2b(
    .a(wr_ptr),
    .b(index)
);
integer j, p;
assign empty = wr_ptr == rd_ptr;
assign full = wr_ptr << 1 == rd_ptr || wr_ptr << 1 == rd_ptr-1;
always @(posedge clk or rst) begin
    if(rst) begin
        wr_ptr <= 8'h1;
        rd_ptr <= 8'h1;
        for (j = 0; j < Q_LENGTH; j = j +1) begin: plz2
            queue[j] = 0;
   
        end
    end
    else begin
        if(!full) begin
            if(wr) begin
                
                queue[index] = {n_din, m_din};
                wr_ptr = wr_ptr[Q_LENGTH-1] == 1 ? 1 : wr_ptr << 1;
            end
        end  
        if(rd) begin
            rd_ptr = rd_ptr[Q_LENGTH-1] == 1 ? 1 : rd_ptr << 1;
        end
        for(p = 0; p < Q_LENGTH; p = p + 1) begin : m_update
            if(modify_vector[p] == 1) begin
                queue[p] <= {queue[p][M_WIDTH +: N_WIDTH], new_m_vector[p*M_WIDTH +: M_WIDTH]};           
            end
        end
        
    end
end

endmodule

module mux_nm #(
    parameter N = 8, 
    parameter M = 4  
) (
    input  [N*M-1:0]    data_in,    
    input  [M-1:0]      one_hot_sel,  
    output reg [N-1:0]  data_out  
);
    integer i;

    always @(*) begin
        data_out = {N{1'b0}}; 
        for (i = 0; i < M; i = i + 1) begin
            if (one_hot_sel[i]) begin
                data_out = data_in[i*N +: N]; 
            end
        end
    end
endmodule