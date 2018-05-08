file delete -force prot_prj

source ./utils/create_package_axi_core.tcl

create_project prot_prj prot_prj -part xc7z045ffg900-2 -force
set_property board_part xilinx.com:zc706:part0:1.0 [current_project]
add_files -fileset sim_1 -norecurse src/axi_core_design_wrapper_tb.v
import_files -force -norecurse
update_compile_order -fileset sim_1
set_property ip_repo_paths ip_repo [current_fileset]
update_ip_catalog

file delete -force ip_repo/axi_core

update_ip_catalog -add_ip ip_repo/axi_core.zip -repo_path ip_repo
create_bd_design "axi_core_design"

# Interface ports
set DDR [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 DDR ]
set FIXED_IO [ create_bd_intf_port -mode Master -vlnv xilinx.com:display_processing_system7:fixedio_rtl:1.0 FIXED_IO ]
set DDR3 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 DDR3 ]
set SYS_CLK [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 SYS_CLK ]

# clk and rst
set clk_wiz_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:5.3 clk_wiz_0 ]
set_property -dict [ list CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {12.29} CONFIG.RESET_TYPE {ACTIVE_LOW} CONFIG.USE_LOCKED {false}  ] $clk_wiz_0
set rst_mig_7series_0_100M [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_mig_7series_0_100M ]
#set rst_processing_system7_0_100M [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_processing_system7_0_100M ]
set reset [ create_bd_port -dir I -type rst reset ]
set_property -dict [ list CONFIG.POLARITY {ACTIVE_HIGH}  ] $reset

# ips
set processing_system7_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 processing_system7_0 ]
set_property -dict [ list CONFIG.PCW_EN_CLK1_PORT {1} CONFIG.PCW_EN_RST1_PORT {1} CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ {100} CONFIG.PCW_FPGA1_PERIPHERAL_FREQMHZ {200} CONFIG.PCW_TTC0_PERIPHERAL_ENABLE {0} CONFIG.PCW_USE_DMA0 {0} CONFIG.PCW_USE_S_AXI_HP0 {0} CONFIG.PCW_APU_PERIPHERAL_FREQMHZ {400} CONFIG.PCW_APU_CLK_RATIO_ENABLE {4:2:1} CONFIG.preset {ZC706*}  ] $processing_system7_0
set mig_7series_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:mig_7series:4.0 mig_7series_0 ]
set str_mig_folder [get_property IP_DIR [ get_ips [ get_property CONFIG.Component_Name $mig_7series_0 ] ] ]
file copy utils/mig.prj ${str_mig_folder}/mig.prj
set_property -dict [ list CONFIG.BOARD_MIG_PARAM {Custom} CONFIG.MIG_DONT_TOUCH_PARAM {Custom} CONFIG.RESET_BOARD_INTERFACE {reset} CONFIG.XML_INPUT_FILE {mig.prj} ] $mig_7series_0
  
