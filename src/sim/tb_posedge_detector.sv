`timescale 1ns / 1ps

module tb_posedge_detector();

    logic clk, trig_in, is_posedge;
    
    posedge_detector pe(
        .clk(clk), .trig_in(trig_in), .is_posedge(is_posedge)
    );
    
    always #5 clk = ~clk;
    
    initial begin
        clk <= 0;
        trig_in <= 0;
        #15 trig_in <= 1'b1;
        #20 trig_in <= 1'b0;
        #35 trig_in <= 1'b1;
        #50 trig_in <= 1'b0;
    end

endmodule
