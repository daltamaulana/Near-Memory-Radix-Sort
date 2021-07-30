//********************************************************************************
//                      [ MODULE ]                                                
//                                                                                
// Institution       : Korea Advanced Institute of Science and Technology         
// Engineer          : Dalta Imam Maulana                                         
//                                                                                
// Project Name      : Near Memory Radix Sort                                     
//                                                                                
// Create Date       : 6/21/2021
// File Name         : status_and_control_unit.v                                           
// Module Dependency : -                                                          
//                                                                                
// Target Device     : ZCU104                                                     
// Tool Version      : Vivado 2020.1                                              
//                                                                                
// Description:                                                                   
//      Status and control unit for near memory radix sort accelerator            
//                                                                                
//********************************************************************************
`timescale 1ns / 1ps

module status_and_control_unit
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
	// Declare ports
	(
		/////////////////////////////////////////////
		//            Clock and Reset              //
		/////////////////////////////////////////////
		input wire         I_ACLK,
		input wire         I_ARESETN,

		/////////////////////////////////////////////
		//      SCU <-> AXI Lite Slave Signal      //
		/////////////////////////////////////////////
		// Signal From PS
		input wire         I_GLOBAL_START,
		input wire         I_FORCE_LOAD_INSTRUCTION, // Also work as debug signal for BRAM Bank Mode
		input wire [31:0]  I_BRAM_DEBUG_ADDR,
		output wire        O_PL_TO_PS_IRQ,
		output wire [31:0] O_STATE_LOGGER_DATA,

		// Monitor Signal
		input wire  [63:0] I_INSTRUCTION_DATA,
		output wire [INSTADDRWIDTH-1:0] O_PROGRAM_COUNTER,

		/////////////////////////////////////////////
		//          SCU <-> Data Ordering          //
		/////////////////////////////////////////////
		// Load Instruction Channel
		output wire        O_LOAD_INSTRUCTION_START,
		input wire         I_LOAD_INSTRUCTION_DONE,

		// Load Input Channel
		output wire        O_LI_START,
		output wire [31:0] O_LI_NO_OF_ROW,
		output wire [DATAADDRWIDTH-1:0] O_LI_START_POINTER,
		output wire [SELWIDTH-1:0]  O_LI_SEL,
		input wire         I_LI_DONE,

		// Stream Out
		output wire        O_SO_START,
		output wire [DATAADDRWIDTH-1:0] O_SO_START_POINTER,
		output wire [DATAADDRWIDTH-1:0] O_SO_END_POINTER,
		input wire         I_SO_DONE,

		////////////////////////////////
		//  DMA Controller <===> SCU  //
		////////////////////////////////
		output wire        O_DMA_START,
		output wire [31:0] O_DMA_ADDR,
		output wire [31:0] O_DMA_BYTE_TO_TRANSFER,
		output wire [31:0] O_DMA_NO_OF_TRANSACTION,
		output reg  [2:0]  O_DMA_MODE,
		input wire         I_DMA_DONE,
		input wire         I_DATA_SEND_DONE,

		///////////////////////////////
		//  Radix Sorting <===> SCU  //
		///////////////////////////////
		output wire 	   O_SORTING_START,
		input wire 	   	   I_SORTING_DONE,

		////////////////////////////////
		//        Debug Signal        //
		////////////////////////////////
		output wire [31:0] O_LI_COUNT,
		output wire [31:0] O_RS_COUNT,
		output wire [31:0] O_SO_COUNT,
		output wire [31:0] O_ALL_COUNT,
		output wire O_PC_CHANGED,
		output wire [3:0]  O_SCU_STATE_MACHINE,
		output wire [3:0]  O_INTERNAL_COUNTER,
		output wire [31:0] O_INSTRUCTION_OUT
	);

	/////////////////////////////////////////////
	//        Global Start Pulse Logic         //
	/////////////////////////////////////////////
	// Declare register and wire
	reg r_global_start_delay;
	wire w_global_start_pulse;

	// Start pulse logic
	assign w_global_start_pulse = !r_global_start_delay && I_GLOBAL_START;
	// Delayed start signal
	always @(posedge I_ACLK)
	begin
		if (!I_ARESETN)
		begin
			r_global_start_delay <= 0;
		end
		else
		begin
			r_global_start_delay <= I_GLOBAL_START;
		end
	end

	/////////////////////////////////////////////
	//           SCU State Machine             //
	/////////////////////////////////////////////
	// Declare localparam
	localparam [3:0] SCU_IDLE = 4'd0,
		SCU_WAIT_SETUP = 4'd1,
		SCU_LOAD_INSTRUCTION = 4'd2,
		SCU_RUNNING = 4'd3;

	// Declare registers and wire
	reg [3:0]  r_scu_state_machine;
	reg [3:0]  r_internal_counter;
	reg r_program_counter_changed;
	wire [3:0] w_internal_counter_max = 15;
	wire w_scu_start_process;

	// Debug signal
	assign O_PC_CHANGED = r_program_counter_changed;
	assign O_SCU_STATE_MACHINE = r_scu_state_machine;
	assign O_INTERNAL_COUNTER = r_internal_counter;
	assign O_INSTRUCTION_OUT = I_INSTRUCTION_DATA[63:32];

	// State machine logic
	always @(posedge I_ACLK)
	begin
		if (!I_ARESETN)
		begin
			r_scu_state_machine <= SCU_IDLE;
		end
		else
		begin
			case (r_scu_state_machine)
				SCU_IDLE:
				begin
					// Wait for several cycle before starting DMA
					if (I_DMA_DONE)
					begin
						r_scu_state_machine <= SCU_WAIT_SETUP;
					end
					else
					begin
						r_scu_state_machine <= SCU_IDLE;
					end
				end
				SCU_WAIT_SETUP:
				begin
					// Wait for global signal to start load instruction process
					if (w_global_start_pulse)
					begin
						r_scu_state_machine <= SCU_LOAD_INSTRUCTION;
					end
					else
					begin
						r_scu_state_machine <= SCU_WAIT_SETUP;
					end
				end
				SCU_LOAD_INSTRUCTION:
				begin
					if (I_LOAD_INSTRUCTION_DONE)
					begin
						r_scu_state_machine <= SCU_RUNNING;
					end
					else
					begin
						r_scu_state_machine <= SCU_LOAD_INSTRUCTION;
					end
				end
				SCU_RUNNING:
				begin
					if (I_FORCE_LOAD_INSTRUCTION)
					begin
						r_scu_state_machine <= SCU_WAIT_SETUP;
					end
					else
					begin
						r_scu_state_machine <= SCU_RUNNING;
					end
				end
				default:
				begin
					if (I_FORCE_LOAD_INSTRUCTION)
					begin
						r_scu_state_machine <= SCU_WAIT_SETUP;
					end
					else
					begin
						r_scu_state_machine <= SCU_IDLE;
					end
				end
			endcase
		end
	end

	// Internal counter logic
	always @(posedge I_ACLK) 
	begin
		if (!I_ARESETN || r_program_counter_changed || ((r_scu_state_machine == SCU_RUNNING) && (r_program_counter == 0)))
		begin
			r_internal_counter <= 0;
		end
		else
		begin
			if ((r_scu_state_machine == SCU_IDLE) || (r_scu_state_machine == SCU_LOAD_INSTRUCTION) || (r_scu_state_machine == SCU_RUNNING))
			begin
				if (r_internal_counter < w_internal_counter_max)
				begin
					r_internal_counter <= r_internal_counter + 1;
				end
				else
				begin
					r_internal_counter <= r_internal_counter;
				end
			end
			else
			begin
				r_internal_counter <= 0;
			end
		end
	end

	// Start process and load instruction logic
	assign w_scu_start_process = (r_internal_counter == 2);
	assign O_LOAD_INSTRUCTION_START = (r_scu_state_machine == SCU_LOAD_INSTRUCTION) && w_scu_start_process;

	/////////////////////////////////////////////
	//        Instruction Decode Logic         //
	/////////////////////////////////////////////
	// Declare registers
	reg [7:0]  r_instruction_opcode;
	reg [7:0]  r_instruction_alpha;
	reg [7:0]  r_instruction_beta;
	reg [3:0]  r_instruction_gamma;
	reg [3:0]  r_instruction_delta;
	reg [31:0] r_instruction_value;

	// Decoder logic
	always @(posedge I_ACLK)
	begin
		if (!I_ARESETN)
		begin
			r_instruction_opcode <= 0;
			r_instruction_alpha <= 0;
			r_instruction_beta <= 0;
			r_instruction_gamma <= 0;
			r_instruction_delta <= 0;
			r_instruction_value <= 0;
		end
		else
		begin
			r_instruction_opcode <= I_INSTRUCTION_DATA[63:56]; // Op Code (8 bit)
			r_instruction_alpha  <= I_INSTRUCTION_DATA[55:48]; // Sel 0   (8 bit)
			r_instruction_beta   <= I_INSTRUCTION_DATA[47:40]; // Sel 1   (8 bit)
			r_instruction_gamma  <= I_INSTRUCTION_DATA[39:36]; // Sel 2   (8 bit)
			r_instruction_delta  <= I_INSTRUCTION_DATA[35:32]; // Sel Col (4 bit)
			r_instruction_value  <= I_INSTRUCTION_DATA[31:0];  // Value   (32 bit)
		end
	end

	/////////////////////////////////////////////
	//           SCU BRAM Bank Logic           //
	/////////////////////////////////////////////
	// Declare wires and registers
	// Start and done signal
	wire w_scu_reg_start;
	wire w_scu_reg_done;
	// Loop signal
	wire [15:0] w_scu_loop_i;
	wire [15:0] w_scu_loop_i_max;
	wire [15:0] w_scu_loop_j;
	wire [15:0] w_scu_loop_j_max;
	wire [15:0] w_scu_loop_k;
	wire [15:0] w_scu_loop_k_max;
	wire [15:0] w_scu_loop_l;
	wire [15:0] w_scu_loop_l_max;
	// SCU reset and mode register
	reg r_scu_loop_done;
	reg [1:0] r_scu_reg_mode;
	reg r_scu_reg_bank_force_reset;
	wire w_scu_reg_bank_reset;

	// Set loop done signal
	wire w_scu_loop_i_done = (w_scu_loop_i == w_scu_loop_i_max) && (r_instruction_opcode == 8'h04);
	wire w_scu_loop_j_done = (w_scu_loop_j == w_scu_loop_j_max) && (r_instruction_opcode == 8'h04);
	wire w_scu_loop_k_done = (w_scu_loop_k == w_scu_loop_k_max) && (r_instruction_opcode == 8'h04);
	wire w_scu_loop_l_done = (w_scu_loop_l == w_scu_loop_l_max) && (r_instruction_opcode == 8'h04);

	// Set loop variables
	always @(*)
	begin
		if (r_instruction_delta == 0)
		begin
			r_scu_loop_done = w_scu_loop_i_done;
		end
		else if (r_instruction_delta == 1)
		begin
			r_scu_loop_done = w_scu_loop_j_done;
		end
		else if (r_instruction_delta == 2)
		begin
			r_scu_loop_done = w_scu_loop_k_done;
		end
		else if (r_instruction_delta == 3)
		begin
			r_scu_loop_done = w_scu_loop_l_done;
		end
		else
		begin
			r_scu_loop_done = 0;
		end
	end

	// Set SCU register bank mode
	always @(*)
	begin
		if (r_instruction_opcode == 8'h02) // Set Register
		begin
			r_scu_reg_mode = 2'b01;
		end
		else if (r_instruction_opcode == 8'h03) // Increment Register
		begin
			r_scu_reg_mode = 2'b10;
		end
		else if (r_instruction_opcode == 8'h04) // Loop
		begin
			r_scu_reg_mode = 2'b11;
		end
		else
		begin
			r_scu_reg_mode = 2'b00;
		end
	end

	// Assign reset value for register bank
	assign w_scu_reg_bank_reset = I_ARESETN && !r_scu_reg_bank_force_reset;

	/////////////////////////////////////////////
	//          Program Counter Logic          //
	/////////////////////////////////////////////
	// Declare registers
	reg [INSTADDRWIDTH-1:0] r_program_counter;
	reg [INSTADDRWIDTH-1:0] r_program_counter_delayed;

	// Program counter change logic
	always @(posedge I_ACLK)
	begin
		if (!I_ARESETN)
		begin
			r_program_counter_changed <= 0;
		end
		else
		begin
			r_program_counter_changed <= (r_program_counter != r_program_counter_delayed);
		end
	end

	// Assign value to program counter output port
	assign O_PROGRAM_COUNTER = r_program_counter[INSTADDRWIDTH-1:0];

	// Program counter logic
	always @(posedge I_ACLK)
	begin
		if (!I_ARESETN || (r_scu_state_machine != SCU_RUNNING))
		begin
			r_program_counter <= 0;
		end
		else
		begin
			if (r_internal_counter >= 1)
			begin
				case (r_instruction_opcode)
					8'h00: // No operation just skip through the instruction, meanwhile if Halt, then wait until signal to start received
					begin
						if ((r_instruction_value[0] == 0 && (O_PROGRAM_COUNTER == 0 || w_scu_start_process)) || ((r_instruction_value[0] == 1) && w_global_start_pulse))
						begin
							r_program_counter <= r_program_counter + 1;
						end
						else
						begin
							r_program_counter <= r_program_counter;
						end
					end
					8'h01, 8'h05: // Start DMA, Deprecated just skips | Reset Register Bank
					begin
						if (w_scu_start_process)
						begin
							r_program_counter <= r_program_counter + 1;
						end
						else
						begin
							r_program_counter <= r_program_counter;
						end
					end
					8'h02, 8'h03: // Set, Increment Register Value
					begin
						if (w_scu_reg_done)
						begin
							r_program_counter <= r_program_counter + 1;
						end
						else
						begin
							r_program_counter <= r_program_counter;
						end
					end
					8'h04: // Loop Instruction
					begin
						if (r_scu_loop_done && w_scu_reg_done)
						begin
							r_program_counter <= r_program_counter + 1;
						end
						else if (!r_scu_loop_done && w_scu_reg_done)
						begin
							r_program_counter <= r_program_counter - r_instruction_value[INSTADDRWIDTH-1:0];
						end
						else
						begin
							r_program_counter <= r_program_counter;
						end
					end
					8'h10: // Load Input
					begin
						if (I_LI_DONE)
						begin
							r_program_counter <= r_program_counter + 1;
						end
						else
						begin
							r_program_counter <= r_program_counter;
						end
					end
					8'h11: // Sorting Process
					begin
						if (I_SORTING_DONE)
						begin
							r_program_counter <= r_program_counter + 1;
						end
						else
						begin
							r_program_counter <= r_program_counter;
						end
					end
					8'h14: // Stream out
					begin
						if (I_DATA_SEND_DONE)
						begin
							r_program_counter <= r_program_counter + 1;
						end
						else
						begin
							r_program_counter <= r_program_counter;
						end
					end
					8'h40: // Goto
					begin
						if (w_scu_start_process)
						begin
							r_program_counter <= r_instruction_value[INSTADDRWIDTH-1:0];
						end
						else
						begin
							r_program_counter <= r_program_counter;
						end
					end
					default:
					begin
						r_program_counter <= r_program_counter;
					end
				endcase
			end
			else
			begin
				r_program_counter <= r_program_counter;
			end
		end
	end

	// Delayed program counter logic
	always @(posedge I_ACLK)
	begin
		if (!I_ARESETN || (r_scu_state_machine != SCU_RUNNING))
		begin
			r_program_counter_delayed <= 0;
		end
		else
		begin
			r_program_counter_delayed <= r_program_counter;
		end
	end

	/////////////////////////////////////////////
	//        SCU Register Bank Control        //
	/////////////////////////////////////////////
	// Output port value logic
	// SCU register bank start logic
	assign w_scu_reg_start = w_scu_start_process && ((r_instruction_opcode == 8'h02) || (r_instruction_opcode == 8'h03) || (r_instruction_opcode == 8'h04));

	// SCU register bank force reset logic
	always @(posedge I_ACLK) 
	begin
		if (!I_ARESETN)
		begin
			r_scu_reg_bank_force_reset <= 0;
		end 
		else
		begin
			r_scu_reg_bank_force_reset <= (w_scu_start_process && (r_instruction_opcode == 8'h05));
		end
	end

	// Load port signal
	// Load Input Channel
	assign O_LI_START         = w_scu_start_process && (r_instruction_opcode == 8'h10);
	assign O_LI_SEL           = {{(SELWIDTH-2){1'b0}}, r_instruction_alpha[1:0]};
	assign O_LI_NO_OF_ROW     = r_instruction_value;

	// Sorting signal
	assign O_SORTING_START = w_scu_start_process && (r_instruction_opcode == 8'h11);

	// Stream Out channel
	assign O_SO_START         = w_scu_start_process && (r_instruction_opcode == 8'h14);

	/////////////////////////////////////////////
	//          DMA Controller Logic           //
	/////////////////////////////////////////////
	// DMA start logic
	assign O_DMA_START = ((r_scu_state_machine == SCU_LOAD_INSTRUCTION || r_scu_state_machine == SCU_IDLE) && r_internal_counter == 2) || (w_scu_start_process && (r_instruction_opcode[7:4] == 4'h1 || r_instruction_opcode[7:4] == 4'h3));

	// Assign interrupt signal
	assign O_PL_TO_PS_IRQ = (r_instruction_opcode == 8'h0) && (r_instruction_value[0] == 1'b1) || (r_scu_state_machine == SCU_WAIT_SETUP);

	// Set DMA mode
	always @(*)
	begin
		if (r_instruction_opcode >= 8'h10 && r_instruction_opcode <= 8'h13)
		begin
			O_DMA_MODE = 3'd1; // Read from DRAM
		end
		else if (r_instruction_opcode == 8'h14)
		begin
			O_DMA_MODE = 3'd2; // Write to DRAM
		end
		else
		begin
			if (r_scu_state_machine == SCU_IDLE)
			begin
				O_DMA_MODE = 3'd0; // Turn on DMA
			end
			else
			begin
				O_DMA_MODE = 3'd3; // Load Instruction
			end
		end
	end

	/////////////////////////////////////////////
	//           Performance Metric            //
	/////////////////////////////////////////////
	// State clock counter
	// Declare register
	reg [31:0] r_clock_count;

	// Counter logic
	always @(posedge I_ACLK)
	begin
		if (!I_ARESETN)
		begin
			r_clock_count <= 0;
		end
		else
		begin
			if (r_program_counter_changed)
			begin
				r_clock_count <= 0;
			end
			else
			begin
				r_clock_count <= r_clock_count + 1;
			end
		end
	end

	// State logger logic
	// Declare wire and registers
	wire w_state_logger_we_a = r_program_counter_changed;
	reg [31:0]  r_state_debug_out;
	reg [31:0]  r_reg_count,
				r_lop_count,
				r_li_count,
				r_sort_count,
				r_so_count,
				r_all_count;

	// Assign value to port
	assign O_LI_COUNT = r_li_count;
	assign O_RS_COUNT = r_sort_count;
	assign O_SO_COUNT = r_so_count;
	assign O_ALL_COUNT = r_all_count;

	// Counter logic
	always @(posedge I_ACLK)
	begin
		if (!I_ARESETN)
		begin
			r_reg_count <= 0;
			r_lop_count <= 0;
			r_li_count <= 0;
			r_sort_count <= 0;
			r_so_count <= 0;
			r_all_count <= 0;
		end
		else
		begin
			if (w_state_logger_we_a)
			begin
				// Register counter
				if (r_instruction_opcode == 8'h02 || r_instruction_opcode == 8'h03)
				begin
					r_reg_count <= r_reg_count + r_clock_count;
				end
				else
				begin
					r_reg_count <= r_reg_count;
				end

				// Loop instruction counter
				if (r_instruction_opcode == 8'h04 || r_instruction_opcode == 8'd40)
				begin
					r_lop_count <= r_lop_count + r_clock_count;
				end
				else
				begin
					r_lop_count <= r_lop_count;
				end

				// Load input instruction counter
				if (r_instruction_opcode == 8'h10)
				begin
					r_li_count <= r_li_count + r_clock_count;
				end
				else
				begin
					r_li_count <= r_li_count;
				end

				// Sorting instruction counter
				if (r_instruction_opcode == 8'h11)
				begin
					r_sort_count <= r_sort_count + r_clock_count;
				end
				else
				begin
					r_sort_count <= r_sort_count;
				end

				// Stream out instruction counter
				if (r_instruction_opcode == 8'h14)
				begin
					r_so_count <= r_so_count + r_clock_count;
				end
				else
				begin
					r_so_count <= r_so_count;
				end

				// Total counter
				if ((r_instruction_opcode == 8'h00) || (r_program_counter < 3))
				begin
					r_all_count <= r_all_count;
				end
				else
				begin
					r_all_count <= r_all_count + r_clock_count;
				end
			end
			else
			begin
				r_reg_count <= r_reg_count;
				r_lop_count <= r_lop_count;
				r_li_count <= r_li_count;
				r_sort_count <= r_sort_count;
				r_so_count <= r_so_count;
				r_all_count <= r_all_count;
			end
		end
	end

	// State debug logic
	always @(posedge I_ACLK)
	begin
		if (!I_ARESETN)
		begin
			r_state_debug_out <= 0;
		end
		else
		begin
			case (I_BRAM_DEBUG_ADDR)
			0:
			begin
				r_state_debug_out <= r_all_count;
			end
			1:
			begin
				r_state_debug_out <= r_reg_count;
			end
			2:
			begin
				r_state_debug_out <= r_lop_count;
			end
			3:
			begin
				r_state_debug_out <= r_li_count;
			end
			4:
			begin
				r_state_debug_out <= r_sort_count;
			end
			7:
			begin
				r_state_debug_out <= r_so_count;
			end
			default:
			begin
				r_state_debug_out <= r_all_count;
			end
			endcase
		end
	end

	// Assign value to port
	assign O_STATE_LOGGER_DATA = r_state_debug_out;

	///////////////////////////////////////////
	//          Instantiate Module           //
	///////////////////////////////////////////
	scu_bram_bank scu_bram_bank_unit
	(
		// Clock and Reset
		.I_ACLK(I_ACLK),
		.I_ARESETN(w_scu_reg_bank_reset),
		// Input from SCU
		.I_SEL_REG(r_instruction_alpha),
		.I_SEL_MULTIPLE(r_instruction_beta),
		.I_EN_MULTIPLE(r_instruction_gamma),
		.I_SEL_COL(r_instruction_delta),
		.I_VALUE(r_instruction_value),
		.I_MODE(r_scu_reg_mode),
		.I_INSTRUCTION_OPCODE(r_instruction_opcode),
		.I_START(w_scu_reg_start),
		.O_DONE(w_scu_reg_done),
		// DMA Address
		.O_DMA_ADDRESS(O_DMA_ADDR),
		.O_DMA_BYTE_TO_TRANSFER(O_DMA_BYTE_TO_TRANSFER),
		.O_DMA_NO_OF_TRANSACTION(O_DMA_NO_OF_TRANSACTION),
		// Load Input
		.O_LI_START_POINTER(O_LI_START_POINTER),
		// Stream Out
		.O_SO_START_POINTER(O_SO_START_POINTER),
		.O_SO_END_POINTER(O_SO_END_POINTER),
		// Loop
		.O_LOOP_I(w_scu_loop_i),
		.O_LOOP_I_MAX(w_scu_loop_i_max),
		.O_LOOP_J(w_scu_loop_j),
		.O_LOOP_J_MAX(w_scu_loop_j_max),
		.O_LOOP_K(w_scu_loop_k),
		.O_LOOP_K_MAX(w_scu_loop_k_max),
		.O_LOOP_L(w_scu_loop_l),
		.O_LOOP_L_MAX(w_scu_loop_l_max)
	);

endmodule