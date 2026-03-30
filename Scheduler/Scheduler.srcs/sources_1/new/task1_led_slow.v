`timescale 1ns / 1ps

module task1_led_slow(
    input  wire clk,
    input  wire reset,
    input  wire enable,
    output reg  led
);

    // Slow blink when enabled; forced OFF when not selected.

    parameter integer DIVIDER = 40;

    reg [7:0] count;

    always @(posedge clk) begin
        if (reset) begin
            count <= 8'd0;
            led   <= 1'b0;
        end else if (enable) begin
            if (count == (DIVIDER - 1)) begin
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
