`timescale 1ns/1ps

module tb_radix_sorting_unit;

    reg CLK, RESETN;
    wire [127:0] DATA_IN1, DATA_IN2;
    wire [127:0] DATA_OUT;
    wire [9:0] ADDR1, ADDR2;
    wire WE1, WE2;
    /*wire EN1, EN2;*/
    reg FIRST_START;
    wire DONE;



    radix_sorting_unit UUT
    (   
        // General signal
        // Input
		.I_ACLK(CLK),
		.I_ARESETN(RESETN),
        .I_SORTING_START(FIRST_START),
        // Output
        .O_SORTING_DONE(DONE),

        // BRAM signal
        // Input
        .I_EVEN_DATA(DATA_IN1),
        .I_ODD_DATA(DATA_IN2),
        // Output
        .O_EVEN_WE(WE1),
        .O_ODD_WE(WE2),
        .O_EVEN_ADDR(ADDR1),
        .O_ODD_ADDR(ADDR2),
        .O_SORT_DATA(DATA_OUT),

        // Debug signal
        .D_SORT_STATE(),
        .D_FIRST_STATE(),
        .D_EVEN_STATE(),
        .D_ODD_STATE(),
        .D_DATA_STATE(),
        .D_SORT_START_DELAY(),
        .D_POINTER_0(), 
        .D_POINTER_1()

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
        .d_in_a(DATA_OUT), .d_in_b(),

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
        .d_out_a(DATA_IN2), .d_out_b()
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
        // $finish;
    end

endmodule