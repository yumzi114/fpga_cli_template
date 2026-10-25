`timescale 1ns / 1ps

module tb_blink_counter;

    logic clk = 1'b0;
    logic rst = 1'b1;
    logic [1:0] led;

    // 200MHz = 5ns period
    always #2.5 clk = ~clk;

    blink_counter #(
        .HALF_PERIOD_TICKS(4)
    ) dut (
        .clk(clk),
        .rst(rst),
        .led(led)
    );

    initial begin
        $display("Starting blink simulation");

        repeat (2) @(negedge clk);
        rst = 1'b0;

        for (int i = 1; i <= 20; i++) begin
            @(posedge clk);
            #0.001;

            if (led[0] !== ((i / 4) % 2)) begin
                $fatal(1, "LED mismatch at cycle %0d", i);
            end
        end

        $display("PASS: LED toggled correctly");
        $finish;
    end

endmodule