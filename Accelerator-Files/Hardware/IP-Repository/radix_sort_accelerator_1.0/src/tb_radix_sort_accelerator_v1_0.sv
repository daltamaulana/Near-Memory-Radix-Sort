`timescale 1ns / 1ps

`define TICK #10
`define HALF_TICK #5


module tb_radix_sort_accelerator_v1_0 ();
    /*********************************************************
    *
    *                 Parameter Definition
    *
    **********************************************************/
    // ======================================================
    // AXI Slave Parameter Definition
    // ======================================================
    // Parameters of Axi Slave Bus Interface S00_AXI_FROM_PS
    parameter integer C_S00_AXI_FROM_PS_DATA_WIDTH	= 32;
    parameter integer C_S00_AXI_FROM_PS_ADDR_WIDTH	= 9;

    // ======================================================
    // AXI Master Parameter Definition
    // ======================================================
    // Parameters of Axi Master Bus Interface M00_AXI_TO_DMA
    parameter  C_M00_AXI_TO_DMA_START_DATA_VALUE	= 32'hAA000000;
    parameter  C_M00_AXI_TO_DMA_TARGET_SLAVE_BASE_ADDR	= 32'h00000000;
    parameter integer C_M00_AXI_TO_DMA_ADDR_WIDTH	= 32;
    parameter integer C_M00_AXI_TO_DMA_DATA_WIDTH	= 32;
    parameter integer C_M00_AXI_TO_DMA_TRANSACTIONS_NUM	= 2;

    // Parameters of Axi Slave Bus Interface S00_AXIS
    parameter integer C_S00_AXIS_TDATA_WIDTH	= 128;

    // Parameters of Axi Master Bus Interface M00_AXIS
    parameter integer C_M00_AXIS_TDATA_WIDTH	= 128;
    parameter integer C_M00_AXIS_START_COUNT	= 32;

    /*********************************************************
    *
    *             Testbench Setup Here
    *
    **********************************************************/

    /*********************************************************
    *
    *             Port Definition
    *
    **********************************************************/
    // =======================================================
    // General Signal
    // =======================================================
    reg s_clk;
    reg s_reset_n;

    // Helper Variable
    integer i, j, clock_count;
    integer no_of_transaction;
    int f_d, f_h;
    reg reset_input;
    reg streaming;

    // AXI Lite Master
    reg [31:0] DMA_Reg[0:127];
    // Memory Interface
    localparam INSTRUCTION_SIZE = 2048;
    reg [31:0] Instruction_RAM[0:INSTRUCTION_SIZE-1];
    initial
    begin
        $readmemh("C:/Projects/Accelerator/near-memory-radix-sort/Hardware/ip_repo/radix_sort_accelerator_1.0/src/instruction.mem", Instruction_RAM);
    end

    localparam DATA_SIZE = 16384;
    reg [31:0] Data_RAM[0:DATA_SIZE-1];
    initial
    begin
        $readmemh("C:/Projects/Accelerator/near-memory-radix-sort/Hardware/ip_repo/radix_sort_accelerator_1.0/src/unsorted_data.mem", Data_RAM);
    end

    localparam OUTPUT_SIZE = 4096;
    reg [31:0] Output_RAM[0:OUTPUT_SIZE-1];
    initial
    begin
        for (i = 0; i < OUTPUT_SIZE; i = i + 1)
        begin
            Output_RAM[i] = 32'd0;
        end
    end

    always @(posedge s_clk)
    begin
        if (clock_count == 2000_000)
        begin
            $display(">>> Clock count: %d | Logged Memory Files!", clock_count);
            $writememh("C:/Projects/Accelerator/radix-sort-accelerator/TestbenchFiles/sorted_data.mem", Output_RAM);
        end
        if (clock_count == 1200)
        begin
            sendDataAddress();
        end
    end

    wire pl_to_ps_irq;

    // ======================================================
    // Slave Input Stimulus (Reg) and Output Monitor (Wire)
    // ======================================================
    // Ports of Axi Slave Bus Interface S00_AXI_FROM_PS
    reg [C_S00_AXI_FROM_PS_ADDR_WIDTH-1 : 0] s00_axi_from_ps_awaddr;
    reg [2 : 0] s00_axi_from_ps_awprot;
    reg s00_axi_from_ps_awvalid;
    wire s00_axi_from_ps_awready;
    reg [C_S00_AXI_FROM_PS_DATA_WIDTH-1 : 0] s00_axi_from_ps_wdata;
    reg [(C_S00_AXI_FROM_PS_DATA_WIDTH/8)-1 : 0] s00_axi_from_ps_wstrb;
    reg s00_axi_from_ps_wvalid;
    wire s00_axi_from_ps_wready;
    wire [1 : 0] s00_axi_from_ps_bresp;
    wire s00_axi_from_ps_bvalid;
    reg s00_axi_from_ps_bready;
    reg [C_S00_AXI_FROM_PS_ADDR_WIDTH-1 : 0] s00_axi_from_ps_araddr;
    reg [2 : 0] s00_axi_from_ps_arprot;
    reg s00_axi_from_ps_arvalid;
    wire s00_axi_from_ps_arready;
    wire [C_S00_AXI_FROM_PS_DATA_WIDTH-1 : 0] s00_axi_from_ps_rdata;
    wire [1 : 0] s00_axi_from_ps_rresp;
    wire s00_axi_from_ps_rvalid;
    reg s00_axi_from_ps_rready;

    // ======================================================
    // Master Input Stimulus (Reg) and Output Monitor (Wire)
    // ======================================================
    // Ports of Axi Master Bus Interface M00_AXI_TO_DMA
    wire [C_M00_AXI_TO_DMA_ADDR_WIDTH-1 : 0] m00_axi_to_dma_awaddr;
    wire [2 : 0] m00_axi_to_dma_awprot;
    wire  m00_axi_to_dma_awvalid;
    reg  m00_axi_to_dma_awready;
    wire [C_M00_AXI_TO_DMA_DATA_WIDTH-1 : 0] m00_axi_to_dma_wdata;
    wire [C_M00_AXI_TO_DMA_DATA_WIDTH/8-1 : 0] m00_axi_to_dma_wstrb;
    wire  m00_axi_to_dma_wvalid;
    reg  m00_axi_to_dma_wready;
    reg [1 : 0] m00_axi_to_dma_bresp;
    reg  m00_axi_to_dma_bvalid;
    wire  m00_axi_to_dma_bready;
    wire [C_M00_AXI_TO_DMA_ADDR_WIDTH-1 : 0] m00_axi_to_dma_araddr;
    wire [2 : 0] m00_axi_to_dma_arprot;
    wire  m00_axi_to_dma_arvalid;
    reg  m00_axi_to_dma_arready;
    reg [C_M00_AXI_TO_DMA_DATA_WIDTH-1 : 0] m00_axi_to_dma_rdata;
    reg [1 : 0] m00_axi_to_dma_rresp;
    reg  m00_axi_to_dma_rvalid;
    wire  m00_axi_to_dma_rready;

    // ======================================================
    // Master Stream Input Stimulus (Reg) and Output Monitor (Wire)
    // ======================================================
    wire  s00_axis_tready;
    reg [C_S00_AXIS_TDATA_WIDTH-1 : 0] s00_axis_tdata;
    reg [(C_S00_AXIS_TDATA_WIDTH/8)-1 : 0] s00_axis_tstrb;
    reg  s00_axis_tlast;
    reg  s00_axis_tvalid;

    // ======================================================
    // Slave Stream Input Stimulus (Reg) and Output Monitor (Wire)
    // ======================================================
    // Ports of Axi Master Bus Interface M00_AXIS
    wire  m00_axis_tvalid;
    wire [C_M00_AXIS_TDATA_WIDTH-1 : 0] m00_axis_tdata;
    wire [(C_M00_AXIS_TDATA_WIDTH/8)-1 : 0] m00_axis_tstrb;
    wire  m00_axis_tlast;
    reg  m00_axis_tready;

    /*********************************************************
    *
    *             Testbench Sequence
    *
    **********************************************************/
    initial begin
        $display("Start of Testbench");

        resetState();

        waitNCycle(20);

        while(!pl_to_ps_irq)
        begin
            waitNCycle(5);
        end
        $display("Setup Instruction");
        setupInstruction();

        $display("End of Testbench");
    end

    always @(posedge s_clk)
    begin
        clock_count <= clock_count + 1;
    end

    /*********************************************************
    *             Testbench Task Sequence
    **********************************************************/
    task setupInstruction();
        // Write all Address
        doAXI4LiteWriteTransaction(32'h08, 32'h8000_0000);
        doAXI4LiteWriteTransaction(32'h00, 32'h0000_0001);
        doAXI4LiteWriteTransaction(32'h00, 32'h0000_0000);
    endtask

    task sendDataAddress();
        // Write all Address
        doAXI4LiteWriteTransaction(32'h04, 32'hA000_0000); // Unsorted Data Address
        doAXI4LiteWriteTransaction(32'h0C, 32'hB000_0000); // Output Address
        doAXI4LiteWriteTransaction(32'h00, 32'h0000_0001);
        doAXI4LiteWriteTransaction(32'h00, 32'h0000_0000);
    endtask

    task waitNCycle( input integer N);
        for (i = 0; i < N; i = i + 1)
        begin
            `TICK;
        end
    endtask

    /*********************************************************
    *             Simulation Task Definition
    **********************************************************/
    task resetState();
        initMemory();
        clock_count <= 0;
        no_of_transaction <= 0;
        s_clk <= 1'b0;
        s_reset_n <= 1'b0;
        reset_input <= 1'b0;
        j = 0;
        streaming = 0;

        s00_axi_from_ps_awaddr <= {C_S00_AXI_FROM_PS_ADDR_WIDTH{1'b0}};
        s00_axi_from_ps_awprot <= 3'b000;
        s00_axi_from_ps_awvalid <= 1'b0;
        s00_axi_from_ps_wdata <= {C_S00_AXI_FROM_PS_ADDR_WIDTH{1'b0}};
        s00_axi_from_ps_wstrb <= {(C_S00_AXI_FROM_PS_ADDR_WIDTH/8){1'b0}};
        s00_axi_from_ps_wvalid <= 1'b0;
        s00_axi_from_ps_bready <= 1'b0;
        s00_axi_from_ps_araddr <= {C_S00_AXI_FROM_PS_ADDR_WIDTH{1'b0}};
        s00_axi_from_ps_arprot <= 3'b000;
        s00_axi_from_ps_arvalid <= 1'b0;
        s00_axi_from_ps_rready <= 1'b0;

        m00_axi_to_dma_awready <= 1'b0;
        m00_axi_to_dma_wready <= 1'b0;
        m00_axi_to_dma_bresp <= 2'b0;
        m00_axi_to_dma_bvalid <= 1'b0;
        m00_axi_to_dma_arready <= 1'b0;
        m00_axi_to_dma_rdata <= {C_M00_AXI_TO_DMA_ADDR_WIDTH{1'b0}};
        m00_axi_to_dma_rresp <= 2'b00;
        m00_axi_to_dma_rvalid <= 1'b0;

        s00_axis_tdata <= {C_M00_AXIS_TDATA_WIDTH{1'b0}};
        s00_axis_tstrb <= {(C_M00_AXIS_TDATA_WIDTH/8){1'b0}};
        s00_axis_tlast <= 1'b0;
        s00_axis_tvalid <= 1'b0;

        m00_axis_tready <= 1'b0;
        waitNCycle(5);
        s_reset_n <= 1'b1;
        `TICK;
    endtask

    task initMemory();
        for (i = 0; i < 127; i = i+1)
        begin
            if (i % 4 == 0)
            begin
                DMA_Reg[i] <= 0;
            end
            else
            begin
                DMA_Reg[i] <= 32'hFFFF_EEEE;
            end
        end
    endtask

    task handleAXI4LiteWriteTransaction();
        // store address
        integer write_address;
        integer write_data;
        // integer burst_write_length;

        // store address and burst length
        write_address = m00_axi_to_dma_awaddr;
        write_data = m00_axi_to_dma_wdata;
        // burst_write_length = m00_axi_awlen;

        $display(" << [DMA controller] single write transaction to address 0x%h, data: %h", write_address, write_data);

        // tell master that provided address (over m00_axi_awaddr) was
        // recognized
        m00_axi_to_dma_awready = 1'b1;

        // wait until the first valid data word arrives
        while(m00_axi_to_dma_wvalid == 1'b0) begin
            `TICK
            s_reset_n = s_reset_n;
        end

        // tell master that transferred data (over m00_axi_wdata) can be stored
        m00_axi_to_dma_wready = 1'b1;

        `TICK
        DMA_Reg[write_address] = write_data;

        // tell master that transfer was successful
        `TICK
        m00_axi_to_dma_wready = 1'b0;
        m00_axi_to_dma_bvalid = 1'b1;
        `TICK
        `TICK
        m00_axi_to_dma_bvalid = 1'b0;

        `TICK s_reset_n = s_reset_n;
    endtask

    task handleAXI4LiteReadTransaction();
        $display(" << [DMA controller] single read transaction to address 0x%h", m00_axi_to_dma_araddr);
        m00_axi_to_dma_arready = 1;
        `TICK;
        m00_axi_to_dma_arready = 0;

        if (streaming == 1)
        begin
            m00_axi_to_dma_rdata = 32'h1000;
        end
        else
        begin
            m00_axi_to_dma_rdata = 32'h1002;
        end
        m00_axi_to_dma_rvalid = 1;
        while (m00_axi_to_dma_rready != 1)
        begin
            `TICK s_reset_n = s_reset_n;
        end
        `TICK;
        m00_axi_to_dma_rvalid = 0;
        `TICK s_reset_n = s_reset_n;
    endtask

    task doAXI4LiteWriteTransaction(input bit [C_S00_AXI_FROM_PS_ADDR_WIDTH-1:0] target_slave_reg, input bit [C_S00_AXI_FROM_PS_DATA_WIDTH-1:0] data);
        string register_name[int];
        register_name[0] = "Global Start";
        register_name[4] = "Input Address";
        register_name[8] = "Instruction Address";
        register_name[12] = "Force Load Instruction";
        register_name[16] = "BRAM Debug Addr";
        register_name[20] = "BRAM Debug Mode";
        register_name[24] = "Program Counter";

        $display(" >> [PS write] slave register %d [%s] at %h, data = %h", target_slave_reg/4, register_name[target_slave_reg], target_slave_reg, data);

        // tell slave the target register and the data
        s00_axi_from_ps_awaddr = target_slave_reg;
        s00_axi_from_ps_awvalid = 1'b1;
        s00_axi_from_ps_wdata = data;
        s00_axi_from_ps_wvalid = 1'b1;
        s00_axi_from_ps_wstrb = 4'b1111;

        // wait until slave recognizes the provided address and data
        while(s00_axi_from_ps_awready == 1'b0 && s00_axi_from_ps_wready == 1'b0) begin
            `TICK
            s_reset_n = s_reset_n;
        end

        `TICK
        s00_axi_from_ps_awaddr = {C_S00_AXI_FROM_PS_ADDR_WIDTH{1'b0}};
        s00_axi_from_ps_awvalid = 1'b0;

        // tell slave the the response can be accepted
        s00_axi_from_ps_bready = 1'b1;

        // wait until slave has processed provided data
        while(s00_axi_from_ps_wready == 1'b1) begin
            `TICK
            s_reset_n = s_reset_n;
        end

        s00_axi_from_ps_wdata = {C_S00_AXI_FROM_PS_DATA_WIDTH{1'b0}};
        s00_axi_from_ps_wvalid = 1'b0;
        s00_axi_from_ps_wstrb = 4'b0000;

        // wait until slave sends its response
        while(s00_axi_from_ps_bvalid == 1'b0) begin
            `TICK
            s_reset_n = s_reset_n;
        end

        `TICK
        s00_axi_from_ps_bready = 1'b0;
    endtask

    task doAXI4LiteReadTransaction(input bit [C_S00_AXI_FROM_PS_ADDR_WIDTH-1:0] target_slave_reg, output bit [C_S00_AXI_FROM_PS_DATA_WIDTH-1:0] data);

        // tell slave the target register
        s00_axi_from_ps_araddr = target_slave_reg;
        s00_axi_from_ps_arvalid = 1'b1;

        // wait until slave recognizes the provided address
        while(s00_axi_from_ps_arready == 1'b0) begin
            `TICK
            s_reset_n = s_reset_n;
        end

        `TICK
        s00_axi_from_ps_araddr = {C_S00_AXI_FROM_PS_ADDR_WIDTH{1'b0}};
        s00_axi_from_ps_arvalid = 1'b0;
        s00_axi_from_ps_rready = 1'b1;

        // wait until slave sends its response
        while(s00_axi_from_ps_rvalid == 1'b0) begin
            `TICK
            s_reset_n = s_reset_n;
        end

        // store data provided by slave
        data = s00_axi_from_ps_rdata;

        $display(" >> [FROM PS] read transaction from slave register %b, data = %h", target_slave_reg, data);

        `TICK
        s00_axi_from_ps_rready = 1'b0;
    endtask

    // =====================================================
    // Handle AXIS Logic
    // =====================================================

    reg [31:0] input_counter;
    reg [3:0] counter;

    initial
    begin
        counter <= 0;
        input_counter <= 0;
    end
    always @(posedge s_clk)
    begin
        if (reset_input || !s_reset_n)
        begin
            counter <= 0;
            input_counter <= 0;
        end
        else
        begin
            if (s00_axis_tvalid && s00_axis_tready)
            begin
                counter <= counter + 1;
                input_counter <= input_counter + 1;
            end
            else
            begin
                counter <= counter;
                input_counter <= input_counter;
            end
        end
    end

    //NOTE: Fix this
    reg [31:0] pointer;
    reg [31:0] leap_ptr;
    always @(*)
    begin
        case (DMA_Reg[24][31:28])
            4'h8: // Load Instruction
            begin
                leap_ptr <= 4;
            end
            4'hA: // Load Unsorted Data
            begin
                leap_ptr <= 4;
            end
            default:
            begin
                leap_ptr <= 1;
            end
        endcase
    end

    always @(posedge s_clk)
    begin
        if (!s_reset_n)
        begin
            pointer <= 0;
        end
        else
        begin
            if (s00_axis_tready && s00_axis_tvalid)
            begin
                if (s00_axis_tlast)
                begin
                    pointer <= 0;
                end
                else
                begin
                    pointer <= pointer + leap_ptr;
                end
            end
            else
            begin
                pointer <= pointer;
            end
        end
    end

    wire [31:0] in_offset = {4'd0, DMA_Reg[24][27:0]};
    always @(*)
    begin
        case (DMA_Reg[24][31:28])
            4'h8: // Load Instruction
            begin
                s00_axis_tdata <= {Instruction_RAM[3+pointer], Instruction_RAM[2+pointer], Instruction_RAM[1+pointer], Instruction_RAM[0+pointer]};
            end
            4'hA: // Load Unsorted Data Base Address
            begin
                s00_axis_tdata <= {Data_RAM[3+pointer+(in_offset/4)], Data_RAM[2+pointer+(in_offset/4)], Data_RAM[1+pointer+(in_offset/4)], Data_RAM[0+pointer+(in_offset/4)]};
            end
            default:
            begin
                s00_axis_tdata <= 128'hffeeddccbbaa99887766554433221100;
            end
        endcase
    end

    reg [31:0] out_pointer;
    reg [31:0] out_leap_ptr;
    always @(*)
    begin
        case (DMA_Reg[72][31:28])
            4'hB: // write Output Address
            begin
                out_leap_ptr <= 4;
            end
            default:
            begin
                out_leap_ptr <= 1;
            end
        endcase
    end
    always @(posedge s_clk)
    begin
        if (!s_reset_n)
        begin
            out_pointer <= 0;
        end
        else
        begin
            if (m00_axis_tready && m00_axis_tvalid)
            begin
                if (m00_axis_tlast)
                begin
                    out_pointer <= 0;
                end
                else
                begin
                    out_pointer <= out_pointer + out_leap_ptr;
                end
            end
            else
            begin
                out_pointer <= out_pointer;
            end
        end
    end

    wire [31:0] out_offset = {4'd0, DMA_Reg[72][27:0]};
    always @(posedge s_clk)
    begin
        if (m00_axis_tready && m00_axis_tvalid)
        begin
            case (DMA_Reg[72][31:28])
                4'hB: // Write Output Result
                begin
                    Output_RAM[0 + out_pointer+(out_offset/4)] <= m00_axis_tdata[127:96];
                    Output_RAM[1 + out_pointer+(out_offset/4)] <= m00_axis_tdata[95:64];
                    Output_RAM[2 + out_pointer+(out_offset/4)] <= m00_axis_tdata[63:32];
                    Output_RAM[3 + out_pointer+(out_offset/4)] <= m00_axis_tdata[31:0];
                end
                default:
                begin
                    $display("ERROR! Check stream out address!");
                end
            endcase
        end
    end

    // integer chaos;
    task doAXI4StreamTransaction(input integer N);
        $display(" >> [AXI Stream From DMA] sending %d bytes of data in %d iteration", N*16, N);
        reset_input = 0;
        `TICK;
        if (N == 1)
        begin
            s00_axis_tlast <= 1;
            s00_axis_tvalid <= 1;
            `TICK;
            `TICK;
        end
        else
        begin
            while (input_counter < (N-1))
            begin
                // chaos = $urandom_range(0,100);
                // if (chaos > 95)
                // begin
                //     s00_axis_tvalid <= 0;
                //     s00_axis_tlast <= 0;
                //     `TICK;
                //     `TICK;
                // end

                if (input_counter == (N-2))
                begin
                    s00_axis_tlast <= 1;
                end
                s00_axis_tvalid <= 1;
                `TICK;
            end
        end

        s00_axis_tvalid <= 0;
        s00_axis_tlast <= 0;
        reset_input = 1;
        `TICK;
        $display(" >> [AXI Stream From DMA] done");
    endtask

    task receiveAXI4StreamTransaction(input integer N);
        streaming = 1;
        DMA_Reg[88] = 0;
        f_d = $fopen("C:/Projects/Accelerator/radix-sort-accelerator/TestbenchFiles/output_decimal.csv", "w");
        f_h = $fopen("C:/Projects/Accelerator/radix-sort-accelerator/TestbenchFiles//output_hex.csv", "w");
        $fwrite(f_d, "Index, Data 127:96, Data 95:64, Data 63:32, Data 31:0\n");
        $fwrite(f_h, "Index, Data 127:96, Data 95:64, Data 63:32, Data 31:0\n");

        j = 0;
        $display(" >> [AXI Stream To DMA] receive %d bytes of data in %d iteration to %h", N*16, N, DMA_Reg[72]);
        m00_axis_tready <= 1; // !FIXME 1
        while (j < N)
        begin
            if (j == 4)
            begin
                m00_axis_tready <= 0;
                `TICK;
                `TICK;
                m00_axis_tready <= 1;
                if (m00_axis_tvalid)
                begin
                    $fwrite(f_d, "%d, %d, %d, %d, %d\n", j, m00_axis_tdata[127:96], m00_axis_tdata[95:64], m00_axis_tdata[63:32], m00_axis_tdata[31:0]);
                    j <= j + 1;
                end
                `TICK;
            end
            else
            begin
                if (m00_axis_tvalid && m00_axis_tready)
                begin
                    $fwrite(f_d, "%d, %d, %d, %d, %d\n", j, m00_axis_tdata[127:96], m00_axis_tdata[95:64], m00_axis_tdata[63:32], m00_axis_tdata[31:0]);
                    j <= j + 1;
                end
                if (j == N)
                    m00_axis_tready = 0;
                `TICK;
            end
        end
        m00_axis_tready = 0;
        `TICK;
        j = 0;
        $fclose(f_d);
        $fclose(f_h);
        no_of_transaction = no_of_transaction + 1;
        $display(" >> [AXI Stream To DMA] transaction done %d", no_of_transaction);
        streaming = 0;
    endtask

    always @(posedge s_clk)
    begin
        if(m00_axi_to_dma_awvalid == 1'b1)
        begin
            handleAXI4LiteWriteTransaction();
        end
    end
    always @(posedge s_clk)
    begin
        if (m00_axi_to_dma_arvalid == 1'b1)
        begin
            handleAXI4LiteReadTransaction();
        end
    end
    wire MM2S_on     = DMA_Reg[0] == 1;
    wire MM2S_btt_nz = DMA_Reg[40] != 0;
    always @(posedge s_clk)
    begin
        if (DMA_Reg[0] == 1)
        begin
            // $display(" >> [AXI Stream To DMA] transaction start");
            if (DMA_Reg[40] != 0)
            begin
                doAXI4StreamTransaction(DMA_Reg[40]/16);
                DMA_Reg[40] = 0;
            end
        end
    end

    wire S2MM_on     = DMA_Reg[48] == 1;
    wire S2MM_btt_nz = DMA_Reg[88] != 0;
    always @(posedge s_clk)
    begin
        if (DMA_Reg[48] == 1)
        begin
            if (DMA_Reg[88] != 0)
            begin
                receiveAXI4StreamTransaction(DMA_Reg[88]/16);
            end
        end
    end
    integer count_data_in;
    always @(posedge s_clk)
    begin
        if (s_reset_n)
        begin
            count_data_in <= 0;
        end
        else
        begin
            if (m00_axis_tvalid && m00_axis_tready)
            begin
               count_data_in <= count_data_in + 1;
               $display("[Stream In] Number: %d\t Data in %h", count_data_in, m00_axis_tdata);
            end
        end
    end

    always begin
        `HALF_TICK;
        s_clk = !s_clk;
    end

    /*********************************************************
    *
    *             Module Instantiation
    *
    **********************************************************/
    radix_sort_accelerator_v1_0 UUT
    (
        .pl_to_ps_irq(pl_to_ps_irq),
        // Ports of Axi Slave Bus Interface S00_AXI_FROM_PS
		.s00_axi_from_ps_aclk(s_clk),
		.s00_axi_from_ps_aresetn(s_reset_n),
		.s00_axi_from_ps_awaddr(s00_axi_from_ps_awaddr),
		.s00_axi_from_ps_awprot(s00_axi_from_ps_awprot),
		.s00_axi_from_ps_awvalid(s00_axi_from_ps_awvalid),
		.s00_axi_from_ps_awready(s00_axi_from_ps_awready),
		.s00_axi_from_ps_wdata(s00_axi_from_ps_wdata),
		.s00_axi_from_ps_wstrb(s00_axi_from_ps_wstrb),
		.s00_axi_from_ps_wvalid(s00_axi_from_ps_wvalid),
		.s00_axi_from_ps_wready(s00_axi_from_ps_wready),
		.s00_axi_from_ps_bresp(s00_axi_from_ps_bresp),
		.s00_axi_from_ps_bvalid(s00_axi_from_ps_bvalid),
		.s00_axi_from_ps_bready(s00_axi_from_ps_bready),
		.s00_axi_from_ps_araddr(s00_axi_from_ps_araddr),
		.s00_axi_from_ps_arprot(s00_axi_from_ps_arprot),
		.s00_axi_from_ps_arvalid(s00_axi_from_ps_arvalid),
		.s00_axi_from_ps_arready(s00_axi_from_ps_arready),
		.s00_axi_from_ps_rdata(s00_axi_from_ps_rdata),
		.s00_axi_from_ps_rresp(s00_axi_from_ps_rresp),
		.s00_axi_from_ps_rvalid(s00_axi_from_ps_rvalid),
		.s00_axi_from_ps_rready(s00_axi_from_ps_rready),

		// Ports of Axi Master Bus Interface M00_AXI_TO_DMA
		.m00_axi_to_dma_aclk(s_clk),
		.m00_axi_to_dma_aresetn(s_reset_n),
		.m00_axi_to_dma_awaddr(m00_axi_to_dma_awaddr),
		.m00_axi_to_dma_awprot(m00_axi_to_dma_awprot),
		.m00_axi_to_dma_awvalid(m00_axi_to_dma_awvalid),
		.m00_axi_to_dma_awready(m00_axi_to_dma_awready),
		.m00_axi_to_dma_wdata(m00_axi_to_dma_wdata),
		.m00_axi_to_dma_wstrb(m00_axi_to_dma_wstrb),
		.m00_axi_to_dma_wvalid(m00_axi_to_dma_wvalid),
		.m00_axi_to_dma_wready(m00_axi_to_dma_wready),
		.m00_axi_to_dma_bresp(m00_axi_to_dma_bresp),
		.m00_axi_to_dma_bvalid(m00_axi_to_dma_bvalid),
		.m00_axi_to_dma_bready(m00_axi_to_dma_bready),
		.m00_axi_to_dma_araddr(m00_axi_to_dma_araddr),
		.m00_axi_to_dma_arprot(m00_axi_to_dma_arprot),
		.m00_axi_to_dma_arvalid(m00_axi_to_dma_arvalid),
		.m00_axi_to_dma_arready(m00_axi_to_dma_arready),
		.m00_axi_to_dma_rdata(m00_axi_to_dma_rdata),
		.m00_axi_to_dma_rresp(m00_axi_to_dma_rresp),
		.m00_axi_to_dma_rvalid(m00_axi_to_dma_rvalid),
		.m00_axi_to_dma_rready(m00_axi_to_dma_rready),

		// Ports of Axi Slave Bus Interface S00_AXIS
		.s00_axis_aclk(s_clk),
		.s00_axis_aresetn(s_reset_n),
		.s00_axis_tready(s00_axis_tready),
		.s00_axis_tdata(s00_axis_tdata),
		.s00_axis_tstrb(s00_axis_tstrb),
		.s00_axis_tlast(s00_axis_tlast),
		.s00_axis_tvalid(s00_axis_tvalid),

		// Ports of Axi Master Bus Interface M00_AXIS
		.m00_axis_aclk(s_clk),
		.m00_axis_aresetn(s_reset_n),
		.m00_axis_tvalid(m00_axis_tvalid),
		.m00_axis_tdata(m00_axis_tdata),
		.m00_axis_tstrb(m00_axis_tstrb),
		.m00_axis_tlast(m00_axis_tlast),
		.m00_axis_tready(m00_axis_tready)
    );

endmodule
