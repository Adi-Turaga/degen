`timescale 1ns / 1ps

module spi_slave2 #(
    parameter int PACKET_SIZE = 24
)(
    input sclk, cs, mosi, rst_n,
    output logic [PACKET_SIZE-1:0] packet_out, // 24 bits (22 bits for data, 2 bits for reg select),
    output logic rx_valid
);

    localparam int COUNTER_WIDTH = $clog2(PACKET_SIZE);
    logic [PACKET_SIZE-1:0] rx_data;
    logic [COUNTER_WIDTH-1:0] counter; // 5-bit counter to count for 24
    logic [PACKET_SIZE-1:0] shifted;

    always_comb begin
        shifted = {rx_data[PACKET_SIZE-2:0], mosi};
    end
    
    always_ff @(posedge sclk) begin
        if(~rst_n) begin
            counter <= '0;
            rx_valid <= 1'b0;
            rx_data <= '0;
        end
        else begin
            if(cs) counter <= '0;
            else begin
                counter <= counter + 1;
                rx_data <= shifted;
                if(counter == PACKET_SIZE-1) begin
                    packet_out <= shifted;
                    rx_valid <= 1'b1;
                    counter <= '0;
                end
            end
        end
    end

endmodule
