//********************************************************************************
//                      [ MODULE ]                                                
//                                                                                
// Institution       : Korea Advanced Institute of Science and Technology         
// Engineer          : Dalta Imam Maulana                                         
//                                                                                
// Project Name      : Near Memory Radix Sort                                     
//                                                                                
// Create Date       : 6/21/2021
// File Name         : load_instruction_module.v                                           
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

module load_instruction_module
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
		parameter INSTADDRWIDTH =10,
		parameter MAXINSTCOUNT =1024
	)

	// Declare ports
	(
		// Clock and Reset
		input wire I_ACLK,
		input wire I_ARESETN,
		// Stream In
		output wire O_STREAM_DEQUEUE,
		input wire I_STREAM_VALID,
		input wire [DWIDTH-1:0] I_STREAM_DATA, // Unordered data
		// SCU part
		input wire I_START,
		output wire O_DONE,
		// BRAM Bank
		output wire [INSTADDRWIDTH-1:0] O_LOAD_INSTRUCTION_POINTER,
		output wire O_LOAD_INSTRUCTION_VALID,
		output wire [DWIDTH-1:0] O_LOAD_INSTRUCTION_DATA
	);

	//////////////////////////////////////
	//        Start Pulse Logic         //
	//////////////////////////////////////
	// Declare register and wire
	reg r_start_delay;
	wire w_start_pulse;

	// Delayed start logic
	always @(posedge I_ACLK)
	begin
		r_start_delay <= I_START;
	end

	// Start pulse logic
	assign w_start_pulse = I_START && !r_start_delay;

	////////////////////////////////////////
	//        State Machine Logic         //
	////////////////////////////////////////
	// Declare local parameter
	localparam [1:0] IDLE    = 2'd0,
		RUNNING = 2'd1,
		DONE    = 2'd2;

	// Declare register
	reg [1:0] r_internal_state;
	wire w_last;

	// Assign last signal logic
	assign w_last = (O_LOAD_INSTRUCTION_POINTER == (MAXINSTCOUNT-2)) && I_STREAM_VALID;

	// Assign done and stream send signal value
	assign O_DONE = (r_internal_state == DONE);

	// State machine logic
	always @(posedge I_ACLK)
	begin
		if (!I_ARESETN)
		begin
			r_internal_state <= IDLE;
		end
		else
		begin
			case (r_internal_state)
				IDLE:
				begin
					if (w_start_pulse)
					begin
						r_internal_state <= RUNNING;
					end
					else
					begin
						r_internal_state <= IDLE;
					end
				end
				RUNNING:
				begin
					if (w_last)
					begin
						r_internal_state <= DONE;
					end
					else
					begin
						r_internal_state <= RUNNING;
					end
				end
				DONE:
				begin
						r_internal_state <= IDLE;
				end
				default:
				begin
						r_internal_state <= IDLE;
				end
			endcase
		end
	end

	///////////////////////////////
	//       Pointer Logic       //
	///////////////////////////////
	// Declare registers
	reg [1:0] r_load_instruction_state;
	reg [INSTADDRWIDTH-1:0] r_load_instruction_pointer;

	// State logic
	always @(posedge I_ACLK)
	begin
		if (!I_ARESETN)
		begin
			r_load_instruction_state <= 2'd0;
		end
		else
		begin
			if (r_internal_state == RUNNING)
			begin
				case (r_load_instruction_state)
					2'd0: // IDLE
					begin
						r_load_instruction_state <= 2'd1;
					end
					2'd1: // Load instruction
					begin
						if ((r_load_instruction_pointer == (MAXINSTCOUNT-2)) && I_STREAM_VALID)
						begin
							r_load_instruction_state <= 2'd2;
						end
						else
						begin
							r_load_instruction_state <= 2'd1;
						end
					end
					default:
					begin
						r_load_instruction_state <= 2'd0;
					end
				endcase
			end
			else
			begin
				r_load_instruction_state <= 2'd0;
			end
		end
	end

	// Pointer logic
	always @(posedge I_ACLK)
	begin
		if (!I_ARESETN || (r_internal_state != RUNNING))
		begin
			r_load_instruction_pointer <= 0;
		end
		else
		begin
			if (O_LOAD_INSTRUCTION_VALID)
			begin
				if (r_load_instruction_pointer == (MAXINSTCOUNT-2))
				begin
					r_load_instruction_pointer <= 0;
				end
				else
				begin
					r_load_instruction_pointer <= r_load_instruction_pointer + 2;
				end
			end
			else
			begin
				r_load_instruction_pointer <= r_load_instruction_pointer;
			end
		end
	end

	////////////////////////////////////////
	//       Output Port Assignment       //
	////////////////////////////////////////
	assign O_LOAD_INSTRUCTION_DATA = I_STREAM_DATA;
	assign O_LOAD_INSTRUCTION_VALID = I_STREAM_VALID && (r_load_instruction_state == 2'd1);
	assign O_LOAD_INSTRUCTION_POINTER = r_load_instruction_pointer;
	assign O_STREAM_DEQUEUE = r_load_instruction_state == 2'd1;

	endmodule
