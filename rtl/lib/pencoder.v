module pencoder #(parameter WIDTH=32)(
    input [WIDTH-1:0] a,
    output reg [$clog2(WIDTH)-1:0] o
);

    integer i;
    always@(*) begin
        for(i = 0; i < WIDTH; i = i + 1) begin
            if(a[i]) begin
                o <= i[$clog2(WIDTH)-1:0];
            end
        end
    end

endmodule