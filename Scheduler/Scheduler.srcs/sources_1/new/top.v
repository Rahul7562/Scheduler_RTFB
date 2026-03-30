`timescale 1ns / 1ps

module top(
    input  wire       clk,
    input  wire       reset,
    input  wire [3:0] task_request,
    input  wire [3:0] priority_in,
    output wire [3:0] led
);

    // Internal interconnect between scheduler pipeline stages.

    wire [3:0] pending_tasks;
    wire [3:0] priority_reg;

    wire [1:0] selected_task;
    wire       selected_valid;
    wire       selected_priority;

    wire       preempt_required;

    wire [2:0] scheduler_state;
    wire       running_valid;
    wire [1:0] running_task;
    wire       running_priority;
    wire [3:0] dispatch_enable;
    wire [3:0] clear_task_mask;
    wire [3:0] requeue_task_mask;
    wire       context_save;
    wire       context_restore;

    wire [3:0] requeue_priority_mask;

    wire [3:0] task_led_bus;
    wire [3:0] task_enable_bus;

    wire       bram_we;
    wire [1:0] bram_addr;
    wire [7:0] bram_din;
    wire [7:0] bram_dout;
    wire [7:0] live_context;

    assign requeue_priority_mask = running_priority ? requeue_task_mask : 4'b0000;

    // Latches incoming task requests and their priority tags.
    task_queue_status u_task_queue (
        .clk             (clk),
        .reset           (reset),
        .task_request    (task_request),
        .priority_in     (priority_in),
        .clear_task      (clear_task_mask),
        .requeue_task    (requeue_task_mask),
        .requeue_priority(requeue_priority_mask),
        .pending_tasks   (pending_tasks),
        .priority_reg    (priority_reg)
    );

    // Picks the highest-priority pending task (or highest index among equals).
    priority_encoder_selector u_priority_encoder (
        .pending_tasks    (pending_tasks),
        .priority_reg     (priority_reg),
        .selected_task    (selected_task),
        .selected_valid   (selected_valid),
        .selected_priority(selected_priority)
    );

    // Requests preemption when a higher-priority task is waiting.
    preemption_comparator_logic u_preemption_logic (
        .running_valid    (running_valid),
        .running_task     (running_task),
        .running_priority (running_priority),
        .candidate_valid  (selected_valid),
        .candidate_task   (selected_task),
        .candidate_priority(selected_priority),
        .preempt_required (preempt_required)
    );

    // Main scheduler FSM controlling dispatch, queue updates, and context events.
    scheduler_fsm_controller u_scheduler_fsm (
        .clk             (clk),
        .reset           (reset),
        .selected_valid  (selected_valid),
        .selected_task   (selected_task),
        .selected_priority(selected_priority),
        .preempt_required(preempt_required),
        .state           (scheduler_state),
        .running_valid   (running_valid),
        .running_task    (running_task),
        .running_priority(running_priority),
        .dispatch_enable (dispatch_enable),
        .clear_task_mask (clear_task_mask),
        .requeue_task_mask(requeue_task_mask),
        .context_save    (context_save),
        .context_restore (context_restore)
    );

    // Generates BRAM save/restore operations for context switching.
    context_switch_manager u_context_switch (
        .clk          (clk),
        .reset        (reset),
        .save_en      (context_save),
        .restore_en   (context_restore),
        .save_task    (running_task),
        .restore_task (selected_task),
        .bram_we      (bram_we),
        .bram_addr    (bram_addr),
        .bram_din     (bram_din),
        .bram_dout    (bram_dout),
        .live_context (live_context)
    );

    // Small on-chip context memory model.
    context_bram u_context_bram (
        .clk (clk),
        .we  (bram_we),
        .addr(bram_addr),
        .din (bram_din),
        .dout(bram_dout)
    );

    task1_led_slow u_task1 (
        .clk   (clk),
        .reset (reset),
        .enable(task_enable_bus[0]),
        .led   (task_led_bus[0])
    );

    task2_led_fast u_task2 (
        .clk   (clk),
        .reset (reset),
        .enable(task_enable_bus[1]),
        .led   (task_led_bus[1])
    );

    task3_led_toggle u_task3 (
        .clk   (clk),
        .reset (reset),
        .enable(task_enable_bus[2]),
        .led   (task_led_bus[2])
    );

    task4_led_pattern u_task4 (
        .clk   (clk),
        .reset (reset),
        .enable(task_enable_bus[3]),
        .led   (task_led_bus[3])
    );

    // Dispatches enable to one task and routes only that task's LED output.
    task_dispatcher_mux u_dispatcher (
        .dispatch_enable(dispatch_enable),
        .task_led_in    (task_led_bus),
        .task_enable    (task_enable_bus),
        .led            (led)
    );

endmodule

