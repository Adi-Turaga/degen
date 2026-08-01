`timescale 1ns / 1ps

module posedge_detector(
    input clk, trig_in,
    output is_posedge
    );
    
    logic trig_in_delay, trig_in_delay2, trig_in_delay3;
    
    // 2-FF synchronized due to async trig_in
    always_ff @(posedge clk) begin
        trig_in_delay <= trig_in;
		trig_in_delay2 <= trig_in_delay;
		
        trig_in_delay3 <= trig_in_delay2;
    end 
    
    // signal has to be different before and after delay
    //assign is_posedge = trig_in & ~trig_in_delay;
	 assign is_posedge = trig_in_delay2 & ~trig_in_delay3;
    
endmodule
