`timescale 1ns / 1ps

module tb_priority_encoder;

    reg  [3:0] pending_tasks;
    reg  [3:0] priority_reg;
    wire [1:0] selected_task;
    wire       selected_valid;
    wire       selected_priority;

    priority_encoder_selector uut (
        .pending_tasks    (pending_tasks),
        .priority_reg     (priority_reg),
        .selected_task    (selected_task),
        .selected_valid   (selected_valid),
        .selected_priority(selected_priority)
    );

    initial begin
        $display("=== TB PRIORITY ENCODER START ===");
        $monitor("t=%0t pending=%b pri=%b -> valid=%b task=%0d sel_pri=%b",
                 $time, pending_tasks, priority_reg, selected_valid, selected_task, selected_priority);

        pending_tasks = 4'b0000;
        priority_reg  = 4'b0000;
        #10;

        $display("Scenario 1: Low-priority only requests");
        pending_tasks = 4'b0011;
        priority_reg  = 4'b0000;
        #10;

        $display("Scenario 2: High-priority request present");
        pending_tasks = 4'b0111;
        priority_reg  = 4'b0100;
        #10;

        $display("Scenario 3 (Preemption Demo): New highest high-priority arrives");
        pending_tasks = 4'b1111;
        priority_reg  = 4'b1000;
        #10;

        $display("Scenario 4: No requests");
        pending_tasks = 4'b0000;
        priority_reg  = 4'b0000;
        #10;

        $display("=== TB PRIORITY ENCODER END ===");
        $finish;
    end

endmodule
