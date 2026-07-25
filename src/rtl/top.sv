`timescale 1ns / 1ps

module top(
    input clk, rst, en, trig_in,
    input [21:0] tA, tB, // tA (t1) and tB (t2) correspond to when they start in microseconds
    input [21:0] tC, tD, // same as tA and tB but for the second pulse
    //input [31:0] tE, tF,
    input [1:0] update,
    output logic pulse_w1, pulse_w2
    );
    
    logic is_posedge, posedge_AB, posedge_CD, sel; 
     
    logic active; 
    logic [21:0] tA_new, tB_new, tC_new, tD_new;
    
    posedge_detector pe(
        .clk(clk), .trig_in(trig_in), .is_posedge(is_posedge)
    );
    
    logic [21:0] t_cycle;
    assign t_cycle = tB > tD ? tB : tD;
    
    always_ff @(posedge clk) begin
        if (rst) sel <= 1'b0;
        else if (is_posedge) sel <= ~sel;
        
        if(update[0] && !active) begin
            case(update[1])
                1'b0: begin
                    tA <= tA_new;
                    tB <= tB_new;
                end
                1'b1: begin
                    tC <= tC_new;
                    tD <= tD_new;
                end 
            endcase
        end
    end

    assign posedge_AB = is_posedge & sel;  // even-numbered triggers (1st, 3rd... however you count "even")
    assign posedge_CD = is_posedge & ~sel;  // odd-numbered triggers
    
    delay_gen_v2 dg2_AB (
        .clk(clk), .rst(rst), .en(en), .is_posedge(posedge_AB), .active(active),
        .t1(tA), .t2(tB), .t_cycle(t_cycle), .pulse(pulse_w1)
    );
    
    delay_gen_v2 dg2_CD (
        .clk(clk), .rst(rst), .en(en), .is_posedge(posedge_CD), .active(active),
        .t1(tC), .t2(tD), .t_cycle(t_cycle), .pulse(pulse_w2)
    );
    
endmodule
