# Quick Start Guide - FPGA Task Scheduler

## Overview
This guide helps you quickly simulate and understand the FPGA hardware task scheduler system.

## File Locations
All Verilog files are located in:
```
/Scheduler/Scheduler.srcs/sources_1/new/
```

## Quick Simulation Steps (Vivado)

### 1. Open Project
- Launch Vivado
- Open the project: `Scheduler/Scheduler.xpr`

### 2. Run Individual Module Tests

#### Test Task Queue
```tcl
set_property top tb_task_queue [get_filesets sim_1]
launch_simulation
run all
```

#### Test Priority Encoder
```tcl
set_property top tb_priority_encoder [get_filesets sim_1]
launch_simulation
run all
```

#### Test Preemption Logic
```tcl
set_property top tb_preemption_logic [get_filesets sim_1]
launch_simulation
run all
```

#### Test Scheduler FSM
```tcl
set_property top tb_scheduler [get_filesets sim_1]
launch_simulation
run all
```

#### Test Context Switch Manager
```tcl
set_property top tb_context_switch [get_filesets sim_1]
launch_simulation
run all
```

#### Test Dispatcher
```tcl
set_property top tb_dispatcher [get_filesets sim_1]
launch_simulation
run all
```

#### Test BRAM
```tcl
set_property top tb_bram [get_filesets sim_1]
launch_simulation
run all
```

#### Test Task 1 (Slow Blink)
```tcl
set_property top tb_task1 [get_filesets sim_1]
launch_simulation
run all
```

#### Test Task 2 (Fast Blink)
```tcl
set_property top tb_task2 [get_filesets sim_1]
launch_simulation
run all
```

#### Test Task 3 (Toggle)
```tcl
set_property top tb_task3 [get_filesets sim_1]
launch_simulation
run all
```

#### Test Task 4 (Pattern)
```tcl
set_property top tb_task4 [get_filesets sim_1]
launch_simulation
run all
```

### 3. Run System-Level Tests

#### Test Complete System Integration
```tcl
set_property top tb_top_system [get_filesets sim_1]
launch_simulation
run all
```

#### Test Final System (Preemption Demo)
```tcl
set_property top tb_final_system [get_filesets sim_1]
launch_simulation
run all
```

## Expected Results

### Module Tests
- **tb_task_queue**: Shows task queuing, clearing, and requeueing
- **tb_priority_encoder**: Demonstrates priority-based task selection
- **tb_preemption_logic**: Shows when preemption is triggered
- **tb_scheduler**: Displays FSM state transitions
- **tb_context_switch**: Shows context save/restore operations
- **tb_dispatcher**: Verifies task enable and LED multiplexing
- **tb_bram**: Tests memory read/write operations

### Task Tests
- **tb_task1**: Slow LED blinking pattern (DIVIDER=40)
- **tb_task2**: Fast LED blinking pattern (DIVIDER=8)
- **tb_task3**: Medium toggle pattern (TOGGLE_DIV=4)
- **tb_task4**: 1-0-1-0 LED pattern (STEP_DIV=6)

### System Tests
- **tb_top_system**: Complete scheduler operation with multiple scenarios
  - Normal priority task execution
  - High priority task preemption
  - Task switching and LED control

- **tb_final_system**: Focused preemption demonstration
  - Low priority task starts
  - High priority task interrupts
  - LED output switches accordingly

## Using iverilog/ModelSim (Alternative)

If you prefer command-line simulation:

### Compile All Files
```bash
iverilog -o sim_output \
  task_queue_status.v \
  priority_encoder_selector.v \
  preemption_comparator_logic.v \
  scheduler_fsm_controller.v \
  context_switch_manager.v \
  task_dispatcher_mux.v \
  context_bram.v \
  task1_led_slow.v \
  task2_led_fast.v \
  task3_led_toggle.v \
  task4_led_pattern.v \
  top.v \
  tb_final_system.v
```

### Run Simulation
```bash
vvp sim_output
```

### View Waveforms
```bash
gtkwave dump.vcd
```

## Key Signals to Monitor

### In tb_top_system or tb_final_system:
- `task_request[3:0]` - Task request inputs
- `priority_in[3:0]` - Priority flags
- `led[3:0]` - LED outputs
- `uut.u_scheduler_fsm.state[2:0]` - FSM state
- `uut.u_scheduler_fsm.running_task[1:0]` - Currently running task
- `uut.u_scheduler_fsm.running_priority` - Current task priority
- `uut.dispatch_enable[3:0]` - Task enable signals

### FSM State Values:
- 0: IDLE
- 1: SELECT_TASK
- 2: RUN_TASK
- 3: PREEMPT
- 4: CONTEXT_SWITCH

## Preemption Demo Walkthrough

### Scenario in tb_final_system:

1. **t=0-20ns**: Reset period
2. **t=20-30ns**: Request task1 (low priority)
   - FSM: IDLE → SELECT_TASK → RUN_TASK
   - LED[0] starts slow blinking
3. **t=70ns**: Request task4 (high priority)
   - FSM: RUN_TASK → PREEMPT → CONTEXT_SWITCH → RUN_TASK
   - Task1 context saved
   - Task1 requeued
   - Task4 context restored
   - LED[3] shows pattern (1010)
4. **Watch**: LED output changes from task1 to task4

## Troubleshooting

### No Waveforms Showing
- Ensure testbench has `$dumpfile` and `$dumpvars` (if using VCD)
- Check that simulation runs to completion ($finish)

### Compilation Errors
- Verify all source files are in project
- Check file paths are correct
- Ensure Verilog-2001 or later syntax support

### Unexpected Behavior
- Check clock period (10ns = 100MHz)
- Verify reset is released after initialization
- Monitor FSM state transitions
- Check task_request timing (should pulse for 1 clock)

## Synthesis Quick Check

To verify design synthesizes correctly:

```tcl
# In Vivado
synth_design -top top -part xc7a35tcpg236-1
report_utilization
report_timing
```

Expected resource usage:
- LUTs: ~100-150
- FFs: ~50-80
- BRAM: 1 (for context storage)

## VIVA Demo Script

### 5-Minute Demonstration

1. **Minute 1**: Show top.v hierarchy
   - Point out scheduler pipeline
   - Explain modular design

2. **Minute 2**: Run tb_final_system
   - Show simulation output
   - Point out state transitions

3. **Minute 3**: Explain preemption
   - Trace signals during preemption
   - Show context switching

4. **Minute 4**: Open scheduler_fsm_controller.v
   - Show FSM states
   - Explain state transitions

5. **Minute 5**: Show synthesis results
   - Resource utilization
   - Timing analysis

## Common VIVA Questions & Answers

**Q: How do you test the scheduler?**
A: Multiple testbenches - individual module tests and system-level integration tests with preemption scenarios.

**Q: Show me a preemption event.**
A: Run tb_final_system, watch at t=70ns when task4 (high priority) preempts task1.

**Q: How is context stored?**
A: Using BRAM (context_bram.v) - 4 entries, one per task, accessed via context_switch_manager.v

**Q: What if two high-priority tasks arrive?**
A: Priority encoder (priority_encoder_selector.v) selects highest task index among high-priority tasks.

**Q: Can tasks run concurrently?**
A: No, dispatcher ensures only one task is enabled at a time (task_dispatcher_mux.v).

## Additional Resources

- SYSTEM_OVERVIEW.md - Complete system documentation
- Individual .v files - Each has detailed comments
- Testbench files - Show usage examples

## Support

For issues or questions:
1. Check simulation console output
2. Review waveforms for signal behavior
3. Read module comments in source files
4. Refer to SYSTEM_OVERVIEW.md for architecture details
