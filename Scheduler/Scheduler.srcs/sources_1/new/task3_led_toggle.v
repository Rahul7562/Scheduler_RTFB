`timescale 1ns / 1ps

module task3_led_toggle(
    input  wire clk,
    input  wire reset,
    input  wire enable,
    output reg  led
);

    // Periodic toggle task when enabled; OFF when disabled.

    parameter integer TOGGLE_DIV = 4;

    reg [7:0] count;

    always @(posedge clk) begin
        if (reset) begin
            count <= 8'd0;
            led   <= 1'b0;
        end else if (enable) begin
            if (count == (TOGGLE_DIV - 1)) begin
                count <= 8'd0;
                led   <= ~led;
            end else begin
                count <= count + 8'd1;
            end
        end else begin
            count <= 8'd0;
            led   <= 1'b0;
        end
    end

endmodule
