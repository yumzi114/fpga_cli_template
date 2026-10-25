`timescale 1ns / 1ps
`default_nettype none

module fsm_pipeline (
    input  wire logic       clk,
    input  wire logic       rst,
    input  wire logic       start,
    output      logic [1:0] state,
    output      logic [7:0] source_data,
    output      logic       source_valid,
    output      logic [7:0] stage1_data,
    output      logic       stage1_valid,
    output      logic [8:0] result,
    output      logic       result_valid
);
    localparam logic [1:0] IDLE = 2'd0, SEND = 2'd1, DONE = 2'd2;
    logic [3:0] index;

    // FSM: on start, generate eight consecutive data words (0..7).
    always_ff @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
            index <= 0;
            source_data <= 0;
            source_valid <= 0;
        end else begin
            source_valid <= 0;
            case (state)
                IDLE: if (start) begin
                    index <= 0;
                    state <= SEND;
                end
                SEND: begin
                    source_data <= {4'b0000, index};
                    source_valid <= 1;
                    if (index == 7)
                        state <= DONE;
                    else
                        index <= index + 1'b1;
                end
                DONE: if (!start) state <= IDLE;
                default: state <= IDLE;
            endcase
        end
    end

    // Pipeline stage 1: x + 3.
    always_ff @(posedge clk) begin
        if (rst) begin
            stage1_data <= 0;
            stage1_valid <= 0;
        end else begin
            stage1_valid <= source_valid;
            if (source_valid) stage1_data <= source_data + 8'd3;
        end
    end

    // Pipeline stage 2: (x + 3) * 2.
    always_ff @(posedge clk) begin
        if (rst) begin
            result <= 0;
            result_valid <= 0;
        end else begin
            result_valid <= stage1_valid;
            if (stage1_valid) result <= {stage1_data, 1'b0};
        end
    end
endmodule

`default_nettype wire
