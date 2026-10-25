`timescale 1ns / 1ps
`default_nettype none

module tb_pipeline4;

    logic clk = 0;
    logic rst = 1;

    wire [7:0] stage1_id;
    wire [7:0] stage2_id;
    wire [7:0] stage3_id;
    wire [7:0] stage4_id;

    wire [3:0] valid;
    wire [15:0] result;

    // 100MHz
    always #5 clk = ~clk;

    pipeline4 dut (
        .clk(clk),
        .rst(rst),

        .stage1_id(stage1_id),
        .stage2_id(stage2_id),
        .stage3_id(stage3_id),
        .stage4_id(stage4_id),

        .valid(valid),
        .result(result)
    );

    initial begin
        repeat (3) @(negedge clk);

        rst = 0;

        repeat (20) @(negedge clk);

        $finish;
    end

endmodule

`default_nettype wire