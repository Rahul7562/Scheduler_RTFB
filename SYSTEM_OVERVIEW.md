# FPGA Hardware Task Scheduler System - Complete Implementation

## System Overview

This repository contains a complete FPGA-based hardware task scheduler system implemented in Verilog with preemptive control for 4 tasks. The system is Vivado-compatible and follows best practices for FPGA design.

## Architecture Components

### Core Modules

1. **task_queue_status.v** - Task Queue & Status Registers
   - Manages pending task requests and their priorities
   - Handles task clearing and requeueing during preemption
   - Synchronous operation with proper reset

2. **priority_encoder_selector.v** - Priority Encoder & Selector
   - Two-level priority selection (high priority first, then normal)
   - Selects highest priority task from pending queue
   - Outputs selected task ID, validity, and priority level

3. **preemption_comparator_logic.v** - Preemption Comparator Logic
   - Compares running task with candidate task
   - Triggers preemption when higher priority task arrives
   - Ensures different task with strictly higher priority

4. **scheduler_fsm_controller.v** - Scheduler FSM Controller
   - Implements 5-state FSM: IDLE, SELECT_TASK, RUN_TASK, PREEMPT, CONTEXT_SWITCH
   - Manages task dispatch and context switch operations
   - Generates control signals for all modules

5. **context_switch_manager.v** - Context Switch Manager
   - Saves and restores task context using BRAM
   - Maintains live context counter
   - Handles synchronous BRAM read/write operations

6. **task_dispatcher_mux.v** - Task Dispatcher (MUX)
   - Routes enable signals to selected task
   - Multiplexes LED outputs
   - Only active task controls LED output

7. **context_bram.v** - BRAM Memory
   - 4-entry block RAM for context storage
   - Synchronous read/write operations
   - Simple register model for context

### Hardware Task Modules

8. **task1_led_slow.v** - Slow Blinking LED Task
   - Toggles LED at slow rate (DIVIDER=40)
   - Only active when enabled
   - LED forced OFF when disabled

9. **task2_led_fast.v** - Fast Blinking LED Task
   - Toggles LED at fast rate (DIVIDER=8)
   - Only active when enabled
   - LED forced OFF when disabled

10. **task3_led_toggle.v** - Toggle LED Task
    - Periodic LED toggling (TOGGLE_DIV=4)
    - Only active when enabled
    - LED forced OFF when disabled

11. **task4_led_pattern.v** - Pattern LED Task
    - Generates 1-0-1-0 pattern (STEP_DIV=6)
    - Uses state machine for pattern generation
    - Only active when enabled

### Top-Level Integration

12. **top.v** - System Top Module
    - Integrates all core modules and tasks
    - Connects scheduler pipeline stages
    - Provides system-level I/O interface

## System Interfaces

### Inputs
- `clk` - System clock
- `reset` - Synchronous reset
- `task_request[3:0]` - Task request signals (one-hot or bitmap)
- `priority_in[3:0]` - Priority flags for each task (1=high, 0=normal)

### Outputs
- `led[3:0]` - LED outputs, one per task

## Scheduler Operation

### FSM States

1. **IDLE** - Waiting for task requests
2. **SELECT_TASK** - Selecting highest priority pending task
3. **RUN_TASK** - Executing selected task
4. **PREEMPT** - Handling preemption event
5. **CONTEXT_SWITCH** - Saving/restoring task context

### Preemption Flow

1. Higher priority task arrives while lower priority task is running
2. Preemption comparator detects condition
3. FSM transitions to PREEMPT state
4. Current task context is saved to BRAM
5. Current task is requeued with its priority
6. FSM transitions to CONTEXT_SWITCH state
7. New task context is restored from BRAM
8. FSM transitions to RUN_TASK state with new task

## Testbenches

### Module Testbenches

- **tb_task_queue.v** - Tests task queuing, clearing, and requeueing
- **tb_priority_encoder.v** - Tests priority selection logic
- **tb_preemption_logic.v** - Tests preemption detection
- **tb_scheduler.v** - Tests FSM state transitions
- **tb_context_switch.v** - Tests context save/restore
- **tb_dispatcher.v** - Tests task dispatch and LED multiplexing
- **tb_bram.v** - Tests BRAM read/write operations

### Task Testbenches

- **tb_task1.v** - Tests slow blinking task
- **tb_task2.v** - Tests fast blinking task
- **tb_task3.v** - Tests toggle task
- **tb_task4.v** - Tests pattern task

### System Testbenches

- **tb_top_system.v** - Complete system integration test
  - Multiple scenarios including preemption demonstrations
  - Tests normal and high-priority task execution
  - Verifies LED output switching

- **tb_final_system.v** - Final system validation
  - Demonstrates preemptive scheduling
  - Shows context switching behavior
  - Validates complete scheduler operation

## Design Features

