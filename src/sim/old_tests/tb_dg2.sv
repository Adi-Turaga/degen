`timescale 1ns / 1ps

module tb_dg2();

    logic clk, rst, en, trig_in, pulse;
    logic [31:0] t1, t2;
    logic [34:0] t_cycle;
    
    delay_gen_v2 dg2_1 (
        .clk(clk), .rst(rst), .en(en), 
        .trig_in(trig_in), .pulse(pulse),
        .t1(t1), .t2(t2), .t_cycle(t_cycle)
    );
    
    always #5 clk = ~clk;

    initial begin
        clk <= 0;
        trig_in <= 0;
        rst <= 1'b1;
        t1 <= 32'd0;
        t2 <= 32'd1000;
        t_cycle <= 32'd51000;
        
        #10;
        rst <= 1'b0;
        
        send_trigger;  
        #500000;
        send_trigger;
        #500000;       
    end

endmodule
