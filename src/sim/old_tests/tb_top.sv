`timescale 1ns / 1ps

module tb_top();
    logic clk, rst_n, trig_in;
    logic en_AB, en_CD, en_EF;
    logic [21:0] tA, tB, tC, tD, tE, tF;
    //logic [21:0] t_cycle;
    logic pulse_w1, pulse_w2, pulse_w3;

    task send_trigger;
        @(posedge clk);
        trig_in <= 1;
        #10000;
        trig_in <= 0;
    endtask

    top dg(
        .clk(clk), .rst_n(rst_n), .trig_in(trig_in),
        .en_AB(en_AB), .en_CD(en_CD), .en_EF(en_EF),
        //.tA(tA), .tB(tB), .tC(tC), .tD(tD), .tE(tE), .tF(tF),
        .pulse_w1(pulse_w1), .pulse_w2(pulse_w2), .pulse_w3(pulse_w3)
    );

    // 100 MHz
    always #5 clk = ~clk;

    initial begin
        clk <= 1'b0;
        trig_in <= 1'b0;
        rst_n <= 1'b0;
        
        #100;
        
        rst_n <= 1'b1;
        en_AB <= 1'b1;
        en_CD <= 1'b1;
        en_EF <= 1'b0;
        
        /*tA <= 22'd0;
        tB <= 22'd1000;
        tC <= 22'd0;
        tD <= 22'd1000;
        tE <= 22'd0;
        tF <= 22'd1000;*/

        #10;

        for(int i = 0; i < 10; i++) begin
            send_trigger;
            #500000;
        end
        
        #500000;
        
        en_EF <= 1'b1;
        for(int i = 0; i < 15; i++) begin
            send_trigger;
            #400000;
        end
        
        #100000;
        
        $finish;
    end
endmodule