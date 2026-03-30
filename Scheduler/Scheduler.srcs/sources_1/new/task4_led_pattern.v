`timescale 1ns / 1ps

module task4_led_pattern(
    input  wire clk,
    input  wire reset,
    input  wire enable,
    output reg  led
);

    // Generates a repeating 1-0-1-0 sequence while enabled.

    parameter integer STEP_DIV = 6;

    reg [7:0] count;
    reg [1:0] pattern_index;

    always @(posedge clk) begin
        if (reset) begin
            count         <= 8'd0;
            pattern_index <= 2'd0;
            led           <= 1'b0;
        end else if (enable) begin
            if (count == (STEP_DIV - 1)) begin
                count <= 8'd0;

                case (pattern_index)
                    2'd0: led <= 1'b1;
                    2'd1: led <= 1'b0;
                    2'd2: led <= 1'b1;
                    2'd3: led <= 1'b0;
                    default: led <= 1'b0;
                endcase

                pattern_index <= pattern_index + 2'd1;
            end else begin
                count <= count + 8'd1;
            end
        end else begin
            count         <= 8'd0;
            pattern_index <= 2'd0;
            led           <= 1'b0;
        end
    end

endmodule
