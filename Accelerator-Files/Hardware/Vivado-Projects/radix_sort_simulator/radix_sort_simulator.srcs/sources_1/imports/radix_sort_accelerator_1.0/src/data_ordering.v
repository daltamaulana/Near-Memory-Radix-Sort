//********************************************************************************
//                      [ MODULE ]                                                
//                                                                                
// Institution       : Korea Advanced Institute of Science and Technology         
// Engineer          : Dalta Imam Maulana                                         
//                                                                                
// Project Name      : Near Memory Radix Sort                                     
//                                                                                
// Create Date       : 6/21/2021
// File Name         : data_ordering.v                                           
// Module Dependency : -                                                          
//                                                                                
// Target Device     : ZCU104                                                     
// Tool Version      : Vivado 2020.1                                              
//                                                                                
// Description:                                                                   
//      Module for controlling data movement from BRAM to DRAM                    
//                                                                                
//********************************************************************************
`timescale 1ns / 1ps

module data_ordering
	////////////////////////////////////////
	//  Ports and Parameters Declaration  //
	////////////////////////////////////////
	// Declare parameters
	#(
		parameter DWIDTH =128,
		parameter SELWIDTH =10,
		parameter INSTWIDTH =64,
		parameter DATABRAMDEPTH =1024,
		parameter DATAADDRWIDTH =11,
		parameter INSTADDRWIDTH =10
	)
	// Declare ports
	(
		// Clock and Reset
		input wire          I_ACLK,
		input wire          I_ARESETN,

		// Stream In Channel
		output wire         O_STREAM_DEQUEUE,
		input wire          I_STREAM_VALID,
		input wire  [DWIDTH-1:0] I_STREAM_DATA,

		// Stream Out Channel
		output wire         O_STREAM_QUEUE,
		input wire          I_STREAM_FULL,

		// Load Instruction Module
		// SCU part
		input wire          I_LOAD_INSTRUCTION_START,
		output wire         O_LOAD_INSTRUCTION_DONE,
		// BRAM Bank part
		output wire [INSTADDRWIDTH-1:0]  O_LOAD_INSTRUCTION_POINTER,
		output wire         O_LOAD_INSTRUCTION_VALID,
		output wire [DWIDTH-1:0] O_LOAD_INSTRUCTION_DATA,

		// Load Input Module
		// SCU part
		input wire          I_LI_START,
		input wire  [31:0]  I_LI_NO_OF_ROW,
		input wire  [DATAADDRWIDTH-1:0]  I_LI_START_POINTER,
		input wire  [SELWIDTH-1:0]   I_LI_SEL,
		output wire         O_LI_DONE,
		// BRAM Bank part
		output wire [DATAADDRWIDTH-1:0]  O_LI_POINTER,
		output wire         O_LI_VALID,
		output wire [DWIDTH-1:0] O_LI_DATA,
		output wire [SELWIDTH-1:0]   O_LI_SEL,

		// Stream Out Module
		// SCU part
		input wire          I_SO_START,
		input wire  [DATAADDRWIDTH-1:0]  I_SO_START_POINTER, // 3 bit
		input wire  [DATAADDRWIDTH-1:0]  I_SO_END_POINTER, // 3 bit
		output wire         O_SO_DONE,
		// BRAM part
		output wire         O_SO_NOW,
		output wire [SELWIDTH-1:0]   O_SO_BRAM_SEL,
		output wire [DATAADDRWIDTH-1:0]  O_SO_POINTER
	);

	///////////////////////////////////////////////////////////////
	//				  Load Instruction Module                  //
	///////////////////////////////////////////////////////////////
	// Declare wire
	wire w_load_instruction_dequeue;

	// Module instantiation
	load_instruction_module load_instruction_module
	(
		// Clock and Reset
		.I_ACLK(I_ACLK),
		.I_ARESETN(I_ARESETN),
		// Stream In
		.O_STREAM_DEQUEUE(w_load_instruction_dequeue),
		.I_STREAM_VALID(I_STREAM_VALID),
		.I_STREAM_DATA(I_STREAM_DATA),
		// SCU part
		.I_START(I_LOAD_INSTRUCTION_START),
		.O_DONE(O_LOAD_INSTRUCTION_DONE),
		// BRAM Bank
		.O_LOAD_INSTRUCTION_POINTER(O_LOAD_INSTRUCTION_POINTER),
		.O_LOAD_INSTRUCTION_VALID(O_LOAD_INSTRUCTION_VALID),
		.O_LOAD_INSTRUCTION_DATA(O_LOAD_INSTRUCTION_DATA)
	);

	////////////////////////////////////////////////////////////
	//                    Load Input Module                   //
	////////////////////////////////////////////////////////////
	// Declare wire
	wire w_load_input_dequeue;

	// Module instantiation
	load_input_module load_input_module
	(
		// Clock and Reset
		.I_ACLK(I_ACLK),
		.I_ARESETN(I_ARESETN),
		// Stream In
		.O_STREAM_DEQUEUE(w_load_input_dequeue),
		.I_STREAM_VALID(I_STREAM_VALID),
		.I_STREAM_DATA(I_STREAM_DATA),
		// SCU part
		.I_START(I_LI_START),
		.I_NO_OF_ROW(I_LI_NO_OF_ROW),
		.I_START_POINTER(I_LI_START_POINTER[DATAADDRWIDTH-1:0]),
		.I_SEL(I_LI_SEL),
		.O_DONE(O_LI_DONE),
		// BRAM Bank
		.O_LI_POINTER(O_LI_POINTER[DATAADDRWIDTH-1:0]),
		.O_LI_VALID(O_LI_VALID),
		.O_LI_DATA(O_LI_DATA),
		.O_LI_SEL(O_LI_SEL)
	);

	////////////////////////////////////////////////////////////
	//                    Stream Out Module                   //
	////////////////////////////////////////////////////////////
	// Declare wire
	wire w_so_queue;
	wire w_so_send_now;

	// Assign value to output port
	assign O_SO_NOW = w_so_send_now;

	// Module instantiation
	stream_out_module stream_out_module
	(
		// Clock and Reset
		.I_ACLK(I_ACLK),
		.I_ARESETN(I_ARESETN),
		// SCU
		.I_START(I_SO_START),
		.I_START_POINTER(I_SO_START_POINTER),
		.I_END_POINTER(I_SO_END_POINTER),
		.O_DONE(O_SO_DONE),
		// BRAM Bank
		.O_BRAM_SEL(O_SO_BRAM_SEL),
		.O_SEND_DATA_POINTER(O_SO_POINTER),
		// Send Data
		.I_STREAM_FULL(I_STREAM_FULL),
		.O_STREAM_QUEUE(w_so_queue),
		.O_STREAM_SEND_NOW(w_so_send_now)
	);

	///////////////////////////////////////////////////////////////////////
	//                    Output Port Value Assignment                   //
	///////////////////////////////////////////////////////////////////////
	assign O_STREAM_QUEUE = w_so_queue;
	assign O_STREAM_DEQUEUE = w_load_instruction_dequeue || w_load_input_dequeue;

	endmodule
