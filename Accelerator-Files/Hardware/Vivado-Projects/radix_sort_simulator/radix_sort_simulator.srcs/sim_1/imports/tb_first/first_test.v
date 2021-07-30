module top_first
#(
    parameter DWIDTH = 32,
    parameter DWIDTH_LOG2 = 5,
    parameter ROW_WIDTH = 128,
    parameter ROW_NUM = 1024,
    parameter ADDR_BIT = 10

)
(   
    input wire clk,
    input wire resetn,
    input wire first_start,
    input wire [ROW_WIDTH-1:0] data_in1,
    input wire [ROW_WIDTH-1:0] data_in2,
    output wire [ROW_WIDTH-1:0] data_out,
    output wire [ADDR_BIT-1:0] addr1, addr2,
    output reg we1, we2,
    output wire done

);
    ///////////////////////////////
	//     Instantiate Module    //
	///////////////////////////////
    // Declare registers and wires
    // Sorting unit
    reg [ROW_WIDTH-1:0] unsorted_cache [1:0];
    reg [ROW_WIDTH-1:0] sorted_cache [1:0];
    wire [2*ROW_WIDTH-1:0] unsorted_array;
    wire [2*ROW_WIDTH-1:0] sorted_array;
    wire row_idx;
    // Data shifter
    reg r_shifter_start;
    wire w_shifter_data_flag;
    wire w_shifter_first_row;
    wire [2:0] w_shifter_data_pattern;
    wire [ADDR_BIT-1:0] w_shifter_zero_count;
    wire [ADDR_BIT-1:0] w_shifter_one_count;
    wire [ROW_WIDTH-1:0] w_shifter_bram_data;

    wire w_shifter_valid;
    wire [ROW_WIDTH-1:0] w_shifter_cache_data;

    // Assign value to wires
    // Sorting unit
    assign unsorted_array = {unsorted_cache[1],unsorted_cache[0]};   

    // Sorting unit
    sorting_unit SORTING_UNIT
    (
        .data_in(unsorted_array),
        .mask_in(32'b1),
        .data_out(sorted_array),
        .row_idx(row_idx)
    );

    // Data shifter unit
    data_shifter data_shifter_unit
    (
        // Input ports
        .I_ACLK(clk),
        .I_ARESETN(resetn),
        .I_START(r_shifter_start),
        .I_DATA_FLAG(1'b0),
        .I_FIRST_ROW(1'b1),
        .I_DATA_PATTERN(3'b000),
        .I_ZERO_COUNT(11'd1024),
        .I_ONE_COUNT(11'd0),
        .I_BRAM_DATA(data_in1),

        // Output ports
        .O_VALID(w_shifter_valid),
        .O_CACHE_DATA(w_shifter_cache_data)
    );



    ////////////////////////////////////////
	//     Start and Done Signal Logic    //
	////////////////////////////////////////
    reg r_first_delay;
    reg first_done;
    wire first_start_pulse;


    always @(posedge clk) 
    begin
        r_first_delay <= first_start;
    end
    // Start pulse generation

    assign first_start_pulse = first_start && !r_first_delay;

    /////////////////////////////////////////////////
    //             First Digit FSM                 //
    /////////////////////////////////////////////////
    // Declare registers
    reg [ADDR_BIT-1:0] first_pointer0, first_pointer1;
    reg [ADDR_BIT-1:0] mixed_pointer;
    reg [ADDR_BIT-1:0] r_addr1, r_addr2;
    reg mixed_flag;  
    reg [2:0] first_state;
    wire [ADDR_BIT-1:0] count0, count1;

    // Declare local parameters
    localparam [2:0] FIRST_IDLE = 3'd0,
                     FIRST_START_SORTER = 3'd1,
                     FIRST_FIRST_READ = 3'd2,
                     FIRST_SECOND_READ = 3'd3,
                     FIRST_WAIT_DATA = 3'd4,
                     FIRST_MIDDLE_RW = 3'd5,
                     FIRST_LAST_WRITE = 3'd6,
                     FIRST_DONE = 3'd7;

    // Assign logic to counter
    assign count0 = mixed_pointer;
    assign count1 = ROW_NUM - mixed_pointer - 1;
    
    // Main logic
    always @(posedge clk)
    begin
        if(!resetn)
        begin
            first_state <= FIRST_IDLE;
            first_done <= 0;
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
                    if(r_addr1 == 1)
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
                    if(first_pointer1 - first_pointer0 == 1)
                    begin
                        first_state <= FIRST_LAST_WRITE;
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
    always @(posedge clk)
    begin
        if(!resetn)
        begin
            first_pointer0 <= 0;
            first_pointer1 <= ROW_NUM - 1;
            r_addr1 <= 0;
            r_addr2 <= 0;
            we1 <= 0;
            we2 <= 0;
            r_shifter_start <= 0;             
        end
        else
        begin
            case(first_state)
                FIRST_IDLE:
                begin
                    // Initialize output write pointer
                    first_pointer0 <= 0;
                    first_pointer1 <= ROW_NUM - 1;          
                end
                FIRST_START_SORTER:
                begin
                    // Assert start sorter signal
                    r_shifter_start <= 1;
                    // Set read and write pointer
                    r_addr1 <= r_addr1;
                    r_addr2 <= r_addr2;
                    // Set write enable signal
                    we1 <= 0;
                    we2 <= 0;
                end
                FIRST_FIRST_READ:
                begin
                    // Assert start sorter signal
                    r_shifter_start <= 0;
                    // Set read and write pointer
                    r_addr1 <= r_addr1 + 1;
                    r_addr2 <= r_addr2;
                    // Set write enable signal
                    we1 <= 0;
                    we2 <= 0;
                end
                FIRST_SECOND_READ:
                begin
                    // Deassert start sorter signal
                    r_shifter_start <= 0;
                    // Set read and write pointer
                    r_addr1 <= r_addr1 + 1;
                    r_addr2 <= r_addr2;
                    // Set write enable signal
                    we1 <= 0;
                    we2 <= 0;
                end
                FIRST_WAIT_DATA:
                begin
                    // Deassert start sorter signal
                    r_shifter_start <= 0;
                    // Set read and write pointer
                    r_addr1 <= r_addr1 + 1;
                    r_addr2 <= r_addr2;
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
                        r_addr2 <= first_pointer0;
                        first_pointer0 <= first_pointer0 + 1; 
                    end
                    else
                    begin
                        r_addr2 <= first_pointer1;
                        first_pointer1 <= first_pointer1 - 1;
                    end
                    // Set read pointer signal
                    if(r_addr1 == ROW_NUM-1)
                    begin
                        r_addr1 <= r_addr1;
                    end
                    else
                    begin 
                        r_addr1 <= r_addr1 + 1;
                    end
                end
                FIRST_LAST_WRITE:
                begin
                    // Set read and write pointer
                    r_addr1 <= r_addr1;
                    r_addr2 <= first_pointer0;
                    // Set write enable signal
                    we1 <= 0;
                    we2 <= 1;
                end
                FIRST_DONE:
                begin
                    // Reset read and write pointer
                    r_addr1 <= 0;
                    r_addr2 <= 0;
                    // Set write enable signal
                    we1 <= 0;
                    we2 <= 0;
                    mixed_pointer <= first_pointer0;
                end
                default:
                begin
                    // Reset read and write pointer
                    r_addr1 <= 0;
                    r_addr2 <= 0;
                    // Set write enable signal
                    we1 <= 0;
                    we2 <= 0;
                end
            endcase
        end
    end

    /////////////////////////////////////////////
    //      FIRST_DIGIT  Data I/O logic        //
    /////////////////////////////////////////////    
    always @(posedge clk)
    begin
        if(!resetn)
        begin
            unsorted_cache[0] <= 0;
            unsorted_cache[1] <= 0;
            sorted_cache[0] <= 0;
            sorted_cache[1] <= 0;
        end
        else
        begin
            case(first_state)
                FIRST_IDLE:
                begin
                    unsorted_cache[0] <= unsorted_cache[0];
                    unsorted_cache[1] <= unsorted_cache[1];
                    sorted_cache[0] <= sorted_cache[0];
                    sorted_cache[1] <= sorted_cache[1];
                end
                FIRST_START_SORTER:
                begin
                    unsorted_cache[0] <= unsorted_cache[0];
                    unsorted_cache[1] <= unsorted_cache[1];
                    sorted_cache[0] <= sorted_cache[0];
                    sorted_cache[1] <= sorted_cache[1];
                end
                FIRST_FIRST_READ:
                begin
                    unsorted_cache[0] <= unsorted_cache[0];
                    unsorted_cache[1] <= unsorted_cache[1];
                end
                FIRST_SECOND_READ:
                begin
                    unsorted_cache[0] <= w_shifter_cache_data; 
                end
                FIRST_WAIT_DATA:
                begin
                    unsorted_cache[0] <= unsorted_cache[0];
                    unsorted_cache[1] <= w_shifter_cache_data;
                end
                FIRST_MIDDLE_RW:
                begin
                    unsorted_cache[0] <= sorted_array[2*ROW_WIDTH-1:ROW_WIDTH];
                    unsorted_cache[1] <= w_shifter_cache_data;
                    sorted_cache[0] <= sorted_array[ROW_WIDTH-1:0];
                    sorted_cache[1] <= sorted_array[2*ROW_WIDTH-1:ROW_WIDTH];
                end
                FIRST_LAST_WRITE:
                begin
                    unsorted_cache[0] <= sorted_array[2*ROW_WIDTH-1:ROW_WIDTH];
                    unsorted_cache[1] <= w_shifter_cache_data;
                    sorted_cache[0] <= sorted_cache[0];
                    sorted_cache[1] <= sorted_cache[1];
                end    
                FIRST_DONE:
                begin
                    unsorted_cache[0] <= 0;
                    unsorted_cache[1] <= 0;
                    sorted_cache[0] <= 0;
                    sorted_cache[1] <= 0;
                    mixed_flag <= sorted_cache[1][0];
                end
                default:
                begin
                    unsorted_cache[0] <= unsorted_cache[0];
                    unsorted_cache[1] <= unsorted_cache[1];
                    sorted_cache[0] <= sorted_cache[0];
                    sorted_cache[1] <= sorted_cache[1];
                end
            endcase
        end
    end


    ///////////////////////////////////////
    //      Assign Value to Ports        //
    ///////////////////////////////////////
    assign addr1 = r_addr1;
    assign addr2 = r_addr2;
    assign data_out = (first_state == FIRST_DONE)? sorted_cache[1] : sorted_cache[0]; 
    assign done = first_done;

    endmodule