### Fully Synchronous Design
- All modules use positive edge clock
- Non-blocking assignments (<=) for sequential logic
- Blocking assignments (=) for combinational logic
- No latches generated

### Modular Architecture
- Clean module boundaries
- Well-defined interfaces
- Easy to understand and maintain
- Suitable for VIVA presentations

### Vivado Compatible
- Standard Verilog syntax
- Synthesizable constructs
- Proper timescale directives
- BRAM inference friendly

### Testbench Features
- Clock generation (10ns period)
- Reset sequences
- Multiple test scenarios
- $monitor and $display statements
- Preemption demonstrations

## Usage Instructions

### Simulation in Vivado

1. Create new RTL project
2. Add all .v files from `Scheduler/Scheduler.srcs/sources_1/new/`
3. Set top.v as top module for synthesis
4. For simulation, select desired testbench as top
5. Run behavioral simulation

### Module-Level Testing

```tcl
# Test individual module
set_property top tb_task_queue [current_fileset sim_1]
launch_simulation
run all
```

### System-Level Testing

```tcl
# Test complete system
set_property top tb_top_system [current_fileset sim_1]
launch_simulation
run all
```

### Final System Test

```tcl
# Final integration test
set_property top tb_final_system [current_fileset sim_1]
launch_simulation
run all
```

## File Organization

```
Scheduler/
└── Scheduler.srcs/
    └── sources_1/
        └── new/
            ├── Core Modules
            │   ├── task_queue_status.v
            │   ├── priority_encoder_selector.v
            │   ├── preemption_comparator_logic.v
            │   ├── scheduler_fsm_controller.v
            │   ├── context_switch_manager.v
            │   ├── task_dispatcher_mux.v
            │   └── context_bram.v
            │
            ├── Task Modules
            │   ├── task1_led_slow.v
            │   ├── task2_led_fast.v
            │   ├── task3_led_toggle.v
            │   └── task4_led_pattern.v
            │
            ├── Integration
            │   └── top.v
            │
            └── Testbenches
                ├── tb_task_queue.v
                ├── tb_priority_encoder.v
                ├── tb_preemption_logic.v
                ├── tb_scheduler.v
                ├── tb_context_switch.v
                ├── tb_dispatcher.v
                ├── tb_bram.v
                ├── tb_task1.v
                ├── tb_task2.v
                ├── tb_task3.v
                ├── tb_task4.v
                ├── tb_top_system.v
                └── tb_final_system.v
```

## Key Design Decisions

1. **Priority Model**: Two-level priority (high/normal) with task index as tiebreaker
2. **Context Model**: Simple 8-bit counter per task
3. **BRAM Size**: 4 entries × 8 bits (minimal for 4 tasks)
4. **LED Control**: Each task has independent LED output
5. **Preemption**: Immediate preemption when higher priority task arrives
6. **Task Enable**: Tasks only operate when dispatch_enable is active

## Verification Points

- [x] All modules synthesize without errors
- [x] No latches generated
- [x] All testbenches compile and run
- [x] Preemption behavior verified
- [x] Context switching demonstrated
- [x] LED outputs correct per task
- [x] Priority selection correct
- [x] FSM state transitions proper
- [x] BRAM operations functional

## VIVA Preparation Notes

### Key Concepts to Explain

1. **Preemptive Scheduling**: Higher priority task interrupts lower priority task
2. **Context Switching**: Saving and restoring task state
3. **FSM Design**: State-based control flow
4. **Priority Encoder**: Combinational logic for task selection
5. **BRAM**: Block RAM for efficient on-chip storage

### Demonstration Flow

1. Show module hierarchy in top.v
2. Explain FSM state diagram
3. Run tb_final_system to show preemption
4. Trace signal flow during context switch
5. Show LED output changes based on scheduler

### Common Questions

**Q: Why use BRAM instead of registers?**
A: BRAM is more resource-efficient for larger contexts and demonstrates standard FPGA storage techniques.

**Q: How does preemption work?**
A: Preemption comparator checks if incoming task has higher priority than running task. If yes, FSM saves current context, requeues current task, and switches to new task.

**Q: What happens if two tasks have same priority?**
A: The priority encoder selects based on task index (higher index wins in this implementation).

**Q: Why separate enable signal for each task?**
A: Tasks must turn off when not selected to prevent unwanted LED behavior and save power.

**Q: Can this scale to more tasks?**
A: Yes, by increasing bit widths (e.g., 8 tasks needs 3-bit task_id, 8-bit masks, larger BRAM).

## Future Enhancements

- Multi-level priority (more than 2 levels)
- Round-robin scheduling for equal priorities
- Task completion detection
- Dynamic priority adjustment
- Larger context storage
- Performance counters
- Power management

## Conclusion

This implementation provides a complete, working FPGA hardware task scheduler suitable for educational purposes, VIVA presentations, and as a foundation for more complex scheduling systems. All modules are fully functional, well-commented, and properly tested.
