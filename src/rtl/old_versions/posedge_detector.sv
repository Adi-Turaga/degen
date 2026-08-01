`timescale 1ns / 1ps

module posedge_detector(
    input clk, trig_in,
    output is_posedge
    );
    
    reg trig_in_delay;
    
    always_ff @(posedge clk) begin
        trig_in_delay <= trig_in;
    end 
    
    // signal has to be different before and after delay
    assign is_posedge = trig_in & ~trig_in_delay;
    
endmodule
