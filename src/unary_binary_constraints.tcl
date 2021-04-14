#### Template Script for RTL->Gate-Level Flow (generated from GENUS 18.14-s037_1) 

if {[file exists /proc/cpuinfo]} {
  sh grep "model name" /proc/cpuinfo
  sh grep "cpu MHz"    /proc/cpuinfo
}

puts "Hostname : [info hostname]"

##############################################################################
## Preset global variables and attributes
##############################################################################


set DESIGN unary_binary_MAC
set GEN_EFF medium
set MAP_OPT_EFF medium
set DATE [clock format [clock seconds] -format "%b%d-%T"] 	
set _OUTPUTS_PATH ./unary_binary_outputs/							
set _REPORTS_PATH ./unary_binary_reports/										
set _LOG_PATH unary_binary_logs_
##set ET_WORKDIR <ET work directory>
set_db / .init_lib_search_path {../asap7_dir/}		                                          
set_db / .script_search_path {./}								        
set_db / .init_hdl_search_path {../unary_binary} 
##Uncomment and specify machine names to enable super-threading.
##set_db / .super_thread_servers {<machine names>} 
##For design size of 1.5M - 5M gates, use 8 to 16 CPUs. For designs > 5M gates, use 16 to 32 CPUs
##set_db / .max_cpus_per_server 8

##Default undriven/unconnected setting is 'none'.  
##set_db / .hdl_unconnected_value 0 | 1 | x | none

set_db / .information_level 7 

set_db auto_ungroup none

###############################################################
## Library setup
###############################################################


read_libs " \
    asap7sc7p5t_AO_RVT_TT_ccs_191031.lib \
    asap7sc7p5t_INVBUF_RVT_TT_ccs_191031.lib \
    asap7sc7p5t_OA_RVT_TT_ccs_191031.lib\
    asap7sc7p5t_SEQ_RVT_TT_ccs_191031.lib \
    asap7sc7p5t_SIMPLE_RVT_TT_ccs_191031.lib \

"

read_physical -lef " \
  asap7_tech_4x_181009.lef \
  asap7sc7p5t_24_R_4x_170912.lef \
"


## Provide either cap_table_file or the qrc_tech_file
#set_db / .cap_table_file <file> 
#read_qrc ./qrcTechFile_typ03_scaled4xV06
##generates <signal>_reg[<bit_width>] format
#set_db / .hdl_array_naming_style %s\[%d\] 
## 

set_db / .hdl_generate_index_style %s_%d_

set_db / .lp_insert_clock_gating true 

####################################################################
## Load Design
####################################################################


read_hdl -language sv "library.sv unary_binary_MAC.sv"
elaborate $DESIGN
puts "Runtime & Memory after 'read_hdl'"
time_info Elaboration



check_design -unresolved

####################################################################
## Constraints Setup
####################################################################

read_sdc ../src/chip.sdc
puts "The number of exceptions is [llength [vfind "design:$DESIGN" -exception *]]"


#set_db "design:$DESIGN" .force_wireload <wireload name> 

if {![file exists ${_LOG_PATH}]} {
  file mkdir ${_LOG_PATH}
  puts "Creating directory ${_LOG_PATH}"
}


if {![file exists ${_REPORTS_PATH}]} {
  file mkdir ${_REPORTS_PATH}
  puts "Creating directory ${_REPORTS_PATH}"
}
check_timing_intent


###################################################################################
## Define cost groups (clock-clock, clock-output, input-clock, input-output)
###################################################################################

## Uncomment to remove already existing costgroups before creating new ones.
## delete_obj [vfind /designs/* -cost_group *]

if {[llength [all_registers]] > 0} { 
  define_cost_group -name I2C -design $DESIGN
  define_cost_group -name C2O -design $DESIGN
  define_cost_group -name C2C -design $DESIGN
  path_group -from [all_registers] -to [all_registers] -group C2C -name C2C
  path_group -from [all_registers] -to [all_outputs] -group C2O -name C2O
  path_group -from [all_inputs]  -to [all_registers] -group I2C -name I2C
}

define_cost_group -name I2O -design $DESIGN
path_group -from [all_inputs]  -to [all_outputs] -group I2O -name I2O


####################################################################################################
## Synthesizing to generic 
####################################################################################################

syn_generic
puts "Runtime & Memory after 'syn_generic'"
time_info GENERIC





# ####################################################################################################
# ## Synthesizing to gates
# ####################################################################################################

 syn_map
 puts "Runtime & Memory after 'syn_map'"
 time_info MAPPED



#######################################################################################################
## Optimize Netlist
#######################################################################################################

syn_opt

puts "Runtime & Memory after 'syn_opt'"
time_info OPT


######################################################################################################
## write backend file set (verilog, SDC, config, etc.)
######################################################################################################

report_power > $_REPORTS_PATH/${DESIGN}_power.rpt
report_timing -unconstrained > $_REPORTS_PATH/${DESIGN}_time.rpt
report_area > $_REPORTS_PATH/${DESIGN}_area.rpt
write_hdl  > ${_OUTPUTS_PATH}/${DESIGN}_m.v
write_sdc > ${_OUTPUTS_PATH}/${DESIGN}_m.sdc
write_sdf -timescale ns -precision 3 > ${_OUTPUTS_PATH}/${DESIGN}_m.sdf

#Uncomment the below if you want more detailed reports
#report_dp > $_REPORTS_PATH/${DESIGN}_datapath_incr.rpt
#write_snapshot -outdir $_REPORTS_PATH -tag final
#report_summary -directory $_REPORTS_PATH

puts "Final Runtime & Memory."
time_info FINAL
puts "============================"
puts "Synthesis Finished ........."
puts "============================"

file copy [get_db / .stdout_log] ${_LOG_PATH}/.
quit
