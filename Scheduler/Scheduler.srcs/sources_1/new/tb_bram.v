`timescale 1ns / 1ps

module tb_bram;

    reg        clk;
    reg        we;
    reg  [1:0] addr;
    reg  [7:0] din;
    wire [7:0] dout;

    context_bram uut (
        .clk (clk),
        .we  (we),
        .addr(addr),
        .din (din),
        .dout(dout)
    );

    always #5 clk = ~clk;

    initial begin
        clk  = 1'b0;
        we   = 1'b0;
        addr = 2'd0;
        din  = 8'd0;

        $display("=== TB BRAM START ===");
        $monitor("t=%0t we=%b addr=%0d din=%0d dout=%0d", $time, we, addr, din, dout);

        $display("Scenario 1: Write task contexts");
        @(posedge clk);
        we   = 1'b1;
        addr = 2'd0;
        din  = 8'd21;
        @(posedge clk);
        addr = 2'd3;
        din  = 8'd99;
        @(posedge clk);
        we   = 1'b0;

        $display("Scenario 2: Read back contexts");
        @(posedge clk);
        addr = 2'd0;
        @(posedge clk);
        addr = 2'd3;

        $display("Scenario 3 (Preemption Demo): Save preempted task and read it back");
        @(posedge clk);
        we   = 1'b1;
        addr = 2'd1;
        din  = 8'd55;
        @(posedge clk);
        we   = 1'b0;
        addr = 2'd1;

        #30;
        $display("=== TB BRAM END ===");
        $finish;
    end

endmodule
