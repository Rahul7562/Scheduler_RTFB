`timescale 1ns / 1ps

module task_queue_status(
    input  wire       clk,
    input  wire       reset,
    input  wire [3:0] task_request,
    input  wire [3:0] priority_in,
    input  wire [3:0] clear_task,
    input  wire [3:0] requeue_task,
    input  wire [3:0] requeue_priority,
    output reg  [3:0] pending_tasks,
    output reg  [3:0] priority_reg
);

    // Pending bits and 1-bit priority are updated synchronously.

    always @(posedge clk) begin
        if (reset) begin
            pending_tasks <= 4'b0000;
            priority_reg  <= 4'b0000;
        end else begin
            pending_tasks <= (pending_tasks | task_request | requeue_task) & ~clear_task;

            priority_reg <= ((priority_reg & ~(task_request | requeue_task | clear_task)) |
                             (priority_in & task_request) |
                             (requeue_priority & requeue_task));
        end
    end

endmodule
