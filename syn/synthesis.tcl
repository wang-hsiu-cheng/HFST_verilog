# Set your TOPLEVEL here
set TOPLEVEL "network_top"

# Change your timing constraint here
set TEST_CYCLE 6.0

source -echo -verbose 0_readfile.tcl 
source -echo -verbose 1_setting.tcl 
source -echo -verbose 2_compile.tcl 
source -echo -verbose 3_report.tcl 

exit