# general connections
set axi_mem_intercon [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_mem_intercon ]
set_property -dict [ list CONFIG.NUM_MI {1}  ] $axi_mem_intercon
connect_bd_net -net mig_7series_0_mmcm_locked [get_bd_pins mig_7series_0/mmcm_locked] [get_bd_pins rst_mig_7series_0_100M/dcm_locked]
connect_bd_net -net mig_7series_0_ui_clk [get_bd_pins axi_mem_intercon/ACLK] [get_bd_pins axi_mem_intercon/M00_ACLK] [get_bd_pins axi_mem_intercon/S00_ACLK] [get_bd_pins mig_7series_0/ui_clk] [get_bd_pins processing_system7_0/M_AXI_GP0_ACLK] [get_bd_pins rst_mig_7series_0_100M/slowest_sync_clk]
connect_bd_net -net mig_7series_0_ui_clk_sync_rst [get_bd_pins mig_7series_0/ui_clk_sync_rst] [get_bd_pins rst_mig_7series_0_100M/ext_reset_in]
connect_bd_net -net processing_system7_0_FCLK_CLK1 [get_bd_pins clk_wiz_0/clk_in1] [get_bd_pins processing_system7_0/FCLK_CLK1]
connect_bd_net -net processing_system7_0_FCLK_RESET1_N [get_bd_pins clk_wiz_0/resetn] [get_bd_pins processing_system7_0/FCLK_RESET1_N]
connect_bd_net -net reset_1 [get_bd_ports reset] [get_bd_pins mig_7series_0/sys_rst]
connect_bd_net -net rst_mig_7series_0_100M_interconnect_aresetn [get_bd_pins axi_mem_intercon/ARESETN] [get_bd_pins rst_mig_7series_0_100M/interconnect_aresetn]
connect_bd_net -net rst_mig_7series_0_100M_peripheral_aresetn [get_bd_pins axi_mem_intercon/M00_ARESETN] [get_bd_pins axi_mem_intercon/S00_ARESETN] [get_bd_pins mig_7series_0/aresetn] [get_bd_pins rst_mig_7series_0_100M/peripheral_aresetn]
connect_bd_intf_net [get_bd_intf_ports DDR] [get_bd_intf_pins processing_system7_0/DDR]
connect_bd_intf_net [get_bd_intf_ports DDR3] [get_bd_intf_pins mig_7series_0/DDR3]
connect_bd_intf_net [get_bd_intf_pins processing_system7_0/M_AXI_GP0] -boundary_type upper [get_bd_intf_pins axi_mem_intercon/S00_AXI]
connect_bd_intf_net -boundary_type upper [get_bd_intf_pins axi_mem_intercon/M00_AXI] [get_bd_intf_pins mig_7series_0/S_AXI]
connect_bd_intf_net [get_bd_intf_ports SYS_CLK] [get_bd_intf_pins mig_7series_0/SYS_CLK]
connect_bd_intf_net [get_bd_intf_ports FIXED_IO] [get_bd_intf_pins processing_system7_0/FIXED_IO]
regenerate_bd_layout

# Create address segments
create_bd_addr_seg -range 0x40000000 -offset 0x40000000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs mig_7series_0/memmap/memaddr] SEG_mig_7series_0_memaddr

# Add custom IP
set axi_core_ip [ create_bd_cell -type ip -vlnv pucrs:user:axi_core axi_core ]
delete_bd_objs [get_bd_intf_nets processing_system7_0_M_AXI_GP0]
connect_bd_intf_net [get_bd_intf_pins axi_core/m_axi] -boundary_type upper [get_bd_intf_pins axi_mem_intercon/S00_AXI]
connect_bd_intf_net [get_bd_intf_pins axi_core/s_axi] [get_bd_intf_pins processing_system7_0/M_AXI_GP0]
connect_bd_net [get_bd_pins axi_core/s_axi_aclk] [get_bd_pins axi_mem_intercon/S00_ACLK]
connect_bd_net [get_bd_pins axi_core/s_axi_aresetn] [get_bd_pins axi_mem_intercon/S00_ARESETN]
connect_bd_net [get_bd_pins axi_core/m_axi_aclk] [get_bd_pins axi_mem_intercon/M00_ACLK]
connect_bd_net [get_bd_pins axi_core/m_axi_aresetn] [get_bd_pins axi_mem_intercon/M00_ARESETN]

# assign custom address segments
delete_bd_objs [get_bd_addr_segs processing_system7_0/Data/SEG_mig_7series_0_memaddr]
delete_bd_objs [get_bd_addr_segs -excluded axi_core/m_axi/SEG_mig_7series_0_memaddr]
assign_bd_address [get_bd_addr_segs {axi_core/s_axi/reg0 }]
assign_bd_address [get_bd_addr_segs {mig_7series_0/memmap/memaddr }]
set_property offset 0x40000000 [get_bd_addr_segs {axi_core/m_axi/SEG_mig_7series_0_memaddr}]

regenerate_bd_layout
regenerate_bd_layout -routing
validate_bd_design
save_bd_design

generate_target all [get_files prot_prj/prot_prj.srcs/sources_1/bd/axi_core_design/axi_core_design.bd]
make_wrapper -files [get_files prot_prj/prot_prj.srcs/sources_1/bd/axi_core_design/axi_core_design.bd] -top
add_files -norecurse prot_prj/prot_prj.srcs/sources_1/bd/axi_core_design/hdl/axi_core_design_wrapper.v
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

# Set strategy
set_property strategy Flow_PerfOptimized_high [get_runs synth_1]