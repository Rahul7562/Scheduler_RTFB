`timescale 1ns / 1ps

module tb_context_switch;

    reg        clk;
    reg        reset;
    reg        save_en;
    reg        restore_en;
    reg  [1:0] save_task;
    reg  [1:0] restore_task;

    wire       bram_we;
    wire [1:0] bram_addr;
    wire [7:0] bram_din;
    wire [7:0] bram_dout;
    wire [7:0] live_context;

    context_switch_manager uut (
        .clk         (clk),
        .reset       (reset),
        .save_en     (save_en),
        .restore_en  (restore_en),
        .save_task   (save_task),
        .restore_task(restore_task),
        .bram_we     (bram_we),
        .bram_addr   (bram_addr),
        .bram_din    (bram_din),
        .bram_dout   (bram_dout),
        .live_context(live_context)
    );

    context_bram u_bram (
        .clk (clk),
        .we  (bram_we),
        .addr(bram_addr),
        .din (bram_din),
        .dout(bram_dout)
    );

    always #5 clk = ~clk;

    initial begin
        clk          = 1'b0;
        reset        = 1'b1;
        save_en      = 1'b0;
        restore_en   = 1'b0;
        save_task    = 2'd0;
        restore_task = 2'd0;

        $display("=== TB CONTEXT SWITCH START ===");
        $monitor("t=%0t save=%b restore=%b save_t=%0d restore_t=%0d bram_we=%b addr=%0d din=%0d dout=%0d live=%0d",
                 $time, save_en, restore_en, save_task, restore_task,
                 bram_we, bram_addr, bram_din, bram_dout, live_context);

        #20;
        reset = 1'b0;

        repeat (5) @(posedge clk);

        $display("Scenario 1: Save context of task1");
        save_task = 2'd0;
        save_en   = 1'b1;
        @(posedge clk);
        save_en   = 1'b0;

        repeat (3) @(posedge clk);

        $display("Scenario 2 (Preemption Demo): Save running task1 and restore task4");
        save_task    = 2'd0;
        save_en      = 1'b1;
        restore_task = 2'd3;
        restore_en   = 1'b1;
        @(posedge clk);
        save_en      = 1'b0;
        restore_en   = 1'b0;

        repeat (4) @(posedge clk);

        $display("Scenario 3: Restore task1 context");
        restore_task = 2'd0;
        restore_en   = 1'b1;
        @(posedge clk);
        restore_en   = 1'b0;

        #40;
        $display("=== TB CONTEXT SWITCH END ===");
        $finish;
    end

endmodule
