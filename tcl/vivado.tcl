set SRC_DIR   $env(DIR_SRC)
set SYN_DIR   $env(DIR_SYN)

# Parse command line argument 
while {[llength $argv]} {
  set argv [lassign $argv flag]
  switch -glob $flag {
    -top-module {
      set argv [lassign $argv TOP]
    }
    -board {
      set argv [lassign $argv PART]
    }
    default {
      return -code error [list {unknown option} $flag]
    }
  }
}

if {![info exists TOP]} {
  return -code error [list {-top-module option is required}]
}

if {![info exists PART]} {
  return -code error [list {-board option is required}]
}


# create project
create_project -force $TOP -part $PART

# Add source
read_verilog [glob [file join $SRC_DIR *.v]]
read_verilog [glob [file join $SYN_DIR *.v]]
read_verilog [glob [file join $SRC_DIR *.sv]]
read_verilog [glob [file join $SYN_DIR *.sv]]
read_verilog [glob [file join $SRC_DIR *.vh]]
read_verilog [glob [file join $SYN_DIR *.vh]]
read_xdc [glob [file join $SYN_DIR *.xdc]]

# Synthesis
synth_design -top $TOP -part $PART -flatten_hierarchy none 
write_checkpoint -force post_synth

# Optimize
opt_design -directive Explore
write_checkpoint -force post_opt

# Place
place_design -directive Explore
phys_opt_design -directive Explore
power_opt_design
write_checkpoint -force post_place

# Route
route_design -directive Explore
phys_opt_design -directive Explore
write_checkpoint -force post_route

# Bitstream
write_bitstream -force $TOP.bit
write_sdf -force $TOP.sdf
write_verilog -mode timesim -force ${TOP}_netlist.v
