`timescale 1ns / 1ps

module tb_task2;

    reg clk;
    reg reset;
    reg enable;
    wire led;

    task2_led_fast #(.DIVIDER(4)) uut (
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

        $display("=== TB TASK2 START ===");
        $monitor("t=%0t reset=%b enable=%b led=%b", $time, reset, enable, led);

        #20;
        reset = 1'b0;

        $display("Scenario 1: Task2 enabled (fast blink)");
        enable = 1'b1;
        #80;

        $display("Scenario 2 (Preemption Demo): Task2 preempted and disabled");
        enable = 1'b0;
        #30;

        $display("Scenario 3: Task2 resumed");
        enable = 1'b1;
        #60;

        $display("=== TB TASK2 END ===");
        $finish;
    end

endmodule
