`timescale 1ns / 1ps

module delay_gen_v2(
    input clk, rst, en,
    input [21:0] t1, t2, // t1 and t2 correspond to when they start in microseconds
    input [21:0] t_cycle , // t_cycle corresponds to how long cycle is,
    input is_posedge,
    output logic pulse, active
    );
    
    typedef enum logic {
        IDLE,
        RUNNING
    } states_e;
    
    /*
        If 10 us pulse w/ 500 us delay is desired,
        - t1 = 0 & t2 = 1000 (if clk frequency = 100 MHz)
        - t_cycle = 50000 (if clk frequency = 100 MHz)
    */
    
    logic [39:0] master_counter;
    //logic is_posedge;
    
    /*logic t1_active, t2_active;
    
    assign t1_active = (t1 < t2) && (master_counter >= t1);
    assign t2_active = (t2 > t1) && (master_counter >= t2);*/
    
    states_e state;
    
    always_ff @(posedge clk) begin
        if(rst) begin
            state <= IDLE;
            master_counter <= '0;
            active <= 1'b0;
        end 
        else begin
            case(state) 
                IDLE: begin
                    if(is_posedge) begin
                        master_counter <= 0;
                        state <= RUNNING;
                        active <= 1'b1;
                    end
                end
                RUNNING: begin
                    if(master_counter == t_cycle-1) begin
                        master_counter <= 1'b0;
                        state <= IDLE;
                        active <= 1'b0;
                    end
                    else master_counter <= master_counter + 1;
                end
            endcase
        end
    end 
    
    //assign pulse = t1_active ^ t2_active;
    assign pulse = (state == RUNNING) &&
               (master_counter >= t1) &&
               (master_counter < t2);
    
endmodule
