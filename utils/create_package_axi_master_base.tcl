file mkdir ip_repo

file delete -force axi_master_ip
file delete -force ip_repo/pucrs_user_axi_master.zip
create_project axi_master_ip axi_master_ip -part xc7z045ffg900-2 -force
set_property board_part xilinx.com:zc706:part0:1.0 [current_project]
add_files -norecurse src/axi_master_base.v
import_files -force -norecurse
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1
ipx::package_project 
set_property library {user} [ipx::current_core]
set_property vendor_display_name {PUCRS} [ipx::current_core]
set_property company_url {http://pucrs.br} [ipx::current_core]
set_property version {1.1} [ipx::current_core]
set_property display_name {axi_master_v1_1} [ipx::current_core]
set_property description {axi_master_v1_1} [ipx::current_core]
set_property vendor {pucrs} [ipx::current_core]
set_property supported_families {{zynq} {Production}} [ipx::current_core]
set_property taxonomy {{/Embedded_Processing/AXI_Infrastructure}} [ipx::current_core]
ipx::check_integrity [ipx::current_core]
ipx::archive_core {ip_repo/pucrs_user_axi_master.zip} [ipx::current_core]
close_project
file delete -force axi_master_ip