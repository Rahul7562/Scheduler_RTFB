`timescale 1ns / 1ps

module tb_scheduler;

    reg        clk;
    reg        reset;
    reg        selected_valid;
    reg  [1:0] selected_task;
    reg        selected_priority;
    reg        preempt_required;

    wire [2:0] state;
    wire       running_valid;
    wire [1:0] running_task;
    wire       running_priority;
    wire [3:0] dispatch_enable;
    wire [3:0] clear_task_mask;
    wire [3:0] requeue_task_mask;
    wire       context_save;
    wire       context_restore;

    scheduler_fsm_controller uut (
        .clk              (clk),
        .reset            (reset),
        .selected_valid   (selected_valid),
        .selected_task    (selected_task),
        .selected_priority(selected_priority),
        .preempt_required (preempt_required),
        .state            (state),
        .running_valid    (running_valid),
        .running_task     (running_task),
        .running_priority (running_priority),
        .dispatch_enable  (dispatch_enable),
        .clear_task_mask  (clear_task_mask),
        .requeue_task_mask(requeue_task_mask),
        .context_save     (context_save),
        .context_restore  (context_restore)
    );

    always #5 clk = ~clk;

    initial begin
        clk              = 1'b0;
        reset            = 1'b1;
        selected_valid   = 1'b0;
        selected_task    = 2'd0;
        selected_priority = 1'b0;
        preempt_required = 1'b0;

        $display("=== TB SCHEDULER FSM START ===");
        $monitor("t=%0t state=%0d sel_v=%b sel_t=%0d sel_p=%b run_v=%b run_t=%0d run_p=%b preempt=%b disp=%b clr=%b rq=%b save=%b restore=%b",
                 $time, state, selected_valid, selected_task, selected_priority,
                 running_valid, running_task, running_priority, preempt_required,
                 dispatch_enable, clear_task_mask, requeue_task_mask, context_save, context_restore);

        #20;
        reset = 1'b0;

        $display("Scenario 1: Select and run task1 low priority");
        @(posedge clk);
        selected_valid    = 1'b1;
        selected_task     = 2'd0;
        selected_priority = 1'b0;
        @(posedge clk);
        selected_valid    = 1'b0;

        repeat (4) @(posedge clk);

        $display("Scenario 2 (Preemption Demo): High-priority task4 preempts");
        selected_valid    = 1'b1;
        selected_task     = 2'd3;
        selected_priority = 1'b1;
        preempt_required  = 1'b1;
        @(posedge clk);
        preempt_required  = 1'b0;

        repeat (3) @(posedge clk);
        selected_valid    = 1'b0;

        #40;
        $display("=== TB SCHEDULER FSM END ===");
        $finish;
    end

endmodule
