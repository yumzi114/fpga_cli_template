`timescale 1ns / 1ps
`default_nettype none

module tb_fsm_pipeline;
    logic clk = 0;
    logic rst = 1;
    logic start = 0;
    wire [1:0] state;
    wire [7:0] source_data, stage1_data;
    wire source_valid, stage1_valid;
    wire [8:0] result;
    wire result_valid;
    int expected_input = 0;
    int received = 0;

    always #5 clk = ~clk; // 100 MHz simulation clock.

    fsm_pipeline dut (.*);

    initial begin
        repeat (3) @(negedge clk);
        rst = 0;
        start = 1;
        wait (received == 8);
        @(negedge clk);
        $display("PASS: 8 pipeline outputs checked");
        $finish;
    end

    always @(negedge clk) begin
        if (!rst && result_valid) begin
            if (result !== ((expected_input + 3) * 2))
                $fatal(1, "Mismatch at item %0d: got %0d", expected_input, result);
            $display("time=%0t item=%0d result=%0d", $time, expected_input, result);
            expected_input++;
            received++;
        end
    end

    initial begin
        #2000;
        $fatal(1, "Timeout");
    end
endmodule

`default_nettype wire
