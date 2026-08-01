`timescale 1ns / 1ps

module regfile (
    input clk, rst_n,
    input rx_valid, // signal indicating whether packet was successfully recieved
    input [23:0] packet, // raw packet containing time and selected pulse
    output logic [19:0] tA_new, tB_new, tC_new, tD_new, tE_new, tF_new,
    output logic [2:0] bitmask_AB, bitmask_CD, bitmask_EF,
    output logic error // in case an out-of-bounds register value is given
    );
    
    logic [19:0] registers[9];
    logic [19:0] data;
    logic [2:0] tX_select;
    logic dff1, dff2_rx_valid, is_bitmask;
    
    assign tA_new = registers[0];
    assign tB_new = registers[1];
    assign tC_new = registers[2];
    assign tD_new = registers[3];
    assign tE_new = registers[4];
    assign tF_new = registers[5];
    
    assign bitmask_AB = registers[6]; // for pulse_w1
    assign bitmask_CD = registers[7]; // for pulse_w2
    assign bitmask_EF = registers[8]; // for pulse_w3
    
    assign tX_select = packet[23:21];
    assign is_bitmask = (packet[20]) ? 1'b1 : 1'b0;
    //assign data = is_bitmask ? packet[2:0] : packet[19:0];
    assign data = packet[19:0];
    
    always_ff @(posedge clk) begin
        if(~rst_n) begin
            for(int i = 0; i < 9; i++)
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
                if(is_bitmask) begin
                    case(tX_select)
                        3'b001: registers[6] <= data[2:0];
                        3'b010: registers[7] <= data[2:0];
                        3'b100: registers[8] <= data[2:0];
                        default: error <= 1'b1; 
                    endcase
                end else begin
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
    end
    
endmodule
