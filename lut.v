module pseudo_color_lut (
    input wire [7:0] raw_temp,
    output reg [7:0] r= 8'b0,
    output reg [7:0] g = 8'b0,
    output reg [7:0] b = 8'b0
);
always @(*) begin
    if (raw_temp < 8'd64) begin
        r = 0;
        g = raw_temp << 2;
        b = 255;
    end
    else if (raw_temp < 8'd128) begin
        r = (raw_temp - 64) << 2;
        g = 255;
        b = 255 - ((raw_temp - 64) << 2);
    end
    else if (raw_temp < 8'd192) begin
        r = 255;
        g = 255;
        b = 0;
        g = 255 - ((raw_temp - 128) << 2);
    end
    else begin
        r = 255;
        g = 0;
        b = (raw_temp - 192) << 2;
    end
end
endmodule
