vlib work
vlib riviera

vlib riviera/xilinx_vip
vlib riviera/xpm
vlib riviera/xil_defaultlib
vlib riviera/axi_infrastructure_v1_1_0
vlib riviera/axi_vip_v1_1_7
vlib riviera/zynq_ultra_ps_e_vip_v1_0_7
vlib riviera/lib_pkg_v1_0_2
vlib riviera/fifo_generator_v13_2_5
vlib riviera/lib_fifo_v1_0_14
vlib riviera/lib_srl_fifo_v1_0_2
vlib riviera/lib_cdc_v1_0_2
vlib riviera/axi_datamover_v5_1_23
vlib riviera/axi_sg_v4_1_13
vlib riviera/axi_dma_v7_1_22
vlib riviera/proc_sys_reset_v5_0_13
vlib riviera/xlconstant_v1_1_7
vlib riviera/smartconnect_v1_0
vlib riviera/axi_register_slice_v2_1_21
vlib riviera/generic_baseblocks_v2_1_0
vlib riviera/axi_data_fifo_v2_1_20
vlib riviera/axi_crossbar_v2_1_22
vlib riviera/axi_protocol_converter_v2_1_21
vlib riviera/axi_clock_converter_v2_1_20
vlib riviera/blk_mem_gen_v8_4_4
vlib riviera/axi_dwidth_converter_v2_1_21

vmap xilinx_vip riviera/xilinx_vip
vmap xpm riviera/xpm
vmap xil_defaultlib riviera/xil_defaultlib
vmap axi_infrastructure_v1_1_0 riviera/axi_infrastructure_v1_1_0
vmap axi_vip_v1_1_7 riviera/axi_vip_v1_1_7
vmap zynq_ultra_ps_e_vip_v1_0_7 riviera/zynq_ultra_ps_e_vip_v1_0_7
vmap lib_pkg_v1_0_2 riviera/lib_pkg_v1_0_2
vmap fifo_generator_v13_2_5 riviera/fifo_generator_v13_2_5
vmap lib_fifo_v1_0_14 riviera/lib_fifo_v1_0_14
vmap lib_srl_fifo_v1_0_2 riviera/lib_srl_fifo_v1_0_2
vmap lib_cdc_v1_0_2 riviera/lib_cdc_v1_0_2
vmap axi_datamover_v5_1_23 riviera/axi_datamover_v5_1_23
vmap axi_sg_v4_1_13 riviera/axi_sg_v4_1_13
vmap axi_dma_v7_1_22 riviera/axi_dma_v7_1_22
vmap proc_sys_reset_v5_0_13 riviera/proc_sys_reset_v5_0_13
vmap xlconstant_v1_1_7 riviera/xlconstant_v1_1_7
vmap smartconnect_v1_0 riviera/smartconnect_v1_0
vmap axi_register_slice_v2_1_21 riviera/axi_register_slice_v2_1_21
vmap generic_baseblocks_v2_1_0 riviera/generic_baseblocks_v2_1_0
vmap axi_data_fifo_v2_1_20 riviera/axi_data_fifo_v2_1_20
vmap axi_crossbar_v2_1_22 riviera/axi_crossbar_v2_1_22
vmap axi_protocol_converter_v2_1_21 riviera/axi_protocol_converter_v2_1_21
vmap axi_clock_converter_v2_1_20 riviera/axi_clock_converter_v2_1_20
vmap blk_mem_gen_v8_4_4 riviera/blk_mem_gen_v8_4_4
vmap axi_dwidth_converter_v2_1_21 riviera/axi_dwidth_converter_v2_1_21

vlog -work xilinx_vip  -sv2k12 "+incdir+C:/Xilinx/Vivado/2020.1/data/xilinx_vip/include" \
"C:/Xilinx/Vivado/2020.1/data/xilinx_vip/hdl/axi4stream_vip_axi4streampc.sv" \
"C:/Xilinx/Vivado/2020.1/data/xilinx_vip/hdl/axi_vip_axi4pc.sv" \
"C:/Xilinx/Vivado/2020.1/data/xilinx_vip/hdl/xil_common_vip_pkg.sv" \
"C:/Xilinx/Vivado/2020.1/data/xilinx_vip/hdl/axi4stream_vip_pkg.sv" \
"C:/Xilinx/Vivado/2020.1/data/xilinx_vip/hdl/axi_vip_pkg.sv" \
"C:/Xilinx/Vivado/2020.1/data/xilinx_vip/hdl/axi4stream_vip_if.sv" \
"C:/Xilinx/Vivado/2020.1/data/xilinx_vip/hdl/axi_vip_if.sv" \
"C:/Xilinx/Vivado/2020.1/data/xilinx_vip/hdl/clk_vip_if.sv" \
"C:/Xilinx/Vivado/2020.1/data/xilinx_vip/hdl/rst_vip_if.sv" \

