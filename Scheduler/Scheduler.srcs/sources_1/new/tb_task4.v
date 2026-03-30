`timescale 1ns / 1ps

module tb_task4;

    reg clk;
    reg reset;
    reg enable;
    wire led;

    task4_led_pattern #(.STEP_DIV(3)) uut (
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

        $display("=== TB TASK4 START ===");
        $monitor("t=%0t reset=%b enable=%b led=%b", $time, reset, enable, led);

        #20;
        reset = 1'b0;

        $display("Scenario 1: Task4 enabled (pattern 1010)");
        enable = 1'b1;
        #100;

        $display("Scenario 2 (Preemption Demo): Task4 disabled");
        enable = 1'b0;
        #40;

        $display("Scenario 3: Task4 resumed");
        enable = 1'b1;
        #80;

        $display("=== TB TASK4 END ===");
        $finish;
    end

endmodule
