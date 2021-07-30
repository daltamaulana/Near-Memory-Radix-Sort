`timescale 1ns / 1ps

module stream_queue_out
    // Declare parameters
    #(
        parameter DWIDTH = 128,
        parameter SIZE = 1024,
        parameter ADDR_BIT = 10
    )
    // Declare ports
    (
        // Input ports
        input wire I_CLK,
        input wire I_RSTN,
        input wire I_QUEUE,
        input wire I_DEQUEUE,
        input wire [DWIDTH-1:0] I_DATA,

        // Output ports
        output wire O_EMPTY,
        output wire O_ALMOST_FULL,
        output wire O_FULL,
        output wire O_DATA_VALID,
        output wire [DWIDTH-1:0] O_DATA,
        output wire [ADDR_BIT-1:0] O_DATA_INDEX,

        // Debug Ports
        input wire [ADDR_BIT-1:0] I_DEBUG_ADDR,
        output wire [DWIDTH-1:0] O_DEBUG_DATA
    );

    //////////////////////////////////////
    //  Registers and wire declaration  //
    //////////////////////////////////////
    // Registers
    reg [ADDR_BIT-1:0] r_write_pointer;
    reg [ADDR_BIT-1:0] r_read_pointer;
    reg [ADDR_BIT-1:0] r_queue_addr;
    reg [ADDR_BIT-1:0] r_data_index;
    reg r_full;
    reg r_data_valid;
    reg r_almost_full;
    reg r_dequeue_delayed;
    
    // Wire
    wire w_write_enable;
    wire [DWIDTH-1:0] w_internal_data;

    //////////////////////////////////////
    //       Dequeue Delay Logic        //
    //////////////////////////////////////
    always @(posedge I_CLK) 
    begin
        r_dequeue_delayed <= I_DEQUEUE;    
    end

    //////////////////////////////////////
    //         Data Index Logic         //
    //////////////////////////////////////
    always @(posedge I_CLK) 
    begin
        if (!I_RSTN)
        begin
            r_data_index <= 0;
        end    
        else
        begin
            r_data_index <= r_read_pointer;
        end
    end

    //////////////////////////////////////
    //   Read and Write Pointer Logic   //
    //////////////////////////////////////
    // Write pointer logic
    always @(posedge I_CLK) 
    begin
        if (!I_RSTN)
        begin
            r_write_pointer <= 0;
        end    
        else
        begin
            if ((I_QUEUE == 1) && (O_FULL == 0))
            begin
                r_write_pointer <= r_write_pointer + 1;
            end
            else
            begin
                r_write_pointer <= r_write_pointer;
            end
        end
    end

    // Read pointer logic
    always @(posedge I_CLK) 
    begin
        if (!I_RSTN)
        begin
            r_read_pointer <= 0;
        end    
        else
        begin
            if ((I_DEQUEUE == 1) && (O_EMPTY == 0))
            begin
                r_read_pointer <= r_read_pointer + 1;
            end
            else
            begin
                r_read_pointer <= r_read_pointer;
            end
        end
    end

    //////////////////////////////////////
    //        Full Signal Logic         //
    //////////////////////////////////////
    always @(*) 
    begin
        if (r_write_pointer < 1023)
        begin
            // Almost full logic
            if (r_write_pointer < 1022)
            begin
                r_almost_full <= ((r_write_pointer + 2) == r_read_pointer);
            end
            else
            begin
                r_almost_full <= (r_read_pointer == 0);
            end
            // Full logic
            r_full <= ((r_write_pointer + 1) == r_read_pointer);
        end    
        else
        begin
            r_almost_full <= (r_read_pointer == 1);
            r_full <= (r_read_pointer == 0);
        end
    end

    //////////////////////////////////////
    //        Output Valid Logic        //
    //////////////////////////////////////
    always @(posedge I_CLK) 
    begin
        if (!I_RSTN)
        begin
            r_data_valid <= 0;
        end    
        else
        begin
            if (O_EMPTY)
            begin
                r_data_valid <= 0;
            end
            else
            begin
                if (I_DEQUEUE && !r_dequeue_delayed)
                begin
                    r_data_valid <= 0;
                end
                else
                begin
                    r_data_valid <= 1;
                end
            end
        end
    end

    //////////////////////////////////////
    //      Queue Address Selector      //
    //////////////////////////////////////
    always @(*) 
    begin
        if (I_QUEUE == 1)
        begin
            r_queue_addr <= r_write_pointer;
        end    
        else
        begin
            r_queue_addr <= I_DEBUG_ADDR;
        end
    end

    //////////////////////////////////////
    //       Module Instantiation       //
    //////////////////////////////////////
    // BRAM signal logic
    assign w_write_enable = (I_QUEUE == 1'b1);

    // BRAM module
    bram_tdp #(
        .DWIDTH(DWIDTH),
        .DEPTH(SIZE),
        .ADDR_BIT(ADDR_BIT)
    ) stream_out_queue_bram (
        .clk_a(I_CLK),
        .clk_b(I_CLK),
        .en_a(1'b1),
        .en_b(1'b1),
        .we_a(w_write_enable),
        .we_b(1'b0),
        .addr_a(r_queue_addr),
        .addr_b(r_read_pointer),
        .d_in_a(I_DATA),
        .d_in_b(I_DATA),
        .d_out_a(O_DEBUG_DATA),
        .d_out_b(w_internal_data)
    );

    //////////////////////////////////////
    //       Port Output Assignment     //
    //////////////////////////////////////
    assign O_EMPTY = (r_write_pointer == r_read_pointer);
    assign O_ALMOST_FULL = r_almost_full;
    assign O_FULL = r_full;
    assign O_DATA_VALID = r_data_valid;
    assign O_DATA = w_internal_data;
    assign O_DATA_INDEX = r_data_index;

endmodule