vlog -work xpm  -sv2k12 "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/e257/hdl" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/2702/hdl/verilog" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/4676/hdl/verilog" "+incdir+C:/Xilinx/Vivado/2020.1/data/xilinx_vip/include" \
"C:/Xilinx/Vivado/2020.1/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"C:/Xilinx/Vivado/2020.1/data/ip/xpm/xpm_fifo/hdl/xpm_fifo.sv" \
"C:/Xilinx/Vivado/2020.1/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -93 \
"C:/Xilinx/Vivado/2020.1/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/e257/hdl" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/2702/hdl/verilog" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/4676/hdl/verilog" "+incdir+C:/Xilinx/Vivado/2020.1/data/xilinx_vip/include" \
"../../../bd/design_1/ipshared/52b3/src/bram_bank.v" \
"../../../bd/design_1/ipshared/52b3/src/bram_tdp.v" \
"../../../bd/design_1/ipshared/52b3/src/count.v" \
"../../../bd/design_1/ipshared/52b3/src/data_ordering.v" \
"../../../bd/design_1/ipshared/52b3/src/data_shifter.v" \
"../../../bd/design_1/ipshared/52b3/src/decoder.v" \
"../../../bd/design_1/ipshared/52b3/src/dma_controller.v" \
"../../../bd/design_1/ipshared/52b3/src/load_input_module.v" \
"../../../bd/design_1/ipshared/52b3/src/load_instruction_module.v" \
"../../../bd/design_1/ipshared/52b3/src/mask_unit.v" \
"../../../bd/design_1/ipshared/52b3/src/radix_sort_accelerator_main_unit.v" \
"../../../bd/design_1/ipshared/52b3/src/radix_sort_accelerator_v1_0_M00_AXIS.v" \
"../../../bd/design_1/ipshared/52b3/src/radix_sort_accelerator_v1_0_M00_AXI_TO_DMA.v" \
"../../../bd/design_1/ipshared/52b3/src/radix_sort_accelerator_v1_0_S00_AXIS.v" \
"../../../bd/design_1/ipshared/52b3/src/radix_sort_accelerator_v1_0_S00_AXI_FROM_PS.v" \
"../../../bd/design_1/ipshared/52b3/src/radix_sorting_unit.v" \
"../../../bd/design_1/ipshared/52b3/src/rearrange_mux.v" \
"../../../bd/design_1/ipshared/52b3/src/scu_bram_bank.v" \
"../../../bd/design_1/ipshared/52b3/src/sorting_unit.v" \
"../../../bd/design_1/ipshared/52b3/src/status_and_control_unit.v" \
"../../../bd/design_1/ipshared/52b3/src/stream_out_module.v" \
"../../../bd/design_1/ipshared/52b3/src/stream_queue_in.v" \
"../../../bd/design_1/ipshared/52b3/src/stream_queue_out.v" \
"../../../bd/design_1/ipshared/52b3/hdl/radix_sort_accelerator_v1_0.v" \
"../../../bd/design_1/ip/design_1_radix_sort_accelerat_0_1/sim/design_1_radix_sort_accelerat_0_1.v" \

vlog -work axi_infrastructure_v1_1_0  -v2k5 "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/e257/hdl" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/2702/hdl/verilog" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/4676/hdl/verilog" "+incdir+C:/Xilinx/Vivado/2020.1/data/xilinx_vip/include" \
"../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/ec67/hdl/axi_infrastructure_v1_1_vl_rfs.v" \

vlog -work axi_vip_v1_1_7  -sv2k12 "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/e257/hdl" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/2702/hdl/verilog" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/4676/hdl/verilog" "+incdir+C:/Xilinx/Vivado/2020.1/data/xilinx_vip/include" \
"../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/ce6c/hdl/axi_vip_v1_1_vl_rfs.sv" \

