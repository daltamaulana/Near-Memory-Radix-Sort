//********************************************************************************
//                      [ MODULE ]                                                
//                                                                                
// Institution       : Korea Advanced Institute of Science and Technology         
// Engineer          : Dalta Imam Maulana                                         
//                                                                                
// Project Name      : Near Memory Radix Sort                                     
//                                                                                
// Create Date       : 6/21/2021
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
		parameter DATABRAMDEPTH =32768,
		parameter DATAADDRWIDTH =17,
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
		// input wire  [DATAADDRWIDTH-1:0] I_SORT_DATA_1_POINTER_A,
		// input wire  [DATAADDRWIDTH-1:0] I_SORT_DATA_1_POINTER_B,
		// Sort data output
		output wire [DWIDTH-1:0] O_SORT_DATA_0_A,
		output wire [DWIDTH-1:0] O_SORT_DATA_0_B,
		// output wire [DWIDTH-1:0] O_SORT_DATA_1_A,
		// output wire [DWIDTH-1:0] O_SORT_DATA_1_B,

		// Sorting BRAM
		// Even pointer
		input wire [DATAADDRWIDTH-2:0] I_SORT_EVEN_POINTER,
		input wire I_SORT_EVEN_VALID,
		input wire [DWIDTH-1:0] I_SORT_EVEN_DATA,
		input wire [SELWIDTH-1:0] I_SORT_EVEN_SEL,
		output reg [DWIDTH-1:0] O_SORT_EVEN_DATA,
		// Odd pointer
		input wire [DATAADDRWIDTH-2:0] I_SORT_ODD_POINTER,
		input wire I_SORT_ODD_VALID,
		input wire [DWIDTH-1:0] I_SORT_ODD_DATA,
		input wire [SELWIDTH-1:0] I_SORT_ODD_SEL,
		output reg [DWIDTH-1:0] O_SORT_ODD_DATA,

		// Output BRAM data pointer
		input wire  [DATAADDRWIDTH-1:0] I_BRAM_OUT_0_POINTER_A,
		input wire  [DATAADDRWIDTH-1:0] I_BRAM_OUT_0_POINTER_B,
		// input wire  [DATAADDRWIDTH-1:0] I_BRAM_OUT_1_POINTER_A,
		// input wire  [DATAADDRWIDTH-1:0] I_BRAM_OUT_1_POINTER_B,
		// Output BRAM data output
		output wire [DWIDTH-1:0] O_BRAM_OUT_0_A,
		output wire [DWIDTH-1:0] O_BRAM_OUT_0_B,
		// output wire [DWIDTH-1:0] O_BRAM_OUT_1_A,
		// output wire [DWIDTH-1:0] O_BRAM_OUT_1_B,

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
	wire w_sort_data_0_we_a = w_sort_data_0_valid || w_sort_even_0_valid;
	wire w_sort_even_0_valid = (I_SORT_EVEN_VALID && (I_SORT_EVEN_SEL == 10'b0000000000));
	wire w_sort_data_0_valid = (I_LI_VALID && (I_LI_SEL == 10'b0000000000));
	wire w_sort_data_0_debug = I_BRAM_MODE_DEBUG == 3'b111;
	wire [DWIDTH-1:0] w_sort_data_0_data = w_sort_data_0_valid ? I_LI_DATA : I_SORT_EVEN_DATA;
	wire [DATAADDRWIDTH-1:0] sort_data_0_pointer_a = w_sort_data_0_valid ? I_LI_POINTER : (I_SORT_EVEN_SEL == 10'b0000000000) ? {1'b0, I_SORT_EVEN_POINTER} : I_SORT_DATA_0_POINTER_A;
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
		.we_a(w_sort_data_0_we_a),
		.we_b(1'b0),
		.addr_a(sort_data_0_pointer_a),
		.addr_b(sort_data_0_pointer_b),
		.d_in_a(w_sort_data_0_data),
		.d_in_b(128'd0),
		.d_out_a(w_sort_data_0_out_a),
		.d_out_b(w_sort_data_0_out_b)
	);

	// Assign value to output
	assign O_SORT_DATA_0_A = w_sort_data_0_out_a;
	assign O_SORT_DATA_0_B = w_sort_data_0_out_b;

	// // Input BRAM 1
	// // Declare wires
	// wire w_sort_data_1_we_a = w_sort_data_1_valid || w_sort_even_1_valid;
	// wire w_sort_even_1_valid = (I_SORT_EVEN_VALID && (I_SORT_EVEN_SEL == 10'b0000000001));
	// wire w_sort_data_1_valid = (I_LI_VALID && (I_LI_SEL == 10'b0000000001));
	// wire w_sort_data_1_debug = I_BRAM_MODE_DEBUG == 3'b111;
	// wire [DWIDTH-1:0] w_sort_data_1_data = w_sort_data_1_valid ? I_LI_DATA : I_SORT_EVEN_DATA;
	// wire [DATAADDRWIDTH-1:0] sort_data_1_pointer_a = w_sort_data_1_valid ? I_LI_POINTER : (I_SORT_EVEN_SEL == 10'b0000000001) ? {1'b0, I_SORT_EVEN_POINTER} : I_SORT_DATA_1_POINTER_A;
	// wire [DATAADDRWIDTH-1:0] sort_data_1_pointer_b = w_sort_data_1_debug ? I_BRAM_DEBUG_ADDR : (I_SO_NOW && (I_SO_BRAM_SEL == 10'b0000000001)) ? I_SO_POINTER: I_SORT_DATA_1_POINTER_B;
	// wire [DWIDTH-1:0] w_sort_data_1_out_a;
	// wire [DWIDTH-1:0] w_sort_data_1_out_b;

	// // Instantiate module
	// bram_tdp #(
	// 	.DWIDTH(DWIDTH),
	// 	.DEPTH(DATABRAMDEPTH),
	// 	.ADDR_BIT(DATAADDRWIDTH)
	// ) sort_data_1_bram (
	// 	.clk_a(I_ACLK),
	// 	.clk_b(I_ACLK),
	// 	.en_a(1'b1),
	// 	.en_b(1'b1),
	// 	.we_a(w_sort_data_1_we_a),
	// 	.we_b(1'b0),
	// 	.addr_a(sort_data_1_pointer_a),
	// 	.addr_b(sort_data_1_pointer_b),
	// 	.d_in_a(w_sort_data_1_data),
	// 	.d_in_b(128'd0),
	// 	.d_out_a(w_sort_data_1_out_a),
	// 	.d_out_b(w_sort_data_1_out_b)
	// );

	// // Assign value to output
	// assign O_SORT_DATA_1_A = w_sort_data_1_out_a;
	// assign O_SORT_DATA_1_B = w_sort_data_1_out_b;

	////////////////////////////////////
	//        Output Data BRAM        //
	////////////////////////////////////
	// Output BRAM 0
	// Declare wires
	wire w_bram_out_0_we_a = sort_odd_0_valid;
	wire sort_odd_0_valid = (I_SORT_ODD_VALID && (I_SORT_ODD_SEL == 10'b0000000000));
	wire w_bram_out_0_debug = I_BRAM_MODE_DEBUG == 3'b111;
	wire [DATAADDRWIDTH-1:0] bram_out_0_pointer_a = (I_SORT_ODD_SEL == 10'b0000000000) ? {1'b0, I_SORT_ODD_POINTER} : I_BRAM_OUT_0_POINTER_A;
	wire [DATAADDRWIDTH-1:0] bram_out_0_pointer_b = w_bram_out_0_debug ? I_BRAM_DEBUG_ADDR : (I_SO_NOW && (I_SO_BRAM_SEL == 10'b0000000000)) ? I_SO_POINTER: I_BRAM_OUT_0_POINTER_B;
	wire [DWIDTH-1:0] w_bram_out_0_out_a;
	wire [DWIDTH-1:0] w_bram_out_0_out_b;

	// Instantiate module
	bram_tdp #(
		.DWIDTH(DWIDTH),
		.DEPTH(DATABRAMDEPTH),
		.ADDR_BIT(DATAADDRWIDTH)
	) bram_out_0 (
		.clk_a(I_ACLK),
		.clk_b(I_ACLK),
		.en_a(1'b1),
		.en_b(1'b1),
		.we_a(w_bram_out_0_we_a),
		.we_b(1'b0),
		.addr_a(bram_out_0_pointer_a),
		.addr_b(bram_out_0_pointer_b),
		.d_in_a(I_SORT_ODD_DATA),
		.d_in_b(128'd0),
		.d_out_a(w_bram_out_0_out_a),
		.d_out_b(w_bram_out_0_out_b)
	);

	// Assign value to output
	assign O_BRAM_OUT_0_A = w_bram_out_0_out_a;
	assign O_BRAM_OUT_0_B = w_bram_out_0_out_b;

	// // Output BRAM 1
	// // Declare wires
	// wire w_bram_out_1_we_a = sort_odd_1_valid;
	// wire sort_odd_1_valid = I_SORT_ODD_VALID && (I_SORT_ODD_SEL == 10'b0000000001);
	// wire w_bram_out_1_debug = I_BRAM_MODE_DEBUG == 3'b111;
	// wire [DATAADDRWIDTH-1:0] bram_out_1_pointer_a = (I_SORT_ODD_SEL == 10'b0000000001) ? {1'b0, I_SORT_ODD_POINTER} : I_BRAM_OUT_1_POINTER_A;
	// wire [DATAADDRWIDTH-1:0] bram_out_1_pointer_b = w_bram_out_1_debug ? I_BRAM_DEBUG_ADDR : (I_SO_NOW && (I_SO_BRAM_SEL == 10'b0000000001)) ? I_SO_POINTER: I_BRAM_OUT_0_POINTER_B;
	// wire [DWIDTH-1:0] w_bram_out_1_out_a;
	// wire [DWIDTH-1:0] w_bram_out_1_out_b;

	// // Instantiate module
	// bram_tdp #(
	// 	.DWIDTH(DWIDTH),
	// 	.DEPTH(DATABRAMDEPTH),
	// 	.ADDR_BIT(DATAADDRWIDTH)
	// ) bram_out_1 (
	// 	.clk_a(I_ACLK),
	// 	.clk_b(I_ACLK),
	// 	.en_a(1'b1),
	// 	.en_b(1'b1),
	// 	.we_a(w_bram_out_1_we_a),
	// 	.we_b(1'b0),
	// 	.addr_a(bram_out_1_pointer_a),
	// 	.addr_b(bram_out_1_pointer_b),
	// 	.d_in_a(I_SORT_ODD_DATA),
	// 	.d_in_b(128'd0),
	// 	.d_out_a(w_bram_out_1_out_a),
	// 	.d_out_b(w_bram_out_1_out_b)
	// );

	// // Assign value to output
	// assign O_BRAM_OUT_1_A = w_bram_out_1_out_a;
	// assign O_BRAM_OUT_1_B = w_bram_out_1_out_b;

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
				O_SO_DATA = O_BRAM_OUT_0_B;
			end
			1:
			begin
				O_SO_DATA = O_BRAM_OUT_0_B;
			end
			default:
			begin
				O_SO_DATA = O_BRAM_OUT_0_B;
			end
		endcase
	end

	// Choose BRAM for sorting
	always @(*) 
	begin
		case (I_SORT_EVEN_SEL)	
			0:
			begin
				O_SORT_EVEN_DATA = O_SORT_DATA_0_A;
			end
			1:
			begin
				O_SORT_EVEN_DATA = O_SORT_DATA_0_A;
			end
			default:
			begin
				O_SORT_EVEN_DATA = O_SORT_DATA_0_A;
			end
		endcase
	end

	always @(*) 
	begin
		case (I_SORT_ODD_SEL)	
			0:
			begin
				O_SORT_ODD_DATA = O_BRAM_OUT_0_A;
			end
			1:
			begin
				O_SORT_ODD_DATA = O_BRAM_OUT_0_A;
			end
			default:
			begin
				O_SORT_ODD_DATA = O_BRAM_OUT_0_A;
			end
		endcase
	end

endmodule