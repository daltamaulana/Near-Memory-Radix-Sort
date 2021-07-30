# Near Memory Radix Sort Documentation
> This document contains information related to near memory radix sort project, especially module dependencies and module operations.

 

## Table of Content

[toc]

## Context
*Contributors*: Dalta Imam Maulana, Jihwan Cho
*Tools*: Vivado 2020.1
*Document Version*: July 29th, 2021
&nbsp;

## System Architecture
> The architecture overview of near memory radix sort accelerator is described in the section below

### Processing System and RAM
Processing system is used as an interface between user and accelerator as shown in the figure below. Meanwhile, RAM is used to store the unsorted data and also act as storage to store sorted data from the accelerator. In this design, processing system is a dedicated ARM processor that is capable of running Linux and PYNQ Framework. User can use PYNQ Framework to control the operation of accelerator by writing an application using Python language.

![](https://github.com/daltamaulana/Near-Memory-Radix-Sort/blob/465fb5cd68cff37f49b3da81e0d8ec35f38167d0/Documentation/Assets/Level%200.jpg?raw=true)

<p align = "center"><b>Figure 1 - System Level 0 Diagram</b></p>

### Radix Sort Accelerator IP Core

![](https://github.com/daltamaulana/Near-Memory-Radix-Sort/blob/465fb5cd68cff37f49b3da81e0d8ec35f38167d0/Documentation/Assets/Radix%20Sort%20IP%20core.jpg?raw=true)
<p align = "center"><b>Figure 2 - System Level 1 Diagram</b></p>

Radix Sort Accelerator IP Core consists of 5 modules as shown in the figure above. Those modules are:
* **AXI Lite Master**: acts as an interface between DMA controller block and AXI DMA block. This module is required since AXI DMA can only be controlled via AXI protocol.
* **AXI Lite Slave**: receives instructions from processing system block and send the instruction to status and control unit to be decoded.
* **AXI Stream Master**: responsible for sending sorted result data from BRAM bank to onboard DRAM via AXI DMA module.
* **AXI Stream Slave**: responsible for receiving unsorted data from onboard DRAM via AXI DMA module.
* **Radix Sort Accelerator Main Unit**: consists of **DMA controller** to control DMA operation, **data ordering and BRAM controller** to control dataflow from and to BRAM and sorting unit, **BRAM bank** to store sorted and unsorted data, **sorting unit** to sort data based on radix sorting algorithm, and **status and control unit** to control operation of each module inside the FPGA fabric.

### AXI Lite Master Interface
AXI Lite Master uses AXI4 Lite protocol. This module is based on Xilinx's template code generated via Vivado software. This unit is responsible for controlling AXI Direct Memory Access (DMA). This unit is controlled by DMA controller module using the signals below:
	**1. Source / Destination Address** [O_DMA_REG_ADDRESS]
	**2. Number of Byte to Transfer** [O_DMA_NO_OF_TRANSACTION]
	**3. Transfer Mode** [O_DMA_TRANSFER_MODE]

DMA operation mode can be set by configuring the transfer mode signal. DMA operation mode that is supported by this module are:
	1. **Starting AXI DMA**
	2. **Request transfer from DRAM** (via MM2S channel)
	3. **Request transfer to DRAM** (via S2MM channel) 

In the Vivado, the AXI DMA is configured to use **Direct Register Mode** (ref: **https://www.xilinx.com/support/documentation/ip_documentation/axi_dma/v7_1/pg021_axi_dma.pdf**). Therefore, every transaction is initiated via AXI4 Lite write request.

![](https://github.com/daltamaulana/Near-Memory-Radix-Sort/blob/465fb5cd68cff37f49b3da81e0d8ec35f38167d0/Documentation/Assets/AXI%20DMA%20Start.jpg?raw=true)
<p align = "center"><b>Figure 3 - Starting AXI DMA Waveform </b></p>

**Two AXI4 Lite requests are needed to start AXI DMA**. The first request is to write the AXI DMA register at address 0x0 with data 0x1. This request will start the MM2S channel of DMA. The second request is to write the AXI DMA register at address 0x30 with data 0x1. This
request will start the S2MM channel of DMA. The request order in this request is not important.

![](https://github.com/daltamaulana/Near-Memory-Radix-Sort/blob/465fb5cd68cff37f49b3da81e0d8ec35f38167d0/Documentation/Assets/AXI%20DMA%20Read.jpg?raw=true)
<p align = "center"><b>Figure 4 - Read from DRAM Request Waveform </b></p>

**Two AXI4 Lite requests are needed to request read data from DRAM via AXI DMA**. The first request is to write the AXI DMA register at address 0x18 with the source address. The
second request is to write the AXI DMA register at address 0x28 with a number of bytes to
transfer. This second request will also start the transaction. The request order is important
since sending request no of byte to transfer will start the transaction.

![](https://github.com/daltamaulana/Near-Memory-Radix-Sort/blob/465fb5cd68cff37f49b3da81e0d8ec35f38167d0/Documentation/Assets/AXI%20DMA%20Write.jpg?raw=true)
<p align = "center"><b>Figure 5 - Write to DRAM Request Waveform </b></p>

**Two AXI4 Lite requests are needed to request write data to DRAM via AXI DMA**. The first request is to write the AXI DMA register at address 0x48 with the destination address. The second request is to write the AXI DMA register at address 0x58 with a number of bytes to transfer. This request will also start the transaction. The request order is important since the second request will start the transaction.

**Note**: The transaction can be terminated early with AXI_TLAST from the master stream. The no of byte transferred will be updated to no of byte received by DMA. DMA will not return an error and accept this as a valid transfer. Not sending AXI_TLAST or sending data more than byte to transfer will result in DMA error (0x5002).

**It must be noted that after finishing a write transaction, DMA can be stalled for several clocks** (ranging from 32-128 clock, it is unknown what caused it, therefore consecutive writes should be spaced and not back-to-back). This event is not happening on read requests. The properties that indicate this event happening is when the AXI Lite master successfully sends a request for the first write to DRAM, and almost immediately requests another transaction after the first one finished (in the span of < 128 clocks usually). The DMA status register will show the right destination address and number of bytes to transfer (usually the register value is fine) but not initiating the request.

### AXI Lite Slave Interface
AXI Lite Slave uses AXI4 Lite protocol. This module is based on Xilinx's template code generated via Vivado software. This unit is responsible to receive/send a control signal from the Processing System (PS). In current design, there are 82 internal registers (7 essential registers, 63 debug registers, and 12 unused registers). This unit sends and receives signals below:
	**1. Start Signal** [I_GLOBAL_START]
	**2. Input Address** [I_ADDR_INPUT]
	**3. Instruction Address** [I_ADDR_INSTRUCTION]
	**4. Output Address** [I_ADDR_OUTPUT]
	**5. Debug Signals**

The register address of each signals is shown in the table below:

| Slv Reg | Address | Category | Read/Write | Details |
| ---- | ---- | ---- | ---- | ---- |
| 0 | 0x000 | Start Signal | Both | This register is used to start the accelerator|
| 1 | 0x004 | Input Address | Both | This register is used to provide unsorted input data address in DRAM |
| 2 | 0x008 | Instruction Address | Both | This register is used to provide instruction address in DRAM |
| 3 | 0x00C | Output Address | Both | This register is used to provide output data address in DRAM |

**Request order example**
Initial setup:

	1. Write instruction address to register 0x008
	2. Write 0x1 value to register 0x000 (start load instruction process)
	3. Write 0x0 value to register 0x000
	Start sorting process:
	1. Write input address to register 0x004
	2. Write output address to register 0x008
	3. Write 0x1 value to register 0x000 (start sorting process)
	4. Write 0x0 value to register 0x000	
	5. Read and wait until Register 0x24 16-bit LSB (program counter) equal to 2
	6. Repeat step 1 for another data

### AXI Stream Master Interface
AXI Stream Master uses AXI4 Stream protocol. This module is based on Xilinx's template code generated via Vivado software. This unit is responsible for sending a stream data from BRAM bank to DRAM via AXI DMA. This module has an internal buffer (queue) with size of 1024x128 bit.

![](https://github.com/daltamaulana/Near-Memory-Radix-Sort/blob/465fb5cd68cff37f49b3da81e0d8ec35f38167d0/Documentation/Assets/AXIS%20Master.jpg?raw=true)
<p align = "center"><b>Figure 6 - AXI Stream Master Interface</b></p>

After AXI Lite master request write transaction to DRAM to AXI DMA unit, AXI Stream master will assert TVALID along with the corresponding TDATA. If the slave (AXI DMA) reply with TREADY signal, the data will be transferred to DRAM and master can send the next data. But, master shouldn't de-assert TVALID signal or change TDATA before slave assert TREADY signal.

When both TVALID and TREADY signal are asserted, data will be sent to DRAM. Therefore, master can proceed to next data transfer. Master can also de-assert TVALID signal after a transaction to stall the transaction if necessary (in case of empty queue). But, it should be noted that if TVALID signal value is low for a long time, DMA error may happen (error 0x5002).

**Note:** master should always asserts TLAST signal to indicate the last data packet or DMA will return an error and halt the process.

![](https://github.com/daltamaulana/Near-Memory-Radix-Sort/blob/465fb5cd68cff37f49b3da81e0d8ec35f38167d0/Documentation/Assets/DMA%20Start.jpg?raw=true)
<p align = "center"><b>Figure 7 - Writing Data to DRAM via AXI DMA Waveform (Start)</b></p>

![](https://github.com/daltamaulana/Near-Memory-Radix-Sort/blob/465fb5cd68cff37f49b3da81e0d8ec35f38167d0/Documentation/Assets/DMA%20end.jpg?raw=true)
<p align = "center"><b>Figure 8 - Writing Data to DRAM via AXI DMA Waveform (End)</b></p>
Figure above shows the process of writing data to DRAM via AXI DMA. When transaction is complete, AXI stream master will asserts **DATA_SEND_DONE** signal to the status and control unit to indicate that the data transfer has been done successfully. It should be noted that it is forbidden to do another DMA request in the middle of transaction. If there is another DMA request in the middle of transaction, DMA will return an error and halt the process. In case of FIFO full, the unit that wants to send data to DRAM should be paused and wait until FIFO is not full (FIFO full signal de-asserted).

### AXI Stream Slave Interface

AXI Stream Slave uses AXI4 Stream protocol. This module is based on Xilinx's template code generated via Vivado software. This unit is responsible for receiving stream data from DRAM via AXI DMA. This unit has an internal buffer (queue) with the size of 1024x128 bit.

![](https://github.com/daltamaulana/Near-Memory-Radix-Sort/blob/465fb5cd68cff37f49b3da81e0d8ec35f38167d0/Documentation/Assets/AXIS%20Slave.jpg?raw=true)
<p align = "center"><b>Figure 8 - AXI Stream Slave Interface</b></p>

After requesting read data from DRAM to DMA, the DMA will assert TVALID along with the
corresponding TDATA. If the slave replies with TREADY signal, then the data transmission is
success and Stream Master can send next data. Data should only be sampled when both TVALID and TREADY signal is HIGH. Therefore, stream_fifo_write_enable logic is TVALID
&& TREADY. This also mean that the data are being queued into the Stream Queue.

Stream Dequeue should be asserted HIGH when data is needed and kept HIGH as long as
STREAM_VALID is LOW or more data is needed. If the Stream Queue is FULL, then the
TREADY signal will go LOW and this will pause the transaction on the AXI side until some unit
read data from the queue. If the Stream Queue is EMPTY, then STREAM_VALID will kept
LOW indicating that there is no data in the stream.

**Note:** TLAST is an optional signal for stream slaves and not used in current implementation. AXI Stream Slave is one-way communication, the state 0 is indicating IDLE and 1 is indicating RECEIVING data.

![](C:\Users\SEED LAB\OneDrive - kaist.ac.kr\KAIST\Research\Projects\Radix Sort Accelerator\Diagram\DMA Receive.jpg)
<p align = "center"><b>Figure 9 - Receiving Data form DRAM via AXI DMA Waveform</b></p>

### DMA Controller
DMA controller is a module that forwards request from Status and Control Unit (SCU) to AXI Lite Master unit. This module receives start pulse. source/destination address, number of byte to transfer, number of received transaction (only used when writing data to DRAM), DMA operation (0: Starting DMA, 1: Read DMA, 2: Write DMA).

![](https://github.com/daltamaulana/Near-Memory-Radix-Sort/blob/465fb5cd68cff37f49b3da81e0d8ec35f38167d0/Documentation/Assets/DMA%20controller.jpg?raw=true)
<p align = "center"><b>Figure 10 - DMA Controller Waveform Example</b></p>

### BRAM Bank
BRAM bank receives several memory address pointers and receive/send data to/from corresponding BRAM. BRAM bank consists of three main section which are Instruction BRAM, Input Data BRAM, and Output Data BRAM. In current design, Instruction BRAM has 1024 address space with each address can store 64-bit data. Meanwhile, Input and Output Data BRAM has 32768 address space with each address space can store 128-bit data.

### Data Ordering

![](https://github.com/daltamaulana/Near-Memory-Radix-Sort/blob/465fb5cd68cff37f49b3da81e0d8ec35f38167d0/Documentation/Assets/Data%20Ordering.jpg?raw=true)
<p align = "center"><b>Figure 11 - Data Ordering Block Diagram</b></p>

Data ordering module consists of:
**1. Load Instruction Module**
This module forward data from AXI Stream Slave to instruction BRAM. This module also converts 128-bit data stream into 64-bit stream of data. In current design, this module is used to load exactly 1024 instruction from DRAM. The number of instruction can be changed by changing the **MAXINSTCOUNT** in the **load_instruction_module.v** file.
**2. Load Input Module**
This module forward data from AXI Stream Slave to input data BRAM without changing the stream bitwidth.
**3. Stream Out Module**
This module is used to generate 128-bit stream data from output BRAM. This data will be sent to DRAM via AXI Stream Master module.

### Status and Control Unit (SCU)



### Radix Sort Accelerator Main Unit

> **Please update this part  ^^**



## RTL Breakdown

> This section contains detailed explanation about each RTL modules from parameters, ports, and module behavior

### Module radix_sort_accelerator_v1_0 
This module is implemented in radix_sort_accelerator_v1_0.v file
#### Module Dependencies
```mermaid
graph TD;
	id1([radix_sort_accelerator_v1_0.v]) -->
	id2([radix_sort_accelerator_v1_0_S00_AXI_FROM_PS.v]);
	id1([radix_sort_accelerator_v1_0.v]) -->
	id3([radix_sort_accelerator_v1_0_M00_AXI_TO_DMA.v]);
	id1([radix_sort_accelerator_v1_0.v]) -->
	id4([radix_sort_accelerator_v1_0_S00_AXIS.v]);
	id1([radix_sort_accelerator_v1_0.v]) -->
	id5([radix_sort_accelerator_v1_0_M00_AXIS.v]);
```

#### Module Parameters
| Name | Type | Default Value | Description |
| --- | --- | --- | --- |
| C_S00_AXI_FROM_PS_DATA_WIDTH | integer | 32 | Parameters of Axi Slave Bus Interface S00_AXI_FROM_PS |
| C_S00_AXI_FROM_PS_ADDR_WIDTH | integer | 9 |  |
| C_M00_AXI_TO_DMA_START_DATA_VALUE | unknown | 32'hAA000000 | Parameters of Axi Master Bus Interface M00_AXI_TO_DMA |
| C_M00_AXI_TO_DMA_TARGET_SLAVE_BASE_ADDR | unknown | 32'h00000000 |  |
| C_M00_AXI_TO_DMA_ADDR_WIDTH | integer | 32 |  |
| C_M00_AXI_TO_DMA_DATA_WIDTH | integer | 32 |  |
| C_M00_AXI_TO_DMA_TRANSACTIONS_NUM | integer | 2 |  |
| C_S00_AXIS_TDATA_WIDTH | integer | 128 | Parameters of Axi Slave Bus Interface S00_AXIS |
| C_M00_AXIS_TDATA_WIDTH | integer | 128 | Parameters of Axi Master Bus Interface M00_AXIS |

#### Module Ports

| Name | Direction | Type | Description |
| --- | --- | --- | --- |
| pl_to_ps_irq | out | logic | Interrupt Pin |
| s00_axi_from_ps_aclk | in | logic | Ports of Axi Slave Bus Interface S00_AXI_FROM_PS |
| s00_axi_from_ps_aresetn | in | logic |  |
| s00_axi_from_ps_awaddr | in | [C_S00_AXI_FROM_PS_ADDR_WIDTH-1:0] logic |  |
| s00_axi_from_ps_awprot | in | [2:0] logic |  |
| s00_axi_from_ps_awvalid | in | logic |  |
| s00_axi_from_ps_awready | out | logic |  |
| s00_axi_from_ps_wdata | in | [C_S00_AXI_FROM_PS_DATA_WIDTH-1:0] logic |  |
| s00_axi_from_ps_wstrb | in | [(C_S00_AXI_FROM_PS_DATA_WIDTH/8)-1:0] logic |  |
| s00_axi_from_ps_wvalid | in | logic |  |
| s00_axi_from_ps_wready | out | logic |  |
| s00_axi_from_ps_bresp | out | [1:0] logic |  |
| s00_axi_from_ps_bvalid | out | logic |  |
| s00_axi_from_ps_bready | in | logic |  |
| s00_axi_from_ps_araddr | in | [C_S00_AXI_FROM_PS_ADDR_WIDTH-1:0] logic |  |
| s00_axi_from_ps_arprot | in | [2:0] logic |  |
| s00_axi_from_ps_arvalid | in | logic |  |
| s00_axi_from_ps_arready | out | logic |  |
| s00_axi_from_ps_rdata | out | [C_S00_AXI_FROM_PS_DATA_WIDTH-1:0] logic |  |
| s00_axi_from_ps_rresp | out | [1:0] logic |  |
| s00_axi_from_ps_rvalid | out | logic |  |
| s00_axi_from_ps_rready | in | logic |  |
| m00_axi_to_dma_aclk | in | logic | Ports of Axi Master Bus Interface M00_AXI_TO_DMA |
| m00_axi_to_dma_aresetn | in | logic |  |
| m00_axi_to_dma_awaddr | out | [C_M00_AXI_TO_DMA_ADDR_WIDTH-1:0] logic |  |
| m00_axi_to_dma_awprot | out | [2:0] logic |  |
| m00_axi_to_dma_awvalid | out | logic |  |
| m00_axi_to_dma_awready | in | logic |  |
| m00_axi_to_dma_wdata | out | [C_M00_AXI_TO_DMA_DATA_WIDTH-1:0] logic |  |
| m00_axi_to_dma_wstrb | out | [C_M00_AXI_TO_DMA_DATA_WIDTH/8-1:0] logic |  |
| m00_axi_to_dma_wvalid | out | logic |  |
| m00_axi_to_dma_wready | in | logic |  |
| m00_axi_to_dma_bresp | in | [1:0] logic |  |
| m00_axi_to_dma_bvalid | in | logic |  |
| m00_axi_to_dma_bready | out | logic |  |
| m00_axi_to_dma_araddr | out | [C_M00_AXI_TO_DMA_ADDR_WIDTH-1:0] logic |  |
| m00_axi_to_dma_arprot | out | [2:0] logic |  |
| m00_axi_to_dma_arvalid | out | logic |  |
| m00_axi_to_dma_arready | in | logic |  |
| m00_axi_to_dma_rdata | in | [C_M00_AXI_TO_DMA_DATA_WIDTH-1:0] logic |  |
| m00_axi_to_dma_rresp | in | [1:0] logic |  |
| m00_axi_to_dma_rvalid | in | logic |  |
| m00_axi_to_dma_rready | out | logic |  |
| s00_axis_aclk | in | logic | Ports of Axi Slave Bus Interface S00_AXIS |
| s00_axis_aresetn | in | logic |  |
| s00_axis_tready | out | logic |  |
| s00_axis_tdata | in | [C_S00_AXIS_TDATA_WIDTH-1:0] logic |  |
| s00_axis_tstrb | in | [(C_S00_AXIS_TDATA_WIDTH/8)-1:0] logic |  |
| s00_axis_tlast | in | logic |  |
| s00_axis_tvalid | in | logic |  |
| m00_axis_aclk | in | logic | Ports of Axi Master Bus Interface M00_AXIS |
| m00_axis_aresetn | in | logic |  |
| m00_axis_tvalid | out | logic |  |
| m00_axis_tdata | out | [C_M00_AXIS_TDATA_WIDTH-1:0] logic |  |
| m00_axis_tstrb | out | [(C_M00_AXIS_TDATA_WIDTH/8)-1:0] logic |  |
| m00_axis_tlast | out | logic |  |
| m00_axis_tready | in | logic |  |



### Module radix_sort_accelerator_v1_0_S00_AXI_FROM_PS 

This module is implemented in radix_sort_accelerator_v1_0_S00_AXI_FROM_PS.v file

#### Module Dependencies



#### Module Parameters

| Name | Type | Default Value | Description |
| --- | --- | --- | --- |
| C_S_AXI_DATA_WIDTH | integer | 32 | Width of S_AXI data bus |
| C_S_AXI_ADDR_WIDTH | integer | 9 | Width of S_AXI address bus |
| ADDR_LSB | integer | (C_S_AXI_DATA_WIDTH/32) + 1 | Example-specific design signals local parameter for addressing 32 bit / 64 bit C_S_AXI_DATA_WIDTH ADDR_LSB is used for addressing 32/64 bit registers/memories ADDR_LSB = 2 for 32 bits (n downto 2) ADDR_LSB = 3 for 64 bits (n downto 3) |
| OPT_MEM_ADDR_BITS | integer | 6 |  |

#### Module Ports

| Name | Direction | Type | Description |
| --- | --- | --- | --- |
| O_GLOBAL_START | out | logic | Users to add ports here |
| O_ADDR_INPUT | out | [C_S_AXI_DATA_WIDTH-1:0] logic |  |
| O_ADDR_INSTRUCTION | out | [C_S_AXI_DATA_WIDTH-1:0] logic |  |
| O_ADDR_OUTPUT | out | [C_S_AXI_DATA_WIDTH-1:0] logic |  |
| O_FORCE_LOAD_INSTRUCTION | out | logic |  |
| I_PROGRAM_COUNTER | in | [C_S_AXI_DATA_WIDTH-1:0] logic |  |
| O_BRAM_DEBUG_ADDR | out | [C_S_AXI_DATA_WIDTH-1:0] logic |  |
| O_BRAM_MODE_DEBUG | out | [2:0] logic |  |
| I_BRAM_DEBUG_INSTRUCTION | in | [63:0] logic |  |
| I_BRAM_DEBUG_WEIGHT | in | [71:0] logic |  |
| I_BRAM_DEBUG_FMAP | in | [127:0] logic |  |
| I_BRAM_DEBUG_BIAS | in | [31:0] logic |  |
| I_BRAM_DEBUG_OUT_0 | in | [447:0] logic |  |
| I_BRAM_DEBUG_OUT_1 | in | [447:0] logic |  |
| I_BRAM_DEBUG_DLQ | in | [447:0] logic |  |
| I_BRAM_DEBUG_MP | in | [447:0] logic |  |
| I_REG_DEBUG_SCALE_POS | in | [31:0] logic |  |
| I_REG_DEBUG_SCALE_NEG | in | [31:0] logic |  |
| I_FSM_STREAM_MASTER | in | [7:0] logic |  |
| I_FSM_STREAM_SLAVE | in | [7:0] logic |  |
| I_FSM_DMA_CONTROLLER | in | [7:0] logic |  |
| I_IRQ_SIGNAL | in | logic |  |
| I_STATE_COUNTER | in | [31:0] logic |  |
| I_FIFO_STATUS_SLAVE | in | [1:0] logic |  |
| I_FIFO_STATUS_MASTER | in | [1:0] logic |  |
| I_PC_CHANGED | in | logic |  |
| I_SCU_STATE_MACHINE | in | [3:0] logic |  |
| I_INTERNAL_COUNTER | in | [3:0] logic |  |
| I_INSTRUCTION_OUT | in | [31:0] logic |  |
| I_SORT_STATE | in | [2:0] logic |  |
| I_FIRST_STATE | in | [2:0] logic |  |
| I_EVEN_STATE | in | [3:0] logic |  |
| I_ODD_STATE | in | [3:0] logic |  |
| I_DATA_STATE | in | [3:0] logic |  |
| I_SORT_START | in | logic |  |
| I_SORT_START_DELAY | in | logic |  |
| I_POINTER0 | in | [9:0] logic |  |
| I_POINTER1 | in | [9:0] logic |  |
| I_ADDR1 | in | [9:0] logic |  |
| I_ADDR2 | in | [9:0] logic |  |
| I_LI_COUNT | in | [31:0] logic |  |
| I_RS_COUNT | in | [31:0] logic |  |
| I_SO_COUNT | in | [31:0] logic |  |
| I_ALL_COUNT | in | [31:0] logic |  |
| S_AXI_ACLK | in | logic | Global Clock Signal |
| S_AXI_ARESETN | in | logic | Global Reset Signal. This Signal is Active LOW |
| S_AXI_AWADDR | in | [C_S_AXI_ADDR_WIDTH-1:0] logic | Write address (issued by master, acceped by Slave) |
| S_AXI_AWPROT | in | [2:0] logic |  |
| S_AXI_AWVALID | in | logic |  |
| S_AXI_AWREADY | out | logic |  |
| S_AXI_WDATA | in | [C_S_AXI_DATA_WIDTH-1:0] logic | Write data (issued by master, acceped by Slave) |
| S_AXI_WSTRB | in | [(C_S_AXI_DATA_WIDTH/8)-1:0] logic |  |
| S_AXI_WVALID | in | logic |  |
| S_AXI_WREADY | out | logic |  |
| S_AXI_BRESP | out | [1:0] logic |  |
| S_AXI_BVALID | out | logic |  |
| S_AXI_BREADY | in | logic |  |
| S_AXI_ARADDR | in | [C_S_AXI_ADDR_WIDTH-1:0] logic | Read address (issued by master, acceped by Slave) |
| S_AXI_ARPROT | in | [2:0] logic |  |
| S_AXI_ARVALID | in | logic |  |
| S_AXI_ARREADY | out | logic |  |
| S_AXI_RDATA | out | [C_S_AXI_DATA_WIDTH-1:0] logic | Read data (issued by slave) |
| S_AXI_RRESP | out | [1:0] logic |  |
| S_AXI_RVALID | out | logic |  |
| S_AXI_RREADY | in | logic |  |



### Module radix_sort_accelerator_v1_0_M00_AXI_TO_DMA 

This module is implemented in radix_sort_accelerator_v1_0_M00_AXI_TO_DMA.v file

#### Module Dependencies



#### Module Parameters

| Name | Type | Default Value | Description |
| --- | --- | --- | --- |
| C_M_TARGET_SLAVE_BASE_ADDR | unknown | 32'h40000000 | The master requires a target slave base address. |
| C_M_AXI_ADDR_WIDTH | integer | 32 | Width of M_AXI address bus. |
| C_M_AXI_DATA_WIDTH | integer | 32 | Width of M_AXI data bus. |
| C_M_TRANSACTIONS_NUM | integer | 2 | Transaction number is the number of write |
| TRANS_NUM_BITS | integer | clogb2(C_M_TRANSACTIONS_NUM-1) |  |
| IDLE | [1:0] logic | 2'b00 | This state issues the status of comparison |
| INIT_WRITE | [1:0] logic | 2'b01 | This state issues the status of comparison |
| TRANSACTION_DONE | [1:0] logic | 2'b10 | This state issues the status of comparison |
| INIT_READ | [1:0] logic | 2'b11 | This state issues the status of comparison |

#### Module Ports

| Name | Direction | Type | Description |
| --- | --- | --- | --- |
| I_REG_ADDRESS | in | [C_M_AXI_DATA_WIDTH-1:0] logic | Users to add ports here |
| I_REG_DATA | in | [C_M_AXI_DATA_WIDTH-1:0] logic |  |
| I_TRANSFER_MODE | in | [1:0] logic |  |
| I_INIT_AXI_TXN | in | logic | Initiate AXI transactions |
| O_AXI_TXN_DONE | out | logic |  |
| O_FSM_DMA_CONTROLLER | out | [7:0] logic |  |
| I_BRAM_DEBUG_ADDR | in | [31:0] logic |  |
| O_DATA_LOGGER | out | [63:0] logic |  |
| M_AXI_ACLK | in | logic | AXI clock signal |
| M_AXI_ARESETN | in | logic | AXI active low reset signal |
| M_AXI_AWADDR | out | [C_M_AXI_ADDR_WIDTH-1:0] logic | Master Interface Write Address Channel ports. Write address (issued by master) |
| M_AXI_AWPROT | out | [2:0] logic | Write channel Protection type. |
| M_AXI_AWVALID | out | logic | Write address valid. |
| M_AXI_AWREADY | in | logic | Write address ready. |
| M_AXI_WDATA | out | [C_M_AXI_DATA_WIDTH-1:0] logic | Master Interface Write Data Channel ports. Write data (issued by master) |
| M_AXI_WSTRB | out | [C_M_AXI_DATA_WIDTH/8-1:0] logic | Write strobes. |
| M_AXI_WVALID | out | logic | Write valid. This signal indicates that valid write data and strobes are available. |
| M_AXI_WREADY | in | logic | Write ready. This signal indicates that the slave can accept the write data. |
| M_AXI_BRESP | in | [1:0] logic | Master Interface Write Response Channel ports. |
| M_AXI_BVALID | in | logic | Write response valid. |
| M_AXI_BREADY | out | logic | Response ready. This signal indicates that the master can accept a write response. |
| M_AXI_ARADDR | out | [C_M_AXI_ADDR_WIDTH-1:0] logic | Master Interface Read Address Channel ports. Read address (issued by master) |
| M_AXI_ARPROT | out | [2:0] logic | Protection type. |
| M_AXI_ARVALID | out | logic | Read address valid. |
| M_AXI_ARREADY | in | logic | Read address ready. |
| M_AXI_RDATA | in | [C_M_AXI_DATA_WIDTH-1:0] logic | Master Interface Read Data Channel ports. Read data (issued by slave) |
| M_AXI_RRESP | in | [1:0] logic | Read response. This signal indicates the status of the read transfer. |
| M_AXI_RVALID | in | logic | Read valid. This signal indicates that the channel is signaling the required read data. |
| M_AXI_RREADY | out | logic | Read ready. This signal indicates that the master can accept the read data and response information. |



### Module radix_sort_accelerator_v1_0_S00_AXIS

This module is implemented in radix_sort_accelerator_v1_0_S00_AXIS.v file

#### Module Dependencies



#### Module Parameters

| Name | Type | Default Value | Description |
| --- | --- | --- | --- |
| C_S_AXIS_TDATA_WIDTH | integer | 128 | AXI4Stream sink: Data Width |
| IDLE | [1:0] logic | 2'h0 | Define the states of state machine |
| STREAM_FIFO | [1:0] logic | 2'h1 | Define the states of state machine |
| FIFO_FULL | [1:0] logic | 2'h2 | Define the states of state machine |

#### Module Ports

| Name | Direction | Type | Description |
| --- | --- | --- | --- |
| I_STREAM_DEQUEUE | in | logic | Users to add ports here |
| O_STREAM_VALID | out | logic |  |
| O_STREAM_FIFO | out | [127:0] logic |  |
| O_STREAM_EMPTY | out | logic |  |
| O_FSM_STREAM_SLAVE | out | [7:0] logic |  |
| I_STREAM_DEBUG_ADDR | in | [31:0] logic | Debug Port |
| O_STREAM_FIFO_INPUT_DEBUG | out | [127:0] logic |  |
| O_FIFO_STATUS | out | [1:0] logic |  |
| S_AXIS_ACLK | in | logic | AXI4Stream sink: Clock |
| S_AXIS_ARESETN | in | logic | AXI4Stream sink: Reset |
| S_AXIS_TREADY | out | logic | Ready to accept data in |
| S_AXIS_TDATA | in | [C_S_AXIS_TDATA_WIDTH-1:0] logic | Data in |
| S_AXIS_TSTRB | in | [(C_S_AXIS_TDATA_WIDTH/8)-1:0] logic | Byte qualifier |
| S_AXIS_TLAST | in | logic | Indicates boundary of last packet |
| S_AXIS_TVALID | in | logic | Data is in valid |



### Module stream_queue_in

This module is implemented in stream_queue_in.v file

#### Module Dependencies



#### Module Parameters

| Name | Type | Default Value | Description |
| --- | --- | --- | --- |
| DWIDTH | unknown | 128 |  |
| SIZE | unknown | 1024 |  |
| ADDR_BIT | unknown | 10 |  |

#### Module Ports
| Name | Direction | Type | Description |
| --- | --- | --- | --- |
| I_CLK | in | logic | Input ports |
| I_RSTN | in | logic |  |
| I_QUEUE | in | logic |  |
| I_DEQUEUE | in | logic |  |
| I_DATA | in | [DWIDTH-1:0] logic |  |
| O_EMPTY | out | logic | Output ports |
| O_ALMOST_FULL | out | logic |  |
| O_FULL | out | logic |  |
| O_DATA_VALID | out | logic |  |
| O_DATA | out | [DWIDTH-1:0] logic |  |
| I_DEBUG_ADDR | in | [ADDR_BIT-1:0] logic | Debug Ports |
| O_DEBUG_DATA | out | [DWIDTH-1:0] logic |  |



### Module radix_sort_accelerator_v1_0_M00_AXIS

This module is implemented in radix_sort_accelerator_v1_0_M00_AXIS.v file

#### Module Dependencies



#### Module Parameters

| Name | Type | Default Value | Description |
| --- | --- | --- | --- |
| FIFO_ADDR_BIT | integer | 10 | User parameter FIFO Address bit |
| C_M_AXIS_TDATA_WIDTH | integer | 128 | AXI Parameter Width of S_AXIS address bus. The slave accepts the read and write addresses of width C_M_AXIS_TDATA_WIDTH. |
| IDLE | [1:0] logic | 2'b00 | State for sending stream data through output port |
| WAIT_FIFO | [1:0] logic | 2'b01 | State for sending stream data through output port |
| SEND_STREAM | [1:0] logic | 2'b10 | State for sending stream data through output port |

#### Module Ports

| Name | Direction | Type | Description |
| --- | --- | --- | --- |
| I_FIFO_IN_QUEUE | in | logic | Signal for storing data to FIFO |
| I_FIFO_IN_DATA | in | [C_M_AXIS_TDATA_WIDTH-1:0] logic |  |
| O_FIFO_ALMOST_FULL | out | logic |  |
| O_FIFO_OUT_FULL | out | logic |  |
| I_NO_OF_TRANSACTION | in | [31:0] logic | FSM Signal |
| O_FSM_STREAM_MASTER | out | [7:0] logic |  |
| O_DATA_SEND_DONE | out | logic |  |
| O_FIFO_STATUS | out | [1:0] logic | Debug signal |
| M_AXIS_ACLK | in | logic | Global ports |
| M_AXIS_ARESETN | in | logic |  |
| M_AXIS_TVALID | out | logic | Master Stream Ports. TVALID indicates that the master is driving a valid transfer, A transfer takes place when both TVALID and TREADY are asserted. |
| M_AXIS_TDATA | out | [C_M_AXIS_TDATA_WIDTH-1:0] logic | TDATA is the primary payload that is used to provide the data that is passing across the interface from the master. |
| M_AXIS_TSTRB | out | [(C_M_AXIS_TDATA_WIDTH/8)-1:0] logic | TSTRB is the byte qualifier that indicates whether the content of the associated byte of TDATA is processed as a data byte or a position byte. |
| M_AXIS_TLAST | out | logic | TLAST indicates the boundary of a packet. |
| M_AXIS_TREADY | in | logic | TREADY indicates that the slave can accept a transfer in the current cycle. |



### Module stream_queue_out

This module is implemented in stream_queue_out.v file

#### Module Dependencies



#### Module Parameters

| Name | Type | Default Value | Description |
| --- | --- | --- | --- |
| DWIDTH | unknown | 128 |  |
| SIZE | unknown | 1024 |  |
| ADDR_BIT | unknown | 10 |  |

#### Module Ports
| Name | Direction | Type | Description |
| --- | --- | --- | --- |
| I_CLK | in | logic | Input ports |
| I_RSTN | in | logic |  |
| I_QUEUE | in | logic |  |
| I_DEQUEUE | in | logic |  |
| I_DATA | in | [DWIDTH-1:0] logic |  |
| O_EMPTY | out | logic | Output ports |
| O_ALMOST_FULL | out | logic |  |
| O_FULL | out | logic |  |
| O_DATA_VALID | out | logic |  |
| O_DATA | out | [DWIDTH-1:0] logic |  |
| O_DATA_INDEX | out | [ADDR_BIT-1:0] logic |  |
| I_DEBUG_ADDR | in | [ADDR_BIT-1:0] logic | Debug Ports |
| O_DEBUG_DATA | out | [DWIDTH-1:0] logic |  |



### Module radix_sort_accelerator_main_unit

This module is implemented in radix_sort_accelerator_main_unit.v file

#### Module Dependencies
```mermaid
graph TD;
	id1([radix_sort_accelerator_main_unit.v]) -->
	id2([status_and_control_unit.v]);
	id1([radix_sort_accelerator_main_unit.v]) -->
	id3([dma_controller.v]);
	id1([radix_sort_accelerator_main_unit.v]) -->
	id4([data_ordering.v]);
	id1([radix_sort_accelerator_main_unit.v]) -->
	id5([bram_bank.v]);
	id1([radix_sort_accelerator_main_unit.v]) -->
	id6([radix_sorting_unit.v]);
	id2([status_and_control_unit.v]) --> 
	id7([scu_bram_bank.v]);
	id4([data_ordering.v]) -->
	id8([load_instruction_module.v]);
	id4([data_ordering.v]) -->
	id9([load_input_module.v]);
	id4([data_ordering.v]) -->
	id10([stream_out_module.v]);
	id5([bram_bank.v]) -->
	id11([bram_tdp.v]);
```


#### Module Parameters
| Name | Type | Default Value | Description |
| --- | --- | --- | --- |
| DWIDTH | unknown | 128 |  |
| SELWIDTH | unknown | 10 |  |
| INSTWIDTH | unknown | 64 |  |
| DATABRAMDEPTH | unknown | 32768 |  |
| DATAADDRWIDTH | unknown | 17 |  |
| INSTADDRWIDTH | unknown | 10 |  |
| NOT_USED | unknown | 0 |  |

#### Module Ports
| Name | Direction | Type | Description |
| --- | --- | --- | --- |
| I_ACLK | in | logic | Clock and Reset |
| I_ARESETN | in | logic |  |
| I_GLOBAL_START | in | logic | Signal From PS |
| I_ADDR_INPUT | in | [31:0] logic |  |
| I_ADDR_INSTRUCTION | in | [31:0] logic |  |
| I_ADDR_OUTPUT | in | [31:0] logic |  |
| I_FORCE_LOAD_INSTRUCTION | in | logic |  |
| O_PROGRAM_COUNTER | out | [31:0] logic | Monitor Signal |
| O_STATE_LOGGER_DATA | out | [31:0] logic |  |
| I_BRAM_DEBUG_ADDR | in | [31:0] logic | Debug BRAM |
| I_BRAM_MODE_DEBUG | in | [2:0] logic |  |
| O_BRAM_DEBUG_INSTRUCTION | out | [63:0] logic |  |
| O_BRAM_DEBUG_WEIGHT | out | [71:0] logic |  |
| O_BRAM_DEBUG_FMAP | out | [127:0] logic |  |
| O_BRAM_DEBUG_BIAS | out | [31:0] logic |  |
| O_BRAM_DEBUG_OUT_0 | out | [447:0] logic |  |
| O_BRAM_DEBUG_OUT_1 | out | [447:0] logic |  |
| O_BRAM_DEBUG_DLQ | out | [447:0] logic |  |
| O_BRAM_DEBUG_MP | out | [447:0] logic |  |
| O_REG_DEBUG_SCALE_POS | out | [31:0] logic |  |
| O_REG_DEBUG_SCALE_NEG | out | [31:0] logic |  |
| I_STREAM_FIFO | in | [DWIDTH-1:0] logic |  |
| O_STREAM_DEQUEUE | out | logic |  |
| I_STREAM_VALID | in | logic |  |
| I_STREAM_EMPTY | in | logic |  |
| O_STREAM_FIFO | out | [DWIDTH-1:0] logic |  |
| O_STREAM_QUEUE | out | logic |  |
| I_STREAM_FULL | in | logic |  |
| I_STREAM_ALMOST_FULL | in | logic |  |
| I_DATA_SEND_DONE | in | logic |  |
| O_DMA_REG_ADDRESS | out | [31:0] logic |  |
| O_DMA_REG_DATA | out | [31:0] logic |  |
| O_DMA_INIT_AXI_TXN | out | logic |  |
| I_DMA_AXI_TXN_DONE | in | logic |  |
| O_DMA_NO_OF_TRANSACTION | out | [31:0] logic |  |
| O_DMA_TRANSFER_MODE | out | [1:0] logic |  |
| O_PL_TO_PS_IRQ | out | logic |  |
| O_PC_CHANGED | out | logic |  |
| O_SCU_STATE_MACHINE | out | [3:0] logic |  |
| O_INTERNAL_COUNTER | out | [3:0] logic |  |
| O_INSTRUCTION_OUT | out | [31:0] logic |  |
| O_SORT_STATE | out | [2:0] logic |  |
| O_FIRST_STATE | out | [2:0] logic |  |
| O_EVEN_STATE | out | [3:0] logic |  |
| O_ODD_STATE | out | [3:0] logic |  |
| O_DATA_STATE | out | [3:0] logic |  |
| O_LI_COUNT | out | [31:0] logic |  |
| O_RS_COUNT | out | [31:0] logic |  |
| O_SO_COUNT | out | [31:0] logic |  |
| O_ALL_COUNT | out | [31:0] logic |  |
| O_POINTER0 | out | [DATAADDRWIDTH-1:0] logic |  |
| O_POINTER1 | out | [DATAADDRWIDTH-1:0] logic |  |
| O_ADDR1 | out | [DATAADDRWIDTH-1:0] logic |  |
| O_ADDR2 | out | [DATAADDRWIDTH-1:0] logic |  |
| O_SORT_START | out | logic |  |
| O_SORT_START_DELAY | out | logic |  |



### Module status_and_control_unit

This module is implemented in status_and_control_unit.v file

#### Module Dependencies



#### Module Parameters

| Name | Type | Default Value | Description |
| --- | --- | --- | --- |
| DWIDTH | unknown | 128 |  |
| SELWIDTH | unknown | 10 |  |
| INSTWIDTH | unknown | 64 |  |
| DATABRAMDEPTH | unknown | 32768 |  |
| DATAADDRWIDTH | unknown | 17 |  |
| INSTADDRWIDTH | unknown | 10 |  |
| SCU_IDLE | [3:0] logic | 4'd0 | Declare localparam |
| SCU_WAIT_SETUP | [3:0] logic | 4'd1 | Declare localparam |
| SCU_LOAD_INSTRUCTION | [3:0] logic | 4'd2 | Declare localparam |
| SCU_RUNNING | [3:0] logic | 4'd3 | Declare localparam |

#### Module Ports

| Name | Direction | Type | Description |
| --- | --- | --- | --- |
| I_ACLK | in | logic |  |
| I_ARESETN | in | logic |  |
| I_GLOBAL_START | in | logic | Signal From PS |
| I_FORCE_LOAD_INSTRUCTION | in | logic | Also work as debug signal for BRAM Bank Mode |
| I_BRAM_DEBUG_ADDR | in | [31:0] logic |  |
| O_PL_TO_PS_IRQ | out | logic |  |
| O_STATE_LOGGER_DATA | out | [31:0] logic |  |
| I_INSTRUCTION_DATA | in | [63:0] logic | Monitor Signal |
| O_PROGRAM_COUNTER | out | [INSTADDRWIDTH-1:0] logic |  |
| O_LOAD_INSTRUCTION_START | out | logic | Load Instruction Channel |
| I_LOAD_INSTRUCTION_DONE | in | logic |  |
| O_LI_START | out | logic | Load Input Channel |
| O_LI_NO_OF_ROW | out | [31:0] logic |  |
| O_LI_START_POINTER | out | [DATAADDRWIDTH-1:0] logic |  |
| O_LI_SEL | out | [SELWIDTH-1:0] logic |  |
| I_LI_DONE | in | logic |  |
| O_SO_START | out | logic | Stream Out |
| O_SO_START_POINTER | out | [DATAADDRWIDTH-1:0] logic |  |
| O_SO_END_POINTER | out | [DATAADDRWIDTH-1:0] logic |  |
| I_SO_DONE | in | logic |  |
| O_DMA_START | out | logic | DMA Controller <===> SCU // |
| O_DMA_ADDR | out | [31:0] logic |  |
| O_DMA_BYTE_TO_TRANSFER | out | [31:0] logic |  |
| O_DMA_NO_OF_TRANSACTION | out | [31:0] logic |  |
| O_DMA_MODE | out | [2:0] logic |  |
| I_DMA_DONE | in | logic |  |
| I_DATA_SEND_DONE | in | logic |  |
| O_SORTING_START | out | logic | Radix Sorting <===> SCU // |
| I_SORTING_DONE | in | logic |  |
| O_LI_COUNT | out | [31:0] logic |  |
| O_RS_COUNT | out | [31:0] logic |  |
| O_SO_COUNT | out | [31:0] logic |  |
| O_ALL_COUNT | out | [31:0] logic |  |
| O_PC_CHANGED | out | logic |  |
| O_SCU_STATE_MACHINE | out | [3:0] logic |  |
| O_INTERNAL_COUNTER | out | [3:0] logic |  |
| O_INSTRUCTION_OUT | out | [31:0] logic |  |



### Module scu_bram_bank

This module is implemented in scu_bram_bank.v file

#### Module Dependencies



#### Module Parameters

| Name | Type | Default Value | Description |
| --- | --- | --- | --- |
| DWIDTH | unknown | 128 |  |
| SELWIDTH | unknown | 10 |  |
| INSTWIDTH | unknown | 64 |  |
| DATABRAMDEPTH | unknown | 32768 |  |
| DATAADDRWIDTH | unknown | 17 |  |
| INSTADDRWIDTH | unknown | 10 |  |
| STATE_IDLE | [1:0] logic | 2'b00 | State machine |
| STATE_SET | [1:0] logic | 2'b01 | State machine |
| STATE_INCREMENT | [1:0] logic | 2'b10 | State machine |
| STATE_DONE | [1:0] logic | 2'b11 | State machine |


#### Module Ports

| Name | Direction | Type | Description |
| --- | --- | --- | --- |
| I_ACLK | in | logic | Clock and Reset |
| I_ARESETN | in | logic |  |
| I_SEL_REG | in | [7:0] logic | Input from SCU |
| I_SEL_MULTIPLE | in | [7:0] logic |  |
| I_EN_MULTIPLE | in | [3:0] logic |  |
| I_SEL_COL | in | [3:0] logic |  |
| I_VALUE | in | [31:0] logic |  |
| I_MODE | in | [1:0] logic | 2'b00 = nothing, 2'b01 = set reg, 2'b10 = increment reg, 2'b11 = do loop |
| I_INSTRUCTION_OPCODE | in | [7:0] logic |  |
| I_START | in | logic |  |
| O_DONE | out | logic |  |
| O_DMA_ADDRESS | out | [31:0] logic | DMA Address |
| O_DMA_BYTE_TO_TRANSFER | out | [31:0] logic |  |
| O_DMA_NO_OF_TRANSACTION | out | [31:0] logic |  |
| O_LI_START_POINTER | out | [DATAADDRWIDTH-1:0] logic | Load Input |
| O_SO_START_POINTER | out | [DATAADDRWIDTH-1:0] logic | Stream Out |
| O_SO_END_POINTER | out | [DATAADDRWIDTH-1:0] logic |  |
| O_LOOP_I | out | [15:0] logic | Loop |
| O_LOOP_I_MAX | out | [15:0] logic |  |
| O_LOOP_J | out | [15:0] logic |  |
| O_LOOP_J_MAX | out | [15:0] logic |  |
| O_LOOP_K | out | [15:0] logic |  |
| O_LOOP_K_MAX | out | [15:0] logic |  |
| O_LOOP_L | out | [15:0] logic |  |
| O_LOOP_L_MAX | out | [15:0] logic |  |



### Module dma_controller

This module is implemented in dma_controller.v file

#### Module Dependencies



#### Module Parameters

| Name | Type | Default Value | Description |
| --- | --- | --- | --- |
| IDLE | [1:0] logic | 2'd0 | Declare local parameters |
| RUNNING | [1:0] logic | 2'd1 | Declare local parameters |
| DONE | [1:0] logic | 2'd2 | Declare local parameters |
| TF_MODE_IDLE | [2:0] logic | 3'd0 | Declare local parameters |
| TF_MODE_ON | [2:0] logic | 3'd1 | Declare local parameters |
| TF_MODE_READ_RAM | [2:0] logic | 3'd2 | Declare local parameters |
| TF_MODE_WRITE_RAM | [2:0] logic | 3'd3 | Declare local parameters |
| TF_MODE_LOAD_INSTRUCTION | [2:0] logic | 3'd4 | Declare local parameters |
| TF_MODE_DONE | [2:0] logic | 3'd5 | Declare local parameters |


#### Module Ports
| Name | Direction | Type | Description |
| --- | --- | --- | --- |
| I_ACLK | in | logic | Clock and Reset |
| I_ARESETN | in | logic |  |
| I_START | in | logic | Signal from PS |
| I_ADDR | in | [31:0] logic |  |
| I_BYTE_TO_TRANSFER | in | [31:0] logic |  |
| I_NO_OF_RECV_TRANSACTION | in | [31:0] logic |  |
| I_MODE | in | [2:0] logic |  |
| I_ADDR_INPUT | in | [31:0] logic |  |
| I_ADDR_INSTRUCTION | in | [31:0] logic |  |
| I_ADDR_OUTPUT | in | [31:0] logic |  |
| O_DONE | out | logic |  |
| O_DMA_REG_ADDRESS | out | [31:0] logic | Signal to DMA |
| O_DMA_REG_DATA | out | [31:0] logic |  |
| O_DMA_INIT_AXI_TXN | out | logic |  |
| I_DMA_AXI_TXN_DONE | in | logic |  |
| O_DMA_NO_OF_TRANSACTION | out | [31:0] logic |  |
| O_DMA_TRANSFER_MODE | out | [1:0] logic |  |
| I_BRAM_DEBUG_ADDR | in | [31:0] logic |  |



### Module data_ordering

This module is implemented in data_ordering.v file

#### Module Dependencies



#### Module Parameters

| Name | Type | Default Value | Description |
| --- | --- | --- | --- |
| DWIDTH | unknown | 128 |  |
| SELWIDTH | unknown | 10 |  |
| INSTWIDTH | unknown | 64 |  |
| DATABRAMDEPTH | unknown | 32768 |  |
| DATAADDRWIDTH | unknown | 17 |  |
| INSTADDRWIDTH | unknown | 10 |  |

#### Module Ports
| Name | Direction | Type | Description |
| --- | --- | --- | --- |
| I_ACLK | in | logic | Clock and Reset |
| I_ARESETN | in | logic |  |
| O_STREAM_DEQUEUE | out | logic | Stream In Channel |
| I_STREAM_VALID | in | logic |  |
| I_STREAM_DATA | in | [DWIDTH-1:0] logic |  |
| O_STREAM_QUEUE | out | logic | Stream Out Channel |
| I_STREAM_FULL | in | logic |  |
| I_LOAD_INSTRUCTION_START | in | logic | Load Instruction Module SCU part |
| O_LOAD_INSTRUCTION_DONE | out | logic |  |
| O_LOAD_INSTRUCTION_POINTER | out | [INSTADDRWIDTH-1:0] logic | BRAM Bank part |
| O_LOAD_INSTRUCTION_VALID | out | logic |  |
| O_LOAD_INSTRUCTION_DATA | out | [DWIDTH-1:0] logic |  |
| I_LI_START | in | logic | Load Input Module SCU part |
| I_LI_NO_OF_ROW | in | [31:0] logic |  |
| I_LI_START_POINTER | in | [DATAADDRWIDTH-1:0] logic |  |
| I_LI_SEL | in | [SELWIDTH-1:0] logic |  |
| O_LI_DONE | out | logic |  |
| O_LI_POINTER | out | [DATAADDRWIDTH-1:0] logic | BRAM Bank part |
| O_LI_VALID | out | logic |  |
| O_LI_DATA | out | [DWIDTH-1:0] logic |  |
| O_LI_SEL | out | [SELWIDTH-1:0] logic |  |
| I_SO_START | in | logic | Stream Out Module SCU part |
| I_SO_START_POINTER | in | [DATAADDRWIDTH-1:0] logic | 3 bit |
| I_SO_END_POINTER | in | [DATAADDRWIDTH-1:0] logic | 3 bit |
| O_SO_DONE | out | logic |  |
| O_SO_NOW | out | logic | BRAM part |
| O_SO_BRAM_SEL | out | [SELWIDTH-1:0] logic |  |
| O_SO_POINTER | out | [DATAADDRWIDTH-1:0] logic |  |



### Module load_instruction_module

This module is implemented in load_instruction_module.v file

#### Module Dependencies



#### Module Parameters

| Name | Type | Default Value | Description |
| --- | --- | --- | --- |
| DWIDTH | unknown | 128 |  |
| SELWIDTH | unknown | 10 |  |
| INSTWIDTH | unknown | 64 |  |
| DATABRAMDEPTH | unknown | 32768 |  |
| DATAADDRWIDTH | unknown | 17 |  |
| INSTADDRWIDTH | unknown | 10 |  |
| MAXINSTCOUNT | unknown | 1024 |  |
| IDLE | [1:0] logic | 2'd0 | Declare local parameter |
| RUNNING | [1:0] logic | 2'd1 | Declare local parameter |
| DONE | [1:0] logic | 2'd2 | Declare local parameter |

#### Module Ports
| Name | Direction | Type | Description |
| --- | --- | --- | --- |
| I_ACLK | in | logic | Clock and Reset |
| I_ARESETN | in | logic |  |
| O_STREAM_DEQUEUE | out | logic | Stream In |
| I_STREAM_VALID | in | logic |  |
| I_STREAM_DATA | in | [DWIDTH-1:0] logic | Unordered data |
| I_START | in | logic | SCU part |
| O_DONE | out | logic |  |
| O_LOAD_INSTRUCTION_POINTER | out | [INSTADDRWIDTH-1:0] logic | BRAM Bank |
| O_LOAD_INSTRUCTION_VALID | out | logic |  |
| O_LOAD_INSTRUCTION_DATA | out | [DWIDTH-1:0] logic |  |



### Module load_input_module

This module is implemented in load_input_module.v file

#### Module Dependencies



#### Module Parameters

| Name | Type | Default Value | Description |
| --- | --- | --- | --- |
| DWIDTH | unknown | 128 |  |
| SELWIDTH | unknown | 10 |  |
| INSTWIDTH | unknown | 64 |  |
| DATABRAMDEPTH | unknown | 32768 |  |
| DATAADDRWIDTH | unknown | 17 |  |
| INSTADDRWIDTH | unknown | 10 |  |
| IDLE | [1:0] logic | 2'd0 | State machines |
| RUNNING | [1:0] logic | 2'd1 | State machines |
| DONE | [1:0] logic | 2'd2 | State machines |

#### Module Ports
| Name | Direction | Type | Description |
| --- | --- | --- | --- |
| I_ACLK | in | logic | Clock and Reset |
| I_ARESETN | in | logic |  |
| O_STREAM_DEQUEUE | out | logic | Stream In |
| I_STREAM_VALID | in | logic |  |
| I_STREAM_DATA | in | [DWIDTH-1:0] logic |  |
| I_START | in | logic | SCU part |
| I_NO_OF_ROW | in | [31:0] logic |  |
| I_START_POINTER | in | [DATAADDRWIDTH-1:0] logic |  |
| I_SEL | in | [SELWIDTH-1:0] logic |  |
| O_DONE | out | logic |  |
| O_LI_POINTER | out | [DATAADDRWIDTH-1:0] logic | BRAM Bank |
| O_LI_VALID | out | logic |  |
| O_LI_DATA | out | [DWIDTH-1:0] logic |  |
| O_LI_SEL | out | [SELWIDTH-1:0] logic |  |



### Module stream_out_module

This module is implemented in stream_out_module.v file

#### Module Dependencies



#### Module Parameters

| Name | Type | Default Value | Description |
| --- | --- | --- | --- |
| DWIDTH | unknown | 128 |  |
| SELWIDTH | unknown | 10 |  |
| INSTWIDTH | unknown | 64 |  |
| DATABRAMDEPTH | unknown | 32768 |  |
| DATAADDRWIDTH | unknown | 17 |  |
| INSTADDRWIDTH | unknown | 10 |  |
| IDLE | [1:0] logic | 2'd0 | State machines |
| RUNNING | [1:0] logic | 2'd1 | State machines |
| DONE | [1:0] logic | 2'd2 | State machines |
| DO_SO_STATE_IDLE | [2:0] logic | 3'd0 | Declare local parameter |
| DO_SO_STATE_LOAD_BANK | [2:0] logic | 3'd1 | Declare local parameter |
| DO_SO_STATE_LOAD_DONE | [2:0] logic | 3'd2 | Declare local parameter |

#### Module Ports
| Name | Direction | Type | Description |
| --- | --- | --- | --- |
| I_ACLK | in | logic | Clock and Reset |
| I_ARESETN | in | logic |  |
| I_START | in | logic | SCU |
| I_START_POINTER | in | [DATAADDRWIDTH-1:0] logic |  |
| I_END_POINTER | in | [DATAADDRWIDTH-1:0] logic |  |
| O_DONE | out | logic |  |
| O_BRAM_SEL | out | [SELWIDTH-1:0] logic | BRAM Bank |
| O_SEND_DATA_POINTER | out | [DATAADDRWIDTH-1:0] logic |  |
| I_STREAM_FULL | in | logic | Send Data |
| O_STREAM_QUEUE | out | logic |  |
| O_STREAM_SEND_NOW | out | logic |  |



### Module bram_bank

This module is implemented in bram_bank.v file

#### Module Dependencies



#### Module Parameters

| Name | Type | Default Value | Description |
| --- | --- | --- | --- |
| DWIDTH | unknown | 128 |  |
| SELWIDTH | unknown | 10 |  |
| INSTWIDTH | unknown | 64 |  |
| DATABRAMDEPTH | unknown | 32768 |  |
| DATAADDRWIDTH | unknown | 17 |  |
| INSTADDRWIDTH | unknown | 10 |  |

#### Module Ports
| Name | Direction | Type | Description |
| --- | --- | --- | --- |
| I_ACLK | in | logic | Input ports |
| I_ARESETN | in | logic |  |
| I_BRAM_MODE_DEBUG | in | [2:0] logic | Debug channel |
| I_BRAM_DEBUG_ADDR | in | [DATAADDRWIDTH-1:0] logic |  |
| I_LOAD_INSTRUCTION_POINTER | in | [INSTADDRWIDTH-1:0] logic | Instruction BRAM Input |
| I_LOAD_INSTRUCTION_VALID | in | logic |  |
| I_LOAD_INSTRUCTION_DATA | in | [DWIDTH-1:0] logic |  |
| I_PROGRAM_COUNTER | in | [INSTADDRWIDTH-1:0] logic |  |
| O_PROGRAM_INSTRUCTION | out | [INSTWIDTH-1:0] logic | Output |
| O_BRAM_DEBUG_INSTRUCTION | out | [INSTWIDTH-1:0] logic |  |
| I_LI_POINTER | in | [DATAADDRWIDTH-1:0] logic | Input BRAM |
| I_LI_VALID | in | logic |  |
| I_LI_DATA | in | [DWIDTH-1:0] logic |  |
| I_LI_SEL | in | [SELWIDTH-1:0] logic |  |
| I_SORT_DATA_0_POINTER_A | in | [DATAADDRWIDTH-1:0] logic | Sort data pointer |
| I_SORT_DATA_0_POINTER_B | in | [DATAADDRWIDTH-1:0] logic |  |
| O_SORT_DATA_0_A | out | [DWIDTH-1:0] logic | input wire DATAADDRWIDTH-1:0 I_SORT_DATA_1_POINTER_A, input wire DATAADDRWIDTH-1:0 I_SORT_DATA_1_POINTER_B, Sort data output |
| O_SORT_DATA_0_B | out | [DWIDTH-1:0] logic |  |
| I_SORT_EVEN_POINTER | in | [DATAADDRWIDTH-2:0] logic | Sorting BRAM Even pointer |
| I_SORT_EVEN_VALID | in | logic |  |
| I_SORT_EVEN_DATA | in | [DWIDTH-1:0] logic |  |
| I_SORT_EVEN_SEL | in | [SELWIDTH-1:0] logic |  |
| O_SORT_EVEN_DATA | out | [DWIDTH-1:0] logic |  |
| I_SORT_ODD_POINTER | in | [DATAADDRWIDTH-2:0] logic | Odd pointer |
| I_SORT_ODD_VALID | in | logic |  |
| I_SORT_ODD_DATA | in | [DWIDTH-1:0] logic |  |
| I_SORT_ODD_SEL | in | [SELWIDTH-1:0] logic |  |
| O_SORT_ODD_DATA | out | [DWIDTH-1:0] logic |  |
| I_BRAM_OUT_0_POINTER_A | in | [DATAADDRWIDTH-1:0] logic | Output BRAM data pointer |
| I_BRAM_OUT_0_POINTER_B | in | [DATAADDRWIDTH-1:0] logic |  |
| O_BRAM_OUT_0_A | out | [DWIDTH-1:0] logic | input wire DATAADDRWIDTH-1:0 I_BRAM_OUT_1_POINTER_A, input wire DATAADDRWIDTH-1:0 I_BRAM_OUT_1_POINTER_B, Output BRAM data output |
| O_BRAM_OUT_0_B | out | [DWIDTH-1:0] logic |  |
| I_SO_NOW | in | logic | Stream Out port Input ports |
| I_SO_BRAM_SEL | in | [SELWIDTH-1:0] logic |  |
| I_SO_POINTER | in | [DATAADDRWIDTH-1:0] logic |  |
| O_SO_DATA | out | [DWIDTH-1:0] logic | Output port |



### Module bram_tdp

This module is implemented in bram_tdp.v file

#### Module Dependencies



#### Module Parameters

| Name | Type | Default Value | Description |
| --- | --- | --- | --- |
| DWIDTH | unknown | 32 |  |
| DEPTH | unknown | 2048 |  |
| ADDR_BIT | unknown | 32 |  |

#### Module Ports
| Name | Direction | Type | Description |
| --- | --- | --- | --- |
| clk_a | in | logic | Input ports Clock and control signal |
| clk_b | in | logic |  |
| en_a | in | logic |  |
| en_b | in | logic |  |
| we_a | in | logic |  |
| we_b | in | logic |  |
| addr_a | in | [ADDR_BIT-1:0] logic | BRAM Address |
| addr_b | in | [ADDR_BIT-1:0] logic |  |
| d_in_a | in | [DWIDTH-1:0] logic | Data input |
| d_in_b | in | [DWIDTH-1:0] logic |  |
| d_out_a | out | [DWIDTH-1:0] logic | Output ports |
| d_out_b | out | [DWIDTH-1:0] logic |  |

