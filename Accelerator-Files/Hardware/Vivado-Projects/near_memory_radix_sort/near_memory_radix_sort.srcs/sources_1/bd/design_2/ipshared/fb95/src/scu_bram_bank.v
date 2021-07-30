//********************************************************************************
//                      [ MODULE ]                                                
//                                                                                
// Institution       : Korea Advanced Institute of Science and Technology         
// Engineer          : Dalta Imam Maulana                                         
//                                                                                
// Project Name      : Near Memory Radix Sort                                     
//                                                                                
// Create Date       : 6/14/2021
// File Name         : scu_bram_bank.v                                           
// Module Dependency : -                                                          
//                                                                                
// Target Device     : ZCU104                                                     
// Tool Version      : Vivado 2020.1                                              
//                                                                                
// Description:                                                                   
//      Status and control unit for BRAM Bank                                     
//                                                                                
//********************************************************************************
`timescale 1ns / 1ps

module scu_bram_bank
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
	// Declare ports
	(
		// Clock and Reset
		input wire I_ACLK,
		input wire I_ARESETN,

		// Input from SCU
		input wire [7:0]  I_SEL_REG,
		input wire [7:0]  I_SEL_MULTIPLE,
		input wire [3:0]  I_EN_MULTIPLE,
		input wire [3:0]  I_SEL_COL,
		input wire [31:0] I_VALUE,
		input wire [1:0]  I_MODE, // 2'b00 = nothing, 2'b01 = set reg, 2'b10 = increment reg, 2'b11 = do loop
		input wire [7:0]  I_INSTRUCTION_OPCODE,
		input wire        I_START,
		output wire       O_DONE,

		// DMA Address
		output reg [31:0]  O_DMA_ADDRESS,
		output reg [31:0]  O_DMA_BYTE_TO_TRANSFER,
		output reg [31:0]  O_DMA_NO_OF_TRANSACTION,

		// Load Input
		output wire [DATAADDRWIDTH-1:0]  O_LI_START_POINTER,

		// Stream Out
		output wire [DATAADDRWIDTH-1:0]  O_SO_START_POINTER,
		output wire [DATAADDRWIDTH-1:0]  O_SO_END_POINTER,

		// Loop
		output wire [15:0]  O_LOOP_I,
		output wire [15:0]  O_LOOP_I_MAX,
		output wire [15:0]  O_LOOP_J,
		output wire [15:0]  O_LOOP_J_MAX,
		output wire [15:0]  O_LOOP_K,
		output wire [15:0]  O_LOOP_K_MAX,
		output wire [15:0]  O_LOOP_L,
		output wire [15:0]  O_LOOP_L_MAX
	);

	///////////////////////////////
	//      Local Parameter      //
	///////////////////////////////
	// State machine
	localparam [1:0] STATE_IDLE = 2'b00,
		STATE_SET       = 2'b01,
		STATE_INCREMENT = 2'b10,
		STATE_DONE      = 2'b11;

	///////////////////////////////
	//     Declare Registers     //
	///////////////////////////////
	// Register array for DMA
	reg [31:0] r_dma_addr [0:3];
	reg [31:0] r_dma_btt [0:3];
	reg [31:0] r_dma_not [0:3];

	// Register array for Start End Pointer
	reg [DATAADDRWIDTH-1:0] r_start_ptr [0:3];
	reg [DATAADDRWIDTH-1:0] r_end_ptr [0:3];
	reg [15:0] r_loop_max [0:3];
	reg [15:0] r_loop [0:3];

	// Register for state machine
	reg [1:0] r_internal_state;

	///////////////////////////////
	//    State Machine Logic    //
	///////////////////////////////
	// Set done signal
	assign O_DONE = (r_internal_state == STATE_DONE);
	// State transition logic
	always @(posedge I_ACLK) 
	begin
		if (!I_ARESETN)
		begin
			r_internal_state <= STATE_IDLE;
		end
		else
		begin
			case (r_internal_state)
				STATE_IDLE:
				begin
					if (I_START)
					begin
						if (I_MODE == STATE_SET)
						begin
							r_internal_state <= STATE_SET;
						end
						else // Loop also get to here
						begin
							r_internal_state <= STATE_INCREMENT;
						end
					end
					else
					begin
						r_internal_state <= STATE_IDLE;
					end
				end
				STATE_SET, STATE_INCREMENT:
				begin
					r_internal_state <= STATE_DONE;
				end
				default:
				begin
					r_internal_state <= STATE_IDLE;
				end
			endcase
		end
	end

	///////////////////////////////
	//     DMA Control Logic     //
	///////////////////////////////
	// Declare variable
	genvar i;
	// Generate DMA control signal
	for (i=0; i<4; i=i+1)
	begin
		always @(posedge I_ACLK)
		begin
			if (!I_ARESETN)
			begin
				r_dma_addr[i] <= 32'd0;
				r_dma_btt[i]  <= 32'd0;
				r_dma_not[i]  <= 32'd0;
			end
			else
			begin
				// Set source or destination address
				if ((r_internal_state == STATE_SET) && (I_SEL_REG == 1) && (I_SEL_COL == i))
				begin
					r_dma_addr[i] <= I_VALUE;
				end
				else if ((r_internal_state == STATE_INCREMENT) && (I_MODE == 2'b10) && (I_SEL_REG == 1) && (I_SEL_COL == i))
				begin
					r_dma_addr[i] <= r_dma_addr[i] + I_VALUE;
				end
				else
				begin
					r_dma_addr[i] <= r_dma_addr[i];
				end

				// Set byte to transfer
				if ((r_internal_state == STATE_SET) && (I_SEL_REG == 2) && (I_SEL_COL == i))
				begin
					r_dma_btt[i] <= I_VALUE;
				end
				else if ((r_internal_state == STATE_INCREMENT) && (I_MODE == 2'b10) && (I_SEL_REG == 2) && (I_SEL_COL == i))
				begin
					r_dma_btt[i] <= r_dma_btt[i] + I_VALUE;
				end
				else
				begin
					r_dma_btt[i] <= r_dma_btt[i];
				end

				// Set DMA number of transactions
				if ((r_internal_state == STATE_SET) && (I_SEL_REG == 3) && (I_SEL_COL == i))
				begin
					r_dma_not[i] <= I_VALUE;
				end
				else if ((r_internal_state == STATE_INCREMENT) && (I_MODE == 2'b10) && (I_SEL_REG == 3) && (I_SEL_COL == i))
				begin
					r_dma_not[i] <= r_dma_not[i] + I_VALUE;
				end
				else
				begin
					r_dma_not[i] <= r_dma_not[i];
				end
			end
		end
	end

	////////////////////////////////////////
	//     Start End Register Control     //
	////////////////////////////////////////
	for (i=0; i<4; i=i+1)
	begin
		always @(posedge I_ACLK)
		begin
			if (!I_ARESETN)
			begin
				r_start_ptr[i] <= {DATAADDRWIDTH{1'b0}};
				r_end_ptr[i] <= {DATAADDRWIDTH{1'b0}};
			end
			else
			begin
				// Set start pointer register
				if ((r_internal_state == STATE_SET) && (I_SEL_REG == 8) && (I_SEL_COL == i))
				begin
					r_start_ptr[i] <= I_VALUE[DATAADDRWIDTH-1:0];
				end
				else if ((r_internal_state == STATE_INCREMENT) && (I_MODE == 2'b10) && (I_SEL_REG == 8) && (I_SEL_COL == i))
				begin
					r_start_ptr[i] <= r_start_ptr[i] + I_VALUE[DATAADDRWIDTH-1:0];
				end
				else
				begin
					r_start_ptr[i] <= r_start_ptr[i];
				end

				// Set end pointer register
				if ((r_internal_state == STATE_SET) && (I_SEL_REG == 9) && (I_SEL_COL == i))
				begin
					r_end_ptr[i] <= I_VALUE[DATAADDRWIDTH-1:0];
				end
				else if ((r_internal_state == STATE_INCREMENT) && (I_MODE == 2'b10) && (I_SEL_REG == 9) && (I_SEL_COL == i))
				begin
					r_end_ptr[i] <= r_end_ptr[i] + I_VALUE[DATAADDRWIDTH-1:0];
				end
				else
				begin
					r_end_ptr[i] <= r_end_ptr[i];
				end
			end
		end
	end

	/////////////////////////////////////
	//      Register Loop Control      //
	/////////////////////////////////////
	// Set register loop value
	for (i = 0; i < 4; i = i + 1)
	begin
		always @(posedge I_ACLK)
		begin
			if (!I_ARESETN)
			begin
				r_loop[i] <= 16'd0;
			end
			else
			begin
				if ((r_internal_state == STATE_INCREMENT) && (I_MODE == 2'b11) && (I_SEL_COL == i))
				begin
					r_loop[i] <= r_loop[i] + 1;
				end
				else
				begin
					if (r_loop[i] == r_loop_max[i])
					begin
						r_loop[i] <= 0;
					end
					else
					begin
						r_loop[i] <= r_loop[i];
					end
				end
			end
		end
	end

	///////////////////////////////////////
	//      Output Value Assignment      //
	///////////////////////////////////////
	// DMA Address
	always @(*) 
	begin
		case (I_INSTRUCTION_OPCODE)
			8'h10: // Load Input
			begin
				O_DMA_ADDRESS           = r_dma_addr[0];
				O_DMA_BYTE_TO_TRANSFER  = r_dma_btt[0];
				O_DMA_NO_OF_TRANSACTION = r_dma_not[0];
			end
			8'h14: // Stream Out
			begin
				O_DMA_ADDRESS           = r_dma_addr[1];
				O_DMA_BYTE_TO_TRANSFER  = r_dma_btt[1];
				O_DMA_NO_OF_TRANSACTION = r_dma_not[1];
			end
			default:
			begin
				O_DMA_ADDRESS           = r_dma_addr[I_SEL_COL[1:0]];
				O_DMA_BYTE_TO_TRANSFER  = r_dma_btt[I_SEL_COL[1:0]];
				O_DMA_NO_OF_TRANSACTION = r_dma_not[I_SEL_COL[1:0]];
			end
		endcase
	end

	// Assign value to start/end pointer port
	// Load Input
	assign O_LI_START_POINTER  = r_start_ptr[0][DATAADDRWIDTH-1:0];
	// Stream Out
	assign O_SO_START_POINTER  = r_start_ptr[1][DATAADDRWIDTH-1:0];
	assign O_SO_END_POINTER    = r_end_ptr[1][DATAADDRWIDTH-1:0];
	// Loop
	assign O_LOOP_I     = r_loop[0];
	assign O_LOOP_I_MAX = r_loop_max[0];
	assign O_LOOP_J     = r_loop[1];
	assign O_LOOP_J_MAX = r_loop_max[1];
	assign O_LOOP_K     = r_loop[2];
	assign O_LOOP_K_MAX = r_loop_max[2];
	assign O_LOOP_L     = r_loop[3];
	assign O_LOOP_L_MAX = r_loop_max[3];

endmodule