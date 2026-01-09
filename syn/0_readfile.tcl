set TOP_DIR $TOPLEVEL
set RPT_DIR report
set NET_DIR netlist

sh rm -rf ./$TOP_DIR
sh rm -rf ./$RPT_DIR
sh rm -rf ./$NET_DIR
sh mkdir ./$TOP_DIR
sh mkdir ./$RPT_DIR
sh mkdir ./$NET_DIR

# Define a lib path
define_design_lib $TOPLEVEL -path ./$TOPLEVEL

# Add your hdl files here
analyze -library $TOPLEVEL -format verilog "../hdl/network/network_top.v"
analyze -library $TOPLEVEL -format verilog "../hdl/network/ip_decoder.v"
analyze -library $TOPLEVEL -format verilog "../hdl/network/ip_encoder.v"
analyze -library $TOPLEVEL -format verilog "../hdl/network/tcp_decoder.v"
analyze -library $TOPLEVEL -format verilog "../hdl/network/tcp_encoder.v"
analyze -library $TOPLEVEL -format verilog "../hdl/utils/checksum.v"
analyze -library $TOPLEVEL -format verilog "../hdl/utils/random.v"

# Elaborate your design
elaborate $TOPLEVEL -architecture verilog -library $TOPLEVEL

# Solve multiple instance
set uniquify_naming_style "%s_mydesign_%d"
uniquify

# Link the design
current_design $TOPLEVEL
link
