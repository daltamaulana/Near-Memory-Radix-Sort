//**********************************************************************************
//                      [ MODULE ]
//
// Institution       : Korea Advanced Institute of Science and Technology (KAIST)
// Engineer          : Dalta Imam Maulana
//
// Project Name      : Near Memory Radix Sort
//
// Create Date       : 06/18/2021
// File Name         : data_shifter.v
// Module Dependency : -
//
// Target Device     : ZCU-104
// Tool Version      : Vivado 2020.1
//
// Description:
//       Module which performs data rearrangement for mixed row data
//
//**********************************************************************************

module data_shifter
    // Declare parameter
    #(
        parameter DWIDTH = 128,
        parameter DATABRAMDEPTH =65536,
        parameter ADDRWIDTH = 17
    )
    // Declare ports
    (
        // Input ports
        input wire I_ACLK,
        input wire I_ARESETN,
        input wire I_START,
        input wire I_DATA_FLAG,
        input wire I_FIRST_ROW,
        input wire [2:0] I_DATA_PATTERN,
        input wire [ADDRWIDTH:0] I_ZERO_COUNT,
        input wire [ADDRWIDTH:0] I_ONE_COUNT,
        input wire [DWIDTH-1:0] I_BRAM_DATA,

        // Output ports
        output wire O_VALID,
        output wire [DWIDTH-1:0] O_CACHE_DATA
    );

    ////////////////////////////////////////
	//     Start and Done Signal Logic    //
	////////////////////////////////////////
    // Declare register and wires
    reg r_start_delay;
    wire w_start_pulse;
    
    // Start signal logic
    always @(posedge I_ACLK) 
    begin
        r_start_delay <= I_START;
    end
    // Start pulse generation
    assign w_start_pulse = I_START && !r_start_delay;

    ////////////////////////////////
	//     State Machine Logic    //
	////////////////////////////////
    // Declare local parameters
    localparam [2:0] IDLE = 3'd0,
                     BYPASS_DATA = 3'd1,
                     INIT_FETCH = 3'd2,
                     INIT_ARRANGE = 3'd3,
                     MID_ARRANGE = 3'd4,
                     LAST_ARRANGE = 3'd5,
                     NO_ARRANGE = 3'd6,
                     DONE = 3'd7;

    // Declare register
    reg [2:0] r_state_machine;

    // Main logic 
    always @(posedge I_ACLK)
    begin
        if (!I_ARESETN)
        begin
            r_state_machine <= IDLE;
        end 
        else
        begin
            case (r_state_machine)
                IDLE:
                begin
                    if (w_start_pulse)
                    begin
                        r_state_machine <= BYPASS_DATA;
                    end
                end
                BYPASS_DATA:
                begin
                    if (I_FIRST_ROW)
                    begin
                        if (r_data_counter < (I_ZERO_COUNT + I_ONE_COUNT))
                        begin
                            r_state_machine <= BYPASS_DATA;
                        end
                        else
                        begin
                            r_state_machine <= IDLE;
                        end 
                    end
                    else
                    begin
                        if (r_data_counter < I_ZERO_COUNT - 1)
                        begin
                            r_state_machine <= BYPASS_DATA;
                        end
                        else
                        begin
                            r_state_machine <= INIT_FETCH;
                        end
                    end
                end
                INIT_FETCH:
                begin
                    if (r_data_counter < (I_ZERO_COUNT + I_ONE_COUNT))
                    begin
                        r_state_machine <= INIT_ARRANGE;
                    end
                    else
                    begin
                        r_state_machine <= NO_ARRANGE;
                    end
                end
                INIT_ARRANGE:
                begin
                    if (r_data_counter < (I_ZERO_COUNT + I_ONE_COUNT))
                    begin
                        r_state_machine <= MID_ARRANGE;
                    end
                    else
                    begin
                        r_state_machine <= LAST_ARRANGE;
                    end
                end
                MID_ARRANGE:
                begin
                    if (r_data_counter < (I_ZERO_COUNT + I_ONE_COUNT))
                    begin
                        r_state_machine <= MID_ARRANGE;
                    end
                    else
                    begin
                        r_state_machine <= LAST_ARRANGE;
                    end
                end
                LAST_ARRANGE:
                begin
                    r_state_machine <= IDLE;
                end
                NO_ARRANGE:
                begin
                    r_state_machine <= IDLE;
                end
                default:
                begin
                    r_state_machine <= IDLE;    
                end
            endcase
        end   
    end

    ///////////////////////////////
	//     Data Shifter Logic    //
	///////////////////////////////
    // Declare local parameters
    localparam [1:0] NO_SHIFT = 2'd0,
                     SHIFT_ONE = 2'd1,
                     SHIFT_TWO = 2'd2,
                     SHIFT_THREE= 2'd3;
    
    // Declare register and genvar
    integer idx;
    reg [2:0] r_data_pattern;
    reg [DWIDTH-1:0] r_data_cache[0:1];

    // Assign value to output port
    assign O_CACHE_DATA = r_data_cache[0];

    // Main logic
    always @(posedge I_ACLK) 
    begin
        if (!I_ARESETN)
        begin
            for (idx=0; idx<2; idx=idx+1)
            begin
                r_data_cache[idx] <= 0;
            end
        end
        else
        begin
            case (r_state_machine)
                IDLE:
                begin
                    for (idx=0; idx<2; idx=idx+1)
                    begin
                        r_data_cache[idx] <= 0;
                    end
                end
                BYPASS_DATA:
                begin
                    r_data_cache[0] <= I_BRAM_DATA;
                    r_data_cache[1] <= r_data_cache[1];
                end
                INIT_FETCH:
                begin
                    r_data_cache[0] <= I_BRAM_DATA;
                    r_data_cache[1] <= r_data_cache[1];
                end
                INIT_ARRANGE:
                begin
                    case (I_DATA_PATTERN)
                        3'd0:
                        begin
                            r_data_cache[0] <= I_BRAM_DATA;
                            r_data_cache[1] <= r_data_cache[0];
                        end
                        3'd1:
                        begin
                            if (I_DATA_FLAG)
                            begin
                                r_data_cache[0] <= {I_BRAM_DATA[95:0], r_data_cache[0][127:96]};
                                r_data_cache[1] <= {r_data_cache[0][95:0], I_BRAM_DATA[127:96]};
                            end 
                            else
                            begin
                                r_data_cache[0] <= {I_BRAM_DATA[95:0], r_data_cache[0][31:0]};
                                r_data_cache[1] <= {r_data_cache[0][127:32], I_BRAM_DATA[127:96]};
                            end   
                        end
                        3'd2:
                        begin
                            if (I_DATA_FLAG)
                            begin
                                r_data_cache[0] <= {I_BRAM_DATA[63:0], r_data_cache[0][127:64]};
                                r_data_cache[1] <= {r_data_cache[0][63:0], I_BRAM_DATA[127:64]};   
                            end 
                            else
                            begin
                                r_data_cache[0] <= {I_BRAM_DATA[63:0], r_data_cache[0][63:0]};
                                r_data_cache[1] <= {r_data_cache[0][127:64], I_BRAM_DATA[127:64]};
                            end
                        end
                        3'd3:
                        begin
                            if (I_DATA_FLAG)
                            begin
                                r_data_cache[0] <= {I_BRAM_DATA[31:0], r_data_cache[0][127:32]};
                                r_data_cache[1] <= {r_data_cache[0][31:0], I_BRAM_DATA[127:32]};
                            end 
                            else
                            begin
                                r_data_cache[0] <= {I_BRAM_DATA[31:0], r_data_cache[0][95:0]};
                                r_data_cache[1] <= {r_data_cache[0][127:96], I_BRAM_DATA[127:32]};
                            end
                        end
                        3'd4:
                        begin
                            r_data_cache[0] <= r_data_cache[0];
                            r_data_cache[1] <= I_BRAM_DATA;
                        end
                        default:
                        begin
                            r_data_cache[0] <= r_data_cache[0];
                            r_data_cache[1] <= r_data_cache[1];
                        end
                    endcase
                end
                MID_ARRANGE:
                begin
                    case (I_DATA_PATTERN)
                        3'd0:
                        begin
                            r_data_cache[0] <= I_BRAM_DATA;
                            r_data_cache[1] <= r_data_cache[1];
                        end
                        3'd1:
                        begin
                            r_data_cache[0] <= {I_BRAM_DATA[95:0], r_data_cache[1][31:0]};
                            r_data_cache[1] <= {r_data_cache[1][127:32], I_BRAM_DATA[127:96]};
                        end
                        3'd2:
                        begin
                            r_data_cache[0] <= {I_BRAM_DATA[63:0], r_data_cache[1][63:0]};
                            r_data_cache[1] <= {r_data_cache[1][127:64], I_BRAM_DATA[127:64]};
                        end
                        3'd3:
                        begin
                            r_data_cache[0] <= {I_BRAM_DATA[31:0], r_data_cache[1][95:0]};
                            r_data_cache[1] <= {r_data_cache[1][127:96], I_BRAM_DATA[127:32]};
                        end
                        3'd4:
                        begin
                            r_data_cache[0] <= r_data_cache[1];
                            r_data_cache[1] <= I_BRAM_DATA;
                        end
                        default:
                        begin
                            r_data_cache[0] <= r_data_cache[0];
                            r_data_cache[1] <= r_data_cache[1];
                        end
                    endcase
                end
                LAST_ARRANGE:
                begin
                    r_data_cache[0] <= r_data_cache[1];
                    r_data_cache[1] <= r_data_cache[1];
                end
                NO_ARRANGE:
                begin
                    r_data_cache[0] <= I_BRAM_DATA;
                    r_data_cache[1] <= r_data_cache[1];
                end
                default:
                begin
                    for (idx=0; idx<2; idx=idx+1)
                    begin
                        r_data_cache[idx] <= r_data_cache[idx];
                    end
                end
            endcase
        end
    end

    // Sample count data
    always @(posedge I_ACLK) 
    begin
        if (!I_ARESETN)
        begin
            r_data_pattern <= 0;
        end 
        else
        begin
            if (r_state_machine == IDLE)
            begin
                r_data_pattern <= 0;
            end
            else if (r_state_machine == INIT_FETCH)
            begin
                r_data_pattern <= I_DATA_PATTERN;
            end
            else
            begin
                r_data_pattern <= r_data_pattern;
            end
        end   
    end

    ///////////////////////////////
	//     Data Counter Logic    //
	///////////////////////////////
    // Declare registers
    reg [ADDRWIDTH:0] r_data_counter;

    // Main logic
    always @(posedge I_ACLK) 
    begin
        if (!I_ARESETN)
        begin
            r_data_counter <= 0;
        end
        else
        begin
            case (r_state_machine)
                IDLE:
                begin
                    r_data_counter <= 0;
                end
                BYPASS_DATA:
                begin
                    r_data_counter <= r_data_counter + 1;
                end
                INIT_FETCH:
                begin
                    r_data_counter <= r_data_counter + 1;
                end
                INIT_ARRANGE:
                begin
                    r_data_counter <= r_data_counter + 1;
                end
                MID_ARRANGE:
                begin
                    r_data_counter <= r_data_counter + 1;
                end
                LAST_ARRANGE:
                begin
                    r_data_counter <= r_data_counter + 1;
                end
                NO_ARRANGE:
                begin
                    r_data_counter <= r_data_counter + 1;
                end
                default:
                begin
                    r_data_counter <= r_data_counter;
                end
            endcase            
        end
    end

    /////////////////////////////
	//     Data Valid Logic    //
	/////////////////////////////
    // Declare register
    reg r_data_valid;
    reg r_data_valid_delayed;

    // Assign value to output port
    assign O_VALID = r_data_valid_delayed;

    // Main logic
    always @(r_state_machine) 
    begin
        case (r_state_machine)
            IDLE:
            begin
                r_data_valid <= 0;
            end
            BYPASS_DATA:
            begin
                r_data_valid <= 1;
            end
            INIT_FETCH:
            begin
                if (I_ZERO_COUNT == (DATABRAMDEPTH-1))
                begin
                    r_data_valid <= 1;  
                end
                else
                begin
                    r_data_valid <= 0; 
                end
            end
            INIT_ARRANGE:
            begin
                r_data_valid <= 1;
            end
            MID_ARRANGE:
            begin
                r_data_valid <= 1;
            end
            LAST_ARRANGE:
            begin
                r_data_valid <= 1;
            end
            NO_ARRANGE:
            begin
                r_data_valid <= 0;
            end
            default:
            begin
                r_data_valid <= 0;
            end
        endcase
    end

    // Delay data valid
    always @(posedge I_ACLK) 
    begin
        r_data_valid_delayed <= r_data_valid;    
    end



endmodule