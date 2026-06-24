module spi_master #(
    parameter size = 17,
    parameter mode = 0
) (
    input wire clk,
    input wire en,
    input wire rst,
    input wire tx_en,
    input wire rx_en,
    input wire miso,
    input wire [7:0] address,
    input wire [7:0] data_out,
    output reg sclk,
    output reg cs_n,
    output reg mosi,
    output reg [15:0] data_in,
    output reg rx_valid
);
    reg [7:0] count;
    reg [7:0] bit_count;
    reg [15:0] tx_data;
    reg [7:0] rx_data;
    localparam LIMIT = 8'd1;
    localparam FINAL = size;
    reg tx_en_reg;
    reg rx_en_reg;
    reg is_write;
    reg CPOL, CPHA;

    always @(posedge clk) begin
        if (rst) begin
            count     <= 0;
            bit_count <= 0;
            mosi      <= 1'b0;
            tx_data   <= 0;
            rx_data   <= 0;
            data_in   <= 0;
            tx_en_reg <= 0;
            rx_en_reg <= 0;
            rx_valid  <= 0;
            is_write  <= 0;
            cs_n      <= 1'b1;
            if (mode == 0) begin CPOL <= 0; CPHA <= 0; sclk <= 0; end
            else if (mode == 1) begin CPOL <= 0; CPHA <= 1; sclk <= 0; end
            else if (mode == 2) begin CPOL <= 1; CPHA <= 0; sclk <= 1; end
            else begin CPOL <= 1; CPHA <= 1; sclk <= 1; end
        end else begin
            tx_en_reg <= tx_en;
            rx_en_reg <= rx_en;
            rx_valid  <= 1'b0;
            if (en) begin
                if (cs_n) begin
                    if (tx_en_reg && !tx_en) begin
                        cs_n      <= 1'b0;
                        bit_count <= 0;
                        count     <= 0;
                        sclk      <= CPOL;
                        is_write  <= 1'b1;
                        tx_data   <= {address, data_out};
                        mosi      <= 1'b1; 
                    end else if (rx_en_reg && !rx_en) begin
                        cs_n      <= 1'b0;
                        bit_count <= 0;
                        count     <= 0;
                        sclk      <= CPOL;
                        is_write  <= 1'b0;
                        tx_data   <= {address, 8'b0};
                        mosi      <= 1'b0;
	                rx_data   <= 8'd0; 
                    end
                end else begin
                    if (count == LIMIT) begin
                        count <= 0;
                        sclk  <= ~sclk;
                        if (~sclk != CPOL) begin
                            if (!is_write && (bit_count >= 9) && (bit_count < FINAL)) begin
                               
                               rx_data <= {rx_data[6:0], miso};
                             
                            end
                            bit_count <= bit_count + 1;
                        end else begin
                            if (bit_count < FINAL) begin
                                if (!is_write && (bit_count >= 9)) begin
                                    mosi <= 1'b0;
                                end else begin
                                    mosi    <= tx_data[15];
                                    tx_data <= {tx_data[14:0], 1'b0};
                                end
                            end else begin
                                cs_n     <= 1'b1;
                                mosi     <= 1'b0;
                                sclk     <= CPOL;
                                if (!is_write) begin
                                    data_in  <={8'b0, rx_data};
				$display("ADDR=%02h RECEIVED=%02h TIME=%0t",address,{rx_data[6:0], miso},$time);
                                    rx_valid <= 1'b1;
                                end
                            end
                        end
                    end else begin
                        count <= count + 1;
                    end
                end
            end else begin
                cs_n <= 1'b1;
                sclk <= CPOL;
                mosi <= 1'b0;
            end
        end
    end
endmodule
