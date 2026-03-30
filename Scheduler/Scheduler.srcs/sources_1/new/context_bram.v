`timescale 1ns / 1ps

module context_bram(
    input  wire       clk,
    input  wire       we,
    input  wire [1:0] addr,
    input  wire [7:0] din,
    output reg  [7:0] dout
);

    // Four-entry BRAM model used to store task contexts.

    reg [7:0] mem [0:3];
    integer i;

    initial begin
        for (i = 0; i < 4; i = i + 1) begin
            mem[i] = 8'd0;
        end
    end

    always @(posedge clk) begin
        if (we) begin
            mem[addr] <= din;
        end
        dout <= mem[addr];
    end

endmodule
