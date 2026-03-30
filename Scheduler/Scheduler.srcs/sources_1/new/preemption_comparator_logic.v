`timescale 1ns / 1ps

module preemption_comparator_logic(
    input  wire       running_valid,
    input  wire [1:0] running_task,
    input  wire       running_priority,
    input  wire       candidate_valid,
    input  wire [1:0] candidate_task,
    input  wire       candidate_priority,
    output wire       preempt_required
);

    // Preempt only when a different pending task has strictly higher priority.

    assign preempt_required = running_valid &&
                              candidate_valid &&
                              (candidate_task != running_task) &&
                              (candidate_priority > running_priority);

endmodule
