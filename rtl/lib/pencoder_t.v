module TOP;

    localparam CYCLE_TIME = 2.0;
    localparam WIDTH = 31;
    integer unsigned k;

    reg [WIDTH-1:0] a;
    wire [$clog2(WIDTH)-1:0] o;

    pencoder #(.WIDTH(WIDTH)) pe(.a(a), .o(o));

    initial begin
        a = {WIDTH{1'b0}};
        for (k = 0; k < 2**WIDTH; k = (k << 1)+17) begin
            a = k[WIDTH-1:0];
            #CYCLE_TIME; 
        end
        #CYCLE_TIME;
        $finish;
    end

    initial begin
        $dumpfile("test.fst");
        $dumpvars(0, TOP);
    end

endmodule