`timescale 1ns / 1ps

module degen_core #(
    parameter int N = 3 // number of pulse lanes
)(
    input clk, rst_n, trig_in,
    input en_AB, en_CD, en_EF,
    input [19:0] tA_in, tB_in, tC_in, tD_in, tE_in, tF_in,
    input [2:0] bitmask_AB_in, bitmask_CD_in, bitmask_EF_in,
    output logic pulse_w1, pulse_w2, pulse_w3
    );
    
    logic is_posedge;
    logic [N-1:0] bitmask_AB, bitmask_CD, bitmask_EF;
    logic [$clog2(N)-1:0] bitmask_ptr;
    logic active_AB, active_CD, active_EF;
    
    logic [20:0] tA, tB, tC, tD, tE, tF;
    logic [2:0] bitmask_AB, bitmask_CD, bitmask_EF;
    
    always_ff @(posedge clk) begin
        //if(~active_AB || ~active_CD || ~active_EF) begin
        tA <= tA_in;
        tB <= tB_in;
        tC <= tC_in;
        tD <= tD_in;
        tE <= tE_in;
        tF <= tF_in;
        bitmask_AB <= bitmask_AB_in;
        bitmask_CD <= bitmask_CD_in;
        bitmask_EF <= bitmask_EF_in;
        //end 
    end
    
    logic [N-1:0] N_en, N_active;
    assign N_en = en_AB + en_CD + en_EF;
    assign N_active = (N_en == 2'b11) ? 3 : 2;
    
    posedge_detector pe(
        .clk(clk), .trig_in(trig_in), .is_posedge(is_posedge)
    );
    
    logic [21:0] tAB_cycle, tCD_cycle, tEF_cycle;
    assign tAB_cycle = tB + 7'd80;
    assign tCD_cycle = tD + 7'd80;
    assign tEF_cycle = tF + 7'd80;
    
    always_ff @(posedge clk) begin
        if (!rst_n) bitmask_ptr <= 1'b0;
        else if (is_posedge) begin
            if(bitmask_ptr == N_active-1) bitmask_ptr <= '0;
            else bitmask_ptr <= bitmask_ptr + 1;
        end 
    end
    
    assign posedge_AB = is_posedge & bitmask_AB[bitmask_ptr];
    assign posedge_CD = is_posedge & bitmask_CD[bitmask_ptr];
    assign posedge_EF = is_posedge & bitmask_EF[bitmask_ptr];
    
    // AB pulse
    delay_gen_v2 dg2_AB (
        .clk(clk), .rst_n(rst_n), .en(en_AB), .is_posedge(posedge_AB), .active(active_AB),
        .t1(tA), .t2(tB), .t_cycle(tAB_cycle), .pulse(pulse_w1)
    );
    
    // CD pulse
    delay_gen_v2 dg2_CD (
        .clk(clk), .rst_n(rst_n), .en(en_CD), .is_posedge(posedge_CD), .active(active_CD),
        .t1(tC), .t2(tD), .t_cycle(tCD_cycle), .pulse(pulse_w2)
    );
    
    // EF pulse
    delay_gen_v2 dg2_EF (
        .clk(clk), .rst_n(rst_n), .en(en_EF), .is_posedge(posedge_EF), .active(active_EF),
        .t1(tE), .t2(tF), .t_cycle(tEF_cycle), .pulse(pulse_w3)
    );
    
endmodule
