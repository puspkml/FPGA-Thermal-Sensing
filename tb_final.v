module tb_thermal();
    reg clk, en, tx_en, rx_en, rst;
    reg [7:0] address;
    reg [7:0] data_out;
    wire sclk, cs_n, mosi, miso, rx_valid;
    wire [15:0] data_in;

    wire [7:0] r_wire, g_wire, b_wire;
    reg [7:0] image_ram_r [0:255];
    reg [7:0] image_ram_g [0:255];
    reg [7:0] image_ram_b [0:255];

    integer ppm_file = 0;
    integer i;

   
    spi_master #(.size(17), .mode(0)) master_inst (
        .clk(clk), .en(en), .rst(rst), .tx_en(tx_en), .rx_en(rx_en),
        .miso(miso), .address(address), .data_out(data_out),
        .sclk(sclk), .cs_n(cs_n), .mosi(mosi), .data_in(data_in), .rx_valid(rx_valid)
    );

   
    mock_thermal_sensor sensor_inst (
        .sclk(sclk), .cs_n(cs_n), .mosi(mosi), .miso(miso)
    );

   
    pseudo_color_lut lut_inst (
        .raw_temp(data_in[7:0]),
        .r(r_wire), .g(g_wire), .b(b_wire)
    );

   
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("thermal.vcd");
        $dumpvars(0, tb_thermal);

   
        rst = 1; en = 0; tx_en = 0; rx_en = 0; address = 0; data_out = 0; #40;
        rst = 0; en = 1;#40;

   
        for (i = 0; i < 256; i = i + 1) begin
            address = i;
            rx_en = 1; #20; 
            rx_en = 0; 
            $display("addr=%0d temp=%h", i, data_in[7:0]);
            @(posedge rx_valid);#1;
   
            image_ram_r[i] = r_wire;
            image_ram_g[i] = g_wire;
            image_ram_b[i] = b_wire;
            #40;
        end

	ppm_file = $fopen("thermal_output.ppm", "w");
        if (ppm_file == 0) begin
            $display("Error: Failed to clear storage nodes for output target allocation.");
            $finish;
        end

	
        $fwrite(ppm_file, "P3\n");
        $fwrite(ppm_file, "16 16\n");
        $fwrite(ppm_file, "255\n");

        
        for (i = 0; i < 256; i = i + 1) begin
            $fwrite(ppm_file, "%d %d %d\n", image_ram_r[i], image_ram_g[i], image_ram_b[i]);
        end

        $fclose(ppm_file);
        $display("Success: 'thermal_output.ppm' successfully written into directory layer.");
        #20;
        $finish;
    end
endmodule
