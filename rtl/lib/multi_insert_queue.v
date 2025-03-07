module multi_insertion_queue #(
    parameter DATA_WIDTH = 32,            // Width of data elements
    parameter QUEUE_DEPTH = 16,           // Maximum number of elements in queue
    parameter MAX_INSERTS_PER_CYCLE = 4   // Maximum number of inserts per clock cycle
)(
    input wire clk,                       // Clock signal
    input wire rst,                     // Active-high reset
    
    // Insertion interface
    input wire [MAX_INSERTS_PER_CYCLE-1:0] insert_valid,                            // Valid signal for each potential insert
    input wire [MAX_INSERTS_PER_CYCLE*DATA_WIDTH-1:0] insert_data,                  // Data for each potential insert
    output wire [MAX_INSERTS_PER_CYCLE-1:0] insert_ready,                           // Ready signal for each potential insert
    
    // Removal interface
    input wire remove_valid,                                                        // Request to remove an element
    output wire [DATA_WIDTH-1:0] remove_data,                                       // Data of removed element
    output wire remove_ready                                                       // Queue has data to remove
    
    // Status signals //TODO: Place outside
    // output wire full,                                                               // Queue is full
    // output wire empty,                                                              // Queue is empty
    // output wire [$clog2(QUEUE_DEPTH+1)-1:0] occupancy                               // Current number of elements
);

    output wire full;
    output wire empty;
    // Internal storage
    reg [DATA_WIDTH-1:0] queue_mem [0:QUEUE_DEPTH-1];
    reg [$clog2(QUEUE_DEPTH+1)-1:0] head;
    reg [$clog2(QUEUE_DEPTH+1)-1:0] tail;
    reg [$clog2(QUEUE_DEPTH+1)-1:0] count;
    
    // Status signals
    assign empty = (count == 0);
    assign full = (count == QUEUE_DEPTH);
    assign occupancy = count;
    
    // Calculate how many elements can be inserted this cycle
    reg [$clog2(MAX_INSERTS_PER_CYCLE+1)-1:0] valid_insert_count;
    wire [$clog2(MAX_INSERTS_PER_CYCLE+1)-1:0] accepted_insert_count;
    
    integer i;
    
    // Count valid insertion requests
    always @(*) begin
        valid_insert_count = 0;
        for (i = 0; i < MAX_INSERTS_PER_CYCLE; i = i + 1) begin
            if (insert_valid[i]) begin
                valid_insert_count = valid_insert_count + 1;
            end
        end
    end
    
    // Determine how many inserts we can accept based on available space
    assign accepted_insert_count = (valid_insert_count > (QUEUE_DEPTH - count)) ? 
                                   (QUEUE_DEPTH - count) : valid_insert_count;
    
    // Generate ready signals
    genvar g;
    generate
        for (g = 0; g < MAX_INSERTS_PER_CYCLE; g = g + 1) begin : ready_gen
            assign insert_ready[g] = !full && (g < (QUEUE_DEPTH - count));
        end
    endgenerate
    
    // Remove interface
    assign remove_ready = !empty;
    assign remove_data = queue_mem[head];
    
    // Queue update logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            head <= 0;
            tail <= 0;
            count <= 0;
            for (i = 0; i < QUEUE_DEPTH; i = i + 1) begin
                queue_mem[i] <= 0;
            end
        end else begin
            // Process removals first
            if (remove_valid && !empty) begin
                head <= (head == QUEUE_DEPTH-1) ? 0 : head + 1;
                count <= count - 1;
            end
            
            // Process insertions
            if (accepted_insert_count > 0) begin
                for (i = 0; i < MAX_INSERTS_PER_CYCLE; i = i + 1) begin
                    if (i < accepted_insert_count && insert_valid[i]) begin
                        queue_mem[(tail + i) % QUEUE_DEPTH] <= insert_data[i*DATA_WIDTH +: DATA_WIDTH];
                    end
                end
                
                tail <= (tail + accepted_insert_count) % QUEUE_DEPTH;
                count <= count + accepted_insert_count - (remove_valid && !empty ? 1 : 0);
            end
        end
    end
    
endmodule
