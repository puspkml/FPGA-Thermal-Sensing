module mock_thermal_sensor (
    input wire sclk,
    input wire cs_n,
    input wire mosi,
    output reg miso = 1'b0
);
    reg [7:0] memory_matrix [0:255];
    reg [7:0] shift_reg;
    reg [7:0] rwb_addr;
    reg [4:0] bit_idx;
    initial begin
	 $readmemh("image.hex", memory_matrix);
    end
    always @(posedge sclk or posedge cs_n) begin
    if (cs_n) begin
        bit_idx  <= 0;
        miso     <= 1'b0;
        rwb_addr <= 0;
        shift_reg<= 0;
    end
    else begin

        if (bit_idx < 9) begin

            rwb_addr <= {rwb_addr[6:0], mosi};

            if (bit_idx == 8) begin
		$display("SLAVE ADDR=%02h DATA=%02h",{rwb_addr[6:0], mosi},memory_matrix[{rwb_addr[6:0], mosi}]);
                shift_reg <= memory_matrix[{rwb_addr[6:0], mosi}];
            end

            miso <= 1'b0;
        end
        else begin

            miso <= shift_reg[7];
            shift_reg <= {shift_reg[6:0],1'b0};

        end

        bit_idx <= bit_idx + 1;
    end
end
endmodule
