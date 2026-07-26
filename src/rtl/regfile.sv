`timescale 1ns / 1ps

module regfile #(
    parameter int PACKET_SIZE = 24,
    parameter int NUM_TIMES = 6,
    
    localparam int T_IDX = $clog2(NUM_TIMES), // 3 for NUM_TIMES=6
    localparam int DATA_WIDTH = PACKET_SIZE - T_IDX // 21 for default values
)(
    input clk, rst_n,
    input rx_valid, // signal indicating whether packet was successfully recieved
    input [PACKET_SIZE-1:0] packet, // raw packet containing time and selected pulse
    output logic [DATA_WIDTH-1:0] tA_new, tB_new, tC_new, tD_new, tE_new, tF_new,
    output logic error // in case an out-of-bounds register value is given
    );
    
    logic [DATA_WIDTH-1:0] registers[NUM_TIMES];
    logic [DATA_WIDTH-1:0] data;
    logic [T_IDX-1:0] tX_select;
    logic dff1, dff2_rx_valid;
    
    assign tA_new = registers[0];
    assign tB_new = registers[1];
    assign tC_new = registers[2];
    assign tD_new = registers[3];
    assign tE_new = registers[4];
    assign tF_new = registers[5];
    
    assign data = packet[DATA_WIDTH-1:0]; // [20:0]
    assign tX_select = packet[PACKET_SIZE-1:DATA_WIDTH]; // [23:21]
    
    always_ff @(posedge clk) begin
        if(~rst_n) begin
            for(int i = 0; i < NUM_TIMES; i++)
                registers[i] <= '0;
            error <= 1'b0;
            dff1 <= 1'b0;
            dff2_rx_valid <= 1'b0;
        end
        else begin
            // 2-FF synchronizer
            dff1 <= rx_valid;
            dff2_rx_valid <= dff1;
            
            error <= 1'b0;
            if(dff2_rx_valid) begin
                case(tX_select) 
                    3'b000: registers[0] <= data;
                    3'b001: registers[1] <= data; 
                    3'b010: registers[2] <= data;
                    3'b011: registers[3] <= data;
                    3'b100: registers[4] <= data;
                    3'b101: registers[5] <= data;
                    default: error <= 1'b1;
                endcase
            end
        end
    end
    
endmodule
