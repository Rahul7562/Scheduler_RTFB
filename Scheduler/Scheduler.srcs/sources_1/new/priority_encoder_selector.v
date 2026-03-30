`timescale 1ns / 1ps

module priority_encoder_selector(
    input  wire [3:0] pending_tasks,
    input  wire [3:0] priority_reg,
    output reg  [1:0] selected_task,
    output reg        selected_valid,
    output reg        selected_priority
);

    // Two-level selection: high-priority requests first, then normal requests.

    always @(*) begin
        selected_task     = 2'd0;
        selected_valid    = 1'b0;
        selected_priority = 1'b0;

        if (pending_tasks[3] && priority_reg[3]) begin
            selected_task     = 2'd3;
            selected_valid    = 1'b1;
            selected_priority = 1'b1;
        end else if (pending_tasks[2] && priority_reg[2]) begin
            selected_task     = 2'd2;
            selected_valid    = 1'b1;
            selected_priority = 1'b1;
        end else if (pending_tasks[1] && priority_reg[1]) begin
            selected_task     = 2'd1;
            selected_valid    = 1'b1;
            selected_priority = 1'b1;
        end else if (pending_tasks[0] && priority_reg[0]) begin
            selected_task     = 2'd0;
            selected_valid    = 1'b1;
            selected_priority = 1'b1;
        end else if (pending_tasks[3]) begin
            selected_task     = 2'd3;
            selected_valid    = 1'b1;
            selected_priority = 1'b0;
        end else if (pending_tasks[2]) begin
            selected_task     = 2'd2;
            selected_valid    = 1'b1;
            selected_priority = 1'b0;
        end else if (pending_tasks[1]) begin
            selected_task     = 2'd1;
            selected_valid    = 1'b1;
            selected_priority = 1'b0;
        end else if (pending_tasks[0]) begin
            selected_task     = 2'd0;
            selected_valid    = 1'b1;
            selected_priority = 1'b0;
        end
    end

endmodule
