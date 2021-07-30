`timescale 1ns / 1ps

module radix_sort_accelerator_v1_0_M00_AXIS
    // Declare parameters
    #(
		// User parameter
        // FIFO Address bit
		parameter integer FIFO_ADDR_BIT	= 10,
        // AXI Parameter
		// Width of S_AXIS address bus. The slave accepts the read and write addresses of width C_M_AXIS_TDATA_WIDTH.
		parameter integer C_M_AXIS_TDATA_WIDTH	= 128
	)
    // Declare ports
	(
		//////////////////////////////
        //        User Ports        //              
	    //////////////////////////////
		// Signal for storing data to FIFO
		input wire 	I_FIFO_IN_QUEUE,
		input wire 	[C_M_AXIS_TDATA_WIDTH-1:0] I_FIFO_IN_DATA,
		output wire O_FIFO_ALMOST_FULL,
		output wire O_FIFO_OUT_FULL,
        // FSM Signal
		input wire [31:0] I_NO_OF_TRANSACTION,
		output wire [7:0] O_FSM_STREAM_MASTER,
		output wire O_DATA_SEND_DONE,
		// Debug signal
		output wire [1:0] O_FIFO_STATUS,

		//////////////////////////////
        //         AXI Ports        //              
	    //////////////////////////////
		// Global ports
		input wire  M_AXIS_ACLK,
		input wire  M_AXIS_ARESETN,
		// Master Stream Ports. TVALID indicates that the master is driving a valid transfer, A transfer takes place when both TVALID and TREADY are asserted.
		output wire  M_AXIS_TVALID,
		// TDATA is the primary payload that is used to provide the data that is passing across the interface from the master.
		output wire [C_M_AXIS_TDATA_WIDTH-1 : 0] M_AXIS_TDATA,
		// TSTRB is the byte qualifier that indicates whether the content of the associated byte of TDATA is processed as a data byte or a position byte.
		output wire [(C_M_AXIS_TDATA_WIDTH/8)-1 : 0] M_AXIS_TSTRB,
		// TLAST indicates the boundary of a packet.
		output wire  M_AXIS_TLAST,
		// TREADY indicates that the slave can accept a transfer in the current cycle.
		input wire  M_AXIS_TREADY
	);

    ///////////////////////////////
	//      Local Parameter      //
	///////////////////////////////
    // Define state of state machine
    localparam [1:0] IDLE = 2'b00,      // This is the initial/idle state
	                 WAIT_FIFO  = 2'b01, // State for waiting counter to reach C_M_START_COUNT
	                 SEND_STREAM   = 2'b10; // State for sending stream data through output port

    //////////////////////////////
    //        FSM Signal        //
	//////////////////////////////
    // State variable
	reg [1:0] r_mst_exec_state;
	// Number of data sent
	reg [31:0] r_no_data_sent;
	reg r_reset_counter;

    //////////////////////////////
    //       AXIS Signal        //
	//////////////////////////////
    // AXIS data valid signal
    reg r_axis_tvalid;
	// AXIS last data signal
	wire w_axis_tlast;
    // Delayed AXIS tready signal
	reg r_axis_tready_delayed;
	// Stream data out
    reg [C_M_AXIS_TDATA_WIDTH-1 : 0] r_stream_data_out;
	// Transaction enable signal
    wire w_tx_en;
	reg r_tx_en_delayed;
	// Master has sent all data stored in FIFO
	wire w_tx_done;

    //////////////////////////////
    //        FIFO Signal       //
	//////////////////////////////
    wire w_fifo_in_dequeue;
    wire w_fifo_out_data_valid;
	wire [127:0] w_fifo_out_data;
	wire w_fifo_out_empty;
	reg r_fifo_out_empty_delayed;
	wire w_fifo_not_empty_delayed = !r_fifo_out_empty_delayed;
    wire [127:0] w_debug_data;

    //////////////////////////////
    //        DMA Signal        //
	//////////////////////////////
    reg [127:0] r_fix_bug_reg;
	reg [9:0] r_fix_bug_reg_index;

    reg [9:0] r_data_index_valid;
	wire [9:0] w_data_index;

	wire w_data_valid;
	wire w_backup_data_valid;
	reg r_dma_stall;

    /////////////////////////////////
    //     State Machine Logic     //
	/////////////////////////////////
    always @(posedge M_AXIS_ACLK)
	begin
        // Synchronous reset
        if (!M_AXIS_ARESETN)
        begin
            r_mst_exec_state <= IDLE;
            r_reset_counter <= 0;
        end
        else
        begin
            case (r_mst_exec_state)
                // Idle state
                IDLE:
                begin
                    r_mst_exec_state <= WAIT_FIFO;
                    r_reset_counter <= 1;
                end
                WAIT_FIFO:
                begin
                    // AXIS master will start sending data when FIFO is not empty
                    // and slave will start to accept data when tvalid is asserted
                    // by AXIS master
                    if (w_fifo_not_empty_delayed)
                    begin
                        r_mst_exec_state  <= SEND_STREAM;
                        r_reset_counter <= 0;
                    end
                    else
                    begin
                        r_mst_exec_state  <= WAIT_FIFO;
                        r_reset_counter <= 0;
                    end
                end
                SEND_STREAM:
                begin
                    // The example design streaming master functionality starts
                    // when the master drives output tdata from the FIFO and the slave
                    // has finished storing the S_AXIS_TDATA
                    if (w_tx_done)
                    begin
                        r_mst_exec_state <= IDLE;
                        r_reset_counter <= 0;
                    end
                    else
                    begin
                        r_mst_exec_state <= SEND_STREAM;
                        r_reset_counter <= 0;
                    end
                end
            endcase
        end
	end

    /////////////////////////////////
    //      AXIS Signal Logic      //
	/////////////////////////////////
    //----------------------------------//
    //     tvalid signal generation     //
    //----------------------------------//
    // axis_tvalid signal is asserted whenever FSM state is SEND_STREAM
    // and number of output streaming data is less than NO_OF_TRANSACTION
    always @(*) 
    begin
        if (r_mst_exec_state == SEND_STREAM)
        begin
            r_axis_tvalid <= w_data_valid || w_backup_data_valid;
        end
        else
        begin
            r_axis_tvalid <= 0;
        end
    end

    //----------------------------------//
    //     tlast signal generation      //
    //----------------------------------//
    // axis_tlast signal is asserted when number of output streaming data
    // is equal to NO_OF_TRANSACTION-1
    assign w_axis_tlast = (r_no_data_sent == (I_NO_OF_TRANSACTION-1)) && r_axis_tvalid;

    /////////////////////////////////
    //     Data transfer Logic     //
	/////////////////////////////////
    // Generate transaction enable signal
    assign w_tx_en = M_AXIS_TREADY && r_axis_tvalid;
    // Generate transaction done signal
    assign w_tx_done = w_axis_tlast && w_tx_en;

    // Delay transaction enable and ready signal to match M_AXIS_DATA latency
    always @(posedge M_AXIS_ACLK) 
    begin
        if (!M_AXIS_ARESETN)
        begin
            r_tx_en_delayed <= 1'b0;
            r_axis_tready_delayed <= 1'b0;
        end
        else
        begin
            r_tx_en_delayed <= w_tx_en;
            r_axis_tready_delayed <= M_AXIS_TREADY;
        end
    end

    // Calculate number of data sent
    always @(posedge M_AXIS_ACLK) 
    begin
        if (!M_AXIS_ARESETN || r_reset_counter)
        begin
            r_no_data_sent <= 0;
        end
        else
        begin
            if (r_no_data_sent <= (I_NO_OF_TRANSACTION-1))
            begin
                if (w_tx_en)
                begin
                    r_no_data_sent <= r_no_data_sent + 1;
                end
                else
                begin
                    r_no_data_sent <= r_no_data_sent;
                end
            end
            else
            begin
                r_no_data_sent <= r_no_data_sent;
            end
        end
    end

    //----------------------------------//
    //        DMA bug fix logic         //
    //----------------------------------//
    // Logic for fixing bug in DMA data transfer
    // Store last data in register for next transfer
    always @(posedge M_AXIS_ACLK) 
    begin
        if (!M_AXIS_ARESETN)
        begin
            r_fix_bug_reg <= 128'd0;
        end    
        else
        begin
            if (!M_AXIS_TREADY && r_axis_tready_delayed)
            begin
                r_fix_bug_reg <= w_fifo_out_data;
            end
            else
            begin
                r_fix_bug_reg <= r_fix_bug_reg;
            end
        end
    end

    // Store last data index in register
    always @(posedge M_AXIS_ACLK) 
    begin
        if (!M_AXIS_ARESETN)
        begin
            r_fix_bug_reg_index <= 128'd0;
        end    
        else
        begin
            if (!M_AXIS_TREADY && r_axis_tready_delayed)
            begin
                r_fix_bug_reg_index <= w_data_index;
            end
            else
            begin
                r_fix_bug_reg_index <= r_fix_bug_reg_index;
            end
        end
    end

    /////////////////////////////////
    //       FIFO data Logic       //
	/////////////////////////////////
    //--------------------------------------//
    //    Output stream selection logic     //
    //--------------------------------------//
    always @(*) 
    begin
        if (w_backup_data_valid && !w_data_valid)
        begin
            r_stream_data_out <= r_fix_bug_reg;
        end    
        else
        begin
            r_stream_data_out <= w_fifo_out_data;
        end
    end

    //--------------------------------------//
    //        FIFO empty delay logic        //
    //--------------------------------------//
    always @(posedge M_AXIS_ACLK) 
    begin
        if (!M_AXIS_ARESETN)
        begin
            r_fifo_out_empty_delayed <= 1'b0;
        end 
        else
        begin
            r_fifo_out_empty_delayed <= w_fifo_out_empty;
        end   
    end

    //--------------------------------------//
    //        FIFO dequeueing logic         //
    //--------------------------------------//
    assign w_fifo_in_dequeue = (r_mst_exec_state == SEND_STREAM) && M_AXIS_TREADY;

    //--------------------------------------//
    //          Data valid logic            //
    //--------------------------------------//
    assign w_data_valid = ((w_data_index == r_data_index_valid) && !r_fifo_out_empty_delayed);
    assign w_backup_data_valid = ((w_data_index != r_data_index_valid) && (r_data_index_valid == r_fix_bug_reg_index));

    //--------------------------------------//
    //       Data index valid logic         //
    //--------------------------------------//
    always @(posedge M_AXIS_ACLK) 
    begin
        if (!M_AXIS_ARESETN)
        begin
            r_data_index_valid <= 0;
        end    
        else
        begin
            if (M_AXIS_TREADY && M_AXIS_TVALID)
            begin
                if (r_data_index_valid < 1023)
                begin
                    r_data_index_valid <= r_data_index_valid + 1;
                end
                else
                begin
                    r_data_index_valid <= 0;
                end
            end
            else
            begin
                r_data_index_valid <= r_data_index_valid;
            end
        end
    end

    /////////////////////////////////
    //       DMA Stall Logic       //
	/////////////////////////////////
    always @(posedge M_AXIS_ACLK) 
    begin
        if (!M_AXIS_ARESETN || w_tx_done)
        begin
            r_dma_stall <= 0;
        end    
        else
        begin
            if (!M_AXIS_TREADY && r_axis_tready_delayed)
            begin
                r_dma_stall <= 1;
            end
            else if (M_AXIS_TREADY && ! r_axis_tready_delayed)
            begin
                r_dma_stall <= 0;
            end
            else
            begin
                r_dma_stall <= r_dma_stall;
            end
        end 
    end

    /////////////////////////////////
    //    Module Instantiation     //
	/////////////////////////////////
    // Stream queue module
    stream_queue_out out_data_fifo
    (
        // Input ports
        .I_CLK(M_AXIS_ACLK),
        .I_RSTN(M_AXIS_ARESETN),
        .I_QUEUE(I_FIFO_IN_QUEUE),
        .I_DEQUEUE(w_fifo_in_dequeue),
        .I_DATA(I_FIFO_IN_DATA),

        // Output ports
        .O_EMPTY(w_fifo_out_empty),
        .O_ALMOST_FULL(O_FIFO_ALMOST_FULL),
        .O_FULL(O_FIFO_OUT_FULL),
        .O_DATA_VALID(w_fifo_out_data_valid),
        .O_DATA(w_fifo_out_data),
        .O_DATA_INDEX(w_data_index),

        // Debug Ports
        .I_DEBUG_ADDR(10'd0),
        .O_DEBUG_DATA(w_debug_data)
    );

    ///////////////////////////////
    //   Port Value Assignment   //
	///////////////////////////////
    // AXIS ports
    assign M_AXIS_TVALID = r_axis_tvalid;
	assign M_AXIS_TDATA	 = r_stream_data_out;
	assign M_AXIS_TLAST	 = w_axis_tlast;
	assign M_AXIS_TSTRB	 = {(C_M_AXIS_TDATA_WIDTH/8){1'b1}};
    // Other ports
    assign O_FSM_STREAM_MASTER = {6'd0, r_mst_exec_state};
    assign O_DATA_SEND_DONE = w_tx_done;
    assign O_FIFO_STATUS = {w_fifo_out_empty, O_FIFO_OUT_FULL};

endmodule
