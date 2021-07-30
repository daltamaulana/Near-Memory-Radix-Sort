`timescale 1 ns / 1 ps

module bram_dram_mover_v1_0_S00_AXIS
    // Declare parameter
    #(
        // AXI4Stream sink: Data Width
		parameter integer C_S_AXIS_TDATA_WIDTH	= 128
    )
    // Declare ports
    (
        // Users to add ports here
		input wire I_STREAM_DEQUEUE,
		output wire O_STREAM_VALID,
		output wire [127:0] O_STREAM_FIFO,
		output wire O_STREAM_EMPTY,
		output wire [7:0] O_FSM_STREAM_SLAVE,

		// Debug Port
		input wire [31:0] I_STREAM_DEBUG_ADDR,
		output wire [127:0] O_STREAM_FIFO_INPUT_DEBUG,
		output wire [1:0] O_FIFO_STATUS,

		// User ports ends
		// Do not modify the ports beyond this line

		// AXI4Stream sink: Clock
		input wire  S_AXIS_ACLK,
		// AXI4Stream sink: Reset
		input wire  S_AXIS_ARESETN,
		// Ready to accept data in
		output wire  S_AXIS_TREADY,
		// Data in
		input wire [C_S_AXIS_TDATA_WIDTH-1 : 0] S_AXIS_TDATA,
		// Byte qualifier
		input wire [(C_S_AXIS_TDATA_WIDTH/8)-1 : 0] S_AXIS_TSTRB,
		// Indicates boundary of last packet
		input wire  S_AXIS_TLAST,
		// Data is in valid
		input wire  S_AXIS_TVALID
    );

    ///////////////////////////////
	//      Local Parameter      //
	///////////////////////////////
	// Define the states of state machine
    localparam [1:0] IDLE = 2'h0,
					 STREAM_FIFO = 2'h1,
					 FIFO_FULL = 2'h2;

	//////////////////////////////
    //        FSM Signal        //              
	//////////////////////////////
	// State variable
	reg [1:0] r_mst_exec_state;

	//////////////////////////////
    //       Queue Signal       //
	//////////////////////////////
	wire w_stream_fifo_write_enable;
	wire w_queue_full;
    wire w_almost_full;
	wire w_queue_empty;

    ////////////////////////////////
    //        Main Logic        ////
	////////////////////////////////
    //----------------------------//
    // Stream FIFO control signal //
    //----------------------------//
    assign w_stream_fifo_write_enable = S_AXIS_TVALID && S_AXIS_TREADY && !w_queue_full;
    assign O_STREAM_EMPTY = w_queue_empty;

    //----------------------------//
    //      AXI stream logic      //
    //----------------------------//
    assign S_AXIS_TREADY = (r_mst_exec_state == STREAM_FIFO) && !w_queue_full;
    //----------------------------//

    //----------------------------------//
    // FIFO control state machine logic //
    //----------------------------------//
    always @(posedge S_AXIS_ACLK) 
    begin
        if (!S_AXIS_ARESETN)
        begin
            r_mst_exec_state <= IDLE;        
        end    
        else
        begin
            case (r_mst_exec_state)
                IDLE:
                begin
                    if (S_AXIS_TVALID == 1'b1)
                    begin
                        r_mst_exec_state <= STREAM_FIFO;
                    end
                    else
                    begin
                        r_mst_exec_state <= IDLE;     
                    end
                end
                STREAM_FIFO:
                begin
                    if (w_queue_full)
                    begin
                        r_mst_exec_state <= FIFO_FULL;    
                    end
                    else
                    begin
                        if (S_AXIS_TVALID == 1'b1)
                        begin
                            r_mst_exec_state <= STREAM_FIFO;
                        end
                        else
                        begin
                            r_mst_exec_state <= IDLE;
                        end
                    end
                end
                FIFO_FULL:
                begin
                    if (w_queue_full)
                    begin
                        r_mst_exec_state <= FIFO_FULL;     
                    end
                    else
                    begin
                        if (S_AXIS_TVALID == 1'b1)
                        begin
                            r_mst_exec_state <= STREAM_FIFO;
                        end
                        else
                        begin
                            r_mst_exec_state <= IDLE;
                        end
                    end
                end
                default:
                begin
                    r_mst_exec_state <= IDLE;
                end
            endcase
        end
    end

    //////////////////////////////////////
    //        Instantiate module        //
    //////////////////////////////////////
    stream_queue_in input_stream_queue_unit (
        // Input ports
        .I_CLK(S_AXIS_ACLK),
        .I_RSTN(S_AXIS_ARESETN),
        .I_QUEUE(w_stream_fifo_write_enable),
        .I_DEQUEUE(I_STREAM_DEQUEUE),
        .I_DATA(S_AXIS_TDATA),

        // Out ports
        .O_EMPTY(w_queue_empty),
		.O_ALMOST_FULL(w_almost_full),
        .O_FULL(w_queue_full),
		.O_DATA_VALID(O_STREAM_VALID),
        .O_DATA(O_STREAM_FIFO),

        // Debug Ports
        .I_DEBUG_ADDR(I_STREAM_DEBUG_ADDR[9:0]),
        .O_DEBUG_DATA(O_STREAM_FIFO_INPUT_DEBUG)
    );

    //-------------------------------------------------//
    //           Received Data Counter Logic           //
    //-------------------------------------------------//
    // Declare registers
    reg r_queue_empty_delay;
    reg [31:0] r_received_data_counter;

    // Counter logic
    always @(posedge S_AXIS_ACLK) 
    begin
        if (!S_AXIS_ARESETN || ((r_received_data_counter != 0) && w_queue_empty && r_queue_empty_delay))
        begin
            r_received_data_counter <= 0;
        end    
        else
        begin
            if (w_stream_fifo_write_enable)
            begin
                r_received_data_counter <= r_received_data_counter + 4; 
            end
            else
            begin
                r_received_data_counter <= r_received_data_counter;
            end
        end
        r_queue_empty_delay <= w_queue_empty;
    end

    //----------------------------------//
    //           Debug Signal           //
    //----------------------------------//
    assign O_FSM_STREAM_SLAVE = {6'd0, r_mst_exec_state};
    assign O_FIFO_STATUS = {O_STREAM_FIFO, w_queue_full};

endmodule
