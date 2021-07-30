////////////////////////////////////////////////////////////
/*             Top module(2 BRAM radix sort)              */
////////////////////////////////////////////////////////////

module two_bram_radix_sorter
    // Declare parameters
    #(
        parameter DWIDTH = 32,
        parameter DWIDTH_LOG2 = 5,
        parameter ROW_WIDTH = 128,
        parameter ROW_NUM = 1024,
        parameter ADDR_BIT = 10

    )
    // Declare ports
    (   
        input wire clk,
        input wire resetn,
        input wire start,
        input wire [ROW_WIDTH-1:0] data_in1,
        input wire [ROW_WIDTH-1:0] data_in2,
        output reg [ROW_WIDTH-1:0] data_out,
        output wire [ADDR_BIT-1:0] addr1, addr2,
        output wire wen1, wen2,
        // Debug signal
        output wire [2:0] sort_state,
        output wire [2:0] o_first_state,
        output wire [3:0] o_even_state,
        output wire [3:0] o_odd_state,
        output wire [3:0] o_data_state,
        output wire sort_start_delay,
        output wire [ADDR_BIT-1:0] o_pointer0, 
        output wire [ADDR_BIT-1:0] o_pointer1,
        output wire done

    );

    ///////////////////////////////
	//     Instantiate Module    //
	///////////////////////////////
    // Declare registers and wires
    // Sorting unit
    reg we1, we2;
    reg [ROW_WIDTH-1:0] unsorted_cache [1:0];
    reg [ROW_WIDTH-1:0] sorted_cache [1:0];
    wire [2*ROW_WIDTH-1:0] unsorted_array;
    wire [2*ROW_WIDTH-1:0] sorted_array;
    wire row_idx;
    wire [2:0] data_pattern;
    reg [DWIDTH-1:0] mask;
    // Data shifter
    reg [ROW_WIDTH-1:0] r_shifter_data;
    wire w_shifter_first_row;
    wire w_shifter_valid;
    wire [ADDR_BIT:0] w_zero_count;
    wire [ADDR_BIT:0] w_one_count;
    wire [ROW_WIDTH-1:0] w_shifter_cache_data;
    wire w_shifter_start;

    // Assign value to wires
    // Sorting unit
    assign unsorted_array = (state == FIRST_DIGIT) ? {first_unsorted_cache[1],first_unsorted_cache[0]} : (state == EVEN_DIGIT) ? {even_unsorted_cache[1],even_unsorted_cache[0]} : (state == ODD_DIGIT) ? {odd_unsorted_cache[1],odd_unsorted_cache[0]} : 256'd0;   
    // Marking first sequence
    assign w_shifter_first_row = (state == FIRST_DIGIT);
    assign w_zero_count = (state == FIRST_DIGIT) ? ROW_NUM : count0;
    assign w_one_count = (state == FIRST_DIGIT) ? 0 : count1;
    assign w_shifter_start = (state == FIRST_DIGIT) ? r_first_shifter_start : (state == EVEN_DIGIT) ? r_even_shifter_start : (state == ODD_DIGIT) ? r_odd_shifter_start : (state == DATA_REARRANGE) ? r_data_shifter_start : 1'b0;
    // Data selector
    always @(*) 
    begin
        case (state)
            IDLE:
            begin
                r_shifter_data = data_in1;
            end
            FIRST_DIGIT:
            begin
                r_shifter_data = data_in1;
            end
            EVEN_DIGIT:
            begin
                r_shifter_data = data_in2;
            end
            ODD_DIGIT:
            begin
                r_shifter_data = data_in1;
            end
            DATA_REARRANGE:
            begin
                r_shifter_data = data_in1;
            end
            default:
            begin
                r_shifter_data = data_in1;
            end
        endcase  
    end

    sorting_unit SORTING_UNIT
    (
        .data_in(unsorted_array),
        .mask_in(mask),
        .data_out(sorted_array),
        .row_idx(row_idx),
        .data_pattern(data_pattern)
    );

    // Data shifter unit
    data_shifter data_shifter_unit
    (
        // Input ports
        .I_ACLK(clk),
        .I_ARESETN(resetn),
        .I_START(w_shifter_start),
        .I_DATA_FLAG(mixed_flag),
        .I_FIRST_ROW(w_shifter_first_row),
        .I_DATA_PATTERN(r_data_pattern),
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
    wire start_pulse;
    // First start
    reg first_start;
    reg r_first_delay;
    reg first_done;
    wire first_start_pulse;
    // Even start
    reg even_start;
    reg r_even_delay;
    reg even_done;
    wire even_start_pulse;
    // Odd start
    reg odd_start;
    reg r_odd_delay;
    reg odd_done;
    wire odd_start_pulse;
    // Data start
    reg data_start;
    reg r_data_delay;
    reg data_done;
    wire data_start_pulse;    
    
    // Start signal logic
    always @(posedge clk) 
    begin
        if (!resetn)
        begin
            r_start_delay <= 0;
            r_first_delay <= 0;
            r_even_delay <= 0;
            r_odd_delay <= 0;
            r_data_delay <= 0;
        end
        else
        begin
            r_start_delay <= start;
            r_first_delay <= first_start;
            r_even_delay <= even_start;
            r_odd_delay <= odd_start;
            r_data_delay <= data_start;
        end
    end
    // Start pulse generation
    assign sort_start_delay = r_start_delay;
    assign start_pulse = start && !r_start_delay;
    assign first_start_pulse = first_start && !r_first_delay;
    assign even_start_pulse = even_start && !r_even_delay;
    assign odd_start_pulse = odd_start && !r_odd_delay;
    assign data_start_pulse = data_start && !r_data_delay;


    /////////////////////////////////////////////////////
    //            Global State Machine                 //
    /////////////////////////////////////////////////////    
    // Declare registers and wire
    reg [2:0] state;
    reg [DWIDTH_LOG2-1:0] digit;
    reg [ADDR_BIT-1:0] pointer0, pointer1;
    reg [ADDR_BIT-1:0] mixed_pointer;
    reg [2:0] r_data_pattern;
    reg mixed_flag;
    wire [ADDR_BIT-1:0] count0, count1;

    // Declare local parameters
    parameter [2:0] IDLE = 3'd0,
                    FIRST_DIGIT = 3'd1,
                    EVEN_DIGIT = 3'd2,
                    ODD_DIGIT = 3'd3,
                    DATA_REARRANGE = 3'd4,
                    DONE = 3'd5;

    // Assign logic to counter
    assign count0 = mixed_pointer;
    assign count1 = ROW_NUM - mixed_pointer - 1;
    assign done = (state == DONE);
    assign sort_state = state;
    assign o_first_state = first_state;
    assign o_even_state = even_state;
    assign o_odd_state = odd_state;
    assign o_data_state = data_state;
    assign o_pointer0 = pointer0;
    assign o_pointer1 = pointer1;

    // State logic
    always @(posedge clk)
    begin
        if(!resetn)
        begin
            state <= IDLE;
        end
        else
        begin
            case(state)
                IDLE:
                begin
                    digit <= 0;
                    mask <= 32'b1;
                    pointer0 <= 0;
                    pointer1 <= ROW_NUM - 1;
                    first_start <= 0;
                    even_start <= 0;
                    odd_start <= 0;
                    data_start <= 0;

                    if(start_pulse) 
                    begin
                        state <= FIRST_DIGIT;
                    end
                    else
                    begin
                        state <= IDLE;
                    end
                end

                FIRST_DIGIT:
                begin
                    if(first_done)
                    begin
                        state <= EVEN_DIGIT;
                        digit <= digit + 1;
                        mask <= mask << 1;
                        first_start <= 0;
                    end
                    else
                    begin
                        state <= FIRST_DIGIT;
                        first_start <= 1;
                    end
                end

                EVEN_DIGIT:
                begin
                    if(even_done)
                    begin
                        even_start <= 0;
                        if(digit == 31)
                        begin
                            state <= DATA_REARRANGE;
                        end
                        else
                        begin
                        state <= ODD_DIGIT;
                        digit <= digit + 1;
                        mask <= mask << 1;
                        end
                    end

                    else
                    begin
                        state <= EVEN_DIGIT;
                        even_start <= 1;
                    end
                end

                ODD_DIGIT:
                begin
                    if(odd_done)
                    begin
                        state <= EVEN_DIGIT;
                        digit <= digit + 1;
                        mask <= mask << 1;
                        odd_start <= 0;
                    end
                    else
                    begin
                        state <= ODD_DIGIT;
                        odd_start <= 1;
                    end
                end

                DATA_REARRANGE:
                begin
                    if(data_done)
                    begin
                        state <= DONE;
                        data_start <= 0;
                    end
                    else
                    begin
                        state <= DATA_REARRANGE;
                        data_start <= 1;
                    end
                end

                DONE:
                begin
                    state <= IDLE;
                end
            endcase
        end
    end


    /////////////////////////////////////////////
    //             FIRST_DIGIT                 //
    /////////////////////////////////////////////
    // Declare registers
    reg [ADDR_BIT-1:0] r_first_addr1, r_first_addr2;
    reg [2:0] first_state;

    // Declare local parameters
    localparam [2:0] FIRST_IDLE = 3'd0,
                     FIRST_START_SORTER = 3'd1,
                     FIRST_FIRST_READ = 3'd2,
                     FIRST_SECOND_READ = 3'd3,
                     FIRST_WAIT_DATA = 3'd4,
                     FIRST_MIDDLE_RW = 3'd5,
                     FIRST_LAST_WRITE = 3'd6,
                     FIRST_DONE = 3'd7;
    
    // Main logic
    always @(posedge clk)
    begin
        if(!resetn)
        begin
            first_state <= FIRST_IDLE;
            first_done <= 0;
            r_data_pattern <= 0;
            mixed_flag <= 0;
        end
        else
        begin
            case(first_state)
                FIRST_IDLE:
                begin
                    if(first_start_pulse)
                    begin
                        first_state <= FIRST_START_SORTER;
                        first_done <= 0;
                    end
                    else
                    begin
                        first_state <= FIRST_IDLE;
                        first_done <= 0;
                    end
                end
                FIRST_START_SORTER:
                begin
                    first_state <= FIRST_FIRST_READ;
                    first_done <= 0;
                end
                FIRST_FIRST_READ:
                begin
                    if(r_first_addr1 == 1)
                    begin
                        first_state <= FIRST_SECOND_READ;
                    end
                    first_done <= 0;
                end
                FIRST_SECOND_READ:
                begin
                    first_done <= 0;
                    first_state <= FIRST_WAIT_DATA;
                end
                FIRST_WAIT_DATA:
                begin
                    first_done <= 0;
                    first_state <= FIRST_MIDDLE_RW;
                end
                FIRST_MIDDLE_RW:
                begin
                    first_done <= 0;
                    if(pointer1 - pointer0 == 1)
                    begin
                        first_state <= FIRST_LAST_WRITE;
                        r_data_pattern <= data_pattern;
                        mixed_flag <= row_idx;
                    end
                end
                FIRST_LAST_WRITE:
                begin
                    first_done <= 0;
                    first_state <= FIRST_DONE;
                end
                FIRST_DONE:
                begin
                    first_done <= 1;
                    first_state <= FIRST_IDLE;
                end
            endcase
        end
    end

    /////////////////////////////////////////////
    //      First Digit Pointer, R/W logic     //
    /////////////////////////////////////////////
    // Declare register
    reg r_first_shifter_start;
    always @(posedge clk)
    begin
        if(!resetn)
        begin
            pointer0 <= 0;
            pointer1 <= ROW_NUM - 1;
            r_first_addr1 <= 0;
            r_first_addr2 <= 0;
            we1 <= 0;
            we2 <= 0;
            r_first_shifter_start <= 0;   
            mixed_pointer <= 0;           
        end
        else
        begin
            case(first_state)
                FIRST_IDLE:
                begin
                    // Nothing to do
                end
                FIRST_START_SORTER:
                begin
                    // Assert start sorter signal
                    r_first_shifter_start <= 1;
                    // Set read and write pointer
                    r_first_addr1 <= r_first_addr1;
                    r_first_addr2 <= r_first_addr2;
                    // Set write enable signal
                    we1 <= 0;
                    we2 <= 0;
                end
                FIRST_FIRST_READ:
                begin
                    // Assert start sorter signal
                    r_first_shifter_start <= 0;
                    // Set read and write pointer
                    r_first_addr1 <= r_first_addr1 + 1;
                    r_first_addr2 <= r_first_addr2;
                    // Set write enable signal
                    we1 <= 0;
                    we2 <= 0;
                end
                FIRST_SECOND_READ:
                begin
                    // Deassert start sorter signal
                    r_first_shifter_start <= 0;
                    // Set read and write pointer
                    r_first_addr1 <= r_first_addr1 + 1;
                    r_first_addr2 <= r_first_addr2;
                    // Set write enable signal
                    we1 <= 0;
                    we2 <= 0;
                end
                FIRST_WAIT_DATA:
                begin
                    // Deassert start sorter signal
                    r_first_shifter_start <= 0;
                    // Set read and write pointer
                    r_first_addr1 <= r_first_addr1 + 1;
                    r_first_addr2 <= r_first_addr2;
                    // Set write enable signal
                    we1 <= 0;
                    we2 <= 0;
                end
                FIRST_MIDDLE_RW:
                begin
                    // Set write enable signal
                    we1 <= 0;
                    we2 <= 1;
                    // Set write pointer signal
                    if(row_idx == 0) 
                    begin
                        r_first_addr2 <= pointer0;
                        pointer0 <= pointer0 + 1; 
                    end
                    else
                    begin
                        r_first_addr2 <= pointer1;
                        pointer1 <= pointer1 - 1;
                    end

                    // Set read pointer signal
                    if(r_first_addr1 == ROW_NUM-1)
                    begin
                        r_first_addr1 <= r_first_addr1;
                    end
                    else
                    begin 
                        r_first_addr1 <= r_first_addr1 + 1;
                    end
                end
                FIRST_LAST_WRITE:
                begin
                    // Set read and write pointer
                    r_first_addr1 <= r_first_addr1;
                    r_first_addr2 <= pointer0;
                    // Set write enable signal
                    we1 <= 0;
                    we2 <= 1;
                end
                FIRST_DONE:
                begin
                    // Reset read and write pointer
                    r_first_addr1 <= 0;
                    r_first_addr2 <= 0;
                    // Set write enable signal
                    we1 <= 0;
                    we2 <= 0;
                    // Set pointer address
                    mixed_pointer <= pointer0;
                    pointer0 <= 0;
                    pointer1 <= ROW_NUM - 1;
                end
                default:
                begin
                    r_first_addr1 <= 0;
                    r_first_addr2 <= 0;
                    we1 <= 0;
                    we2 <= 0;
                    pointer0 <= pointer0;
                    pointer1 <= pointer1;
                end
            endcase
        end
    end

    ////////////////////////////////////////////
    //      FIRST_DIGIT  Data I/O logic       //
    ////////////////////////////////////////////
    // Declare register
    reg [ROW_WIDTH-1:0] first_sorted_cache [1:0];
    reg [ROW_WIDTH-1:0] first_unsorted_cache [1:0];
    always @(posedge clk)
    begin
        if(!resetn)
        begin
            first_unsorted_cache[0] <= 0;
            first_unsorted_cache[1] <= 0;
            first_sorted_cache[0] <= 0;
            first_sorted_cache[1] <= 0;
        end
        else
        begin
            case(first_state)
                FIRST_IDLE:
                begin
                    // Nothing to do
                end
                FIRST_START_SORTER:
                begin
                    first_unsorted_cache[0] <= first_unsorted_cache[0];
                    first_unsorted_cache[1] <= first_unsorted_cache[1];
                    first_sorted_cache[0] <= first_sorted_cache[0];
                    first_sorted_cache[1] <= first_sorted_cache[1];
                end
                FIRST_FIRST_READ:
                begin
                    first_unsorted_cache[0] <= first_unsorted_cache[0];
                    first_unsorted_cache[1] <= first_unsorted_cache[1];
                end
                FIRST_SECOND_READ:
                begin
                    first_unsorted_cache[0] <= w_shifter_cache_data; 
                end
                FIRST_WAIT_DATA:
                begin
                    first_unsorted_cache[0] <= first_unsorted_cache[0];
                    first_unsorted_cache[1] <= w_shifter_cache_data;
                end
                FIRST_MIDDLE_RW:
                begin
                    first_unsorted_cache[0] <= sorted_array[2*ROW_WIDTH-1:ROW_WIDTH];
                    first_unsorted_cache[1] <= w_shifter_cache_data;
                    first_sorted_cache[0] <= sorted_array[ROW_WIDTH-1:0];
                    first_sorted_cache[1] <= sorted_array[2*ROW_WIDTH-1:ROW_WIDTH];
                end
                FIRST_LAST_WRITE:
                begin
                    first_unsorted_cache[0] <= sorted_array[2*ROW_WIDTH-1:ROW_WIDTH];
                    first_unsorted_cache[1] <= w_shifter_cache_data;
                    first_sorted_cache[0] <= first_sorted_cache[0];
                    first_sorted_cache[1] <= first_sorted_cache[1];
                end    
                FIRST_DONE:
                begin
                    first_unsorted_cache[0] <= 0;
                    first_unsorted_cache[1] <= 0;
                    first_sorted_cache[0] <= 0;
                    first_sorted_cache[1] <= 0;
                end
                default:
                begin
                    first_unsorted_cache[0] <= first_unsorted_cache[0];
                    first_unsorted_cache[1] <= first_unsorted_cache[1];
                    first_sorted_cache[0] <= first_sorted_cache[0];
                    first_sorted_cache[1] <= first_sorted_cache[1];
                end
            endcase
        end
    end


    ///////////////////////////////////////////////
    //                EVEN_DIGIT                 //
    //////////////////////////////////////////////
    // declare register
    reg [3:0] even_state;
    reg [ADDR_BIT-1:0] r_even_addr1, r_even_addr2;

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

    always @(posedge clk)
    begin
        if(!resetn)
        begin
            even_state <= EVEN_IDLE;
            even_done <= 0;
            r_data_pattern <= 0;
        end
        else
        begin
            case(even_state)
                EVEN_IDLE:
                begin   
                    if(even_start_pulse)
                    begin
                        even_state <= EVEN_START_SORTER;
                    end
                    else
                    begin
                        even_state <= EVEN_IDLE;
                    end
                    even_done <= 0;
                end
                EVEN_START_SORTER:
                begin
                    even_state <= EVEN_FIRST_READ;
                    even_done <= 0;
                end
                EVEN_FIRST_READ:
                begin
                    if(r_even_addr2 == 1)
                    begin
                        even_state <= EVEN_SECOND_READ;
                    end
                    even_done <= 0;
                end
                EVEN_SECOND_READ:
                begin
                    even_done <= 0;
                    even_state <= EVEN_WAIT_DATA;
                end
                EVEN_WAIT_DATA:
                begin
                    even_done <= 0;
                    even_state <= EVEN_ZERO_MIDDLE_RW;
                end
                EVEN_ZERO_MIDDLE_RW:
                begin
                    even_done <= 0;
                    if(r_even_addr2 == mixed_pointer - 1)
                    begin
                        even_state <= EVEN_WAIT_SHIFT_DATA;
                    end
                end
                EVEN_WAIT_SHIFT_DATA:
                begin
                    even_done <= 0;
                    even_state <= EVEN_ONE_MIDDLE_RW;
                end
                EVEN_ONE_MIDDLE_RW:
                begin
                    even_done <= 0;
                    if(pointer1 - pointer0 == 1)
                    begin
                        even_state <= EVEN_LAST_WRITE;
                        r_data_pattern <= data_pattern;
                        mixed_flag <= row_idx;
                    end
                end
                EVEN_LAST_WRITE:
                begin
                    even_done <= 0;
                    even_state <= EVEN_DONE;
                end
                EVEN_DONE:
                begin
                    even_done <= 1;
                    even_state <= EVEN_IDLE;
                end
                default
                begin
                    even_done <= 0;
                    even_state <= EVEN_IDLE;
                end
            endcase
        end
    end

    ////////////////////////////////////////////
    //      EVEN_DIGIT Pointer, R/W logic     //
    ////////////////////////////////////////////
    // Declare registers
    reg r_even_shifter_start;

    always @(posedge clk)
    begin
        if(!resetn)
        begin
            pointer0 <= 0;
            pointer1 <= ROW_NUM - 1;
            r_even_addr1 <= 0;
            r_even_addr2 <= 0;
            we1 <= 0;
            we2 <= 0; 
            r_even_shifter_start <= 0;
        end
        else
        begin
            case(even_state)
                EVEN_IDLE:
                begin   
                    // Nothing to do
                end
                EVEN_START_SORTER:
                begin
                    pointer0 <= 0;
                    pointer1 <= ROW_NUM - 1;
                    // Assert start sorter signal
                    r_even_shifter_start <= 1;
                    // Set read and write pointer
                    r_even_addr1 <= r_even_addr1;
                    r_even_addr2 <= r_even_addr2;
                    // Set write enable signal
                    we1 <= 0;
                    we2 <= 0;
                end
                EVEN_FIRST_READ:
                begin
                    // Assert start sorter signal
                    r_even_shifter_start <= 0;
                    // Set read and write pointer
                    r_even_addr1 <= r_even_addr1;
                    r_even_addr2 <= r_even_addr2 + 1;
                    // Set write enable signal
                    we1 <= 0;
                    we2 <= 0;
                end
                EVEN_SECOND_READ:
                begin
                    // Deassert start sorter signal
                    r_even_shifter_start <= 0;
                    // Set read and write pointer
                    r_even_addr1 <= r_even_addr1;
                    r_even_addr2 <= r_even_addr2 + 1;
                    // Set write enable signal
                    we1 <= 0;
                    we2 <= 0;
                end
                EVEN_WAIT_DATA:
                begin
                    // Deassert start sorter signal
                    r_even_shifter_start <= 0;
                    // Set read and write pointer
                    r_even_addr1 <= r_even_addr1;
                    r_even_addr2 <= r_even_addr2 + 1;
                    // Set write enable signal
                    we1 <= 0;
                    we2 <= 0;
                end
                EVEN_ZERO_MIDDLE_RW:
                begin
                    // Set write enable signal
                    we1 <= 1;
                    we2 <= 0;
                    // Set write pointer signal
                    if(row_idx == 0) 
                    begin
                        r_even_addr1 <= pointer0;
                        pointer0 <= pointer0 + 1; 
                    end
                    else
                    begin
                        r_even_addr1 <= pointer1;
                        pointer1 <= pointer1 - 1;
                    end
                    // Set read pointer signal
                    if(r_even_addr2 == ROW_NUM-1)
                    begin
                        r_even_addr2 <= r_even_addr2;
                    end
                    else
                    begin 
                        r_even_addr2 <= r_even_addr2 + 1;
                    end
                end
                EVEN_WAIT_SHIFT_DATA:
                begin
                    // Set write enable signal
                    we1 <= 1;
                    we2 <= 0;
                    // Set write pointer signal
                    if(row_idx == 0) 
                    begin
                        r_even_addr1 <= pointer0;
                        pointer0 <= pointer0 + 1; 
                    end
                    else
                    begin
                        r_even_addr1 <= pointer1;
                        pointer1 <= pointer1 - 1;
                    end
                    // Set read pointer signal
                    r_even_addr2 <=  ROW_NUM - 1;
                end
                EVEN_ONE_MIDDLE_RW:
                begin
                    if ((w_shifter_valid) || (!w_shifter_valid && (pointer1 - pointer0 == 1)))
                    begin
                        // Set write enable signal
                        we1 <= 1;
                        we2 <= 0;
                        // Set write pointer signal
                        if(row_idx == 0) 
                        begin
                            r_even_addr1 <= pointer0;
                            pointer0 <= pointer0 + 1; 
                        end
                        else
                        begin
                            r_even_addr1 <= pointer1;
                            pointer1 <= pointer1 - 1;
                        end
                        // Set read pointer signal
                        if(r_even_addr2 == mixed_pointer+1)
                        begin
                            r_even_addr2 <= r_even_addr2;
                        end
                        else
                        begin 
                            r_even_addr2 <= r_even_addr2 - 1;
                        end
                    end
                    else 
                    begin
                        // Set write enable signal
                        we1 <= 0;
                        we2 <= 0;
                        // Set pointer signal
                        r_even_addr1 <= r_even_addr1;
                        r_even_addr2 <= r_even_addr2 - 1;
                        pointer0 <= pointer0;
                        pointer1 <= pointer1;
                    end
                end
                EVEN_LAST_WRITE:
                begin
                    // Set read and write pointer
                    r_even_addr1 <= pointer0;
                    r_even_addr2 <= r_even_addr2;
                    // Set write enable signal
                    we1 <= 1;
                    we2 <= 0;
                end
                EVEN_DONE:
                begin
                    // Reset read and write pointer
                    r_even_addr1 <= 0;
                    r_even_addr2 <= 0;
                    // Set write enable signal
                    we1 <= 0;
                    we2 <= 0;
                    // Set pointer address
                    mixed_pointer <= pointer0;
                    pointer0 <= 0;
                    pointer1 <= ROW_NUM - 1;
                end
                default:
                begin
                    r_even_addr1 <= 0;
                    r_even_addr2 <= 0;
                    we1 <= 0;
                    we2 <= 0;
                    pointer0 <= pointer0;
                    pointer1 <= pointer1;
                end
            endcase
        end
    end
    
    //////////////////////////////////////////////
    //      EVEN_DIGIT  Data I/O logic        //
    //////////////////////////////////////////// 
    // Declare register
    reg [ROW_WIDTH-1:0] even_sorted_cache [1:0];
    reg [ROW_WIDTH-1:0] even_unsorted_cache [1:0];

    always @(posedge clk)
    begin
        if(!resetn)
        begin
            even_unsorted_cache[0] <= 0;
            even_unsorted_cache[1] <= 0;
            even_sorted_cache[0] <= 0;
            even_sorted_cache[1] <= 0;            
        end
        else
        begin
            case(even_state)
                EVEN_IDLE:
                begin
                    // Nothing to do
                end
                EVEN_START_SORTER:
                begin
                    even_unsorted_cache[0] <= even_unsorted_cache[0];
                    even_unsorted_cache[1] <= even_unsorted_cache[1];
                    even_sorted_cache[0] <= even_sorted_cache[0];
                    even_sorted_cache[1] <= even_sorted_cache[1];
                end
                EVEN_FIRST_READ:
                begin
                    even_unsorted_cache[0] <= even_unsorted_cache[0];
                    even_unsorted_cache[1] <= even_unsorted_cache[1];
                end
                EVEN_SECOND_READ:
                begin
                    even_unsorted_cache[0] <= w_shifter_cache_data; 
                end
                EVEN_WAIT_DATA:
                begin
                    even_unsorted_cache[0] <= even_unsorted_cache[0];
                    even_unsorted_cache[1] <= w_shifter_cache_data;
                end
                EVEN_ZERO_MIDDLE_RW:
                begin
                    even_unsorted_cache[0] <= sorted_array[2*ROW_WIDTH-1:ROW_WIDTH];
                    even_unsorted_cache[1] <= w_shifter_cache_data;
                    even_sorted_cache[0] <= sorted_array[ROW_WIDTH-1:0];
                    even_sorted_cache[1] <= sorted_array[2*ROW_WIDTH-1:ROW_WIDTH];
                end
                EVEN_WAIT_SHIFT_DATA:
                begin
                    even_unsorted_cache[0] <= sorted_array[2*ROW_WIDTH-1:ROW_WIDTH];
                    even_unsorted_cache[1] <= w_shifter_cache_data;
                    even_sorted_cache[0] <= sorted_array[ROW_WIDTH-1:0];
                    even_sorted_cache[1] <= sorted_array[2*ROW_WIDTH-1:ROW_WIDTH];
                end
                EVEN_ONE_MIDDLE_RW:
                begin
                    if ((w_shifter_valid) || (!w_shifter_valid && (pointer1 - pointer0 == 1)))
                    begin
                        even_unsorted_cache[0] <= sorted_array[2*ROW_WIDTH-1:ROW_WIDTH];
                        even_unsorted_cache[1] <= w_shifter_cache_data;
                        even_sorted_cache[0] <= sorted_array[ROW_WIDTH-1:0];
                        even_sorted_cache[1] <= sorted_array[2*ROW_WIDTH-1:ROW_WIDTH];
                    end
                    else
                    begin
                        even_unsorted_cache[0] <= even_unsorted_cache[0];
                        even_unsorted_cache[1] <= even_unsorted_cache[1];
                        even_sorted_cache[0] <= even_sorted_cache[0];
                        even_sorted_cache[1] <= even_sorted_cache[1];
                    end
                end
                EVEN_LAST_WRITE:
                begin
                    even_unsorted_cache[0] <= sorted_array[2*ROW_WIDTH-1:ROW_WIDTH];
                    even_unsorted_cache[1] <= w_shifter_cache_data;
                    even_sorted_cache[0] <= even_sorted_cache[0];
                    even_sorted_cache[1] <= even_sorted_cache[1];
                end    
                EVEN_DONE:
                begin
                    even_unsorted_cache[0] <= 0;
                    even_unsorted_cache[1] <= 0;
                    even_sorted_cache[0] <= 0;
                    even_sorted_cache[1] <= 0;
                end
                default:
                begin
                    even_unsorted_cache[0] <= even_unsorted_cache[0];
                    even_unsorted_cache[1] <= even_unsorted_cache[1];
                    even_sorted_cache[0] <= even_sorted_cache[0];
                    even_sorted_cache[1] <= even_sorted_cache[1];
                end
            endcase
        end
    end


    //////////////////////////////////////////////
    //                ODD_DIGIT                 //
    //////////////////////////////////////////////
    // declare register
    reg [3:0] odd_state;
    reg [ADDR_BIT-1:0] r_odd_addr1, r_odd_addr2;

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

    always @(posedge clk)
    begin
        if(!resetn)
        begin
            odd_state <= ODD_IDLE;
            odd_done <= 0;
            r_data_pattern <= 0;
        end
        else
        begin
            case(odd_state)
                ODD_IDLE:
                begin   
                    if(odd_start_pulse)
                    begin
                        odd_state <= ODD_START_SORTER;
                    end
                    else
                    begin
                        odd_state <= ODD_IDLE;
                    end
                    odd_done <= 0;
                end
                ODD_START_SORTER:
                begin
                    odd_state <= ODD_FIRST_READ;
                    odd_done <= 0;
                end
                ODD_FIRST_READ:
                begin
                    if(r_odd_addr1 == 1)
                    begin
                        odd_state <= ODD_SECOND_READ;
                    end
                    odd_done <= 0;
                end
                ODD_SECOND_READ:
                begin
                    odd_done <= 0;
                    odd_state <= ODD_WAIT_DATA;
                end
                ODD_WAIT_DATA:
                begin
                    odd_done <= 0;
                    odd_state <= ODD_ZERO_MIDDLE_RW;
                end
                ODD_ZERO_MIDDLE_RW:
                begin
                    odd_done <= 0;
                    if(r_odd_addr1 == mixed_pointer - 1)
                    begin
                        odd_state <= ODD_WAIT_SHIFT_DATA;
                    end
                end
                ODD_WAIT_SHIFT_DATA:
                begin
                    odd_done <= 0;
                    odd_state <= ODD_ONE_MIDDLE_RW;
                end
                ODD_ONE_MIDDLE_RW:
                begin
                    odd_done <= 0;
                    if(pointer1 - pointer0 == 1)
                    begin
                        odd_state <= ODD_LAST_WRITE;
                        r_data_pattern <= data_pattern;
                        mixed_flag <= row_idx;
                    end
                end
                ODD_LAST_WRITE:
                begin
                    odd_done <= 0;
                    odd_state <= ODD_DONE;
                end
                ODD_DONE:
                begin
                    odd_done <= 1;
                    odd_state <= ODD_IDLE;
                end
                default
                begin
                    odd_done <= 0;
                    odd_state <= ODD_IDLE;
                end
            endcase
        end
    end

    ///////////////////////////////////////////
    //      ODD_DIGIT Pointer, R/W logic     //
    ///////////////////////////////////////////
    // Declare registers
    reg r_odd_shifter_start;
    always @(posedge clk)
    begin
        if(!resetn)
        begin
            pointer0 <= 0;
            pointer1 <= ROW_NUM - 1;
            r_odd_addr1 <= 0;
            r_odd_addr2 <= 0;
            we1 <= 0;
            we2 <= 0; 
            r_odd_shifter_start <= 0;
        end
        else
        begin
            case(odd_state)
                ODD_IDLE:
                begin   
                    // Nothing to do
                end
                ODD_START_SORTER:
                begin
                    pointer0 <= 0;
                    pointer1 <= ROW_NUM - 1;
                    // Assert start sorter signal
                    r_odd_shifter_start <= 1;
                    // Set read and write pointer
                    r_odd_addr1 <= r_odd_addr1;
                    r_odd_addr2 <= r_odd_addr2;
                    // Set write enable signal
                    we1 <= 0;
                    we2 <= 0;
                end
                ODD_FIRST_READ:
                begin
                    // Assert start sorter signal
                    r_odd_shifter_start <= 0;
                    // Set read and write pointer
                    r_odd_addr1 <= r_odd_addr1 + 1;
                    r_odd_addr2 <= r_odd_addr2;
                    // Set write enable signal
                    we1 <= 0;
                    we2 <= 0;
                end
                ODD_SECOND_READ:
                begin
                    // Deassert start sorter signal
                    r_odd_shifter_start <= 0;
                    // Set read and write pointer
                    r_odd_addr1 <= r_odd_addr1 + 1;
                    r_odd_addr2 <= r_odd_addr2;
                    // Set write enable signal
                    we1 <= 0;
                    we2 <= 0;
                end
                ODD_WAIT_DATA:
                begin
                    // Deassert start sorter signal
                    r_odd_shifter_start <= 0;
                    // Set read and write pointer
                    r_odd_addr1 <= r_odd_addr1 + 1;
                    r_odd_addr2 <= r_odd_addr2;
                    // Set write enable signal
                    we1 <= 0;
                    we2 <= 0;
                end
                ODD_ZERO_MIDDLE_RW:
                begin
                    // Set write enable signal
                    we1 <= 0;
                    we2 <= 1;
                    // Set write pointer signal
                    if(row_idx == 0) 
                    begin
                        r_odd_addr2 <= pointer0;
                        pointer0 <= pointer0 + 1; 
                    end
                    else
                    begin
                        r_odd_addr2 <= pointer1;
                        pointer1 <= pointer1 - 1;
                    end
                    // Set read pointer signal
                    if(r_odd_addr1 == ROW_NUM-1)
                    begin
                        r_odd_addr1 <= r_odd_addr1;
                    end
                    else
                    begin 
                        r_odd_addr1 <= r_odd_addr1 + 1;
                    end
                end
                ODD_WAIT_SHIFT_DATA:
                begin
                    // Set write enable signal
                    we1 <= 0;
                    we2 <= 1;
                    // Set write pointer signal
                    if(row_idx == 0) 
                    begin
                        r_odd_addr2 <= pointer0;
                        pointer0 <= pointer0 + 1; 
                    end
                    else
                    begin
                        r_odd_addr2 <= pointer1;
                        pointer1 <= pointer1 - 1;
                    end
                    // Set read pointer signal
                    r_odd_addr1 <=  ROW_NUM - 1;
                end
                ODD_ONE_MIDDLE_RW:
                begin
                    if ((w_shifter_valid) || (!w_shifter_valid && (pointer1 - pointer0 == 1)))
                    begin
                        // Set write enable signal
                        we1 <= 0;
                        we2 <= 1;
                        // Set write pointer signal
                        if(row_idx == 0) 
                        begin
                            r_odd_addr2 <= pointer0;
                            pointer0 <= pointer0 + 1; 
                        end
                        else
                        begin
                            r_odd_addr2 <= pointer1;
                            pointer1 <= pointer1 - 1;
                        end
                        // Set read pointer signal
                        if(r_odd_addr1 == mixed_pointer+1)
                        begin
                            r_odd_addr1 <= r_odd_addr1;
                        end
                        else
                        begin 
                            r_odd_addr1 <= r_odd_addr1 - 1;
                        end
                    end
                    else
                    begin
                        // Set write enable signal
                        we1 <= 0;
                        we2 <= 0;
                        // Set pointer signal
                        r_odd_addr1 <= r_odd_addr1 - 1;
                        r_odd_addr2 <= r_odd_addr2;
                        pointer0 <= pointer0;
                        pointer1 <= pointer1;
                    end
                end
                ODD_LAST_WRITE:
                begin
                    // Set read and write pointer
                    r_odd_addr1 <= r_odd_addr1;
                    r_odd_addr2 <= pointer0;
                    // Set write enable signal
                    we1 <= 0;
                    we2 <= 1;
                end
                ODD_DONE:
                begin
                    // Reset read and write pointer
                    r_odd_addr1 <= 0;
                    r_odd_addr2 <= 0;
                    // Set write enable signal
                    we1 <= 0;
                    we2 <= 0;
                    // Set pointer address
                    mixed_pointer <= pointer0;
                    pointer0 <= 0;
                    pointer1 <= ROW_NUM - 1;
                end
                default:
                begin
                    r_odd_addr1 <= 0;
                    r_odd_addr2 <= 0;
                    we1 <= 0;
                    we2 <= 0;
                    pointer0 <= pointer0;
                    pointer1 <= pointer1;
                end
            endcase
        end
    end
    
    ////////////////////////////////////////////
    //      ODD_DIGIT  Data I/O logic        //
    //////////////////////////////////////////// 
    // Declare register
    reg [ROW_WIDTH-1:0] odd_sorted_cache [1:0];
    reg [ROW_WIDTH-1:0] odd_unsorted_cache [1:0];
    always @(posedge clk)
    begin
        if(!resetn)
        begin
            odd_unsorted_cache[0] <= 0;
            odd_unsorted_cache[1] <= 0;
            odd_sorted_cache[0] <= 0;
            odd_sorted_cache[1] <= 0;            
        end
        else
        begin
            case(odd_state)
                ODD_IDLE:
                begin
                    // Nothing to do
                end
                ODD_START_SORTER:
                begin
                    odd_unsorted_cache[0] <= odd_unsorted_cache[0];
                    odd_unsorted_cache[1] <= odd_unsorted_cache[1];
                    odd_sorted_cache[0] <= odd_sorted_cache[0];
                    odd_sorted_cache[1] <= odd_sorted_cache[1];
                end
                ODD_FIRST_READ:
                begin
                    odd_unsorted_cache[0] <= odd_unsorted_cache[0];
                    odd_unsorted_cache[1] <= odd_unsorted_cache[1];
                end
                ODD_SECOND_READ:
                begin
                    odd_unsorted_cache[0] <= w_shifter_cache_data; 
                end
                ODD_WAIT_DATA:
                begin
                    odd_unsorted_cache[0] <= odd_unsorted_cache[0];
                    odd_unsorted_cache[1] <= w_shifter_cache_data;
                end
                ODD_ZERO_MIDDLE_RW:
                begin
                    odd_unsorted_cache[0] <= sorted_array[2*ROW_WIDTH-1:ROW_WIDTH];
                    odd_unsorted_cache[1] <= w_shifter_cache_data;
                    odd_sorted_cache[0] <= sorted_array[ROW_WIDTH-1:0];
                    odd_sorted_cache[1] <= sorted_array[2*ROW_WIDTH-1:ROW_WIDTH];
                end
                ODD_WAIT_SHIFT_DATA:
                begin
                    odd_unsorted_cache[0] <= sorted_array[2*ROW_WIDTH-1:ROW_WIDTH];
                    odd_unsorted_cache[1] <= w_shifter_cache_data;
                    odd_sorted_cache[0] <= sorted_array[ROW_WIDTH-1:0];
                    odd_sorted_cache[1] <= sorted_array[2*ROW_WIDTH-1:ROW_WIDTH];
                end
                ODD_ONE_MIDDLE_RW:
                begin
                    if ((w_shifter_valid) || (!w_shifter_valid && (pointer1 - pointer0 == 1)))
                    begin
                        odd_unsorted_cache[0] <= sorted_array[2*ROW_WIDTH-1:ROW_WIDTH];
                        odd_unsorted_cache[1] <= w_shifter_cache_data;
                        odd_sorted_cache[0] <= sorted_array[ROW_WIDTH-1:0];
                        odd_sorted_cache[1] <= sorted_array[2*ROW_WIDTH-1:ROW_WIDTH];
                    end
                    else
                    begin
                        odd_unsorted_cache[0] <= odd_unsorted_cache[0];
                        odd_unsorted_cache[1] <= odd_unsorted_cache[1];
                        odd_sorted_cache[0] <= odd_sorted_cache[0];
                        odd_sorted_cache[1] <= odd_sorted_cache[1];
                    end
                end
                ODD_LAST_WRITE:
                begin
                    odd_unsorted_cache[0] <= sorted_array[2*ROW_WIDTH-1:ROW_WIDTH];
                    odd_unsorted_cache[1] <= w_shifter_cache_data;
                    odd_sorted_cache[0] <= odd_sorted_cache[0];
                    odd_sorted_cache[1] <= odd_sorted_cache[1];
                end    
                ODD_DONE:
                begin
                    odd_unsorted_cache[0] <= 0;
                    odd_unsorted_cache[1] <= 0;
                    odd_sorted_cache[0] <= 0;
                    odd_sorted_cache[1] <= 0;
                end
                default:
                begin
                    odd_unsorted_cache[0] <= odd_unsorted_cache[0];
                    odd_unsorted_cache[1] <= odd_unsorted_cache[1];
                    odd_sorted_cache[0] <= odd_sorted_cache[0];
                    odd_sorted_cache[1] <= odd_sorted_cache[1];
                end
            endcase
        end
    end


    /////////////////////////////////////////////////////
    //                Data Arrangement                 //
    /////////////////////////////////////////////////////
    // declare register
    reg [3:0] data_state;
    reg [ADDR_BIT-1:0] r_data_addr1, r_data_addr2;

    // Declare local parameters
    parameter [3:0] DATA_ARRANGE_IDLE = 4'd0,
                    DATA_ARRANGE_START = 4'd1,
                    DATA_ARRANGE_ZERO_PROCESS = 4'd2,
                    DATA_ARRANGE_ONE_PROCESS = 4'd3,
                    DATA_ARRANGE_DONE = 4'd4;

    always @(posedge clk)
    begin
        if(!resetn)
        begin
            data_state <= DATA_ARRANGE_IDLE;
            data_done <= 0;
            r_data_pattern <= 0;
        end
        else
        begin
            case(data_state)
                DATA_ARRANGE_IDLE:
                begin   
                    if(data_start_pulse)
                    begin
                        data_state <= DATA_ARRANGE_START;
                    end
                    else
                    begin
                        data_state <= DATA_ARRANGE_IDLE;
                    end
                    data_done <= 0;
                end
                DATA_ARRANGE_START:
                begin
                    data_state <= DATA_ARRANGE_ZERO_PROCESS;
                    data_done <= 0;
                end
                DATA_ARRANGE_ZERO_PROCESS:
                begin
                    if(r_data_addr1 == mixed_pointer)
                    begin
                        data_state <= DATA_ARRANGE_ONE_PROCESS;
                    end
                    else
                    begin
                        data_state <= data_state;
                    end
                    data_done <= 0;
                end
                DATA_ARRANGE_ONE_PROCESS:
                begin
                    if(r_data_addr2 == ROW_NUM-1)
                    begin
                        data_state <= DATA_ARRANGE_DONE;
                    end
                    else
                    begin
                        data_state <= data_state;
                    end
                    data_done <= 0;
                end
                DATA_ARRANGE_DONE:
                begin
                    data_state <= DATA_ARRANGE_IDLE;
                    data_done <= 1;
                end
                default
                begin
                    data_state <= DATA_ARRANGE_IDLE;
                    data_done <= 0;
                end
            endcase
        end
    end

    //////////////////////////////////////////////////
    //      Data Arrangement Pointer, R/W logic     //
    //////////////////////////////////////////////////
    // Declare registers
    reg r_data_shifter_start;
    always @(posedge clk)
    begin
        if(!resetn)
        begin
            pointer0 <= 0;
            pointer1 <= ROW_NUM - 1;
            r_data_addr1 <= 0;
            r_data_addr2 <= 0;
            we1 <= 0;
            we2 <= 0; 
            r_data_shifter_start <= 0;
        end
        else
        begin
            case(data_state)
                DATA_ARRANGE_IDLE:
                begin   
                    // Nothing to do
                end
                DATA_ARRANGE_START:
                begin
                    pointer0 <= 0;
                    pointer1 <= ROW_NUM - 1;
                    // Assert start sorter signal
                    r_data_shifter_start <= 1;
                    // Set read and write pointer
                    r_data_addr1 <= r_data_addr1;
                    r_data_addr2 <= r_data_addr2;
                    // Set write enable signal
                    we1 <= 0;
                    we2 <= 0;
                end
                DATA_ARRANGE_ZERO_PROCESS:
                begin
                    // Assert start sorter signal
                    r_data_shifter_start <= 0;
                    // Set read pointer signal
                    if(r_data_addr1 < mixed_pointer)
                    begin
                        r_data_addr1 <= r_data_addr1 + 1;
                    end
                    else
                    begin 
                        r_data_addr1 <= ROW_NUM - 1;
                    end

                    if (w_shifter_valid)
                    begin
                        // Set write pointer signal
                        if (r_data_addr2 < (ROW_NUM - 1))
                        begin
                            r_data_addr2 <= r_data_addr2 + 1;
                        end
                        else
                        begin
                            r_data_addr2 <= r_data_addr2;
                        end
                        // Set write enable signal
                        we1 <= 0;
                        we2 <= 1;
                    end
                    else
                    begin
                        r_data_addr2 <= r_data_addr2;
                        // Set write enable signal
                        we1 <= 0;
                        we2 <= 0;
                    end
                end
                DATA_ARRANGE_ONE_PROCESS:
                begin
                    // Assert start sorter signal
                    r_data_shifter_start <= 0;
                    // Set read pointer signal
                        if(r_data_addr1 == mixed_pointer + 1)
                        begin
                            r_data_addr1 <= r_data_addr1;
                        end
                        else
                        begin 
                            r_data_addr1 <= r_data_addr1 - 1;
                        end

                    if (w_shifter_valid)
                    begin
                        // Set write pointer signal
                        if (r_data_addr2 < (ROW_NUM - 1))
                        begin
                            r_data_addr2 <= r_data_addr2 + 1;
                        end
                        else
                        begin
                            r_data_addr2 <= r_data_addr2;
                        end
                        // Set write enable signal
                        we1 <= 0;
                        we2 <= 1;
                    end
                    else
                    begin
                        r_data_addr2 <= r_data_addr2;
                        // Set write enable signal
                        we1 <= 0;
                        we2 <= 0;
                    end

                    
                end
                DATA_ARRANGE_DONE:
                begin
                    // Reset read and write pointer
                    r_data_addr1 <= 0;
                    r_data_addr2 <= 0;
                    // Set write enable signal
                    we1 <= 0;
                    we2 <= 0;
                    // Set pointer address
                    mixed_pointer <= pointer0;
                    pointer0 <= 0;
                    pointer1 <= ROW_NUM - 1;
                end
                default:
                begin
                    // Reset read and write pointer
                    r_data_addr1 <= 0;
                    r_data_addr2 <= 0;
                    // Set write enable signal
                    we1 <= 0;
                    we2 <= 0;
                    // Set pointer address
                    pointer0 <= 0;
                    pointer1 <= ROW_NUM - 1;
                end
            endcase
        end
    end


    ///////////////////////////////////////
    //      Assign Value to Ports        //
    ///////////////////////////////////////
    assign addr1 = (state == FIRST_DIGIT) ? r_first_addr1 : (state == EVEN_DIGIT) ? r_even_addr1 : (state == ODD_DIGIT) ? r_odd_addr1 : (state == DATA_REARRANGE) ? r_data_addr1 : r_first_addr1;
    assign addr2 = (state == FIRST_DIGIT) ? r_first_addr2 : (state == EVEN_DIGIT) ? r_even_addr2 : (state == ODD_DIGIT) ? r_odd_addr2 : (state == DATA_REARRANGE) ? r_data_addr2 : r_first_addr2;   
    assign wen1 = (state == DATA_REARRANGE) ? w_shifter_valid : we1;
    assign wen2 = (state == DATA_REARRANGE) ? w_shifter_valid : we2;

    always @(*) 
    begin
        case (state)
            FIRST_DIGIT:
            begin
                if (first_state == FIRST_DONE)
                begin
                    data_out <= first_sorted_cache[1];
                end
                else
                begin
                    data_out <= first_sorted_cache[0];
                end
            end
            EVEN_DIGIT:
            begin
                if (even_state == EVEN_DONE)
                begin
                    data_out <= even_sorted_cache[1];
                end
                else
                begin
                    data_out <= even_sorted_cache[0];
                end
            end
            ODD_DIGIT:
            begin
                if (odd_state == ODD_DONE)
                begin
                    data_out <= odd_sorted_cache[1];
                end
                else
                begin
                    data_out <= odd_sorted_cache[0];
                end
            end
            DATA_REARRANGE:
            begin
                data_out <= w_shifter_cache_data;
            end
            default:
            begin
                data_out <= 128'd0;
            end
        endcase    
    end

endmodule

