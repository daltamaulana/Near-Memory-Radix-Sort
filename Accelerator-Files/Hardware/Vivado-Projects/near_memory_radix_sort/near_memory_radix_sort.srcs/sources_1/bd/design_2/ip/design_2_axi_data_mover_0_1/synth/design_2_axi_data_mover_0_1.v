// (c) Copyright 1995-2021 Xilinx, Inc. All rights reserved.
// 
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
// 
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
// 
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
// 
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
// 
// DO NOT MODIFY THIS FILE.


// IP VLNV: xilinx.com:user:axi_data_mover:1.0
// IP Revision: 4

(* X_CORE_INFO = "axi_data_mover_v1_0,Vivado 2020.1" *)
(* CHECK_LICENSE_TYPE = "design_2_axi_data_mover_0_1,axi_data_mover_v1_0,{}" *)
(* CORE_GENERATION_INFO = "design_2_axi_data_mover_0_1,axi_data_mover_v1_0,{x_ipProduct=Vivado 2020.1,x_ipVendor=xilinx.com,x_ipLibrary=user,x_ipName=axi_data_mover,x_ipVersion=1.0,x_ipCoreRevision=4,x_ipLanguage=VERILOG,x_ipSimLanguage=VERILOG,C_M00_AXIS_TDATA_WIDTH=128,C_S00_AXIS_TDATA_WIDTH=128,C_S00_AXI_FROM_PS_DATA_WIDTH=32,C_S00_AXI_FROM_PS_ADDR_WIDTH=9,C_M00_AXI_TO_DMA_START_DATA_VALUE=0xAA000000,C_M00_AXI_TO_DMA_TARGET_SLAVE_BASE_ADDR=0xB0008000,C_M00_AXI_TO_DMA_ADDR_WIDTH=32,C_M00_AXI_TO_DMA_DATA_WIDTH=32,C_M00_A\
XI_TO_DMA_TRANSACTIONS_NUM=2}" *)
(* DowngradeIPIdentifiedWarnings = "yes" *)
module design_2_axi_data_mover_0_1 (
  pl_to_ps_irq,
  s00_axi_from_ps_aclk,
  s00_axi_from_ps_aresetn,
  s00_axi_from_ps_awaddr,
  s00_axi_from_ps_awprot,
  s00_axi_from_ps_awvalid,
  s00_axi_from_ps_awready,
  s00_axi_from_ps_wdata,
  s00_axi_from_ps_wstrb,
  s00_axi_from_ps_wvalid,
  s00_axi_from_ps_wready,
  s00_axi_from_ps_bresp,
  s00_axi_from_ps_bvalid,
  s00_axi_from_ps_bready,
  s00_axi_from_ps_araddr,
  s00_axi_from_ps_arprot,
  s00_axi_from_ps_arvalid,
  s00_axi_from_ps_arready,
  s00_axi_from_ps_rdata,
  s00_axi_from_ps_rresp,
  s00_axi_from_ps_rvalid,
  s00_axi_from_ps_rready,
  m00_axi_to_dma_aclk,
  m00_axi_to_dma_aresetn,
  m00_axi_to_dma_awaddr,
  m00_axi_to_dma_awprot,
  m00_axi_to_dma_awvalid,
  m00_axi_to_dma_awready,
  m00_axi_to_dma_wdata,
  m00_axi_to_dma_wstrb,
  m00_axi_to_dma_wvalid,
  m00_axi_to_dma_wready,
  m00_axi_to_dma_bresp,
  m00_axi_to_dma_bvalid,
  m00_axi_to_dma_bready,
  m00_axi_to_dma_araddr,
  m00_axi_to_dma_arprot,
  m00_axi_to_dma_arvalid,
  m00_axi_to_dma_arready,
  m00_axi_to_dma_rdata,
  m00_axi_to_dma_rresp,
  m00_axi_to_dma_rvalid,
  m00_axi_to_dma_rready,
  s00_axis_aclk,
  s00_axis_aresetn,
  s00_axis_tready,
  s00_axis_tdata,
  s00_axis_tstrb,
  s00_axis_tlast,
  s00_axis_tvalid,
  m00_axis_aclk,
  m00_axis_aresetn,
  m00_axis_tvalid,
  m00_axis_tdata,
  m00_axis_tstrb,
  m00_axis_tlast,
  m00_axis_tready
);

