//********************************************************************************
//                      [ MODULE ]                                                
//                                                                                
// Institution       : Korea Advanced Institute of Science and Technology         
// Engineer          : Dalta Imam Maulana                                         
//                                                                                
// Project Name      : Near Memory Radix Sort                                     
//                                                                                
// Create Date       : 6/14/2021
// File Name         : bram_bank.v                                           
// Module Dependency : -                                                          
//                                                                                
// Target Device     : ZCU104                                                     
// Tool Version      : Vivado 2020.1                                              
//                                                                                
// Description:                                                                   
//      BRAM Bank for storing instruction, unsorted data, and sorted result       
//                                                                                
//********************************************************************************
`timescale 1ns / 1ps

module bram_bank
	////////////////////////////////////////
	//  Ports and Parameters Declaration  //
	////////////////////////////////////////
	// Declare parameters
	#(
		parameter DWIDTH =128,
		parameter SELWIDTH =10,
		parameter INSTWIDTH =64,
		parameter DATABRAMDEPTH =1024,
		parameter DATAADDRWIDTH =15,
		parameter INSTADDRWIDTH =10
	)
	// Declare module ports
	(
		// Input ports
		input wire I_ACLK,
		input wire I_ARESETN,

		// Debug channel
		input wire [2:0] I_BRAM_MODE_DEBUG,
		input wire [DATAADDRWIDTH-1:0] I_BRAM_DEBUG_ADDR,

		// Instruction BRAM
		// Input
		input wire [INSTADDRWIDTH-1:0] I_LOAD_INSTRUCTION_POINTER,
		input wire I_LOAD_INSTRUCTION_VALID,
		input wire [DWIDTH-1:0] I_LOAD_INSTRUCTION_DATA,
		input wire [INSTADDRWIDTH-1:0] I_PROGRAM_COUNTER,
		// Output
		output wire [INSTWIDTH-1:0] O_PROGRAM_INSTRUCTION,
		output reg [INSTWIDTH-1:0] O_BRAM_DEBUG_INSTRUCTION,

		// Input BRAM
		input wire [DATAADDRWIDTH-1:0] I_LI_POINTER,
		input wire I_LI_VALID,
		input wire [DWIDTH-1:0] I_LI_DATA,
		input wire [SELWIDTH-1:0] I_LI_SEL,
		// Sort data pointer
		input wire  [DATAADDRWIDTH-1:0] I_SORT_DATA_0_POINTER_A,
		input wire  [DATAADDRWIDTH-1:0] I_SORT_DATA_0_POINTER_B,
		input wire  [DATAADDRWIDTH-1:0] I_SORT_DATA_1_POINTER_A,
		input wire  [DATAADDRWIDTH-1:0] I_SORT_DATA_1_POINTER_B,
		input wire  [DATAADDRWIDTH-1:0] I_SORT_DATA_2_POINTER_A,
		input wire  [DATAADDRWIDTH-1:0] I_SORT_DATA_2_POINTER_B,
		input wire  [DATAADDRWIDTH-1:0] I_SORT_DATA_3_POINTER_A,
		input wire  [DATAADDRWIDTH-1:0] I_SORT_DATA_3_POINTER_B,
		input wire  [DATAADDRWIDTH-1:0] I_SORT_DATA_4_POINTER_A,
		input wire  [DATAADDRWIDTH-1:0] I_SORT_DATA_4_POINTER_B,
		input wire  [DATAADDRWIDTH-1:0] I_SORT_DATA_5_POINTER_A,
		input wire  [DATAADDRWIDTH-1:0] I_SORT_DATA_5_POINTER_B,
		input wire  [DATAADDRWIDTH-1:0] I_SORT_DATA_6_POINTER_A,
		input wire  [DATAADDRWIDTH-1:0] I_SORT_DATA_6_POINTER_B,
		input wire  [DATAADDRWIDTH-1:0] I_SORT_DATA_7_POINTER_A,
		input wire  [DATAADDRWIDTH-1:0] I_SORT_DATA_7_POINTER_B,
		input wire  [DATAADDRWIDTH-1:0] I_SORT_DATA_8_POINTER_A,
		input wire  [DATAADDRWIDTH-1:0] I_SORT_DATA_8_POINTER_B,
		input wire  [DATAADDRWIDTH-1:0] I_SORT_DATA_9_POINTER_A,
		input wire  [DATAADDRWIDTH-1:0] I_SORT_DATA_9_POINTER_B,
		input wire  [DATAADDRWIDTH-1:0] I_SORT_DATA_10_POINTER_A,
		input wire  [DATAADDRWIDTH-1:0] I_SORT_DATA_10_POINTER_B,
		input wire  [DATAADDRWIDTH-1:0] I_SORT_DATA_11_POINTER_A,
		input wire  [DATAADDRWIDTH-1:0] I_SORT_DATA_11_POINTER_B,
		input wire  [DATAADDRWIDTH-1:0] I_SORT_DATA_12_POINTER_A,
		input wire  [DATAADDRWIDTH-1:0] I_SORT_DATA_12_POINTER_B,
		input wire  [DATAADDRWIDTH-1:0] I_SORT_DATA_13_POINTER_A,
		input wire  [DATAADDRWIDTH-1:0] I_SORT_DATA_13_POINTER_B,
		input wire  [DATAADDRWIDTH-1:0] I_SORT_DATA_14_POINTER_A,
		input wire  [DATAADDRWIDTH-1:0] I_SORT_DATA_14_POINTER_B,
		input wire  [DATAADDRWIDTH-1:0] I_SORT_DATA_15_POINTER_A,
		input wire  [DATAADDRWIDTH-1:0] I_SORT_DATA_15_POINTER_B,
		input wire  [DATAADDRWIDTH-1:0] I_SORT_DATA_16_POINTER_A,
		input wire  [DATAADDRWIDTH-1:0] I_SORT_DATA_16_POINTER_B,
		input wire  [DATAADDRWIDTH-1:0] I_SORT_DATA_17_POINTER_A,
		input wire  [DATAADDRWIDTH-1:0] I_SORT_DATA_17_POINTER_B,
		input wire  [DATAADDRWIDTH-1:0] I_SORT_DATA_18_POINTER_A,
		input wire  [DATAADDRWIDTH-1:0] I_SORT_DATA_18_POINTER_B,
		input wire  [DATAADDRWIDTH-1:0] I_SORT_DATA_19_POINTER_A,
		input wire  [DATAADDRWIDTH-1:0] I_SORT_DATA_19_POINTER_B,
		// Sort data output
		output wire [DWIDTH-1:0] O_SORT_DATA_0_A,
		output wire [DWIDTH-1:0] O_SORT_DATA_0_B,
		output wire [DWIDTH-1:0] O_SORT_DATA_1_A,
		output wire [DWIDTH-1:0] O_SORT_DATA_1_B,
		output wire [DWIDTH-1:0] O_SORT_DATA_2_A,
		output wire [DWIDTH-1:0] O_SORT_DATA_2_B,
		output wire [DWIDTH-1:0] O_SORT_DATA_3_A,
		output wire [DWIDTH-1:0] O_SORT_DATA_3_B,
		output wire [DWIDTH-1:0] O_SORT_DATA_4_A,
		output wire [DWIDTH-1:0] O_SORT_DATA_4_B,
		output wire [DWIDTH-1:0] O_SORT_DATA_5_A,
		output wire [DWIDTH-1:0] O_SORT_DATA_5_B,
		output wire [DWIDTH-1:0] O_SORT_DATA_6_A,
		output wire [DWIDTH-1:0] O_SORT_DATA_6_B,
		output wire [DWIDTH-1:0] O_SORT_DATA_7_A,
		output wire [DWIDTH-1:0] O_SORT_DATA_7_B,
		output wire [DWIDTH-1:0] O_SORT_DATA_8_A,
		output wire [DWIDTH-1:0] O_SORT_DATA_8_B,
		output wire [DWIDTH-1:0] O_SORT_DATA_9_A,
		output wire [DWIDTH-1:0] O_SORT_DATA_9_B,
		output wire [DWIDTH-1:0] O_SORT_DATA_10_A,
		output wire [DWIDTH-1:0] O_SORT_DATA_10_B,
		output wire [DWIDTH-1:0] O_SORT_DATA_11_A,
		output wire [DWIDTH-1:0] O_SORT_DATA_11_B,
		output wire [DWIDTH-1:0] O_SORT_DATA_12_A,
		output wire [DWIDTH-1:0] O_SORT_DATA_12_B,
		output wire [DWIDTH-1:0] O_SORT_DATA_13_A,
		output wire [DWIDTH-1:0] O_SORT_DATA_13_B,
		output wire [DWIDTH-1:0] O_SORT_DATA_14_A,
		output wire [DWIDTH-1:0] O_SORT_DATA_14_B,
		output wire [DWIDTH-1:0] O_SORT_DATA_15_A,
		output wire [DWIDTH-1:0] O_SORT_DATA_15_B,
		output wire [DWIDTH-1:0] O_SORT_DATA_16_A,
		output wire [DWIDTH-1:0] O_SORT_DATA_16_B,
		output wire [DWIDTH-1:0] O_SORT_DATA_17_A,
		output wire [DWIDTH-1:0] O_SORT_DATA_17_B,
		output wire [DWIDTH-1:0] O_SORT_DATA_18_A,
		output wire [DWIDTH-1:0] O_SORT_DATA_18_B,
		output wire [DWIDTH-1:0] O_SORT_DATA_19_A,
		output wire [DWIDTH-1:0] O_SORT_DATA_19_B,

		// Stream Out port
		// Input ports
		input wire I_SO_NOW,
		input wire [SELWIDTH-1:0] I_SO_BRAM_SEL,
		input wire [DATAADDRWIDTH-1:0] I_SO_POINTER,
		// Output port
		output reg [DWIDTH-1:0] O_SO_DATA
	);
	////////////////////////////////////
	//        Instruction BRAM        //
	////////////////////////////////////
	// Declare wires
	wire [INSTADDRWIDTH-1:0] w_instruction_pointer_a;
	wire [INSTADDRWIDTH-1:0] w_instruction_pointer_b;
	wire [INSTWIDTH-1:0] w_out_instruction_a;
	wire [INSTWIDTH-1:0] w_out_instruction_b;

	// Assign value to wires
	assign w_instruction_pointer_a = I_LOAD_INSTRUCTION_VALID ? I_LOAD_INSTRUCTION_POINTER : I_PROGRAM_COUNTER;
	assign w_instruction_pointer_b = I_LOAD_INSTRUCTION_VALID ? I_LOAD_INSTRUCTION_POINTER+1 : I_BRAM_DEBUG_ADDR;

	// Instantiate module
	bram_tdp #(
		.DWIDTH(INSTWIDTH),
		.DEPTH(1024),
		.ADDR_BIT(INSTADDRWIDTH)
	) instruction_bram (
		.clk_a(I_ACLK),
		.clk_b(I_ACLK),
		.en_a(1'b1),
		.en_b(1'b1),
		.we_a(I_LOAD_INSTRUCTION_VALID),
		.we_b(I_LOAD_INSTRUCTION_VALID),
		.addr_a(w_instruction_pointer_a),
		.addr_b(w_instruction_pointer_b),
		.d_in_a(I_LOAD_INSTRUCTION_DATA[63:0]),
		.d_in_b(I_LOAD_INSTRUCTION_DATA[127:64]),
		.d_out_a(w_out_instruction_a),
		.d_out_b(w_out_instruction_b)
	);

	// Set output instruction port value
	// Program instruction
	assign O_PROGRAM_INSTRUCTION = w_out_instruction_a;
	// Debug instruction
	always @(posedge I_ACLK)
	begin
		if (!I_ARESETN)
		begin
			O_BRAM_DEBUG_INSTRUCTION <= 0;
		end
		else
		begin
			O_BRAM_DEBUG_INSTRUCTION <= w_out_instruction_b;
		end
	end

	///////////////////////////////////
	//        Input Data BRAM        //
	///////////////////////////////////
	// Input BRAM 0
	// Declare wires
	wire w_sort_data_0_valid = I_LI_VALID && (I_LI_SEL == 10'b0000000000);
	wire w_sort_data_0_debug = I_BRAM_MODE_DEBUG == 3'b111;
	wire [DATAADDRWIDTH-1:0] sort_data_0_pointer_a = w_sort_data_0_valid ? I_LI_POINTER : I_SORT_DATA_0_POINTER_A;
	wire [DATAADDRWIDTH-1:0] sort_data_0_pointer_b = w_sort_data_0_debug ? I_BRAM_DEBUG_ADDR : (I_SO_NOW && (I_SO_BRAM_SEL == 10'b0000000000)) ? I_SO_POINTER: I_SORT_DATA_0_POINTER_B;
	wire [DWIDTH-1:0] w_sort_data_0_out_a;
	wire [DWIDTH-1:0] w_sort_data_0_out_b;

	// Instantiate module
	bram_tdp #(
		.DWIDTH(DWIDTH),
		.DEPTH(DATABRAMDEPTH),
		.ADDR_BIT(DATAADDRWIDTH)
	) sort_data_0_bram (
		.clk_a(I_ACLK),
		.clk_b(I_ACLK),
		.en_a(1'b1),
		.en_b(1'b1),
		.we_a(w_sort_data_0_valid),
		.we_b(1'b0),
		.addr_a(sort_data_0_pointer_a),
		.addr_b(sort_data_0_pointer_b),
		.d_in_a(I_LI_DATA),
		.d_in_b(128'd0),
		.d_out_a(w_sort_data_0_out_a),
		.d_out_b(w_sort_data_0_out_b)
	);

	// Assign value to output
	assign O_SORT_DATA_0_A = w_sort_data_0_out_a;
	assign O_SORT_DATA_0_B = w_sort_data_0_out_b;

	// Input BRAM 1
	// Declare wires
	wire w_sort_data_1_valid = I_LI_VALID && (I_LI_SEL == 10'b0000000001);
	wire w_sort_data_1_debug = I_BRAM_MODE_DEBUG == 3'b111;
	wire [DATAADDRWIDTH-1:0] sort_data_1_pointer_a = w_sort_data_1_valid ? I_LI_POINTER : I_SORT_DATA_1_POINTER_A;
	wire [DATAADDRWIDTH-1:0] sort_data_1_pointer_b = w_sort_data_1_debug ? I_BRAM_DEBUG_ADDR : (I_SO_NOW && (I_SO_BRAM_SEL == 10'b0000000001)) ? I_SO_POINTER: I_SORT_DATA_1_POINTER_B;
	wire [DWIDTH-1:0] w_sort_data_1_out_a;
	wire [DWIDTH-1:0] w_sort_data_1_out_b;

	// Instantiate module
	bram_tdp #(
		.DWIDTH(DWIDTH),
		.DEPTH(DATABRAMDEPTH),
		.ADDR_BIT(DATAADDRWIDTH)
	) sort_data_1_bram (
		.clk_a(I_ACLK),
		.clk_b(I_ACLK),
		.en_a(1'b1),
		.en_b(1'b1),
		.we_a(w_sort_data_1_valid),
		.we_b(1'b0),
		.addr_a(sort_data_1_pointer_a),
		.addr_b(sort_data_1_pointer_b),
		.d_in_a(I_LI_DATA),
		.d_in_b(128'd0),
		.d_out_a(w_sort_data_1_out_a),
		.d_out_b(w_sort_data_1_out_b)
	);

	// Assign value to output
	assign O_SORT_DATA_1_A = w_sort_data_1_out_a;
	assign O_SORT_DATA_1_B = w_sort_data_1_out_b;

	// Input BRAM 2
	// Declare wires
	wire w_sort_data_2_valid = I_LI_VALID && (I_LI_SEL == 10'b0000000010);
	wire w_sort_data_2_debug = I_BRAM_MODE_DEBUG == 3'b111;
	wire [DATAADDRWIDTH-1:0] sort_data_2_pointer_a = w_sort_data_2_valid ? I_LI_POINTER : I_SORT_DATA_2_POINTER_A;
	wire [DATAADDRWIDTH-1:0] sort_data_2_pointer_b = w_sort_data_2_debug ? I_BRAM_DEBUG_ADDR : (I_SO_NOW && (I_SO_BRAM_SEL == 10'b0000000010)) ? I_SO_POINTER: I_SORT_DATA_2_POINTER_B;
	wire [DWIDTH-1:0] w_sort_data_2_out_a;
	wire [DWIDTH-1:0] w_sort_data_2_out_b;

	// Instantiate module
	bram_tdp #(
		.DWIDTH(DWIDTH),
		.DEPTH(DATABRAMDEPTH),
		.ADDR_BIT(DATAADDRWIDTH)
	) sort_data_2_bram (
		.clk_a(I_ACLK),
		.clk_b(I_ACLK),
		.en_a(1'b1),
		.en_b(1'b1),
		.we_a(w_sort_data_2_valid),
		.we_b(1'b0),
		.addr_a(sort_data_2_pointer_a),
		.addr_b(sort_data_2_pointer_b),
		.d_in_a(I_LI_DATA),
		.d_in_b(128'd0),
		.d_out_a(w_sort_data_2_out_a),
		.d_out_b(w_sort_data_2_out_b)
	);

	// Assign value to output
	assign O_SORT_DATA_2_A = w_sort_data_2_out_a;
	assign O_SORT_DATA_2_B = w_sort_data_2_out_b;

	// Input BRAM 3
	// Declare wires
	wire w_sort_data_3_valid = I_LI_VALID && (I_LI_SEL == 10'b0000000011);
	wire w_sort_data_3_debug = I_BRAM_MODE_DEBUG == 3'b111;
	wire [DATAADDRWIDTH-1:0] sort_data_3_pointer_a = w_sort_data_3_valid ? I_LI_POINTER : I_SORT_DATA_3_POINTER_A;
	wire [DATAADDRWIDTH-1:0] sort_data_3_pointer_b = w_sort_data_3_debug ? I_BRAM_DEBUG_ADDR : (I_SO_NOW && (I_SO_BRAM_SEL == 10'b0000000011)) ? I_SO_POINTER: I_SORT_DATA_3_POINTER_B;
	wire [DWIDTH-1:0] w_sort_data_3_out_a;
	wire [DWIDTH-1:0] w_sort_data_3_out_b;

	// Instantiate module
	bram_tdp #(
		.DWIDTH(DWIDTH),
		.DEPTH(DATABRAMDEPTH),
		.ADDR_BIT(DATAADDRWIDTH)
	) sort_data_3_bram (
		.clk_a(I_ACLK),
		.clk_b(I_ACLK),
		.en_a(1'b1),
		.en_b(1'b1),
		.we_a(w_sort_data_3_valid),
		.we_b(1'b0),
		.addr_a(sort_data_3_pointer_a),
		.addr_b(sort_data_3_pointer_b),
		.d_in_a(I_LI_DATA),
		.d_in_b(128'd0),
		.d_out_a(w_sort_data_3_out_a),
		.d_out_b(w_sort_data_3_out_b)
	);

	// Assign value to output
	assign O_SORT_DATA_3_A = w_sort_data_3_out_a;
	assign O_SORT_DATA_3_B = w_sort_data_3_out_b;

	// Input BRAM 4
	// Declare wires
	wire w_sort_data_4_valid = I_LI_VALID && (I_LI_SEL == 10'b0000000100);
	wire w_sort_data_4_debug = I_BRAM_MODE_DEBUG == 3'b111;
	wire [DATAADDRWIDTH-1:0] sort_data_4_pointer_a = w_sort_data_4_valid ? I_LI_POINTER : I_SORT_DATA_4_POINTER_A;
	wire [DATAADDRWIDTH-1:0] sort_data_4_pointer_b = w_sort_data_4_debug ? I_BRAM_DEBUG_ADDR : (I_SO_NOW && (I_SO_BRAM_SEL == 10'b0000000100)) ? I_SO_POINTER: I_SORT_DATA_4_POINTER_B;
	wire [DWIDTH-1:0] w_sort_data_4_out_a;
	wire [DWIDTH-1:0] w_sort_data_4_out_b;

	// Instantiate module
	bram_tdp #(
		.DWIDTH(DWIDTH),
		.DEPTH(DATABRAMDEPTH),
		.ADDR_BIT(DATAADDRWIDTH)
	) sort_data_4_bram (
		.clk_a(I_ACLK),
		.clk_b(I_ACLK),
		.en_a(1'b1),
		.en_b(1'b1),
		.we_a(w_sort_data_4_valid),
		.we_b(1'b0),
		.addr_a(sort_data_4_pointer_a),
		.addr_b(sort_data_4_pointer_b),
		.d_in_a(I_LI_DATA),
		.d_in_b(128'd0),
		.d_out_a(w_sort_data_4_out_a),
		.d_out_b(w_sort_data_4_out_b)
	);

	// Assign value to output
	assign O_SORT_DATA_4_A = w_sort_data_4_out_a;
	assign O_SORT_DATA_4_B = w_sort_data_4_out_b;

	// Input BRAM 5
	// Declare wires
	wire w_sort_data_5_valid = I_LI_VALID && (I_LI_SEL == 10'b0000000101);
	wire w_sort_data_5_debug = I_BRAM_MODE_DEBUG == 3'b111;
	wire [DATAADDRWIDTH-1:0] sort_data_5_pointer_a = w_sort_data_5_valid ? I_LI_POINTER : I_SORT_DATA_5_POINTER_A;
	wire [DATAADDRWIDTH-1:0] sort_data_5_pointer_b = w_sort_data_5_debug ? I_BRAM_DEBUG_ADDR : (I_SO_NOW && (I_SO_BRAM_SEL == 10'b0000000101)) ? I_SO_POINTER: I_SORT_DATA_5_POINTER_B;
	wire [DWIDTH-1:0] w_sort_data_5_out_a;
	wire [DWIDTH-1:0] w_sort_data_5_out_b;

	// Instantiate module
	bram_tdp #(
		.DWIDTH(DWIDTH),
		.DEPTH(DATABRAMDEPTH),
		.ADDR_BIT(DATAADDRWIDTH)
	) sort_data_5_bram (
		.clk_a(I_ACLK),
		.clk_b(I_ACLK),
		.en_a(1'b1),
		.en_b(1'b1),
		.we_a(w_sort_data_5_valid),
		.we_b(1'b0),
		.addr_a(sort_data_5_pointer_a),
		.addr_b(sort_data_5_pointer_b),
		.d_in_a(I_LI_DATA),
		.d_in_b(128'd0),
		.d_out_a(w_sort_data_5_out_a),
		.d_out_b(w_sort_data_5_out_b)
	);

	// Assign value to output
	assign O_SORT_DATA_5_A = w_sort_data_5_out_a;
	assign O_SORT_DATA_5_B = w_sort_data_5_out_b;

	// Input BRAM 6
	// Declare wires
	wire w_sort_data_6_valid = I_LI_VALID && (I_LI_SEL == 10'b0000000110);
	wire w_sort_data_6_debug = I_BRAM_MODE_DEBUG == 3'b111;
	wire [DATAADDRWIDTH-1:0] sort_data_6_pointer_a = w_sort_data_6_valid ? I_LI_POINTER : I_SORT_DATA_6_POINTER_A;
	wire [DATAADDRWIDTH-1:0] sort_data_6_pointer_b = w_sort_data_6_debug ? I_BRAM_DEBUG_ADDR : (I_SO_NOW && (I_SO_BRAM_SEL == 10'b0000000110)) ? I_SO_POINTER: I_SORT_DATA_6_POINTER_B;
	wire [DWIDTH-1:0] w_sort_data_6_out_a;
	wire [DWIDTH-1:0] w_sort_data_6_out_b;

	// Instantiate module
	bram_tdp #(
		.DWIDTH(DWIDTH),
		.DEPTH(DATABRAMDEPTH),
		.ADDR_BIT(DATAADDRWIDTH)
	) sort_data_6_bram (
		.clk_a(I_ACLK),
		.clk_b(I_ACLK),
		.en_a(1'b1),
		.en_b(1'b1),
		.we_a(w_sort_data_6_valid),
		.we_b(1'b0),
		.addr_a(sort_data_6_pointer_a),
		.addr_b(sort_data_6_pointer_b),
		.d_in_a(I_LI_DATA),
		.d_in_b(128'd0),
		.d_out_a(w_sort_data_6_out_a),
		.d_out_b(w_sort_data_6_out_b)
	);

	// Assign value to output
	assign O_SORT_DATA_6_A = w_sort_data_6_out_a;
	assign O_SORT_DATA_6_B = w_sort_data_6_out_b;

	// Input BRAM 7
	// Declare wires
	wire w_sort_data_7_valid = I_LI_VALID && (I_LI_SEL == 10'b0000000111);
	wire w_sort_data_7_debug = I_BRAM_MODE_DEBUG == 3'b111;
	wire [DATAADDRWIDTH-1:0] sort_data_7_pointer_a = w_sort_data_7_valid ? I_LI_POINTER : I_SORT_DATA_7_POINTER_A;
	wire [DATAADDRWIDTH-1:0] sort_data_7_pointer_b = w_sort_data_7_debug ? I_BRAM_DEBUG_ADDR : (I_SO_NOW && (I_SO_BRAM_SEL == 10'b0000000111)) ? I_SO_POINTER: I_SORT_DATA_7_POINTER_B;
	wire [DWIDTH-1:0] w_sort_data_7_out_a;
	wire [DWIDTH-1:0] w_sort_data_7_out_b;

	// Instantiate module
	bram_tdp #(
		.DWIDTH(DWIDTH),
		.DEPTH(DATABRAMDEPTH),
		.ADDR_BIT(DATAADDRWIDTH)
	) sort_data_7_bram (
		.clk_a(I_ACLK),
		.clk_b(I_ACLK),
		.en_a(1'b1),
		.en_b(1'b1),
		.we_a(w_sort_data_7_valid),
		.we_b(1'b0),
		.addr_a(sort_data_7_pointer_a),
		.addr_b(sort_data_7_pointer_b),
		.d_in_a(I_LI_DATA),
		.d_in_b(128'd0),
		.d_out_a(w_sort_data_7_out_a),
		.d_out_b(w_sort_data_7_out_b)
	);

	// Assign value to output
	assign O_SORT_DATA_7_A = w_sort_data_7_out_a;
	assign O_SORT_DATA_7_B = w_sort_data_7_out_b;

	// Input BRAM 8
	// Declare wires
	wire w_sort_data_8_valid = I_LI_VALID && (I_LI_SEL == 10'b0000001000);
	wire w_sort_data_8_debug = I_BRAM_MODE_DEBUG == 3'b111;
	wire [DATAADDRWIDTH-1:0] sort_data_8_pointer_a = w_sort_data_8_valid ? I_LI_POINTER : I_SORT_DATA_8_POINTER_A;
	wire [DATAADDRWIDTH-1:0] sort_data_8_pointer_b = w_sort_data_8_debug ? I_BRAM_DEBUG_ADDR : (I_SO_NOW && (I_SO_BRAM_SEL == 10'b0000001000)) ? I_SO_POINTER: I_SORT_DATA_8_POINTER_B;
	wire [DWIDTH-1:0] w_sort_data_8_out_a;
	wire [DWIDTH-1:0] w_sort_data_8_out_b;

	// Instantiate module
	bram_tdp #(
		.DWIDTH(DWIDTH),
		.DEPTH(DATABRAMDEPTH),
		.ADDR_BIT(DATAADDRWIDTH)
	) sort_data_8_bram (
		.clk_a(I_ACLK),
		.clk_b(I_ACLK),
		.en_a(1'b1),
		.en_b(1'b1),
		.we_a(w_sort_data_8_valid),
		.we_b(1'b0),
		.addr_a(sort_data_8_pointer_a),
		.addr_b(sort_data_8_pointer_b),
		.d_in_a(I_LI_DATA),
		.d_in_b(128'd0),
		.d_out_a(w_sort_data_8_out_a),
		.d_out_b(w_sort_data_8_out_b)
	);

	// Assign value to output
	assign O_SORT_DATA_8_A = w_sort_data_8_out_a;
	assign O_SORT_DATA_8_B = w_sort_data_8_out_b;

	// Input BRAM 9
	// Declare wires
	wire w_sort_data_9_valid = I_LI_VALID && (I_LI_SEL == 10'b0000001001);
	wire w_sort_data_9_debug = I_BRAM_MODE_DEBUG == 3'b111;
	wire [DATAADDRWIDTH-1:0] sort_data_9_pointer_a = w_sort_data_9_valid ? I_LI_POINTER : I_SORT_DATA_9_POINTER_A;
	wire [DATAADDRWIDTH-1:0] sort_data_9_pointer_b = w_sort_data_9_debug ? I_BRAM_DEBUG_ADDR : (I_SO_NOW && (I_SO_BRAM_SEL == 10'b0000001001)) ? I_SO_POINTER: I_SORT_DATA_9_POINTER_B;
	wire [DWIDTH-1:0] w_sort_data_9_out_a;
	wire [DWIDTH-1:0] w_sort_data_9_out_b;

	// Instantiate module
	bram_tdp #(
		.DWIDTH(DWIDTH),
		.DEPTH(DATABRAMDEPTH),
		.ADDR_BIT(DATAADDRWIDTH)
	) sort_data_9_bram (
		.clk_a(I_ACLK),
		.clk_b(I_ACLK),
		.en_a(1'b1),
		.en_b(1'b1),
		.we_a(w_sort_data_9_valid),
		.we_b(1'b0),
		.addr_a(sort_data_9_pointer_a),
		.addr_b(sort_data_9_pointer_b),
		.d_in_a(I_LI_DATA),
		.d_in_b(128'd0),
		.d_out_a(w_sort_data_9_out_a),
		.d_out_b(w_sort_data_9_out_b)
	);

	// Assign value to output
	assign O_SORT_DATA_9_A = w_sort_data_9_out_a;
	assign O_SORT_DATA_9_B = w_sort_data_9_out_b;

	// Input BRAM 10
	// Declare wires
	wire w_sort_data_10_valid = I_LI_VALID && (I_LI_SEL == 10'b0000001010);
	wire w_sort_data_10_debug = I_BRAM_MODE_DEBUG == 3'b111;
	wire [DATAADDRWIDTH-1:0] sort_data_10_pointer_a = w_sort_data_10_valid ? I_LI_POINTER : I_SORT_DATA_10_POINTER_A;
	wire [DATAADDRWIDTH-1:0] sort_data_10_pointer_b = w_sort_data_10_debug ? I_BRAM_DEBUG_ADDR : (I_SO_NOW && (I_SO_BRAM_SEL == 10'b0000001010)) ? I_SO_POINTER: I_SORT_DATA_10_POINTER_B;
	wire [DWIDTH-1:0] w_sort_data_10_out_a;
	wire [DWIDTH-1:0] w_sort_data_10_out_b;

	// Instantiate module
	bram_tdp #(
		.DWIDTH(DWIDTH),
		.DEPTH(DATABRAMDEPTH),
		.ADDR_BIT(DATAADDRWIDTH)
	) sort_data_10_bram (
		.clk_a(I_ACLK),
		.clk_b(I_ACLK),
		.en_a(1'b1),
		.en_b(1'b1),
		.we_a(w_sort_data_10_valid),
		.we_b(1'b0),
		.addr_a(sort_data_10_pointer_a),
		.addr_b(sort_data_10_pointer_b),
		.d_in_a(I_LI_DATA),
		.d_in_b(128'd0),
		.d_out_a(w_sort_data_10_out_a),
		.d_out_b(w_sort_data_10_out_b)
	);

	// Assign value to output
	assign O_SORT_DATA_10_A = w_sort_data_10_out_a;
	assign O_SORT_DATA_10_B = w_sort_data_10_out_b;

	// Input BRAM 11
	// Declare wires
	wire w_sort_data_11_valid = I_LI_VALID && (I_LI_SEL == 10'b0000001011);
	wire w_sort_data_11_debug = I_BRAM_MODE_DEBUG == 3'b111;
	wire [DATAADDRWIDTH-1:0] sort_data_11_pointer_a = w_sort_data_11_valid ? I_LI_POINTER : I_SORT_DATA_11_POINTER_A;
	wire [DATAADDRWIDTH-1:0] sort_data_11_pointer_b = w_sort_data_11_debug ? I_BRAM_DEBUG_ADDR : (I_SO_NOW && (I_SO_BRAM_SEL == 10'b0000001011)) ? I_SO_POINTER: I_SORT_DATA_11_POINTER_B;
	wire [DWIDTH-1:0] w_sort_data_11_out_a;
	wire [DWIDTH-1:0] w_sort_data_11_out_b;

	// Instantiate module
	bram_tdp #(
		.DWIDTH(DWIDTH),
		.DEPTH(DATABRAMDEPTH),
		.ADDR_BIT(DATAADDRWIDTH)
	) sort_data_11_bram (
		.clk_a(I_ACLK),
		.clk_b(I_ACLK),
		.en_a(1'b1),
		.en_b(1'b1),
		.we_a(w_sort_data_11_valid),
		.we_b(1'b0),
		.addr_a(sort_data_11_pointer_a),
		.addr_b(sort_data_11_pointer_b),
		.d_in_a(I_LI_DATA),
		.d_in_b(128'd0),
		.d_out_a(w_sort_data_11_out_a),
		.d_out_b(w_sort_data_11_out_b)
	);

	// Assign value to output
	assign O_SORT_DATA_11_A = w_sort_data_11_out_a;
	assign O_SORT_DATA_11_B = w_sort_data_11_out_b;

	// Input BRAM 12
	// Declare wires
	wire w_sort_data_12_valid = I_LI_VALID && (I_LI_SEL == 10'b0000001100);
	wire w_sort_data_12_debug = I_BRAM_MODE_DEBUG == 3'b111;
	wire [DATAADDRWIDTH-1:0] sort_data_12_pointer_a = w_sort_data_12_valid ? I_LI_POINTER : I_SORT_DATA_12_POINTER_A;
	wire [DATAADDRWIDTH-1:0] sort_data_12_pointer_b = w_sort_data_12_debug ? I_BRAM_DEBUG_ADDR : (I_SO_NOW && (I_SO_BRAM_SEL == 10'b0000001100)) ? I_SO_POINTER: I_SORT_DATA_12_POINTER_B;
	wire [DWIDTH-1:0] w_sort_data_12_out_a;
	wire [DWIDTH-1:0] w_sort_data_12_out_b;

	// Instantiate module
	bram_tdp #(
		.DWIDTH(DWIDTH),
		.DEPTH(DATABRAMDEPTH),
		.ADDR_BIT(DATAADDRWIDTH)
	) sort_data_12_bram (
		.clk_a(I_ACLK),
		.clk_b(I_ACLK),
		.en_a(1'b1),
		.en_b(1'b1),
		.we_a(w_sort_data_12_valid),
		.we_b(1'b0),
		.addr_a(sort_data_12_pointer_a),
		.addr_b(sort_data_12_pointer_b),
		.d_in_a(I_LI_DATA),
		.d_in_b(128'd0),
		.d_out_a(w_sort_data_12_out_a),
		.d_out_b(w_sort_data_12_out_b)
	);

	// Assign value to output
	assign O_SORT_DATA_12_A = w_sort_data_12_out_a;
	assign O_SORT_DATA_12_B = w_sort_data_12_out_b;

	// Input BRAM 13
	// Declare wires
	wire w_sort_data_13_valid = I_LI_VALID && (I_LI_SEL == 10'b0000001101);
	wire w_sort_data_13_debug = I_BRAM_MODE_DEBUG == 3'b111;
	wire [DATAADDRWIDTH-1:0] sort_data_13_pointer_a = w_sort_data_13_valid ? I_LI_POINTER : I_SORT_DATA_13_POINTER_A;
	wire [DATAADDRWIDTH-1:0] sort_data_13_pointer_b = w_sort_data_13_debug ? I_BRAM_DEBUG_ADDR : (I_SO_NOW && (I_SO_BRAM_SEL == 10'b0000001101)) ? I_SO_POINTER: I_SORT_DATA_13_POINTER_B;
	wire [DWIDTH-1:0] w_sort_data_13_out_a;
	wire [DWIDTH-1:0] w_sort_data_13_out_b;

	// Instantiate module
	bram_tdp #(
		.DWIDTH(DWIDTH),
		.DEPTH(DATABRAMDEPTH),
		.ADDR_BIT(DATAADDRWIDTH)
	) sort_data_13_bram (
		.clk_a(I_ACLK),
		.clk_b(I_ACLK),
		.en_a(1'b1),
		.en_b(1'b1),
		.we_a(w_sort_data_13_valid),
		.we_b(1'b0),
		.addr_a(sort_data_13_pointer_a),
		.addr_b(sort_data_13_pointer_b),
		.d_in_a(I_LI_DATA),
		.d_in_b(128'd0),
		.d_out_a(w_sort_data_13_out_a),
		.d_out_b(w_sort_data_13_out_b)
	);

	// Assign value to output
	assign O_SORT_DATA_13_A = w_sort_data_13_out_a;
	assign O_SORT_DATA_13_B = w_sort_data_13_out_b;

	// Input BRAM 14
	// Declare wires
	wire w_sort_data_14_valid = I_LI_VALID && (I_LI_SEL == 10'b0000001110);
	wire w_sort_data_14_debug = I_BRAM_MODE_DEBUG == 3'b111;
	wire [DATAADDRWIDTH-1:0] sort_data_14_pointer_a = w_sort_data_14_valid ? I_LI_POINTER : I_SORT_DATA_14_POINTER_A;
	wire [DATAADDRWIDTH-1:0] sort_data_14_pointer_b = w_sort_data_14_debug ? I_BRAM_DEBUG_ADDR : (I_SO_NOW && (I_SO_BRAM_SEL == 10'b0000001110)) ? I_SO_POINTER: I_SORT_DATA_14_POINTER_B;
	wire [DWIDTH-1:0] w_sort_data_14_out_a;
	wire [DWIDTH-1:0] w_sort_data_14_out_b;

	// Instantiate module
	bram_tdp #(
		.DWIDTH(DWIDTH),
		.DEPTH(DATABRAMDEPTH),
		.ADDR_BIT(DATAADDRWIDTH)
	) sort_data_14_bram (
		.clk_a(I_ACLK),
		.clk_b(I_ACLK),
		.en_a(1'b1),
		.en_b(1'b1),
		.we_a(w_sort_data_14_valid),
		.we_b(1'b0),
		.addr_a(sort_data_14_pointer_a),
		.addr_b(sort_data_14_pointer_b),
		.d_in_a(I_LI_DATA),
		.d_in_b(128'd0),
		.d_out_a(w_sort_data_14_out_a),
		.d_out_b(w_sort_data_14_out_b)
	);

	// Assign value to output
	assign O_SORT_DATA_14_A = w_sort_data_14_out_a;
	assign O_SORT_DATA_14_B = w_sort_data_14_out_b;

	// Input BRAM 15
	// Declare wires
	wire w_sort_data_15_valid = I_LI_VALID && (I_LI_SEL == 10'b0000001111);
	wire w_sort_data_15_debug = I_BRAM_MODE_DEBUG == 3'b111;
	wire [DATAADDRWIDTH-1:0] sort_data_15_pointer_a = w_sort_data_15_valid ? I_LI_POINTER : I_SORT_DATA_15_POINTER_A;
	wire [DATAADDRWIDTH-1:0] sort_data_15_pointer_b = w_sort_data_15_debug ? I_BRAM_DEBUG_ADDR : (I_SO_NOW && (I_SO_BRAM_SEL == 10'b0000001111)) ? I_SO_POINTER: I_SORT_DATA_15_POINTER_B;
	wire [DWIDTH-1:0] w_sort_data_15_out_a;
	wire [DWIDTH-1:0] w_sort_data_15_out_b;

	// Instantiate module
	bram_tdp #(
		.DWIDTH(DWIDTH),
		.DEPTH(DATABRAMDEPTH),
		.ADDR_BIT(DATAADDRWIDTH)
	) sort_data_15_bram (
		.clk_a(I_ACLK),
		.clk_b(I_ACLK),
		.en_a(1'b1),
		.en_b(1'b1),
		.we_a(w_sort_data_15_valid),
		.we_b(1'b0),
		.addr_a(sort_data_15_pointer_a),
		.addr_b(sort_data_15_pointer_b),
		.d_in_a(I_LI_DATA),
		.d_in_b(128'd0),
		.d_out_a(w_sort_data_15_out_a),
		.d_out_b(w_sort_data_15_out_b)
	);

	// Assign value to output
	assign O_SORT_DATA_15_A = w_sort_data_15_out_a;
	assign O_SORT_DATA_15_B = w_sort_data_15_out_b;

	// Input BRAM 16
	// Declare wires
	wire w_sort_data_16_valid = I_LI_VALID && (I_LI_SEL == 10'b0000010000);
	wire w_sort_data_16_debug = I_BRAM_MODE_DEBUG == 3'b111;
	wire [DATAADDRWIDTH-1:0] sort_data_16_pointer_a = w_sort_data_16_valid ? I_LI_POINTER : I_SORT_DATA_16_POINTER_A;
	wire [DATAADDRWIDTH-1:0] sort_data_16_pointer_b = w_sort_data_16_debug ? I_BRAM_DEBUG_ADDR : (I_SO_NOW && (I_SO_BRAM_SEL == 10'b0000010000)) ? I_SO_POINTER: I_SORT_DATA_16_POINTER_B;
	wire [DWIDTH-1:0] w_sort_data_16_out_a;
	wire [DWIDTH-1:0] w_sort_data_16_out_b;

	// Instantiate module
	bram_tdp #(
		.DWIDTH(DWIDTH),
		.DEPTH(DATABRAMDEPTH),
		.ADDR_BIT(DATAADDRWIDTH)
	) sort_data_16_bram (
		.clk_a(I_ACLK),
		.clk_b(I_ACLK),
		.en_a(1'b1),
		.en_b(1'b1),
		.we_a(w_sort_data_16_valid),
		.we_b(1'b0),
		.addr_a(sort_data_16_pointer_a),
		.addr_b(sort_data_16_pointer_b),
		.d_in_a(I_LI_DATA),
		.d_in_b(128'd0),
		.d_out_a(w_sort_data_16_out_a),
		.d_out_b(w_sort_data_16_out_b)
	);

	// Assign value to output
	assign O_SORT_DATA_16_A = w_sort_data_16_out_a;
	assign O_SORT_DATA_16_B = w_sort_data_16_out_b;

	// Input BRAM 17
	// Declare wires
	wire w_sort_data_17_valid = I_LI_VALID && (I_LI_SEL == 10'b0000010001);
	wire w_sort_data_17_debug = I_BRAM_MODE_DEBUG == 3'b111;
	wire [DATAADDRWIDTH-1:0] sort_data_17_pointer_a = w_sort_data_17_valid ? I_LI_POINTER : I_SORT_DATA_17_POINTER_A;
	wire [DATAADDRWIDTH-1:0] sort_data_17_pointer_b = w_sort_data_17_debug ? I_BRAM_DEBUG_ADDR : (I_SO_NOW && (I_SO_BRAM_SEL == 10'b0000010001)) ? I_SO_POINTER: I_SORT_DATA_17_POINTER_B;
	wire [DWIDTH-1:0] w_sort_data_17_out_a;
	wire [DWIDTH-1:0] w_sort_data_17_out_b;

	// Instantiate module
	bram_tdp #(
		.DWIDTH(DWIDTH),
		.DEPTH(DATABRAMDEPTH),
		.ADDR_BIT(DATAADDRWIDTH)
	) sort_data_17_bram (
		.clk_a(I_ACLK),
		.clk_b(I_ACLK),
		.en_a(1'b1),
		.en_b(1'b1),
		.we_a(w_sort_data_17_valid),
		.we_b(1'b0),
		.addr_a(sort_data_17_pointer_a),
		.addr_b(sort_data_17_pointer_b),
		.d_in_a(I_LI_DATA),
		.d_in_b(128'd0),
		.d_out_a(w_sort_data_17_out_a),
		.d_out_b(w_sort_data_17_out_b)
	);

	// Assign value to output
	assign O_SORT_DATA_17_A = w_sort_data_17_out_a;
	assign O_SORT_DATA_17_B = w_sort_data_17_out_b;

	// Input BRAM 18
	// Declare wires
	wire w_sort_data_18_valid = I_LI_VALID && (I_LI_SEL == 10'b0000010010);
	wire w_sort_data_18_debug = I_BRAM_MODE_DEBUG == 3'b111;
	wire [DATAADDRWIDTH-1:0] sort_data_18_pointer_a = w_sort_data_18_valid ? I_LI_POINTER : I_SORT_DATA_18_POINTER_A;
	wire [DATAADDRWIDTH-1:0] sort_data_18_pointer_b = w_sort_data_18_debug ? I_BRAM_DEBUG_ADDR : (I_SO_NOW && (I_SO_BRAM_SEL == 10'b0000010010)) ? I_SO_POINTER: I_SORT_DATA_18_POINTER_B;
	wire [DWIDTH-1:0] w_sort_data_18_out_a;
	wire [DWIDTH-1:0] w_sort_data_18_out_b;

	// Instantiate module
	bram_tdp #(
		.DWIDTH(DWIDTH),
		.DEPTH(DATABRAMDEPTH),
		.ADDR_BIT(DATAADDRWIDTH)
	) sort_data_18_bram (
		.clk_a(I_ACLK),
		.clk_b(I_ACLK),
		.en_a(1'b1),
		.en_b(1'b1),
		.we_a(w_sort_data_18_valid),
		.we_b(1'b0),
		.addr_a(sort_data_18_pointer_a),
		.addr_b(sort_data_18_pointer_b),
		.d_in_a(I_LI_DATA),
		.d_in_b(128'd0),
		.d_out_a(w_sort_data_18_out_a),
		.d_out_b(w_sort_data_18_out_b)
	);

	// Assign value to output
	assign O_SORT_DATA_18_A = w_sort_data_18_out_a;
	assign O_SORT_DATA_18_B = w_sort_data_18_out_b;

	// Input BRAM 19
	// Declare wires
	wire w_sort_data_19_valid = I_LI_VALID && (I_LI_SEL == 10'b0000010011);
	wire w_sort_data_19_debug = I_BRAM_MODE_DEBUG == 3'b111;
	wire [DATAADDRWIDTH-1:0] sort_data_19_pointer_a = w_sort_data_19_valid ? I_LI_POINTER : I_SORT_DATA_19_POINTER_A;
	wire [DATAADDRWIDTH-1:0] sort_data_19_pointer_b = w_sort_data_19_debug ? I_BRAM_DEBUG_ADDR : (I_SO_NOW && (I_SO_BRAM_SEL == 10'b0000010011)) ? I_SO_POINTER: I_SORT_DATA_19_POINTER_B;
	wire [DWIDTH-1:0] w_sort_data_19_out_a;
	wire [DWIDTH-1:0] w_sort_data_19_out_b;

	// Instantiate module
	bram_tdp #(
		.DWIDTH(DWIDTH),
		.DEPTH(DATABRAMDEPTH),
		.ADDR_BIT(DATAADDRWIDTH)
	) sort_data_19_bram (
		.clk_a(I_ACLK),
		.clk_b(I_ACLK),
		.en_a(1'b1),
		.en_b(1'b1),
		.we_a(w_sort_data_19_valid),
		.we_b(1'b0),
		.addr_a(sort_data_19_pointer_a),
		.addr_b(sort_data_19_pointer_b),
		.d_in_a(I_LI_DATA),
		.d_in_b(128'd0),
		.d_out_a(w_sort_data_19_out_a),
		.d_out_b(w_sort_data_19_out_b)
	);

	// Assign value to output
	assign O_SORT_DATA_19_A = w_sort_data_19_out_a;
	assign O_SORT_DATA_19_B = w_sort_data_19_out_b;

	//////////////////////////////////////
	//        Output Stream Logic       //
	//////////////////////////////////////
	// Delay BRAM selector
	// Declare register
	reg [SELWIDTH-1:0] r_so_bram_sel_delayed;
	// Delay logic
	always @(posedge I_ACLK)
	begin
		r_so_bram_sel_delayed <= I_SO_BRAM_SEL;
	end

	// Choose BRAM
	always @(*) 
	begin
		case (r_so_bram_sel_delayed)
			0:
			begin
				O_SO_DATA = O_SORT_DATA_0_B;
			end
			1:
			begin
				O_SO_DATA = O_SORT_DATA_1_B;
			end
			2:
			begin
				O_SO_DATA = O_SORT_DATA_2_B;
			end
			3:
			begin
				O_SO_DATA = O_SORT_DATA_3_B;
			end
			4:
			begin
				O_SO_DATA = O_SORT_DATA_4_B;
			end
			5:
			begin
				O_SO_DATA = O_SORT_DATA_5_B;
			end
			6:
			begin
				O_SO_DATA = O_SORT_DATA_6_B;
			end
			7:
			begin
				O_SO_DATA = O_SORT_DATA_7_B;
			end
			8:
			begin
				O_SO_DATA = O_SORT_DATA_8_B;
			end
			9:
			begin
				O_SO_DATA = O_SORT_DATA_9_B;
			end
			10:
			begin
				O_SO_DATA = O_SORT_DATA_10_B;
			end
			11:
			begin
				O_SO_DATA = O_SORT_DATA_11_B;
			end
			12:
			begin
				O_SO_DATA = O_SORT_DATA_12_B;
			end
			13:
			begin
				O_SO_DATA = O_SORT_DATA_13_B;
			end
			14:
			begin
				O_SO_DATA = O_SORT_DATA_14_B;
			end
			15:
			begin
				O_SO_DATA = O_SORT_DATA_15_B;
			end
			16:
			begin
				O_SO_DATA = O_SORT_DATA_16_B;
			end
			17:
			begin
				O_SO_DATA = O_SORT_DATA_17_B;
			end
			18:
			begin
				O_SO_DATA = O_SORT_DATA_18_B;
			end
			19:
			begin
				O_SO_DATA = O_SORT_DATA_19_B;
			end
			default:
			begin
				O_SO_DATA = O_SORT_DATA_1_B;
			end
		endcase
	end

endmodule