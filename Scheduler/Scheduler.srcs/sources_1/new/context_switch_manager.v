`timescale 1ns / 1ps

module context_switch_manager(
    input  wire       clk,
    input  wire       reset,
    input  wire       save_en,
    input  wire       restore_en,
    input  wire [1:0] save_task,
    input  wire [1:0] restore_task,
    output reg        bram_we,
    output reg  [1:0] bram_addr,
    output reg  [7:0] bram_din,
    input  wire [7:0] bram_dout,
    output reg  [7:0] live_context
);

    // Simple context model: counter value is considered task context.

    reg [7:0] context_counter;
    reg       restore_pending;

    always @(posedge clk) begin
        if (reset) begin
            bram_we         <= 1'b0;
            bram_addr       <= 2'd0;
            bram_din        <= 8'd0;
            live_context    <= 8'd0;
            context_counter <= 8'd0;
            restore_pending <= 1'b0;
        end else begin
            bram_we      <= 1'b0;
            live_context <= context_counter;

            if (save_en) begin
                bram_we   <= 1'b1;
                bram_addr <= save_task;
                bram_din  <= context_counter;
            end

            if (restore_en) begin
                bram_we         <= 1'b0;
                bram_addr       <= restore_task;
                restore_pending <= 1'b1;
            end else begin
                restore_pending <= 1'b0;
            end

            // BRAM read is synchronous, so restore one cycle after request.
            if (restore_pending) begin
                context_counter <= bram_dout;
                live_context    <= bram_dout;
            end else begin
                context_counter <= context_counter + 8'd1;
            end
        end
    end

endmodule
