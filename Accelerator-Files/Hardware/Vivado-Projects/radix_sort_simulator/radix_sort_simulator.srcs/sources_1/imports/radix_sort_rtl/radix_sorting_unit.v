//**********************************************************************************
//                      [ MODULE ]
//
// Institution       : Korea Advanced Institute of Science and Technology (KAIST)
// Engineer          : -
//
// Project Name      : Near Memory Radix Sort
//
// Create Date       : 06/22/2021
// File Name         : radix_sorting_unit.v
// Module Dependency : -
//
// Target Device     : ZCU-104
// Tool Version      : Vivado 2020.1
//
// Description:
//       Module which performs radix sorting operation
//
//**********************************************************************************

module radix_sorting_unit
    // Declare parameters
    #(
        parameter DWIDTH = 128,
        parameter SELWIDTH =10,
		parameter INSTWIDTH =64,
        parameter ELEMWIDTH = 32,
        parameter DWIDTHBIT = 5,
        parameter DATABRAMDEPTH =1024, 
        parameter DATAADDRWIDTH =11,
        parameter INSTADDRWIDTH =10
    )
    // Declare ports
    (
        // General signal
        // Input
		input wire I_ACLK,
		input wire I_ARESETN,
        input wire I_SORTING_START,
        // Output
        output wire O_SORTING_DONE,

        // BRAM signal
        // Input
        input wire [DWIDTH-1:0] I_EVEN_DATA,
        input wire [DWIDTH-1:0] I_ODD_DATA,
        // Output
        output wire O_EVEN_WE,
        output wire O_ODD_WE,
        output wire [DATAADDRWIDTH-1:0] O_EVEN_ADDR,
        output wire [DATAADDRWIDTH-1:0] O_ODD_ADDR,
        output wire [DWIDTH-1:0] O_SORT_DATA,

        // Debug signal
        output wire [2:0] D_SORT_STATE,
        output wire [2:0] D_FIRST_STATE,
        output wire [3:0] D_EVEN_STATE,
        output wire [3:0] D_ODD_STATE,
        output wire [3:0] D_DATA_STATE,
        output wire D_SORT_START_DELAY,
        output wire [DATAADDRWIDTH:0] D_POINTER_0, 
        output wire [DATAADDRWIDTH:0] D_POINTER_1
    );

    ///////////////////////////////
	//     Instantiate Module    //
	///////////////////////////////
    // Declare registers and wires
    // Sorting unit
    reg [ELEMWIDTH-1:0] r_data_mask;
    wire w_row_idx;
    wire [2:0] w_data_pattern;
    wire [(2*DWIDTH)-1:0] w_sorted_array;
    wire [(2*DWIDTH)-1:0] w_unsorted_array;

    // Data shifter
    reg [DWIDTH-1:0] r_shifter_data;
    wire w_shifter_start;
    wire w_shifter_valid;
    wire w_shifter_first_row;
    wire [DATAADDRWIDTH-1:0] w_one_count;
    wire [DATAADDRWIDTH-1:0] w_zero_count;
    wire [DWIDTH-1:0] w_shifter_cache_data;

    // Assign value to wires
    // Sorting unit
    assign w_unsorted_array = (r_sort_state == FIRST_DIGIT) ? {r_first_unsorted_cache[1], r_first_unsorted_cache[0]} : 
                              (r_sort_state == EVEN_DIGIT) ? {r_even_unsorted_cache[1], r_even_unsorted_cache[0]} : 
                              (r_sort_state == ODD_DIGIT) ? {r_odd_unsorted_cache[1], r_odd_unsorted_cache[0]} : 256'd0;
    // Data marker
    assign w_shifter_first_row = (r_sort_state == FIRST_DIGIT);
    assign w_zero_count = (r_sort_state == FIRST_DIGIT) ? DATABRAMDEPTH : w_count_0;
    assign w_one_count = (r_sort_state == FIRST_DIGIT) ? 0 : w_count_1;
    assign w_shifter_start = (r_sort_state == FIRST_DIGIT) ? r_first_shifter_start : 
                             (r_sort_state == EVEN_DIGIT) ? r_even_shifter_start : 
                             (r_sort_state == ODD_DIGIT) ? r_odd_shifter_start : 
                             (r_sort_state == DATA_REARRANGE) ? r_data_shifter_start : 1'b0;

    // Data selector
    always @(*) 
    begin
        case (r_sort_state)
            IDLE:
            begin
                r_shifter_data = I_EVEN_DATA;
            end
            FIRST_DIGIT:
            begin
                r_shifter_data = I_EVEN_DATA;
            end
            EVEN_DIGIT:
            begin
                r_shifter_data = I_ODD_DATA;
            end
            ODD_DIGIT:
            begin
                r_shifter_data = I_EVEN_DATA;
            end
            DATA_REARRANGE:
            begin
                r_shifter_data = I_EVEN_DATA;
            end
            default:
            begin
                r_shifter_data = I_EVEN_DATA;
            end
        endcase  
    end

    // Instantiate module
    // Sorting unit
    sorting_unit sorting_unit (
        .data_in(w_unsorted_array),
        .mask_in(r_data_mask),
        .data_out(w_sorted_array),
        .row_idx(w_row_idx),
        .data_pattern(w_data_pattern)
    );

    // Data shifter unit
    data_shifter data_shifter_unit (
        // Input ports
        .I_ACLK(I_ACLK),
        .I_ARESETN(I_ARESETN),
        .I_START(w_shifter_start),
        .I_DATA_FLAG(w_sorter_mixed_flag),
        .I_FIRST_ROW(w_shifter_first_row),
        .I_DATA_PATTERN(w_sorter_data_pattern),
        .I_ZERO_COUNT(w_zero_count),
        .I_ONE_COUNT(w_one_count),
        .I_BRAM_DATA(r_shifter_data),

        // Output ports
        .O_VALID(w_shifter_valid),
        .O_CACHE_DATA(w_shifter_cache_data)
    );

    ////////////////////////////////////////
	//     Start and Done Signal Logic    //
	////////////////////////////////////////
    // Declare registers
    // Global start
    reg r_start_delay;
    wire w_start_pulse;
    // First start
    reg r_first_start;
    reg r_first_start_delay;
    wire w_first_done;
    wire w_first_start_pulse;
    // Even start
    reg r_even_start;
    reg r_even_start_delay;
    wire w_even_done;
    wire w_even_start_pulse;
    // Odd start
    reg r_odd_start;
    reg r_odd_start_delay;
    wire w_odd_done;
    wire w_odd_start_pulse;
    // Data start
    reg r_data_start;
    reg r_data_start_delay;
    wire w_data_done;
    wire w_data_start_pulse;    
    
    // Delayed start signal
    always @(posedge I_ACLK) 
    begin
        if (!I_ARESETN)
        begin
            r_start_delay <= 0;
            r_first_start_delay <= 0;
            r_even_start_delay <= 0;
            r_odd_start_delay <= 0;
            r_data_start_delay <= 0;
        end
        else
        begin
            r_start_delay <= I_SORTING_START;
            r_first_start_delay <= r_first_start;
            r_even_start_delay <= r_even_start;
            r_odd_start_delay <= r_odd_start;
            r_data_start_delay <= r_data_start;
        end
    end

    // Start pulse generation
    assign w_start_pulse        = I_SORTING_START && !r_start_delay;
    assign w_first_start_pulse  = r_first_start && !r_first_start_delay;
    assign w_even_start_pulse   = r_even_start && !r_even_start_delay;
    assign w_odd_start_pulse    = r_odd_start && !r_odd_start_delay;
    assign w_data_start_pulse   = r_data_start && !r_data_start_delay;
    // Debug signal
    assign D_SORT_START_DELAY = r_start_delay;

    /////////////////////////////////////////////////////
    //            Global State Machine                 //
    ///////////////////////////////////////////////////// 
    // Declare registers and wire
    
    reg [2:0] r_sort_state;
    reg [2:0] r_sort_state_prev;
    reg [DWIDTHBIT-1:0] r_digit;
    wire [DATAADDRWIDTH-1:0] w_mixed_pointer;
    wire [DATAADDRWIDTH-1:0] w_pointer_0;
    wire [DATAADDRWIDTH-1:0] w_pointer_1;
    wire w_sorter_mixed_flag;
    wire [2:0] w_sorter_data_pattern;
    wire [DATAADDRWIDTH-1:0] w_count_0;
    wire [DATAADDRWIDTH-1:0] w_count_1;

    // Declare local parameters
    parameter [2:0] IDLE = 3'd0,
                    FIRST_DIGIT = 3'd1,
                    EVEN_DIGIT = 3'd2,
                    ODD_DIGIT = 3'd3,
                    DATA_REARRANGE = 3'd4,
                    DONE = 3'd5;

    // Assign logic to port and wires
    assign w_count_0 = w_mixed_pointer;
    assign w_count_1 = DATABRAMDEPTH - w_mixed_pointer - 1;
    assign O_SORTING_DONE = (r_sort_state == DONE);
    // Debug signal
    assign D_SORT_STATE  = r_sort_state;
    assign D_FIRST_STATE = r_first_state;
    assign D_EVEN_STATE  = r_even_state;
    assign D_ODD_STATE   = r_odd_state;
    assign D_DATA_STATE  = r_data_state;
    assign D_POINTER_0   = {1'b0, w_pointer_0};
    assign D_POINTER_1   = {1'b0, w_pointer_1};

    // Assign pointer signal
    assign w_pointer_0 = (r_sort_state == FIRST_DIGIT) ? r_first_pointer_0 :
                         (r_sort_state == EVEN_DIGIT) ? r_even_pointer_0 :
                         (r_sort_state == ODD_DIGIT) ? r_odd_pointer_0 :
                         (r_sort_state == DATA_REARRANGE) ? r_data_pointer_0 : 11'd0; 

    assign w_pointer_1 = (r_sort_state == FIRST_DIGIT) ? r_first_pointer_1 :
                         (r_sort_state == EVEN_DIGIT) ? r_even_pointer_1 :
                         (r_sort_state == ODD_DIGIT) ? r_odd_pointer_1 :
                         (r_sort_state == DATA_REARRANGE) ? r_data_pointer_1 : 11'd0;

    // Set data pattern and flag signal
    assign w_sorter_mixed_flag = ((r_sort_state == EVEN_DIGIT) && (r_sort_state_prev == FIRST_DIGIT)) ? r_first_mixed_flag :
                                 ((r_sort_state == EVEN_DIGIT) && (r_sort_state_prev == ODD_DIGIT)) ? r_odd_mixed_flag :
                                 (r_sort_state == ODD_DIGIT) ? r_even_mixed_flag :
                                 (r_sort_state == DATA_REARRANGE) ? r_even_mixed_flag : 1'b0;

    assign w_sorter_data_pattern = ((r_sort_state == EVEN_DIGIT) && (r_sort_state_prev == FIRST_DIGIT)) ? r_first_data_pattern :
                                 ((r_sort_state == EVEN_DIGIT) && (r_sort_state_prev == ODD_DIGIT)) ? r_odd_data_pattern :
                                 (r_sort_state == ODD_DIGIT) ? r_even_data_pattern :
                                 (r_sort_state == DATA_REARRANGE) ? r_even_data_pattern : 3'd0;
    
    assign w_mixed_pointer = ((r_sort_state == EVEN_DIGIT) && (r_sort_state_prev == FIRST_DIGIT)) ? r_first_mixed_pointer :
                             ((r_sort_state == EVEN_DIGIT) && (r_sort_state_prev == ODD_DIGIT)) ? r_odd_mixed_pointer :
                             (r_sort_state == ODD_DIGIT) ? r_even_mixed_pointer :
                             (r_sort_state == DATA_REARRANGE) ? r_even_mixed_pointer : 11'd0;
    
    // State logic
    always @(posedge I_ACLK) 
    begin
        if (!I_ARESETN)
        begin
            r_sort_state <= IDLE;
            r_sort_state_prev <= IDLE;
        end 
        else
        begin
            case (r_sort_state)
                IDLE:
                begin
                    if (w_start_pulse)
                    begin
                        r_sort_state <= FIRST_DIGIT;
                        r_sort_state_prev <= IDLE;
                    end
                    else
                    begin
                        r_sort_state <= IDLE;
                        r_sort_state_prev <= IDLE;
                    end
                end
                FIRST_DIGIT:
                begin
                    if (w_first_done)
                    begin
                        r_sort_state <= EVEN_DIGIT;
                        r_sort_state_prev <= FIRST_DIGIT;
                    end
                    else
                    begin
                        r_sort_state <= FIRST_DIGIT;
                        r_sort_state_prev <= IDLE;
                    end
                end
                EVEN_DIGIT:
                begin
                    if (w_even_done)
                    begin
                        if (r_digit == 31)
                        begin
                            r_sort_state <= DATA_REARRANGE;
                            r_sort_state_prev <= EVEN_DIGIT;
                        end
                        else
                        begin
                            r_sort_state <= ODD_DIGIT;
                            r_sort_state_prev <= EVEN_DIGIT;
                        end
                    end
                    else
                    begin
                        if (r_digit == 1)
                        begin
                            r_sort_state <= EVEN_DIGIT;
                            r_sort_state_prev <= FIRST_DIGIT;
                        end
                        else
                        begin
                            r_sort_state <= EVEN_DIGIT;
                            r_sort_state_prev <= ODD_DIGIT;
                        end
                    end
                end
                ODD_DIGIT:
                begin
                    if (w_odd_done)
                    begin
                        r_sort_state <= EVEN_DIGIT;
                        r_sort_state_prev <= ODD_DIGIT;
                    end
                    else
                    begin
                        r_sort_state <= ODD_DIGIT;
                        r_sort_state_prev <= EVEN_DIGIT;
                    end
                end
                DATA_REARRANGE:
                begin
                    if (w_data_done)
                    begin
                        r_sort_state <= DONE;
                        r_sort_state_prev <= DATA_REARRANGE;
                    end
                    else
                    begin
                        r_sort_state <= DATA_REARRANGE;
                        r_sort_state_prev <= EVEN_DIGIT;
                    end
                end
                DONE:
                begin
                    r_sort_state <= IDLE;
                    r_sort_state_prev <= DATA_REARRANGE;
                end
                default:
                begin
                    r_sort_state <= IDLE;
                    r_sort_state_prev <= IDLE;
                end
            endcase
        end   
    end

    // Assign logic related to state
    always @(posedge I_ACLK) 
    begin
        if (!I_ARESETN)
        begin
            r_digit <= 0;
            r_data_mask <= 32'd1;
            r_first_start <= 0;
            r_even_start <= 0;
            r_odd_start <= 0;
            r_data_start <= 0;
        end
        else
        begin
            case (r_sort_state)
                IDLE:
                begin
                    r_digit <= 0;
                    r_data_mask <= 32'd1;
                    r_first_start <= 0;
                    r_even_start <= 0;
                    r_odd_start <= 0;
                    r_data_start <= 0;
                end
                FIRST_DIGIT:
                begin
                    if (w_first_done)
                    begin
                        r_digit <= r_digit + 1;
                        r_data_mask <= r_data_mask << 1;
                        r_first_start <= 0;
                        r_even_start <= 0;
                        r_odd_start <= 0;
                        r_data_start <= 0;
                    end
                    else
                    begin
                        r_digit <= r_digit;
                        r_data_mask <= r_data_mask;
                        r_first_start <= 1;
                        r_even_start <= 0;
                        r_odd_start <= 0;
                        r_data_start <= 0;
                    end
                end
                EVEN_DIGIT:
                begin
                    if (w_even_done)
                    begin
                        r_digit <= r_digit + 1;
                        r_data_mask <= r_data_mask << 1;
                        r_first_start <= 0;
                        r_even_start <= 0;
                        r_odd_start <= 0;
                        r_data_start <= 0;
                    end
                    else
                    begin
                        r_digit <= r_digit;
                        r_data_mask <= r_data_mask;
                        r_first_start <= 0;
                        r_even_start <= 1;
                        r_odd_start <= 0;
                        r_data_start <= 0;
                    end
                end
                ODD_DIGIT:
                begin
                    if (w_odd_done)
                    begin
                        r_digit <= r_digit + 1;
                        r_data_mask <= r_data_mask << 1;
                        r_first_start <= 0;
                        r_even_start <= 0;
                        r_odd_start <= 0;
                        r_data_start <= 0;
                    end
                    else
                    begin
                        r_digit <= r_digit;
                        r_data_mask <= r_data_mask;
                        r_first_start <= 0;
                        r_even_start <= 0;
                        r_odd_start <= 1;
                        r_data_start <= 0;
                    end
                end
                DATA_REARRANGE:
                begin
                    if (w_data_done)
                    begin
                        r_digit <= r_digit;
                        r_data_mask <= r_data_mask;
                        r_first_start <= 0;
                        r_even_start <= 0;
                        r_odd_start <= 0;
                        r_data_start <= 0;
                    end
                    else
                    begin
                        r_digit <= r_digit;
                        r_data_mask <= r_data_mask;
                        r_first_start <= 0;
                        r_even_start <= 0;
                        r_odd_start <= 0;
                        r_data_start <= 1;
                    end
                end
                DONE:
                begin
                    r_digit <= r_digit;
                    r_data_mask <= r_data_mask;
                    r_first_start <= 0;
                    r_even_start <= 0;
                    r_odd_start <= 0;
                    r_data_start <= 0;
                end
                default:
                begin
                    r_digit <= r_digit;
                    r_data_mask <= r_data_mask;
                    r_first_start <= 0;
                    r_even_start <= 0;
                    r_odd_start <= 0;
                    r_data_start <= 0;
                end
            endcase
        end
    end

    //////////////////////////////////////////////////
    //             First Digit Sort                 //
    //////////////////////////////////////////////////
    // Declare registers
    reg [2:0] r_first_state;
    reg r_first_mixed_flag;
    reg [DATAADDRWIDTH-1:0] r_first_mixed_pointer;
    reg [2:0] r_first_data_pattern;

    // Declare local parameters
    localparam [2:0] FIRST_IDLE = 3'd0,
                     FIRST_START_SORTER = 3'd1,
                     FIRST_FIRST_READ = 3'd2,
                     FIRST_SECOND_READ = 3'd3,
                     FIRST_WAIT_DATA = 3'd4,
                     FIRST_MIDDLE_RW = 3'd5,
                     FIRST_LAST_WRITE = 3'd6,
                     FIRST_DONE = 3'd7;

    // Assign value to wire
    assign w_first_done = (r_first_state == FIRST_DONE);

    // State transition logic
    always @(posedge I_ACLK) 
    begin
        if (!I_ARESETN)
        begin
            r_first_state <= FIRST_IDLE;
        end    
        else
        begin
            case (r_first_state)
                FIRST_IDLE:
                begin
                    if (w_first_start_pulse)
                    begin
                        r_first_state <= FIRST_START_SORTER;
                    end
                    else
                    begin
                        r_first_state <= FIRST_IDLE;
                    end
                end
                FIRST_START_SORTER:
                begin
                    r_first_state <= FIRST_FIRST_READ;
                end
                FIRST_FIRST_READ:
                begin
                    if (r_first_addr_even == 1)
                    begin
                        r_first_state <= FIRST_SECOND_READ;
                    end
                    else
                    begin
                        r_first_state <= FIRST_FIRST_READ;
                    end
                end
                FIRST_SECOND_READ:
                begin
                    r_first_state <= FIRST_WAIT_DATA;
                end
                FIRST_WAIT_DATA:
                begin
                    r_first_state <= FIRST_MIDDLE_RW;
                end
                FIRST_MIDDLE_RW:
                begin
                    if ((r_first_pointer_1 - r_first_pointer_0) == 1)
                    begin
                        r_first_state <= FIRST_LAST_WRITE;
                    end
                end
                FIRST_LAST_WRITE:
                begin
                    r_first_state <= FIRST_DONE;
                end  
                FIRST_DONE:
                begin
                    r_first_state <= FIRST_IDLE;
                end
                default:
                begin
                    r_first_state <= FIRST_IDLE;
                end
            endcase
        end
    end

    // Mixed flag sampling logic
    always @(posedge I_ACLK) 
    begin
        if (!I_ARESETN)
        begin
            r_first_mixed_flag <= 0;
            r_first_data_pattern <= 0;
        end 
        else
        begin
            if (r_first_state == FIRST_MIDDLE_RW)
            begin
                if ((r_first_pointer_1 - r_first_pointer_0) == 1)
                begin
                    r_first_mixed_flag <= w_row_idx;
                    r_first_data_pattern <= w_data_pattern;
                end
                else
                begin
                    r_first_mixed_flag <= r_first_mixed_flag;
                    r_first_data_pattern <= r_first_data_pattern;
                end
            end
            else
            begin
                r_first_mixed_flag <= r_first_mixed_flag;
                r_first_data_pattern <= r_first_data_pattern;
            end
        end   
    end

    /////////////////////////////////////////////
    //      First Digit Pointer, R/W logic     //
    /////////////////////////////////////////////
    // Declare registers
    reg r_first_shifter_start;
    reg r_first_even_we;
    reg r_first_odd_we;
    reg [DATAADDRWIDTH-1:0] r_first_addr_even;
    reg [DATAADDRWIDTH-1:0] r_first_addr_odd;
    reg [DATAADDRWIDTH-1:0] r_first_pointer_0;
    reg [DATAADDRWIDTH-1:0] r_first_pointer_1;

    // Main logic
    always @(posedge I_ACLK) 
    begin
        if (!I_ARESETN)
        begin
            r_first_pointer_0 <= 0;
            r_first_pointer_1 <= DATABRAMDEPTH - 1;
            r_first_addr_even <= 0;
            r_first_addr_odd <= 0;
            r_first_even_we <= 0;
            r_first_odd_we <= 0;
            r_first_shifter_start <= 0;
            r_first_mixed_pointer <= 0;
        end 
        else
        begin
            case (r_first_state)
                FIRST_IDLE:
                begin
                    // Nothing to do
                end
                FIRST_START_SORTER:
                begin
                    // Assert start sorter signal
                    r_first_shifter_start <= 1;
                    // Set zero and one pointer
                    r_first_pointer_0 <= r_first_pointer_0;
                    r_first_pointer_1 <= r_first_pointer_1;
                    r_first_mixed_pointer <= r_first_mixed_pointer;
                    // Set read and write pointer
                    r_first_addr_even <= r_first_addr_even;
                    r_first_addr_odd <= r_first_addr_odd;
                    // Set write enable signal
                    r_first_even_we <= 0;
                    r_first_odd_we <= 0;
                end
                FIRST_FIRST_READ:
                begin
                    // Assert start sorter signal
                    r_first_shifter_start <= 0;
                    // Set zero and one pointer
                    r_first_pointer_0 <= r_first_pointer_0;
                    r_first_pointer_1 <= r_first_pointer_1;
                    r_first_mixed_pointer <= r_first_mixed_pointer;
                    // Set read and write pointer
                    r_first_addr_even <= r_first_addr_even + 1; 
                    r_first_addr_odd <= r_first_addr_odd;
                    // Set write enable signal
                    r_first_even_we <= 0;
                    r_first_odd_we <= 0;
                end
                FIRST_SECOND_READ:
                begin
                    // Assert start sorter signal
                    r_first_shifter_start <= 0;
                    // Set zero and one pointer
                    r_first_pointer_0 <= r_first_pointer_0;
                    r_first_pointer_1 <= r_first_pointer_1;
                    r_first_mixed_pointer <= r_first_mixed_pointer;
                    // Set read and write pointer
                    r_first_addr_even <= r_first_addr_even + 1; 
                    r_first_addr_odd <= r_first_addr_odd;
                    // Set write enable signal
                    r_first_even_we <= 0;
                    r_first_odd_we <= 0;
                end
                FIRST_WAIT_DATA:
                begin
                    // Assert start sorter signal
                    r_first_shifter_start <= 0;
                    // Set zero and one pointer
                    r_first_pointer_0 <= r_first_pointer_0;
                    r_first_pointer_1 <= r_first_pointer_1;
                    r_first_mixed_pointer <= r_first_mixed_pointer;
                    // Set read and write pointer
                    r_first_addr_even <= r_first_addr_even + 1; 
                    r_first_addr_odd <= r_first_addr_odd;
                    // Set write enable signal
                    r_first_even_we <= 0;
                    r_first_odd_we <= 0;
                end
                FIRST_MIDDLE_RW:
                begin
                    // Assert start sorter signal
                    r_first_shifter_start <= 0;
                    // Set write enable signal
                    r_first_even_we <= 0;
                    r_first_odd_we <= 1;
                    // Set write pointer signal
                    if(w_row_idx == 0) 
                    begin
                        r_first_addr_odd <= r_first_pointer_0;
                        r_first_pointer_0 <= r_first_pointer_0 + 1; 
                    end
                    else
                    begin
                        r_first_addr_odd <= r_first_pointer_1;
                        r_first_pointer_1 <= r_first_pointer_1 - 1;
                    end
                    // Set read pointer signal
                    if (r_first_addr_even == DATABRAMDEPTH-1)
                    begin
                        r_first_addr_even <= r_first_addr_even;
                    end
                    else
                    begin
                        r_first_addr_even <= r_first_addr_even + 1;
                    end
                    // Set mixed pointer
                    r_first_mixed_pointer <= r_first_mixed_pointer;
                end
                FIRST_LAST_WRITE:
                begin
                    // Assert start sorter signal
                    r_first_shifter_start <= 0;
                    // Set zero and one pointer
                    r_first_pointer_0 <= r_first_pointer_0;
                    r_first_pointer_1 <= r_first_pointer_1;
                    r_first_mixed_pointer <= r_first_mixed_pointer;
                    // Set read and write pointer
                    r_first_addr_even <= r_first_addr_even; 
                    r_first_addr_odd <= r_first_pointer_0;
                    // Set write enable signal
                    r_first_even_we <= 0;
                    r_first_odd_we <= 1;
                end
                FIRST_DONE:
                begin
                    // Assert start sorter signal
                    r_first_shifter_start <= 0;
                    // Set zero and one pointer
                    r_first_pointer_0 <= 0;
                    r_first_pointer_1 <= DATABRAMDEPTH - 1;
                    r_first_mixed_pointer <= r_first_pointer_0;
                    // Set read and write pointer
                    r_first_addr_even <= 0; 
                    r_first_addr_odd <= 0;
                    // Set write enable signal
                    r_first_even_we <= 0;
                    r_first_odd_we <= 0;
                end 
            endcase
        end   
    end

    ////////////////////////////////////////////
    //      FIRST_DIGIT  Data I/O logic       //
    ////////////////////////////////////////////
    // Declare register
    reg [DWIDTH-1:0] r_first_sorted_cache [1:0];
    reg [DWIDTH-1:0] r_first_unsorted_cache [1:0];
    
    // Main logic
    always @(posedge I_ACLK) 
    begin
        if (!I_ARESETN)
        begin
            r_first_unsorted_cache[0] <= 0;
            r_first_unsorted_cache[1] <= 0;
            r_first_sorted_cache[0] <= 0;
            r_first_sorted_cache[1] <= 0;
        end 
        else
        begin
            case (r_first_state)
                FIRST_IDLE:
                begin
                    // Do nothing
                end
                FIRST_START_SORTER:
                begin
                    r_first_unsorted_cache[0] <= r_first_unsorted_cache[0];
                    r_first_unsorted_cache[1] <= r_first_unsorted_cache[1];
                    r_first_sorted_cache[0] <= r_first_sorted_cache[0];
                    r_first_sorted_cache[1] <= r_first_sorted_cache[1];
                end
                FIRST_FIRST_READ:
                begin
                    r_first_unsorted_cache[0] <= r_first_unsorted_cache[0];
                    r_first_unsorted_cache[1] <= r_first_unsorted_cache[1];
                    r_first_sorted_cache[0] <= r_first_sorted_cache[0];
                    r_first_sorted_cache[1] <= r_first_sorted_cache[1];
                end
                FIRST_SECOND_READ:
                begin
                    r_first_unsorted_cache[0] <= w_shifter_cache_data;
                    r_first_unsorted_cache[1] <= r_first_unsorted_cache[1];
                    r_first_sorted_cache[0] <= r_first_sorted_cache[0];
                    r_first_sorted_cache[1] <= r_first_sorted_cache[1];
                end
                FIRST_WAIT_DATA:
                begin
                    r_first_unsorted_cache[0] <= r_first_unsorted_cache[0];
                    r_first_unsorted_cache[1] <= w_shifter_cache_data;
                    r_first_sorted_cache[0] <= r_first_sorted_cache[0];
                    r_first_sorted_cache[1] <= r_first_sorted_cache[1];
                end
                FIRST_MIDDLE_RW:
                begin
                    r_first_unsorted_cache[0] <= w_sorted_array[2*DWIDTH-1:DWIDTH];
                    r_first_unsorted_cache[1] <= w_shifter_cache_data;
                    r_first_sorted_cache[0] <= w_sorted_array[DWIDTH-1:0];
                    r_first_sorted_cache[1] <= w_sorted_array[2*DWIDTH-1:DWIDTH];
                end
                FIRST_LAST_WRITE:
                begin
                    r_first_unsorted_cache[0] <= w_sorted_array[2*DWIDTH-1:DWIDTH];
                    r_first_unsorted_cache[1] <= w_shifter_cache_data;
                    r_first_sorted_cache[0] <= r_first_sorted_cache[0];
                    r_first_sorted_cache[1] <= r_first_sorted_cache[1];
                end
                FIRST_DONE:
                begin
                    r_first_unsorted_cache[0] <= 0;
                    r_first_unsorted_cache[1] <= 0;
                    r_first_sorted_cache[0] <= 0;
                    r_first_sorted_cache[1] <= 0;
                end
                default:
                begin
                    r_first_unsorted_cache[0] <= r_first_unsorted_cache[0];
                    r_first_unsorted_cache[1] <= r_first_unsorted_cache[1];
                    r_first_sorted_cache[0] <= r_first_sorted_cache[0];
                    r_first_sorted_cache[1] <= r_first_sorted_cache[1];
                end
            endcase
        end   
    end

    //////////////////////////////////////////////////
    //                Even Soring State             //
    //////////////////////////////////////////////////
    // Declare registers
    reg [3:0] r_even_state;
    reg r_even_mixed_flag;
    reg [DATAADDRWIDTH-1:0] r_even_mixed_pointer;
    reg [2:0] r_even_data_pattern;

    // Declare local parameters
    parameter [3:0] EVEN_IDLE = 4'd0,
                    EVEN_START_SORTER = 4'd1,
                    EVEN_FIRST_READ = 4'd2,
                    EVEN_SECOND_READ = 4'd3,
                    EVEN_WAIT_DATA = 4'd4,
                    EVEN_ZERO_MIDDLE_RW = 4'd5,
                    EVEN_WAIT_SHIFT_DATA = 4'd6,
                    EVEN_ONE_MIDDLE_RW = 4'd7,
                    EVEN_LAST_WRITE = 4'd8,
                    EVEN_DONE = 4'd9;

    // Assign value to wire
    assign w_even_done = (r_even_state == EVEN_DONE);

    // State logic
    always @(posedge I_ACLK) 
    begin
        if (!I_ARESETN)
        begin
            r_even_state <= EVEN_IDLE;
        end 
        else
        begin
            case (r_even_state)
                EVEN_IDLE:
                begin
                    if (w_even_start_pulse)
                    begin
                        r_even_state <= EVEN_START_SORTER;
                    end
                    else
                    begin
                        r_even_state <= r_even_state;
                    end
                end
                EVEN_START_SORTER:
                begin
                    r_even_state <= EVEN_FIRST_READ;
                end
                EVEN_FIRST_READ:
                begin
                    if (r_even_addr_odd == 1)
                    begin
                        r_even_state <= EVEN_SECOND_READ;
                    end
                    else
                    begin
                        r_even_state <= r_even_state;
                    end
                end
                EVEN_SECOND_READ:
                begin
                    r_even_state <= EVEN_WAIT_DATA;
                end
                EVEN_WAIT_DATA:
                begin
                    r_even_state <= EVEN_ZERO_MIDDLE_RW;
                end
                EVEN_ZERO_MIDDLE_RW:
                begin
                    if (r_even_addr_odd == (w_mixed_pointer - 1))
                    begin
                        r_even_state <= EVEN_WAIT_SHIFT_DATA;
                    end
                end
                EVEN_WAIT_SHIFT_DATA:
                begin
                    r_even_state <= EVEN_ONE_MIDDLE_RW;
                end
                EVEN_ONE_MIDDLE_RW:
                begin
                    if ((r_even_pointer_1 - r_even_pointer_0) == 1)
                    begin
                        r_even_state <= EVEN_LAST_WRITE;
                    end
                    else
                    begin
                        r_even_state <= r_even_state;
                    end
                end
                EVEN_LAST_WRITE:
                begin
                    r_even_state <= EVEN_DONE;
                end
                EVEN_DONE:
                begin
                    r_even_state <= EVEN_IDLE;
                end
                default:
                begin
                    r_even_state <= EVEN_IDLE;
                end
            endcase
        end   
    end

    // Mixed flag sampling logic
    always @(posedge I_ACLK) 
    begin
        if (!I_ARESETN)
        begin
            r_even_mixed_flag <= 0;
            r_even_data_pattern <= 0;
        end 
        else
        begin
            if (r_even_state == EVEN_ONE_MIDDLE_RW)
            begin
                if ((r_even_pointer_1 - r_even_pointer_0) == 1)
                begin
                    r_even_mixed_flag <= w_row_idx;
                    r_even_data_pattern <= w_data_pattern;
                end
                else
                begin
                    r_even_mixed_flag <= r_even_mixed_flag;
                    r_even_data_pattern <= r_even_data_pattern;
                end
            end
            else
            begin
                r_even_mixed_flag <= r_even_mixed_flag;
                r_even_data_pattern <= r_even_data_pattern;
            end
        end   
    end

    ////////////////////////////////////////////
    //      Even Digit Pointer, R/W logic     //
    ////////////////////////////////////////////
    // Declare registers
    reg r_even_shifter_start;
    reg r_even_even_we;
    reg r_even_odd_we;
    reg [DATAADDRWIDTH-1:0] r_even_addr_even;
    reg [DATAADDRWIDTH-1:0] r_even_addr_odd;
    reg [DATAADDRWIDTH-1:0] r_even_pointer_0;
    reg [DATAADDRWIDTH-1:0] r_even_pointer_1;

    // Main logic
    always @(posedge I_ACLK) 
    begin
        if (!I_ARESETN)
        begin
            r_even_pointer_0 <= 0;
            r_even_pointer_1 <= DATABRAMDEPTH - 1;
            r_even_addr_even <= 0;
            r_even_addr_odd <= 0;
            r_even_even_we <= 0;
            r_even_odd_we <= 0;
            r_even_shifter_start <= 0;
            r_even_mixed_pointer <= 0;
        end 
        else
        begin
            case (r_even_state)
                EVEN_IDLE:
                begin
                    // Nothing to do
                end
                EVEN_START_SORTER:
                begin
                    // Assert start sorter signal
                    r_even_shifter_start <= 1;
                    // Set zero and one pointer
                    r_even_pointer_0 <= r_even_pointer_0;
                    r_even_pointer_1 <= r_even_pointer_1;
                    r_even_mixed_pointer <= r_even_mixed_pointer;
                    // Set read and write pointer
                    r_even_addr_even <= r_even_addr_even;
                    r_even_addr_odd <= r_even_addr_odd;
                    // Set write enable signal
                    r_even_even_we <= 0;
                    r_even_odd_we <= 0;
                end
                EVEN_FIRST_READ:
                begin
                    // Assert start sorter signal
                    r_even_shifter_start <= 0;
                    // Set zero and one pointer
                    r_even_pointer_0 <= r_even_pointer_0;
                    r_even_pointer_1 <= r_even_pointer_1;
                    r_even_mixed_pointer <= r_even_mixed_pointer;
                    // Set read and write pointer
                    r_even_addr_even <= r_even_addr_even; 
                    r_even_addr_odd <= r_even_addr_odd + 1;
                    // Set write enable signal
                    r_even_even_we <= 0;
                    r_even_odd_we <= 0;
                end
                EVEN_SECOND_READ:
                begin
                   // Assert start sorter signal
                    r_even_shifter_start <= 0;
                    // Set zero and one pointer
                    r_even_pointer_0 <= r_even_pointer_0;
                    r_even_pointer_1 <= r_even_pointer_1;
                    r_even_mixed_pointer <= r_even_mixed_pointer;
                    // Set read and write pointer
                    r_even_addr_even <= r_even_addr_even; 
                    r_even_addr_odd <= r_even_addr_odd + 1;
                    // Set write enable signal
                    r_even_even_we <= 0;
                    r_even_odd_we <= 0; 
                end
                EVEN_WAIT_DATA:
                begin
                    // Assert start sorter signal
                    r_even_shifter_start <= 0;
                    // Set zero and one pointer
                    r_even_pointer_0 <= r_even_pointer_0;
                    r_even_pointer_1 <= r_even_pointer_1;
                    r_even_mixed_pointer <= r_even_mixed_pointer;
                    // Set read and write pointer
                    r_even_addr_even <= r_even_addr_even; 
                    r_even_addr_odd <= r_even_addr_odd + 1;
                    // Set write enable signal
                    r_even_even_we <= 0;
                    r_even_odd_we <= 0; 
                end
                EVEN_ZERO_MIDDLE_RW:
                begin
                    // Assert start sorter signal
                    r_even_shifter_start <= 0;
                    // Set write enable signal
                    r_even_even_we <= 1;
                    r_even_odd_we <= 0;
                    // Set write pointer signal
                    if(w_row_idx == 0) 
                    begin
                        r_even_addr_even <= r_even_pointer_0;
                        r_even_pointer_0 <= r_even_pointer_0 + 1; 
                    end
                    else
                    begin
                        r_even_addr_even <= r_even_pointer_1;
                        r_even_pointer_1 <= r_even_pointer_1 - 1;
                    end
                    // Set read pointer signal
                    if (r_even_addr_odd == DATABRAMDEPTH-1)
                    begin
                        r_even_addr_odd <= r_even_addr_odd;
                    end
                    else
                    begin
                        r_even_addr_odd <= r_even_addr_odd + 1;
                    end
                end
                EVEN_WAIT_SHIFT_DATA:
                begin
                    // Assert start sorter signal
                    r_even_shifter_start <= 0;
                    // Set write enable signal
                    r_even_even_we <= 1;
                    r_even_odd_we <= 0;
                    // Set write pointer signal
                    if(w_row_idx == 0) 
                    begin
                        r_even_addr_even <= r_even_pointer_0;
                        r_even_pointer_0 <= r_even_pointer_0 + 1; 
                    end
                    else
                    begin
                        r_even_addr_even <= r_even_pointer_1;
                        r_even_pointer_1 <= r_even_pointer_1 - 1;
                    end
                    // Set read pointer signal
                    r_even_addr_odd <= DATABRAMDEPTH-1;
                end
                EVEN_ONE_MIDDLE_RW:
                begin
                    if ((w_shifter_valid) || (!w_shifter_valid && (r_even_pointer_1 - r_even_pointer_0 == 1)))
                    begin
                        // Set write enable signal
                        r_even_even_we <= 1;
                        r_even_odd_we <= 0;
                        // Set write pointer signal
                        if(w_row_idx == 0) 
                        begin
                            r_even_addr_even <= r_even_pointer_0;
                            r_even_pointer_0 <= r_even_pointer_0 + 1; 
                        end
                        else
                        begin
                            r_even_addr_even <= r_even_pointer_1;
                            r_even_pointer_1 <= r_even_pointer_1 - 1;
                        end
                        // Set read pointer signal
                        if (r_even_addr_odd == (w_mixed_pointer + 1))
                        begin
                            r_even_addr_odd <= r_even_addr_odd;
                        end
                        else
                        begin
                            r_even_addr_odd <= r_even_addr_odd - 1;
                        end
                    end
                    else
                    begin
                        // Set write enable signal
                        r_even_even_we <= 0;
                        r_even_odd_we <= 0;
                        // Write pointer
                        r_even_addr_even <= r_even_addr_even;
                        // Read pointer
                        if (r_even_addr_odd == (w_mixed_pointer + 1))
                        begin
                            r_even_addr_odd <= r_even_addr_odd;
                        end
                        else
                        begin
                            r_even_addr_odd <= r_even_addr_odd - 1;
                        end
                        // Cache pointer
                        r_even_pointer_0 <= r_even_pointer_0;
                        r_even_pointer_1 <= r_even_pointer_1;
                    end
                end
                EVEN_LAST_WRITE:
                begin
                    // Assert start sorter signal
                    r_even_shifter_start <= 0;
                    // Set zero and one pointer
                    r_even_pointer_0 <= r_even_pointer_0;
                    r_even_pointer_1 <= r_even_pointer_1;
                    r_even_mixed_pointer <= r_even_mixed_pointer;
                    // Set read and write pointer
                    r_even_addr_even <= r_even_pointer_0; 
                    r_even_addr_odd <= r_even_addr_odd;
                    // Set write enable signal
                    r_even_even_we <= 1;
                    r_even_odd_we <= 0;
                end
                EVEN_DONE:
                begin
                    // Assert start sorter signal
                    r_even_shifter_start <= 0;
                    // Set zero and one pointer
                    r_even_pointer_0 <= 0;
                    r_even_pointer_1 <= DATABRAMDEPTH - 1;
                    r_even_mixed_pointer <= r_even_pointer_0;
                    // Set read and write pointer
                    r_even_addr_even <= 0; 
                    r_even_addr_odd <= 0;
                    // Set write enable signal
                    r_even_even_we <= 0;
                    r_even_odd_we <= 0;
                end
                default:
                begin
                    // Assert start sorter signal
                    r_even_shifter_start <= 0;
                    // Set zero and one pointer
                    r_even_pointer_0 <= r_even_pointer_0;
                    r_even_pointer_1 <= r_even_pointer_1;
                    r_even_mixed_pointer <= r_even_mixed_pointer;
                    // Set read and write pointer
                    r_even_addr_even <= 0; 
                    r_even_addr_odd <= 0;
                    // Set write enable signal
                    r_even_even_we <= 0;
                    r_even_odd_we <= 0;
                end
            endcase
        end   
    end

    ///////////////////////////////////////////
    //      Even Digit Data I/O logic        //
    ///////////////////////////////////////////
    // Declare registers
    reg [DWIDTH-1:0] r_even_sorted_cache [1:0];
    reg [DWIDTH-1:0] r_even_unsorted_cache [1:0];

    // Main logic
    always @(posedge I_ACLK) 
    begin
        if (!I_ARESETN)
        begin
            r_even_unsorted_cache[0] <= 0;
            r_even_unsorted_cache[1] <= 0;
            r_even_sorted_cache[0] <= 0;
            r_even_sorted_cache[1] <= 0; 
        end 
        else
        begin
            case (r_even_state)
                EVEN_IDLE:
                begin
                    // Nothing to do
                end
                EVEN_START_SORTER:
                begin
                    r_even_unsorted_cache[0] <= r_even_unsorted_cache[0];
                    r_even_unsorted_cache[1] <= r_even_unsorted_cache[1];
                    r_even_sorted_cache[0] <= r_even_sorted_cache[0];
                    r_even_sorted_cache[1] <= r_even_sorted_cache[1];
                end
                EVEN_FIRST_READ:
                begin
                    r_even_unsorted_cache[0] <= r_even_unsorted_cache[0];
                    r_even_unsorted_cache[1] <= r_even_unsorted_cache[1];
                    r_even_sorted_cache[0] <= r_even_sorted_cache[0];
                    r_even_sorted_cache[1] <= r_even_sorted_cache[1];
                end
                EVEN_SECOND_READ:
                begin
                    r_even_unsorted_cache[0] <= w_shifter_cache_data;
                    r_even_unsorted_cache[1] <= r_even_unsorted_cache[1];
                    r_even_sorted_cache[0] <= r_even_sorted_cache[0];
                    r_even_sorted_cache[1] <= r_even_sorted_cache[1];
                end
                EVEN_WAIT_DATA:
                begin
                    r_even_unsorted_cache[0] <= r_even_unsorted_cache[0];
                    r_even_unsorted_cache[1] <= w_shifter_cache_data;
                    r_even_sorted_cache[0] <= r_even_sorted_cache[0];
                    r_even_sorted_cache[1] <= r_even_sorted_cache[1];
                end
                EVEN_ZERO_MIDDLE_RW:
                begin
                    r_even_unsorted_cache[0] <= w_sorted_array[(2*DWIDTH)-1:DWIDTH];
                    r_even_unsorted_cache[1] <= w_shifter_cache_data;
                    r_even_sorted_cache[0] <= w_sorted_array[DWIDTH-1:0];
                    r_even_sorted_cache[1] <= w_sorted_array[(2*DWIDTH)-1:DWIDTH];
                end
                EVEN_WAIT_SHIFT_DATA:
                begin
                    r_even_unsorted_cache[0] <= w_sorted_array[(2*DWIDTH)-1:DWIDTH];
                    r_even_unsorted_cache[1] <= w_shifter_cache_data;
                    r_even_sorted_cache[0] <= w_sorted_array[DWIDTH-1:0];
                    r_even_sorted_cache[1] <= w_sorted_array[(2*DWIDTH)-1:DWIDTH];
                end
                EVEN_ONE_MIDDLE_RW:
                begin
                    if ((w_shifter_valid) || (!w_shifter_valid && (r_even_pointer_1 - r_even_pointer_0 == 1)))
                    begin
                        r_even_unsorted_cache[0] <= w_sorted_array[(2*DWIDTH)-1:DWIDTH];
                        r_even_unsorted_cache[1] <= w_shifter_cache_data;
                        r_even_sorted_cache[0] <= w_sorted_array[DWIDTH-1:0];
                        r_even_sorted_cache[1] <= w_sorted_array[(2*DWIDTH)-1:DWIDTH];
                    end
                    else
                    begin
                        r_even_unsorted_cache[0] <= r_even_unsorted_cache[0];
                        r_even_unsorted_cache[1] <= r_even_unsorted_cache[1];
                        r_even_sorted_cache[0] <= r_even_sorted_cache[0];
                        r_even_sorted_cache[1] <= r_even_sorted_cache[1];
                    end
                end
                EVEN_LAST_WRITE:
                begin
                    r_even_unsorted_cache[0] <= w_sorted_array[(2*DWIDTH)-1:DWIDTH];
                    r_even_unsorted_cache[1] <= w_shifter_cache_data;
                    r_even_sorted_cache[0] <= r_even_sorted_cache[0];
                    r_even_sorted_cache[1] <= r_even_sorted_cache[1];
                end
                EVEN_DONE:
                begin
                    r_even_unsorted_cache[0] <= 0;
                    r_even_unsorted_cache[1] <= 0;
                    r_even_sorted_cache[0] <= 0;
                    r_even_sorted_cache[1] <= 0;
                end
                default:
                begin
                    r_even_unsorted_cache[0] <= r_even_unsorted_cache[0];
                    r_even_unsorted_cache[1] <= r_even_unsorted_cache[1];
                    r_even_sorted_cache[0] <= r_even_sorted_cache[0];
                    r_even_sorted_cache[1] <= r_even_sorted_cache[1];
                end
            endcase
        end   
    end

    //////////////////////////////////////////////////
    //                Odd Soring State             //
    //////////////////////////////////////////////////
    // Declare registers
    reg [3:0] r_odd_state;
    reg r_odd_mixed_flag;
    reg [DATAADDRWIDTH-1:0] r_odd_mixed_pointer;
    reg [2:0] r_odd_data_pattern;
    

    // Declare local parameters
    parameter [3:0] ODD_IDLE = 4'd0,
                    ODD_START_SORTER = 4'd1,
                    ODD_FIRST_READ = 4'd2,
                    ODD_SECOND_READ = 4'd3,
                    ODD_WAIT_DATA = 4'd4,
                    ODD_ZERO_MIDDLE_RW = 4'd5,
                    ODD_WAIT_SHIFT_DATA = 4'd6,
                    ODD_ONE_MIDDLE_RW = 4'd7,
                    ODD_LAST_WRITE = 4'd8,
                    ODD_DONE = 4'd9;

    // Assign value to wire
    assign w_odd_done = (r_odd_state == ODD_DONE);

    // State logic
    always @(posedge I_ACLK) 
    begin
        if (!I_ARESETN)
        begin
            r_odd_state <= ODD_IDLE;
        end 
        else
        begin
            case (r_odd_state)
                ODD_IDLE:
                begin
                    if (w_odd_start_pulse)
                    begin
                        r_odd_state <= ODD_START_SORTER;
                    end
                    else
                    begin
                        r_odd_state <= r_odd_state;
                    end
                end
                ODD_START_SORTER:
                begin
                    r_odd_state <= ODD_FIRST_READ;
                end
                ODD_FIRST_READ:
                begin
                    if (r_odd_addr_even == 1)
                    begin
                        r_odd_state <= ODD_SECOND_READ;
                    end
                    else
                    begin
                        r_odd_state <= r_odd_state;
                    end
                end
                ODD_SECOND_READ:
                begin
                    r_odd_state <= ODD_WAIT_DATA;
                end
                ODD_WAIT_DATA:
                begin
                    r_odd_state <= ODD_ZERO_MIDDLE_RW;
                end
                ODD_ZERO_MIDDLE_RW:
                begin
                    if (r_odd_addr_even == (w_mixed_pointer - 1))
                    begin
                        r_odd_state <= ODD_WAIT_SHIFT_DATA;
                    end
                end
                ODD_WAIT_SHIFT_DATA:
                begin
                    r_odd_state <= ODD_ONE_MIDDLE_RW;
                end
                ODD_ONE_MIDDLE_RW:
                begin
                    if ((r_odd_pointer_1 - r_odd_pointer_0) == 1)
                    begin
                        r_odd_state <= ODD_LAST_WRITE;
                    end
                    else
                    begin
                        r_odd_state <= r_odd_state;
                    end
                end
                ODD_LAST_WRITE:
                begin
                    r_odd_state <= ODD_DONE;
                end
                ODD_DONE:
                begin
                    r_odd_state <= ODD_IDLE;
                end
                default:
                begin
                    r_odd_state <= ODD_IDLE;
                end
            endcase
        end   
    end

    // Mixed flag sampling logic
    always @(posedge I_ACLK) 
    begin
        if (!I_ARESETN)
        begin
            r_odd_mixed_flag <= 0;
            r_odd_data_pattern <= 0;
        end 
        else
        begin
            if (r_odd_state == ODD_ONE_MIDDLE_RW)
            begin
                if ((r_odd_pointer_1 - r_odd_pointer_0) == 1)
                begin
                    r_odd_mixed_flag <= w_row_idx;
                    r_odd_data_pattern <= w_data_pattern;
                end
                else
                begin
                    r_odd_mixed_flag <= r_odd_mixed_flag;
                    r_odd_data_pattern <= r_odd_data_pattern;
                end
            end
            else
            begin
                r_odd_mixed_flag <= r_odd_mixed_flag;
                r_odd_data_pattern <= r_odd_data_pattern;
            end
        end   
    end

    ////////////////////////////////////////////
    //      Odd Digit Pointer, R/W logic     //
    ////////////////////////////////////////////
    // Declare registers
    reg r_odd_shifter_start;
    reg r_odd_even_we;
    reg r_odd_odd_we;
    reg [DATAADDRWIDTH-1:0] r_odd_addr_even;
    reg [DATAADDRWIDTH-1:0] r_odd_addr_odd;
    reg [DATAADDRWIDTH-1:0] r_odd_pointer_0;
    reg [DATAADDRWIDTH-1:0] r_odd_pointer_1;

    // Main logic
    always @(posedge I_ACLK) 
    begin
        if (!I_ARESETN)
        begin
            r_odd_pointer_0 <= 0;
            r_odd_pointer_1 <= DATABRAMDEPTH - 1;
            r_odd_addr_even <= 0;
            r_odd_addr_odd <= 0;
            r_odd_even_we <= 0;
            r_odd_odd_we <= 0;
            r_odd_shifter_start <= 0;
            r_odd_mixed_pointer <= 0;
        end 
        else
        begin
            case (r_odd_state)
                ODD_IDLE:
                begin
                    // Nothing to do
                end
                ODD_START_SORTER:
                begin
                    // Assert start sorter signal
                    r_odd_shifter_start <= 1;
                    // Set zero and one pointer
                    r_odd_pointer_0 <= r_odd_pointer_0;
                    r_odd_pointer_1 <= r_odd_pointer_1;
                    r_odd_mixed_pointer <= r_odd_mixed_pointer;
                    // Set read and write pointer
                    r_odd_addr_odd <= r_odd_addr_odd;
                    r_odd_addr_even <= r_odd_addr_even;
                    // Set write enable signal
                    r_odd_even_we <= 0;
                    r_odd_odd_we <= 0;
                end
                ODD_FIRST_READ:
                begin
                    // Assert start sorter signal
                    r_odd_shifter_start <= 0;
                    // Set zero and one pointer
                    r_odd_pointer_0 <= r_odd_pointer_0;
                    r_odd_pointer_1 <= r_odd_pointer_1;
                    r_odd_mixed_pointer <= r_odd_mixed_pointer;
                    // Set read and write pointer
                    r_odd_addr_odd <= r_odd_addr_odd; 
                    r_odd_addr_even <= r_odd_addr_even + 1;
                    // Set write enable signal
                    r_odd_even_we <= 0;
                    r_odd_odd_we <= 0;
                end
                ODD_SECOND_READ:
                begin
                   // Assert start sorter signal
                    r_odd_shifter_start <= 0;
                    // Set zero and one pointer
                    r_odd_pointer_0 <= r_odd_pointer_0;
                    r_odd_pointer_1 <= r_odd_pointer_1;
                    r_odd_mixed_pointer <= r_odd_mixed_pointer;
                    // Set read and write pointer
                    r_odd_addr_odd <= r_odd_addr_odd; 
                    r_odd_addr_even <= r_odd_addr_even + 1;
                    // Set write enable signal
                    r_odd_even_we <= 0;
                    r_odd_odd_we <= 0; 
                end
                ODD_WAIT_DATA:
                begin
                    // Assert start sorter signal
                    r_odd_shifter_start <= 0;
                    // Set zero and one pointer
                    r_odd_pointer_0 <= r_odd_pointer_0;
                    r_odd_pointer_1 <= r_odd_pointer_1;
                    r_odd_mixed_pointer <= r_odd_mixed_pointer;
                    // Set read and write pointer
                    r_odd_addr_odd <= r_odd_addr_odd; 
                    r_odd_addr_even <= r_odd_addr_even + 1;
                    // Set write enable signal
                    r_odd_even_we <= 0;
                    r_odd_odd_we <= 0; 
                end
                ODD_ZERO_MIDDLE_RW:
                begin
                    // Assert start sorter signal
                    r_odd_shifter_start <= 0;
                    // Set write enable signal
                    r_odd_even_we <= 0;
                    r_odd_odd_we <= 1;
                    // Set write pointer signal
                    if(w_row_idx == 0) 
                    begin
                        r_odd_addr_odd <= r_odd_pointer_0;
                        r_odd_pointer_0 <= r_odd_pointer_0 + 1; 
                    end
                    else
                    begin
                        r_odd_addr_odd <= r_odd_pointer_1;
                        r_odd_pointer_1 <= r_odd_pointer_1 - 1;
                    end
                    // Set read pointer signal
                    if (r_odd_addr_even == DATABRAMDEPTH-1)
                    begin
                        r_odd_addr_even <= r_odd_addr_even;
                    end
                    else
                    begin
                        r_odd_addr_even <= r_odd_addr_even + 1;
                    end
                end
                ODD_WAIT_SHIFT_DATA:
                begin
                    // Assert start sorter signal
                    r_odd_shifter_start <= 0;
                    // Set write enable signal
                    r_odd_even_we <= 0;
                    r_odd_odd_we <= 1;
                    // Set write pointer signal
                    if(w_row_idx == 0) 
                    begin
                        r_odd_addr_odd <= r_odd_pointer_0;
                        r_odd_pointer_0 <= r_odd_pointer_0 + 1; 
                    end
                    else
                    begin
                        r_odd_addr_odd <= r_odd_pointer_1;
                        r_odd_pointer_1 <= r_odd_pointer_1 - 1;
                    end
                    // Set read pointer signal
                    r_odd_addr_even <= DATABRAMDEPTH-1;
                end
                ODD_ONE_MIDDLE_RW:
                begin
                    if ((w_shifter_valid) || (!w_shifter_valid && (r_odd_pointer_1 - r_odd_pointer_0 == 1)))
                    begin
                        // Set write enable signal
                        r_odd_even_we <= 0;
                        r_odd_odd_we <= 1;
                        // Set write pointer signal
                        if(w_row_idx == 0) 
                        begin
                            r_odd_addr_odd <= r_odd_pointer_0;
                            r_odd_pointer_0 <= r_odd_pointer_0 + 1; 
                        end
                        else
                        begin
                            r_odd_addr_odd <= r_odd_pointer_1;
                            r_odd_pointer_1 <= r_odd_pointer_1 - 1;
                        end
                        // Set read pointer signal
                        if (r_odd_addr_even == (w_mixed_pointer + 1))
                        begin
                            r_odd_addr_even <= r_odd_addr_even;
                        end
                        else
                        begin
                            r_odd_addr_even <= r_odd_addr_even - 1;
                        end
                    end
                    else
                    begin
                        // Set write enable signal
                        r_odd_even_we <= 0;
                        r_odd_odd_we <= 0;
                        // Write pointer
                        r_odd_addr_odd <= r_odd_addr_odd;
                        // Read pointer
                        if (r_odd_addr_even == (w_mixed_pointer + 1))
                        begin
                            r_odd_addr_even <= r_odd_addr_even;
                        end
                        else
                        begin
                            r_odd_addr_even <= r_odd_addr_even - 1;
                        end
                        // Cache pointer
                        r_odd_pointer_0 <= r_odd_pointer_0;
                        r_odd_pointer_1 <= r_odd_pointer_1;
                    end
                end
                ODD_LAST_WRITE:
                begin
                    // Assert start sorter signal
                    r_odd_shifter_start <= 0;
                    // Set zero and one pointer
                    r_odd_pointer_0 <= r_odd_pointer_0;
                    r_odd_pointer_1 <= r_odd_pointer_1;
                    r_odd_mixed_pointer <= r_odd_mixed_pointer;
                    // Set read and write pointer
                    r_odd_addr_odd <= r_odd_pointer_0; 
                    r_odd_addr_even <= r_odd_addr_even;
                    // Set write enable signal
                    r_odd_even_we <= 0;
                    r_odd_odd_we <= 1;
                end
                ODD_DONE:
                begin
                    // Assert start sorter signal
                    r_odd_shifter_start <= 0;
                    // Set zero and one pointer
                    r_odd_pointer_0 <= 0;
                    r_odd_pointer_1 <= DATABRAMDEPTH - 1;
                    r_odd_mixed_pointer <= r_odd_pointer_0;
                    // Set read and write pointer
                    r_odd_addr_odd <= 0; 
                    r_odd_addr_even <= 0;
                    // Set write enable signal
                    r_odd_even_we <= 0;
                    r_odd_odd_we <= 0;
                end
                default:
                begin
                    // Assert start sorter signal
                    r_odd_shifter_start <= 0;
                    // Set zero and one pointer
                    r_odd_pointer_0 <= r_odd_pointer_0;
                    r_odd_pointer_1 <= r_odd_pointer_1;
                    r_odd_mixed_pointer <= r_odd_mixed_pointer;
                    // Set read and write pointer
                    r_odd_addr_even <= 0; 
                    r_odd_addr_odd <= 0;
                    // Set write enable signal
                    r_odd_even_we <= 0;
                    r_odd_odd_we <= 0;
                end
            endcase
        end   
    end

    ///////////////////////////////////////////
    //      Odd Digit Data I/O logic        //
    ///////////////////////////////////////////
    // Declare registers
    reg [DWIDTH-1:0] r_odd_sorted_cache [1:0];
    reg [DWIDTH-1:0] r_odd_unsorted_cache [1:0];

    // Main logic
    always @(posedge I_ACLK) 
    begin
        if (!I_ARESETN)
        begin
            r_odd_unsorted_cache[0] <= 0;
            r_odd_unsorted_cache[1] <= 0;
            r_odd_sorted_cache[0] <= 0;
            r_odd_sorted_cache[1] <= 0; 
        end 
        else
        begin
            case (r_odd_state)
                ODD_IDLE:
                begin
                    // Nothing to do
                end
                ODD_START_SORTER:
                begin
                    r_odd_unsorted_cache[0] <= r_odd_unsorted_cache[0];
                    r_odd_unsorted_cache[1] <= r_odd_unsorted_cache[1];
                    r_odd_sorted_cache[0] <= r_odd_sorted_cache[0];
                    r_odd_sorted_cache[1] <= r_odd_sorted_cache[1];
                end
                ODD_FIRST_READ:
                begin
                    r_odd_unsorted_cache[0] <= r_odd_unsorted_cache[0];
                    r_odd_unsorted_cache[1] <= r_odd_unsorted_cache[1];
                    r_odd_sorted_cache[0] <= r_odd_sorted_cache[0];
                    r_odd_sorted_cache[1] <= r_odd_sorted_cache[1];
                end
                ODD_SECOND_READ:
                begin
                    r_odd_unsorted_cache[0] <= w_shifter_cache_data;
                    r_odd_unsorted_cache[1] <= r_odd_unsorted_cache[1];
                    r_odd_sorted_cache[0] <= r_odd_sorted_cache[0];
                    r_odd_sorted_cache[1] <= r_odd_sorted_cache[1];
                end
                ODD_WAIT_DATA:
                begin
                    r_odd_unsorted_cache[0] <= r_odd_unsorted_cache[0];
                    r_odd_unsorted_cache[1] <= w_shifter_cache_data;
                    r_odd_sorted_cache[0] <= r_odd_sorted_cache[0];
                    r_odd_sorted_cache[1] <= r_odd_sorted_cache[1];
                end
                ODD_ZERO_MIDDLE_RW:
                begin
                    r_odd_unsorted_cache[0] <= w_sorted_array[(2*DWIDTH)-1:DWIDTH];
                    r_odd_unsorted_cache[1] <= w_shifter_cache_data;
                    r_odd_sorted_cache[0] <= w_sorted_array[DWIDTH-1:0];
                    r_odd_sorted_cache[1] <= w_sorted_array[(2*DWIDTH)-1:DWIDTH];
                end
                ODD_WAIT_SHIFT_DATA:
                begin
                    r_odd_unsorted_cache[0] <= w_sorted_array[(2*DWIDTH)-1:DWIDTH];
                    r_odd_unsorted_cache[1] <= w_shifter_cache_data;
                    r_odd_sorted_cache[0] <= w_sorted_array[DWIDTH-1:0];
                    r_odd_sorted_cache[1] <= w_sorted_array[(2*DWIDTH)-1:DWIDTH];
                end
                ODD_ONE_MIDDLE_RW:
                begin
                    if ((w_shifter_valid) || (!w_shifter_valid && (r_odd_pointer_1 - r_odd_pointer_0 == 1)))
                    begin
                        r_odd_unsorted_cache[0] <= w_sorted_array[(2*DWIDTH)-1:DWIDTH];
                        r_odd_unsorted_cache[1] <= w_shifter_cache_data;
                        r_odd_sorted_cache[0] <= w_sorted_array[DWIDTH-1:0];
                        r_odd_sorted_cache[1] <= w_sorted_array[(2*DWIDTH)-1:DWIDTH];
                    end
                    else
                    begin
                        r_odd_unsorted_cache[0] <= r_odd_unsorted_cache[0];
                        r_odd_unsorted_cache[1] <= r_odd_unsorted_cache[1];
                        r_odd_sorted_cache[0] <= r_odd_sorted_cache[0];
                        r_odd_sorted_cache[1] <= r_odd_sorted_cache[1];
                    end
                end
                ODD_LAST_WRITE:
                begin
                    r_odd_unsorted_cache[0] <= w_sorted_array[(2*DWIDTH)-1:DWIDTH];
                    r_odd_unsorted_cache[1] <= w_shifter_cache_data;
                    r_odd_sorted_cache[0] <= r_odd_sorted_cache[0];
                    r_odd_sorted_cache[1] <= r_odd_sorted_cache[1];
                end
                ODD_DONE:
                begin
                    r_odd_unsorted_cache[0] <= 0;
                    r_odd_unsorted_cache[1] <= 0;
                    r_odd_sorted_cache[0] <= 0;
                    r_odd_sorted_cache[1] <= 0;
                end
                default:
                begin
                    r_odd_unsorted_cache[0] <= r_odd_unsorted_cache[0];
                    r_odd_unsorted_cache[1] <= r_odd_unsorted_cache[1];
                    r_odd_sorted_cache[0] <= r_odd_sorted_cache[0];
                    r_odd_sorted_cache[1] <= r_odd_sorted_cache[1];
                end
            endcase
        end   
    end

    /////////////////////////////////////////////////////
    //                Data Arrangement                 //
    /////////////////////////////////////////////////////
    // Declare registers
    reg [3:0] r_data_state;

    // Declare local parameters
    parameter [3:0] DATA_ARRANGE_IDLE = 4'd0,
                    DATA_ARRANGE_START = 4'd1,
                    DATA_ARRANGE_ZERO_PROCESS = 4'd2,
                    DATA_ARRANGE_ONE_PROCESS = 4'd3,
                    DATA_ARRANGE_DONE = 4'd4;
     
    // Assign value to wire
    assign w_data_done = (r_data_state == DATA_ARRANGE_DONE);

    // State logic
    always @(posedge I_ACLK) 
    begin
        if (!I_ARESETN)
        begin
            r_data_state <= DATA_ARRANGE_IDLE;
        end 
        else
        begin
            case (r_data_state)
                DATA_ARRANGE_IDLE:
                begin
                    if (w_data_start_pulse)
                    begin
                        r_data_state <= DATA_ARRANGE_START;
                    end
                    else
                    begin
                        r_data_state <= DATA_ARRANGE_IDLE;
                    end
                end
                DATA_ARRANGE_START:
                begin
                    r_data_state <= DATA_ARRANGE_ZERO_PROCESS;
                end
                DATA_ARRANGE_ZERO_PROCESS:
                begin
                    if (r_data_addr_even == w_mixed_pointer)
                    begin
                        r_data_state <= DATA_ARRANGE_ONE_PROCESS;
                    end
                    else
                    begin
                        r_data_state <= r_data_state;
                    end
                end
                DATA_ARRANGE_ONE_PROCESS:
                begin
                    if (r_data_addr_odd == (DATABRAMDEPTH - 1))
                    begin
                        r_data_state <= DATA_ARRANGE_DONE;
                    end
                    else
                    begin
                        r_data_state <= r_data_state;
                    end
                end
                DATA_ARRANGE_DONE:
                begin
                    r_data_state <= DATA_ARRANGE_IDLE;
                end
                default:
                begin
                    r_data_state <= DATA_ARRANGE_IDLE;
                end
            endcase
        end   
    end

    //////////////////////////////////////////////////
    //      Data Arrangement Pointer, R/W logic     //
    //////////////////////////////////////////////////
    // Declare registers
    reg r_data_shifter_start;
    reg r_data_even_we;
    reg r_data_odd_we;
    reg [DATAADDRWIDTH-1:0] r_data_mixed_pointer;
    reg [DATAADDRWIDTH-1:0] r_data_addr_even;
    reg [DATAADDRWIDTH-1:0] r_data_addr_odd;
    reg [DATAADDRWIDTH-1:0] r_data_pointer_0;
    reg [DATAADDRWIDTH-1:0] r_data_pointer_1;

    // Main logic
    always @(posedge I_ACLK) 
    begin
        if (!I_ARESETN)
        begin
            r_data_pointer_0 <= 0;
            r_data_pointer_1 <= DATABRAMDEPTH - 1;
            r_data_addr_even <= 0;
            r_data_addr_odd <= 0;
            r_data_even_we <= 0;
            r_data_odd_we <= 0;
            r_data_shifter_start <= 0;
            r_data_mixed_pointer <= 0;
        end 
        else
        begin
            case (r_data_state)
                DATA_ARRANGE_IDLE:
                begin
                    // Nothing to do
                end
                DATA_ARRANGE_START:
                begin
                    // Assert start sorter signal
                    r_data_shifter_start <= 1;
                    // Set zero and one pointer
                    r_data_pointer_0 <= r_data_pointer_0;
                    r_data_pointer_1 <= r_data_pointer_1;
                    r_data_mixed_pointer <= r_data_mixed_pointer;
                    // Set read and write pointer
                    r_data_addr_odd <= r_data_addr_odd;
                    r_data_addr_even <= r_data_addr_even;
                    // Set write enable signal
                    r_data_even_we <= 0;
                    r_data_odd_we <= 0;
                end
                DATA_ARRANGE_ZERO_PROCESS:
                begin
                    // Assert start sorter signal
                    r_data_shifter_start <= 0;
                    // Set read pointer signal
                    if (r_data_addr_even < w_mixed_pointer)
                    begin
                        r_data_addr_even <= r_data_addr_even + 1;
                    end
                    else
                    begin
                        r_data_addr_even <= DATABRAMDEPTH - 1;
                    end

                    if (w_shifter_valid)
                    begin
                        // Set write pointer signal
                        if (r_data_addr_odd < (DATABRAMDEPTH - 1))
                        begin
                            r_data_addr_odd <= r_data_addr_odd + 1;
                        end
                        else
                        begin
                            r_data_addr_odd <= r_data_addr_odd;
                        end
                        // Set write enable signal
                        r_data_even_we <= 0;
                        r_data_odd_we <= 1;
                    end
                    else
                    begin
                        r_data_addr_odd <= r_data_addr_odd;
                        // Set write enable signal
                        r_data_even_we <= 0;
                        r_data_odd_we <= 0;
                    end
                end
                DATA_ARRANGE_ONE_PROCESS:
                begin
                    // Assert start sorter signal
                    r_data_shifter_start <= 0;
                    // Set read pointer signal
                    if (r_data_addr_even == (w_mixed_pointer + 1))
                    begin
                        r_data_addr_even <= r_data_addr_even;
                    end
                    else
                    begin
                        r_data_addr_even <= r_data_addr_even - 1;
                    end

                    if (w_shifter_valid)
                    begin
                        // Set write pointer signal
                        if (r_data_addr_odd < (DATABRAMDEPTH - 1))
                        begin
                            r_data_addr_odd <= r_data_addr_odd + 1;
                        end
                        else
                        begin
                            r_data_addr_odd <= r_data_addr_odd;
                        end
                        // Set write enable signal
                        r_data_even_we <= 0;
                        r_data_odd_we <= 1;
                    end
                    else
                    begin
                        r_data_addr_odd <= r_data_addr_odd;
                        // Set write enable signal
                        r_data_even_we <= 0;
                        r_data_odd_we <= 0;
                    end
                end
                DATA_ARRANGE_DONE:
                begin
                    // Assert start sorter signal
                    r_data_shifter_start <= 0;
                    // Set zero and one pointer
                    r_data_pointer_0 <= 0;
                    r_data_pointer_1 <= DATABRAMDEPTH - 1;
                    r_data_mixed_pointer <= r_data_pointer_0;
                    // Set read and write pointer
                    r_data_addr_odd <= 0;
                    r_data_addr_even <= 0;
                    // Set write enable signal
                    r_data_even_we <= 0;
                    r_data_odd_we <= 0; 
                end
                default:
                begin
                    // Assert start sorter signal
                    r_data_shifter_start <= 0;
                    // Set zero and one pointer
                    r_data_pointer_0 <= 0;
                    r_data_pointer_1 <= DATABRAMDEPTH - 1;
                    r_data_mixed_pointer <= r_data_mixed_pointer;
                    // Set read and write pointer
                    r_data_addr_odd <= 0;
                    r_data_addr_even <= 0;
                    // Set write enable signal
                    r_data_even_we <= 0;
                    r_data_odd_we <= 0; 
                end
            endcase
        end   
    end

    ///////////////////////////////////////
    //      Assign Value to Ports        //
    ///////////////////////////////////////
    assign O_EVEN_ADDR = (r_sort_state == FIRST_DIGIT) ? r_first_addr_even : (r_sort_state == EVEN_DIGIT) ? r_even_addr_even : 
                         (r_sort_state == ODD_DIGIT) ? r_odd_addr_even : (r_sort_state == DATA_REARRANGE) ? r_data_addr_even : 11'd0;
    assign O_ODD_ADDR  = (r_sort_state == FIRST_DIGIT) ? r_first_addr_odd : (r_sort_state == EVEN_DIGIT) ? r_even_addr_odd : 
                         (r_sort_state == ODD_DIGIT) ? r_odd_addr_odd : (r_sort_state == DATA_REARRANGE) ? r_data_addr_odd : 11'd0;
    assign O_EVEN_WE   = (r_sort_state == FIRST_DIGIT) ? r_first_even_we : (r_sort_state == EVEN_DIGIT) ? r_even_even_we : 
                         (r_sort_state == ODD_DIGIT) ? r_odd_even_we : (r_sort_state == DATA_REARRANGE) ? 1'd0 : 1'd0;
    assign O_ODD_WE    = (r_sort_state == FIRST_DIGIT) ? r_first_odd_we : (r_sort_state == EVEN_DIGIT) ? r_even_odd_we : 
                         (r_sort_state == ODD_DIGIT) ? r_odd_odd_we : (r_sort_state == DATA_REARRANGE) ? w_shifter_valid : 1'd0;

    // Declare register
    reg [DWIDTH-1:0] r_sort_data;
    // Main logic
    always @(*) 
    begin
        case (r_sort_state)
            FIRST_DIGIT:
            begin
                if (r_first_state == FIRST_DONE)
                begin
                    r_sort_data = r_first_sorted_cache[1];
                end
                else
                begin
                    r_sort_data = r_first_sorted_cache[0];
                end
            end
            EVEN_DIGIT:
            begin
                if (r_even_state == EVEN_DONE)
                begin
                    r_sort_data = r_even_sorted_cache[1];
                end
                else
                begin
                    r_sort_data = r_even_sorted_cache[0];
                end
            end
            ODD_DIGIT:
            begin
                if (r_odd_state == ODD_DONE)
                begin
                    r_sort_data = r_odd_sorted_cache[1];
                end
                else
                begin
                    r_sort_data = r_odd_sorted_cache[0];
                end
            end
            DATA_REARRANGE:
            begin
                r_sort_data = w_shifter_cache_data;
            end
            default:
            begin
                r_sort_data = 128'd0;
            end
        endcase    
    end
    // Assign value to port
    assign O_SORT_DATA = r_sort_data;

endmodule