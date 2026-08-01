`timescale 1ns/1ps

module tb_uart2reg;

    localparam CLK_FREQ  = 50_000_000;
    localparam BAUD_RATE = 115200;
    localparam TICK      = CLK_FREQ / BAUD_RATE;
    localparam CLK_PERIOD = 20;          // 50 MHz

    logic clk;
    logic rst_n;
    logic din;

    logic [23:0] packet_out;
    logic        rx_valid;

    logic [19:0] tA_new, tB_new, tC_new;
    logic [19:0] tD_new, tE_new, tF_new;

    logic [2:0] bitmask_AB;
    logic [2:0] bitmask_CD;
    logic [2:0] bitmask_EF;

    logic error;

    //------------------------------------------------------------
    // DUTs
    //------------------------------------------------------------

    uart_rx2 #(
        .BAUD_RATE(BAUD_RATE),
        .CLK_FREQ(CLK_FREQ)
    ) uart_rx_inst (
        .clk(clk), .rst_n(rst_n), .din(din),
        .packet_out(packet_out), .rx_valid(rx_valid)
    );

    regfile regfile_inst (
        .clk(clk), .rst_n(rst_n), .rx_valid(rx_valid), 
        .packet(packet_out), .error(error),

        .tA_new(tA_new), .tB_new(tB_new),
        .tC_new(tC_new), .tD_new(tD_new),
        .tE_new(tE_new), .tF_new(tF_new),

        .bitmask_AB(bitmask_AB), .bitmask_CD(bitmask_CD), .bitmask_EF(bitmask_EF)
    );

    always #20 clk = ~clk;

    task automatic uart_send_byte(input [7:0] data);
        begin
            din = 0;
            repeat(TICK) @(posedge clk);

            for (int i=0; i<8; i++) begin
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
        din <= 1;      // UART idle

        repeat(10) @(posedge clk);

        rst_n <= 1;

        repeat(10) @(posedge clk);

        uart_send_packet(24'h000000);   // tA = 0
        uart_send_packet(24'h2001F4);   // tB = 500
        uart_send_packet(24'h400000);   // tC = 0
        uart_send_packet(24'h6001F4);   // tD = 500
        uart_send_packet(24'h800000);   // tE = 0
        uart_send_packet(24'hA001F4);   // tF = 500

        uart_send_packet(24'h300004);   // bitmask AB = 100
        uart_send_packet(24'h500002);   // bitmask CD = 010
        uart_send_packet(24'h900001);   // bitmask EF = 001

        repeat(2000) @(posedge clk);

        $display("-------------------------------------");
        $display("tA = %d", tA_new);
        $display("tB = %d", tB_new);
        $display("tC = %d", tC_new);
        $display("tD = %d", tD_new);
        $display("tE = %d", tE_new);
        $display("tF = %d", tF_new);

        $display("bitmask_AB = %b", bitmask_AB);
        $display("bitmask_CD = %b", bitmask_CD);
        $display("bitmask_EF = %b", bitmask_EF);

        $display("error = %b", error);
        $display("-------------------------------------");

        $finish;
    end

endmodule