vlog -work zynq_ultra_ps_e_vip_v1_0_7  -sv2k12 "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/e257/hdl" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/2702/hdl/verilog" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/4676/hdl/verilog" "+incdir+C:/Xilinx/Vivado/2020.1/data/xilinx_vip/include" \
"../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/e257/hdl/zynq_ultra_ps_e_vip_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/e257/hdl" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/2702/hdl/verilog" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/4676/hdl/verilog" "+incdir+C:/Xilinx/Vivado/2020.1/data/xilinx_vip/include" \
"../../../bd/design_1/ip/design_1_zynq_ultra_ps_e_0_0/sim/design_1_zynq_ultra_ps_e_0_0_vip_wrapper.v" \

vcom -work lib_pkg_v1_0_2 -93 \
"../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/0513/hdl/lib_pkg_v1_0_rfs.vhd" \

vlog -work fifo_generator_v13_2_5  -v2k5 "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/e257/hdl" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/2702/hdl/verilog" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/4676/hdl/verilog" "+incdir+C:/Xilinx/Vivado/2020.1/data/xilinx_vip/include" \
"../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/276e/simulation/fifo_generator_vlog_beh.v" \

vcom -work fifo_generator_v13_2_5 -93 \
"../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/276e/hdl/fifo_generator_v13_2_rfs.vhd" \

vlog -work fifo_generator_v13_2_5  -v2k5 "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/e257/hdl" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/2702/hdl/verilog" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/4676/hdl/verilog" "+incdir+C:/Xilinx/Vivado/2020.1/data/xilinx_vip/include" \
"../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/276e/hdl/fifo_generator_v13_2_rfs.v" \

vcom -work lib_fifo_v1_0_14 -93 \
"../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/a5cb/hdl/lib_fifo_v1_0_rfs.vhd" \

vcom -work lib_srl_fifo_v1_0_2 -93 \
"../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/51ce/hdl/lib_srl_fifo_v1_0_rfs.vhd" \

vcom -work lib_cdc_v1_0_2 -93 \
"../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/ef1e/hdl/lib_cdc_v1_0_rfs.vhd" \

vcom -work axi_datamover_v5_1_23 -93 \
"../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/af86/hdl/axi_datamover_v5_1_vh_rfs.vhd" \

vcom -work axi_sg_v4_1_13 -93 \
"../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/4919/hdl/axi_sg_v4_1_rfs.vhd" \

vcom -work axi_dma_v7_1_22 -93 \
"../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/0fb1/hdl/axi_dma_v7_1_vh_rfs.vhd" \

vcom -work xil_defaultlib -93 \
"../../../bd/design_1/ip/design_1_axi_dma_0_0/sim/design_1_axi_dma_0_0.vhd" \

vcom -work proc_sys_reset_v5_0_13 -93 \
"../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/8842/hdl/proc_sys_reset_v5_0_vh_rfs.vhd" \

vcom -work xil_defaultlib -93 \
"../../../bd/design_1/ip/design_1_rst_ps8_0_100M_0/sim/design_1_rst_ps8_0_100M_0.vhd" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/e257/hdl" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/2702/hdl/verilog" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/4676/hdl/verilog" "+incdir+C:/Xilinx/Vivado/2020.1/data/xilinx_vip/include" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/sim/bd_afc3.v" \

vlog -work xlconstant_v1_1_7  -v2k5 "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/e257/hdl" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/2702/hdl/verilog" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/4676/hdl/verilog" "+incdir+C:/Xilinx/Vivado/2020.1/data/xilinx_vip/include" \
"../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/fcfc/hdl/xlconstant_v1_1_vl_rfs.v" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/e257/hdl" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/2702/hdl/verilog" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/4676/hdl/verilog" "+incdir+C:/Xilinx/Vivado/2020.1/data/xilinx_vip/include" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_0/sim/bd_afc3_one_0.v" \

vcom -work xil_defaultlib -93 \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_1/sim/bd_afc3_psr_aclk_0.vhd" \

vlog -work smartconnect_v1_0  -sv2k12 "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/e257/hdl" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/2702/hdl/verilog" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/4676/hdl/verilog" "+incdir+C:/Xilinx/Vivado/2020.1/data/xilinx_vip/include" \
"../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/2702/hdl/sc_util_v1_0_vl_rfs.sv" \
"../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/c012/hdl/sc_switchboard_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib  -sv2k12 "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/e257/hdl" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/2702/hdl/verilog" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/4676/hdl/verilog" "+incdir+C:/Xilinx/Vivado/2020.1/data/xilinx_vip/include" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_2/sim/bd_afc3_arsw_0.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_3/sim/bd_afc3_rsw_0.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_4/sim/bd_afc3_awsw_0.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_5/sim/bd_afc3_wsw_0.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_6/sim/bd_afc3_bsw_0.sv" \

