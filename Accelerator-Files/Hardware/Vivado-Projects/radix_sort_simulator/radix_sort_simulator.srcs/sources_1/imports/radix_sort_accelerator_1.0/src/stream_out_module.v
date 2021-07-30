//********************************************************************************
//                      [ MODULE ]                                                
//                                                                                
// Institution       : Korea Advanced Institute of Science and Technology         
// Engineer          : Dalta Imam Maulana                                         
//                                                                                
// Project Name      : Near Memory Radix Sort                                     
//                                                                                
// Create Date       : 6/21/2021
// File Name         : stream_out_module.v                                           
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

module stream_out_module
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
		// SCU
		input wire          I_START,
		input wire  [DATAADDRWIDTH-1:0]  I_START_POINTER,
		input wire  [DATAADDRWIDTH-1:0]  I_END_POINTER,
		output wire         O_DONE,
		// BRAM Bank
		output wire [SELWIDTH-1:0]  O_BRAM_SEL,
		output wire [DATAADDRWIDTH-1:0] O_SEND_DATA_POINTER,
		// Send Data
		input wire          I_STREAM_FULL,
		output wire         O_STREAM_QUEUE,
		output wire         O_STREAM_SEND_NOW
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
	reg [1:0] r_internal_state;
	wire w_last;

	// Assign value for last signal
	assign w_last = ((r_internal_state == RUNNING) && (r_do_so_state != DO_SO_STATE_IDLE) && (r_data_counter == {{(32-DATAADDRWIDTH){1'b0}}, I_END_POINTER}));

	// Assign done and stream send signal value
	assign O_DONE = (r_internal_state == DONE);
	assign O_STREAM_SEND_NOW = (w_start_pulse || (r_internal_state == RUNNING));

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

	/////////////////////////////////////
	//    Stream Output State Logic    //
	/////////////////////////////////////
	// Declare local parameter
	localparam [2:0]   DO_SO_STATE_IDLE = 3'd0,
		DO_SO_STATE_LOAD_BANK = 3'd1,
		DO_SO_STATE_LOAD_DONE = 3'd2;

	// Declare wire and registers
	wire w_stream_queue;
	reg r_stream_queue_delayed;
	wire w_do_so_last;
	reg [2:0] r_do_so_state;
	reg [DATAADDRWIDTH-1:0] r_send_pointer;
	reg [31:0] r_data_counter;

	// Assign value to last signal
	assign w_do_so_last = ((r_internal_state == RUNNING) && (r_do_so_state != DO_SO_STATE_IDLE) && (r_data_counter == {{(32-DATAADDRWIDTH){1'b0}}, I_END_POINTER}));

	// Assign value to stream queue signal
	assign w_stream_queue = ((r_internal_state == RUNNING) && (r_do_so_state != DO_SO_STATE_IDLE));
	assign O_STREAM_QUEUE = (w_stream_queue && r_stream_queue_delayed) && !I_STREAM_FULL;

	// Delay queue signal
	always @(posedge I_ACLK)
	begin
		r_stream_queue_delayed <= w_stream_queue;
	end

	// Data pointer logic
	always @(posedge I_ACLK)
	begin
		if (!I_ARESETN || (r_internal_state != RUNNING))
		begin
			r_send_pointer <= I_START_POINTER;
			r_data_counter <= {{(32-DATAADDRWIDTH){1'b0}}, I_START_POINTER};
		end
		else
		begin
			if (w_start_pulse)
			begin
				r_send_pointer <= I_START_POINTER;
				r_data_counter <= {{(32-DATAADDRWIDTH){1'b0}}, I_START_POINTER};
			end
			else
			begin
				if (!I_STREAM_FULL)
				begin
					if (!w_do_so_last && (r_do_so_state == DO_SO_STATE_LOAD_BANK))
					begin
						if (r_send_pointer < (DATABRAMDEPTH-1))
						begin
							r_send_pointer <= r_send_pointer + 1;
							r_data_counter <= r_data_counter + 1;
						end
						else
						begin
							r_send_pointer <= 0;
							r_data_counter <= r_data_counter + 1;
						end
					end
					else
					begin
						r_send_pointer <= r_send_pointer;
						r_data_counter <= r_data_counter;
					end
				end
				else
				begin
					r_send_pointer <= r_send_pointer;
					r_data_counter <= r_data_counter;
				end
			end
		end
	end

	// Stream out state logic
	always @(posedge I_ACLK)
	begin
		if (!I_ARESETN || (r_internal_state != RUNNING))
		begin
			r_do_so_state <= DO_SO_STATE_IDLE;
		end
		else
		begin
			case (r_do_so_state)
				DO_SO_STATE_IDLE:
				begin
					r_do_so_state <= DO_SO_STATE_LOAD_BANK;
				end
				DO_SO_STATE_LOAD_BANK:
				begin
					if (w_do_so_last)
					begin
						r_do_so_state <= DO_SO_STATE_LOAD_DONE;
					end
					else
					begin
						r_do_so_state <= DO_SO_STATE_LOAD_BANK;
					end
				end
				default:
				begin
					r_do_so_state <= r_do_so_state;
				end
			endcase
		end
	end

	///////////////////////////////
	//    BRAM Selector Logic    //
	///////////////////////////////
	// Declare register
	reg [SELWIDTH-1:0] r_bram_sel;

	// BRAM selector logic
	always @(*)
	begin
		if (r_data_counter < 1024)
		begin
			r_bram_sel = 10'b0000000000;
		end
		else if ((r_data_counter >= 1024) && (r_data_counter < 2048))
		begin
			r_bram_sel = 10'b0000000001;
		end
		else
		begin
			r_bram_sel = 10'b0000000000;
		end
	end

	////////////////////////////////////////
	//    Output Port Logic Assignment    //
	////////////////////////////////////////
	assign O_BRAM_SEL = r_bram_sel;
	assign O_SEND_DATA_POINTER = r_send_pointer;

endmodule