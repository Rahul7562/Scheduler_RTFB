`timescale 1ns / 1ps

module tb_task_queue;

    reg        clk;
    reg        reset;
    reg  [3:0] task_request;
    reg  [3:0] priority_in;
    reg  [3:0] clear_task;
    reg  [3:0] requeue_task;
    reg  [3:0] requeue_priority;
    wire [3:0] pending_tasks;
    wire [3:0] priority_reg;

    task_queue_status uut (
        .clk             (clk),
        .reset           (reset),
        .task_request    (task_request),
        .priority_in     (priority_in),
        .clear_task      (clear_task),
        .requeue_task    (requeue_task),
        .requeue_priority(requeue_priority),
        .pending_tasks   (pending_tasks),
        .priority_reg    (priority_reg)
    );

    always #5 clk = ~clk;

    initial begin
        clk             = 1'b0;
        reset           = 1'b1;
        task_request    = 4'b0000;
        priority_in     = 4'b0000;
        clear_task      = 4'b0000;
        requeue_task    = 4'b0000;
        requeue_priority = 4'b0000;

        $display("=== TB TASK QUEUE START ===");
        $monitor("t=%0t reset=%b req=%b pri_in=%b clr=%b requeue=%b pending=%b pri_reg=%b",
                  $time, reset, task_request, priority_in, clear_task, requeue_task, pending_tasks, priority_reg);

        #20;
        reset = 1'b0;

        $display("Scenario 1: Add low-priority task1 request");
        @(posedge clk);
        task_request = 4'b0001;
        priority_in  = 4'b0000;
        @(posedge clk);
        task_request = 4'b0000;

        $display("Scenario 2: Add high-priority task3 request");
        @(posedge clk);
        task_request = 4'b0100;
        priority_in  = 4'b0100;
        @(posedge clk);
        task_request = 4'b0000;
        priority_in  = 4'b0000;

        $display("Scenario 3: Clear task3 after dispatch");
        @(posedge clk);
        clear_task = 4'b0100;
        @(posedge clk);
        clear_task = 4'b0000;

        $display("Scenario 4 (Preemption Demo): Requeue task1 after preemption");
        @(posedge clk);
        requeue_task     = 4'b0001;
        requeue_priority = 4'b0000;
        @(posedge clk);
        requeue_task     = 4'b0000;
        requeue_priority = 4'b0000;

        #40;
        $display("=== TB TASK QUEUE END ===");
        $finish;
    end

endmodule
