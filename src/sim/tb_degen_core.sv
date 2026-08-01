`timescale 1ns / 1ps

module tb_degen_core();
    logic clk, rst_n, trig_in;
    logic en_AB, en_CD, en_EF;
    logic [19:0] tA, tB, tC, tD, tE, tF;
    logic [2:0] bitmask_AB, bitmask_CD, bitmask_EF;
    //logic [21:0] t_cycle;
    logic pulse_w1, pulse_w2, pulse_w3;

    task send_trigger;
        @(posedge clk);
        trig_in <= 1;
        #10000;
        trig_in <= 0;
    endtask

    degen_core dg(
        .clk(clk), .rst_n(rst_n), .trig_in(trig_in),
        .en_AB(en_AB), .en_CD(en_CD), .en_EF(en_EF),
        .tA_in(tA), .tB_in(tB), .tC_in(tC), .tD_in(tD), .tE_in(tE), .tF_in(tF),
        .bitmask_AB_in(bitmask_AB), .bitmask_CD_in(bitmask_CD), .bitmask_EF_in(bitmask_EF),
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
        en_EF <= 1'b1;
        
        tA <= 20'd0;
        tB <= 20'd1000;
        tC <= 20'd0;
        tD <= 20'd1000;
        tE <= 20'd0;
        tF <= 20'd1000;
        
        bitmask_AB <= 3'b100;
        bitmask_CD <= 3'b010;
        bitmask_EF <= 3'b001;

        #10;

        for(int i = 0; i < 10; i++) begin
            send_trigger;
            #500000;
        end
        
        #500000;
        
        //en_EF <= 1'b1;
        for(int i = 0; i < 15; i++) begin
            send_trigger;
            if(i == 6) begin
                en_EF <= 1'b0;
                bitmask_AB <= 3'b001;
                bitmask_CD <= 3'b010;
                bitmask_EF <= 3'b100;
                tA <= 20'b0;
                tB <= 20'd5000;
            end
            #400000;
        end
        
        #100000;
        
        $finish;
    end
endmodule