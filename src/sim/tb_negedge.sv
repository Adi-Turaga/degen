`timescale 1ns / 1ps

module tb_negedge();

    logic clk, tx_idle, is_negedge;
    
    negedge_detector ne(
        .clk(clk), .tx_idle(tx_idle), .is_negedge(is_negedge)
    );
    
    always #5 clk = ~clk;
    
    initial begin
        clk <= 0;
        tx_idle <= 0;
        #15 tx_idle <= 1'b1;
        #20 tx_idle <= 1'b0;
        #35 tx_idle <= 1'b1;
        #50 tx_idle <= 1'b0;
        #20 $finish;
    end

endmodule
