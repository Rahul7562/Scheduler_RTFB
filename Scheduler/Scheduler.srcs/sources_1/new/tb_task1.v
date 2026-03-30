`timescale 1ns / 1ps

module tb_task1;

    reg clk;
    reg reset;
    reg enable;
    wire led;

    task1_led_slow #(.DIVIDER(10)) uut (
        .clk   (clk),
        .reset (reset),
        .enable(enable),
        .led   (led)
    );

    always #5 clk = ~clk;

    initial begin
        clk    = 1'b0;
        reset  = 1'b1;
        enable = 1'b0;

        $display("=== TB TASK1 START ===");
        $monitor("t=%0t reset=%b enable=%b led=%b", $time, reset, enable, led);

        #20;
        reset = 1'b0;

        $display("Scenario 1: Task1 enabled (slow blink)");
        enable = 1'b1;
        #120;

        $display("Scenario 2 (Preemption Demo): Task1 disabled by scheduler");
        enable = 1'b0;
        #40;

        $display("Scenario 3: Task1 resumed");
        enable = 1'b1;
        #80;

        $display("=== TB TASK1 END ===");
        $finish;
    end

endmodule
