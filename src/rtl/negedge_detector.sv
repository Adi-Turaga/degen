`timescale 1ns / 1ps

module negedge_detector(
    input clk, tx_idle,
    output is_negedge, din_sync
    );
    
    logic dff_sync1, dff_sync2, dff_sync3;
    
    // 2-FF synchronized due to async tx line
    always_ff @(posedge clk) begin
        dff_sync1 <= tx_idle;
		dff_sync2 <= dff_sync1;
		dff_sync3 <= dff_sync2;
    end 
    
    // signal has to be different before and after delay
    assign is_negedge = dff_sync3 & ~dff_sync2;
    assign din_sync = dff_sync3;
endmodule
