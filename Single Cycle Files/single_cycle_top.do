# Create work library
vlib work

# Compile Verilog
#     All Verilog files that are part of this design should have
#     their own "vlog" line below.
vlog "./single_cycle_top.sv"
vlog "./system_control_signals.sv"
vlog "./single_cycle_instructionpath.sv"
vlog "./single_cycle_datapath.sv"
vlog "./XOR_gate_2_inputs.sv"
vlog "./regfile.sv"
vlog "./alu.sv"
vlog "./datamem.sv"
vlog "./instructmem.sv"
vlog "./extend.sv"
vlog "./mux_2to1.sv"
vlog "./zeroCheck.sv"
vlog "./and_gate_2_inputs.sv"
vlog "./or_gate_2_inputs.sv"
vlog "./AB_arithmetic.sv"
vlog "./AB_gates.sv"
vlog "./inverter.sv"
vlog "./Decoder_5x32.sv"
vlog "./Decoder_4x16.sv"
#vlog "./Decoder_3x8.sv"
#vlog "./Decoder_2x4.sv"
vlog "./mux_32to1.sv"
vlog "./mux_16to1.sv"
vlog "./mux_8to1.sv"
vlog "./mux_4to1.sv"
vlog "./register_latch.sv"
vlog "./math.sv"


# Call vsim to invoke simulator
#     Make sure the last item on the line is the name of the
#     testbench module you want to execute.
vsim -voptargs="+acc" -t 1ps -lib work single_cycle_top_testbench

# Source the wave do file
#     This should be the file that sets up the signal window for
#     the module you are testing.
do single_cycle_top_wave.do

# Set the window types
view wave
view structure
view signals

# Run the simulation
run -all

# End
