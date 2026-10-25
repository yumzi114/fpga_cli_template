`timescale 1ns / 1ps
`default_nettype none

module pipeline4 (
    input wire logic clk,
    input wire logic rst,

    output logic [7:0] stage1_id,
    output logic [7:0] stage2_id,
    output logic [7:0] stage3_id,
    output logic [7:0] stage4_id,

    output logic [3:0] valid,

    output logic [15:0] result
);

    logic [7:0] counter;

    always_ff @(posedge clk) begin
        if (rst) begin
            counter <= 0;

            stage1_id <= 0;
            stage2_id <= 0;
            stage3_id <= 0;
            stage4_id <= 0;

            valid <= 0;
            result <= 0;
        end else begin

            // Stage 1: 새로운 데이터 생성
            stage1_id <= counter;
            counter <= counter + 1'b1;

            // Stage 2: 이전 데이터 전달
            stage2_id <= stage1_id;

            // Stage 3
            stage3_id <= stage2_id;

            // Stage 4
            stage4_id <= stage3_id;

            // 유효 신호도 파이프라인으로 이동
            valid <= {valid[2:0], 1'b1};

            // 마지막 단계의 데이터 계산
            result <= {8'd0, stage3_id} * 16'd2;

        end
    end

endmodule

`default_nettype wire