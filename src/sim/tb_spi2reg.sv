`timescale 1ns / 1ps

module tb_spi2reg();

    localparam int PACKET_SIZE = 24;
    localparam int NUM_TIMES = 6;
    localparam int T_IDX = $clog2(NUM_TIMES);
    localparam int DATA_WIDTH = PACKET_SIZE - T_IDX;

    logic clk, rst_n;
    logic sclk, cs, mosi;
    logic [PACKET_SIZE-1:0] packet_out;
    logic rx_valid;

    logic [DATA_WIDTH-1:0] tA_new, tB_new, tC_new, tD_new, tE_new, tF_new;
    logic [2:0] bitmask_AB, bitmask_CD, bitmask_EF;
    logic error;

    spi_slave2 #(
        .PACKET_SIZE(PACKET_SIZE)
    ) uut_spi (
        .sclk       (sclk),
        .cs         (cs),
        .mosi       (mosi),
        .rst_n      (rst_n),
        .packet_out (packet_out),
        .rx_valid   (rx_valid)
    );

    regfile uut_rf (
        .clk      (clk),
        .rst_n    (rst_n),
        .rx_valid (rx_valid),
        .packet   (packet_out), // input from SPI packet_out
        .tA_new   (tA_new), 
        .tB_new   (tB_new),
        .tC_new   (tC_new),
        .tD_new   (tD_new),
        .tE_new   (tE_new),
        .tF_new   (tF_new),
        .bitmask_AB(bitmask_AB), .bitmask_CD(bitmask_CD), .bitmask_EF(bitmask_EF),
        .error    (error)
    );
    
    always #10 clk = ~clk;
    always #62.5 sclk = ~sclk;
    
    // ============================================================================
    task automatic spi_send_packet(input logic [PACKET_SIZE-1:0] packet);
        cs   = 1;
        mosi = 0;

        @(negedge sclk);
        cs = 0;

        mosi = packet[PACKET_SIZE-1];

        @(posedge sclk);

        for (int i = PACKET_SIZE-2; i >= 0; i--) begin
            @(negedge sclk);
            mosi = packet[i];
            @(posedge sclk);
        end

        @(negedge sclk);
        cs   = 1;
        mosi = 0;

        repeat (2) @(posedge sclk);
    endtask
    // ============================================================================

    logic [PACKET_SIZE-1:0] tA_sel, tB_sel, tC_sel, tD_sel, tE_sel, tF_sel;
    logic [23:0] bitmask_AB_sel, bitmask_CD_sel, bitmask_EF_sel;
    
    initial begin
        sclk <= 1'b0;
        clk <= 1'b0;
        rst_n <= 1'b0;
        
        rst_n <= 1'b1;
        
        tA_sel <= 24'h0;
        tB_sel <= 24'h2001f4;
        tC_sel <= 24'h400000;
        tD_sel <= 24'h6001f4;
        tE_sel <= 24'h800000;
        tF_sel <= 24'ha001f4;
        
        bitmask_AB_sel <= 24'h300004;
        bitmask_CD_sel <= 24'h500002;
        bitmask_EF_sel <= 24'h900001;
        
        repeat(15) @(posedge clk);
        
        //----------------------------------------------------
        $display("\nSending packet = %h", tA_sel);
        spi_send_packet(tA_sel);
        wait(rx_valid);
        $display("Received packet = %h", packet_out);
        
        repeat (15) @(posedge sclk);
        
        $display("\nSending packet = %h", tB_sel);
        spi_send_packet(tB_sel);
        wait(rx_valid);
        $display("Received packet = %h", packet_out);
        
        repeat (15) @(posedge sclk);
        
        $display("\nSending packet = %h", tC_sel);
        spi_send_packet(tC_sel);
        wait(rx_valid);
        $display("Received packet = %h", packet_out);
        
        repeat (15) @(posedge sclk);
        
        $display("\nSending packet = %h", tD_sel);
        spi_send_packet(tD_sel);
        wait(rx_valid);
        $display("Received packet = %h", packet_out);
        
        repeat (15) @(posedge sclk);
        
        $display("\nSending packet = %h", tE_sel);
        spi_send_packet(tE_sel);
        wait(rx_valid);
        $display("Received packet = %h", packet_out);
        
        repeat (15) @(posedge sclk);
        
        $display("\nSending packet = %h", tF_sel);
        spi_send_packet(tF_sel);
        wait(rx_valid);
        $display("Received packet = %h", packet_out);
        
        repeat (15) @(posedge sclk);
        
        $display("\nSending packet = %h", 24'hFFFFFF);
        spi_send_packet(24'hFFFFFF);
        wait(rx_valid);
        $display("Received packet = %h", packet_out);
        
        $display("\nSending packet = %h", bitmask_AB_sel);
        spi_send_packet(bitmask_AB_sel);
        wait(rx_valid);
        $display("Received packet = %h", bitmask_AB_sel);
        
        $display("\nSending packet = %h", bitmask_CD_sel);
        spi_send_packet(bitmask_CD_sel);
        wait(rx_valid);
        $display("Received packet = %h", bitmask_CD_sel);
        
        $display("\nSending packet = %h", bitmask_EF_sel);
        spi_send_packet(bitmask_EF_sel);
        wait(rx_valid);
        $display("Received packet = %h", bitmask_EF_sel);

        //----------------------------------------------------
        #2000;
        $finish;
        
    end
    
endmodule
