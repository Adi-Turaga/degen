`timescale 1ns / 1ps

module tb_regfile();
    parameter int PACKET_SIZE = 24;
    parameter int NUM_TIMES = 6;
    
    localparam int T_IDX = $clog2(NUM_TIMES); // 3 for NUM_TIMES=6
    localparam int DATA_WIDTH = PACKET_SIZE - T_IDX; // 21 for default values

    logic clk, rst_n, rx_valid;
    logic [PACKET_SIZE-1:0] packet;  // raw packet containing time and selected pulse
    logic [DATA_WIDTH-1:0] tA, tB, tC, tD, tE, tF;
    logic error; // in case an out-of-bounds register value is given
    
    task send_data(input [23:0] packet_in);
    //begin
        @(posedge clk);
        packet   <= packet_in;
        rx_valid <= 1'b1;
    
        @(posedge clk);
        rx_valid <= 1'b0;
    
        // Hold packet stable long enough for synchronizer
        repeat(5) @(posedge clk);
    //end
    endtask
    
    regfile rf1(
        .clk(clk), .rst_n(rst_n), .rx_valid(rx_valid), 
        .packet(packet), .error(error),
        .tA_new(tA), .tB_new(tB), .tC_new(tC), .tD_new(tD), .tE_new(tE), .tF_new(tF)
    );
    
    logic [PACKET_SIZE-1:0] test_vector1, test_vector2, test_vector3;
    
    always #5 clk = ~clk;
    
    initial begin
        $monitor("Time=%0t : dff1=%0d, dff2_rx_valid=%0d, tX_select=%0d",
                    $time, rf1.dff1, rf1.dff2_rx_valid, rf1.tX_select);
    end
    
    initial begin
        clk <= 1'b0;
        rst_n <= 1'b0;
        rx_valid <= 1'b0;
        //packet <= '0;
        
        #100;
        
        rst_n <= 1'b1;
        rx_valid <= 1'b1;
        
        test_vector1 <= 24'h00A1B2;
        test_vector2 <= 24'hC02468;
        test_vector3 <= 24'hA03579;
        
        repeat(15) @(posedge clk);
        
        send_data(test_vector1); assert(tA == test_vector1[20:0]);
        send_data(test_vector2); assert(tB == test_vector2[20:0]); assert(error == 1'b1);
        send_data(test_vector3); assert(tC == test_vector3[20:0]);
        
        send_data(24'h00000);
        send_data(24'h2003e8);
        
        repeat(10) @(posedge clk);
        $finish;
    end
    
endmodule
