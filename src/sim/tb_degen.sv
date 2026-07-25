`timescale 1ns / 1ps

module tb_degen();

    logic clk, rst, trig_in;
    logic [31:0] tA, tB, tC, tD;
    logic [34:0] t_cycle;
    logic pulse_w1, pulse_w2;
    
    task send_trigger;
        @(posedge clk);
        trig_in <= 1;
        #10000;
        trig_in <= 0;
    endtask
    
    degen dg(
        .clk(clk), .rst(rst), .trig_in(trig_in),
        .tA(tA), .tB(tB), .tC(tC), .tD(tD), .t_cycle(t_cycle),
        .pulse_w1(pulse_w1), .pulse_w2(pulse_w2)
    );
    
    always #5 clk = ~clk;

    initial begin
        clk <= 1'b0;
        rst <= 1'b1;
        trig_in <= 1'b0;
        
        #10000;
        rst <= 1'b0;
        tA <= 32'd0;
        tB <= 32'd1000;
        tC <= 32'd50000;
        tD <= 32'd51000;
        t_cycle <= 32'd51000; // 510 us at 100 MHz
        
        for(int i = 0; i < 15; i++) begin
            send_trigger;
            #500000;
        end
    end
    

endmodule
