# Create work library
vlib work

# Compile Verilog
#     All Verilog files that are part of this design should have
#     their own "vlog" line below.
#vlog "./instructmem.sv"

vlog "./instructmem_synthesizable.sv"
vlog "./datamem.sv"
vlog "./payItForward.sv"
vlog "./MUX2byX_X.sv"
vlog "./MUX2by64_64.sv"
vlog "./math.sv"
vlog "./two_seg7.sv"

vlog "./REGISTER.sv"
vlog "./regfile.sv"
vlog "./MUX32by64_64.sv"
vlog "./MUX32_1.sv"
vlog "./MUX16_1.sv"
vlog "./decoder.sv"

vlog "./D_FF_enable.sv"
vlog "./D_FF.sv"
vlog "./MUX8_1.sv"
vlog "./MUX4_1.sv"
vlog "./MUX2_1.sv"
vlog "./fullAdder_1bit.sv"

vlog "./alu.sv"
vlog "./control_logic.sv"
vlog "./pipinghotCPU.sv"
vlog "./ALU_1bit.sv"
vlog "./extendem.sv"
vlog "./check_zero.sv"

# Call vsim to invoke simulator
#     Make sure the last item on the line is the name of the
#     testbench module you want to execute.
vsim -voptargs="+acc" -t 1ps -lib work pipinghotCPU_testbench

# Source the wave do file
#     This should be the file that sets up the signal window for
#     the module you are testing.
do pipinghotCPU_wave.do

# Set the window types
view wave
view structure
view signals

# Run the simulation
run -all

# End
