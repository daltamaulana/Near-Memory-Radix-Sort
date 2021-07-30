// Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2020.1 (win64) Build 2902540 Wed May 27 19:54:49 MDT 2020
// Date        : Sat Jun 19 20:50:54 2021
// Host        : SEED-LAB-DLT running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
//               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ design_2_axi_data_mover_0_1_stub.v
// Design      : design_2_axi_data_mover_0_1
// Purpose     : Stub declaration of top-level module interface
// Device      : xczu7ev-ffvc1156-2-e
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "axi_data_mover_v1_0,Vivado 2020.1" *)
module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix(pl_to_ps_irq, s00_axi_from_ps_aclk, 
  s00_axi_from_ps_aresetn, s00_axi_from_ps_awaddr, s00_axi_from_ps_awprot, 
  s00_axi_from_ps_awvalid, s00_axi_from_ps_awready, s00_axi_from_ps_wdata, 
  s00_axi_from_ps_wstrb, s00_axi_from_ps_wvalid, s00_axi_from_ps_wready, 
  s00_axi_from_ps_bresp, s00_axi_from_ps_bvalid, s00_axi_from_ps_bready, 
  s00_axi_from_ps_araddr, s00_axi_from_ps_arprot, s00_axi_from_ps_arvalid, 
  s00_axi_from_ps_arready, s00_axi_from_ps_rdata, s00_axi_from_ps_rresp, 
  s00_axi_from_ps_rvalid, s00_axi_from_ps_rready, m00_axi_to_dma_aclk, 
  m00_axi_to_dma_aresetn, m00_axi_to_dma_awaddr, m00_axi_to_dma_awprot, 
  m00_axi_to_dma_awvalid, m00_axi_to_dma_awready, m00_axi_to_dma_wdata, 
  m00_axi_to_dma_wstrb, m00_axi_to_dma_wvalid, m00_axi_to_dma_wready, 
  m00_axi_to_dma_bresp, m00_axi_to_dma_bvalid, m00_axi_to_dma_bready, 
  m00_axi_to_dma_araddr, m00_axi_to_dma_arprot, m00_axi_to_dma_arvalid, 
  m00_axi_to_dma_arready, m00_axi_to_dma_rdata, m00_axi_to_dma_rresp, 
  m00_axi_to_dma_rvalid, m00_axi_to_dma_rready, s00_axis_aclk, s00_axis_aresetn, 
  s00_axis_tready, s00_axis_tdata, s00_axis_tstrb, s00_axis_tlast, s00_axis_tvalid, 
  m00_axis_aclk, m00_axis_aresetn, m00_axis_tvalid, m00_axis_tdata, m00_axis_tstrb, 
  m00_axis_tlast, m00_axis_tready)
/* synthesis syn_black_box black_box_pad_pin="pl_to_ps_irq,s00_axi_from_ps_aclk,s00_axi_from_ps_aresetn,s00_axi_from_ps_awaddr[8:0],s00_axi_from_ps_awprot[2:0],s00_axi_from_ps_awvalid,s00_axi_from_ps_awready,s00_axi_from_ps_wdata[31:0],s00_axi_from_ps_wstrb[3:0],s00_axi_from_ps_wvalid,s00_axi_from_ps_wready,s00_axi_from_ps_bresp[1:0],s00_axi_from_ps_bvalid,s00_axi_from_ps_bready,s00_axi_from_ps_araddr[8:0],s00_axi_from_ps_arprot[2:0],s00_axi_from_ps_arvalid,s00_axi_from_ps_arready,s00_axi_from_ps_rdata[31:0],s00_axi_from_ps_rresp[1:0],s00_axi_from_ps_rvalid,s00_axi_from_ps_rready,m00_axi_to_dma_aclk,m00_axi_to_dma_aresetn,m00_axi_to_dma_awaddr[31:0],m00_axi_to_dma_awprot[2:0],m00_axi_to_dma_awvalid,m00_axi_to_dma_awready,m00_axi_to_dma_wdata[31:0],m00_axi_to_dma_wstrb[3:0],m00_axi_to_dma_wvalid,m00_axi_to_dma_wready,m00_axi_to_dma_bresp[1:0],m00_axi_to_dma_bvalid,m00_axi_to_dma_bready,m00_axi_to_dma_araddr[31:0],m00_axi_to_dma_arprot[2:0],m00_axi_to_dma_arvalid,m00_axi_to_dma_arready,m00_axi_to_dma_rdata[31:0],m00_axi_to_dma_rresp[1:0],m00_axi_to_dma_rvalid,m00_axi_to_dma_rready,s00_axis_aclk,s00_axis_aresetn,s00_axis_tready,s00_axis_tdata[127:0],s00_axis_tstrb[15:0],s00_axis_tlast,s00_axis_tvalid,m00_axis_aclk,m00_axis_aresetn,m00_axis_tvalid,m00_axis_tdata[127:0],m00_axis_tstrb[15:0],m00_axis_tlast,m00_axis_tready" */;
  output pl_to_ps_irq;
  input s00_axi_from_ps_aclk;
  input s00_axi_from_ps_aresetn;
  input [8:0]s00_axi_from_ps_awaddr;
  input [2:0]s00_axi_from_ps_awprot;
  input s00_axi_from_ps_awvalid;
  output s00_axi_from_ps_awready;
  input [31:0]s00_axi_from_ps_wdata;
  input [3:0]s00_axi_from_ps_wstrb;
  input s00_axi_from_ps_wvalid;
  output s00_axi_from_ps_wready;
  output [1:0]s00_axi_from_ps_bresp;
  output s00_axi_from_ps_bvalid;
  input s00_axi_from_ps_bready;
  input [8:0]s00_axi_from_ps_araddr;
  input [2:0]s00_axi_from_ps_arprot;
  input s00_axi_from_ps_arvalid;
  output s00_axi_from_ps_arready;
  output [31:0]s00_axi_from_ps_rdata;
  output [1:0]s00_axi_from_ps_rresp;
  output s00_axi_from_ps_rvalid;
  input s00_axi_from_ps_rready;
  input m00_axi_to_dma_aclk;
  input m00_axi_to_dma_aresetn;
  output [31:0]m00_axi_to_dma_awaddr;
  output [2:0]m00_axi_to_dma_awprot;
  output m00_axi_to_dma_awvalid;
  input m00_axi_to_dma_awready;
  output [31:0]m00_axi_to_dma_wdata;
  output [3:0]m00_axi_to_dma_wstrb;
  output m00_axi_to_dma_wvalid;
  input m00_axi_to_dma_wready;
  input [1:0]m00_axi_to_dma_bresp;
  input m00_axi_to_dma_bvalid;
  output m00_axi_to_dma_bready;
  output [31:0]m00_axi_to_dma_araddr;
  output [2:0]m00_axi_to_dma_arprot;
  output m00_axi_to_dma_arvalid;
  input m00_axi_to_dma_arready;
  input [31:0]m00_axi_to_dma_rdata;
  input [1:0]m00_axi_to_dma_rresp;
  input m00_axi_to_dma_rvalid;
  output m00_axi_to_dma_rready;
  input s00_axis_aclk;
  input s00_axis_aresetn;
  output s00_axis_tready;
  input [127:0]s00_axis_tdata;
  input [15:0]s00_axis_tstrb;
  input s00_axis_tlast;
  input s00_axis_tvalid;
  input m00_axis_aclk;
  input m00_axis_aresetn;
  output m00_axis_tvalid;
  output [127:0]m00_axis_tdata;
  output [15:0]m00_axis_tstrb;
  output m00_axis_tlast;
  input m00_axis_tready;
endmodule
