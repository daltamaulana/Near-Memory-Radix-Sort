-- Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2020.1 (win64) Build 2902540 Wed May 27 19:54:49 MDT 2020
-- Date        : Sat Jun 19 20:50:56 2021
-- Host        : SEED-LAB-DLT running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub
--               c:/Projects/Accelerator/near-memory-radix-sort/Hardware/near_memory_radix_sort/near_memory_radix_sort.srcs/sources_1/bd/design_2/ip/design_2_axi_data_mover_0_1/design_2_axi_data_mover_0_1_stub.vhdl
-- Design      : design_2_axi_data_mover_0_1
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xczu7ev-ffvc1156-2-e
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity design_2_axi_data_mover_0_1 is
  Port ( 
    pl_to_ps_irq : out STD_LOGIC;
    s00_axi_from_ps_aclk : in STD_LOGIC;
    s00_axi_from_ps_aresetn : in STD_LOGIC;
    s00_axi_from_ps_awaddr : in STD_LOGIC_VECTOR ( 8 downto 0 );
    s00_axi_from_ps_awprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    s00_axi_from_ps_awvalid : in STD_LOGIC;
    s00_axi_from_ps_awready : out STD_LOGIC;
    s00_axi_from_ps_wdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    s00_axi_from_ps_wstrb : in STD_LOGIC_VECTOR ( 3 downto 0 );
    s00_axi_from_ps_wvalid : in STD_LOGIC;
    s00_axi_from_ps_wready : out STD_LOGIC;
    s00_axi_from_ps_bresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    s00_axi_from_ps_bvalid : out STD_LOGIC;
    s00_axi_from_ps_bready : in STD_LOGIC;
    s00_axi_from_ps_araddr : in STD_LOGIC_VECTOR ( 8 downto 0 );
    s00_axi_from_ps_arprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    s00_axi_from_ps_arvalid : in STD_LOGIC;
    s00_axi_from_ps_arready : out STD_LOGIC;
    s00_axi_from_ps_rdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    s00_axi_from_ps_rresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    s00_axi_from_ps_rvalid : out STD_LOGIC;
    s00_axi_from_ps_rready : in STD_LOGIC;
    m00_axi_to_dma_aclk : in STD_LOGIC;
    m00_axi_to_dma_aresetn : in STD_LOGIC;
    m00_axi_to_dma_awaddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
    m00_axi_to_dma_awprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    m00_axi_to_dma_awvalid : out STD_LOGIC;
    m00_axi_to_dma_awready : in STD_LOGIC;
    m00_axi_to_dma_wdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    m00_axi_to_dma_wstrb : out STD_LOGIC_VECTOR ( 3 downto 0 );
    m00_axi_to_dma_wvalid : out STD_LOGIC;
    m00_axi_to_dma_wready : in STD_LOGIC;
    m00_axi_to_dma_bresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    m00_axi_to_dma_bvalid : in STD_LOGIC;
    m00_axi_to_dma_bready : out STD_LOGIC;
    m00_axi_to_dma_araddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
    m00_axi_to_dma_arprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    m00_axi_to_dma_arvalid : out STD_LOGIC;
    m00_axi_to_dma_arready : in STD_LOGIC;
    m00_axi_to_dma_rdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    m00_axi_to_dma_rresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    m00_axi_to_dma_rvalid : in STD_LOGIC;
    m00_axi_to_dma_rready : out STD_LOGIC;
    s00_axis_aclk : in STD_LOGIC;
    s00_axis_aresetn : in STD_LOGIC;
    s00_axis_tready : out STD_LOGIC;
    s00_axis_tdata : in STD_LOGIC_VECTOR ( 127 downto 0 );
    s00_axis_tstrb : in STD_LOGIC_VECTOR ( 15 downto 0 );
    s00_axis_tlast : in STD_LOGIC;
    s00_axis_tvalid : in STD_LOGIC;
    m00_axis_aclk : in STD_LOGIC;
    m00_axis_aresetn : in STD_LOGIC;
    m00_axis_tvalid : out STD_LOGIC;
    m00_axis_tdata : out STD_LOGIC_VECTOR ( 127 downto 0 );
    m00_axis_tstrb : out STD_LOGIC_VECTOR ( 15 downto 0 );
    m00_axis_tlast : out STD_LOGIC;
    m00_axis_tready : in STD_LOGIC
  );

end design_2_axi_data_mover_0_1;

architecture stub of design_2_axi_data_mover_0_1 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "pl_to_ps_irq,s00_axi_from_ps_aclk,s00_axi_from_ps_aresetn,s00_axi_from_ps_awaddr[8:0],s00_axi_from_ps_awprot[2:0],s00_axi_from_ps_awvalid,s00_axi_from_ps_awready,s00_axi_from_ps_wdata[31:0],s00_axi_from_ps_wstrb[3:0],s00_axi_from_ps_wvalid,s00_axi_from_ps_wready,s00_axi_from_ps_bresp[1:0],s00_axi_from_ps_bvalid,s00_axi_from_ps_bready,s00_axi_from_ps_araddr[8:0],s00_axi_from_ps_arprot[2:0],s00_axi_from_ps_arvalid,s00_axi_from_ps_arready,s00_axi_from_ps_rdata[31:0],s00_axi_from_ps_rresp[1:0],s00_axi_from_ps_rvalid,s00_axi_from_ps_rready,m00_axi_to_dma_aclk,m00_axi_to_dma_aresetn,m00_axi_to_dma_awaddr[31:0],m00_axi_to_dma_awprot[2:0],m00_axi_to_dma_awvalid,m00_axi_to_dma_awready,m00_axi_to_dma_wdata[31:0],m00_axi_to_dma_wstrb[3:0],m00_axi_to_dma_wvalid,m00_axi_to_dma_wready,m00_axi_to_dma_bresp[1:0],m00_axi_to_dma_bvalid,m00_axi_to_dma_bready,m00_axi_to_dma_araddr[31:0],m00_axi_to_dma_arprot[2:0],m00_axi_to_dma_arvalid,m00_axi_to_dma_arready,m00_axi_to_dma_rdata[31:0],m00_axi_to_dma_rresp[1:0],m00_axi_to_dma_rvalid,m00_axi_to_dma_rready,s00_axis_aclk,s00_axis_aresetn,s00_axis_tready,s00_axis_tdata[127:0],s00_axis_tstrb[15:0],s00_axis_tlast,s00_axis_tvalid,m00_axis_aclk,m00_axis_aresetn,m00_axis_tvalid,m00_axis_tdata[127:0],m00_axis_tstrb[15:0],m00_axis_tlast,m00_axis_tready";
attribute X_CORE_INFO : string;
attribute X_CORE_INFO of stub : architecture is "axi_data_mover_v1_0,Vivado 2020.1";
begin
end;
