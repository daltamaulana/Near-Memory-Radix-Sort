//********************************************************************************
//                      [ MODULE ]                                                
//                                                                                
// Institution       : Korea Advanced Institute of Science and Technology         
// Engineer          : Dalta Imam Maulana                                         
//                                                                                
// Project Name      : Near Memory Radix Sort                                     
//                                                                                
// Create Date       : 6/19/2021
// File Name         : bram_dram_mover_main_unit.v                                           
// Module Dependency : -                                                          
//                                                                                
// Target Device     : ZCU104                                                     
// Tool Version      : Vivado 2020.1                                              
//                                                                                
// Description:                                                                   
//      Module containing all operational unit of the IP                          
//                                                                                
//********************************************************************************
`timescale 1ns / 1ps

module bram_dram_mover_main_unit
	////////////////////////////////////////
	//  Ports and Parameters Declaration  //
	////////////////////////////////////////
	// Declare parameters
	#(
		parameter DWIDTH =128,
		parameter SELWIDTH =10,
		parameter INSTWIDTH =64,
		parameter DATABRAMDEPTH =1024,
		parameter DATAADDRWIDTH =17,
		parameter INSTADDRWIDTH =10
	)
	// Declare ports
	(
		// Clock and Reset
		input wire I_ACLK,
		input wire I_ARESETN,

		///////////////////////////////////////////////
		//    Main Unit <-> AXI Lite Slave Signal    //
		///////////////////////////////////////////////
		// Signal From PS
		input wire          I_GLOBAL_START,
		input wire  [31:0]  I_ADDR_INPUT,
		input wire  [31:0]  I_ADDR_INSTRUCTION,
		input wire  [31:0]  I_ADDR_OUTPUT,
		input wire          I_FORCE_LOAD_INSTRUCTION,
		// Monitor Signal
		output reg  [31:0]  O_PROGRAM_COUNTER,
		output wire [31:0]  O_STATE_LOGGER_DATA,
		// Debug BRAM
		input wire  [31:0]  I_BRAM_DEBUG_ADDR,
		input wire  [2:0]   I_BRAM_MODE_DEBUG,
		output wire [63:0]  O_BRAM_DEBUG_INSTRUCTION,
		output wire [71:0]  O_BRAM_DEBUG_WEIGHT,
		output wire [127:0] O_BRAM_DEBUG_FMAP,
		output wire [31:0]  O_BRAM_DEBUG_BIAS,
		output wire [447:0] O_BRAM_DEBUG_OUT_0,
		output wire [447:0] O_BRAM_DEBUG_OUT_1,
		output wire [447:0] O_BRAM_DEBUG_DLQ,
		output wire [447:0] O_BRAM_DEBUG_MP,
		output wire [31:0]  O_REG_DEBUG_SCALE_POS,
		output wire [31:0]  O_REG_DEBUG_SCALE_NEG,

		////////////////////////////////////////////
		//     Main Unit <-> AXIS Slave Signal    //
		////////////////////////////////////////////
		input wire [DWIDTH-1:0]  I_STREAM_FIFO,
		output wire         O_STREAM_DEQUEUE,
		input wire          I_STREAM_VALID,
		input wire          I_STREAM_EMPTY,

		/////////////////////////////////////////////
		//     Main Unit <-> AXIS Master Signal    //
		/////////////////////////////////////////////
		output wire [DWIDTH-1:0] O_STREAM_FIFO,
		output wire         O_STREAM_QUEUE,
		input wire          I_STREAM_FULL,
		input wire          I_STREAM_ALMOST_FULL,
		input wire          I_DATA_SEND_DONE,

		////////////////////////////////////////////////
		//    Main Unit <-> AXI Lite Master Signal    //
		////////////////////////////////////////////////
		output wire [31:0]  O_DMA_REG_ADDRESS,
		output wire [31:0]  O_DMA_REG_DATA,
		output wire         O_DMA_INIT_AXI_TXN,
		input wire          I_DMA_AXI_TXN_DONE,
		output wire [31:0]  O_DMA_NO_OF_TRANSACTION,
		output wire [1:0]   O_DMA_TRANSFER_MODE,

		output wire         O_PL_TO_PS_IRQ,

		////////////////////////////////
		//        Debug Signal        //
		////////////////////////////////
		output wire O_PC_CHANGED,
		output wire [3:0]  O_SCU_STATE_MACHINE,
		output wire [3:0]  O_INTERNAL_COUNTER,
		output wire [31:0] O_INSTRUCTION_OUT
	);

	///////////////////////////////////
	//    Declare Local Parameter    //
	///////////////////////////////////
	localparam NOT_USED = 0;

	////////////////////////
	//    Declare Wire    //
	////////////////////////
	// SCU <--> BRAM Bank
	// Instruction Read
	wire [63:0]  w_scu_instruction_data;
	wire [INSTADDRWIDTH-1:0]  w_scu_program_counter;
	// Stream out

	// SCU <--> Data Ordering
	// Instruction Load
	wire         w_scu_load_instruction_start;
	wire         w_scu_load_instruction_done;
	// Input Load
	wire         w_scu_li_start;
	wire [31:0]  w_scu_li_no_of_row;
	wire [DATAADDRWIDTH-1:0]  w_scu_li_start_pointer;
	wire [SELWIDTH-1:0]   w_scu_li_sel;
	wire         w_scu_li_done;
	// Stream Out
	wire         w_scu_so_start;
	wire [DATAADDRWIDTH-1:0]  w_scu_so_start_pointer;
	wire [DATAADDRWIDTH-1:0]  w_scu_so_end_pointer;
	wire [SELWIDTH-1:0]   w_scu_so_bram_sel;
	wire         w_scu_so_done;

	// Data Ordering <--> Bram Bank
	// Instruction Load
	wire [INSTADDRWIDTH-1:0]  w_do_load_instruction_pointer;
	wire         w_do_load_instruction_valid;
	wire [DWIDTH-1:0] w_do_load_instruction_data;
	// Input Load
	wire [DATAADDRWIDTH-1:0]  w_do_li_pointer;
	wire         w_do_li_valid;
	wire [DWIDTH-1:0] w_do_li_data;
	wire [SELWIDTH-1:0]   w_do_li_sel;
	// Stream Out
	wire         w_do_so_now;
	wire [SELWIDTH-1:0]   w_do_so_bram_sel;
	wire [DATAADDRWIDTH-1:0]  w_do_so_pointer;

	// SCU <--> DMA Controller
	wire         w_scu_dma_start;
	wire [31:0]  w_scu_dma_addr;
	wire [31:0]  w_scu_dma_byte_to_transfer;
	wire [31:0]  w_scu_dma_no_of_transaction;
	wire [2:0]   w_scu_dma_mode;
	wire         w_scu_dma_done;

	////////////////////////////////
	//    Module Instantiation    //
	////////////////////////////////
	// Status and control unit
	status_and_control_unit status_and_control_unit
	(
		/////////////////////////////////////////////
		//            Clock and Reset              //
		/////////////////////////////////////////////
		.I_ACLK(I_ACLK),
		.I_ARESETN(I_ARESETN),

		/////////////////////////////////////////////
		//      SCU <-> AXI Lite Slave Signal      //
		/////////////////////////////////////////////
		// Signal From PS
		.I_GLOBAL_START(I_GLOBAL_START),
		.I_FORCE_LOAD_INSTRUCTION(I_FORCE_LOAD_INSTRUCTION), // Also work as debug signal for BRAM Bank Mode
		.I_BRAM_DEBUG_ADDR(I_BRAM_DEBUG_ADDR),
		.O_PL_TO_PS_IRQ(O_PL_TO_PS_IRQ),
		.O_STATE_LOGGER_DATA(O_STATE_LOGGER_DATA),

		// Monitor Signal
		.I_INSTRUCTION_DATA(w_scu_instruction_data),
		.O_PROGRAM_COUNTER(w_scu_program_counter),

		/////////////////////////////////////////////
		//          SCU <-> Data Ordering          //
		/////////////////////////////////////////////
		// Load Instruction Channel
		.O_LOAD_INSTRUCTION_START(w_scu_load_instruction_start),
		.I_LOAD_INSTRUCTION_DONE(w_scu_load_instruction_done),

		// Load Input Channel
		.O_LI_START(w_scu_li_start),
		.O_LI_NO_OF_ROW(w_scu_li_no_of_row),
		.O_LI_START_POINTER(w_scu_li_start_pointer),
		.O_LI_SEL(w_scu_li_sel),
		.I_LI_DONE(w_scu_li_done),

		// Stream Out
		.O_SO_START(w_scu_so_start),
		.O_SO_START_POINTER(w_scu_so_start_pointer),
		.O_SO_END_POINTER(w_scu_so_end_pointer),
		.I_SO_DONE(w_scu_so_done),

		////////////////////////////////
		//  DMA Controller <===> SCU  //
		////////////////////////////////
		.O_DMA_START(w_scu_dma_start),
		.O_DMA_ADDR(w_scu_dma_addr),
		.O_DMA_BYTE_TO_TRANSFER(w_scu_dma_byte_to_transfer),
		.O_DMA_NO_OF_TRANSACTION(w_scu_dma_no_of_transaction),
		.O_DMA_MODE(w_scu_dma_mode),
		.I_DMA_DONE(w_scu_dma_done),
		.I_DATA_SEND_DONE(I_DATA_SEND_DONE),

		////////////////////////////////
		//        Debug Signal        //
		////////////////////////////////
		.O_PC_CHANGED(O_PC_CHANGED),
		.O_SCU_STATE_MACHINE(O_SCU_STATE_MACHINE),
		.O_INTERNAL_COUNTER(O_INTERNAL_COUNTER),
		.O_INSTRUCTION_OUT(O_INSTRUCTION_OUT)
	);

	// DMA Controller unit
	dma_controller dma_controller_unit
	(
		// Clock and Reset
		.I_ACLK(I_ACLK),
		.I_ARESETN(I_ARESETN),

		// Signal from PS
		.I_START(w_scu_dma_start),
		.I_ADDR(w_scu_dma_addr),
		.I_BYTE_TO_TRANSFER(w_scu_dma_byte_to_transfer),
		.I_NO_OF_RECV_TRANSACTION(w_scu_dma_no_of_transaction),
		.I_MODE(w_scu_dma_mode),

		.I_ADDR_INPUT(I_ADDR_INPUT),
		.I_ADDR_INSTRUCTION(I_ADDR_INSTRUCTION),
		.I_ADDR_OUTPUT(I_ADDR_OUTPUT),

		.O_DONE(w_scu_dma_done),

		// Signal to DMA
		.O_DMA_REG_ADDRESS(O_DMA_REG_ADDRESS),
		.O_DMA_REG_DATA(O_DMA_REG_DATA),
		.O_DMA_INIT_AXI_TXN(O_DMA_INIT_AXI_TXN),
		.I_DMA_AXI_TXN_DONE(I_DMA_AXI_TXN_DONE),
		.O_DMA_NO_OF_TRANSACTION(O_DMA_NO_OF_TRANSACTION),
		.O_DMA_TRANSFER_MODE(O_DMA_TRANSFER_MODE),

		.I_BRAM_DEBUG_ADDR(I_BRAM_DEBUG_ADDR)
	);

	// Data ordering unit
	data_ordering data_ordering_unit
	(
		// Clock and Reset
		.I_ACLK(I_ACLK),
		.I_ARESETN(I_ARESETN),

		// Stream In Channel
		.O_STREAM_DEQUEUE(O_STREAM_DEQUEUE),
		.I_STREAM_VALID(I_STREAM_VALID),
		.I_STREAM_DATA(I_STREAM_FIFO),

		// Stream Out Channel
		.O_STREAM_QUEUE(O_STREAM_QUEUE),
		.I_STREAM_FULL(I_STREAM_FULL),

		// Load Instruction Module
		// SCU part
		.I_LOAD_INSTRUCTION_START(w_scu_load_instruction_start),
		.O_LOAD_INSTRUCTION_DONE(w_scu_load_instruction_done),
		// BRAM Bank part
		.O_LOAD_INSTRUCTION_POINTER(w_do_load_instruction_pointer),
		.O_LOAD_INSTRUCTION_VALID(w_do_load_instruction_valid),
		.O_LOAD_INSTRUCTION_DATA(w_do_load_instruction_data),

		// Load Input Module
		// SCU part
		.I_LI_START(w_scu_li_start),
		.I_LI_NO_OF_ROW(w_scu_li_no_of_row),
		.I_LI_START_POINTER(w_scu_li_start_pointer),
		.I_LI_SEL(w_scu_li_sel),
		.O_LI_DONE(w_scu_li_done),
		// BRAM Bank part
		.O_LI_POINTER(w_do_li_pointer),
		.O_LI_VALID(w_do_li_valid),
		.O_LI_DATA(w_do_li_data),
		.O_LI_SEL(w_do_li_sel),

		// Stream Out Module
		// SCU part
		.I_SO_START(w_scu_so_start),
		.I_SO_START_POINTER(w_scu_so_start_pointer),
		.I_SO_END_POINTER(w_scu_so_end_pointer),
		.O_SO_DONE(w_scu_so_done),
		// BRAM part
		.O_SO_NOW(w_do_so_now),
		.O_SO_BRAM_SEL(w_do_so_bram_sel),
		.O_SO_POINTER(w_do_so_pointer)
	);

	// BRAM bank unit
	bram_bank bram_bank_unit
	(
		// Clock and reset
		// Input ports
		.I_ACLK(I_ACLK),
		.I_ARESETN(I_ARESETN),

		// Debug channel
		.I_BRAM_MODE_DEBUG(I_BRAM_MODE_DEBUG),
		.I_BRAM_DEBUG_ADDR(I_BRAM_DEBUG_ADDR[13:0]),

		// Instruction BRAM
		// Input
		.I_LOAD_INSTRUCTION_POINTER(w_do_load_instruction_pointer),
		.I_LOAD_INSTRUCTION_VALID(w_do_load_instruction_valid),
		.I_LOAD_INSTRUCTION_DATA(w_do_load_instruction_data),
		// Output
		.I_PROGRAM_COUNTER(w_scu_program_counter),
		.O_PROGRAM_INSTRUCTION(w_scu_instruction_data),
		.O_BRAM_DEBUG_INSTRUCTION(O_BRAM_DEBUG_INSTRUCTION),

		// Input BRAM
		.I_LI_POINTER(w_do_li_pointer),
		.I_LI_VALID(w_do_li_valid),
		.I_LI_DATA(w_do_li_data),
		.I_LI_SEL(w_do_li_sel),
		.I_SORT_DATA_0_POINTER_A(),
		.I_SORT_DATA_0_POINTER_B(),
		.I_SORT_DATA_1_POINTER_A(),
		.I_SORT_DATA_1_POINTER_B(),
		.I_SORT_DATA_2_POINTER_A(),
		.I_SORT_DATA_2_POINTER_B(),
		.I_SORT_DATA_3_POINTER_A(),
		.I_SORT_DATA_3_POINTER_B(),
		.I_SORT_DATA_4_POINTER_A(),
		.I_SORT_DATA_4_POINTER_B(),
		.I_SORT_DATA_5_POINTER_A(),
		.I_SORT_DATA_5_POINTER_B(),
		.I_SORT_DATA_6_POINTER_A(),
		.I_SORT_DATA_6_POINTER_B(),
		.I_SORT_DATA_7_POINTER_A(),
		.I_SORT_DATA_7_POINTER_B(),
		.I_SORT_DATA_8_POINTER_A(),
		.I_SORT_DATA_8_POINTER_B(),
		.I_SORT_DATA_9_POINTER_A(),
		.I_SORT_DATA_9_POINTER_B(),
		.I_SORT_DATA_10_POINTER_A(),
		.I_SORT_DATA_10_POINTER_B(),
		.I_SORT_DATA_11_POINTER_A(),
		.I_SORT_DATA_11_POINTER_B(),
		.I_SORT_DATA_12_POINTER_A(),
		.I_SORT_DATA_12_POINTER_B(),
		.I_SORT_DATA_13_POINTER_A(),
		.I_SORT_DATA_13_POINTER_B(),
		.I_SORT_DATA_14_POINTER_A(),
		.I_SORT_DATA_14_POINTER_B(),
		.I_SORT_DATA_15_POINTER_A(),
		.I_SORT_DATA_15_POINTER_B(),
		.I_SORT_DATA_16_POINTER_A(),
		.I_SORT_DATA_16_POINTER_B(),
		.I_SORT_DATA_17_POINTER_A(),
		.I_SORT_DATA_17_POINTER_B(),
		.I_SORT_DATA_18_POINTER_A(),
		.I_SORT_DATA_18_POINTER_B(),
		.I_SORT_DATA_19_POINTER_A(),
		.I_SORT_DATA_19_POINTER_B(),
		.I_SORT_DATA_20_POINTER_A(),
		.I_SORT_DATA_20_POINTER_B(),
		.I_SORT_DATA_21_POINTER_A(),
		.I_SORT_DATA_21_POINTER_B(),
		.I_SORT_DATA_22_POINTER_A(),
		.I_SORT_DATA_22_POINTER_B(),
		.I_SORT_DATA_23_POINTER_A(),
		.I_SORT_DATA_23_POINTER_B(),
		.I_SORT_DATA_24_POINTER_A(),
		.I_SORT_DATA_24_POINTER_B(),
		.I_SORT_DATA_25_POINTER_A(),
		.I_SORT_DATA_25_POINTER_B(),
		.I_SORT_DATA_26_POINTER_A(),
		.I_SORT_DATA_26_POINTER_B(),
		.I_SORT_DATA_27_POINTER_A(),
		.I_SORT_DATA_27_POINTER_B(),
		.I_SORT_DATA_28_POINTER_A(),
		.I_SORT_DATA_28_POINTER_B(),
		.I_SORT_DATA_29_POINTER_A(),
		.I_SORT_DATA_29_POINTER_B(),
		.I_SORT_DATA_30_POINTER_A(),
		.I_SORT_DATA_30_POINTER_B(),
		.I_SORT_DATA_31_POINTER_A(),
		.I_SORT_DATA_31_POINTER_B(),
		.I_SORT_DATA_32_POINTER_A(),
		.I_SORT_DATA_32_POINTER_B(),
		.I_SORT_DATA_33_POINTER_A(),
		.I_SORT_DATA_33_POINTER_B(),
		.I_SORT_DATA_34_POINTER_A(),
		.I_SORT_DATA_34_POINTER_B(),
		.I_SORT_DATA_35_POINTER_A(),
		.I_SORT_DATA_35_POINTER_B(),
		.I_SORT_DATA_36_POINTER_A(),
		.I_SORT_DATA_36_POINTER_B(),
		.I_SORT_DATA_37_POINTER_A(),
		.I_SORT_DATA_37_POINTER_B(),
		.I_SORT_DATA_38_POINTER_A(),
		.I_SORT_DATA_38_POINTER_B(),
		.I_SORT_DATA_39_POINTER_A(),
		.I_SORT_DATA_39_POINTER_B(),
		.I_SORT_DATA_40_POINTER_A(),
		.I_SORT_DATA_40_POINTER_B(),
		.I_SORT_DATA_41_POINTER_A(),
		.I_SORT_DATA_41_POINTER_B(),
		.I_SORT_DATA_42_POINTER_A(),
		.I_SORT_DATA_42_POINTER_B(),
		.I_SORT_DATA_43_POINTER_A(),
		.I_SORT_DATA_43_POINTER_B(),
		.I_SORT_DATA_44_POINTER_A(),
		.I_SORT_DATA_44_POINTER_B(),
		.I_SORT_DATA_45_POINTER_A(),
		.I_SORT_DATA_45_POINTER_B(),
		.I_SORT_DATA_46_POINTER_A(),
		.I_SORT_DATA_46_POINTER_B(),
		.I_SORT_DATA_47_POINTER_A(),
		.I_SORT_DATA_47_POINTER_B(),
		.I_SORT_DATA_48_POINTER_A(),
		.I_SORT_DATA_48_POINTER_B(),
		.I_SORT_DATA_49_POINTER_A(),
		.I_SORT_DATA_49_POINTER_B(),
		.I_SORT_DATA_50_POINTER_A(),
		.I_SORT_DATA_50_POINTER_B(),
		.I_SORT_DATA_51_POINTER_A(),
		.I_SORT_DATA_51_POINTER_B(),
		.I_SORT_DATA_52_POINTER_A(),
		.I_SORT_DATA_52_POINTER_B(),
		.I_SORT_DATA_53_POINTER_A(),
		.I_SORT_DATA_53_POINTER_B(),
		.I_SORT_DATA_54_POINTER_A(),
		.I_SORT_DATA_54_POINTER_B(),
		.I_SORT_DATA_55_POINTER_A(),
		.I_SORT_DATA_55_POINTER_B(),
		.I_SORT_DATA_56_POINTER_A(),
		.I_SORT_DATA_56_POINTER_B(),
		.I_SORT_DATA_57_POINTER_A(),
		.I_SORT_DATA_57_POINTER_B(),
		.I_SORT_DATA_58_POINTER_A(),
		.I_SORT_DATA_58_POINTER_B(),
		.I_SORT_DATA_59_POINTER_A(),
		.I_SORT_DATA_59_POINTER_B(),
		.I_SORT_DATA_60_POINTER_A(),
		.I_SORT_DATA_60_POINTER_B(),
		.I_SORT_DATA_61_POINTER_A(),
		.I_SORT_DATA_61_POINTER_B(),
		.I_SORT_DATA_62_POINTER_A(),
		.I_SORT_DATA_62_POINTER_B(),
		.I_SORT_DATA_63_POINTER_A(),
		.I_SORT_DATA_63_POINTER_B(),
		.I_SORT_DATA_64_POINTER_A(),
		.I_SORT_DATA_64_POINTER_B(),
		.I_SORT_DATA_65_POINTER_A(),
		.I_SORT_DATA_65_POINTER_B(),
		.I_SORT_DATA_66_POINTER_A(),
		.I_SORT_DATA_66_POINTER_B(),
		.I_SORT_DATA_67_POINTER_A(),
		.I_SORT_DATA_67_POINTER_B(),
		.I_SORT_DATA_68_POINTER_A(),
		.I_SORT_DATA_68_POINTER_B(),
		.I_SORT_DATA_69_POINTER_A(),
		.I_SORT_DATA_69_POINTER_B(),
		.I_SORT_DATA_70_POINTER_A(),
		.I_SORT_DATA_70_POINTER_B(),
		.I_SORT_DATA_71_POINTER_A(),
		.I_SORT_DATA_71_POINTER_B(),
		.I_SORT_DATA_72_POINTER_A(),
		.I_SORT_DATA_72_POINTER_B(),
		.I_SORT_DATA_73_POINTER_A(),
		.I_SORT_DATA_73_POINTER_B(),
		.I_SORT_DATA_74_POINTER_A(),
		.I_SORT_DATA_74_POINTER_B(),
		.I_SORT_DATA_75_POINTER_A(),
		.I_SORT_DATA_75_POINTER_B(),
		.I_SORT_DATA_76_POINTER_A(),
		.I_SORT_DATA_76_POINTER_B(),
		.I_SORT_DATA_77_POINTER_A(),
		.I_SORT_DATA_77_POINTER_B(),
		.I_SORT_DATA_78_POINTER_A(),
		.I_SORT_DATA_78_POINTER_B(),
		.I_SORT_DATA_79_POINTER_A(),
		.I_SORT_DATA_79_POINTER_B(),
		// Sort data output
		.O_SORT_DATA_0_A(),
		.O_SORT_DATA_0_B(),
		.O_SORT_DATA_1_A(),
		.O_SORT_DATA_1_B(),
		.O_SORT_DATA_2_A(),
		.O_SORT_DATA_2_B(),
		.O_SORT_DATA_3_A(),
		.O_SORT_DATA_3_B(),
		.O_SORT_DATA_4_A(),
		.O_SORT_DATA_4_B(),
		.O_SORT_DATA_5_A(),
		.O_SORT_DATA_5_B(),
		.O_SORT_DATA_6_A(),
		.O_SORT_DATA_6_B(),
		.O_SORT_DATA_7_A(),
		.O_SORT_DATA_7_B(),
		.O_SORT_DATA_8_A(),
		.O_SORT_DATA_8_B(),
		.O_SORT_DATA_9_A(),
		.O_SORT_DATA_9_B(),
		.O_SORT_DATA_10_A(),
		.O_SORT_DATA_10_B(),
		.O_SORT_DATA_11_A(),
		.O_SORT_DATA_11_B(),
		.O_SORT_DATA_12_A(),
		.O_SORT_DATA_12_B(),
		.O_SORT_DATA_13_A(),
		.O_SORT_DATA_13_B(),
		.O_SORT_DATA_14_A(),
		.O_SORT_DATA_14_B(),
		.O_SORT_DATA_15_A(),
		.O_SORT_DATA_15_B(),
		.O_SORT_DATA_16_A(),
		.O_SORT_DATA_16_B(),
		.O_SORT_DATA_17_A(),
		.O_SORT_DATA_17_B(),
		.O_SORT_DATA_18_A(),
		.O_SORT_DATA_18_B(),
		.O_SORT_DATA_19_A(),
		.O_SORT_DATA_19_B(),
		.O_SORT_DATA_20_A(),
		.O_SORT_DATA_20_B(),
		.O_SORT_DATA_21_A(),
		.O_SORT_DATA_21_B(),
		.O_SORT_DATA_22_A(),
		.O_SORT_DATA_22_B(),
		.O_SORT_DATA_23_A(),
		.O_SORT_DATA_23_B(),
		.O_SORT_DATA_24_A(),
		.O_SORT_DATA_24_B(),
		.O_SORT_DATA_25_A(),
		.O_SORT_DATA_25_B(),
		.O_SORT_DATA_26_A(),
		.O_SORT_DATA_26_B(),
		.O_SORT_DATA_27_A(),
		.O_SORT_DATA_27_B(),
		.O_SORT_DATA_28_A(),
		.O_SORT_DATA_28_B(),
		.O_SORT_DATA_29_A(),
		.O_SORT_DATA_29_B(),
		.O_SORT_DATA_30_A(),
		.O_SORT_DATA_30_B(),
		.O_SORT_DATA_31_A(),
		.O_SORT_DATA_31_B(),
		.O_SORT_DATA_32_A(),
		.O_SORT_DATA_32_B(),
		.O_SORT_DATA_33_A(),
		.O_SORT_DATA_33_B(),
		.O_SORT_DATA_34_A(),
		.O_SORT_DATA_34_B(),
		.O_SORT_DATA_35_A(),
		.O_SORT_DATA_35_B(),
		.O_SORT_DATA_36_A(),
		.O_SORT_DATA_36_B(),
		.O_SORT_DATA_37_A(),
		.O_SORT_DATA_37_B(),
		.O_SORT_DATA_38_A(),
		.O_SORT_DATA_38_B(),
		.O_SORT_DATA_39_A(),
		.O_SORT_DATA_39_B(),
		.O_SORT_DATA_40_A(),
		.O_SORT_DATA_40_B(),
		.O_SORT_DATA_41_A(),
		.O_SORT_DATA_41_B(),
		.O_SORT_DATA_42_A(),
		.O_SORT_DATA_42_B(),
		.O_SORT_DATA_43_A(),
		.O_SORT_DATA_43_B(),
		.O_SORT_DATA_44_A(),
		.O_SORT_DATA_44_B(),
		.O_SORT_DATA_45_A(),
		.O_SORT_DATA_45_B(),
		.O_SORT_DATA_46_A(),
		.O_SORT_DATA_46_B(),
		.O_SORT_DATA_47_A(),
		.O_SORT_DATA_47_B(),
		.O_SORT_DATA_48_A(),
		.O_SORT_DATA_48_B(),
		.O_SORT_DATA_49_A(),
		.O_SORT_DATA_49_B(),
		.O_SORT_DATA_50_A(),
		.O_SORT_DATA_50_B(),
		.O_SORT_DATA_51_A(),
		.O_SORT_DATA_51_B(),
		.O_SORT_DATA_52_A(),
		.O_SORT_DATA_52_B(),
		.O_SORT_DATA_53_A(),
		.O_SORT_DATA_53_B(),
		.O_SORT_DATA_54_A(),
		.O_SORT_DATA_54_B(),
		.O_SORT_DATA_55_A(),
		.O_SORT_DATA_55_B(),
		.O_SORT_DATA_56_A(),
		.O_SORT_DATA_56_B(),
		.O_SORT_DATA_57_A(),
		.O_SORT_DATA_57_B(),
		.O_SORT_DATA_58_A(),
		.O_SORT_DATA_58_B(),
		.O_SORT_DATA_59_A(),
		.O_SORT_DATA_59_B(),
		.O_SORT_DATA_60_A(),
		.O_SORT_DATA_60_B(),
		.O_SORT_DATA_61_A(),
		.O_SORT_DATA_61_B(),
		.O_SORT_DATA_62_A(),
		.O_SORT_DATA_62_B(),
		.O_SORT_DATA_63_A(),
		.O_SORT_DATA_63_B(),
		.O_SORT_DATA_64_A(),
		.O_SORT_DATA_64_B(),
		.O_SORT_DATA_65_A(),
		.O_SORT_DATA_65_B(),
		.O_SORT_DATA_66_A(),
		.O_SORT_DATA_66_B(),
		.O_SORT_DATA_67_A(),
		.O_SORT_DATA_67_B(),
		.O_SORT_DATA_68_A(),
		.O_SORT_DATA_68_B(),
		.O_SORT_DATA_69_A(),
		.O_SORT_DATA_69_B(),
		.O_SORT_DATA_70_A(),
		.O_SORT_DATA_70_B(),
		.O_SORT_DATA_71_A(),
		.O_SORT_DATA_71_B(),
		.O_SORT_DATA_72_A(),
		.O_SORT_DATA_72_B(),
		.O_SORT_DATA_73_A(),
		.O_SORT_DATA_73_B(),
		.O_SORT_DATA_74_A(),
		.O_SORT_DATA_74_B(),
		.O_SORT_DATA_75_A(),
		.O_SORT_DATA_75_B(),
		.O_SORT_DATA_76_A(),
		.O_SORT_DATA_76_B(),
		.O_SORT_DATA_77_A(),
		.O_SORT_DATA_77_B(),
		.O_SORT_DATA_78_A(),
		.O_SORT_DATA_78_B(),
		.O_SORT_DATA_79_A(),
		.O_SORT_DATA_79_B(),

		// Stream Out port
		// Input ports
		.I_SO_NOW(w_do_so_now),
		.I_SO_BRAM_SEL(w_do_so_bram_sel),
		.I_SO_POINTER(w_do_so_pointer),
		// Output port
		.O_SO_DATA(O_STREAM_FIFO)
	);

	////////////////////////////////////////
	//    Output Port Value Assignment    //
	////////////////////////////////////////
	always @(posedge I_ACLK)
	begin
		if (!I_ARESETN)
		begin
			O_PROGRAM_COUNTER <= 0;
		end
		else
		begin
			O_PROGRAM_COUNTER <= {19'd0, w_scu_program_counter};
		end
	end

	endmodule
