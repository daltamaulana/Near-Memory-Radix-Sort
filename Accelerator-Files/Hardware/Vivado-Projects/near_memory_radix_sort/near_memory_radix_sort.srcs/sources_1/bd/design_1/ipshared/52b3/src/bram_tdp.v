//*************************************************************
//                      [ MODULE ]
//
// Institution       : Bandung Institute of Technology
// Engineer          : Dalta Imam Maulana
//
// Project Name      : Nodeflux Systolic Array
//
// Create Date       : 20/11/2019
// File Name         : bram_tdp.v
// Module Dependency : -
//
// Target Device     : Pynq-Z1
// Tool Version      : Vivado 2018.2
//
// Description:
//      True dual port Block RAM
//
//***********************************************************//

module bram_tdp
    // Declare parameters
    #(
        parameter DWIDTH = 32,
        parameter DEPTH = 2048,
        parameter ADDR_BIT = 32
    )

    // Declare input and output ports
    (
        // Input ports
        // Clock and control signal
        input clk_a, clk_b, en_a, en_b, we_a, we_b,
        // BRAM Address
        input [ADDR_BIT-1:0] addr_a, addr_b,
        // Data input
        input [DWIDTH-1:0] d_in_a, d_in_b,

        // Output ports
        output reg [DWIDTH-1:0] d_out_a, d_out_b
    );

    (* ram_style = "ultra" *)

    // Declare register
    reg [DWIDTH-1:0] ram [DEPTH-1:0];
    genvar i;
    
    for (i = 0; i < DEPTH; i = i + 1)
    begin
        initial
        begin
            ram[i] = 0;
        end
    end

    // Main logic
    // Port A
    always @(posedge clk_a)
    begin
    if (en_a)
        begin
        if (we_a)
            ram[addr_a] <= d_in_a;
        d_out_a <= ram[addr_a];
        end
    end

    // Port B
    always @(posedge clk_b)
    begin
    if (en_b)
        begin
        if (we_b)
            ram[addr_b] <= d_in_b;
        d_out_b <= ram[addr_b];
        end
    end

endmodule