`timescale 1ns / 1ps

module radix_sort_accelerator_v1_0_M00_AXI_TO_DMA
    // Declare parameters
    #(
		// The master requires a target slave base address.
		parameter  C_M_TARGET_SLAVE_BASE_ADDR	= 32'h40000000,
		// Width of M_AXI address bus.
		parameter integer C_M_AXI_ADDR_WIDTH	= 32,
		// Width of M_AXI data bus.
		parameter integer C_M_AXI_DATA_WIDTH	= 32,
		// Transaction number is the number of write
		parameter integer C_M_TRANSACTIONS_NUM	= 2
	)
    // Declare ports
	(
		// Users to add ports here
		input wire [C_M_AXI_DATA_WIDTH-1:0] I_REG_ADDRESS,
		input wire [C_M_AXI_DATA_WIDTH-1:0] I_REG_DATA,
		input wire [1:0]                    I_TRANSFER_MODE,
		// Initiate AXI transactions
		input wire  I_INIT_AXI_TXN,
		output wire O_AXI_TXN_DONE,
		output wire [7:0] O_FSM_DMA_CONTROLLER,
		input wire [31:0] I_BRAM_DEBUG_ADDR,
		output wire [63:0] O_DATA_LOGGER,
		// User ports ends
		// Do not modify the ports beyond this line

		// AXI clock signal
		input wire  M_AXI_ACLK,
		// AXI active low reset signal
		input wire  M_AXI_ARESETN,
		// Master Interface Write Address Channel ports. Write address (issued by master)
		output wire [C_M_AXI_ADDR_WIDTH-1 : 0] M_AXI_AWADDR,
		// Write channel Protection type.
		output wire [2 : 0] M_AXI_AWPROT,
		// Write address valid.
		output wire  M_AXI_AWVALID,
		// Write address ready.
		input wire  M_AXI_AWREADY,
		// Master Interface Write Data Channel ports. Write data (issued by master)
		output wire [C_M_AXI_DATA_WIDTH-1 : 0] M_AXI_WDATA,
		// Write strobes.
		output wire [C_M_AXI_DATA_WIDTH/8-1 : 0] M_AXI_WSTRB,
		// Write valid. This signal indicates that valid write data and strobes are available.
		output wire  M_AXI_WVALID,
		// Write ready. This signal indicates that the slave can accept the write data.
		input wire  M_AXI_WREADY,
		// Master Interface Write Response Channel ports.
		input wire [1 : 0] M_AXI_BRESP,
		// Write response valid.
		input wire  M_AXI_BVALID,
		// Response ready. This signal indicates that the master can accept a write response.
		output wire  M_AXI_BREADY,
		// Master Interface Read Address Channel ports. Read address (issued by master)
		output wire [C_M_AXI_ADDR_WIDTH-1 : 0] M_AXI_ARADDR,
		// Protection type.
		output wire [2 : 0] M_AXI_ARPROT,
		// Read address valid.
		output wire  M_AXI_ARVALID,
		// Read address ready.
		input wire  M_AXI_ARREADY,
		// Master Interface Read Data Channel ports. Read data (issued by slave)
		input wire [C_M_AXI_DATA_WIDTH-1 : 0] M_AXI_RDATA,
		// Read response. This signal indicates the status of the read transfer.
		input wire [1 : 0] M_AXI_RRESP,
		// Read valid. This signal indicates that the channel is signaling the required read data.
		input wire  M_AXI_RVALID,
		// Read ready. This signal indicates that the master can accept the read data and response information.
		output wire  M_AXI_RREADY
	);

	// function called clogb2 that returns an integer which has the
	// value of the ceiling of the log base 2

	 function integer clogb2 (input integer bit_depth);
		 begin
		 for(clogb2=0; bit_depth>0; clogb2=clogb2+1)
			 bit_depth = bit_depth >> 1;
		 end
	 endfunction

	// TRANS_NUM_BITS is the width of the index counter for
	// number of write or read transaction.
	 localparam integer TRANS_NUM_BITS = clogb2(C_M_TRANSACTIONS_NUM-1);

	// Example State machine to initialize counter, initialize write transactions,
	// initialize read transactions and comparison of read data with the
	// written data words.
	parameter [1:0] IDLE = 2'b00, // This state initiates AXI4Lite transaction
			// after the state machine changes state to INIT_WRITE
			// when there is 0 to 1 transition on INIT_AXI_TXN
		INIT_WRITE   = 2'b01, // This state initializes write transaction,
			// once writes are done, the state machine
			// changes state to INIT_READ
		TRANSACTION_DONE = 2'b10, // This state initializes read transaction
			// once reads are done, the state machine
			// changes state to INIT_COMPARE
		INIT_READ = 2'b11; // This state issues the status of comparison
			// of the written data with the read data

	reg [1:0] mst_exec_state;
	assign O_FSM_DMA_CONTROLLER = {6'd0, mst_exec_state};
	// AXI4LITE signals
	//write address valid
	reg  	axi_awvalid;
	//write data valid
	reg  	axi_wvalid;
	//read address valid
	reg  	axi_arvalid;
	//read data acceptance
	reg  	axi_rready;
	//write response acceptance
	reg  	axi_bready;
	//write address
	reg [C_M_AXI_ADDR_WIDTH-1 : 0] 	axi_awaddr;
	//write data
	reg [C_M_AXI_DATA_WIDTH-1 : 0] 	axi_wdata;
	//read addresss
	reg [C_M_AXI_ADDR_WIDTH-1 : 0] 	axi_araddr;
	//Asserts when there is a write response error
	wire  	write_resp_error;
	//Asserts when there is a read response error
	wire  	read_resp_error;
	//A pulse to initiate a write transaction
	reg  	start_single_write;
	//A pulse to initiate a read transaction
	reg  	start_single_read;
	//Asserts when a single beat write transaction is issued and remains asserted till the completion of write trasaction.
	reg  	write_issued;
	//Asserts when a single beat read transaction is issued and remains asserted till the completion of read trasaction.
	reg  	read_issued;
	//flag that marks the completion of write trasactions. The number of write transaction is user selected by the parameter C_M_TRANSACTIONS_NUM.
	reg  	writes_done;
	//flag that marks the completion of read trasactions. The number of read transaction is user selected by the parameter C_M_TRANSACTIONS_NUM
	reg  	reads_done;
	reg  	read_mismatch;
	//index counter to track the number of write transaction issued
	reg [TRANS_NUM_BITS : 0] 	write_index;
	//index counter to track the number of read transaction issued
	reg [TRANS_NUM_BITS : 0] 	read_index;
	//Flag is asserted when the write index reaches the last write transction number
	reg  	last_write;
	//Flag is asserted when the read index reaches the last read transction number
	reg  	last_read;
	reg  	init_txn_ff;
	reg  	init_txn_ff2;
	wire  	init_txn_pulse;


	// I/O Connections assignments

	//Adding the offset address to the base addr of the slave
	assign M_AXI_AWADDR	= C_M_TARGET_SLAVE_BASE_ADDR + axi_awaddr;
	//AXI 4 write data
	assign M_AXI_WDATA	= axi_wdata;
	assign M_AXI_AWPROT	= 3'b000;
	assign M_AXI_AWVALID	= axi_awvalid;
	//Write Data(W)
	assign M_AXI_WVALID	= axi_wvalid;
	//Set all byte strobes in this example
	assign M_AXI_WSTRB	= 4'b1111;
	//Write Response (B)
	assign M_AXI_BREADY	= axi_bready;
	//Read Address (AR)
	assign M_AXI_ARADDR	= C_M_TARGET_SLAVE_BASE_ADDR + axi_araddr;
	assign M_AXI_ARVALID	= axi_arvalid;
	assign M_AXI_ARPROT	= 3'b001;
	//Read and Read Response (R)
	assign M_AXI_RREADY	= axi_rready;
	//Example design I/O
	assign init_txn_pulse	= (!init_txn_ff2) && init_txn_ff;


	//Generate a pulse to initiate AXI transaction.
	always @(posedge M_AXI_ACLK)
	  begin
	    // Initiates AXI transaction delay
	    if (M_AXI_ARESETN == 0 )
	      begin
	        init_txn_ff <= 1'b0;
	        init_txn_ff2 <= 1'b0;
	      end
	    else
	      begin
	        init_txn_ff <= I_INIT_AXI_TXN;
	        init_txn_ff2 <= init_txn_ff;
	      end
	  end


	//--------------------
	//Write Address Channel
	//--------------------

	// The purpose of the write address channel is to request the address and
	// command information for the entire transaction.  It is a single beat
	// of information.

	// Note for this example the axi_awvalid/axi_wvalid are asserted at the same
	// time, and then each is deasserted independent from each other.
	// This is a lower-performance, but simplier control scheme.

	// AXI VALID signals must be held active until accepted by the partner.

	// A data transfer is accepted by the slave when a master has
	// VALID data and the slave acknoledges it is also READY. While the master
	// is allowed to generated multiple, back-to-back requests by not
	// deasserting VALID, this design will add rest cycle for
	// simplicity.

	// Since only one outstanding transaction is issued by the user design,
	// there will not be a collision between a new request and an accepted
	// request on the same clock cycle.

	  always @(posedge M_AXI_ACLK)
	  begin
	    //Only VALID signals must be deasserted during reset per AXI spec
	    //Consider inverting then registering active-low reset for higher fmax
	    if (M_AXI_ARESETN == 0 || mst_exec_state != INIT_WRITE)
	      begin
	        axi_awvalid <= 1'b0;
	      end
	      //Signal a new address/data command is available by user logic
	    else
	      begin
	        if (start_single_write)
	          begin
	            axi_awvalid <= 1'b1;
	          end
	     //Address accepted by interconnect/slave (issue of M_AXI_AWREADY by slave)
	        else if (M_AXI_AWREADY && axi_awvalid)
	          begin
	            axi_awvalid <= 1'b0;
	          end
	      end
	  end


	  // start_single_write triggers a new write
	  // transaction. write_index is a counter to
	  // keep track with number of write transaction
	  // issued/initiated
	  always @(posedge M_AXI_ACLK)
	  begin
	    if (M_AXI_ARESETN == 0 || mst_exec_state != INIT_WRITE)
	      begin
	        write_index <= 0;
	      end
	      // Signals a new write address/ write data is
	      // available by user logic
	    else if (start_single_write)
	      begin
	        write_index <= write_index + 1;
	      end
	  end


	//--------------------
	//Write Data Channel
	//--------------------

	//The write data channel is for transfering the actual data.
	//The data generation is speific to the example design, and
	//so only the WVALID/WREADY handshake is shown here

	   always @(posedge M_AXI_ACLK)
	   begin
	     if (M_AXI_ARESETN == 0  || mst_exec_state != INIT_WRITE)
	       begin
	         axi_wvalid <= 1'b0;
	       end
	     //Signal a new address/data command is available by user logic
	     else if (start_single_write)
	       begin
	         axi_wvalid <= 1'b1;
	       end
	     //Data accepted by interconnect/slave (issue of M_AXI_WREADY by slave)
	     else if (M_AXI_WREADY && axi_wvalid)
	       begin
	        axi_wvalid <= 1'b0;
	       end
	   end


	//----------------------------
	//Write Response (B) Channel
	//----------------------------

	//The write response channel provides feedback that the write has committed
	//to memory. BREADY will occur after both the data and the write address
	//has arrived and been accepted by the slave, and can guarantee that no
	//other accesses launched afterwards will be able to be reordered before it.

	//The BRESP bit [1] is used indicate any errors from the interconnect or
	//slave for the entire write burst. This example will capture the error.

	//While not necessary per spec, it is advisable to reset READY signals in
	//case of differing reset latencies between master/slave.

	  always @(posedge M_AXI_ACLK)
	  begin
	    if (M_AXI_ARESETN == 0 || mst_exec_state != INIT_WRITE)
	      begin
	        axi_bready <= 1'b0;
	      end
	    // accept/acknowledge bresp with axi_bready by the master
	    // when M_AXI_BVALID is asserted by slave
	    else if (M_AXI_BVALID && ~axi_bready)
	      begin
	        axi_bready <= 1'b1;
	      end
	    // deassert after one clock cycle
	    else if (axi_bready)
	      begin
	        axi_bready <= 1'b0;
	      end
	    // retain the previous value
	    else
	      axi_bready <= axi_bready;
	  end

	//Flag write errors
	assign write_resp_error = (axi_bready & M_AXI_BVALID & M_AXI_BRESP[1]);


	//----------------------------
	//Read Address Channel
	//----------------------------

	//start_single_read triggers a new read transaction. read_index is a counter to
	//keep track with number of read transaction issued/initiated

	  always @(posedge M_AXI_ACLK)
	  begin
	    if (M_AXI_ARESETN == 0 || mst_exec_state != INIT_READ)
	      begin
	        read_index <= 0;
	      end
	    // Signals a new read address is
	    // available by user logic
	    else if (start_single_read)
	      begin
	        read_index <= read_index + 1;
	      end
	  end

	  // A new axi_arvalid is asserted when there is a valid read address
	  // available by the master. start_single_read triggers a new read
	  // transaction
	  always @(posedge M_AXI_ACLK)
	  begin
	    if (M_AXI_ARESETN == 0 || mst_exec_state != INIT_READ)
	      begin
	        axi_arvalid <= 1'b0;
	      end
	    //Signal a new read address command is available by user logic
	    else if (start_single_read)
	      begin
	        axi_arvalid <= 1'b1;
	      end
	    //RAddress accepted by interconnect/slave (issue of M_AXI_ARREADY by slave)
	    else if (M_AXI_ARREADY && axi_arvalid)
	      begin
	        axi_arvalid <= 1'b0;
	      end
	    // retain the previous value
	  end


	//--------------------------------
	//Read Data (and Response) Channel
	//--------------------------------

	//The Read Data channel returns the results of the read request
	//The master will accept the read data by asserting axi_rready
	//when there is a valid read data available.
	//While not necessary per spec, it is advisable to reset READY signals in
	//case of differing reset latencies between master/slave.

	  always @(posedge M_AXI_ACLK)
	  begin
	    if (M_AXI_ARESETN == 0 || mst_exec_state != INIT_READ)
	      begin
	        axi_rready <= 1'b0;
	      end
	    // accept/acknowledge rdata/rresp with axi_rready by the master
	    // when M_AXI_RVALID is asserted by slave
	    else if (M_AXI_RVALID && ~axi_rready)
	      begin
	        axi_rready <= 1'b1;
	      end
	    // deassert after one clock cycle
	    else if (axi_rready)
	      begin
	        axi_rready <= 1'b0;
	      end
	    // retain the previous value
	  end

	//Flag write errors
	assign read_resp_error = (axi_rready & M_AXI_RVALID & M_AXI_RRESP[1]);


	//--------------------------------
	//User Logic
	//--------------------------------

	//Address/Data Stimulus

	//Address/data pairs for this example. The read and write values should
	//match.
	//Modify these as desired for different address patterns.

	  //Write Addresses
	  always @(posedge M_AXI_ACLK)
	      begin
	        if (M_AXI_ARESETN == 0  || mst_exec_state != INIT_WRITE)
	          begin
	            if (I_TRANSFER_MODE == 2'd0)
				begin
					axi_awaddr <= 32'h0;
				end
				// Mode Set Read Data from RAM
				else if (I_TRANSFER_MODE == 2'd1)
				begin
					axi_awaddr <= 32'h18;
				end
				// Mode Set Write Data to RAM
				else if (I_TRANSFER_MODE == 2'd2)
				begin
					// Run DMA
					axi_awaddr <= 32'h48;
				end
				// Default
				else
				begin
					// Run DMA
					axi_awaddr <= 32'h0;
				end
	          end
	          // Signals a new write address/ write data is
	          // available by user logic
	        else
			begin
				if (M_AXI_AWREADY && axi_awvalid)
	          	begin
					// Mode Start DMA
					if (I_TRANSFER_MODE == 2'd0)
					begin
						case (write_index)
						8'h0:
							begin
								// Run DMA MM2S
								axi_awaddr <= 32'h0;
							end
						8'h1:
							begin
								// Run DMA S2MM
								axi_awaddr <= 32'h30;
							end
						default:
							begin
								// Run DMA
								axi_awaddr <= 32'h0;
							end
						endcase
					end
					// Mode Set Read Data from RAM
					else if (I_TRANSFER_MODE == 2'd1)
					begin
						case (write_index)
							8'h1:
								begin
									// Byte to transfer
									axi_awaddr <= 32'h28;
								end
							default:
								begin
									// Run DMA
									axi_awaddr <= 32'h18;
								end
						endcase
					end
					// Mode Set Write Data to RAM
					else if (I_TRANSFER_MODE == 2'd2)
					begin
						case (write_index)
							8'h1:
								begin
									// Byte to transfer
									axi_awaddr <= 32'h58;
								end
							default:
								begin
									// Run DMA
									axi_awaddr <= 32'h48;
								end
						endcase
					end
					// Default
					else
					begin
						case (write_index)
							8'h1:
								begin
									// Run DMA S2MM
									axi_awaddr <= 32'h30;
								end
							default:
								begin
									// Run DMA
									axi_awaddr <= 32'h0;
								end
						endcase
					end
	          	end
			end

	      end

	  // Write data generation
	  always @(posedge M_AXI_ACLK)
		begin
			if (M_AXI_ARESETN == 0 || mst_exec_state != INIT_WRITE)
			begin
				// Mode Start DMA
				if (I_TRANSFER_MODE == 2'd0)
				begin
					axi_wdata <= 32'h1;
				end
				// Mode Transfer Data to/from RAM
				else if (I_TRANSFER_MODE == 2'd1 || I_TRANSFER_MODE == 2'd2)
				begin
					axi_wdata <= I_REG_ADDRESS;
				end
				// Default
				else
				begin
					// Run DMA
					axi_wdata <= 32'h1;
				end
			end
			// Signals a new write address/ write data is
			// available by user logic
			else if (M_AXI_WREADY && axi_wvalid)
				begin
				// Mode Start DMA
				if (I_TRANSFER_MODE == 2'd0)
				begin
					// Run DMA MM2S && S2MM
					axi_wdata <= 32'h1;
				end
				// Mode Transfer Data to/from RAM
				else if (I_TRANSFER_MODE == 2'd1 || I_TRANSFER_MODE == 2'd2)
				begin
					case (write_index)
						8'h0:
							begin
								// Source Address
								axi_wdata <= I_REG_ADDRESS;
							end
						8'h1:
							begin
								// Byte to transfer
								axi_wdata <= I_REG_DATA;
							end
						default:
							begin
								// Run DMA
								axi_wdata <= I_REG_ADDRESS;
							end
					endcase
				end
				// Default
				else
				begin
					axi_wdata <= 32'h1;
				end
			end
		end 

	  //Read Addresses
	  always @(posedge M_AXI_ACLK)
	      begin
	        if (M_AXI_ARESETN == 0  || mst_exec_state != INIT_READ)
	          begin
	            axi_araddr <= 32'h34;
	          end
	          // Signals a new write address/ write data is
	          // available by user logic
	        else if (M_AXI_ARREADY && axi_arvalid)
	          begin
	            axi_araddr <= 32'h34;
	          end
	      end

	  //implement master command interface state machine
	  reg [7:0] timeout_counter;
	  wire [7:0] timeout_max = 10;

	  reg [7:0] wait_before_read;
	  reg [7:0] wait_before_read_max = 16;

	  always @ ( posedge M_AXI_ACLK)
	  begin
	    if (M_AXI_ARESETN == 1'b0)
	      begin
	      // reset condition
	      // All the signals are assigned default values under reset condition
	        mst_exec_state  <= IDLE;
	        start_single_write <= 1'b0;
	        write_issued  <= 1'b0;
	        start_single_read  <= 1'b0;
	        read_issued   <= 1'b0;
	      end
	    else
	      begin
	       // state transition
	        case (mst_exec_state)
	          IDLE:
	          // This state is responsible to initiate
	          // AXI transaction when init_txn_pulse is asserted
	            if ( init_txn_pulse == 1'b1 )
	              begin
	                mst_exec_state  <= INIT_WRITE;
	              end
	            else
	              begin
	                mst_exec_state  <= IDLE;
	              end
	          INIT_WRITE:
	            // This state is responsible to issue start_single_write pulse to
	            // initiate a write transaction. Write transactions will be
	            // issued until last_write signal is asserted.
	            // write controller
	            if (writes_done)
	              begin
					//   if (TRANSFER_MODE == 2)
					//   begin
	                // 	  mst_exec_state <= INIT_READ;// Check if command get through  
					//   end
					//   else
					//   begin
						  mst_exec_state <= TRANSACTION_DONE;// then goes to idle again by default
					//   end
	              end
	            else
	              begin
	                mst_exec_state  <= INIT_WRITE;

	                  if (~axi_awvalid && ~axi_wvalid && ~M_AXI_BVALID && ~last_write && ~start_single_write && ~write_issued)
	                    begin
	                      start_single_write <= 1'b1;
	                      write_issued  <= 1'b1;
	                    end
	                  else if (axi_bready)
	                    begin
	                      write_issued  <= 1'b0;
	                    end
	                  else
	                    begin
	                      start_single_write <= 1'b0; //Negate to generate a pulse
	                    end
	              end	                                                                                    
	          INIT_READ:                                                                
	            // This state is responsible to issue start_single_read pulse to        
	            // initiate a read transaction. Read transactions will be               
	            // issued until last_read signal is asserted.                           
	             // read controller                                                     
	             if (reads_done)                                      
	               begin
					   if (read_mismatch && (timeout_counter < timeout_max))
					   begin
						   mst_exec_state <= INIT_WRITE;                                    
					   end
					   else
					   begin
	                 		mst_exec_state <= TRANSACTION_DONE;                                    
					   end
	               end                                                                  
	             else                                                                   
	               begin                                                                
	                 mst_exec_state  <= INIT_READ;                                      
	                 if (wait_before_read >= wait_before_read_max)
					 begin
						if (~axi_arvalid && ~M_AXI_RVALID && ~last_read && ~start_single_read && ~read_issued)
						begin                                                            
							start_single_read <= 1'b1;                                     
							read_issued  <= 1'b1;                                          
						end                                                              
						else if (axi_rready)                                               
						begin                                                            
							read_issued  <= 1'b0;                                          
						end                                                              
						else                                                               
						begin                                                            
							start_single_read <= 1'b0; //Negate to generate a pulse        
						end                                                              
					 end
					 else
					 begin
						 read_issued  <= read_issued;                                          
						 start_single_read <= start_single_read;
					 end
	               end        
	           default:
	             begin
	               mst_exec_state  <= IDLE;
	             end
	        endcase
	    end
	  end //MASTER_EXECUTION_PROC

	  //Terminal write count

	  always @(posedge M_AXI_ACLK)
	  begin
	    if (M_AXI_ARESETN == 0 || mst_exec_state != INIT_WRITE)
	      last_write <= 1'b0;

	    //The last write should be associated with a write address ready response
	    else if ((write_index == C_M_TRANSACTIONS_NUM) && M_AXI_AWREADY)
	      last_write <= 1'b1;
	    else
	      last_write <= last_write;
	  end

	  //Check for last write completion.

	  //This logic is to qualify the last write count with the final write
	  //response. This demonstrates how to confirm that a write has been
	  //committed.

	  always @(posedge M_AXI_ACLK)
	  begin
	    if (M_AXI_ARESETN == 0 || mst_exec_state != INIT_WRITE)
	      writes_done <= 1'b0;

	      //The writes_done should be associated with a bready response
	    else if (last_write && M_AXI_BVALID && axi_bready)
	      writes_done <= 1'b1;
	    else
	      writes_done <= writes_done;
	  end

	//------------------
	//Read example
	//------------------

	//Terminal Read Count

	  always @(posedge M_AXI_ACLK)
	  begin
	    if (M_AXI_ARESETN == 0 || mst_exec_state != INIT_READ)
	      last_read <= 1'b0;

	    //The last read should be associated with a read address ready response
	    else if ((read_index == 1) && (M_AXI_ARREADY) )
	      last_read <= 1'b1;
	    else
	      last_read <= last_read;
	  end

	/*
	 Check for last read completion.

	 This logic is to qualify the last read count with the final read
	 response/data.
	 */
	  always @(posedge M_AXI_ACLK)
	  begin
	    if (M_AXI_ARESETN == 0 || mst_exec_state != INIT_READ)
	      reads_done <= 1'b0;

	    //The reads_done should be associated with a read ready response
	    else if (last_read && M_AXI_RVALID && axi_rready)
	      reads_done <= 1'b1;
	    else
	      reads_done <= reads_done;
	    end

		                                                  
	//-----------------------------                                                     
	//Example design error register                                                     
	//-----------------------------                                                     
	                                                                                    
	//Data Comparison                                                                   
	  always @(posedge M_AXI_ACLK)                                                      
	  begin                                                                             
	    if (M_AXI_ARESETN == 0  || mst_exec_state != INIT_READ)                                                         
	    begin
			read_mismatch <= 1'b0;                                                          
		end                                                                                
	    //The read data when available (on axi_rready) is compared with the expected data
	    else if ((M_AXI_RVALID && axi_rready) && (M_AXI_RDATA[7:0] != 8'h00))
		begin
	      	read_mismatch <= 1'b1;                                                        
		end
	    else                                                                            
		begin
	      	read_mismatch <= read_mismatch;                                               
		end
	  end  

	always @(posedge M_AXI_ACLK)
	begin
		if (!M_AXI_ARESETN || init_txn_pulse)
		begin
			timeout_counter <= 0;
		end
		else
		begin
			if (start_single_read)
			begin
				timeout_counter <= timeout_counter + 1;
			end
			else
			begin
				timeout_counter <= timeout_counter;
			end
		end
	end

	always @(posedge M_AXI_ACLK)
	begin
		if (!M_AXI_ARESETN || mst_exec_state != INIT_READ)
		begin
			wait_before_read <= 0;
		end
		else
		begin
			if (wait_before_read < wait_before_read_max)
			begin
				wait_before_read <= wait_before_read + 1;
			end
			else
			begin
				wait_before_read <= wait_before_read;
			end
		end
	end
	
	assign O_AXI_TXN_DONE = mst_exec_state == TRANSACTION_DONE;

	// wire [63:0] data_logger = (mst_exec_state == INIT_WRITE) ? {2'b00, M_AXI_AWREADY, M_AXI_AWVALID, M_AXI_BREADY, M_AXI_BVALID, 4'b0110,  M_AXI_WREADY, M_AXI_WVALID, INIT_AXI_TXN, AXI_TXN_DONE, TRANSFER_MODE, M_AXI_AWADDR[15:0], M_AXI_WDATA} : {2'b00, M_AXI_AWREADY, M_AXI_AWVALID, M_AXI_ARREADY, M_AXI_ARVALID, 4'b0110,  M_AXI_RREADY, M_AXI_RVALID, INIT_AXI_TXN, AXI_TXN_DONE, TRANSFER_MODE, M_AXI_ARADDR[15:0], M_AXI_RDATA};
    // data_logger #(
    //     .DATA_WIDTH(64)
    // ) data_logger_inst (
    //     .I_ACLK(M_AXI_ACLK),
    //     .I_ARESETN(M_AXI_ARESETN),

    //     .I_START(INIT_AXI_TXN),
    //     .I_DATA_LOGGER(data_logger),
    //     .I_DONE(AXI_TXN_DONE),

    //     .I_READ_ADDR(I_BRAM_DEBUG_ADDR),
    //     .O_DATA_LOGGER(O_DATA_LOGGER)
    // );

	assign O_DATA_LOGGER = 64'd0;

endmodule