vlog -work smartconnect_v1_0  -sv2k12 "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/e257/hdl" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/2702/hdl/verilog" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/4676/hdl/verilog" "+incdir+C:/Xilinx/Vivado/2020.1/data/xilinx_vip/include" \
"../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/053f/hdl/sc_mmu_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib  -sv2k12 "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/e257/hdl" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/2702/hdl/verilog" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/4676/hdl/verilog" "+incdir+C:/Xilinx/Vivado/2020.1/data/xilinx_vip/include" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_7/sim/bd_afc3_s00mmu_0.sv" \

vlog -work smartconnect_v1_0  -sv2k12 "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/e257/hdl" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/2702/hdl/verilog" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/4676/hdl/verilog" "+incdir+C:/Xilinx/Vivado/2020.1/data/xilinx_vip/include" \
"../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/ca72/hdl/sc_transaction_regulator_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib  -sv2k12 "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/e257/hdl" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/2702/hdl/verilog" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/4676/hdl/verilog" "+incdir+C:/Xilinx/Vivado/2020.1/data/xilinx_vip/include" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_8/sim/bd_afc3_s00tr_0.sv" \

vlog -work smartconnect_v1_0  -sv2k12 "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/e257/hdl" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/2702/hdl/verilog" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/4676/hdl/verilog" "+incdir+C:/Xilinx/Vivado/2020.1/data/xilinx_vip/include" \
"../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/9d43/hdl/sc_si_converter_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib  -sv2k12 "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/e257/hdl" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/2702/hdl/verilog" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/4676/hdl/verilog" "+incdir+C:/Xilinx/Vivado/2020.1/data/xilinx_vip/include" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_9/sim/bd_afc3_s00sic_0.sv" \

vlog -work smartconnect_v1_0  -sv2k12 "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/e257/hdl" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/2702/hdl/verilog" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/4676/hdl/verilog" "+incdir+C:/Xilinx/Vivado/2020.1/data/xilinx_vip/include" \
"../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/b89e/hdl/sc_axi2sc_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib  -sv2k12 "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/e257/hdl" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/2702/hdl/verilog" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/4676/hdl/verilog" "+incdir+C:/Xilinx/Vivado/2020.1/data/xilinx_vip/include" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_10/sim/bd_afc3_s00a2s_0.sv" \

vlog -work smartconnect_v1_0  -sv2k12 "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/e257/hdl" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/2702/hdl/verilog" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/4676/hdl/verilog" "+incdir+C:/Xilinx/Vivado/2020.1/data/xilinx_vip/include" \
"../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/4676/hdl/sc_node_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib  -sv2k12 "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/e257/hdl" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/2702/hdl/verilog" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/4676/hdl/verilog" "+incdir+C:/Xilinx/Vivado/2020.1/data/xilinx_vip/include" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_11/sim/bd_afc3_sarn_0.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_12/sim/bd_afc3_srn_0.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_13/sim/bd_afc3_s01mmu_0.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_14/sim/bd_afc3_s01tr_0.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_15/sim/bd_afc3_s01sic_0.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_16/sim/bd_afc3_s01a2s_0.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_17/sim/bd_afc3_sawn_0.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_18/sim/bd_afc3_swn_0.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_19/sim/bd_afc3_sbn_0.sv" \

vlog -work smartconnect_v1_0  -sv2k12 "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/e257/hdl" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/2702/hdl/verilog" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/4676/hdl/verilog" "+incdir+C:/Xilinx/Vivado/2020.1/data/xilinx_vip/include" \
"../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/7005/hdl/sc_sc2axi_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib  -sv2k12 "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/e257/hdl" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/2702/hdl/verilog" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/4676/hdl/verilog" "+incdir+C:/Xilinx/Vivado/2020.1/data/xilinx_vip/include" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_20/sim/bd_afc3_m00s2a_0.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_21/sim/bd_afc3_m00arn_0.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_22/sim/bd_afc3_m00rn_0.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_23/sim/bd_afc3_m00awn_0.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_24/sim/bd_afc3_m00wn_0.sv" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_25/sim/bd_afc3_m00bn_0.sv" \

vlog -work smartconnect_v1_0  -sv2k12 "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/e257/hdl" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/2702/hdl/verilog" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/4676/hdl/verilog" "+incdir+C:/Xilinx/Vivado/2020.1/data/xilinx_vip/include" \
"../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/7af8/hdl/sc_exit_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib  -sv2k12 "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/e257/hdl" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/2702/hdl/verilog" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/4676/hdl/verilog" "+incdir+C:/Xilinx/Vivado/2020.1/data/xilinx_vip/include" \
"../../../bd/design_1/ip/design_1_axi_smc_0/bd_0/ip/ip_26/sim/bd_afc3_m00e_0.sv" \

