`timescale 1ns / 1ps

module tb_regfile();

    logic clk, rst_n, rx_valid;
    logic [23:0] packet;  // raw packet containing time and selected pulse
    logic [19:0] tA, tB, tC, tD, tE, tF;
    logic [2:0] bitmask_AB, bitmask_CD, bitmask_EF;
    logic error; // in case an out-of-bounds register value is given
    
    task send_data(input [23:0] packet_in);
        @(posedge clk);
        packet   <= packet_in;
        rx_valid <= 1'b1;
    
        @(posedge clk);
        rx_valid <= 1'b0;
    
        // Hold packet stable long enough for synchronizer
        repeat(5) @(posedge clk);
    endtask
    
    regfile rf1(
        .clk(clk), .rst_n(rst_n), .rx_valid(rx_valid), 
        .packet(packet), .error(error),
        .tA_new(tA), .tB_new(tB), .tC_new(tC), .tD_new(tD), .tE_new(tE), .tF_new(tF),
        .bitmask_AB(bitmask_AB), .bitmask_CD(bitmask_CD), .bitmask_EF(bitmask_EF)
    );
    
    logic [23:0] tA_sel, tB_sel, tC_sel, tD_sel, tE_sel, tF_sel;
    logic [23:0] bitmask_AB_sel, bitmask_CD_sel, bitmask_EF_sel;
    
    always #5 clk = ~clk;
    
    initial begin
        $monitor("Time=%0t : dff1=%0d, dff2_rx_valid=%0d, tX_select=%0d, is_bitmask=%0d, packet_in=%4b, packet=%4b",
                    $time, rf1.dff1, rf1.dff2_rx_valid, rf1.tX_select, rf1.is_bitmask, packet[23:20], rf1.packet[23:20]);
    end
    
    initial begin
        clk <= 1'b0;
        rst_n <= 1'b0;
        rx_valid <= 1'b0;
        //packet <= '0;
        
        #100;
        
        rst_n <= 1'b1;
        rx_valid <= 1'b1;
        
        tA_sel <= 24'h0;
        tB_sel <= 24'h2001f4;
        tC_sel <= 24'h400000;
        tD_sel <= 24'h6001f4;
        tE_sel <= 24'h800000;
        tF_sel <= 24'ha001f4;
        
        //bitmask_AB <= 24'h300004;
        bitmask_AB_sel <= 24'b001100000000000000000100;
        bitmask_CD_sel <= 24'h500002;
        bitmask_EF_sel <= 24'h900001;
        
        repeat(15) @(posedge clk);
        
        send_data(tA_sel);
        send_data(tB_sel);
        send_data(tC_sel); 
        send_data(tD_sel); 
        send_data(tE_sel); 
        send_data(tF_sel); 
        
        send_data(bitmask_AB_sel);
        send_data(bitmask_CD_sel);
        send_data(bitmask_EF_sel);
        
        repeat(10) @(posedge clk);
        $finish;
    end
    
endmodule
