`timescale 1ns / 1ps

module dma_controller
    // Declare ports
    (
        // Clock and Reset
        input wire        I_ACLK,
        input wire        I_ARESETN,
        
        // Signal from PS
        input wire        I_START,
        input wire [31:0] I_ADDR,
        input wire [31:0] I_BYTE_TO_TRANSFER,
        input wire [31:0] I_NO_OF_RECV_TRANSACTION,
        input wire [2:0]  I_MODE,

        input wire [31:0] I_ADDR_INPUT,
        input wire [31:0] I_ADDR_INSTRUCTION,
        input wire [31:0] I_ADDR_OUTPUT,

        output wire       O_DONE,

        // Signal to DMA
        output wire [31:0] O_DMA_REG_ADDRESS,
        output wire [31:0] O_DMA_REG_DATA,
        output wire        O_DMA_INIT_AXI_TXN,
        input  wire        I_DMA_AXI_TXN_DONE,
        output wire [31:0] O_DMA_NO_OF_TRANSACTION,
        output reg  [1:0]  O_DMA_TRANSFER_MODE,

        input  wire [31:0] I_BRAM_DEBUG_ADDR
    );

    ///////////////////////////////
	//     Start Signal Logic    //
	///////////////////////////////
    // Declare register and wire
    reg r_start_delay;
    wire w_start_pulse;
    
    // Start signal logic
    always @(posedge I_ACLK) 
    begin
        r_start_delay <= I_START;
    end
    // Start pulse generation
    assign w_start_pulse = I_START && !r_start_delay;

    ////////////////////////////////////////
	//     General State Machine Logic    //
	////////////////////////////////////////
    // Declare local parameters
    localparam [1:0] IDLE    = 2'd0,
                     RUNNING = 2'd1,
                     DONE    = 2'd2;
    
    // Declare local parameters
    localparam [2:0] TF_MODE_IDLE = 3'd0,
                     TF_MODE_ON = 3'd1,
                     TF_MODE_READ_RAM = 3'd2,
                     TF_MODE_WRITE_RAM = 3'd3,
                     TF_MODE_LOAD_INSTRUCTION = 3'd4,
                     TF_MODE_DONE = 3'd5;
    
    // Declare registers
    reg [1:0] r_internal_state;
    reg [2:0] r_dma_controller_state;

    // Assign done and stream send signal value
    assign O_DONE = (r_internal_state == DONE);

    // State machine logic
    always @(posedge I_ACLK) 
    begin
        if (!I_ARESETN)
        begin
            r_internal_state <= IDLE;
        end    
        else
        begin
            case (r_internal_state)
                IDLE:
                begin
                    if (w_start_pulse)
                    begin
                        r_internal_state <= RUNNING;
                    end
                    else
                    begin
                        r_internal_state <= IDLE;
                    end
                end
                RUNNING:
                begin
                    if (r_dma_controller_state == TF_MODE_DONE)
                    begin
                        r_internal_state <= DONE;
                    end
                    else
                    begin
                        r_internal_state <= RUNNING;
                    end
                end
                DONE:
                begin
                    r_internal_state <= IDLE;
                end
                default:
                begin
                    r_internal_state <= IDLE;
                end
            endcase
        end
    end

    ////////////////////////////////
	//     DMA Operation Logic    //
	////////////////////////////////
    // Declare registers
    reg [3:0] r_no_of_req_issued;
    wire [3:0] w_no_of_req_max;

    // State logic
    always @(posedge I_ACLK) 
    begin
        if (!I_ARESETN || r_internal_state != RUNNING)
        begin
            r_dma_controller_state <= TF_MODE_IDLE;
        end    
        else
        begin
            case (r_dma_controller_state)
                TF_MODE_IDLE:
                begin
                    if (I_MODE == 0)
                    begin
                        r_dma_controller_state <= TF_MODE_ON;
                    end
                    else if (I_MODE == 1)
                    begin
                        r_dma_controller_state <= TF_MODE_READ_RAM;
                    end
                    else if (I_MODE == 2)
                    begin
                        r_dma_controller_state <= TF_MODE_WRITE_RAM;
                    end
                    else if (I_MODE == 3)
                    begin
                        r_dma_controller_state <= TF_MODE_LOAD_INSTRUCTION;
                    end
                    else
                    begin
                        r_dma_controller_state <= TF_MODE_IDLE;
                    end
                end
                TF_MODE_ON, TF_MODE_READ_RAM, TF_MODE_WRITE_RAM, TF_MODE_LOAD_INSTRUCTION:
                begin
                    if ((r_no_of_req_issued == (w_no_of_req_max-1)) && I_DMA_AXI_TXN_DONE)
                    begin
                        r_dma_controller_state <= TF_MODE_DONE;
                    end
                    else
                    begin
                        r_dma_controller_state <= r_dma_controller_state;
                    end
                end
                default:
                begin
                    r_dma_controller_state <= r_dma_controller_state;
                end
            endcase
        end
    end

    // Request issued logic
    always @(posedge I_ACLK)
    begin
        if (!I_ARESETN || (r_internal_state != RUNNING))
        begin
            r_no_of_req_issued <= 0;
        end
        else
        begin
            if (I_DMA_AXI_TXN_DONE)
            begin
                r_no_of_req_issued <= r_no_of_req_issued + 1;
            end
            else
            begin
                r_no_of_req_issued <= r_no_of_req_issued;
            end
        end
    end

    // Request max logic
    assign w_no_of_req_max = 1;

    //******************************//
	//     Initial Counter Logic    //
	//******************************//
    // Declare register
    reg [1:0] r_init_counter;

    // Counter logic
    always @(posedge I_ACLK) 
    begin
        if (!I_ARESETN || (r_internal_state != RUNNING) || I_DMA_AXI_TXN_DONE)
        begin
            r_init_counter <= 0;
        end    
        else
        begin
            if (r_dma_controller_state != TF_MODE_IDLE)
            begin
                if (r_init_counter == 3)
                begin
                    r_init_counter <= r_init_counter;
                end
                else
                begin
                    r_init_counter <= r_init_counter + 1;
                end
            end
            else
            begin
                r_init_counter <= 0;
            end
        end
    end

    //****************************************//
	//     Register Address and Data Logic    //
	//****************************************//
    // Declare registers
    reg [31:0] r_reg_address;
    reg [31:0] r_reg_data;

    // Address and data logic
    always @(posedge I_ACLK) 
    begin
        if (!I_ARESETN || (r_internal_state != RUNNING))
        begin
            r_reg_address <= 0;
            r_reg_data <= 0;
        end    
        else
        begin
            case (r_dma_controller_state)
                TF_MODE_ON:
                begin
                    r_reg_address <= 1;
                    r_reg_data <= 1;
                end
                TF_MODE_READ_RAM:
                begin
                    r_reg_address <= I_ADDR_INPUT;
                    r_reg_data <= I_BYTE_TO_TRANSFER;
                end
                TF_MODE_WRITE_RAM:
                begin
                    r_reg_address <= I_ADDR_OUTPUT;
                    r_reg_data <= I_BYTE_TO_TRANSFER;
                end
                TF_MODE_LOAD_INSTRUCTION:
                begin
                    r_reg_address <= I_ADDR_INSTRUCTION;
                    r_reg_data <= 8*1024; // 1024 x 64-bit instruction
                end
                default:
                begin
                    r_reg_address <= 0;
                    r_reg_data <= 0;
                end
            endcase
        end
    end

    // Assign value to output port
    assign O_DMA_REG_ADDRESS = r_reg_address;
    assign O_DMA_REG_DATA = r_reg_data;
    assign O_DMA_NO_OF_TRANSACTION = I_NO_OF_RECV_TRANSACTION; // Only Used when receiving data in iteration means bytes/16
    assign O_DMA_INIT_AXI_TXN = (r_internal_state == RUNNING) && (r_init_counter == 2);

    // DMA transfer mode
    always @(*) 
    begin
        case (I_MODE)
            1, 3: // Read RAM or read instruction
            begin
                O_DMA_TRANSFER_MODE = 1; // Read RAM
            end
            2: // Write RAM
            begin
                O_DMA_TRANSFER_MODE = 2; // Write RAM
            end
            default:
            begin
                O_DMA_TRANSFER_MODE = 0; // IDLE
            end
        endcase    
    end

endmodule