vlog -work axi_register_slice_v2_1_21  -v2k5 "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/e257/hdl" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/2702/hdl/verilog" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/4676/hdl/verilog" "+incdir+C:/Xilinx/Vivado/2020.1/data/xilinx_vip/include" \
"../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/2ef9/hdl/axi_register_slice_v2_1_vl_rfs.v" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/e257/hdl" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/2702/hdl/verilog" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/4676/hdl/verilog" "+incdir+C:/Xilinx/Vivado/2020.1/data/xilinx_vip/include" \
"../../../bd/design_1/ip/design_1_axi_smc_0/sim/design_1_axi_smc_0.v" \

vlog -work generic_baseblocks_v2_1_0  -v2k5 "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/e257/hdl" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/2702/hdl/verilog" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/4676/hdl/verilog" "+incdir+C:/Xilinx/Vivado/2020.1/data/xilinx_vip/include" \
"../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/b752/hdl/generic_baseblocks_v2_1_vl_rfs.v" \

vlog -work axi_data_fifo_v2_1_20  -v2k5 "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/e257/hdl" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/2702/hdl/verilog" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/4676/hdl/verilog" "+incdir+C:/Xilinx/Vivado/2020.1/data/xilinx_vip/include" \
"../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/47c9/hdl/axi_data_fifo_v2_1_vl_rfs.v" \

vlog -work axi_crossbar_v2_1_22  -v2k5 "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/e257/hdl" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/2702/hdl/verilog" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/4676/hdl/verilog" "+incdir+C:/Xilinx/Vivado/2020.1/data/xilinx_vip/include" \
"../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/b68e/hdl/axi_crossbar_v2_1_vl_rfs.v" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/e257/hdl" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/2702/hdl/verilog" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/4676/hdl/verilog" "+incdir+C:/Xilinx/Vivado/2020.1/data/xilinx_vip/include" \
"../../../bd/design_1/ip/design_1_xbar_0/sim/design_1_xbar_0.v" \

vlog -work axi_protocol_converter_v2_1_21  -v2k5 "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/e257/hdl" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/2702/hdl/verilog" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/4676/hdl/verilog" "+incdir+C:/Xilinx/Vivado/2020.1/data/xilinx_vip/include" \
"../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/8dfa/hdl/axi_protocol_converter_v2_1_vl_rfs.v" \

vlog -work axi_clock_converter_v2_1_20  -v2k5 "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/e257/hdl" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/2702/hdl/verilog" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/4676/hdl/verilog" "+incdir+C:/Xilinx/Vivado/2020.1/data/xilinx_vip/include" \
"../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/7589/hdl/axi_clock_converter_v2_1_vl_rfs.v" \

vlog -work blk_mem_gen_v8_4_4  -v2k5 "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/e257/hdl" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/2702/hdl/verilog" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/4676/hdl/verilog" "+incdir+C:/Xilinx/Vivado/2020.1/data/xilinx_vip/include" \
"../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/2985/simulation/blk_mem_gen_v8_4.v" \

vlog -work axi_dwidth_converter_v2_1_21  -v2k5 "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/e257/hdl" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/2702/hdl/verilog" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/4676/hdl/verilog" "+incdir+C:/Xilinx/Vivado/2020.1/data/xilinx_vip/include" \
"../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/07be/hdl/axi_dwidth_converter_v2_1_vl_rfs.v" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/ec67/hdl" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/e257/hdl" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/2702/hdl/verilog" "+incdir+../../../../near_memory_radix_sort.srcs/sources_1/bd/design_1/ipshared/4676/hdl/verilog" "+incdir+C:/Xilinx/Vivado/2020.1/data/xilinx_vip/include" \
"../../../bd/design_1/ip/design_1_auto_ds_0/sim/design_1_auto_ds_0.v" \
"../../../bd/design_1/ip/design_1_auto_pc_0/sim/design_1_auto_pc_0.v" \
"../../../bd/design_1/ip/design_1_auto_ds_1/sim/design_1_auto_ds_1.v" \
"../../../bd/design_1/ip/design_1_auto_pc_1/sim/design_1_auto_pc_1.v" \
"../../../bd/design_1/sim/design_1.v" \

vlog -work xil_defaultlib \
"glbl.v"

