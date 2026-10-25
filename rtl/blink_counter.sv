`timescale 1ns / 1ps
`default_nettype none

module blink_counter #(
    parameter int unsigned HALF_PERIOD_TICKS = 20_000_000
) (
    input wire logic clk,
    input wire logic rst,
    output logic [1:0] led
);

  localparam int unsigned COUNT_BITS = (HALF_PERIOD_TICKS > 1) ? $clog2(HALF_PERIOD_TICKS) : 1;

  logic [COUNT_BITS-1:0] count = '0;
  logic phase = 1'b0;

  always_ff @(posedge clk) begin
    if (rst) begin
      count <= '0;
      phase <= 1'b0;
    end else if (count == HALF_PERIOD_TICKS - 1) begin
      count <= '0;
      phase <= ~phase;
    end else begin
      count <= count + 1'b1;
    end
  end

  assign led = {~phase, phase};

endmodule

`default_nettype wire
