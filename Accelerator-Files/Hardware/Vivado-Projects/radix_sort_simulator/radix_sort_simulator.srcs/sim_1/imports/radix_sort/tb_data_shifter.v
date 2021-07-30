//**********************************************************************************
//                      [ MODULE ]
//
// Institution       : Korea Advanced Institute of Science and Technology (KAIST)
// Engineer          : Dalta Imam Maulana
//
// Project Name      : Near Memory Radix Sort
//
// Create Date       : 06/20/2021
// File Name         : tb_data_shifter.v
// Module Dependency : -
//
// Target Device     : ZCU-104
// Tool Version      : Vivado 2020.1
//
// Description:
//       [Testbench] Module which performs data rearrangement for mixed row data
//
//**********************************************************************************

module tb_data_shifter;
    ///////////////////////////////////
	//     Generate Test Sequence    //
	///////////////////////////////////
    // Declare integer
    integer i;
    // Declare registers and wires
    // Input ports
        reg I_ACLK;
        reg I_ARESETN;
        reg I_START;
        reg I_DATA_FLAG;
        reg [2:0] I_DATA_PATTERN;
        reg [ADDRWIDTH-1:0] I_ZERO_COUNT;
        reg [ADDRWIDTH-1:0] I_ONE_COUNT;
        reg [DWIDTH-1:0] I_BRAM_DATA;

        // Output ports
        wire O_VALID;
        wire [DWIDTH-1:0] O_CACHE_DATA;

        // Declare local parameters
        localparam PERIOD = 20;
        localparam DWIDTH = 128;
        localparam DEPTH = 1024;
        localparam ADDRWIDTH = 10;

        // Initialize register
        initial 
        begin
            I_ACLK = 1;
            I_ARESETN = 1;
            I_START = 0;
            I_DATA_FLAG = 0;
            I_DATA_PATTERN = 0;
            I_ZERO_COUNT = 0;
            I_ONE_COUNT = 0;
            I_BRAM_DATA = 0;               
        end

        // Generate clock signal
        always 
        begin
            #(PERIOD/2);
            I_ACLK = !I_ACLK;
        end

        // Generate input sequence
        initial 
        begin
            // Initial reset
            I_ARESETN <= 0;
            #PERIOD;

            // Start sequence
            I_ARESETN <= 1;
            I_START <= 1;
            I_DATA_FLAG <= 0;
            I_DATA_PATTERN <= 3;
            I_ZERO_COUNT <= 4;
            I_ONE_COUNT <= 4;
            I_BRAM_DATA <= 128'h00000000000000000000000000000000;
            #PERIOD;

            // Zero sequnce
            I_ARESETN <= 1;
            I_START <= 0;
            I_DATA_FLAG <= 0;
            I_DATA_PATTERN <= 3;
            I_ZERO_COUNT <= 4;
            I_ONE_COUNT <= 4;
            I_BRAM_DATA <= 128'h00000008000000060000000400000002;
            #PERIOD;
            
            I_ARESETN <= 1;
            I_START <= 0;
            I_DATA_FLAG <= 0;
            I_DATA_PATTERN <= 3;
            I_ZERO_COUNT <= 4;
            I_ONE_COUNT <= 4;
            I_BRAM_DATA <= 128'h000000100000000E0000000C0000000A;
            #PERIOD;

            I_ARESETN <= 1;
            I_START <= 0;
            I_DATA_FLAG <= 0;
            I_DATA_PATTERN <= 3;
            I_ZERO_COUNT <= 4;
            I_ONE_COUNT <= 4;
            I_BRAM_DATA <= 128'h00000018000000160000001400000012;
            #PERIOD;

            I_ARESETN <= 1;
            I_START <= 0;
            I_DATA_FLAG <= 0;
            I_DATA_PATTERN <= 3;
            I_ZERO_COUNT <= 4;
            I_ONE_COUNT <= 4;
            I_BRAM_DATA <= 128'h000000200000001E0000001C0000001A;
            #PERIOD;

            // <Mix sequnce
            I_ARESETN <= 1;
            I_START <= 0;
            I_DATA_FLAG <= 0;
            I_DATA_PATTERN <= 3;
            I_ZERO_COUNT <= 4;
            I_ONE_COUNT <= 4;
            I_BRAM_DATA <= 128'h00000019000000260000002400000022;
            #PERIOD;

            // One sequnce
            I_ARESETN <= 1;
            I_START <= 0;
            I_DATA_FLAG <= 0;
            I_DATA_PATTERN <= 3;
            I_ZERO_COUNT <= 4;
            I_ONE_COUNT <= 4;
            I_BRAM_DATA <= 128'h00000007000000050000000300000001;
            #PERIOD;

            I_ARESETN <= 1;
            I_START <= 0;
            I_DATA_FLAG <= 0;
            I_DATA_PATTERN <= 3;
            I_ZERO_COUNT <= 4;
            I_ONE_COUNT <= 4;
            I_BRAM_DATA <= 128'h0000000F0000000D0000000B00000009;
            #PERIOD;

            I_ARESETN <= 1;
            I_START <= 0;
            I_DATA_FLAG <= 0;
            I_DATA_PATTERN <= 3;
            I_ZERO_COUNT <= 4;
            I_ONE_COUNT <= 4;
            I_BRAM_DATA <= 128'h00000017000000150000001300000011;
            #PERIOD;
            #PERIOD;
            #PERIOD;
            #PERIOD;
          
            // Start sequence
            I_ARESETN <= 1;
            I_START <= 1;
            I_DATA_FLAG <= 0;
            I_DATA_PATTERN <= 2;
            I_ZERO_COUNT <= 4;
            I_ONE_COUNT <= 4;
            I_BRAM_DATA <= 128'h00000000000000000000000000000000;
            #PERIOD;

            // Zero sequnce
            I_ARESETN <= 1;
            I_START <= 0;
            I_DATA_FLAG <= 0;
            I_DATA_PATTERN <= 2;
            I_ZERO_COUNT <= 4;
            I_ONE_COUNT <= 4;
            I_BRAM_DATA <= 128'h00000008000000060000000400000002;
            #PERIOD;
            
            I_ARESETN <= 1;
            I_START <= 0;
            I_DATA_FLAG <= 0;
            I_DATA_PATTERN <= 2;
            I_ZERO_COUNT <= 4;
            I_ONE_COUNT <= 4;
            I_BRAM_DATA <= 128'h000000100000000E0000000C0000000A;
            #PERIOD;

            I_ARESETN <= 1;
            I_START <= 0;
            I_DATA_FLAG <= 0;
            I_DATA_PATTERN <= 2;
            I_ZERO_COUNT <= 4;
            I_ONE_COUNT <= 4;
            I_BRAM_DATA <= 128'h00000018000000160000001400000012;
            #PERIOD;

            I_ARESETN <= 1;
            I_START <= 0;
            I_DATA_FLAG <= 0;
            I_DATA_PATTERN <= 2;
            I_ZERO_COUNT <= 4;
            I_ONE_COUNT <= 4;
            I_BRAM_DATA <= 128'h000000200000001E0000001C0000001A;
            #PERIOD;

            // <Mix sequnce
            I_ARESETN <= 1;
            I_START <= 0;
            I_DATA_FLAG <= 0;
            I_DATA_PATTERN <= 2;
            I_ZERO_COUNT <= 4;
            I_ONE_COUNT <= 4;
            I_BRAM_DATA <= 128'h0000001B000000190000002400000022;
            #PERIOD;

            // One sequnce
            I_ARESETN <= 1;
            I_START <= 0;
            I_DATA_FLAG <= 0;
            I_DATA_PATTERN <= 2;
            I_ZERO_COUNT <= 4;
            I_ONE_COUNT <= 4;
            I_BRAM_DATA <= 128'h00000007000000050000000300000001;
            #PERIOD;

            I_ARESETN <= 1;
            I_START <= 0;
            I_DATA_FLAG <= 0;
            I_DATA_PATTERN <= 2;
            I_ZERO_COUNT <= 4;
            I_ONE_COUNT <= 4;
            I_BRAM_DATA <= 128'h0000000F0000000D0000000B00000009;
            #PERIOD;

            I_ARESETN <= 1;
            I_START <= 0;
            I_DATA_FLAG <= 0;
            I_DATA_PATTERN <= 2;
            I_ZERO_COUNT <= 4;
            I_ONE_COUNT <= 4;
            I_BRAM_DATA <= 128'h00000017000000150000001300000011;
            #PERIOD;
            #PERIOD;
            #PERIOD;
            #PERIOD;

            // Start sequence
            I_ARESETN <= 1;
            I_START <= 1;
            I_DATA_FLAG <= 0;
            I_DATA_PATTERN <= 1;
            I_ZERO_COUNT <= 4;
            I_ONE_COUNT <= 4;
            I_BRAM_DATA <= 128'h00000000000000000000000000000000;
            #PERIOD;

            // Zero sequnce
            I_ARESETN <= 1;
            I_START <= 0;
            I_DATA_FLAG <= 0;
            I_DATA_PATTERN <= 1;
            I_ZERO_COUNT <= 4;
            I_ONE_COUNT <= 4;
            I_BRAM_DATA <= 128'h00000008000000060000000400000002;
            #PERIOD;
            
            I_ARESETN <= 1;
            I_START <= 0;
            I_DATA_FLAG <= 0;
            I_DATA_PATTERN <= 1;
            I_ZERO_COUNT <= 4;
            I_ONE_COUNT <= 4;
            I_BRAM_DATA <= 128'h000000100000000E0000000C0000000A;
            #PERIOD;

            I_ARESETN <= 1;
            I_START <= 0;
            I_DATA_FLAG <= 0;
            I_DATA_PATTERN <= 1;
            I_ZERO_COUNT <= 4;
            I_ONE_COUNT <= 4;
            I_BRAM_DATA <= 128'h00000018000000160000001400000012;
            #PERIOD;

            I_ARESETN <= 1;
            I_START <= 0;
            I_DATA_FLAG <= 0;
            I_DATA_PATTERN <= 1;
            I_ZERO_COUNT <= 4;
            I_ONE_COUNT <= 4;
            I_BRAM_DATA <= 128'h000000200000001E0000001C0000001A;
            #PERIOD;

            // <Mix sequnce
            I_ARESETN <= 1;
            I_START <= 0;
            I_DATA_FLAG <= 0;
            I_DATA_PATTERN <= 1;
            I_ZERO_COUNT <= 4;
            I_ONE_COUNT <= 4;
            I_BRAM_DATA <= 128'h0000001D0000001B0000001900000022;
            #PERIOD;

            // One sequnce
            I_ARESETN <= 1;
            I_START <= 0;
            I_DATA_FLAG <= 0;
            I_DATA_PATTERN <= 1;
            I_ZERO_COUNT <= 4;
            I_ONE_COUNT <= 4;
            I_BRAM_DATA <= 128'h00000007000000050000000300000001;
            #PERIOD;

            I_ARESETN <= 1;
            I_START <= 0;
            I_DATA_FLAG <= 0;
            I_DATA_PATTERN <= 1;
            I_ZERO_COUNT <= 4;
            I_ONE_COUNT <= 4;
            I_BRAM_DATA <= 128'h0000000F0000000D0000000B00000009;
            #PERIOD;

            I_ARESETN <= 1;
            I_START <= 0;
            I_DATA_FLAG <= 0;
            I_DATA_PATTERN <= 1;
            I_ZERO_COUNT <= 4;
            I_ONE_COUNT <= 4;
            I_BRAM_DATA <= 128'h00000017000000150000001300000011;
            #PERIOD;
            #PERIOD;
            #PERIOD;
            #PERIOD;

            // Start sequence
            I_ARESETN <= 1;
            I_START <= 1;
            I_DATA_FLAG <= 0;
            I_DATA_PATTERN <= 4;
            I_ZERO_COUNT <= 4;
            I_ONE_COUNT <= 4;
            I_BRAM_DATA <= 128'h00000000000000000000000000000000;
            #PERIOD;

            // Zero sequnce
            I_ARESETN <= 1;
            I_START <= 0;
            I_DATA_FLAG <= 0;
            I_DATA_PATTERN <= 4;
            I_ZERO_COUNT <= 4;
            I_ONE_COUNT <= 4;
            I_BRAM_DATA <= 128'h00000008000000060000000400000002;
            #PERIOD;
            
            I_ARESETN <= 1;
            I_START <= 0;
            I_DATA_FLAG <= 0;
            I_DATA_PATTERN <= 4;
            I_ZERO_COUNT <= 4;
            I_ONE_COUNT <= 4;
            I_BRAM_DATA <= 128'h000000100000000E0000000C0000000A;
            #PERIOD;

            I_ARESETN <= 1;
            I_START <= 0;
            I_DATA_FLAG <= 0;
            I_DATA_PATTERN <= 4;
            I_ZERO_COUNT <= 4;
            I_ONE_COUNT <= 4;
            I_BRAM_DATA <= 128'h00000018000000160000001400000012;
            #PERIOD;

            I_ARESETN <= 1;
            I_START <= 0;
            I_DATA_FLAG <= 0;
            I_DATA_PATTERN <= 4;
            I_ZERO_COUNT <= 4;
            I_ONE_COUNT <= 4;
            I_BRAM_DATA <= 128'h000000200000001E0000001C0000001A;
            #PERIOD;

            // <Mix sequnce
            I_ARESETN <= 1;
            I_START <= 0;
            I_DATA_FLAG <= 0;
            I_DATA_PATTERN <= 4;
            I_ZERO_COUNT <= 4;
            I_ONE_COUNT <= 4;
            I_BRAM_DATA <= 128'h00000028000000260000002400000022;
            #PERIOD;

            // One sequnce
            I_ARESETN <= 1;
            I_START <= 0;
            I_DATA_FLAG <= 0;
            I_DATA_PATTERN <= 4;
            I_ZERO_COUNT <= 4;
            I_ONE_COUNT <= 4;
            I_BRAM_DATA <= 128'h00000007000000050000000300000001;
            #PERIOD;

            I_ARESETN <= 1;
            I_START <= 0;
            I_DATA_FLAG <= 0;
            I_DATA_PATTERN <= 4;
            I_ZERO_COUNT <= 4;
            I_ONE_COUNT <= 4;
            I_BRAM_DATA <= 128'h0000000F0000000D0000000B00000009;
            #PERIOD;

            I_ARESETN <= 1;
            I_START <= 0;
            I_DATA_FLAG <= 0;
            I_DATA_PATTERN <= 4;
            I_ZERO_COUNT <= 4;
            I_ONE_COUNT <= 4;
            I_BRAM_DATA <= 128'h00000017000000150000001300000011;
            #PERIOD;
            #PERIOD;
            #PERIOD;
            #PERIOD;

            // Start sequence
            I_ARESETN <= 1;
            I_START <= 1;
            I_DATA_FLAG <= 1;
            I_DATA_PATTERN <= 3;
            I_ZERO_COUNT <= 4;
            I_ONE_COUNT <= 4;
            I_BRAM_DATA <= 128'h00000000000000000000000000000000;
            #PERIOD;

            // Zero sequnce
            I_ARESETN <= 1;
            I_START <= 0;
            I_DATA_FLAG <= 1;
            I_DATA_PATTERN <= 3;
            I_ZERO_COUNT <= 4;
            I_ONE_COUNT <= 4;
            I_BRAM_DATA <= 128'h00000008000000060000000400000002;
            #PERIOD;
            
            I_ARESETN <= 1;
            I_START <= 0;
            I_DATA_FLAG <= 1;
            I_DATA_PATTERN <= 3;
            I_ZERO_COUNT <= 4;
            I_ONE_COUNT <= 4;
            I_BRAM_DATA <= 128'h000000100000000E0000000C0000000A;
            #PERIOD;

            I_ARESETN <= 1;
            I_START <= 0;
            I_DATA_FLAG <= 1;
            I_DATA_PATTERN <= 3;
            I_ZERO_COUNT <= 4;
            I_ONE_COUNT <= 4;
            I_BRAM_DATA <= 128'h00000018000000160000001400000012;
            #PERIOD;

            I_ARESETN <= 1;
            I_START <= 0;
            I_DATA_FLAG <= 1;
            I_DATA_PATTERN <= 3;
            I_ZERO_COUNT <= 4;
            I_ONE_COUNT <= 4;
            I_BRAM_DATA <= 128'h000000200000001E0000001C0000001A;
            #PERIOD;

            // <Mix sequnce
            I_ARESETN <= 1;
            I_START <= 0;
            I_DATA_FLAG <= 1;
            I_DATA_PATTERN <= 3;
            I_ZERO_COUNT <= 4;
            I_ONE_COUNT <= 4;
            I_BRAM_DATA <= 128'h00000026000000240000002200000019;
            #PERIOD;

            // One sequnce
            I_ARESETN <= 1;
            I_START <= 0;
            I_DATA_FLAG <= 1;
            I_DATA_PATTERN <= 3;
            I_ZERO_COUNT <= 4;
            I_ONE_COUNT <= 4;
            I_BRAM_DATA <= 128'h00000007000000050000000300000001;
            #PERIOD;

            I_ARESETN <= 1;
            I_START <= 0;
            I_DATA_FLAG <= 1;
            I_DATA_PATTERN <= 3;
            I_ZERO_COUNT <= 4;
            I_ONE_COUNT <= 4;
            I_BRAM_DATA <= 128'h0000000F0000000D0000000B00000009;
            #PERIOD;

            I_ARESETN <= 1;
            I_START <= 0;
            I_DATA_FLAG <= 1;
            I_DATA_PATTERN <= 3;
            I_ZERO_COUNT <= 4;
            I_ONE_COUNT <= 4;
            I_BRAM_DATA <= 128'h00000017000000150000001300000011;
            #PERIOD;
            #PERIOD;
            #PERIOD;
            #PERIOD;

            // Start sequence
            I_ARESETN <= 1;
            I_START <= 1;
            I_DATA_FLAG <= 1;
            I_DATA_PATTERN <= 2;
            I_ZERO_COUNT <= 4;
            I_ONE_COUNT <= 4;
            I_BRAM_DATA <= 128'h00000000000000000000000000000000;
            #PERIOD;

            // Zero sequnce
            I_ARESETN <= 1;
            I_START <= 0;
            I_DATA_FLAG <= 1;
            I_DATA_PATTERN <= 2;
            I_ZERO_COUNT <= 4;
            I_ONE_COUNT <= 4;
            I_BRAM_DATA <= 128'h00000008000000060000000400000002;
            #PERIOD;
            
            I_ARESETN <= 1;
            I_START <= 0;
            I_DATA_FLAG <= 1;
            I_DATA_PATTERN <= 2;
            I_ZERO_COUNT <= 4;
            I_ONE_COUNT <= 4;
            I_BRAM_DATA <= 128'h000000100000000E0000000C0000000A;
            #PERIOD;

            I_ARESETN <= 1;
            I_START <= 0;
            I_DATA_FLAG <= 1;
            I_DATA_PATTERN <= 2;
            I_ZERO_COUNT <= 4;
            I_ONE_COUNT <= 4;
            I_BRAM_DATA <= 128'h00000018000000160000001400000012;
            #PERIOD;

            I_ARESETN <= 1;
            I_START <= 0;
            I_DATA_FLAG <= 1;
            I_DATA_PATTERN <= 2;
            I_ZERO_COUNT <= 4;
            I_ONE_COUNT <= 4;
            I_BRAM_DATA <= 128'h000000200000001E0000001C0000001A;
            #PERIOD;

            // <Mix sequnce
            I_ARESETN <= 1;
            I_START <= 0;
            I_DATA_FLAG <= 1;
            I_DATA_PATTERN <= 2;
            I_ZERO_COUNT <= 4;
            I_ONE_COUNT <= 4;
            I_BRAM_DATA <= 128'h00000024000000220000001B00000019;
            #PERIOD;

            // One sequnce
            I_ARESETN <= 1;
            I_START <= 0;
            I_DATA_FLAG <= 1;
            I_DATA_PATTERN <= 2;
            I_ZERO_COUNT <= 4;
            I_ONE_COUNT <= 4;
            I_BRAM_DATA <= 128'h00000007000000050000000300000001;
            #PERIOD;

            I_ARESETN <= 1;
            I_START <= 0;
            I_DATA_FLAG <= 1;
            I_DATA_PATTERN <= 2;
            I_ZERO_COUNT <= 4;
            I_ONE_COUNT <= 4;
            I_BRAM_DATA <= 128'h0000000F0000000D0000000B00000009;
            #PERIOD;

            I_ARESETN <= 1;
            I_START <= 0;
            I_DATA_FLAG <= 1;
            I_DATA_PATTERN <= 2;
            I_ZERO_COUNT <= 4;
            I_ONE_COUNT <= 4;
            I_BRAM_DATA <= 128'h00000017000000150000001300000011;
            #PERIOD;
            #PERIOD;
            #PERIOD;
            #PERIOD;

            // Start sequence
            I_ARESETN <= 1;
            I_START <= 1;
            I_DATA_FLAG <= 1;
            I_DATA_PATTERN <= 1;
            I_ZERO_COUNT <= 4;
            I_ONE_COUNT <= 4;
            I_BRAM_DATA <= 128'h00000000000000000000000000000000;
            #PERIOD;

            // Zero sequnce
            I_ARESETN <= 1;
            I_START <= 0;
            I_DATA_FLAG <= 1;
            I_DATA_PATTERN <= 1;
            I_ZERO_COUNT <= 4;
            I_ONE_COUNT <= 4;
            I_BRAM_DATA <= 128'h00000008000000060000000400000002;
            #PERIOD;
            
            I_ARESETN <= 1;
            I_START <= 0;
            I_DATA_FLAG <= 1;
            I_DATA_PATTERN <= 1;
            I_ZERO_COUNT <= 4;
            I_ONE_COUNT <= 4;
            I_BRAM_DATA <= 128'h000000100000000E0000000C0000000A;
            #PERIOD;

            I_ARESETN <= 1;
            I_START <= 0;
            I_DATA_FLAG <= 1;
            I_DATA_PATTERN <= 1;
            I_ZERO_COUNT <= 4;
            I_ONE_COUNT <= 4;
            I_BRAM_DATA <= 128'h00000018000000160000001400000012;
            #PERIOD;

            I_ARESETN <= 1;
            I_START <= 0;
            I_DATA_FLAG <= 1;
            I_DATA_PATTERN <= 1;
            I_ZERO_COUNT <= 4;
            I_ONE_COUNT <= 4;
            I_BRAM_DATA <= 128'h000000200000001E0000001C0000001A;
            #PERIOD;

            // <Mix sequnce
            I_ARESETN <= 1;
            I_START <= 0;
            I_DATA_FLAG <= 1;
            I_DATA_PATTERN <= 1;
            I_ZERO_COUNT <= 4;
            I_ONE_COUNT <= 4;
            I_BRAM_DATA <= 128'h000000220000001D0000001B00000019;
            #PERIOD;

            // One sequnce
            I_ARESETN <= 1;
            I_START <= 0;
            I_DATA_FLAG <= 1;
            I_DATA_PATTERN <= 1;
            I_ZERO_COUNT <= 4;
            I_ONE_COUNT <= 4;
            I_BRAM_DATA <= 128'h00000007000000050000000300000001;
            #PERIOD;

            I_ARESETN <= 1;
            I_START <= 0;
            I_DATA_FLAG <= 1;
            I_DATA_PATTERN <= 1;
            I_ZERO_COUNT <= 4;
            I_ONE_COUNT <= 4;
            I_BRAM_DATA <= 128'h0000000F0000000D0000000B00000009;
            #PERIOD;

            I_ARESETN <= 1;
            I_START <= 0;
            I_DATA_FLAG <= 1;
            I_DATA_PATTERN <= 1;
            I_ZERO_COUNT <= 4;
            I_ONE_COUNT <= 4;
            I_BRAM_DATA <= 128'h00000017000000150000001300000011;
            #PERIOD;
            #PERIOD;
            #PERIOD;
            #PERIOD;

            // Start sequence
            I_ARESETN <= 1;
            I_START <= 1;
            I_DATA_FLAG <= 1;
            I_DATA_PATTERN <= 4;
            I_ZERO_COUNT <= 4;
            I_ONE_COUNT <= 4;
            I_BRAM_DATA <= 128'h00000000000000000000000000000000;
            #PERIOD;

            // Zero sequnce
            I_ARESETN <= 1;
            I_START <= 0;
            I_DATA_FLAG <= 1;
            I_DATA_PATTERN <= 4;
            I_ZERO_COUNT <= 4;
            I_ONE_COUNT <= 4;
            I_BRAM_DATA <= 128'h00000008000000060000000400000002;
            #PERIOD;
            
            I_ARESETN <= 1;
            I_START <= 0;
            I_DATA_FLAG <= 1;
            I_DATA_PATTERN <= 4;
            I_ZERO_COUNT <= 4;
            I_ONE_COUNT <= 4;
            I_BRAM_DATA <= 128'h000000100000000E0000000C0000000A;
            #PERIOD;

            I_ARESETN <= 1;
            I_START <= 0;
            I_DATA_FLAG <= 1;
            I_DATA_PATTERN <= 4;
            I_ZERO_COUNT <= 4;
            I_ONE_COUNT <= 4;
            I_BRAM_DATA <= 128'h00000018000000160000001400000012;
            #PERIOD;

            I_ARESETN <= 1;
            I_START <= 0;
            I_DATA_FLAG <= 1;
            I_DATA_PATTERN <= 4;
            I_ZERO_COUNT <= 4;
            I_ONE_COUNT <= 4;
            I_BRAM_DATA <= 128'h000000200000001E0000001C0000001A;
            #PERIOD;

            // <Mix sequnce
            I_ARESETN <= 1;
            I_START <= 0;
            I_DATA_FLAG <= 1;
            I_DATA_PATTERN <= 4;
            I_ZERO_COUNT <= 4;
            I_ONE_COUNT <= 4;
            I_BRAM_DATA <= 128'h00000028000000260000002400000022;
            #PERIOD;

            // One sequnce
            I_ARESETN <= 1;
            I_START <= 0;
            I_DATA_FLAG <= 1;
            I_DATA_PATTERN <= 4;
            I_ZERO_COUNT <= 4;
            I_ONE_COUNT <= 4;
            I_BRAM_DATA <= 128'h00000007000000050000000300000001;
            #PERIOD;

            I_ARESETN <= 1;
            I_START <= 0;
            I_DATA_FLAG <= 1;
            I_DATA_PATTERN <= 4;
            I_ZERO_COUNT <= 4;
            I_ONE_COUNT <= 4;
            I_BRAM_DATA <= 128'h0000000F0000000D0000000B00000009;
            #PERIOD;

            I_ARESETN <= 1;
            I_START <= 0;
            I_DATA_FLAG <= 1;
            I_DATA_PATTERN <= 4;
            I_ZERO_COUNT <= 4;
            I_ONE_COUNT <= 4;
            I_BRAM_DATA <= 128'h00000017000000150000001300000011;
            #PERIOD;
            #PERIOD;
            #PERIOD;
            #PERIOD;

            $finish();
        end

        // Instantiate module
        data_shifter UUT
        (
            // Input ports
            .I_ACLK(I_ACLK),
            .I_ARESETN(I_ARESETN),
            .I_START(I_START),
            .I_DATA_FLAG(I_DATA_FLAG),
            .I_DATA_PATTERN(I_DATA_PATTERN),
            .I_ZERO_COUNT(I_ZERO_COUNT),
            .I_ONE_COUNT(I_ONE_COUNT),
            .I_BRAM_DATA(I_BRAM_DATA),

            // Output ports
            .O_VALID(O_VALID),
            .O_CACHE_DATA(O_CACHE_DATA)
        );

endmodule