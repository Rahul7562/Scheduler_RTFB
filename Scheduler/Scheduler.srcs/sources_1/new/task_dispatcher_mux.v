`timescale 1ns / 1ps

module task_dispatcher_mux(
    input  wire [3:0] dispatch_enable,
    input  wire [3:0] task_led_in,
    output reg  [3:0] task_enable,
    output reg  [3:0] led
);

    // Only the selected task is enabled and allowed to drive LED output.

    always @(*) begin
        task_enable = dispatch_enable;
        led         = task_led_in & dispatch_enable;
    end

endmodule
