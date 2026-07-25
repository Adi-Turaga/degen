`timescale 1ns/1ps

module tb_spi_slave;

    localparam PACKET_SIZE = 24;

    logic sclk;
    logic cs;
    logic mosi;
    logic rst_n;

    logic [PACKET_SIZE-1:0] packet_out;
    logic rx_valid;

    //----------------------------------------
    // DUT
    //----------------------------------------
    spi_slave2 #(
        .PACKET_SIZE(PACKET_SIZE)
    ) dut (
        .sclk(sclk),
        .cs(cs),
        .mosi(mosi),
        .rst_n(rst_n),
        .packet_out(packet_out),
        .rx_valid(rx_valid)
    );

    //----------------------------------------
    // 10 MHz SPI Clock
    //----------------------------------------
    initial begin
        sclk = 0;
        forever #50 sclk = ~sclk;
    end

    //----------------------------------------
    // Send one SPI packet (MSB first)
    //----------------------------------------
    task automatic spi_send_packet(
        input logic [PACKET_SIZE-1:0] packet
    );
        integer i;
        begin
            // Idle bus
            cs   = 1;
            mosi = 0;

            // Start transaction on falling edge
            @(negedge sclk);
            cs = 0;

            // Present MSB before first rising edge
            mosi = packet[PACKET_SIZE-1];

            // First bit sampled here
            @(posedge sclk);

            // Remaining bits
            for (i = PACKET_SIZE-2; i >= 0; i--) begin
                @(negedge sclk);
                mosi = packet[i];
                @(posedge sclk);
            end

            // End transaction
            @(negedge sclk);
            cs   = 1;
            mosi = 0;

            repeat (2) @(posedge sclk);
        end
    endtask

    //----------------------------------------
    // Test
    //----------------------------------------
    logic [23:0] tx_packet1, tx_packet2;

    initial begin

        rst_n = 0;
        cs     = 1;
        mosi   = 0;

        repeat (5) @(posedge sclk);

        rst_n = 1;

        tx_packet1 = 24'hA5C3F0;
        tx_packet2 = 24'hBBCCAA;

        //----------------------------------------------------
        $display("\nSending packet = %h", tx_packet1);
        spi_send_packet(tx_packet1);

        wait(rx_valid);
        $display("Received packet = %h", packet_out);

        //----------------------------------------------------
        repeat (5) @(posedge sclk);

        $display("\nSending packet = %h", tx_packet2);
        spi_send_packet(tx_packet2);

        wait(rx_valid);
        $display("Received packet = %h", packet_out);

        //----------------------------------------------------
        #2000;
        $finish;
    end

    //----------------------------------------
    // Monitor
    //----------------------------------------
    initial begin
        $monitor("[%0t] CS=%b MOSI=%b CNT=%0d RX_DATA=%h VALID=%b OUT=%h",
                 $time,
                 cs,
                 mosi,
                 dut.counter,
                 dut.rx_data,
                 rx_valid,
                 packet_out);
    end

endmodule