`timescale 1ns / 1ps

module spi_slave #(
    parameter int PACKET_SIZE = 24
)(
    input sclk, cs, mosi, rst_n,
    output logic [PACKET_SIZE-1:0] packet_out, // 24 bits (22 bits for data, 2 bits for reg select),
    output logic rx_valid
);

    localparam int COUNTER_WIDTH = $clog2(PACKET_SIZE); // log2(24) ~= 24
    
    typedef enum logic [1:0] {
        IDLE = 2'b00,
        RX = 2'b01,
        DONE = 2'b10
    } spi_states_e;
    
    spi_states_e current_state, next_state;
   
    logic [PACKET_SIZE-1:0] rx_data;
    logic [COUNTER_WIDTH-1:0] counter; // 5-bit counter to count for 24
    logic rx_done;
    
    assign rx_done = rx_valid;
    
    always_comb begin
        next_state = current_state;
        case(current_state)
            IDLE: begin
                if(!cs) next_state = RX;
            end
            RX: begin
                if(rx_done) next_state = DONE;          
            end
            DONE: begin
                next_state = IDLE;
            end
        endcase
    end 
    
    always_ff @(posedge sclk) begin
        rx_valid <= 1'b0;
        if(~rst_n) begin
            current_state <= IDLE;
            counter <= '0;
            rx_valid <= 1'b0;
            rx_data <= '0;
            //packet_out <= '0;
        end 
        else begin
            current_state <= next_state;
            if(current_state == RX && !cs) begin
                counter <= counter + 1;
                if(counter == PACKET_SIZE-1) begin
                    packet_out <= rx_data;
                    counter <= '0;
                    rx_valid <= 1'b1;
                end  
                rx_data <= {rx_data[PACKET_SIZE-2:0], mosi};
            end
        end
    end
    
endmodule
