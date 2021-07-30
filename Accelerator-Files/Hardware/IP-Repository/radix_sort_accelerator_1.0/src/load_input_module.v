//********************************************************************************
//                      [ MODULE ]                                                
//                                                                                
// Institution       : Korea Advanced Institute of Science and Technology         
// Engineer          : Dalta Imam Maulana                                         
//                                                                                
// Project Name      : Near Memory Radix Sort                                     
//                                                                                
// Create Date       : 6/21/2021
// File Name         : load_input_module.v                                           
// Module Dependency : -                                                          
//                                                                                
// Target Device     : ZCU104                                                     
// Tool Version      : Vivado 2020.1                                              
//                                                                                
// Description:                                                                   
//      Module for loading and managing input data from DRAM to BRAM              
//                                                                                
//********************************************************************************
`timescale 1ns / 1ps

module load_input_module
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
		// Clock and Reset
		input wire I_ACLK,
		input wire I_ARESETN,
		// Stream In
		output wire O_STREAM_DEQUEUE,
		input wire I_STREAM_VALID,
		input wire [DWIDTH-1:0] I_STREAM_DATA,
		// SCU part
		input wire I_START,
		input wire [31:0] I_NO_OF_ROW,
		input wire [DATAADDRWIDTH-1:0] I_START_POINTER,
		input wire [SELWIDTH-1:0] I_SEL,
		output wire O_DONE,
		// BRAM Bank
		output wire [DATAADDRWIDTH-1:0] O_LI_POINTER,
		output wire O_LI_VALID,
		output wire [DWIDTH-1:0] O_LI_DATA,
		output reg [SELWIDTH-1:0] O_LI_SEL
	);

	///////////////////////////////
	//      Local Parameter      //
	///////////////////////////////
	// State machines
	localparam [1:0] IDLE    = 2'd0,
		RUNNING = 2'd1,
		DONE    = 2'd2;

	///////////////////////////////
	//     Start Signal Logic    //
	///////////////////////////////
	// Declare register and wire
	reg r_start_delay;
	wire w_start_pulse;

	// Start signal logic
	always @(posedge I_ACLK) 
	begin
		r_start_delay <= I_START;
	end
	// Start pulse generation
	assign w_start_pulse = I_START && !r_start_delay;

	///////////////////////////////
	//    State Machine Logic    //
	///////////////////////////////
	// Declare register
	reg [31:0] r_data_counter;
	reg [DATAADDRWIDTH-1:0] r_load_input_pointer;
	reg [1:0] r_internal_state;
	wire w_last;

	// Assign value for last signal
	assign w_last = (r_data_counter == I_NO_OF_ROW-1) && I_STREAM_VALID;

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
	reg [1:0] r_load_input_state;

	// State machine logic
	always @(posedge I_ACLK)
	begin
		if (!I_ARESETN)
		begin
			r_load_input_state <= 2'd0;
		end
		else
		begin
			if (r_internal_state == RUNNING)
			begin
				case (r_load_input_state)
					2'd0:
					begin
						r_load_input_state <= 2'd1;
					end
					2'd1:
					begin
						if ((r_data_counter == (I_NO_OF_ROW-1)) && I_STREAM_VALID)
						begin
							r_load_input_state <= 2'd2;
						end
						else
						begin
							r_load_input_state <= 2'd1;
						end
					end
					default:
					begin
						r_load_input_state <= 2'd0;
					end
				endcase
			end
			else
			begin
				r_load_input_state <= 2'd0;
			end
		end
	end

	// Input pointer logic
	always @(posedge I_ACLK)
	begin
		if (!I_ARESETN || (r_internal_state != RUNNING))
		begin
			r_load_input_pointer <= 0;
		end
		else
		begin
			if (O_LI_VALID)
			begin
				if (r_load_input_pointer < (DATABRAMDEPTH-1))
				begin
					r_load_input_pointer <= r_load_input_pointer + 1;
				end
				else
				begin
					r_load_input_pointer <= 0;
				end
			end
			else
			begin
				r_load_input_pointer <= r_load_input_pointer;
			end
		end
	end

	// Data counter logic
	always @(posedge I_ACLK)
	begin
		if (!I_ARESETN || (r_internal_state != RUNNING))
		begin
			r_data_counter <= 0;
		end
		else
		begin
			if (O_LI_VALID)
			begin
				r_data_counter <= r_data_counter + 1;
			end
			else
			begin
				r_data_counter <= r_data_counter;
			end
		end
	end

	// Signal to BRAM
	assign O_LI_POINTER = I_START_POINTER + r_load_input_pointer;
	assign O_LI_VALID = I_STREAM_VALID && (r_load_input_state == 2'd1) && (r_internal_state == RUNNING);
	assign O_LI_DATA = I_STREAM_DATA;

	// Signal to FIFO input
	assign O_STREAM_DEQUEUE = (r_load_input_state == 2'd1);

	// BRAM Input selector
	always @(*)
	begin
		if (r_data_counter < 32768)
		begin
			O_LI_SEL = 10'b0000000000;
		end
		else if ((r_data_counter >= 32768) && (r_data_counter < 65536))
		begin
			O_LI_SEL = 10'b0000000001;
		end
		else
		begin
			O_LI_SEL = 10'b0000000000;
		end
	end

endmodule