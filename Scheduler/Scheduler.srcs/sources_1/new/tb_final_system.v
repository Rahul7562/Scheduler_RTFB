`timescale 1ns / 1ps

module tb_final_system;

    reg        clk;
    reg        reset;
    reg  [3:0] task_request;
    reg  [3:0] priority_in;
    wire [3:0] led;

    top uut (
        .clk         (clk),
        .reset       (reset),
        .task_request(task_request),
        .priority_in (priority_in),
        .led         (led)
    );

    always #5 clk = ~clk;

    initial begin
        clk          = 1'b0;
        reset        = 1'b1;
        task_request = 4'b0000;
        priority_in  = 4'b0000;

        $display("=== TB FINAL SYSTEM START ===");
        $monitor("t=%0t req=%b pri=%b state=%0d run_task=%0d run_pri=%b led=%b",
                 $time, task_request, priority_in,
                 uut.u_scheduler_fsm.state,
                 uut.u_scheduler_fsm.running_task,
                 uut.u_scheduler_fsm.running_priority,
                 led);

        #20;
        reset = 1'b0;

        $display("Final Scenario 1: Start task1 as low priority");
        @(posedge clk);
        task_request = 4'b0001;
        priority_in  = 4'b0000;
        @(posedge clk);
        task_request = 4'b0000;

        repeat (25) @(posedge clk);

        $display("Final Scenario 2 (Preemption Demo): task4 high priority interrupts");
        task_request = 4'b1000;
        priority_in  = 4'b1000;
        @(posedge clk);
        task_request = 4'b0000;
        priority_in  = 4'b0000;

        repeat (40) @(posedge clk);

        $display("=== TB FINAL SYSTEM END ===");
        $finish;
    end

endmodule
