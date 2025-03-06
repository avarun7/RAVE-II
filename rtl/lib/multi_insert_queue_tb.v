
// Testbench for the multi-insertion queue
module multi_insertion_queue_tb;
parameter DATA_WIDTH = 8;
parameter QUEUE_DEPTH = 16;
parameter MAX_INSERTS_PER_CYCLE = 4;

reg clk;
reg rst_n;

reg [MAX_INSERTS_PER_CYCLE-1:0] insert_valid;
reg [MAX_INSERTS_PER_CYCLE*DATA_WIDTH-1:0] insert_data;
wire [MAX_INSERTS_PER_CYCLE-1:0] insert_ready;

reg remove_valid;
wire [DATA_WIDTH-1:0] remove_data;
wire remove_ready;

wire full;
wire empty;
wire [$clog2(QUEUE_DEPTH+1)-1:0] occupancy;

// Instantiate the queue
multi_insertion_queue #(
    .DATA_WIDTH(DATA_WIDTH),
    .QUEUE_DEPTH(QUEUE_DEPTH),
    .MAX_INSERTS_PER_CYCLE(MAX_INSERTS_PER_CYCLE)
) miq (
    .clk(clk),
    .rst_n(rst_n),
    .insert_valid(insert_valid),
    .insert_data(insert_data),
    .insert_ready(insert_ready),
    .remove_valid(remove_valid),
    .remove_data(remove_data),
    .remove_ready(remove_ready),
    .full(full),
    .empty(empty),
    .occupancy(occupancy)
);

// Clock generation
always #5 clk = ~clk;

// Test sequence
initial begin
    // Initialize
    clk = 0;
    rst_n = 0;
    insert_valid = 0;
    insert_data = 0;
    remove_valid = 0;
    
    // Reset
    #10 rst_n = 1;
    
    // Insert single element
    #10;
    insert_valid = 4'b0001;
    insert_data[7:0] = 8'hA1;
    #10;
    insert_valid = 0;
    
    // Insert multiple elements
    #10;
    insert_valid = 4'b0111;
    insert_data[7:0] = 8'hB2;
    insert_data[15:8] = 8'hC3;
    insert_data[23:16] = 8'hD4;
    #10;
    insert_valid = 0;
    
    // Remove elements
    #10;
    remove_valid = 1;
    #10;
    #10;
    #10;
    #10;
    remove_valid = 0;
    
    // Insert and remove in same cycle
    #10;
    insert_valid = 4'b0011;
    insert_data[7:0] = 8'hE5;
    insert_data[15:8] = 8'hF6;
    remove_valid = 1;
    #10;
    insert_valid = 0;
    remove_valid = 0;
    
    // Run a bit longer to observe results
    #50;
    $finish;
end

// Monitor
initial begin
    $monitor("Time=%0t, Reset=%b, Occ=%0d, Full=%b, Empty=%b, InsValid=%b, InsReady=%b, RemReady=%b, RemData=%h",
             $time, rst_n, occupancy, full, empty, insert_valid, insert_ready, remove_ready, remove_data);
end

endmodule

