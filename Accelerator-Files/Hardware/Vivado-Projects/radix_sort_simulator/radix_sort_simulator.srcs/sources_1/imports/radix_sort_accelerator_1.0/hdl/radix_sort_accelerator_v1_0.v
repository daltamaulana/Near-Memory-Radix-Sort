
`timescale 1 ns / 1 ps

module radix_sort_accelerator_v1_0 
	// Declare parameters
	#(
		// Parameters of Axi Slave Bus Interface S00_AXI_FROM_PS
		parameter integer C_S00_AXI_FROM_PS_DATA_WIDTH	= 32,
		parameter integer C_S00_AXI_FROM_PS_ADDR_WIDTH	= 9,

		// Parameters of Axi Master Bus Interface M00_AXI_TO_DMA
		parameter  C_M00_AXI_TO_DMA_START_DATA_VALUE	= 32'hAA000000,
		parameter  C_M00_AXI_TO_DMA_TARGET_SLAVE_BASE_ADDR	= 32'h00000000,
		parameter integer C_M00_AXI_TO_DMA_ADDR_WIDTH	= 32,
		parameter integer C_M00_AXI_TO_DMA_DATA_WIDTH	= 32,
		parameter integer C_M00_AXI_TO_DMA_TRANSACTIONS_NUM	= 2,

		// Parameters of Axi Slave Bus Interface S00_AXIS
		parameter integer C_S00_AXIS_TDATA_WIDTH	= 128,

		// Parameters of Axi Master Bus Interface M00_AXIS
		parameter integer C_M00_AXIS_TDATA_WIDTH	= 128
	)
	// Declare ports
	(
		// Interrupt Pin
		output wire pl_to_ps_irq,
		
		// Ports of Axi Slave Bus Interface S00_AXI_FROM_PS
		input wire  s00_axi_from_ps_aclk,
		input wire  s00_axi_from_ps_aresetn,
		input wire [C_S00_AXI_FROM_PS_ADDR_WIDTH-1 : 0] s00_axi_from_ps_awaddr,
		input wire [2 : 0] s00_axi_from_ps_awprot,
		input wire  s00_axi_from_ps_awvalid,
		output wire  s00_axi_from_ps_awready,
		input wire [C_S00_AXI_FROM_PS_DATA_WIDTH-1 : 0] s00_axi_from_ps_wdata,
		input wire [(C_S00_AXI_FROM_PS_DATA_WIDTH/8)-1 : 0] s00_axi_from_ps_wstrb,
		input wire  s00_axi_from_ps_wvalid,
		output wire  s00_axi_from_ps_wready,
		output wire [1 : 0] s00_axi_from_ps_bresp,
		output wire  s00_axi_from_ps_bvalid,
		input wire  s00_axi_from_ps_bready,
		input wire [C_S00_AXI_FROM_PS_ADDR_WIDTH-1 : 0] s00_axi_from_ps_araddr,
		input wire [2 : 0] s00_axi_from_ps_arprot,
		input wire  s00_axi_from_ps_arvalid,
		output wire  s00_axi_from_ps_arready,
		output wire [C_S00_AXI_FROM_PS_DATA_WIDTH-1 : 0] s00_axi_from_ps_rdata,
		output wire [1 : 0] s00_axi_from_ps_rresp,
		output wire  s00_axi_from_ps_rvalid,
		input wire  s00_axi_from_ps_rready,

		// Ports of Axi Master Bus Interface M00_AXI_TO_DMA
		input wire  m00_axi_to_dma_aclk,
		input wire  m00_axi_to_dma_aresetn,
		output wire [C_M00_AXI_TO_DMA_ADDR_WIDTH-1 : 0] m00_axi_to_dma_awaddr,
		output wire [2 : 0] m00_axi_to_dma_awprot,
		output wire  m00_axi_to_dma_awvalid,
		input wire  m00_axi_to_dma_awready,
		output wire [C_M00_AXI_TO_DMA_DATA_WIDTH-1 : 0] m00_axi_to_dma_wdata,
		output wire [C_M00_AXI_TO_DMA_DATA_WIDTH/8-1 : 0] m00_axi_to_dma_wstrb,
		output wire  m00_axi_to_dma_wvalid,
		input wire  m00_axi_to_dma_wready,
		input wire [1 : 0] m00_axi_to_dma_bresp,
		input wire  m00_axi_to_dma_bvalid,
		output wire  m00_axi_to_dma_bready,
		output wire [C_M00_AXI_TO_DMA_ADDR_WIDTH-1 : 0] m00_axi_to_dma_araddr,
		output wire [2 : 0] m00_axi_to_dma_arprot,
		output wire  m00_axi_to_dma_arvalid,
		input wire  m00_axi_to_dma_arready,
		input wire [C_M00_AXI_TO_DMA_DATA_WIDTH-1 : 0] m00_axi_to_dma_rdata,
		input wire [1 : 0] m00_axi_to_dma_rresp,
		input wire  m00_axi_to_dma_rvalid,
		output wire  m00_axi_to_dma_rready,

		// Ports of Axi Slave Bus Interface S00_AXIS
		input wire  s00_axis_aclk,
		input wire  s00_axis_aresetn,
		output wire  s00_axis_tready,
		input wire [C_S00_AXIS_TDATA_WIDTH-1 : 0] s00_axis_tdata,
		input wire [(C_S00_AXIS_TDATA_WIDTH/8)-1 : 0] s00_axis_tstrb,
		input wire  s00_axis_tlast,
		input wire  s00_axis_tvalid,

		// Ports of Axi Master Bus Interface M00_AXIS
		input wire  m00_axis_aclk,
		input wire  m00_axis_aresetn,
		output wire  m00_axis_tvalid,
		output wire [C_M00_AXIS_TDATA_WIDTH-1 : 0] m00_axis_tdata,
		output wire [(C_M00_AXIS_TDATA_WIDTH/8)-1 : 0] m00_axis_tstrb,
		output wire  m00_axis_tlast,
		input wire  m00_axis_tready
	);

	//////////////////////////////////////////////////////////
	//				    Wire Definition                     //
	//////////////////////////////////////////////////////////
	//---------------------------------------//
	//    AXIL Slave <-> Main Unit (SCU)     //
	//---------------------------------------//
	// <======
	wire [31:0] w_program_counter;
	wire [7:0] w_fsm_stream_master;
	wire [7:0] w_fsm_stream_slave;
	wire [7:0] w_fsm_dma_controller;

	wire [63:0]  w_bram_debug_instruction;
	wire [71:0]  w_bram_debug_weight;
	wire [127:0] w_bram_debug_fmap;
	wire [31:0]  w_bram_debug_bias;
	wire [447:0] w_bram_debug_out_0;
	wire [447:0] w_bram_debug_out_1;
	wire [447:0] w_bram_debug_dlq;
	wire [447:0] w_bram_debug_mp;
	wire [31:0]  w_reg_debug_scale_pos;
	wire [31:0]  w_reg_debug_scale_neg;
	wire [31:0]  w_state_logger_data;

	// =======>
	wire 	    w_global_start;
	wire [31:0] w_addr_input;
	wire [31:0] w_addr_instruction;
	wire [31:0] w_addr_output;
	wire        w_force_load_instruction;

	wire [31:0] w_bram_debug_addr;
	wire [2:0]  w_bram_mode_debug;

	//----------------------------------------------//
	//   AXIS Slave <-> Main Unit (Data Ordering)   //
	//----------------------------------------------//
	// <===========
	wire w_stream_dequeue;
	// ===========>
	wire w_stream_valid;
	wire [C_S00_AXIS_TDATA_WIDTH-1:0] w_stream_fifo_input;

	//---------------------------------//
	//    Main Unit <-> AXIS Master    //
	//---------------------------------//
	// <===========
	wire w_stream_full;
	wire w_stream_almost_full;
	// ===========>
	wire [C_M00_AXIS_TDATA_WIDTH-1:0] w_stream_fifo_output;
	wire w_stream_queue;
	wire w_stream_empty;

	//--------------------------------//
	//    AXI Master <-> Main Unit    //
	//--------------------------------//
	// <=====
	wire w_dma_init_axi_txn;
	wire w_dma_axi_txn_done;
	wire [31:0] w_reg_address;
	wire [31:0] w_reg_data;
	wire w_data_send_done;
	wire [31:0] w_no_of_transaction;
	wire [1:0] w_dma_transfer_mode;

	wire [1:0] w_fifo_status_slave;
	wire [1:0] w_fifo_status_master;

	wire [63:0] w_m00_data_logger;

	////////////////////////////////
	//        Debug Signal        //
	////////////////////////////////
	wire w_pc_changed;
	wire [3:0]  w_scu_state_machine;
	wire [3:0]  w_internal_counter;
	wire [31:0] w_instruction_out;

	//////////////////////////////////////////////////////////
	//				  Instantiate Module                    //
	//////////////////////////////////////////////////////////
	//---------------------------------------------//
	//   			 AXI Slave Unit                //
	//---------------------------------------------//
	radix_sort_accelerator_v1_0_S00_AXI_FROM_PS #(
		.C_S_AXI_DATA_WIDTH(C_S00_AXI_FROM_PS_DATA_WIDTH),
		.C_S_AXI_ADDR_WIDTH(C_S00_AXI_FROM_PS_ADDR_WIDTH)	
	) radix_sort_accelerator_v1_0_S00_AXI_FROM_PS_unit (
		// User defined ports
		.O_GLOBAL_START(w_global_start),
		.O_ADDR_INPUT(w_addr_input),
		.O_ADDR_INSTRUCTION(w_addr_instruction),
		.O_ADDR_OUTPUT(w_addr_output),
		.O_FORCE_LOAD_INSTRUCTION(w_force_load_instruction),

		.I_PROGRAM_COUNTER(w_program_counter),

		.O_BRAM_DEBUG_ADDR(w_bram_debug_addr),
		.O_BRAM_MODE_DEBUG(w_bram_mode_debug),

		.I_BRAM_DEBUG_INSTRUCTION(w_bram_debug_instruction),
		.I_BRAM_DEBUG_WEIGHT(w_bram_debug_weight),
		.I_BRAM_DEBUG_FMAP(w_bram_debug_fmap),
		.I_BRAM_DEBUG_BIAS(w_bram_debug_bias),
		.I_BRAM_DEBUG_OUT_0(w_bram_debug_out_0),
		.I_BRAM_DEBUG_OUT_1(w_bram_debug_out_0),
		.I_BRAM_DEBUG_DLQ(w_bram_debug_dlq),
		.I_BRAM_DEBUG_MP(w_bram_debug_mp),
		.I_REG_DEBUG_SCALE_POS(w_reg_debug_scale_pos),
		.I_REG_DEBUG_SCALE_NEG(w_reg_debug_scale_neg),

		.I_FSM_STREAM_MASTER(w_fsm_stream_master),
		.I_FSM_STREAM_SLAVE(w_fsm_stream_slave),
		.I_FSM_DMA_CONTROLLER(w_fsm_dma_controller),
		.I_IRQ_SIGNAL(pl_to_ps_irq),
		.I_STATE_COUNTER(w_state_logger_data),
		.I_FIFO_STATUS_SLAVE(w_fifo_status_slave),
		.I_FIFO_STATUS_MASTER(w_fifo_status_master),

		////////////////////////////////
        //        Debug Signal        //
        ////////////////////////////////
		.I_PC_CHANGED(w_pc_changed),
        .I_SCU_STATE_MACHINE(w_scu_state_machine),
        .I_INTERNAL_COUNTER(w_internal_counter),
        .I_INSTRUCTION_OUT(w_instruction_out),

		// AXI signals
		.S_AXI_ACLK(s00_axi_from_ps_aclk),
		.S_AXI_ARESETN(s00_axi_from_ps_aresetn),
		.S_AXI_AWADDR(s00_axi_from_ps_awaddr),
		.S_AXI_AWPROT(s00_axi_from_ps_awprot),
		.S_AXI_AWVALID(s00_axi_from_ps_awvalid),
		.S_AXI_AWREADY(s00_axi_from_ps_awready),
		.S_AXI_WDATA(s00_axi_from_ps_wdata),
		.S_AXI_WSTRB(s00_axi_from_ps_wstrb),
		.S_AXI_WVALID(s00_axi_from_ps_wvalid),
		.S_AXI_WREADY(s00_axi_from_ps_wready),
		.S_AXI_BRESP(s00_axi_from_ps_bresp),
		.S_AXI_BVALID(s00_axi_from_ps_bvalid),
		.S_AXI_BREADY(s00_axi_from_ps_bready),
		.S_AXI_ARADDR(s00_axi_from_ps_araddr),
		.S_AXI_ARPROT(s00_axi_from_ps_arprot),
		.S_AXI_ARVALID(s00_axi_from_ps_arvalid),
		.S_AXI_ARREADY(s00_axi_from_ps_arready),
		.S_AXI_RDATA(s00_axi_from_ps_rdata),
		.S_AXI_RRESP(s00_axi_from_ps_rresp),
		.S_AXI_RVALID(s00_axi_from_ps_rvalid),
		.S_AXI_RREADY(s00_axi_from_ps_rready)
	);

	//---------------------------------------------//
	//   			AXI Master Unit                //
	//---------------------------------------------//
	radix_sort_accelerator_v1_0_M00_AXI_TO_DMA #(
		.C_M_TARGET_SLAVE_BASE_ADDR(C_M00_AXI_TO_DMA_TARGET_SLAVE_BASE_ADDR),
		.C_M_AXI_ADDR_WIDTH(C_M00_AXI_TO_DMA_ADDR_WIDTH),
		.C_M_AXI_DATA_WIDTH(C_M00_AXI_TO_DMA_DATA_WIDTH),
		.C_M_TRANSACTIONS_NUM(C_M00_AXI_TO_DMA_TRANSACTIONS_NUM)
	) radix_sort_accelerator_v1_0_M00_AXI_TO_DMA_unit (
		// User defined ports
		.I_REG_ADDRESS(w_reg_address),
		.I_REG_DATA(w_reg_data),
		.I_TRANSFER_MODE(w_dma_transfer_mode),
		.I_INIT_AXI_TXN(w_dma_init_axi_txn),
		.O_AXI_TXN_DONE(w_dma_axi_txn_done),
		.O_FSM_DMA_CONTROLLER(w_fsm_dma_controller),
		.I_BRAM_DEBUG_ADDR(w_m00_data_logger),
		.O_DATA_LOGGER(w_bram_debug_addr),
		
		// AXI ports
		.M_AXI_ACLK(m00_axi_to_dma_aclk),
		.M_AXI_ARESETN(m00_axi_to_dma_aresetn),
		.M_AXI_AWADDR(m00_axi_to_dma_awaddr),
		.M_AXI_AWPROT(m00_axi_to_dma_awprot),
		.M_AXI_AWVALID(m00_axi_to_dma_awvalid),
		.M_AXI_AWREADY(m00_axi_to_dma_awready),
		.M_AXI_WDATA(m00_axi_to_dma_wdata),
		.M_AXI_WSTRB(m00_axi_to_dma_wstrb),
		.M_AXI_WVALID(m00_axi_to_dma_wvalid),
		.M_AXI_WREADY(m00_axi_to_dma_wready),
		.M_AXI_BRESP(m00_axi_to_dma_bresp),
		.M_AXI_BVALID(m00_axi_to_dma_bvalid),
		.M_AXI_BREADY(m00_axi_to_dma_bready),
		.M_AXI_ARADDR(m00_axi_to_dma_araddr),
		.M_AXI_ARPROT(m00_axi_to_dma_arprot),
		.M_AXI_ARVALID(m00_axi_to_dma_arvalid),
		.M_AXI_ARREADY(m00_axi_to_dma_arready),
		.M_AXI_RDATA(m00_axi_to_dma_rdata),
		.M_AXI_RRESP(m00_axi_to_dma_rresp),
		.M_AXI_RVALID(m00_axi_to_dma_rvalid),
		.M_AXI_RREADY(m00_axi_to_dma_rready)
	);

	//----------------------------------------------//
	//   			 AXIS Slave Unit                //
	//----------------------------------------------//
	radix_sort_accelerator_v1_0_S00_AXIS #(
		.C_S_AXIS_TDATA_WIDTH(C_S00_AXIS_TDATA_WIDTH)
	) radix_sort_accelerator_v1_0_S00_AXIS_unit (
		// Control signal
		.I_STREAM_DEQUEUE(w_stream_dequeue),
		.O_STREAM_VALID(w_stream_valid),
		.O_STREAM_FIFO(w_stream_fifo_input),
		.O_STREAM_EMPTY(w_stream_empty),
		// Debug signal
		.O_FSM_STREAM_SLAVE(w_fsm_stream_slave),
		.I_STREAM_DEBUG_ADDR(w_bram_debug_addr),
		.O_FIFO_STATUS(w_fifo_status_slave),
		// AXIS post
		.S_AXIS_ACLK(s00_axis_aclk),
		.S_AXIS_ARESETN(s00_axis_aresetn),
		.S_AXIS_TREADY(s00_axis_tready),
		.S_AXIS_TDATA(s00_axis_tdata),
		.S_AXIS_TSTRB(s00_axis_tstrb),
		.S_AXIS_TLAST(s00_axis_tlast),
		.S_AXIS_TVALID(s00_axis_tvalid)
	);

	//----------------------------------------------//
	//   			AXIS Master Unit                //
	//----------------------------------------------//
	radix_sort_accelerator_v1_0_M00_AXIS #(
		.C_M_AXIS_TDATA_WIDTH(C_M00_AXIS_TDATA_WIDTH)
	) radix_sort_accelerator_v1_0_M00_AXIS_unit (
		// User ports
		// Signal for storing data to FIFO
		.I_FIFO_IN_QUEUE(w_stream_queue),
		.I_FIFO_IN_DATA(w_stream_fifo_output),
		.O_FIFO_ALMOST_FULL(w_stream_almost_full),
		.O_FIFO_OUT_FULL(w_stream_full),
        // FSM Signal
		.I_NO_OF_TRANSACTION(w_no_of_transaction),
		.O_FSM_STREAM_MASTER(w_fsm_stream_master),
		.O_DATA_SEND_DONE(w_data_send_done),
		// Debug signal
		.O_FIFO_STATUS(w_fifo_status_master),

		// AXI ports
		// Global ports
		.M_AXIS_ACLK(m00_axis_aclk),
		.M_AXIS_ARESETN(m00_axis_aresetn),
		.M_AXIS_TVALID(m00_axis_tvalid),
		.M_AXIS_TDATA(m00_axis_tdata),
		.M_AXIS_TSTRB(m00_axis_tstrb),
		.M_AXIS_TLAST(m00_axis_tlast),
		.M_AXIS_TREADY(m00_axis_tready)
	);

	//-------------------------------------------------------//
	//   			BRAM DRAM Mover Main Unit                //
	//-------------------------------------------------------//
	radix_sort_accelerator_main_unit radix_sort_accelerator_main_unit
	(
		// Clock and Reset
        .I_ACLK(m00_axis_aclk),
        .I_ARESETN(m00_axis_aresetn),

        ///////////////////////////////////////////////
		//    Main Unit <-> AXI Lite Slave Signal    //
		///////////////////////////////////////////////
		// Signal From PS
		.I_GLOBAL_START(w_global_start),
		.I_ADDR_INPUT(w_addr_input),
        .I_ADDR_INSTRUCTION(w_addr_instruction),
        .I_ADDR_OUTPUT(w_addr_output),
        .I_FORCE_LOAD_INSTRUCTION(w_force_load_instruction),
		// Monitor Signal
		.O_PROGRAM_COUNTER(w_program_counter),
        .O_STATE_LOGGER_DATA(w_state_logger_data),
		// Debug BRAM
		.I_BRAM_DEBUG_ADDR(w_bram_debug_addr),
        .I_BRAM_MODE_DEBUG(w_bram_mode_debug),
        .O_BRAM_DEBUG_INSTRUCTION(w_bram_debug_instruction),
        .O_BRAM_DEBUG_WEIGHT(w_bram_debug_weight),
        .O_BRAM_DEBUG_FMAP(w_bram_debug_fmap),
        .O_BRAM_DEBUG_BIAS(w_bram_debug_bias),
        .O_BRAM_DEBUG_OUT_0(w_bram_debug_out_0),
        .O_BRAM_DEBUG_OUT_1(w_bram_debug_out_1),
        .O_BRAM_DEBUG_DLQ(w_bram_debug_dlq),
        .O_BRAM_DEBUG_MP(w_bram_debug_mp),
        .O_REG_DEBUG_SCALE_POS(w_reg_debug_scale_pos),
        .O_REG_DEBUG_SCALE_NEG(w_reg_debug_scale_neg),

        ////////////////////////////////////////////
		//     Main Unit <-> AXIS Slave Signal    //
		////////////////////////////////////////////
        .I_STREAM_FIFO(w_stream_fifo_input),
        .O_STREAM_DEQUEUE(w_stream_dequeue),
		.I_STREAM_VALID(w_stream_valid),
        .I_STREAM_EMPTY(w_stream_empty),

        /////////////////////////////////////////////
		//     Main Unit <-> AXIS Master Signal    //
		/////////////////////////////////////////////
        .O_STREAM_FIFO(w_stream_fifo_output),
        .O_STREAM_QUEUE(w_stream_queue),
        .I_STREAM_FULL(w_stream_full),
        .I_STREAM_ALMOST_FULL(w_stream_almost_full),
        .I_DATA_SEND_DONE(w_data_send_done),

        ////////////////////////////////////////////////
		//    Main Unit <-> AXI Lite Master Signal    //
		////////////////////////////////////////////////
		.O_DMA_REG_ADDRESS(w_reg_address),
		.O_DMA_REG_DATA(w_reg_data),
		.O_DMA_INIT_AXI_TXN(w_dma_init_axi_txn),
		.I_DMA_AXI_TXN_DONE(w_dma_axi_txn_done),
        .O_DMA_NO_OF_TRANSACTION(w_no_of_transaction),
        .O_DMA_TRANSFER_MODE(w_dma_transfer_mode),
		// Interrupt signal
        .O_PL_TO_PS_IRQ(pl_to_ps_irq),

		////////////////////////////////
        //        Debug Signal        //
        ////////////////////////////////
		.O_PC_CHANGED(w_pc_changed),
        .O_SCU_STATE_MACHINE(w_scu_state_machine),
        .O_INTERNAL_COUNTER(w_internal_counter),
        .O_INSTRUCTION_OUT(w_instruction_out)
	);

endmodule