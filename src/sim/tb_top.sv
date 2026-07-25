/*`timescale 1ns / 1ps

module tb_top();

    logic clk, rst, en, trig_in;
    logic [31:0] tA, tB, tC, tD;
    logic [34:0] t_cycle;
    logic pulse_w1, pulse_w2;
    
    task send_trigger;
        @(posedge clk);
        trig_in <= 1;
        #10000;
        trig_in <= 0;
    endtask
    
    top dg(
        .clk(clk), .rst(rst), .en(en), .trig_in(trig_in),
        .tA(tA), .tB(tB), .tC(tC), .tD(tD), .t_cycle(t_cycle),
        .pulse_w1(pulse_w1), .pulse_w2(pulse_w2)
    );
    
    always #5 clk = ~clk;
    
    initial begin
        clk <= 1'b0;
        rst <= 1'b1;
        trig_in <= 1'b0;
        
        tA <= 32'd0;
        tB <= 32'd1000;
        tC <= 32'd50000;
        tD <= 32'd51000;
        t_cycle <= 32'd51000; // in us, so in reality this is #510000 in ns/ps scale

        #10;
        rst <= 1'b0;
        
        for(int i = 0; i < 15; i++) begin
            send_trigger;
            #500000; // every 0.5 ms, send the 10us wide trigger
            //repeat(51000) @(posedge clk);
        end
 
    end 

endmodule
*/
`timescale 1ns / 1ps
module tb_top();
    logic clk, rst, trig_in;
    logic [21:0] tA, tB, tC, tD;
    logic [21:0] t_cycle;
    logic pulse_w1, pulse_w2;

    task send_trigger;
        @(posedge clk);
        trig_in <= 1;
        #10000;
        trig_in <= 0;
    endtask

    top dg(
        .clk(clk), .rst(rst), .trig_in(trig_in),
        .tA(tA), .tB(tB), .tC(tC), .tD(tD), 
        .tAB_cycle(t_cycle), .tCD_cycle(t_cycle),
        .pulse_w1(pulse_w1), .pulse_w2(pulse_w2)
    );

    // 100 MHz
    always #5 clk = ~clk;

    initial begin
        clk <= 1'b0;
        trig_in <= 1'b0;
        rst <= 1'b1;
        
        #100;
        
        rst <= 1'b0;
        tA <= 32'd0;
        tB <= 32'd1000;
        tC <= 32'd0;
        tD <= 32'd1000;
        t_cycle <= 32'd1000;

        #10;

        for(int i = 0; i < 15; i++) begin
            send_trigger;
            #500000; // total loop time = 500,000 ns exactly
        end
    end
endmodule