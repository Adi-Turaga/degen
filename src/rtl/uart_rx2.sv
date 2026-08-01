`timescale 1ns / 1ps

module uart_rx2 #(
    parameter int BAUD_RATE = 115200,
    parameter int CLK_FREQ = 50_000_000,
    
    localparam int TICK = CLK_FREQ / BAUD_RATE
)(
    input clk, rst_n, din,
    output logic [23:0] packet_out,
    output logic rx_valid
);

    typedef enum logic [1:0] {
        IDLE,
        START,
        RX,
        STOP
    } UART_states_e;

    logic [23:0] rx_data;
    logic [$clog2(TICK)-1:0] baud_counter; // should be 434 for 115200 baud rate
    logic [7:0] shift_reg; 
    logic [2:0] bit_counter; // 8 bits in one frame
    logic [1:0] byte_counter; // 3 bytes in one packet (24 bits / 8 bits/byte)
    logic is_negedge, din_sync;
    
    UART_states_e current_state, next_state;
    
    negedge_detector ne1(
        .clk(clk), .tx_idle(din), .is_negedge(is_negedge), .din_sync(din_sync)
    );
    
    always_comb begin
        next_state = current_state;
        case(current_state)
            IDLE: begin
                if(is_negedge) begin
                    next_state = START;
                end
            end  
            START: begin
                if(baud_counter == (TICK/2)-1) begin
                    next_state = (din_sync == 1'b0) ? RX : IDLE;
                end
            end
            RX: begin
                if (bit_counter == 7 && baud_counter == TICK-1)
                    next_state = STOP;
            end
            STOP: begin
                if(baud_counter == (TICK/2) - 1) begin
                //if(baud_counter == TICK - 1) begin
                    next_state = IDLE;
                end
            end
        endcase
    end   
       
    always_ff @(posedge clk) begin
        if (~rst_n) begin
            current_state <= IDLE;
            shift_reg <= 8'b0;
            baud_counter <= '0;
            bit_counter <= 3'b0;
            byte_counter <= 2'b0;
            rx_data <= 24'b0;
            packet_out <= 24'b0;
            rx_valid <= 1'b0;
        end
        else begin
            current_state <= next_state;
            rx_valid <= 1'b0;
    
            case (current_state)
                START: baud_counter <= baud_counter + 1;
    
                RX: begin
                    baud_counter <= baud_counter + 1;
                    if (baud_counter == TICK-1) begin
                        baud_counter <= '0;
                        shift_reg <= {din_sync, shift_reg[7:1]};  // LSB-first
                        bit_counter <= bit_counter + 1;
                    end
                end
    
                STOP: begin
                    baud_counter <= baud_counter + 1;
                    if (baud_counter == (TICK/2)-1) begin
                        rx_data <= {rx_data[15:0], shift_reg};
    
                        bit_counter <= 3'b0;
    
                        if (byte_counter == 2'd2) begin
                            packet_out <= {rx_data[15:0], shift_reg};
                            rx_valid <= 1'b1;
                            byte_counter <= 2'b0;
                        end
                        else begin
                            byte_counter <= byte_counter + 1;
                        end
                    end
                end
            endcase
            if (current_state != next_state) baud_counter <= '0;
        end
    end 
    
endmodule