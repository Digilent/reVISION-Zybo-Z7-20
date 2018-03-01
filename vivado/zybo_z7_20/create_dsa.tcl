#SDSoC Platform DSA Generation Script

set_property PFM_NAME "digilentinc.com:zybo_z7_20:zybo_z7_20:1.0" [get_files ./zybo_z7_20.srcs/sources_1/bd/zybo_z7_20/zybo_z7_20.bd]
set_property PFM.CLOCK { \
	FCLK_CLK0 {id "0" is_default "true" proc_sys_reset "psr_fclk0" } \
	} [get_bd_cells /processing_system7_0]
set_property PFM.CLOCK { \
	BUFG_O {id "1" is_default "false" proc_sys_reset "psr_fclk1" } \
	} [get_bd_cells /util_bufg_fclk1]
set_property PFM.CLOCK { \
	clk_out2 {id "2" is_default "false" proc_sys_reset "psr_clkwiz2" } \
	clk_out3 {id "3" is_default "false" proc_sys_reset "psr_clkwiz3" } \
	clk_out4 {id "4" is_default "false" proc_sys_reset "psr_clkwiz4" } \
	clk_out5 {id "5" is_default "false" proc_sys_reset "psr_clkwiz5" } \
	} [get_bd_cells /clk_wiz_0]
set_property PFM.AXI_PORT { \
	M_AXI_GP1 {memport "M_AXI_GP"} \
	S_AXI_HP2 {memport "S_AXI_HP" sptag "HP2" memory "ps7 HP2_DDR_LOWOCM"} \
	S_AXI_HP3 {memport "S_AXI_HP" sptag "HP3" memory "ps7 HP3_DDR_LOWOCM"} \
	S_AXI_ACP {memport "S_AXI_ACP" sptag "ACP" memory "ps_ACP_DDR_LOWOCM"} \
	} [get_bd_cells /processing_system7_0]
set intVar []
for {set i 6} {$i < 16} {incr i} {
	lappend intVar In$i {}
}
set_property PFM.IRQ $intVar [get_bd_cells /xlconcat_0]

set_property dsa.ip_cache_dir [get_property ip_output_repo [current_project]] [current_project]

write_dsa -force -include_bit ./zybo_z7_20.dsa


