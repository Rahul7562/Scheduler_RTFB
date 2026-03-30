`timescale 1ns / 1ps

module tb_preemption_logic;

    reg        running_valid;
    reg  [1:0] running_task;
    reg        running_priority;
    reg        candidate_valid;
    reg  [1:0] candidate_task;
    reg        candidate_priority;
    wire       preempt_required;

    preemption_comparator_logic uut (
        .running_valid     (running_valid),
        .running_task      (running_task),
        .running_priority  (running_priority),
        .candidate_valid   (candidate_valid),
        .candidate_task    (candidate_task),
        .candidate_priority(candidate_priority),
        .preempt_required  (preempt_required)
    );

    initial begin
        $display("=== TB PREEMPTION LOGIC START ===");
        $monitor("t=%0t run_v=%b run_t=%0d run_p=%b cand_v=%b cand_t=%0d cand_p=%b preempt=%b",
                 $time, running_valid, running_task, running_priority,
                 candidate_valid, candidate_task, candidate_priority, preempt_required);

        running_valid     = 1'b0;
        running_task      = 2'd0;
        running_priority  = 1'b0;
        candidate_valid   = 1'b0;
        candidate_task    = 2'd0;
        candidate_priority = 1'b0;
        #10;

        $display("Scenario 1: Running low priority, candidate low priority");
        running_valid      = 1'b1;
        running_task       = 2'd1;
        running_priority   = 1'b0;
        candidate_valid    = 1'b1;
        candidate_task     = 2'd2;
        candidate_priority = 1'b0;
        #10;

        $display("Scenario 2 (Preemption Demo): Candidate high priority arrives");
        candidate_task     = 2'd3;
        candidate_priority = 1'b1;
        #10;

        $display("Scenario 3: Same task should not preempt");
        candidate_task     = 2'd1;
        candidate_priority = 1'b1;
        #10;

        $display("=== TB PREEMPTION LOGIC END ===");
        $finish;
    end

endmodule
