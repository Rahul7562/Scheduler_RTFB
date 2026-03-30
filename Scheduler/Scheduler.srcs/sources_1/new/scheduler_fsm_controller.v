`timescale 1ns / 1ps

module scheduler_fsm_controller(
    input  wire       clk,
    input  wire       reset,
    input  wire       selected_valid,
    input  wire [1:0] selected_task,
    input  wire       selected_priority,
    input  wire       preempt_required,
    output reg  [2:0] state,
    output reg        running_valid,
    output reg  [1:0] running_task,
    output reg        running_priority,
    output reg  [3:0] dispatch_enable,
    output reg  [3:0] clear_task_mask,
    output reg  [3:0] requeue_task_mask,
    output reg        context_save,
    output reg        context_restore
);

    // Required scheduler states.

    localparam IDLE           = 3'd0;
    localparam SELECT_TASK    = 3'd1;
    localparam RUN_TASK       = 3'd2;
    localparam PREEMPT        = 3'd3;
    localparam CONTEXT_SWITCH = 3'd4;

    reg [2:0] next_state;

    // Utility for decoder-style one-hot task control signals.
    function [3:0] task_to_onehot;
        input [1:0] task_id;
        begin
            case (task_id)
                2'd0: task_to_onehot = 4'b0001;
                2'd1: task_to_onehot = 4'b0010;
                2'd2: task_to_onehot = 4'b0100;
                2'd3: task_to_onehot = 4'b1000;
                default: task_to_onehot = 4'b0000;
            endcase
        end
    endfunction

    // Next-state logic.
    always @(*) begin
        next_state = state;

        case (state)
            IDLE: begin
                if (selected_valid) begin
                    next_state = SELECT_TASK;
                end
            end

            SELECT_TASK: begin
                next_state = RUN_TASK;
            end

            RUN_TASK: begin
                if (preempt_required) begin
                    next_state = PREEMPT;
                end
            end

            PREEMPT: begin
                next_state = CONTEXT_SWITCH;
            end

            CONTEXT_SWITCH: begin
                if (selected_valid) begin
                    next_state = RUN_TASK;
                end else begin
                    next_state = IDLE;
                end
            end

            default: begin
                next_state = IDLE;
            end
        endcase
    end

    // Sequential state and running-task context registers.
    always @(posedge clk) begin
        if (reset) begin
            state             <= IDLE;
            running_valid     <= 1'b0;
            running_task      <= 2'd0;
            running_priority  <= 1'b0;
        end else begin
            state <= next_state;

            case (state)
                IDLE: begin
                    if (selected_valid) begin
                        running_valid    <= 1'b1;
                        running_task     <= selected_task;
                        running_priority <= selected_priority;
                    end else begin
                        running_valid    <= 1'b0;
                        running_task     <= 2'd0;
                        running_priority <= 1'b0;
                    end
                end

                SELECT_TASK: begin
                    running_valid    <= selected_valid;
                    running_task     <= selected_task;
                    running_priority <= selected_priority;
                end

                RUN_TASK: begin
                    running_valid    <= running_valid;
                    running_task     <= running_task;
                    running_priority <= running_priority;
                end

                PREEMPT: begin
                    running_valid    <= running_valid;
                    running_task     <= running_task;
                    running_priority <= running_priority;
                end

                CONTEXT_SWITCH: begin
                    running_valid    <= selected_valid;
                    running_task     <= selected_task;
                    running_priority <= selected_priority;
                end

                default: begin
                    running_valid    <= 1'b0;
                    running_task     <= 2'd0;
                    running_priority <= 1'b0;
                end
            endcase
        end
    end

    // Output logic for dispatcher, queue control, and context operations.
    always @(*) begin
        dispatch_enable  = 4'b0000;
        clear_task_mask  = 4'b0000;
        requeue_task_mask = 4'b0000;
        context_save     = 1'b0;
        context_restore  = 1'b0;

        case (state)
            SELECT_TASK: begin
                clear_task_mask = task_to_onehot(selected_task);
                context_restore = 1'b1;
            end

            RUN_TASK: begin
                if (running_valid) begin
                    dispatch_enable = task_to_onehot(running_task);
                end
            end

            PREEMPT: begin
                context_save = 1'b1;
                if (running_valid) begin
                    requeue_task_mask = task_to_onehot(running_task);
                end
            end

            CONTEXT_SWITCH: begin
                clear_task_mask = task_to_onehot(selected_task);
                context_restore = 1'b1;
            end

            default: begin
            end
        endcase
    end

endmodule
