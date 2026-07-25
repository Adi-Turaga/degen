`timescale 1ns / 1ps

module tb_dg1();

    logic clk, rst, en, trig_in, pulse_w1, delay;
    
    delay_gen dg1 (
        .clk(clk), .rst(rst), .en(en), 
        .trig_in(trig_in), .pulse_w1(pulse_w1), .delay(delay)
    );
    
    always #5 clk = ~clk;
    
    initial begin
        clk <= 0;
        trig_in <= 0;
        rst <= 1'b1;
        
        #10 
        rst <= 1'b0;
        trig_in <= 1;
        
        #20 trig_in <= 0;
    end
    
endmodule
