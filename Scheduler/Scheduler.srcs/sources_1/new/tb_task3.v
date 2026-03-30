`timescale 1ns / 1ps

module tb_task3;

    reg clk;
    reg reset;
    reg enable;
    wire led;

    task3_led_toggle #(.TOGGLE_DIV(2)) uut (
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

        $display("=== TB TASK3 START ===");
        $monitor("t=%0t reset=%b enable=%b led=%b", $time, reset, enable, led);

        #20;
        reset = 1'b0;

        $display("Scenario 1: Task3 enabled (toggle)");
        enable = 1'b1;
        #60;

        $display("Scenario 2 (Preemption Demo): Task3 disabled due to higher priority");
        enable = 1'b0;
        #30;

        $display("Scenario 3: Task3 resumed");
        enable = 1'b1;
        #60;

        $display("=== TB TASK3 END ===");
        $finish;
    end

endmodule
