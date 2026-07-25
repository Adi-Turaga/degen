`timescale 1ns / 1ps

module degen #(
    parameter int NUM_SLOTS = 2
)(
    input clk, rst,trig_in,
    input [31:0] tA, tB, // tA is the start time and tB is the stop time
    input [31:0] tC, tD, // tC is the start time and tD is the stop time
    input [34:0] t_cycle , // t_cycle corresponds to how long cycle is,
    output logic pulse_w1, pulse_w2
);
    logic is_posedge;
    
    posedge_detector pe(
        .clk(clk), .trig_in(trig_in), .is_posedge(is_posedge)
    );
    
    logic [39:0] master_counter;
    
    // for slots
    logic [39:0] trig_time[NUM_SLOTS];
    logic [39:0] elapsed[NUM_SLOTS];
    logic slot_valid[NUM_SLOTS];
    logic [$clog2(NUM_SLOTS)-1:0] wr_ptr;
    
    logic p1_en[NUM_SLOTS];
    logic p2_en[NUM_SLOTS];
    
    always_ff @(posedge clk) begin
        if(rst) begin
            master_counter <= 40'b0;
            wr_ptr <= '0;
            for(int i = 0; i < NUM_SLOTS; i++) slot_valid[i] <= 1'b0;
        end
        else begin
            master_counter <= master_counter + 1;
            if(is_posedge) begin
                trig_time[wr_ptr] <= master_counter;
                slot_valid[wr_ptr] <= 1'b1;
                wr_ptr <= wr_ptr + 1;
            end
            for(int j = 0; j < NUM_SLOTS; j++) begin
                if(slot_valid[j] && elapsed[j] >= t_cycle) slot_valid[j] <= 1'b0;
            end 
        end
    end
    
    generate
        for(genvar k = 0; k < NUM_SLOTS; k++) begin : slots
            assign elapsed[k] = master_counter - trig_time[k];
            assign p1_en[k] = (slot_valid[k]) && (elapsed[k] >= tA) && (elapsed[k] < tB);
            assign p2_en[k] = (slot_valid[k]) && (elapsed[k] >= tC) && (elapsed[k] < tD);
        end
    endgenerate
    
    always_comb begin
        pulse_w1 = 1'b0;
        pulse_w2 = 1'b0;
        for(int m = 0; m < NUM_SLOTS; m++) begin
            pulse_w1 |= p1_en[m];
            pulse_w2 |= p2_en[m];
        end
    end
    
endmodule
