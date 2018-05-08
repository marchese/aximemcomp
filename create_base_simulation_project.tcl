file delete -force base_sim_prj

# add sources
create_project base_sim_prj base_sim_prj -part xc7z045ffg900-2 -force
set_property board_part xilinx.com:zc706:part0:1.0 [current_project]
add_files -norecurse src/axi_slave.v
add_files -norecurse src/axi_master_base.v
add_files -fileset sim_1 -norecurse src/axi_core_design_wrapper_tb.v
set_property top axi_core_design_wrapper_tb [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]
import_files -force -norecurse
update_compile_order -fileset sim_1

# create block design
create_bd_design "axi_core_design"

create_bd_cell -type module -reference axi_slave axi_slave
create_bd_cell -type module -reference axi_master axi_master

create_bd_port -dir I -type clk ACLK
set_property CONFIG.FREQ_HZ 100000000 [ get_bd_ports /ACLK]
connect_bd_net [get_bd_ports /ACLK] [get_bd_pins /axi_master/m_axi_aclk]
connect_bd_net [get_bd_ports /ACLK] [get_bd_pins /axi_slave/s_axi_aclk]

create_bd_port -dir I -type rst ARESETN
connect_bd_net [get_bd_ports /ARESETN] [get_bd_pins /axi_master/m_axi_aresetn]
connect_bd_net [get_bd_ports /ARESETN] [get_bd_pins /axi_slave/s_axi_aresetn]

connect_bd_intf_net [get_bd_intf_pins /axi_master/m_axi] [get_bd_intf_pins /axi_slave/s_axi]

regenerate_bd_layout

assign_bd_address
assign_bd_address [get_bd_addr_segs {axi_slave/s_axi/reg0 }]
set_property range 1G [get_bd_addr_segs {axi_master/m_axi/SEG_axi_slave_reg0}]

validate_bd_design
save_bd_design

make_wrapper -files [get_files base_sim_prj/base_sim_prj.srcs/sources_1/bd/axi_core_design/axi_core_design.bd] -top

update_compile_order -fileset sources_1
set_property runtime {} [get_filesets sim_1]
add_files -fileset sim_1 -norecurse utils/base_sim_wav.wcfg