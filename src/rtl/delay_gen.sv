`timescale 1ns / 1ps

typedef enum logic [1:0] {
    IDLE,
    PULSE,
    DELAY
} states_e;

module delay_gen #(
    parameter int DELAY_WIDTH = 50000,  // 500us (0.5 ms) for 100 MHz clock freq
    parameter int PULSE_WIDTH = 1000    // 10us for 100 MHz clock freq
)(
    input clk, rst, en, trig_in,
    output logic pulse_w1, delay
    );
    
    // Assuming that clock frequency is 100 MHz; period = 10 ns
    // Pulse duration = 10 us => counter = 1000
    // Delay duration = 500us => counter = 50000
    
    localparam int COUNTER_MAX = DELAY_WIDTH + PULSE_WIDTH;
    localparam int COUNTER_WIDTH = $clog2(COUNTER_MAX);
    
    logic [COUNTER_WIDTH-1:0] counter;
    logic is_posedge;
    
    posedge_detector pe(
        .clk(clk), .trig_in(trig_in), .is_posedge(is_posedge)
    );
    
    states_e state;
    
    always_ff @(posedge clk) begin 
        if(rst) begin
            counter <= 1'b0;
            pulse_w1 <= 1'b0;
            delay <= 1'b0;
            state <= IDLE;
        end
        else begin
            case(state) 
                IDLE: begin
                    if(is_posedge) begin
                        pulse_w1 <= 1'b1;
                        counter <= 1'b0;
                        state <= PULSE;
                    end 
                end  
                PULSE: begin
                    if(counter == PULSE_WIDTH-1) begin
                        pulse_w1 <= 1'b0;
                        delay <= 1'b1;
                        counter <= 1'b0;
                        state <= DELAY;
                    end
                    else counter <= counter + 1;
                end
                DELAY: begin
                    if(counter == DELAY_WIDTH-1) begin
                        delay <= 1'b0;
                        counter <= 1'b0;
                        state <= IDLE;
                    end 
                    else counter <= counter + 1;
                end
            endcase
        end
    end
    
endmodule
