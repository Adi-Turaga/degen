`timescale 1ns / 1ps

module tb_top;

    localparam CLK_FREQ   = 50_000_000;
    localparam BAUD_RATE  = 115200;
    localparam TICK       = CLK_FREQ / BAUD_RATE;
    localparam CLK_PERIOD = 20;

    logic clk;
    logic rst_n;
    logic trig_in;

    logic sclk;
    logic din;

    logic en_AB;
    logic en_CD;
    logic en_EF;

    logic pulse_w1;
    logic pulse_w2;
    logic pulse_w3;

    top #(
        .BAUD_RATE(BAUD_RATE),
        .CLK_FREQ(CLK_FREQ)
    ) uut (
        .clk(clk),
        .rst_n(rst_n),
        .trig_in(trig_in),
        .din(din),

        .en_AB(en_AB),
        .en_CD(en_CD),
        .en_EF(en_EF),

        .pulse_w1(pulse_w1),
        .pulse_w2(pulse_w2),
        .pulse_w3(pulse_w3)
    );

    always #(CLK_PERIOD/2) clk = ~clk;

    task automatic uart_send_byte(input [7:0] data);
        begin
            din = 0;
            repeat(TICK) @(posedge clk);

            for (int i = 0; i < 8; i++) begin
                din = data[i];
                repeat(TICK) @(posedge clk);
            end

            din = 1;
            repeat(TICK) @(posedge clk);
        end
    endtask

    task automatic uart_send_packet(input [23:0] packet);
        begin
            uart_send_byte(packet[23:16]);
            uart_send_byte(packet[15:8]);
            uart_send_byte(packet[7:0]);

            repeat(TICK) @(posedge clk);
        end
    endtask

    initial begin

        clk <= 0;
        rst_n <= 0;
        din <= 1;

        trig_in <= 0;

        en_AB <= 0;
        en_CD <= 0;
        en_EF <= 0;

        repeat(100) @(posedge clk);
        rst_n <= 1;
        repeat(100) @(posedge clk);
        
        uart_send_packet(24'h900004);   // AB = 100
        uart_send_packet(24'h500002);   // CD = 010
        uart_send_packet(24'h300001);   // EF = 001
        
        repeat(500) @(posedge clk);

        // 10us pulses
        uart_send_packet(24'h000000);   // tA = 0
        uart_send_packet(24'h2001F4);   // tB = 500
        uart_send_packet(24'h400000);   // tC = 0
        uart_send_packet(24'h6001F4);   // tD = 500
        uart_send_packet(24'h800000);   // tE = 0
        uart_send_packet(24'hA001F4);   // tF = 500
        
        repeat(2000) @(posedge clk);
        
        en_AB <= 1;
        en_CD <= 1;
        en_EF <= 1;

        repeat(200) @(posedge clk);

        for(int i = 0; i < 15; i++) begin
            trig_in <= 1;
            #5000;
            trig_in <= 0;
            #100000;
        end
        
        en_EF <= 1'b0;
        
        uart_send_packet(24'h3e8);
        uart_send_packet(24'h2009c4);
        
        for(int i = 0; i < 15; i++) begin
            trig_in <= 1;
            #5000;
            trig_in <= 0;
            #100000;
        end

        repeat(500) @(posedge clk);

        $finish;

    end

endmodule