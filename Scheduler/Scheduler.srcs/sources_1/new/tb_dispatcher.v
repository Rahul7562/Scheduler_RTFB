`timescale 1ns / 1ps

module tb_dispatcher;

    reg  [3:0] dispatch_enable;
    reg  [3:0] task_led_in;
    wire [3:0] task_enable;
    wire [3:0] led;

    task_dispatcher_mux uut (
        .dispatch_enable(dispatch_enable),
        .task_led_in    (task_led_in),
        .task_enable    (task_enable),
        .led            (led)
    );

    initial begin
        $display("=== TB DISPATCHER START ===");
        $monitor("t=%0t dispatch=%b task_led_in=%b task_enable=%b led=%b",
                 $time, dispatch_enable, task_led_in, task_enable, led);

        dispatch_enable = 4'b0000;
        task_led_in     = 4'b0000;
        #10;

        $display("Scenario 1: Run task1 LED only");
        dispatch_enable = 4'b0001;
        task_led_in     = 4'b1111;
        #10;

        $display("Scenario 2: Run task2 LED only");
        dispatch_enable = 4'b0010;
        task_led_in     = 4'b1111;
        #10;

        $display("Scenario 3 (Preemption Demo): Switch from task2 to task4");
        dispatch_enable = 4'b0010;
        task_led_in     = 4'b1111;
        #5;
        dispatch_enable = 4'b1000;
        task_led_in     = 4'b1111;
        #10;

        $display("=== TB DISPATCHER END ===");
        $finish;
    end

endmodule
