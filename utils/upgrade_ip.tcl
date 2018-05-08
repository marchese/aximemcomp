close_sim -force
update_ip_catalog -rebuild -scan_changes
upgrade_ip -vlnv pucrs:user:axicore:1.1 [get_ips  axicore_design_axicore_0] -log ip_upgrade.log
export_ip_user_files -of_objects [get_ips axicore_design_axicore_0] -no_script -sync -force -quiet
report_ip_status -name ip_status
launch_simulation
open_wave_config {axicore_project_behav.wcfg}
run 40 us