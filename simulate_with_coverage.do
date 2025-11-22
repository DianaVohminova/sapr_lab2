# ??????? ?????????? ??????????
quit -sim
.main clear

# ???????? ??????? ??????????
vlib work2

echo "=========================================="
echo "Starting APB Sync Generator Simulation with Coverage"
echo "=========================================="

# ????????? ?????????? work2 ??? ???????
vmap work work2

# ?????????? SystemVerilog ??????
vlog -sv l2_master.sv
vlog -sv l2_slave.sv  
vlog -sv testbench_with_coverage.sv

echo "Compilation completed"

# ?????? ????????? ?????????
vsim -voptargs=+acc work.Testbench_With_Coverage

echo "Simulation started"

# ?????????? ???? ??? ???????
add wave -divider "APB Interface"
add wave -hex /Testbench_With_Coverage/PADDR
add wave -hex /Testbench_With_Coverage/PWDATA
add wave -hex /Testbench_With_Coverage/PRDATA
add wave -binary /Testbench_With_Coverage/PSEL
add wave -binary /Testbench_With_Coverage/PENABLE
add wave -binary /Testbench_With_Coverage/PWRITE
add wave -binary /Testbench_With_Coverage/PREADY

add wave -divider "Master FSM"
add wave -binary /Testbench_With_Coverage/master_inst/state

add wave -divider "Sync Generator"
add wave -binary /Testbench_With_Coverage/SYNC_OUT
add wave -hex /Testbench_With_Coverage/slave_inst/control_reg
add wave -hex /Testbench_With_Coverage/slave_inst/period_reg
add wave -hex /Testbench_With_Coverage/slave_inst/counter_reg
add wave -binary /Testbench_With_Coverage/slave_inst/sync_reg

add wave -divider "Coverage Flags"
add wave -literal /Testbench_With_Coverage/fsm_idle_covered
add wave -literal /Testbench_With_Coverage/fsm_setup_covered
add wave -literal /Testbench_With_Coverage/fsm_access_covered
add wave -literal /Testbench_With_Coverage/write_control_covered
add wave -literal /Testbench_With_Coverage/write_period_covered
add wave -literal /Testbench_With_Coverage/read_status_covered
add wave -literal /Testbench_With_Coverage/sync_toggle_covered
add wave -literal /Testbench_With_Coverage/counter_reset_covered
add wave -literal /Testbench_With_Coverage/generator_start_covered
add wave -literal /Testbench_With_Coverage/generator_stop_covered
add wave -literal /Testbench_With_Coverage/boundary_period_covered

wave zoom full

echo "Running simulation..."
run 4000ns

echo "Simulation completed"