(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME pl_to_ps_irq, SENSITIVITY LEVEL_HIGH, PortWidth 1" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:interrupt:1.0 pl_to_ps_irq INTERRUPT" *)
output wire pl_to_ps_irq;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME s00_axi_from_ps_aclk, ASSOCIATED_RESET s00_axi_from_ps_aresetn, ASSOCIATED_BUSIF s00_axi_from_ps, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.000, CLK_DOMAIN design_2_zynq_ultra_ps_e_0_0_pl_clk0, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 s00_axi_from_ps_aclk CLK" *)
input wire s00_axi_from_ps_aclk;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME s00_axi_from_ps_aresetn, POLARITY ACTIVE_LOW, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 s00_axi_from_ps_aresetn RST" *)
input wire s00_axi_from_ps_aresetn;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s00_axi_from_ps AWADDR" *)
input wire [8 : 0] s00_axi_from_ps_awaddr;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s00_axi_from_ps AWPROT" *)
input wire [2 : 0] s00_axi_from_ps_awprot;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s00_axi_from_ps AWVALID" *)
input wire s00_axi_from_ps_awvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s00_axi_from_ps AWREADY" *)
output wire s00_axi_from_ps_awready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s00_axi_from_ps WDATA" *)
input wire [31 : 0] s00_axi_from_ps_wdata;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s00_axi_from_ps WSTRB" *)
input wire [3 : 0] s00_axi_from_ps_wstrb;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s00_axi_from_ps WVALID" *)
input wire s00_axi_from_ps_wvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s00_axi_from_ps WREADY" *)
output wire s00_axi_from_ps_wready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s00_axi_from_ps BRESP" *)
output wire [1 : 0] s00_axi_from_ps_bresp;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s00_axi_from_ps BVALID" *)
output wire s00_axi_from_ps_bvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s00_axi_from_ps BREADY" *)
input wire s00_axi_from_ps_bready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s00_axi_from_ps ARADDR" *)
input wire [8 : 0] s00_axi_from_ps_araddr;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s00_axi_from_ps ARPROT" *)
input wire [2 : 0] s00_axi_from_ps_arprot;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s00_axi_from_ps ARVALID" *)
input wire s00_axi_from_ps_arvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s00_axi_from_ps ARREADY" *)
output wire s00_axi_from_ps_arready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s00_axi_from_ps RDATA" *)
output wire [31 : 0] s00_axi_from_ps_rdata;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s00_axi_from_ps RRESP" *)
output wire [1 : 0] s00_axi_from_ps_rresp;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s00_axi_from_ps RVALID" *)
output wire s00_axi_from_ps_rvalid;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME s00_axi_from_ps, DATA_WIDTH 32, PROTOCOL AXI4LITE, FREQ_HZ 100000000, ID_WIDTH 0, ADDR_WIDTH 9, AWUSER_WIDTH 0, ARUSER_WIDTH 0, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, READ_WRITE_MODE READ_WRITE, HAS_BURST 0, HAS_LOCK 0, HAS_PROT 1, HAS_CACHE 0, HAS_QOS 0, HAS_REGION 0, HAS_WSTRB 1, HAS_BRESP 1, HAS_RRESP 1, SUPPORTS_NARROW_BURST 0, NUM_READ_OUTSTANDING 8, NUM_WRITE_OUTSTANDING 8, MAX_BURST_LENGTH 1, PHASE 0.000, CLK_DOMAIN design_2_zynq_ultra_ps_e_0_0_pl_clk0, NUM_READ_TH\
READS 4, NUM_WRITE_THREADS 4, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s00_axi_from_ps RREADY" *)
input wire s00_axi_from_ps_rready;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME m00_axi_to_dma_aclk, ASSOCIATED_RESET m00_axi_to_dma_aresetn, ASSOCIATED_BUSIF m00_axi_to_dma, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.000, CLK_DOMAIN design_2_zynq_ultra_ps_e_0_0_pl_clk0, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 m00_axi_to_dma_aclk CLK" *)
input wire m00_axi_to_dma_aclk;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME m00_axi_to_dma_aresetn, POLARITY ACTIVE_LOW, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 m00_axi_to_dma_aresetn RST" *)
input wire m00_axi_to_dma_aresetn;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m00_axi_to_dma AWADDR" *)
output wire [31 : 0] m00_axi_to_dma_awaddr;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m00_axi_to_dma AWPROT" *)
output wire [2 : 0] m00_axi_to_dma_awprot;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m00_axi_to_dma AWVALID" *)
output wire m00_axi_to_dma_awvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m00_axi_to_dma AWREADY" *)
input wire m00_axi_to_dma_awready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m00_axi_to_dma WDATA" *)
output wire [31 : 0] m00_axi_to_dma_wdata;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m00_axi_to_dma WSTRB" *)
output wire [3 : 0] m00_axi_to_dma_wstrb;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m00_axi_to_dma WVALID" *)
output wire m00_axi_to_dma_wvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m00_axi_to_dma WREADY" *)
input wire m00_axi_to_dma_wready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m00_axi_to_dma BRESP" *)
input wire [1 : 0] m00_axi_to_dma_bresp;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m00_axi_to_dma BVALID" *)
input wire m00_axi_to_dma_bvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m00_axi_to_dma BREADY" *)
output wire m00_axi_to_dma_bready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m00_axi_to_dma ARADDR" *)
output wire [31 : 0] m00_axi_to_dma_araddr;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m00_axi_to_dma ARPROT" *)
output wire [2 : 0] m00_axi_to_dma_arprot;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m00_axi_to_dma ARVALID" *)
output wire m00_axi_to_dma_arvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m00_axi_to_dma ARREADY" *)
input wire m00_axi_to_dma_arready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m00_axi_to_dma RDATA" *)
input wire [31 : 0] m00_axi_to_dma_rdata;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m00_axi_to_dma RRESP" *)
input wire [1 : 0] m00_axi_to_dma_rresp;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m00_axi_to_dma RVALID" *)
input wire m00_axi_to_dma_rvalid;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME m00_axi_to_dma, DATA_WIDTH 32, PROTOCOL AXI4LITE, FREQ_HZ 100000000, ID_WIDTH 0, ADDR_WIDTH 32, AWUSER_WIDTH 0, ARUSER_WIDTH 0, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, READ_WRITE_MODE READ_WRITE, HAS_BURST 0, HAS_LOCK 0, HAS_PROT 1, HAS_CACHE 0, HAS_QOS 0, HAS_REGION 0, HAS_WSTRB 1, HAS_BRESP 1, HAS_RRESP 1, SUPPORTS_NARROW_BURST 0, NUM_READ_OUTSTANDING 1, NUM_WRITE_OUTSTANDING 1, MAX_BURST_LENGTH 1, PHASE 0.000, CLK_DOMAIN design_2_zynq_ultra_ps_e_0_0_pl_clk0, NUM_READ_TH\
READS 1, NUM_WRITE_THREADS 1, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m00_axi_to_dma RREADY" *)
output wire m00_axi_to_dma_rready;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME S00_AXIS_CLK, ASSOCIATED_BUSIF S00_AXIS, ASSOCIATED_RESET s00_axis_aresetn, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.000, CLK_DOMAIN design_2_zynq_ultra_ps_e_0_0_pl_clk0, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 S00_AXIS_CLK CLK" *)
input wire s00_axis_aclk;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME S00_AXIS_RST, POLARITY ACTIVE_LOW, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 S00_AXIS_RST RST" *)
input wire s00_axis_aresetn;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S00_AXIS TREADY" *)
output wire s00_axis_tready;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S00_AXIS TDATA" *)
input wire [127 : 0] s00_axis_tdata;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S00_AXIS TSTRB" *)
input wire [15 : 0] s00_axis_tstrb;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S00_AXIS TLAST" *)
input wire s00_axis_tlast;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME S00_AXIS, WIZ_DATA_WIDTH 32, TDATA_NUM_BYTES 16, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 1, HAS_TSTRB 1, HAS_TKEEP 0, HAS_TLAST 1, FREQ_HZ 100000000, PHASE 0.000, CLK_DOMAIN design_2_zynq_ultra_ps_e_0_0_pl_clk0, LAYERED_METADATA undef, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S00_AXIS TVALID" *)
input wire s00_axis_tvalid;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME M00_AXIS_CLK, ASSOCIATED_BUSIF M00_AXIS, ASSOCIATED_RESET m00_axis_aresetn, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.000, CLK_DOMAIN design_2_zynq_ultra_ps_e_0_0_pl_clk0, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 M00_AXIS_CLK CLK" *)
input wire m00_axis_aclk;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME M00_AXIS_RST, POLARITY ACTIVE_LOW, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 M00_AXIS_RST RST" *)
input wire m00_axis_aresetn;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M00_AXIS TVALID" *)
output wire m00_axis_tvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M00_AXIS TDATA" *)
output wire [127 : 0] m00_axis_tdata;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M00_AXIS TSTRB" *)
output wire [15 : 0] m00_axis_tstrb;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M00_AXIS TLAST" *)
output wire m00_axis_tlast;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME M00_AXIS, WIZ_DATA_WIDTH 32, TDATA_NUM_BYTES 16, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 1, HAS_TSTRB 1, HAS_TKEEP 0, HAS_TLAST 1, FREQ_HZ 100000000, PHASE 0.000, CLK_DOMAIN design_2_zynq_ultra_ps_e_0_0_pl_clk0, LAYERED_METADATA undef, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M00_AXIS TREADY" *)
input wire m00_axis_tready;

  axi_data_mover_v1_0 #(
    .C_M00_AXIS_TDATA_WIDTH(128),  // Width of S_AXIS address bus. The slave accepts the read and write addresses of width C_M_AXIS_TDATA_WIDTH.
    .C_S00_AXIS_TDATA_WIDTH(128),  // AXI4Stream sink: Data Width
    .C_S00_AXI_FROM_PS_DATA_WIDTH(32),
    .C_S00_AXI_FROM_PS_ADDR_WIDTH(9),
    .C_M00_AXI_TO_DMA_START_DATA_VALUE('HAA000000),
    .C_M00_AXI_TO_DMA_TARGET_SLAVE_BASE_ADDR('HB0008000),
    .C_M00_AXI_TO_DMA_ADDR_WIDTH(32),
    .C_M00_AXI_TO_DMA_DATA_WIDTH(32),
    .C_M00_AXI_TO_DMA_TRANSACTIONS_NUM(2)
  ) inst (
    .pl_to_ps_irq(pl_to_ps_irq),
    .s00_axi_from_ps_aclk(s00_axi_from_ps_aclk),
    .s00_axi_from_ps_aresetn(s00_axi_from_ps_aresetn),
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
    .m00_axi_to_dma_aclk(m00_axi_to_dma_aclk),
    .m00_axi_to_dma_aresetn(m00_axi_to_dma_aresetn),
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
    .s00_axis_aclk(s00_axis_aclk),
    .s00_axis_aresetn(s00_axis_aresetn),
    .s00_axis_tready(s00_axis_tready),
    .s00_axis_tdata(s00_axis_tdata),
    .s00_axis_tstrb(s00_axis_tstrb),
    .s00_axis_tlast(s00_axis_tlast),
    .s00_axis_tvalid(s00_axis_tvalid),
    .m00_axis_aclk(m00_axis_aclk),
    .m00_axis_aresetn(m00_axis_aresetn),
    .m00_axis_tvalid(m00_axis_tvalid),
    .m00_axis_tdata(m00_axis_tdata),
    .m00_axis_tstrb(m00_axis_tstrb),
    .m00_axis_tlast(m00_axis_tlast),
    .m00_axis_tready(m00_axis_tready)
  );
endmodule
