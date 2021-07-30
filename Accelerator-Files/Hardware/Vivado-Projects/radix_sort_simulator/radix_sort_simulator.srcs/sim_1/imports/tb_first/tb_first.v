



`timescale 1ns/1ps

module tb_first;

    reg CLK, RESETN;
    wire [127:0] DATA_IN1, DATA_IN2;
    wire [127:0] DATA_OUT;
    wire [9:0] ADDR1, ADDR2;
    wire WE1, WE2;
    /*wire EN1, EN2;*/
    reg FIRST_START;
    wire DONE;



    top_first TOP_FIRST
    (   
        .clk(CLK),
        .resetn(RESETN),
        .first_start(FIRST_START),
        .data_in1(DATA_IN1),
        .data_in2(),
        .data_out(DATA_OUT),
        .addr1(ADDR1), .addr2(ADDR2),
        .we1(WE1), .we2(WE2),
        .done(DONE)

    );
    
    bram_tdp_in #(
        .DWIDTH(128),
        .DEPTH(1024),
        .ADDR_BIT(10)
    )
    BRAM1
    (
        .clk_a(CLK), .clk_b(CLK), .en_a(1'b1), .en_b(1'b1), .we_a(WE1), .we_b(0),
        // BRAM Address
        .addr_a(ADDR1), .addr_b(),
        // Data input
        .d_in_a(), .d_in_b(),

        // Output ports
        .d_out_a(DATA_IN1), .d_out_b()
    );

    bram_tdp_out #(
        .DWIDTH(128),
        .DEPTH(1024),
        .ADDR_BIT(10)
    )
    BRAM2
    (
        .clk_a(CLK), .clk_b(CLK), .en_a(1'b1), .en_b(1'b1), .we_a(WE2), .we_b(),
        // BRAM Address
        .addr_a(ADDR2), .addr_b(),
        // Data input
        .d_in_a(DATA_OUT), .d_in_b(),

        // Output ports
        .d_out_a(), .d_out_b()
    );

    initial begin
        CLK = 0;
        forever #10 CLK = ~CLK;     
    end

    initial begin
        RESETN = 0; #40;
        RESETN = 1; #40;
        FIRST_START = 0; #40;
        FIRST_START = 1; #30000;
        $finish;
    end

endmodule