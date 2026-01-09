# High Frequency Stock Trading

## Structure
```
.
|-- hdl
|   |-- checksum.v
|   |-- fix_decoder.v
|   |-- fix_encoder.v
|   |-- fix_top.v
|   |-- ip_decoder.v
|   |-- ip_encoder.v
|   |-- network_top.v
|   |-- random.v
|   |-- tcp_decoder.v
|   `-- tcp_encoder.v
|-- sim
|   |-- client_encoder.dat
|   |-- client_msg.dat
|   |-- hdl.f
|   |-- log.txt
|   |-- run_sim.sh
|   |-- server_decoder.dat
|   |-- server_msg.dat
|   |-- test_fix_top.v
|   |-- test_network_top.fsdb
|   `-- test_network_top.v
|-- syn
|   |-- .synopsys_dc.setup
|   |-- 0_readfile.tcl
|   |-- 1_setting.tcl
|   |-- 2_compile.tcl
|   |-- 3_report.tcl
|   |-- report_area_network_top.out
|   |-- report_network_top.out
|   |-- report_time_network_top.out
|   |-- run_syn.sh
|   `-- synthesis.tcl
|-- README.md
|-- .gitignore
```
## Features
1. FIX protocol trading
   - **NOT READY**

2. IP and TCP network
   1. Simulation
      1. Execute 2 `network_test.cpp` programs. THey can communicate with each other. 
      2. Record the communication ass the golden answer for this network RTL module.
   2. Synthesis
      1. In /syn folder. We synthesis the RTL with *Cadence GSC library (GPDK45)* library
      2. Use `.tcl` file to setup the index
      3. Before deployment, we use **Vivado** to synthesis this module and generate the bitstream. 
   3. Deployment(PYNQ Z1)
      1. Create Block Design in Vivado
      2. Use AXI GPIO
      3. Can use Python to Read/Write the signal from/to FPGA

## Simulation Steps
1. Run `./run_sim.sh`
